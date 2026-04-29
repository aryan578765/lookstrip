import 'package:flutter/material.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_typography.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';

/// LooksTrip Theme — Dark Only
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ─── Color Scheme ───
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.teal,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.tealContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),

      // ─── Scaffold ───
      scaffoldBackgroundColor: AppColors.surface,

      // ─── Text Theme ───
      textTheme: textTheme.apply(
        bodyColor: AppColors.onSurface,
        displayColor: AppColors.onSurface,
      ),

      // ─── App Bar ───
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: AppColors.onSurface,
        ),
      ),

      // ─── Bottom Nav / App Bar ───
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        height: AppShapes.navBarHeight,
      ),

      // ─── FAB ───
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusFull),
        ),
      ),

      // ─── Cards ───
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusLg),
        ),
      ),

      // ─── Elevated Button ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, AppShapes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShapes.radiusFull),
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ─── Outlined Button ───
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShapes.radiusFull),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ─── Text Button ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ─── Input Decoration ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppShapes.spaceMd,
          vertical: AppShapes.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.onSurfaceMuted,
        ),
      ),

      // ─── Chip ───
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        selectedColor: AppColors.primaryContainer,
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.onSurface),
        side: const BorderSide(color: AppColors.outline, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppShapes.spaceMd,
          vertical: AppShapes.spaceXs,
        ),
      ),

      // ─── Bottom Sheet ───
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppShapes.radius2xl),
          ),
        ),
        dragHandleColor: AppColors.outline,
        dragHandleSize: Size(36, 4),
        showDragHandle: true,
      ),

      // ─── Dialog ───
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.radius2xl),
        ),
      ),

      // ─── Divider ───
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ─── Snackbar ───
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
