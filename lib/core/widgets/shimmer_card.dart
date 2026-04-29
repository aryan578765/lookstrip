import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';

/// Base shimmer box
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Shimmer wrapper
class ShimmerWrap extends StatelessWidget {
  final Widget child;
  const ShimmerWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainer,
      highlightColor: AppColors.surfaceContainerHigh,
      child: child,
    );
  }
}

/// Flight card skeleton
class ShimmerFlightCard extends StatelessWidget {
  const ShimmerFlightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppShapes.spaceMd),
        padding: const EdgeInsets.all(AppShapes.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _ShimmerBox(width: 80, height: 16),
                const _ShimmerBox(width: 60, height: 24, radius: 12),
              ],
            ),
            const SizedBox(height: AppShapes.spaceMd),
            Row(
              children: [
                const _ShimmerBox(width: 40, height: 28),
                const SizedBox(width: AppShapes.spaceSm),
                Expanded(child: _ShimmerBox(height: 2)),
                const SizedBox(width: AppShapes.spaceSm),
                const _ShimmerBox(width: 40, height: 28),
              ],
            ),
            const SizedBox(height: AppShapes.spaceSm),
            const _ShimmerBox(width: 120, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Hotel card skeleton
class ShimmerHotelCard extends StatelessWidget {
  const ShimmerHotelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppShapes.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(height: 120, radius: AppShapes.radiusMd),
            Padding(
              padding: const EdgeInsets.all(AppShapes.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ShimmerBox(width: 180, height: 16),
                  const SizedBox(height: AppShapes.spaceSm),
                  const _ShimmerBox(width: 100, height: 12),
                  const SizedBox(height: AppShapes.spaceSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _ShimmerBox(width: 60, height: 14),
                      const _ShimmerBox(width: 80, height: 24),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Weather card skeleton
class ShimmerWeatherCard extends StatelessWidget {
  const ShimmerWeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(AppShapes.spaceSm),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        ),
        child: const Column(
          children: [
            _ShimmerBox(width: 30, height: 12),
            SizedBox(height: AppShapes.spaceSm),
            _ShimmerBox(width: 36, height: 36, radius: 18),
            SizedBox(height: AppShapes.spaceSm),
            _ShimmerBox(width: 50, height: 14),
          ],
        ),
      ),
    );
  }
}

/// Places card skeleton
class ShimmerPlacesCard extends StatelessWidget {
  const ShimmerPlacesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppShapes.spaceMd),
        padding: const EdgeInsets.all(AppShapes.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        ),
        child: const Row(
          children: [
            _ShimmerBox(width: 60, height: 60, radius: 12),
            SizedBox(width: AppShapes.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 140, height: 14),
                  SizedBox(height: AppShapes.spaceSm),
                  _ShimmerBox(width: 80, height: 10),
                  SizedBox(height: AppShapes.spaceXs),
                  _ShimmerBox(width: 100, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic list shimmer — shows N shimmer cards
class ShimmerList extends StatelessWidget {
  final int count;
  final Widget Function() builder;
  const ShimmerList({super.key, this.count = 3, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppShapes.screenPadding),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, _) => builder(),
    );
  }
}
