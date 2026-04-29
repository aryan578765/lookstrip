import 'package:flutter/material.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/trip_model.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  int get _daysUntil => trip.startDate.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppShapes.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.radiusLg),
        ),
        child: Column(
          children: [
            // ─── Hero ───
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppShapes.radiusLg),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      trip.emoji,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: AppShapes.spaceSm,
                    left: AppShapes.spaceSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: trip.status == 'upcoming'
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(AppShapes.radiusSm),
                      ),
                      child: Text(
                        trip.status == 'upcoming' && _daysUntil > 0
                            ? 'In $_daysUntil days'
                            : trip.status.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: trip.status == 'upcoming'
                              ? AppColors.primary
                              : AppColors.onSurfaceMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  // Delete button
                  Positioned(
                    top: AppShapes.spaceSm,
                    right: AppShapes.spaceSm,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Info ───
            Padding(
              padding: const EdgeInsets.all(AppShapes.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppShapes.spaceXs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trip.destination,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppColors.onSurfaceMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(trip.startDate)} – ${_formatDate(trip.endDate)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppShapes.spaceSm),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: trip.itinerary.isNotEmpty ? 1.0 : 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.amberGlow,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppShapes.spaceSm),
                      Text(
                        '${trip.days} days',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
