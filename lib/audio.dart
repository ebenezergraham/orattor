import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

/// Summary of one recording, computed on-device.
class VoiceMetrics {
  final double meanPitch; // Hz, 0 if no voiced frames
  final double pitchStd; // Hz
  final double loudnessDb; // mean dBFS of voiced frames
  final double voicedRatio; // 0..1
  final double syllablesPerSec; // energy-peak rate
  final int pauses; // silent gaps > 0.4s inside speech
  final double seconds;
  const VoiceMetrics(this.meanPitch, this.pitchStd, this.loudnessDb, this.voicedRatio,
      this.syllablesPerSec, this.pauses, this.seconds);
  bool get hasVoice => voicedRatio > 0.05 && meanPitch > 0;
}

/// Streaming pitch/energy analyzer (autocorrelation, 16 kHz mono PCM16).
class VoiceRecorder {
  static const sampleRate = 16000;
  static const _win = 1024, _hop = 512;
  final _rec = AudioRecorder();
  StreamSubscription<Uint8List>? _sub;
  final livePitch = ValueNotifier<double>(0);
  final liveLevel = ValueNotifier<double>(0); // 0..1
  final _buf = <double>[];
  final _pitches = <double>[], _dbs = <double>[], _rms = <double>[];
  int _frames = 0, _voiced = 0;

  Future<bool> start() async {
    if (!await _rec.hasPermission()) return false;
    _buf.clear();
    _pitches.clear();
    _dbs.clear();
    _rms.clear();
    _frames = _voiced = 0;
    final s = await _rec.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits, sampleRate: sampleRate, numChannels: 1));
    _sub = s.listen(_onData);
    return true;
  }

  void _onData(Uint8List bytes) {
    final bd = ByteData.sublistView(bytes);
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      _buf.add(bd.getInt16(i, Endian.little) / 32768.0);
    }
    while (_buf.length >= _win) {
      _frame(_buf.sublist(0, _win));
      _buf.removeRange(0, _hop);
    }
  }

  void _frame(List<double> x) {
    _frames++;
    var e = 0.0;
    for (final v in x) {
      e += v * v;
    }
    final rms = sqrt(e / x.length);
    _rms.add(rms);
    liveLevel.value = (rms * 8).clamp(0, 1).toDouble();
    if (rms < 0.01) {
      livePitch.value = 0;
      return;
    }
    final f = pitchOf(x, sampleRate);
    if (f > 0) {
      _voiced++;
      _pitches.add(f);
      _dbs.add(20 * log(rms) / ln10);
      livePitch.value = f;
    }
  }

  /// Autocorrelation pitch in 70–420 Hz. Returns 0 when unvoiced.
  static double pitchOf(List<double> x, int sr) {
    final minLag = sr ~/ 420, maxLag = min(sr ~/ 70, x.length - 1);
    var r0 = 0.0;
    for (final v in x) {
      r0 += v * v;
    }
    if (r0 == 0) return 0;
    var best = 0.0;
    var bestLag = 0;
    for (var lag = minLag; lag <= maxLag; lag++) {
      var s = 0.0;
      for (var i = 0; i + lag < x.length; i++) {
        s += x[i] * x[i + lag];
      }
      if (s > best) {
        best = s;
        bestLag = lag;
      }
    }
    return best / r0 > 0.35 && bestLag > 0 ? sr / bestLag : 0;
  }

  Future<VoiceMetrics> stop() async {
    await _sub?.cancel();
    await _rec.stop();
    livePitch.value = 0;
    liveLevel.value = 0;
    final secs = _frames * _hop / sampleRate;
    final mean = _pitches.isEmpty ? 0.0 : _pitches.reduce((a, b) => a + b) / _pitches.length;
    final std = _pitches.length < 2
        ? 0.0
        : sqrt(_pitches.map((p) => (p - mean) * (p - mean)).reduce((a, b) => a + b) / _pitches.length);
    final db = _dbs.isEmpty ? -60.0 : _dbs.reduce((a, b) => a + b) / _dbs.length;
    // Syllable proxy: local maxima of smoothed energy above a threshold.
    var peaks = 0, pauses = 0, silentRun = 0, seenSpeech = false;
    for (var i = 2; i < _rms.length - 2; i++) {
      final a = (_rms[i - 2] + _rms[i - 1] + _rms[i]) / 3;
      final b = (_rms[i - 1] + _rms[i] + _rms[i + 1]) / 3;
      final c = (_rms[i] + _rms[i + 1] + _rms[i + 2]) / 3;
      if (b > a && b >= c && b > 0.02) peaks++;
    }
    for (final r in _rms) {
      if (r < 0.01) {
        silentRun++;
      } else {
        if (seenSpeech && silentRun * _hop / sampleRate > 0.4) pauses++;
        silentRun = 0;
        seenSpeech = true;
      }
    }
    return VoiceMetrics(mean, std, db, _frames == 0 ? 0 : _voiced / _frames,
        secs == 0 ? 0 : peaks / secs, pauses, secs);
  }

  void dispose() {
    _sub?.cancel();
    _rec.dispose();
  }
}

const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
double noteFreq(int midi) => 440.0 * pow(2, (midi - 69) / 12).toDouble();
String noteName(int midi) => '${noteNames[midi % 12]}${midi ~/ 12 - 1}';
