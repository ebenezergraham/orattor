import 'package:flutter/material.dart';
import '../analysis.dart';
import '../audio.dart';
import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

const _prompts = {
  'Accent Test': 'Please call Stella. Ask her to bring these things with her from the store: six spoons of fresh snow peas, five thick slabs of blue cheese, and maybe a snack for her brother Bob.',
  'Spanish Accent Test': 'Por favor, llama a Stella. Pídele que traiga estas cosas de la tienda.',
  'Voice Test': 'Read aloud: "The rainbow is a division of white light into many beautiful colors."',
  'Voice Rating': 'Talk for about 30 seconds: tell us about your best day this year.',
  'Age Test': 'Say: "Hello, my name is ... and I am happy to be here today."',
  'Speech Test': 'Describe your morning routine in your own words.',
  'Celebrity Test': 'Read aloud: "When you do the common things in life in an uncommon way, you will command the attention of the world."',
};

void openTest(BuildContext c, String title) {
  Widget page;
  if (title == 'Archetype Test') {
    page = const ArchetypePage();
  } else if (title == 'Tongue Twister Test') {
    page = const TongueTwisterPage();
  } else {
    page = TestPage(title: title);
  }
  Navigator.push(c, MaterialPageRoute(builder: (_) => page));
}

class TestsHub extends StatelessWidget {
  const TestsHub({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Free voice tests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        for (final t in tests)
          Card(
            child: ListTile(
              leading: Icon(t.icon, color: VI.primary),
              title: Text(t.title),
              subtitle: Text(t.body),
              onTap: () => openTest(context, t.title),
            ),
          ),
      ]);
}

class TestPage extends StatefulWidget {
  final String title;
  const TestPage({super.key, required this.title});
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Result? result;
  String native = 'English';

  void _done(VoiceMetrics m) {
    final r = switch (widget.title) {
      'Voice Test' => voiceTest(m),
      'Voice Rating' => voiceRating(m),
      'Speech Test' => speechTest(m),
      'Age Test' => ageTest(m),
      'Celebrity Test' => celebrityTest(m),
      _ => accentTest(m, native),
    };
    AppState.I.addResult(r);
    setState(() => result = r);
  }

  @override
  Widget build(BuildContext context) {
    final isAccent = widget.title.contains('Accent');
    return Scaffold(
      appBar: AppBar(backgroundColor: VI.surface, title: Text(widget.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Text(_prompts[widget.title] ?? 'Read aloud: "The quick brown fox jumps over the lazy dog."',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4)),
            if (isAccent) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: native,
                decoration: const InputDecoration(labelText: 'Your native language'),
                items: ['English', 'Spanish', 'French', 'German', 'Hindi', 'Mandarin', 'Arabic', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => native = v!),
              ),
            ],
            const SizedBox(height: 32),
            RecordPanel(maxSeconds: widget.title == 'Voice Rating' ? 30 : 15, onDone: _done),
            if (result != null) ...[
              const SizedBox(height: 28),
              ResultCard(result!),
              if (isAccent)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Demo estimate: real accent detection needs a trained model.',
                      style: TextStyle(color: VI.muted, fontSize: 12)),
                ),
              if (widget.title == 'Age Test')
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('For fun: based on pitch and steadiness only.', style: TextStyle(color: VI.muted, fontSize: 12)),
                ),
            ],
          ]),
        ),
      ),
    );
  }
}

class TongueTwisterPage extends StatefulWidget {
  const TongueTwisterPage({super.key});
  @override
  State<TongueTwisterPage> createState() => _TongueTwisterPageState();
}

class _TongueTwisterPageState extends State<TongueTwisterPage> {
  int i = 0;
  Result? result;
  @override
  Widget build(BuildContext context) {
    final text = tongueTwisters[i];
    return Scaffold(
      appBar: AppBar(backgroundColor: VI.surface, title: const Text('Tongue Twister Test')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Wrap(spacing: 8, children: [
              for (var k = 0; k < tongueTwisters.length; k++)
                ChoiceChip(
                    label: Text('#${k + 1}'),
                    selected: i == k,
                    onSelected: (_) => setState(() {
                          i = k;
                          result = null;
                        })),
            ]),
            const SizedBox(height: 20),
            Text('"$text"', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 28),
            RecordPanel(
                key: ValueKey(i),
                maxSeconds: 12,
                onDone: (m) {
                  final r = tongueTwisterTest(m, text.split(' ').length);
                  AppState.I.addResult(r);
                  setState(() => result = r);
                }),
            if (result != null) ...[const SizedBox(height: 24), ResultCard(result!)],
          ]),
        ),
      ),
    );
  }
}

class ArchetypePage extends StatefulWidget {
  const ArchetypePage({super.key});
  @override
  State<ArchetypePage> createState() => _ArchetypePageState();
}

class _ArchetypePageState extends State<ArchetypePage> {
  final answers = <int>[];
  Result? result;
  @override
  Widget build(BuildContext context) {
    final done = answers.length >= archetypeQuiz.length;
    return Scaffold(
      appBar: AppBar(backgroundColor: VI.surface, title: const Text('Archetype Test')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: done
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(result!.headline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: VI.primary)),
                    const SizedBox(height: 20),
                    OutlinedButton(onPressed: () => setState(() => answers.clear()), child: const Text('Retake')),
                  ])
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(archetypeQuiz[answers.length].$1,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    for (var k = 0; k < archetypeQuiz[answers.length].$2.length; k++)
                      Card(
                        child: ListTile(
                          title: Text(archetypeQuiz[answers.length].$2[k]),
                          onTap: () => setState(() {
                            answers.add(k);
                            if (answers.length == archetypeQuiz.length) {
                              result = archetypeResult(answers);
                              AppState.I.addResult(result!);
                            }
                          }),
                        ),
                      ),
                  ]),
          ),
        ),
      ),
    );
  }
}
