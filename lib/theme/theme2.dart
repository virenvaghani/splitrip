// lib/theme/theme_data.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splitrip/theme/theme_colors.dart';

TextTheme buildTextTheme(Color textColor) {
  final baseTextStyle = GoogleFonts.inter(color: textColor, letterSpacing: 0.2);

  return TextTheme(
    displayLarge: baseTextStyle.copyWith(
      fontSize: 57,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
    ),
    displayMedium: baseTextStyle.copyWith(
      fontSize: 45,
      fontWeight: FontWeight.w300,
    ),
    displaySmall: baseTextStyle.copyWith(fontSize: 36),
    headlineLarge: baseTextStyle.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w500,
    ),
    headlineMedium: baseTextStyle.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: baseTextStyle.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: baseTextStyle.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: baseTextStyle.copyWith(fontSize: 16),
    bodyMedium: baseTextStyle.copyWith(fontSize: 14),
    bodySmall: baseTextStyle.copyWith(fontSize: 12),
    labelLarge: baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: baseTextStyle.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: baseTextStyle.copyWith(
      fontSize: 11,
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
