import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/core/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static const double _radius = 4;

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.action,
      onPrimary: AppColors.surface,
      secondary: AppColors.primary,
      onSecondary: AppColors.surface,
      error: AppColors.error,
      onError: AppColors.surface,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    );

    final textTheme = TextTheme(
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      headlineSmall: AppTextStyles.h3,
      titleLarge: AppTextStyles.h2,
      titleMedium: AppTextStyles.h3,
      titleSmall: AppTextStyles.label,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.label,
      labelMedium: AppTextStyles.button,
      labelSmall: AppTextStyles.caption,
    );
    
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.bodyLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.action,
          foregroundColor: AppColors.surface,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: shape,
          textStyle: textTheme.labelMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.action,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size.fromHeight(48),
          shape: shape,
          textStyle: AppTextStyles.link,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        border: inputBorder(AppColors.border),
        enabledBorder: inputBorder(AppColors.border),
        focusedBorder: inputBorder(AppColors.action, 1.5),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error, 1.5),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
        unselectedLabelStyle: AppTextStyles.caption,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
