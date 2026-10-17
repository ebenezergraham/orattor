import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../state.dart';
import 'app_shell.dart';

// (question, options, multi-select)
const _quiz = [
  ('What do you want to improve? (choose all that apply)', ['Confidence', 'Clarity', 'Presence', 'Accent'], true),
  ('What gets in your way? (choose all that apply)', ['Nerves', 'Filler words ("um")', 'Speaking too fast', 'Monotone delivery'], true),
  ('How much can you practice daily?', ['3 minutes', '5 minutes', '10 minutes'], false),
];

class OnboardingPage extends StatefulWidget {
  final int? initialGoal;
  const OnboardingPage({super.key, this.initialGoal});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int step = 0;
  final answers = <int, String>{};
  final picked = <String>{};
  final nameCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final done = step >= _quiz.length;
    return Scaffold(
      appBar: AppBar(backgroundColor: VI.surface, title: const Text('Your training plan')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: done ? _plan() : _question(),
          ),
        ),
      ),
    );
  }

  Widget _question() {
    final q = _quiz[step];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      LinearProgressIndicator(value: (step + 1) / _quiz.length, color: VI.primary, backgroundColor: VI.border),
      const SizedBox(height: 32),
      if (step == 0 && widget.initialGoal != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('Goal: ${goals[widget.initialGoal!]}', style: const TextStyle(color: VI.muted)),
        ),
      Text(q.$1, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 20),
      for (final o in q.$2)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: q.$3
                ? CheckboxListTile(
                    title: Text(o),
                    value: picked.contains(o),
                    activeColor: VI.primary,
                    checkColor: const Color(0xFF171723),
                    onChanged: (v) => setState(() => v == true ? picked.add(o) : picked.remove(o)),
                  )
                : ListTile(
                    title: Text(o),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => setState(() {
                      answers[step] = o;
                      step++;
                    }),
                  ),
          ),
        ),
      if (q.$3) ...[
        const SizedBox(height: 10),
        FilledButton(
          onPressed: picked.isEmpty
              ? null
              : () => setState(() {
                    // keep the option order from the quiz, not tap order
                    answers[step] = [for (final o in q.$2) if (picked.contains(o)) o].join(', ');
                    picked.clear();
                    step++;
                  }),
          child: const Text('Continue'),
        ),
      ],
    ]);
  }

  Widget _plan() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.check_circle_rounded, size: 72, color: VI.success),
        const SizedBox(height: 16),
        const Text('Your daily plan is ready', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Focus: ${answers[0]} • Obstacle: ${answers[1]} • ${answers[2]} a day',
            textAlign: TextAlign.center, style: const TextStyle(color: VI.muted)),
        const SizedBox(height: 28),
        TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Your name (optional)')),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () {
            AppState.I.completeOnboarding(nameCtl.text.trim(), answers[0] ?? 'Confidence',
                widget.initialGoal == null ? '' : goals[widget.initialGoal!]);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppShell()));
          },
          child: const Text('Start training'),
        ),
      ]);
}
