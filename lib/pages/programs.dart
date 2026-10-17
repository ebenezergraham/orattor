import 'package:flutter/material.dart';
import '../state.dart';
import '../theme.dart';

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
  Program('Masculinization', 'Build a deeper, grounded voice.', Icons.arrow_downward_rounded, [
    ('Find your low register', 'Hum at your lowest comfortable pitch; feel chest vibration.'),
    ('Resonance in the chest', 'Hand on chest; say "mmm-hmm" and feel it buzz.'),
    ('Downward inflection', 'Practice ending sentences on a falling pitch.'),
    ('Daily read-aloud', 'Read a paragraph keeping pitch near your new base note.'),
  ]),
  Program('Feminization', 'Develop a brighter, lighter voice.', Icons.arrow_upward_rounded, [
    ('Pitch glides', 'Slide from low to high on "weee" without strain.'),
    ('Forward resonance', 'Hum "mmm" and feel buzz in the nose and lips.'),
    ('Lighter intonation', 'Add gentle rising and falling melodies to sentences.'),
    ('Daily read-aloud', 'Read a paragraph keeping a comfortable raised pitch.'),
  ]),
  Program('Public speaking', 'Present with presence.', Icons.campaign_rounded, [
    ('Open strong', 'Start with a story or bold question, not "so, um".'),
    ('Pause power', 'Pause for 2 seconds after each key point.'),
    ('Eye contact and pace', 'Look at one person per sentence; keep ~150 wpm.'),
  ]),
];

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Programs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        for (final p in programs)
          Card(
            child: ListTile(
              leading: Icon(p.icon, color: VI.primary),
              title: Text(p.name),
              subtitle: Text('${p.blurb}\n${p.lessons.where((l) => AppState.I.programLessons.contains('${p.name}/${l.$1}')).length}/${p.lessons.length} lessons done'),
              isThreeLine: true,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProgramDetail(p))),
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
