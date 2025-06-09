import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splitrip/theme/theme.dart';
import '../data/constants.dart';

// Define custom colors
const Color lightBackground = Color(0xFFF5F5F5);
const Color darkBackground = Color(0xFF212121);
Color primaryColor = colortheme.themecolor; // Ensure colortheme.themecolor is defined
const Color accentColor = Color(0xFF03DAC6);
const Color lightTextColor = Color(0xFF212121);
const Color darkTextColor = Color(0xFFE0E0E0);
const Color secondaryColor = Color(0xFF757575);

// Custom text theme
TextTheme _buildTextTheme(Color textColor, Brightness brightness) {
  final baseTextStyle = GoogleFonts.inter(
    color: textColor,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w400,
  );

  return TextTheme(
    displayLarge: baseTextStyle.copyWith(fontSize: 57, fontWeight: FontWeight.w300, letterSpacing: -0.5),
    displayMedium: baseTextStyle.copyWith(fontSize: 45, fontWeight: FontWeight.w300),
    displaySmall: baseTextStyle.copyWith(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: baseTextStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w500),
    headlineMedium: baseTextStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w500),
    headlineSmall: baseTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w500),
    titleLarge: baseTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: baseTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
    titleSmall: baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    bodyLarge: baseTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall: baseTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelLarge: baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelMedium: baseTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall: baseTextStyle.copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );
}

class ThemeController extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isTransitioning = false;

  ThemeController() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isTransitioning => _isTransitioning;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  Future<void> setThemeMode(bool value) async {
    try {
      _isTransitioning = true;
      notifyListeners();

      _isDarkMode = value;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(Kconstant.ThemeModeKey, value);

      // Wait for the transition duration (300ms) before removing blur
      await Future.delayed(const Duration(milliseconds: 300));
      _isTransitioning = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme: $e');
      _isTransitioning = false;
      notifyListeners();
    }
  }

  Future<void> _loadTheme() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(Kconstant.ThemeModeKey) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  // Light Theme
  final ThemeData lightTheme = ThemeData(

    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: lightTextColor,
      error: Color(0xFFD32F2F),
      onError: Colors.white,
    ),
    textTheme: _buildTextTheme(lightTextColor, Brightness.light),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightTextColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: Color(0xFF212121),
        letterSpacing: 0.2,
        fontWeight: FontWeight.w400,
      ).copyWith(fontSize: 24, fontWeight: FontWeight.w500),
      iconTheme: IconThemeData(color: lightTextColor),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: secondaryColor,
      thickness: 1,
    ),
    iconTheme: IconThemeData(
      color: lightTextColor,
      size: 24,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: secondaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: secondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: secondaryColor,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.inter(
        color: secondaryColor.withOpacity(0.6),
        fontSize: 14,
      ),
    ),
  );

  // Dark Theme
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextColor,
      error: Color(0xFFEF5350),
      onError: Colors.black,
    ),
    textTheme: _buildTextTheme(darkTextColor, Brightness.dark),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkTextColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: Color(0xFFE0E0E0),
        letterSpacing: 0.2,
        fontWeight: FontWeight.w400,
      ).copyWith(fontSize: 24, fontWeight: FontWeight.w500),
      iconTheme: IconThemeData(color: darkTextColor),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: Color(0xFF2A3439),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Color(0xFF959393),
      thickness: 1,
    ),
    iconTheme: IconThemeData(
      color: darkTextColor,
      size: 24,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFF616161)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFF616161)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: darkTextColor,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.inter(
        color: darkTextColor.withOpacity(0.6),
        fontSize: 14,
      ),
    ),
  );
}