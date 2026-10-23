import 'package:flutter_test/flutter_test.dart';
import 'package:orattor/audio.dart';
import 'package:orattor/curriculum.dart';
import 'package:orattor/pages/lesson.dart';
import 'package:orattor/pages/programs.dart';

void main() {
  test('every track and lesson is complete and uniquely keyed', () {
    final keys = <String>{};
    for (final t in tracks) {
      expect(t.lessons, isNotEmpty, reason: t.name);
      for (final l in t.lessons) {
        expect(l.steps.length, greaterThanOrEqualTo(3), reason: '${t.name}/${l.title}');
        expect(l.why.trim(), isNotEmpty);
        expect(l.success.trim(), isNotEmpty);
        expect(l.minutes, inInclusiveRange(1, 10));
        for (final s in l.steps) {
          expect(s.text.trim(), isNotEmpty);
          expect(s.seconds, inInclusiveRange(0, 180));
        }
        expect(keys.add(t.key(l)), isTrue, reason: 'duplicate ${t.key(l)}');
      }
    }
  });

  test('track keys do not collide with legacy programs', () {
    final legacy = {for (final p in programs) ...[for (final l in p.lessons) '${p.name}/${l.$1}']};
    for (final t in tracks) {
      for (final l in t.lessons) {
        expect(legacy.contains(t.key(l)), isFalse);
      }
    }
  });

  test('recommendations start with foundations and follow curriculum order', () {
    final path = recommendedTracks({Concern.presenting, Concern.nasal});
    expect(path.map((t) => t.name), ['Foundations', 'Nasal voice', 'Presenting']);
    expect(recommendedTracks({}).map((t) => t.name), ['Foundations']);
  });

  test('measure readouts handle silence and describe pitch, pace', () {
    const silent = VoiceMetrics(0, 0, -60, 0, 0, 0, 5);
    expect(describeMeasure(Measure.pitch, silent), contains("didn't hear"));
    const voice = VoiceMetrics(112, 10, -24, .6, 4, 3, 10);
    expect(describeMeasure(Measure.pitch, voice), contains('112 Hz'));
    expect(describeMeasure(Measure.pace, voice), contains('words per minute'));
    const high = VoiceMetrics(190, 10, -24, .6, 4, 3, 10);
    expect(describeMeasure(Measure.pitch, high), contains('yawn-sigh'));
  });
}
