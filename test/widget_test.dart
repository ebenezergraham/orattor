import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orattor/main.dart';
import 'package:orattor/audio.dart';
import 'dart:math';

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
}
