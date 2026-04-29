import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LooksTrip Typography System
/// Display: DM Serif Display — elegant, editorial
/// UI/Body: DM Sans — clean, legible, geometric
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    return TextTheme(
      // ─── Display ───
      displayLarge: GoogleFonts.dmSerifDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 44 / 36,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 30,
        fontWeight: FontWeight.w400,
        height: 38 / 30,
        letterSpacing: -0.25,
      ),
      displaySmall: GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 32 / 24,
        letterSpacing: 0,
      ),

      // ─── Headline ───
      headlineLarge: GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 28 / 20,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        letterSpacing: 0.15,
      ),

      // ─── Body ───
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        letterSpacing: 0.4,
      ),

      // ─── Label ───
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 16 / 11,
        letterSpacing: 0.5,
      ),
    );
  }
}
