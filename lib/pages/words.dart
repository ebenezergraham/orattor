import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

/// A word the user heard, where they first heard it, and how well they recall it.
class WordEntry {
  final String word;
  String meaning;
  String context;
  String source;
  final DateTime heard;
  int practiced;
  int score;
  DateTime? lastPracticed;

  WordEntry({
    required this.word,
    required this.meaning,
    this.context = '',
    this.source = '',
    DateTime? heard,
    this.practiced = 0,
    this.score = 0,
    this.lastPracticed,
  }) : heard = heard ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'w': word,
    'm': meaning,
    'c': context,
    's': source,
    'h': heard.toIso8601String(),
    'p': practiced,
    'sc': score,
    'lp': lastPracticed?.toIso8601String(),
  };

  factory WordEntry.fromJson(Map<String, dynamic> j) => WordEntry(
    word: j['w'],
    meaning: j['m'],
    context: j['c'] ?? '',
    source: j['s'] ?? '',
    heard: DateTime.parse(j['h']),
    practiced: j['p'] ?? 0,
    score: j['sc'] ?? 0,
    lastPracticed: j['lp'] == null ? null : DateTime.parse(j['lp']),
  );
}

enum Recall { good, partial, missed }

/// Persistent word list, shared by the list and practice screens.
class WordStore extends ChangeNotifier {
  static final WordStore I = WordStore._();
  WordStore._();
  static const _key = 'words';
  List<WordEntry> words = [];

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    words = (p.getStringList(_key) ?? [])
        .map((s) => WordEntry.fromJson(jsonDecode(s)))
        .toList();
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
      _key,
      words.map((w) => jsonEncode(w.toJson())).toList(),
    );
  }

  void add(WordEntry e) {
    final i = words.indexWhere(
      (w) => w.word.toLowerCase() == e.word.toLowerCase(),
    );
    if (i >= 0) {
      words[i].meaning = e.meaning;
      words[i].context = e.context;
      words[i].source = e.source;
    } else {
      words.insert(0, e);
    }
    _save();
    notifyListeners();
  }

  void remove(WordEntry e) {
    words.remove(e);
    _save();
    notifyListeners();
  }

  void record(WordEntry e, Recall r) {
    e.practiced++;
    e.score = max(
      0,
      e.score +
          switch (r) {
            Recall.good => 1,
            Recall.partial => 0,
            Recall.missed => -1,
          },
    );
    e.lastPracticed = DateTime.now();
    _save();
    notifyListeners();
  }

  /// Random pick that favours never-practiced and weak words, and avoids
  /// repeating [not] when there is another choice.
  WordEntry? pick({WordEntry? not, Random? rng}) {
    var pool = words;
    if (pool.length > 1 && not != null) {
      pool = pool.where((w) => w != not).toList();
    }
    if (pool.isEmpty) return null;
    final weights = [
      for (final w in pool) 1 / (1 + w.score) + (w.practiced == 0 ? 2 : 0),
    ];
    var r = (rng ?? Random()).nextDouble() * weights.reduce((a, b) => a + b);
    for (var i = 0; i < pool.length; i++) {
      r -= weights[i];
      if (r <= 0) return pool[i];
    }
    return pool.last;
  }
}

const _stop = {
  'that',
  'this',
  'with',
  'from',
  'have',
  'been',
  'were',
  'what',
  'when',
  'where',
  'which',
  'their',
  'there',
  'they',
  'them',
  'than',
  'then',
  'about',
  'into',
  'some',
  'such',
  'very',
  'more',
  'most',
  'also',
  'being',
  'does',
  'will',
  'would',
  'could',
  'should',
  'your',
  'something',
  'someone',
  'used',
  'like',
  'make',
  'makes',
  'thing',
  'things',
  'often',
};

Set<String> _keyTerms(String s) => {
  for (final t in s.toLowerCase().split(RegExp(r'[^a-z]+')))
    if (t.length >= 4 && !_stop.contains(t)) t.substring(0, min(t.length, 5)),
};

class Grade {
  final double coverage;
  final List<String> hit;
  final List<String> missed;
  Grade(this.coverage, this.hit, this.missed);
  Recall get suggested => coverage >= .6
      ? Recall.good
      : (coverage >= .25 ? Recall.partial : Recall.missed);
}

/// Compares the user's explanation to the stored meaning by key terms (word
/// stems), not by understanding, so it is a rough check the user can override.
Grade gradeExplanation(String answer, String meaning) {
  final want = <String, String>{};
  for (final t in meaning.toLowerCase().split(RegExp(r'[^a-z]+'))) {
    if (t.length >= 4 && !_stop.contains(t)) {
      want[t.substring(0, min(t.length, 5))] = t;
    }
  }
  if (want.isEmpty) return Grade(0, [], []);
  final got = _keyTerms(answer);
  final hit = [
    for (final e in want.entries)
      if (got.contains(e.key)) e.value,
  ];
  final missed = [
    for (final e in want.entries)
      if (!got.contains(e.key)) e.value,
  ];
  return Grade(hit.length / want.length, hit, missed);
}

class WordsPage extends StatefulWidget {
  const WordsPage({super.key});
  @override
  State<WordsPage> createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  final store = WordStore.I;

  @override
  void initState() {
    super.initState();
    store.addListener(_r);
  }

  void _r() => mounted ? setState(() {}) : null;

  @override
  void dispose() {
    store.removeListener(_r);
    super.dispose();
  }

  Future<void> _add() async {
    final word = TextEditingController(), meaning = TextEditingController();
    final source = TextEditingController(), context_ = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: VI.bg2,
        title: const Text('Add a word'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: word,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Word'),
              ),
              TextField(
                controller: meaning,
                maxLines: null,
                decoration: const InputDecoration(labelText: 'What it means'),
              ),
              TextField(
                controller: source,
                decoration: const InputDecoration(
                  labelText: 'Where you heard it (person, show, podcast…)',
                ),
              ),
              TextField(
                controller: context_,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'The sentence or situation',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true &&
        word.text.trim().isNotEmpty &&
        meaning.text.trim().isNotEmpty) {
      store.add(
        WordEntry(
          word: word.text.trim(),
          meaning: meaning.text.trim(),
          source: source.text.trim(),
          context: context_.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = store.words;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: VI.surface,
        title: const Text('Word journal'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: VI.primary,
        foregroundColor: const Color(0xFF171723),
        icon: const Icon(Icons.add),
        label: const Text('Add word'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              children: [
                FilledButton.icon(
                  onPressed: ws.isEmpty
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WordPracticePage(),
                          ),
                        ),
                  icon: const Icon(Icons.shuffle_rounded),
                  label: const Text('Practice a random word'),
                ),
                const SizedBox(height: 12),
                if (ws.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Add words you hear, with where you heard them. Practice quizzes you on them later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: VI.muted),
                    ),
                  ),
                for (final w in ws)
                  Card(
                    child: ListTile(
                      title: Text(
                        w.word,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        [
                          w.meaning,
                          if (w.source.isNotEmpty) 'Heard: ${w.source}',
                          'Practiced ${w.practiced}×',
                        ].join('\n'),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => store.remove(w),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WordPracticePage extends StatefulWidget {
  const WordPracticePage({super.key});
  @override
  State<WordPracticePage> createState() => _WordPracticePageState();
}

class _WordPracticePageState extends State<WordPracticePage> {
  final store = WordStore.I;
  final ctl = TextEditingController();
  WordEntry? word;
  Grade? grade;

  @override
  void initState() {
    super.initState();
    word = store.pick();
  }

  void _next() => setState(() {
    word = store.pick(not: word);
    grade = null;
    ctl.clear();
  });

  void _rate(Recall r) {
    store.record(word!, r);
    _next();
  }

  @override
  Widget build(BuildContext context) {
    final w = word;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: VI.surface,
        title: const Text('Practice'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: w == null
                ? const Center(child: Text('No words yet.'))
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Text(
                        'What does this mean?',
                        style: TextStyle(color: VI.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        w.word,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (w.source.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'You first heard it: ${w.source}',
                            style: const TextStyle(color: VI.muted),
                          ),
                        ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: ctl,
                        enabled: grade == null,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Explain it in your own words…',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (grade == null)
                        FilledButton(
                          onPressed: () => setState(
                            () => grade = gradeExplanation(ctl.text, w.meaning),
                          ),
                          child: const Text('Check my answer'),
                        )
                      else
                        ..._feedback(w, grade!),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _feedback(WordEntry w, Grade g) {
    final verdict = switch (g.suggested) {
      Recall.good => ('Nice, that covers it', VI.success),
      Recall.partial => ('Partly there', VI.primary),
      Recall.missed => ('Not quite', const Color(0xFFF97066)),
    };
    return [
      Text(
        verdict.$1,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: verdict.$2,
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('It means', style: TextStyle(color: VI.muted)),
              Text(w.meaning, style: const TextStyle(fontSize: 16)),
              if (w.context.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'You heard it in',
                  style: TextStyle(color: VI.muted),
                ),
                Text(w.context),
              ],
              if (g.hit.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'You covered: ${g.hit.join(', ')}',
                  style: const TextStyle(color: VI.success),
                ),
              ],
              if (g.missed.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'You missed: ${g.missed.join(', ')}',
                  style: const TextStyle(color: VI.muted),
                ),
              ],
            ],
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'This compares key terms only, so you decide how it went:',
          style: TextStyle(color: VI.muted, fontSize: 12),
        ),
      ),
      Row(
        children: [
          for (final r in Recall.values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: r == g.suggested
                    ? FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _rate(r),
                        child: Text(_label(r)),
                      )
                    : OutlinedButton(
                        onPressed: () => _rate(r),
                        child: Text(_label(r)),
                      ),
              ),
            ),
        ],
      ),
    ];
  }

  String _label(Recall r) => switch (r) {
    Recall.good => 'Got it',
    Recall.partial => 'Partly',
    Recall.missed => 'Missed',
  };
}
