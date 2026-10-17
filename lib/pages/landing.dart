import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import 'app_shell.dart';
import 'onboarding.dart';
import 'tests.dart';
import '../state.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int? goal;

  void _start() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => OnboardingPage(initialGoal: goal)));

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= 1200;
    return Scaffold(
      appBar: _NavBar(wide: wide, onDownload: _start),
      drawer: wide ? null : _MenuDrawer(onStart: _start),
      body: SingleChildScrollView(
        child: Column(children: [
          _Section(child: _hero(wide)),
          _Section(alt: true, child: _press()),
          _Section(child: _accent(wide)),
          _Section(alt: true, child: _how(wide)),
          _Section(child: _features(wide)),
          _Section(alt: true, child: _testsGrid(wide)),
          _Section(child: _reviews(wide)),
          _Section(alt: true, child: _closing()),
          _footer(wide),
        ]),
      ),
    );
  }

  Widget _hero(bool wide) => Column(children: [
        const SizedBox(height: 24),
        Text('Transform Your Voice & Communication Skills with AI-Powered Coaching',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: wide ? 52 : 30, fontWeight: FontWeight.w800, height: 1.15)),
        const SizedBox(height: 16),
        const Text('Record short exercises, get instant feedback on pitch, clarity, pace and confidence, then train with a daily plan.',
            textAlign: TextAlign.center, style: TextStyle(color: VI.muted, fontSize: 18)),
        const SizedBox(height: 32),
        const Text('Choose your main goal to get started', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [
          for (var i = 0; i < goals.length; i++)
            ChoiceChip(
              label: Text(goals[i]),
              selected: goal == i,
              selectedColor: VI.primary,
              labelStyle: TextStyle(color: goal == i ? const Color(0xFF171723) : null),
              onSelected: (_) => setState(() => goal = i),
            ),
        ]),
        const SizedBox(height: 28),
        FilledButton(onPressed: _start, child: const Text('Get my training plan')),
        const SizedBox(height: 14),
        const Text('Over 4 million people have used our free voice tests',
            style: TextStyle(color: VI.muted)),
        const SizedBox(height: 24),
      ]);

  Widget _press() => Column(children: [
        const Text('FEATURED IN', style: TextStyle(color: VI.muted, letterSpacing: 2, fontSize: 12)),
        const SizedBox(height: 14),
        Wrap(spacing: 32, runSpacing: 12, alignment: WrapAlignment.center, children: [
          for (final p in press)
            Text(p, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: VI.muted)),
        ]),
      ]);

  Widget _accent(bool wide) {
    final stats = Wrap(spacing: 28, runSpacing: 14, children: const [
      _Stat('8.4M+', 'tests taken'),
      _Stat('4.8', 'rating'),
      _Stat('96%', "can't fool the AI"),
      _Stat('120+', 'accents detected'),
    ]);
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('How strong is your accent when you speak English?',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      const Text('Read a short phrase and our AI rates how strong your accent sounds.',
          style: TextStyle(color: VI.muted, fontSize: 16)),
      const SizedBox(height: 20),
      stats,
      const SizedBox(height: 24),
      FilledButton(
          onPressed: () => openTest(context, 'Accent Test'),
          child: const Text('Test my accent • FREE')),
    ]);
    return wide
        ? Row(children: [
            Expanded(child: text),
            const SizedBox(width: 48),
            const Expanded(child: Icon(Icons.translate_rounded, size: 180, color: VI.primary)),
          ])
        : text;
  }

  Widget _how(bool wide) => Column(children: [
        const Text('One Coach. Three Minutes a Day.',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        _grid(wide ? 3 : 1, [
          for (var i = 0; i < steps.length; i++)
            _InfoCard(
                leading: CircleAvatar(
                    backgroundColor: VI.primary,
                    foregroundColor: const Color(0xFF171723),
                    child: Text('${i + 1}')),
                title: steps[i].$1,
                body: steps[i].$2),
        ]),
        const SizedBox(height: 24),
        FilledButton(onPressed: _start, child: const Text('Try it now')),
      ]);

  Widget _features(bool wide) => Column(children: [
        const Text("What's Inside the App",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        _grid(wide ? 3 : 1, [
          for (final f in features)
            _InfoCard(leading: Icon(f.icon, color: VI.primary, size: 32), title: f.title, body: f.body)
        ]),
      ]);

  Widget _testsGrid(bool wide) => Column(children: [
        const Text('Free Voice Tests', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        _grid(wide ? 3 : 1, [
          for (final t in tests)
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => openTest(context, t.title),
              child: _InfoCard(leading: Icon(t.icon, color: VI.action, size: 32), title: t.title, body: t.body),
            )
        ]),
      ]);

  Widget _reviews(bool wide) => Column(children: [
        const Text('Loved by speakers worldwide',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        _grid(wide ? 3 : 1, [
          for (final t in testimonials)
            _InfoCard(
                leading: Row(mainAxisSize: MainAxisSize.min, children: [
                  for (var i = 0; i < 5; i++) const Icon(Icons.star_rounded, color: VI.primary, size: 20)
                ]),
                title: '${t.$1} • ${t.$2}',
                body: t.$3),
        ]),
      ]);

  Widget _closing() => Column(children: [
        const Text('Boost your voice, confidence, and career',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        FilledButton(onPressed: _start, child: const Text('Try it for free')),
        const SizedBox(height: 28),
        const Wrap(spacing: 24, runSpacing: 8, alignment: WrapAlignment.center, children: [
          Text('European AI Startup Program', style: TextStyle(color: VI.muted)),
          Text('AWS AI Challenge', style: TextStyle(color: VI.muted)),
          Text('TechChill 2022', style: TextStyle(color: VI.muted)),
          Text('Latitude59 2022', style: TextStyle(color: VI.muted)),
          Text('Startup Fair 2023', style: TextStyle(color: VI.muted)),
        ]),
      ]);

  Widget _footer(bool wide) => Container(
        color: VI.surface,
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 56, runSpacing: 24, children: const [
                _FooterCol('Support', ['Help center', 'support@vocalimage.app']),
                _FooterCol('Content', ['Tongue Twisters', 'Voice Training', 'Public Speaking', 'Articulate']),
                _FooterCol('Company', ['Careers', 'Media Kit', 'Newsroom', 'For Sales']),
                _FooterCol('Tests', ['Accent', 'Archetype', 'Tongue Twister', 'Voice Rating', 'Age']),
              ]),
              const SizedBox(height: 24),
              const Wrap(spacing: 12, children: [
                Chip(avatar: Icon(Icons.apple), label: Text('App Store')),
                Chip(avatar: Icon(Icons.android), label: Text('Google Play')),
              ]),
              const SizedBox(height: 16),
              const Text('New York, NY • Tallinn, Estonia', style: TextStyle(color: VI.muted)),
              const SizedBox(height: 8),
              const Text('© 2021–2026 Vocal Image • Privacy policy • Terms & conditions',
                  style: TextStyle(color: VI.muted)),
            ]),
          ),
        ),
      );

  Widget _grid(int cols, List<Widget> kids) => LayoutBuilder(builder: (_, c) {
        const gap = 16.0;
        final itemW = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(spacing: gap, runSpacing: gap, children: [
          for (final k in kids) SizedBox(width: itemW, child: k)
        ]);
      });
}

class _NavBar extends StatelessWidget implements PreferredSizeWidget {
  final bool wide;
  final VoidCallback onDownload;
  const _NavBar({required this.wide, required this.onDownload});
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => AppBar(
        backgroundColor: VI.surface,
        title: const Row(children: [
          Icon(Icons.graphic_eq_rounded, color: VI.primary),
          SizedBox(width: 8),
          Text('Vocal Image', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          if (wide) ...[
            TextButton(onPressed: () {}, child: const Text('Blog')),
            for (final e in menu.entries)
              PopupMenuButton<String>(
                color: VI.card,
                tooltip: '',
                itemBuilder: (_) => [for (final i in e.value) PopupMenuItem(value: i, child: Text(i))],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [Text(e.key), const Icon(Icons.arrow_drop_down)]),
                ),
              ),
            TextButton(onPressed: () {}, child: const Text('Help')),
            TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppState.I.onboarded ? const AppShell() : const OnboardingPage())),
                child: const Text('Log In')),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Center(child: Text('EN'))),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: FilledButton(
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                onPressed: onDownload,
                child: const Text('Download')),
          ),
        ],
      );
}

class _MenuDrawer extends StatelessWidget {
  final VoidCallback onStart;
  const _MenuDrawer({required this.onStart});
  @override
  Widget build(BuildContext context) => Drawer(
        backgroundColor: VI.bg2,
        child: ListView(children: [
          const DrawerHeader(child: Text('Vocal Image', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
          const ListTile(title: Text('Blog')),
          for (final e in menu.entries)
            ExpansionTile(title: Text(e.key), children: [for (final i in e.value) ListTile(title: Text(i), dense: true)]),
          const ListTile(title: Text('Help')),
          ListTile(
              title: const Text('Log In'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppState.I.onboarded ? const AppShell() : const OnboardingPage()))),
        ]),
      );
}

class _Section extends StatelessWidget {
  final Widget child;
  final bool alt;
  const _Section({required this.child, this.alt = false});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: alt ? VI.bg2 : VI.bg,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 56),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: child)),
      );
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: VI.primary)),
        Text(label, style: const TextStyle(color: VI.muted)),
      ]);
}

class _InfoCard extends StatelessWidget {
  final Widget leading;
  final String title, body;
  const _InfoCard({required this.leading, required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            leading,
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(color: VI.muted)),
          ]),
        ),
      );
}

class _FooterCol extends StatelessWidget {
  final String title;
  final List<String> items;
  const _FooterCol(this.title, this.items);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final i in items) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(i, style: const TextStyle(color: VI.muted))),
      ]);
}
