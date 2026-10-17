import 'package:flutter/material.dart';
import 'audio.dart';
import 'state.dart';
import 'theme.dart';

Widget scoreBars(Map<String, num> scores) => Column(children: [
      for (final e in scores.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(e.key), Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w700))]),
            const SizedBox(height: 4),
            if (e.value <= 100 && !e.key.contains('Hz') && !e.key.contains('Words') && !e.key.contains('age'))
              LinearProgressIndicator(
                  value: e.value / 100, color: VI.primary, backgroundColor: VI.border, minHeight: 8),
          ]),
        ),
    ]);

class ResultCard extends StatelessWidget {
  final Result r;
  const ResultCard(this.r, {super.key});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.headline, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: VI.primary)),
            const SizedBox(height: 16),
            scoreBars(r.scores),
          ]),
        ),
      );
}

/// Mic recorder with live pitch + level. Calls [onDone] with metrics.
class RecordPanel extends StatefulWidget {
  final int maxSeconds;
  final void Function(VoiceMetrics) onDone;
  const RecordPanel({super.key, this.maxSeconds = 15, required this.onDone});
  @override
  State<RecordPanel> createState() => _RecordPanelState();
}

class _RecordPanelState extends State<RecordPanel> {
  final rec = VoiceRecorder();
  bool on = false;
  int sec = 0;
  String? error;

  Future<void> _toggle() async {
    if (!on) {
      final ok = await rec.start().catchError((_) => false);
      if (!ok) {
        setState(() => error = 'Microphone unavailable or permission denied.');
        return;
      }
      setState(() {
        on = true;
        sec = 0;
        error = null;
      });
      _tick();
    } else {
      await _finish();
    }
  }

  Future<void> _tick() async {
    while (on && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!on || !mounted) return;
      setState(() => sec++);
      if (sec >= widget.maxSeconds) await _finish();
    }
  }

  Future<void> _finish() async {
    if (!on) return;
    setState(() => on = false);
    final m = await rec.stop();
    if (!mounted) return;
    if (!m.hasVoice) {
      setState(() => error = "We didn't hear your voice. Try again closer to the mic.");
      return;
    }
    widget.onDone(m);
  }

  @override
  void dispose() {
    on = false;
    rec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: on ? 108 : 96,
            height: on ? 108 : 96,
            decoration: BoxDecoration(shape: BoxShape.circle, color: on ? const Color(0xFFD92D20) : VI.primary),
            child: Icon(on ? Icons.stop_rounded : Icons.mic_rounded, size: 44, color: const Color(0xFF171723)),
          ),
        ),
        const SizedBox(height: 12),
        Text(on ? 'Recording… ${sec}s / ${widget.maxSeconds}s' : 'Tap to record',
            style: const TextStyle(color: VI.muted)),
        if (on)
          ValueListenableBuilder<double>(
            valueListenable: rec.liveLevel,
            builder: (_, v, __) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(value: v, color: VI.action, backgroundColor: VI.border, minHeight: 6),
            ),
          ),
        if (on)
          ValueListenableBuilder<double>(
            valueListenable: rec.livePitch,
            builder: (_, v, __) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(v > 0 ? '${v.round()} Hz' : '—', style: const TextStyle(color: VI.muted)),
            ),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(error!, style: const TextStyle(color: Color(0xFFF57469)), textAlign: TextAlign.center),
          ),
      ]);
}
