import 'package:flutter/material.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'learn.dart';
import 'programs.dart';
import 'tests.dart';
import 'train.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int tab = 0;
  final s = AppState.I;

  @override
  void initState() {
    super.initState();
    s.addListener(_r);
  }

  void _r() => mounted ? setState(() {}) : null;

  @override
  void dispose() {
    s.removeListener(_r);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_today(), const TestsHub(), const TrainHub(), const ProgramsPage(), const LearnPage(), _profile()];
    return Scaffold(
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: pages[tab]))),
      bottomNavigationBar: NavigationBar(
        backgroundColor: VI.surface,
        indicatorColor: VI.primary.withValues(alpha: .25),
        selectedIndex: tab,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_rounded), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.mic_rounded), label: 'Tests'),
          NavigationDestination(icon: Icon(Icons.fitness_center_rounded), label: 'Train'),
          NavigationDestination(icon: Icon(Icons.school_rounded), label: 'Programs'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _today() {
    final tasks = <(String, String, VoidCallback)>[
      ('breathing', 'Warm-up breathing', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreathingPage()))),
      ('pitch', 'Pitch matching', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PitchTrainerPage()))),
      ('twister', 'Tongue twister sprint', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TongueTwisterPage()))),
      ('shorts', 'Watch a coaching short', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShortsPage()))),
    ];
    // Twister counts as done when a result for it exists today.
    final today = DateTime.now();
    final twisterDone = s.results.any((r) => r.test == 'Tongue Twister Test' && r.at.day == today.day && r.at.month == today.month);
    bool isDone(String id) => id == 'twister' ? twisterDone : s.doneToday.contains(id);
    final n = tasks.where((t) => isDone(t.$1)).length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Hi ${s.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      Text('Focus: ${s.focus}${s.goal.isEmpty ? '' : ' • ${s.goal}'}', style: const TextStyle(color: VI.muted)),
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.local_fire_department, color: VI.primary),
        Text(' ${s.streak} day streak', style: const TextStyle(fontWeight: FontWeight.w700)),
        const Spacer(),
        Text('${s.xp} XP', style: const TextStyle(color: VI.muted)),
      ]),
      const SizedBox(height: 16),
      LinearProgressIndicator(value: n / tasks.length, color: VI.primary, backgroundColor: VI.border, minHeight: 8),
      const SizedBox(height: 4),
      Text('$n/${tasks.length} done today • about 3 minutes', style: const TextStyle(color: VI.muted)),
      const SizedBox(height: 12),
      for (final t in tasks)
        Card(
          child: ListTile(
            leading: Icon(isDone(t.$1) ? Icons.check_circle : Icons.circle_outlined, color: isDone(t.$1) ? VI.success : VI.muted),
            title: Text(t.$2),
            trailing: const Icon(Icons.chevron_right),
            onTap: t.$3,
          ),
        ),
    ]);
  }

  Widget _profile() {
    final rs = s.results;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Center(child: CircleAvatar(radius: 40, backgroundColor: VI.card, child: Icon(Icons.person, size: 40))),
      const SizedBox(height: 12),
      Center(child: Text(s.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
      const SizedBox(height: 16),
      Card(child: ListTile(leading: const Icon(Icons.local_fire_department, color: VI.primary), title: const Text('Day streak'), trailing: Text('${s.streak}'))),
      Card(child: ListTile(leading: const Icon(Icons.bolt, color: VI.primary), title: const Text('XP'), trailing: Text('${s.xp}'))),
      const SizedBox(height: 8),
      const Text('Progress & past results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      if (rs.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('Take a test to see results here.', style: TextStyle(color: VI.muted))),
      for (final r in rs.take(20))
        Card(
          child: ExpansionTile(
            title: Text(r.test),
            subtitle: Text(r.headline, maxLines: 1, overflow: TextOverflow.ellipsis),
            children: [Padding(padding: const EdgeInsets.all(16), child: scoreBars(r.scores))],
          ),
        ),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: s.reset, child: const Text('Reset progress')),
    ]);
  }
}
