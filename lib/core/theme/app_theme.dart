import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Colores principales del boceto
  static const brand = Color(0xFF4F46E5);
  static const brand2 = Color(0xFF06B6D4);
  static const ok = Color(0xFF16A34A);
  static const warn = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const bg = Color(0xFFF6F8FC);
  static const card = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFE6EAF2);

  // Dark mode
  static const darkBg = Color(0xFF111827);
  static const darkCard = Color(0xFF1F2937);
  static const darkLine = Color(0xFF374151);

  // Gradientes
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, brand2],
  );

  static const okGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ok, brand2],
  );
}

class AppTheme {
  static const double cardRadius = 18.0;
  static const double buttonRadius = 999.0;
  static const double inputRadius = 14.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        brightness: Brightness.light,
        primary: AppColors.brand,
        secondary: AppColors.brand2,
        surface: AppColors.card,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg.withValues(alpha: 0.75),
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(
            color: AppColors.brand.withValues(alpha: 0.55),
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.muted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.muted, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// Sombra del boceto
const appShadow = BoxShadow(
  color: Color(0x140F172A),
  blurRadius: 30,
  offset: Offset(0, 10),
);
