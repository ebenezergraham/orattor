import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../audio.dart';
import '../curriculum.dart';
import '../state.dart';
import '../theme.dart';

class TrackPage extends StatefulWidget {
  final Track track;
  const TrackPage(this.track, {super.key});
  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  @override
  Widget build(BuildContext context) {
    final t = widget.track;
    final s = AppState.I;
    final done = t.lessons.where((l) => s.programLessons.contains(t.key(l))).length;
    return Scaffold(
      appBar: AppBar(backgroundColor: VI.surface, title: Text(t.name)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Text(t.blurb, style: const TextStyle(fontSize: 16, color: VI.muted)),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                  value: done / t.lessons.length, color: VI.primary, backgroundColor: VI.border, minHeight: 8),
              const SizedBox(height: 4),
              Text('$done of ${t.lessons.length} lessons done', style: const TextStyle(color: VI.muted)),
              if (t.note != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: VI.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: VI.border)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.info_outline_rounded, color: VI.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(t.note!, style: const TextStyle(height: 1.4))),
                  ]),
                ),
              ],
              const SizedBox(height: 16),
              for (var i = 0; i < t.lessons.length; i++)
                Card(
                  child: ListTile(
                    leading: Icon(
                      s.programLessons.contains(t.key(t.lessons[i])) ? Icons.check_circle : Icons.circle_outlined,
                      color: s.programLessons.contains(t.key(t.lessons[i])) ? VI.success : VI.muted,
                    ),
                    title: Text('${i + 1}. ${t.lessons[i].title}'),
                    subtitle: Text('${t.lessons[i].minutes} min • ${t.lessons[i].steps.length} steps'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => LessonPage(t, t.lessons[i])))
                        .then((_) => setState(() {})),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class LessonPage extends StatefulWidget {
  final Track track;
  final Lesson lesson;
  const LessonPage(this.track, this.lesson, {super.key});
  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  bool get _done => AppState.I.programLessons.contains(widget.track.key(widget.lesson));

  Widget _heading(String t) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    return Scaffold(
      appBar: AppBar(backgroundColor: VI.surface, title: Text(l.title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Text('${l.minutes} min • ${l.steps.length} steps', style: const TextStyle(color: VI.muted)),
              _heading('Why this matters'),
              Text(l.why, style: const TextStyle(fontSize: 16, height: 1.45)),
              _heading('Do this'),
              for (var i = 0; i < l.steps.length; i++) _StepTile(i + 1, l.steps[i]),
              if (l.measure != Measure.none) ...[
                _heading('Try it and measure'),
                MeasureCard(l.measure),
              ],
              _heading("You'll know it's working when"),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_circle_outline, color: VI.success, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(l.success, style: const TextStyle(fontSize: 16, height: 1.4))),
              ]),
              if (l.mistakes.isNotEmpty) ...[
                _heading('Common mistakes'),
                for (final m in l.mistakes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.warning_amber_rounded, color: VI.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m, style: const TextStyle(height: 1.4))),
                    ]),
                  ),
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _done
                    ? null
                    : () {
                        AppState.I.completeProgramLesson(widget.track.key(l));
                        setState(() {});
                      },
                icon: Icon(_done ? Icons.check : Icons.flag_rounded),
                label: Text(_done ? 'Completed' : 'Mark lesson complete (+20 XP)'),
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatefulWidget {
  final int n;
  final LessonStep step;
  const _StepTile(this.n, this.step);
  @override
  State<_StepTile> createState() => _StepTileState();
}

class _StepTileState extends State<_StepTile> {
  Timer? _t;
  int _left = 0;
  bool _checked = false;

  void _start() {
    _t?.cancel();
    setState(() => _left = widget.step.seconds);
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _left--);
      if (_left <= 0) {
        t.cancel();
        setState(() => _checked = true);
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secs = widget.step.seconds;
    final running = _left > 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: () => setState(() => _checked = !_checked),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: _checked ? VI.success : VI.border,
              foregroundColor: _checked ? Colors.black : Colors.white,
              child: _checked
                  ? const Icon(Icons.check, size: 16)
                  : Text('${widget.n}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.step.text, style: const TextStyle(fontSize: 16, height: 1.4)),
              if (secs > 0) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: running ? null : _start,
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: Text(running ? '$_left s left' : 'Start $secs s timer'),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Records the user speaking and reports the metric a lesson cares about.
class MeasureCard extends StatefulWidget {
  final Measure kind;
  const MeasureCard(this.kind, {super.key});
  @override
  State<MeasureCard> createState() => _MeasureCardState();
}

class _MeasureCardState extends State<MeasureCard> {
  final rec = VoiceRecorder();
  bool on = false;
  VoiceMetrics? result;
  String? error;

  Future<void> _toggle() async {
    if (on) {
      final m = await rec.stop();
      setState(() {
        on = false;
        result = m;
      });
      return;
    }
    final ok = await rec.start().catchError((_) => false);
    if (!ok) {
      setState(() => error = 'Microphone unavailable or permission denied.');
      return;
    }
    setState(() {
      on = true;
      error = null;
      result = null;
    });
  }

  @override
  void dispose() {
    rec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = switch (widget.kind) {
      Measure.pitch => 'Read a paragraph or count to 20 in your normal voice, then stop.',
      Measure.loudness => 'Say "Good evening, everyone" at the level you are practicing, then stop. Keep your phone at the same distance each time.',
      _ => 'Read a paragraph at your natural pace for about 30 seconds, then stop.',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(prompt, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 12),
          if (on)
            ValueListenableBuilder<double>(
              valueListenable: rec.liveLevel,
              builder: (_, v, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(value: v, color: VI.primary, backgroundColor: VI.border, minHeight: 8),
              ),
            ),
          FilledButton.icon(
            onPressed: _toggle,
            icon: Icon(on ? Icons.stop_rounded : Icons.mic_rounded),
            label: Text(on ? 'Stop and measure' : 'Record'),
          ),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: Color(0xFFF97066)))),
          if (result != null) ...[
            const Divider(height: 28),
            Text(describeMeasure(widget.kind, result!), style: const TextStyle(fontSize: 15, height: 1.45)),
          ],
        ]),
      ),
    );
  }
}

/// Plain-language reading of a recording for one metric. Public for testing.
String describeMeasure(Measure kind, VoiceMetrics m) {
  if (!m.hasVoice || m.seconds < 2) {
    return "I didn't hear enough voice. Try again a bit closer to the microphone and speak for a few seconds.";
  }
  switch (kind) {
    case Measure.pitch:
      final midi = (69 + 12 * log(m.meanPitch / 440) / ln2).round();
      final hz = m.meanPitch.round();
      final base = 'Average speaking pitch: $hz Hz (${noteName(midi)}). ';
      if (m.meanPitch < 80) {
        return '${base}That is very low. If it felt crackly or effortful, you may be in vocal fry. Come up a couple of notes to where it feels easy and clear.';
      }
      if (m.meanPitch > 165) {
        return '${base}Typical adult male speech is roughly 85 to 155 Hz. Try a yawn-sigh and then speak again, letting the pitch settle down only as far as feels easy. Compare the two numbers.';
      }
      return '${base}That is inside the typical adult male range of about 85 to 155 Hz. What matters is that it feels easy and rings. Record again after a yawn-sigh and compare.';
    case Measure.loudness:
      return 'Level: ${m.loudnessDb.toStringAsFixed(0)} dBFS. This number depends on your phone and distance, so only compare attempts at the same distance. A louder attempt should be a less negative number. Keep your pitch steady and your throat relaxed as you go up.';
    case Measure.pace:
      final wpm = (m.syllablesPerSec * 60 / 1.4).round();
      final verdict = wpm > 170
          ? 'That is fast. Add short pauses at commas and full stops.'
          : wpm < 110
              ? 'That is slow. Keep the energy up and trim long gaps.'
              : 'That is a comfortable pace.';
      return 'Estimated pace: about $wpm words per minute (a rough estimate from syllable rhythm). Pauses noticed: ${m.pauses}. A good presenting range is about 130 to 160. $verdict';
    case Measure.none:
      return '';
  }
}
