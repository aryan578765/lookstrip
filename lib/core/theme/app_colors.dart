import 'package:flutter/material.dart';

/// LooksTrip Dark-Only Color System
/// Seed: #F59E0B (Amber) — All tokens pass WCAG AAA on dark backgrounds
class AppColors {
  AppColors._();

  // ─── Primary (Amber/Gold) ───
  static const Color primary = Color(0xFFFBBF24);
  static const Color primaryDark = Color(0xFFD97706);
  static const Color primaryDarker = Color(0xFFB45309);
  static const Color primaryContainer = Color(0xFF92400E);
  static const Color onPrimary = Color(0xFF1C1917);

  // ─── Surface (Dark) ───
  static const Color surface = Color(0xFF0C0A09);
  static const Color surfaceContainer = Color(0xFF1C1917);
  static const Color surfaceContainerHigh = Color(0xFF292524);
  static const Color surfaceContainerHighest = Color(0xFF44403C);

  // ─── Text ───
  static const Color onSurface = Color(0xFFFAFAF9);
  static const Color onSurfaceVariant = Color(0xFFA8A29E);
  static const Color onSurfaceMuted = Color(0xFF78716C);

  // ─── Outline ───
  static const Color outline = Color(0xFF44403C);
  static const Color outlineVariant = Color(0xFF292524);

  // ─── Accent ───
  static const Color teal = Color(0xFF0D9488);
  static const Color tealContainer = Color(0xFF042F2E);

  // ─── Semantic ───
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFF064E3B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFF78350F);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFF7F1D1D);

  // ─── Gradients ───
  static const LinearGradient amberGlow = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetHero = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGlass = LinearGradient(
    colors: [Color(0xB31C1917), Color(0x661C1917)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Shadows (Dark mode) ───
  static List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
