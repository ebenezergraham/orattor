import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orattor/main.dart';
import 'package:orattor/audio.dart';
import 'dart:math';
import 'package:orattor/pages/words.dart';

void main() {
  testWidgets('landing renders', (t) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(1600, 900);
    t.view.devicePixelRatio = 1;
    await t.pumpWidget(const OrattorApp());
    expect(find.text('Get my training plan'), findsOneWidget);
  });

  test('pitch detector finds 200 Hz sine', () {
    final x = [for (var i = 0; i < 1024; i++) sin(2 * pi * 200 * i / 16000)];
    expect((VoiceRecorder.pitchOf(x, 16000) - 200).abs() < 6, isTrue);
  });

  test('word grading compares key terms', () {
    const meaning = 'Optimistic, especially in a bad or difficult situation';
    Recall grade(String a) => gradeExplanation(a, meaning).suggested;
    expect(
      grade('optimistic in a difficult situation, especially'),
      Recall.good,
    );
    expect(grade('being optimism when things are difficult'), Recall.partial);
    expect(grade('a type of fish'), Recall.missed);
  });

  test('word picker favours unpracticed words and avoids repeats', () {
    final a = WordEntry(word: 'a', meaning: 'x', practiced: 5, score: 5);
    final b = WordEntry(word: 'b', meaning: 'y');
    final store = WordStore.I..words = [a, b];
    expect(store.pick(not: a), b);
    expect(store.pick(), isNotNull);
  });
}
