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
        primary: Color(0xFF0D67B5),
        primaryContainer: Color(0xFFDCE9FD),
        secondary: Color(0xFF0A4F8A),
        tertiary: Color(0xFF72A7D9),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 9,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      appBarStyle: FlexAppBarStyle.primary,
      subThemesData: const FlexSubThemesData(inputDecoratorRadius: 16),
      useMaterial3: true,
      fontFamily: GoogleFonts.openSans().fontFamily,
    ).toTheme;

    return base.copyWith(
      chipTheme: base.chipTheme.copyWith(showCheckmark: false),
      textTheme: GoogleFonts.openSansTextTheme(base.textTheme).copyWith(
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
        titleTextStyle: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: base.colorScheme.onPrimary,
        ),
        toolbarTextStyle: GoogleFonts.openSans(
          fontSize: 14,
          color: base.colorScheme.onPrimary,
        ),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    final base = FlexColorScheme.dark(
      colors: const FlexSchemeColor(
        primary: Color(0xFF0D67B5),
        primaryContainer: Color(0xFF0F3A67),
        secondary: Color(0xFF93C2FF),
        tertiary: Color(0xFF5A9BFF),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 15,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      appBarStyle: FlexAppBarStyle.primary,
      subThemesData: const FlexSubThemesData(inputDecoratorRadius: 16),
      useMaterial3: true,
      fontFamily: GoogleFonts.openSans().fontFamily,
    ).toTheme;

    return base.copyWith(
      chipTheme: base.chipTheme.copyWith(showCheckmark: false),
      textTheme: GoogleFonts.openSansTextTheme(base.textTheme).copyWith(
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
        titleTextStyle: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: base.colorScheme.onPrimary,
        ),
        toolbarTextStyle: GoogleFonts.openSans(
          fontSize: 14,
          color: base.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
