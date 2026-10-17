import 'package:flutter/material.dart';

class Feature {
  final IconData icon;
  final String title, body;
  const Feature(this.icon, this.title, this.body);
}

class VoiceTest {
  final IconData icon;
  final String title, body;
  const VoiceTest(this.icon, this.title, this.body);
}

const goals = [
  'Enhance professional or leadership skills',
  'Develop public speaking or presentation abilities',
  'Cultivate masculinity or femininity',
  'Increase self-confidence',
  'Discover voice type',
];

const features = [
  Feature(Icons.forum_rounded, 'AI Roleplay',
      'Practice interviews, salary negotiations and first dates. The AI character responds, pushes back and scores you.'),
  Feature(Icons.record_voice_over_rounded, 'Articulation Trainer',
      'Tongue twisters with AI scores for speed and clarity, plus leaderboards.'),
  Feature(Icons.graphic_eq_rounded, 'Intonation, Visualized',
      'Real-time pitch matching, presented like a rhythm game.'),
  Feature(Icons.air_rounded, 'Breathing & Calm',
      'Guided breathing exercises to reduce nerves before it counts.'),
  Feature(Icons.play_circle_rounded, 'Shorts',
      'Short coaching videos with one communication tip each.'),
  Feature(Icons.emoji_events_rounded, 'Voice Arena',
      'Compare your Voice Rating on a leaderboard.'),
];

const tests = [
  VoiceTest(Icons.translate_rounded, 'Accent Test', '120+ accents detected from one phrase.'),
  VoiceTest(Icons.psychology_rounded, 'Archetype Test', 'Find your voice among 12 archetypes.'),
  VoiceTest(Icons.speed_rounded, 'Tongue Twister Test', 'Articulation and pacing.'),
  VoiceTest(Icons.star_rounded, 'Voice Rating', '30 seconds rated for depth, energy and confidence.'),
  VoiceTest(Icons.mic_rounded, 'Voice Test', 'Pitch, tone and texture.'),
  VoiceTest(Icons.cake_rounded, 'Age Test', 'How old does your voice sound?'),
  VoiceTest(Icons.chat_rounded, 'Speech Test', 'Pace, clarity and filler words.'),
  VoiceTest(Icons.theater_comedy_rounded, 'Celebrity Test', 'Which famous voice matches yours?'),
  VoiceTest(Icons.language_rounded, 'Spanish Accent Test', '13 Spanish accents.'),
];


const steps = [
  ('Take the quiz', 'About two minutes of questions about your goals and obstacles.'),
  ('Get your daily plan', 'Short lessons with recorded exercises and instant AI feedback.'),
  ('Hear the difference', 'Re-test after two weeks and compare your recordings.'),
];


const tongueTwisters = [
  'She sells seashells by the seashore.',
  'Red lorry, yellow lorry, red lorry, yellow lorry.',
  'Peter Piper picked a peck of pickled peppers.',
  'Unique New York, you know you need unique New York.',
];

const menu = {
  'Books': ['7 Cues of Charisma', 'Ultimate Voice Guide', 'Mastering American Accent', 'Kill the "Um"'],
  'Free Tests': ['Accent Test', 'Archetype Test', 'Tongue Twister Test'],
  'Learn': ['Tongue Twisters', 'Voice Training', 'Public Speaking', 'Articulate'],
  'Research': ['TTS Landscape 2026'],
};
