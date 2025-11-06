// lib/app/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // Cache untuk mencegah rebuild yang tidak perlu
  static TextTheme? _cachedTextTheme;

  static TextTheme _buildTextTheme() {
    if (_cachedTextTheme != null) return _cachedTextTheme!;

    _cachedTextTheme = TextTheme(
      // [hero] = 110px
      displayLarge: GoogleFonts.poppins(
        fontSize: 110,
        fontWeight: FontWeight.w300,
        color: AppColors.textDark,
      ),

      // [h1] = 68px
      headlineLarge: GoogleFonts.poppins(
        fontSize: 68,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),

      // [h2] = 42px
      headlineMedium: GoogleFonts.poppins(
        fontSize: 42,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),

      // [h3] = 26px
      headlineSmall: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),

      // [normal] = 16px -> bodyLarge
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textDark,
      ),

      // [caption] = 10px -> labelSmall
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.normal,
        color: AppColors.neutral600,
      ),

      // Standar M3 Text Styles
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textDark,
      ),
    );

    return _cachedTextTheme!;
  }

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
  scaffoldBackgroundColor: AppColors.neutral100,
    
    // --- 1. Color Scheme ---
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textLight,        
      secondary: AppColors.accent,           
      onSecondary: AppColors.textDark,      
      surface: AppColors.neutral100,         
      onSurface: AppColors.textDark,         
      error: Colors.red,                     
    ),

    // --- 2. Text Theme (Menggunakan cached text theme) ---
    textTheme: _buildTextTheme(),
    
  );
}