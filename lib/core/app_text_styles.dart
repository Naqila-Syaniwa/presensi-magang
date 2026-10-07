import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presensimagang/core/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _inter(
    double size,
    FontWeight weight,
    Color color, {
      double? height,
    }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  // Judul
  static final TextStyle h1 =
      _inter(28, FontWeight.w600, AppColors.textPrimary);
  static final TextStyle h2 =
      _inter(20, FontWeight.w700, AppColors.textPrimary);
  static final TextStyle h3 =
      _inter(16, FontWeight.w600, AppColors.textPrimary);
  
  // Isi
  static final TextStyle bodyLarge =
      _inter(16, FontWeight.w400, AppColors.textPrimary, height: 1.5);
  static final TextStyle body =
      _inter(14, FontWeight.w400, AppColors.textPrimary, height: 1.5);
  static final TextStyle caption =
      _inter(12, FontWeight.w400, AppColors.textSecondary, height: 1.4);

  // Form dan tombol
  static final TextStyle label =
      _inter(14, FontWeight.w500, AppColors.textPrimary);
  static final TextStyle button =
      _inter(16, FontWeight.w500, AppColors.surface);
  static final TextStyle link =
      _inter(14, FontWeight.w500, AppColors.action);
}