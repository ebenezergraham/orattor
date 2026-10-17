import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Learn', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        for (final e in menu.entries)
          Card(
            child: ExpansionTile(
              title: Text(e.key),
              children: [
                for (final i in e.value)
                  ListTile(
                    title: Text(i),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArticlePage(i))),
                  ),
              ],
            ),
          ),
      ]);
}

const _articles = {
  'Tongue Twisters': 'Tongue twisters train the articulators (lips, tongue, jaw). Start slowly, aim for crisp consonants, then speed up. Try: "Red lorry, yellow lorry."',
  'Voice Training': 'Warm up with humming, lip trills and sirens. Keep your breath low and steady, relax your jaw, and practise 3–5 minutes daily for lasting change.',
  'Public Speaking': 'Structure your talk, open with a hook, use pauses, vary pitch and pace, and rehearse out loud. Confidence comes from repetition.',
  'Articulate': 'Clear speech comes from open vowels and precise consonants. Over-enunciate in practice so it feels natural when you speak normally.',
  '7 Cues of Charisma': 'Summary: warmth, presence and power are shown through voice and body cues such as steady pace, purposeful pauses and a grounded pitch.',
  'Ultimate Voice Guide': 'Summary: a complete guide to pitch, resonance, breath support and projection with daily exercises.',
  'Mastering American Accent': 'Summary: focus on the American R, flap T, reduced vowels and sentence stress.',
  'Kill the "Um"': 'Summary: replace fillers with pauses, plan your first words, and slow down.',
};

class ArticlePage extends StatelessWidget {
  final String title;
  const ArticlePage(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: VI.surface, title: Text(title)),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_articles[title] ?? 'Read the full article on vocalimage.app.', style: const TextStyle(fontSize: 18, height: 1.5)),
        ),
      );
}
