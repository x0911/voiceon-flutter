import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = _buildLightTheme();
  static final ThemeData darkTheme = _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    final base = FlexColorScheme.light(
      colors: const FlexSchemeColor(
        primary: Color(0xFF00796B),
        primaryContainer: Color(0xFFB2DFDB),
        secondary: Color(0xFF004D40),
        tertiary: Color(0xFF80CBC4),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 9,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      appBarStyle: FlexAppBarStyle.primary,
      subThemesData: const FlexSubThemesData(inputDecoratorRadius: 16),
      useMaterial3: true,
      fontFamily: GoogleFonts.dmSans().fontFamily,
    ).toTheme;

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.dmSerifDisplay(
          textStyle: base.textTheme.displayLarge,
        ),
        displayMedium: GoogleFonts.dmSerifDisplay(
          textStyle: base.textTheme.displayMedium,
        ),
        displaySmall: GoogleFonts.dmSerifDisplay(
          textStyle: base.textTheme.displaySmall,
        ),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          textStyle: base.textTheme.headlineSmall?.copyWith(
            color: base.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    final base = FlexColorScheme.dark(
      colors: const FlexSchemeColor(
        primary: Color(0xFF4DB6AC),
        primaryContainer: Color(0xFF004D40),
        secondary: Color(0xFF80CBC4),
        tertiary: Color(0xFF1DE9B6),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 15,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      appBarStyle: FlexAppBarStyle.primary,
      subThemesData: const FlexSubThemesData(inputDecoratorRadius: 16),
      useMaterial3: true,
      fontFamily: GoogleFonts.dmSans().fontFamily,
    ).toTheme;

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.dmSerifDisplay(
          textStyle: base.textTheme.displayLarge,
        ),
        displayMedium: GoogleFonts.dmSerifDisplay(
          textStyle: base.textTheme.displayMedium,
        ),
        displaySmall: GoogleFonts.dmSerifDisplay(
          textStyle: base.textTheme.displaySmall,
        ),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          textStyle: base.textTheme.headlineSmall?.copyWith(
            color: base.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
