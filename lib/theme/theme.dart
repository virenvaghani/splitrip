// lib/theme/theme_data.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splitrip/theme/theme_colors.dart';

TextTheme buildTextTheme(Color textColor) {
  final baseTextStyle = GoogleFonts.sora(color: textColor, letterSpacing: 0.2);

  return TextTheme(
    // Large Displays
    displayLarge: baseTextStyle.copyWith(
      fontSize: 30, // Reduced from 54
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
    ),
    displayMedium: baseTextStyle.copyWith(
      fontSize: 28, // Reduced from 42
      fontWeight: FontWeight.w300,
    ),
    displaySmall: baseTextStyle.copyWith(
      fontSize: 26, // Reduced from 34
      fontWeight: FontWeight.w400,
    ),

    // Headlines
    headlineLarge: baseTextStyle.copyWith(
      fontSize: 22, // Reduced from 28
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: baseTextStyle.copyWith(
      fontSize: 20, // Reduced from 24
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: baseTextStyle.copyWith(
      fontSize: 18, // Reduced from 20
      fontWeight: FontWeight.w400,
    ),

    // Titles
    titleLarge: baseTextStyle.copyWith(
      fontSize: 16, // Reduced from 18
      fontWeight: FontWeight.w600,
    ),
    titleMedium: baseTextStyle.copyWith(
      fontSize: 14, // Reduced from 16
      fontWeight: FontWeight.w500,
    ),
    titleSmall: baseTextStyle.copyWith(
      fontSize: 12, // Reduced from 14
      fontWeight: FontWeight.w500,
    ),

    // Body Text
    bodyLarge: baseTextStyle.copyWith(
      fontSize: 16, // Reduced from 16
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: baseTextStyle.copyWith(
      fontSize: 14, // Reduced from 14
      fontWeight: FontWeight.w400,
    ),
    bodySmall: baseTextStyle.copyWith(
      fontSize: 12, // Reduced from 12
      fontWeight: FontWeight.w400,
    ),

    // Labels
    labelLarge: baseTextStyle.copyWith(
      fontSize: 14, // Reduced from 14
      fontWeight: FontWeight.w500,
    ),
    labelMedium: baseTextStyle.copyWith(
      fontSize: 12, // Reduced from 12
      fontWeight: FontWeight.w500,
    ),
    labelSmall: baseTextStyle.copyWith(
      fontSize: 10, // Reduced from 10
      fontWeight: FontWeight.w500,
    ),
  );
}


final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackground,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.lightBackground,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: AppColors.lightText,
    error: Colors.red.shade700,
    onError: Colors.white,
  ),
  textTheme: buildTextTheme(AppColors.lightText),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightBackground,
    foregroundColor: AppColors.lightText,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.inter(
      color: AppColors.lightText,
      fontWeight: FontWeight.w500,
      fontSize: 24,
    ),
    iconTheme: IconThemeData(color: AppColors.lightText),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.darkBackground,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.darkText,
    error: Colors.red.shade300,
    onError: Colors.black,
  ),
  textTheme: buildTextTheme(AppColors.darkText),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkText,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.inter(
      color: AppColors.darkText,
      fontWeight: FontWeight.w500,
      fontSize: 24,
    ),
    iconTheme: IconThemeData(color: AppColors.darkText),
  ),
);
