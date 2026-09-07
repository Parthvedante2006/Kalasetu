import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const turmeric = Color(0xFFD9971C);
  static const terracotta = Color(0xFFBF5B3F);
  static const indigo = Color(0xFF2B3A55);
  static const handloomCream = Color(0xFFF3ECDD);
  static const warmCharcoal = Color(0xFF33302C);
  static const sage = Color(0xFF7C8B6F);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.muktaTextTheme();

    return ThemeData(
      scaffoldBackgroundColor: AppColors.handloomCream,
      primaryColor: AppColors.turmeric,
      colorScheme: ColorScheme.light(
        primary: AppColors.turmeric,
        secondary: AppColors.terracotta,
        surface: AppColors.handloomCream,
        onPrimary: Colors.white,
        onSurface: AppColors.warmCharcoal,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineMedium: GoogleFonts.mukta(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.indigo,
        ),
        bodyLarge: GoogleFonts.mukta(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.warmCharcoal,
        ),
        bodySmall: GoogleFonts.mukta(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.warmCharcoal.withValues(alpha: 0.7),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.turmeric,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.mukta(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.handloomCream,
        elevation: 3,
        shadowColor: AppColors.warmCharcoal.withValues(alpha: 0.25),
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.indigo,
        iconTheme: const IconThemeData(color: AppColors.indigo),
        titleTextStyle: GoogleFonts.mukta(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.indigo,
          letterSpacing: 0.5,
        ),
      ),
      useMaterial3: true,
    );
  }
}