import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.cloudBlue,
  fontFamily: GoogleFonts.inter().fontFamily,
  colorScheme: ColorScheme.light(
    primary: AppColors.deepBlue,
    onPrimary: AppColors.white,
    secondary: AppColors.accent,
    background: AppColors.cloudBlue,
    error: AppColors.error,
  ),
  textTheme: GoogleFonts.interTextTheme().copyWith(
    headlineLarge: const TextStyle(
        fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 28),
    titleMedium: const TextStyle(
        fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 17),
    bodyMedium: const TextStyle(
        color: AppColors.textMuted, fontSize: 15),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.skyBlue.withOpacity(0.9),
    foregroundColor: AppColors.deepBlue,
    elevation: 0,
    titleTextStyle: GoogleFonts.inter(
      fontWeight: FontWeight.bold,
      fontSize: 21,
      color: AppColors.deepBlue,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.7)),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.skyBlue,
      foregroundColor: AppColors.deepBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      elevation: 0,
    ),
  ),
);