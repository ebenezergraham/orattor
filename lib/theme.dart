import 'package:flutter/material.dart';

class VI {
  static const primary = Color(0xFFFFD15A);
  static const bg = Color(0xFF121620);
  static const bg2 = Color(0xFF1B202C);
  static const card = Color(0xFF222833);
  static const surface = Color(0xFF10131A);
  static const border = Color(0xFF2B3242);
  static const action = Color(0xFF6589EC);
  static const success = Color(0xFF12B76A);
  static const muted = Color(0xFF9AA3B8);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: VI.bg,
    colorScheme: const ColorScheme.dark(
      primary: VI.primary,
      onPrimary: Color(0xFF171723),
      secondary: VI.action,
      surface: VI.bg2,
    ),
    textTheme: base.textTheme.apply(fontFamily: 'Ubuntu', fontFamilyFallback: const ['Roboto', 'Arial']),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: VI.primary,
        foregroundColor: const Color(0xFF171723),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    cardTheme: CardThemeData(
      color: VI.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: VI.border),
      ),
    ),
  );
}
