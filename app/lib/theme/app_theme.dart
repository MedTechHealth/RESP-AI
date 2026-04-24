import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  // Lungs & Respiratory Theme Colors
  static const Color lungBlue = Color(0xFF0F172A);
  static const Color oxygenCyan = Color(0xFF06B6D4);
  static const Color breathTeal = Color(0xFF14B8A6);
  static const Color alertCoral = Color(0xFFF43F5E);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color safeGreen = Color(0xFF10B981);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0B0F19);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);

  // Vicks Vaprup Inspired Colors
  static const Color vaprupMint = Color(0xFFD9F4F4); // Light, cool background
  static const Color vaprupTeal = Color(0xFF00C0A4); // Primary green
  static const Color vaprupBlue = Color(0xFF007BFF); // Primary blue
  static const Color vaprupDarkText = Color(
    0xFF2C3E50,
  ); // Dark text for light themes
  static const Color vaprupLightText = Color(
    0xFFECF0F1,
  ); // Light text for dark themes
  static const Color vaprupAccent = Color(0xFF1ABC9C); // Accent color

  static const LinearGradient primaryVaprupGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vaprupBlue, vaprupTeal],
  );

  // Spacing Scale
  static const double spaceXs = 8.0;
  static const double spaceSm = 16.0;
  static const double spaceMd = 24.0;
  static const double spaceLg = 32.0;
  static const double spaceXl = 48.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: oxygenCyan,
        secondary: breathTeal,
        surface: surfaceLight,
        error: alertCoral,
        onPrimary: Colors.white,
        onSurface: lungBlue,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: lungBlue,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          color: lungBlue,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          color: lungBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lungBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lungBlue,
          side: const BorderSide(color: lungBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: oxygenCyan,
        secondary: breathTeal,
        surface: surfaceDark,
        error: alertCoral,
        onPrimary: lungBlue,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            displayMedium: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: oxygenCyan,
          foregroundColor: lungBlue,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  static ThemeData get vaprupTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: vaprupBlue,
        secondary: vaprupTeal,
        surface: vaprupMint,
        error: alertCoral, // Reusing existing error color
        onPrimary: Colors.white,
        onSurface: vaprupDarkText,
        onError: alertCoral,
        tertiary: warningAmber, // Using tertiary for warning
        tertiaryContainer: safeGreen, // Using tertiaryContainer for success
        onSecondary: vaprupDarkText,
        onBackground: vaprupDarkText,
        onSurfaceVariant: vaprupLightText,
        surfaceVariant: vaprupMint,
        outline: vaprupBlue,
        shadow: Colors.black12,
        inversePrimary: vaprupTeal,
        inverseSurface: vaprupBlue,
      ),
      scaffoldBackgroundColor: vaprupMint,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: vaprupDarkText,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          color: vaprupDarkText,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          color: vaprupDarkText,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(color: vaprupDarkText),
        bodyMedium: GoogleFonts.inter(color: vaprupDarkText),
        labelLarge: GoogleFonts.inter(color: vaprupDarkText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vaprupBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: vaprupBlue,
          side: const BorderSide(color: vaprupBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
