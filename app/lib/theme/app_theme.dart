import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Premium Medical Tech Palette
  // Using more sophisticated shades
  static const primaryIndigo = Color(0xFF4F46E5); // Indigo 600
  static const primaryBlue = Color(0xFF2563EB); // Blue 600
  static const accentCyan = Color(0xFF06B6D4); // Cyan 500
  static const accentEmerald = Color(0xFF059669); // Emerald 600
  static const warningAmber = Color(0xFFD97706); // Amber 600
  static const errorRose = Color(0xFFE11D48); // Rose 600

  // Backgrounds & Surfaces
  static const scaffoldBg = Color(0xFFFBFDFF); // Very light blue-white
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF475569); // Slate 600
  static const textTertiary = Color(0xFF94A3B8); // Slate 400
  static const borderLight = Color(0xFFF1F5F9); // Slate 100
  static const borderMedium = Color(0xFFE2E8F0); // Slate 200

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryIndigo,
    scaffoldBackgroundColor: scaffoldBg,
    cardColor: cardBg,
    colorScheme: ColorScheme.light(
      primary: primaryIndigo,
      onPrimary: Colors.white,
      secondary: accentCyan,
      onSecondary: Colors.white,
      surface: cardBg,
      onSurface: textPrimary,
      error: errorRose,
      onError: Colors.white,
      outline: borderMedium,
      surfaceContainerHighest: Color(0xFFF8FAFC),
    ),

    // Modern Typography
    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        color: textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    ),

    // Component Themes
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimary, size: 24),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: primaryIndigo.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: borderLight, width: 1.5),
      ),
    ),
  );

  // Keep darkTheme for compatibility but updated to modern standards
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryIndigo,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    cardColor: const Color(0xFF1E293B),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryIndigo,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
  );
}
