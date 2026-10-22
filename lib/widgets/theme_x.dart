import 'package:flutter/material.dart';

/// Jalan pintas warna tema untuk widget milik Dev B.
///
/// Dipakai supaya widget tidak menulis warna terang secara langsung
/// (Colors.white / AppColors.*) dan otomatis ikut mode gelap.
extension ThemeColorsX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Teks sekunder (setara AppColors.textSecondary di mode terang).
  Color get mutedText => colors.onSurface.withValues(alpha: 0.6);

  /// Garis/border/divider (mengikuti dividerTheme; di mode terang
  /// = AppColors.border).
  Color get lineColor =>
      Theme.of(this).dividerTheme.color ?? colors.outlineVariant;
}