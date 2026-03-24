import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Frost & Slate Palette
  static const slate = Color(0xFF0F172A);
  static const slateSoft = Color(0xFF334155);
  static const slateMuted = Color(0xFF64748B);

  static const frost = Color(0xFFF5F7FA);
  static const frostDeep = Color(0xFFE2E8F0);
  static const glass = Color(0xFFFFFFFF);
  static const glassBorder = Color(0xFFE2E8F0);

  static const respiratoryTeal = Color(0xFF0D9488);
  static const respiratoryTealSoft = Color(0xFFCCFBFE);
  static const oxide = Color(0xFFE11D48);
  static const oxideSoft = Color(0xFFFFF1F2);
  static const gold = Color(0xFFCA8A04);
  static const goldSoft = Color(0xFFFEF9C3);
  static const success = Color(0xFF16A34A);

  static const shadow = Color(0x0F0F172A);

  static TextTheme _textTheme(Color bodyColor, Color mutedColor) {
    return TextTheme(
      displayLarge: GoogleFonts.fraunces(
        color: bodyColor,
        fontSize: 50,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.fraunces(
        color: bodyColor,
        fontSize: 40,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      headlineLarge: GoogleFonts.fraunces(
        color: bodyColor,
        fontSize: 32,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.fraunces(
        color: bodyColor,
        fontSize: 25,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleLarge: GoogleFonts.dmSans(
        color: bodyColor,
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.dmSans(
        color: bodyColor,
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.dmSans(
        color: bodyColor,
        fontSize: 16,
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.dmSans(
        color: mutedColor,
        fontSize: 14,
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.dmSans(
        color: bodyColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.dmSans(
        color: mutedColor,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.dmSans(
        color: mutedColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: frost,
    primaryColor: respiratoryTeal,
    colorScheme: const ColorScheme.light(
      primary: slate,
      onPrimary: Colors.white,
      secondary: gold,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: slate,
      error: oxide,
      onError: Colors.white,
      outline: glassBorder,
      surfaceContainerHighest: frostDeep,
      tertiary: success,
    ),
    textTheme: _textTheme(slate, slateMuted),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: slate),
      titleTextStyle: GoogleFonts.dmSans(
        color: slate,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.8),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: glassBorder, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: slate,
        foregroundColor: Colors.white,
        disabledBackgroundColor: frostDeep,
        disabledForegroundColor: slateMuted,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: slate,
        side: const BorderSide(color: glassBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: slate,
        backgroundColor: Colors.white.withValues(alpha: 0.5),
        minimumSize: const Size(44, 44),
      ),
    ),
    dividerTheme: const DividerThemeData(color: glassBorder, thickness: 0.5),
  );

  static ThemeData darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF020617), // Slate 950
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: slate,
      secondary: gold,
      surface: Color(0xFF0F172A), // Slate 900
      onSurface: Color(0xFFF1F5F9), // Slate 100
      error: oxide,
      outline: Color(0xFF1E293B), // Slate 800
      tertiary: success,
    ),
    textTheme: _textTheme(const Color(0xFFF1F5F9), const Color(0xFF94A3B8)),
  );

  static List<BoxShadow> get panelShadow => const <BoxShadow>[
    BoxShadow(color: shadow, blurRadius: 36, offset: Offset(0, 16)),
  ];

  static const BorderRadius panelRadius = BorderRadius.all(Radius.circular(28));

  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];
}
