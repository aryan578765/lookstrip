import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/trip_model.dart';

/// Detail bottom sheet showing full itinerary
class TripDetailSheet extends StatelessWidget {
  final Trip trip;

  const TripDetailSheet({super.key, required this.trip});

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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppShapes.radius2xl),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppShapes.spaceMd),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ─── Hero ───
              Container(
                height: 160,
                margin: const EdgeInsets.all(AppShapes.screenPadding),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppShapes.radiusLg),
                ),
                child: Center(
                  child: Text(trip.emoji, style: const TextStyle(fontSize: 72)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppShapes.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Title ───
                    Text(
                      trip.title,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 26,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppShapes.spaceXs),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.destination,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppShapes.spaceMd),

                    // ─── Info chips ───
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.calendar_month_rounded,
                          label:
                              '${_formatDate(trip.startDate)} – ${_formatDate(trip.endDate)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppShapes.spaceSm),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.schedule_rounded,
                          label: '${trip.days} days',
                        ),
                        const SizedBox(width: AppShapes.spaceSm),
                        _InfoChip(
                          icon: Icons.checklist_rounded,
                          label: '${trip.itinerary.length} days planned',
                        ),
                      ],
                    ),

                    const SizedBox(height: AppShapes.spaceLg),

                    // ─── Itinerary ───
                    if (trip.itinerary.isNotEmpty) ...[
                      Text(
                        'Itinerary',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppShapes.spaceMd),
                      ...trip.itinerary.map((day) => _DaySection(day: day)),
                    ] else ...[
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: AppShapes.spaceLg),
                            const Text('📝', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: AppShapes.spaceMd),
                            Text(
                              'No itinerary yet',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppShapes.spaceXs),
                            Text(
                              'Use AI Chat to generate one!',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppShapes.space3xl),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppShapes.spaceMd,
        vertical: AppShapes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: AppShapes.spaceXs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final TripDay day;

  const _DaySection({required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppShapes.spaceMd,
            vertical: AppShapes.spaceSm,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.amberGlow,
            borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          ),
          child: Text(
            'Day ${day.dayNumber} — ${day.title}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppShapes.spaceSm),

        // Activities
        ...day.activities.map(
          (activity) => Padding(
            padding: const EdgeInsets.only(
              left: AppShapes.spaceMd,
              bottom: AppShapes.spaceSm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline dot
                Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(width: 1, height: 32, color: AppColors.outline),
                  ],
                ),
                const SizedBox(width: AppShapes.spaceMd),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppShapes.spaceSm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Text(
                          activity.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: AppShapes.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    activity.time,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(width: AppShapes.spaceSm),
                                  Expanded(
                                    child: Text(
                                      activity.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                activity.description,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppShapes.spaceSm),
      ],
    );
  }
}
