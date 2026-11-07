import 'package:flutter/material.dart';

/// Mirrors the root design-tokens.json palette for the Android cashier shell.
abstract final class PosColors {
  static const canvas = Color(0xFFF5F3EF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFECE9E3);
  static const text = Color(0xFF242925);
  static const muted = Color(0xFF64685F);
  static const border = Color(0xFFDDDCD4);
  static const accent = Color(0xFFA74327);
  static const accentSoft = Color(0xFFF7E8DE);
  static const danger = Color(0xFFA12D32);
  static const success = Color(0xFF386044);
  static const ink = Color(0xFF232E29);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: PosColors.accent,
    brightness: Brightness.light,
    surface: PosColors.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(
      primary: PosColors.accent,
      surface: PosColors.surface,
      error: PosColors.danger,
    ),
    scaffoldBackgroundColor: PosColors.canvas,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: PosColors.text,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(color: PosColors.text, fontSize: 15, height: 1.5),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: PosColors.accent,
        foregroundColor: PosColors.surface,
      ),
    ),
  );
}
