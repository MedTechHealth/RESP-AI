import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vicks Palette (Parchment & Menthol)
  static const parchment = Color(0xFFF5F0E6);
  static const vicksBlue = Color(0xFF003366);
  static const vicksBlueSoft = Color(0xFFE0E7FF);
  static const mentholCyan = Color(0xFF00C6B5);
  static const clinicalAmber = Color(0xFFFFB800);
  static const success = Color(0xFF16A34A);
  static const oxide = Color(0xFFE11D48);

  static const glassBorder = Color(0x1A003366); // vicksBlue with 0.1 alpha
  static const shadow = Color(0x0F003366);

  // Aliases for backward compatibility during transition
  static const slate = vicksBlue;
  static const slateSoft = vicksBlueSoft;
  static const slateMuted = Color(0xB3003366); // vicksBlue 0.7 alpha
  static const frost = parchment;
  static const frostDeep = Color(0xFFE8E4D8); // Slightly darker parchment
  static const glass = Colors.white;
  static const respiratoryTeal = mentholCyan;
  static const respiratoryTealSoft = Color(0x3300C6B5); // mentholCyan 0.2 alpha
  static const gold = clinicalAmber;
  static const goldSoft = Color(0x33FFB800); // clinicalAmber 0.2 alpha

  static TextTheme _textTheme(Color bodyColor, Color mutedColor) {
    final baseFeatures = [const FontFeature.tabularFigures()];

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
        fontFeatures: baseFeatures,
      ),
      bodyMedium: GoogleFonts.dmSans(
        color: mutedColor,
        fontSize: 14,
        height: 1.6,
        fontWeight: FontWeight.w400,
        fontFeatures: baseFeatures,
      ),
      labelLarge: GoogleFonts.dmSans(
        color: bodyColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        fontFeatures: baseFeatures,
      ),
      labelMedium: GoogleFonts.dmSans(
        color: mutedColor,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        fontFeatures: baseFeatures,
      ),
      labelSmall: GoogleFonts.dmSans(
        color: mutedColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        fontFeatures: baseFeatures,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: parchment,
    primaryColor: mentholCyan,
    colorScheme: const ColorScheme.light(
      primary: vicksBlue,
      onPrimary: Colors.white,
      secondary: mentholCyan,
      onSecondary: Colors.white,
      surface: parchment,
      onSurface: vicksBlue,
      error: oxide,
      onError: Colors.white,
      outline: glassBorder,
      surfaceContainerHighest: vicksBlueSoft,
      tertiary: clinicalAmber,
    ),
    textTheme: _textTheme(vicksBlue, vicksBlue.withValues(alpha: 0.7)),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: vicksBlue),
      titleTextStyle: GoogleFonts.dmSans(
        color: vicksBlue,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.6),
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
        backgroundColor: vicksBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: vicksBlueSoft,
        disabledForegroundColor: vicksBlue.withValues(alpha: 0.5),
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
        foregroundColor: vicksBlue,
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
        foregroundColor: vicksBlue,
        backgroundColor: Colors.white.withValues(alpha: 0.5),
        minimumSize: const Size(44, 44),
      ),
    ),
    dividerTheme: const DividerThemeData(color: glassBorder, thickness: 0.5),
  );

  static ThemeData darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF001A33), // Deepest Vicks Blue
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: vicksBlue,
      secondary: mentholCyan,
      surface: Color(0xFF00264D),
      onSurface: Color(0xFFF1F5F9),
      error: oxide,
      outline: Color(0xFF003366),
      tertiary: clinicalAmber,
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
