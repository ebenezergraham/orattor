import 'package:flutter/material.dart';
import '../curriculum.dart';
import '../state.dart';
import '../theme.dart';
import 'lesson.dart';

class Program {
  final String name, blurb;
  final IconData icon;
  final List<(String, String)> lessons;
  const Program(this.name, this.blurb, this.icon, this.lessons);
}

const programs = [
  Program('Speech recovery', 'Gentle exercises for people recovering from stroke.', Icons.healing_rounded, [
    ('Breath support', 'Inhale through the nose for 3 counts, exhale on a steady "ahh" for 5. Repeat 5 times.'),
    ('Lip and tongue warm-up', 'Trill your lips for 10 seconds, then move the tongue side to side 10 times.'),
    ('Single syllables', 'Slowly repeat "pa, ta, ka" 10 times, focusing on crisp starts.'),
    ('Short phrases', 'Say "Good morning" and "How are you" with a pause between words.'),
  ]),
  Program('Feminization', 'Develop a brighter, lighter voice.', Icons.arrow_upward_rounded, [
    ('Pitch glides', 'Slide from low to high on "weee" without strain.'),
    ('Forward resonance', 'Hum "mmm" and feel buzz in the nose and lips.'),
    ('Lighter intonation', 'Add gentle rising and falling melodies to sentences.'),
    ('Daily read-aloud', 'Read a paragraph keeping a comfortable raised pitch.'),
  ]),
];

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});
  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  Future<void> _open(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) => setState(() {}));

  Future<void> _whereToStart() async {
    final picked = <Concern>{};
    final result = await showDialog<Set<Concern>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          backgroundColor: VI.bg2,
          title: const Text('What sounds like you?'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final c in Concern.values)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: VI.primary,
                  checkColor: Colors.black,
                  title: Text(concernLabels[c]!),
                  value: picked.contains(c),
                  onChanged: (v) => set(() => v == true ? picked.add(c) : picked.remove(c)),
                ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: picked.isEmpty ? null : () => Navigator.pop(ctx, picked), child: const Text('Show my path')),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    final path = recommendedTracks(result);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: VI.bg2,
      builder: (ctx) => SafeArea(
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(20), children: [
          const Text('Your path, in order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Start with Foundations, then work down the list.', style: TextStyle(color: VI.muted)),
          const SizedBox(height: 8),
          for (var i = 0; i < path.length; i++)
            ListTile(
              leading: CircleAvatar(radius: 14, backgroundColor: VI.primary, foregroundColor: Colors.black, child: Text('${i + 1}')),
              title: Text(path[i].name),
              subtitle: Text('${path[i].lessons.length} lessons'),
              onTap: () {
                Navigator.pop(ctx);
                _open(TrackPage(path[i]));
              },
            ),
        ]),
      ),
    );
  }

  int _done(Track t) => t.lessons.where((l) => AppState.I.programLessons.contains(t.key(l))).length;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Programs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Card(
          color: VI.primary.withValues(alpha: .12),
          child: ListTile(
            leading: const Icon(Icons.explore_rounded, color: VI.primary),
            title: const Text('Not sure where to start?'),
            subtitle: const Text('Tell us what you notice about your voice and get an ordered path.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _whereToStart,
          ),
        ),
        const SizedBox(height: 8),
        const Text('Voice training tracks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        for (final t in tracks)
          Card(
            child: ListTile(
              leading: Icon(t.icon, color: VI.primary),
              title: Text(t.name),
              subtitle: Text('${t.blurb}\n${_done(t)}/${t.lessons.length} lessons done'),
              isThreeLine: true,
              onTap: () => _open(TrackPage(t)),
            ),
          ),
        const SizedBox(height: 12),
        const Text('Other programs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        for (final p in programs)
          Card(
            child: ListTile(
              leading: Icon(p.icon, color: VI.primary),
              title: Text(p.name),
              subtitle: Text('${p.blurb}\n${p.lessons.where((l) => AppState.I.programLessons.contains('${p.name}/${l.$1}')).length}/${p.lessons.length} lessons done'),
              isThreeLine: true,
              onTap: () => _open(ProgramDetail(p)),
            ),
          ),
      ]);
}

class ProgramDetail extends StatefulWidget {
  final Program p;
  const ProgramDetail(this.p, {super.key});
  @override
  State<ProgramDetail> createState() => _ProgramDetailState();
}

class _ProgramDetailState extends State<ProgramDetail> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: VI.surface, title: Text(widget.p.name)),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          for (final l in widget.p.lessons)
            Card(
              child: CheckboxListTile(
                activeColor: VI.primary,
                checkColor: Colors.black,
                title: Text(l.$1),
                subtitle: Text(l.$2),
                value: AppState.I.programLessons.contains('${widget.p.name}/${l.$1}'),
                onChanged: (_) {
                  AppState.I.completeProgramLesson('${widget.p.name}/${l.$1}');
                  setState(() {});
                },
              ),
            ),
        ]),
      );
}
