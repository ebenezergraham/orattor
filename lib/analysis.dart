import 'dart:math';
import 'audio.dart';
import 'state.dart';

int _c(num v) => v.round().clamp(0, 100);

String pitchClass(double hz) {
  if (hz <= 0) return 'Unknown';
  if (hz < 110) return 'Deep (bass)';
  if (hz < 150) return 'Low (baritone)';
  if (hz < 200) return 'Medium';
  if (hz < 260) return 'High (alto)';
  return 'Very high (soprano)';
}

Result voiceTest(VoiceMetrics m) {
  final variation = _c(m.pitchStd / 40 * 100);
  final steadiness = _c(100 - (m.pitchStd - 15).abs() * 2);
  return Result('Voice Test', {
    'Pitch (Hz)': m.meanPitch.round(),
    'Tone variation': variation,
    'Texture steadiness': steadiness,
  }, pitchClass(m.meanPitch));
}

Result voiceRating(VoiceMetrics m) {
  final depth = _c(100 - (m.meanPitch - 85) / 2.2);
  final energy = _c((m.loudnessDb + 50) * 3.3);
  final conf = _c(m.voicedRatio * 60 + min(m.pitchStd, 40) + (m.pauses < 3 ? 10 : 0));
  final overall = _c((depth + energy + conf) / 3);
  return Result('Voice Rating', {'Depth': depth, 'Energy': energy, 'Confidence': conf, 'Overall': overall},
      'Your voice scores $overall/100');
}

Result speechTest(VoiceMetrics m) {
  final wpm = (m.syllablesPerSec * 60 / 1.5).round(); // ~1.5 syllables per word
  final pace = _c(100 - (wpm - 150).abs() * 0.8);
  final clarity = _c(m.voicedRatio * 120);
  final fluency = _c(100 - m.pauses * 12);
  return Result('Speech Test', {'Words/min (est.)': wpm, 'Pace': pace, 'Clarity': clarity, 'Fluency (pauses)': fluency},
      wpm < 110 ? 'A little slow' : wpm > 190 ? 'A little fast' : 'Great pace');
}

Result ageTest(VoiceMetrics m) {
  // Playful heuristic: pitch plus steadiness.
  final base = m.meanPitch < 140 ? 38 : m.meanPitch < 190 ? 30 : 24;
  final age = (base + (m.pitchStd < 12 ? 10 : 0) - (m.pitchStd > 35 ? 6 : 0)).clamp(16, 80);
  return Result('Age Test', {'Perceived age': age}, 'Your voice sounds about $age');
}

const celebrities = [
  ('Morgan Freeman', 100.0, 'calm and resonant'),
  ('Barack Obama', 120.0, 'measured and warm'),
  ('Keanu Reeves', 135.0, 'soft and sincere'),
  ('Emma Watson', 190.0, 'clear and bright'),
  ('Scarlett Johansson', 175.0, 'husky and smooth'),
  ('Taylor Swift', 215.0, 'light and expressive'),
];

Result celebrityTest(VoiceMetrics m) {
  final best = celebrities.reduce(
      (a, b) => (a.$2 - m.meanPitch).abs() <= (b.$2 - m.meanPitch).abs() ? a : b);
  final match = _c(100 - (best.$2 - m.meanPitch).abs() * 1.2);
  return Result('Celebrity Test', {'Match %': match}, 'You sound like ${best.$1} — ${best.$3}');
}

Result tongueTwisterTest(VoiceMetrics m, int words) {
  final wps = m.seconds == 0 ? 0 : words / m.seconds;
  final speed = _c(wps / 4 * 100);
  final clarity = _c(m.voicedRatio * 120 - m.pauses * 5);
  return Result('Tongue Twister Test', {'Speed': speed, 'Clarity': clarity, 'Overall': _c((speed + clarity) / 2)},
      'Finished in ${m.seconds.toStringAsFixed(1)}s');
}

const accents = ['General American', 'British (RP)', 'Australian', 'Irish', 'Indian English', 'Southern US', 'Canadian', 'South African'];

/// Not a real accent classifier — a trained model is required.
Result accentTest(VoiceMetrics m, String native) {
  final r = Random(m.meanPitch.round() * 31 + m.syllablesPerSec.round());
  final strength = _c(30 + r.nextInt(50) + (m.pauses > 2 ? 8 : 0));
  final a = accents[r.nextInt(accents.length)];
  return Result('Accent Test', {'Accent strength': strength},
      'Closest to $a (demo estimate, native: $native)');
}

class Archetype {
  final String name, blurb;
  const Archetype(this.name, this.blurb);
}

const archetypes = [
  Archetype('The Commander', 'Authoritative and decisive. People follow your lead.'),
  Archetype('The Storyteller', 'Warm, expressive, and magnetic in a room.'),
  Archetype('The Analyst', 'Calm, precise, and credible with facts.'),
  Archetype('The Mentor', 'Patient and encouraging; makes others feel safe.'),
  Archetype('The Entertainer', 'Playful energy and quick wit.'),
  Archetype('The Diplomat', 'Smooth and balanced; defuses tension.'),
];

const archetypeQuiz = [
  ('In a meeting you usually...', ['Take charge', 'Tell a story', 'Present the data', 'Make sure everyone is heard']),
  ('Your friends say your voice is...', ['Strong', 'Expressive', 'Steady', 'Comforting']),
  ('Under pressure you...', ['Speak firmly', 'Use humor', 'Slow down and think', 'Seek compromise']),
];

Result archetypeResult(List<int> answers) {
  final tally = List<int>.filled(4, 0);
  for (final a in answers) {
    tally[a]++;
  }
  final top = tally.indexOf(tally.reduce(max));
  final idx = [0, 1, 2, 3][top] + (answers.fold<int>(0, (a, b) => a + b) % 2 == 0 ? 0 : 2);
  final a = archetypes[idx % archetypes.length];
  return Result('Archetype Test', {}, '${a.name}: ${a.blurb}');
}
