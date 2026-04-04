import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _sand = Color(0xFFF6EFE8);
  static const _mist = Color(0xFFFFFBF7);
  static const _ink = Color(0xFF1D1A1D);
  static const _rose = Color(0xFFF06A61);
  static const _teal = Color(0xFF2D978E);
  static const _clay = Color(0xFFBF8666);
  static const _slate = Color(0xFF5A6272);

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _mist,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _rose,
        brightness: Brightness.light,
        surface: Colors.white,
      ).copyWith(
        primary: _rose,
        secondary: _teal,
        tertiary: _clay,
        outline: _slate.withOpacity(0.25),
      ),
    );

    final textTheme = GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: _ink,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: _ink,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: _ink,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: _ink,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: _slate,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.78),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _sand.withOpacity(0.75),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: _slate.withOpacity(0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: _rose,
            width: 1.3,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _rose.withOpacity(0.16),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
