import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';

/// Glassmorphism card — surgical use only (overlays, map cards, hero overlays)
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppShapes.radiusXl,
    this.padding,
    this.blur = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: RepaintBoundary(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppShapes.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
