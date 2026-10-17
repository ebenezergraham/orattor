import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../audio.dart';
import '../data.dart';
import '../state.dart';
import '../theme.dart';
import 'tests.dart';

class TrainHub extends StatelessWidget {
  const TrainHub({super.key});
  @override
  Widget build(BuildContext context) {
    void go(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    final items = <(Feature, Widget)>[
      (features[0], const RoleplayPage()),
      (features[1], const TongueTwisterPage()),
      (features[2], const PitchTrainerPage()),
      (features[3], const BreathingPage()),
      (features[4], const ShortsPage()),
      (features[5], const ArenaPage()),
    ];
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Train', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      for (final it in items)
        Card(
          child: ListTile(
            leading: Icon(it.$1.icon, color: VI.primary),
            title: Text(it.$1.title),
            subtitle: Text(it.$1.body),
            onTap: () => go(it.$2),
          ),
        ),
    ]);
  }
}

// ---------- Breathing & Calm ----------
class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});
  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> with SingleTickerProviderStateMixin {
  // 4-4-6 pattern: inhale, hold, exhale.
  static const phases = [('Breathe in', 4), ('Hold', 4), ('Breathe out', 6)];
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  bool running = false;
  int cycles = 0, phase = 0;
  static const target = 5;
  Timer? t;

  void _run() {
    running = true;
    cycles = 0;
    phase = -1;
    _next();
  }

  void _next() {
    if (!running || !mounted) return;
    phase = (phase + 1) % 3;
    if (phase == 0 && cycles >= target) {
      running = false;
      AppState.I.completeTask('breathing');
      setState(() {});
      return;
    }
    final secs = phases[phase].$2;
    c.duration = Duration(seconds: secs);
    if (phase == 0) c.forward(from: 0);
    if (phase == 2) c.reverse(from: 1);
    setState(() {});
    t = Timer(Duration(seconds: secs), () {
      if (phase == 2) cycles++;
      _next();
    });
  }

  @override
  void dispose() {
    running = false;
    t?.cancel();
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: VI.surface, title: const Text('Breathing & Calm')),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedBuilder(
              animation: c,
              builder: (_, __) => Container(
                width: 120 + 120 * c.value,
                height: 120 + 120 * c.value,
                decoration: BoxDecoration(shape: BoxShape.circle, color: VI.action.withValues(alpha: .35 + .4 * c.value)),
              ),
            ),
            const SizedBox(height: 32),
            Text(running ? phases[phase].$1 : (cycles >= target ? 'Well done. You feel calmer.' : 'Slow, even breaths calm nerves.'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Cycle ${min(cycles + 1, target)} of $target', style: const TextStyle(color: VI.muted)),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: running ? null : _run, child: Text(cycles >= target ? 'Again' : 'Start')),
          ]),
        ),
      );
}

// ---------- Intonation / pitch trainer ----------
class PitchTrainerPage extends StatefulWidget {
  const PitchTrainerPage({super.key});
  @override
  State<PitchTrainerPage> createState() => _PitchTrainerPageState();
}

class _PitchTrainerPageState extends State<PitchTrainerPage> {
  final rec = VoiceRecorder();
  bool on = false;
  int midi = 55; // G3
  int hits = 0;
  double held = 0;
  String? error;
  Timer? t;

  Future<void> _toggle() async {
    if (on) {
      t?.cancel();
      await rec.stop();
      setState(() => on = false);
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
      hits = 0;
    });
    t = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final f = rec.livePitch.value;
      final cents = f > 0 ? 1200 * log(f / noteFreq(midi)) / ln2 : 999.0;
      if (cents.abs() < 50) {
        held += .1;
        if (held >= 1.0) {
          held = 0;
          hits++;
          midi = 48 + Random().nextInt(17);
          if (hits == 5) AppState.I.completeTask('pitch');
        }
      } else {
        held = 0;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    t?.cancel();
    rec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = rec.livePitch.value;
    final cents = f > 0 ? (1200 * log(f / noteFreq(midi)) / ln2).clamp(-600, 600).toDouble() : null;
    return Scaffold(
      appBar: AppBar(backgroundColor: VI.surface, title: const Text('Intonation')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Match the target note by humming or singing', style: TextStyle(color: VI.muted)),
              const SizedBox(height: 12),
              Text(noteName(midi), style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w800, color: VI.primary)),
              Text('${noteFreq(midi).round()} Hz', style: const TextStyle(color: VI.muted)),
              const SizedBox(height: 32),
              SizedBox(
                height: 40,
                child: LayoutBuilder(
                  builder: (_, c) => Stack(alignment: Alignment.centerLeft, children: [
                    Container(height: 6, decoration: BoxDecoration(color: VI.border, borderRadius: BorderRadius.circular(3))),
                    Positioned(left: c.maxWidth / 2 - 14, child: Container(width: 28, height: 28, decoration: BoxDecoration(border: Border.all(color: VI.success, width: 3), shape: BoxShape.circle))),
                    if (cents != null)
                      Positioned(left: c.maxWidth / 2 + cents / 600 * (c.maxWidth / 2) - 8, child: const CircleAvatar(radius: 8, backgroundColor: VI.action)),
                  ]),
                ),
              ),
              Text(cents == null ? 'Listening…' : (cents.abs() < 50 ? 'On pitch!' : cents < 0 ? 'Go higher' : 'Go lower'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Notes matched: $hits', style: const TextStyle(color: VI.muted)),
              const SizedBox(height: 24),
              FilledButton(onPressed: _toggle, child: Text(on ? 'Stop' : 'Start')),
              if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Color(0xFFF57469)))),
            ]),
          ),
        ),
      ),
    );
  }
}

// ---------- AI Roleplay (scripted, branching) ----------
const _scenarios = {
  'Job interview': [
    ('Interviewer', 'Tell me about yourself and why you want this role.', [
      ('I led a team that cut costs 20%. I want to bring that to you.', 3, 'Strong, concrete answer. Let’s dig in.'),
      ('Um, I guess I just need a job.', 0, 'That’s a bit vague. Can you be more specific?'),
      ('I’ve got five years in the field and love solving hard problems.', 2, 'Good. What’s a problem you solved recently?'),
    ]),
    ('Interviewer', 'What’s your biggest weakness?', [
      ('I over-prepare, so I now set time limits on prep.', 3, 'Self-aware and practical. Nice.'),
      ('I don’t really have any.', 0, 'Everyone has something. That felt evasive.'),
      ('I can be impatient, and I’m working on listening first.', 2, 'Honest. Thank you.'),
    ]),
  ],
  'Salary negotiation': [
    ('Manager', 'We can offer you \$80k. Does that work?', [
      ('Thank you. Based on my research and impact, I was looking at \$95k.', 3, 'I hear you. Let me see what flexibility we have.'),
      ('Okay, sure.', 0, 'Great. We’ll get the paperwork started.'),
      ('Could we discuss closer to \$90k?', 2, 'I can probably get to \$85k. What else matters to you?'),
    ]),
    ('Manager', 'What else would make this offer work for you?', [
      ('A signing bonus and a six-month review.', 3, 'Reasonable. Let me take that to HR.'),
      ('Nothing, that’s fine.', 0, 'Alright, we’ll proceed as is.'),
      ('Extra vacation days would help.', 2, 'I can look into that.'),
    ]),
  ],
  'First date': [
    ('Date', 'So, what do you do for fun?', [
      ('I cook and hike. Last week I tried making ramen from scratch.', 3, 'Wow, ramen from scratch? Tell me more!'),
      ('Not much really.', 0, 'Oh. Okay… anything you’re into?'),
      ('I love music. You?', 2, 'Same! Mostly indie. What was your last concert?'),
    ]),
  ],
};

class RoleplayPage extends StatefulWidget {
  const RoleplayPage({super.key});
  @override
  State<RoleplayPage> createState() => _RoleplayPageState();
}

class _RoleplayPageState extends State<RoleplayPage> {
  String? scenario;
  int turn = 0, score = 0;
  final log = <(bool, String)>[]; // (isUser, text)

  void _pick(String s) {
    scenario = s;
    turn = 0;
    score = 0;
    log
      ..clear()
      ..add((false, _scenarios[s]![0].$2));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (scenario == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: VI.surface, title: const Text('AI Roleplay')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          for (final k in _scenarios.keys) Card(child: ListTile(title: Text(k), trailing: const Icon(Icons.chevron_right), onTap: () => _pick(k))),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Scripted practice conversations with scoring. Live AI characters need Vocal Image’s service.',
                style: TextStyle(color: VI.muted, fontSize: 12)),
          ),
        ]),
      );
    }
    final steps = _scenarios[scenario]!;
    final finished = turn >= steps.length;
    final max = steps.length * 3;
    return Scaffold(
      appBar: AppBar(backgroundColor: VI.surface, title: Text(scenario!)),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            for (final m in log)
              Align(
                alignment: m.$1 ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(color: m.$1 ? VI.primary : VI.card, borderRadius: BorderRadius.circular(14)),
                  child: Text(m.$2, style: TextStyle(color: m.$1 ? const Color(0xFF171723) : null)),
                ),
              ),
          ]),
        ),
        if (!finished)
          SafeArea(
            child: Column(children: [
              for (final o in steps[turn].$3)
                ListTile(
                  title: Text(o.$1),
                  tileColor: VI.bg2,
                  onTap: () => setState(() {
                    log.add((true, o.$1));
                    log.add((false, o.$3));
                    score += o.$2;
                    turn++;
                    if (turn < steps.length) {
                      log.add((false, steps[turn].$2));
                    } else {
                      AppState.I.addResult(Result('AI Roleplay', {'Score': (score / max * 100).round()}, '$scenario: ${(score / max * 100).round()}%'));
                    }
                  }),
                ),
            ]),
          )
        else
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Text('Score: ${(score / max * 100).round()}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: VI.primary)),
                const SizedBox(height: 8),
                FilledButton(onPressed: () => setState(() => scenario = null), child: const Text('Try another scenario')),
              ]),
            ),
          ),
      ]),
    );
  }
}

// ---------- Shorts ----------
const _shorts = [
  ('Pause, don’t “um”', 'Replace filler words with a silent beat. Silence sounds confident.'),
  ('Land your sentences', 'Drop your pitch at the end of a statement. Rising pitch sounds like a question.'),
  ('Breathe from the belly', 'Place a hand on your stomach; it should move out as you inhale.'),
  ('Slow down 10%', 'Most nervous speakers rush. Aim for ~150 words per minute.'),
  ('Smile while you speak', 'A slight smile warms tone and brightens vowels.'),
  ('Vary your pitch', 'Monotone loses people. Emphasize one key word per sentence.'),
];

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});
  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  final c = PageController();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: VI.surface, title: const Text('Shorts')),
        body: PageView.builder(
          controller: c,
          scrollDirection: Axis.vertical,
          itemCount: _shorts.length,
          onPageChanged: (i) => i == _shorts.length - 1 ? AppState.I.completeTask('shorts') : null,
          itemBuilder: (_, i) => Container(
            padding: const EdgeInsets.all(32),
            color: Color.lerp(VI.bg, VI.action, i / (_shorts.length * 2)),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Tip ${i + 1}/${_shorts.length}', style: const TextStyle(color: VI.primary)),
                const SizedBox(height: 16),
                Text(_shorts[i].$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Text(_shorts[i].$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 32),
                const Icon(Icons.keyboard_arrow_up_rounded),
              ]),
            ),
          ),
        ),
      );
}

// ---------- Voice Arena ----------
class ArenaPage extends StatelessWidget {
  const ArenaPage({super.key});
  @override
  Widget build(BuildContext context) {
    final mine = AppState.I.results.where((r) => r.test == 'Voice Rating').map((r) => r.scores['Overall']?.toInt() ?? 0);
    final best = mine.isEmpty ? null : mine.reduce(max);
    final board = [
      ('Aria', 94), ('Marcus', 91), ('Lena', 88), ('Diego', 85), ('Priya', 82), ('Tom', 76), ('Yuki', 71),
      if (best != null) (AppState.I.name, best),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return Scaffold(
      appBar: AppBar(backgroundColor: VI.surface, title: const Text('Voice Arena')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        if (best == null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.mic, color: VI.primary),
              title: const Text('Take the Voice Rating to join the leaderboard'),
              onTap: () => openTest(context, 'Voice Rating'),
            ),
          ),
        for (var i = 0; i < board.length; i++)
          Card(
            color: board[i].$1 == AppState.I.name && best != null ? VI.primary.withValues(alpha: .15) : null,
            child: ListTile(
              leading: CircleAvatar(backgroundColor: i < 3 ? VI.primary : VI.border, foregroundColor: Colors.black, child: Text('${i + 1}')),
              title: Text(board[i].$1),
              trailing: Text('${board[i].$2}', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        const Padding(padding: EdgeInsets.all(8), child: Text('Sample leaderboard; the community leaderboard is on-device only.', style: TextStyle(color: VI.muted, fontSize: 12))),
      ]),
    );
  }
}
