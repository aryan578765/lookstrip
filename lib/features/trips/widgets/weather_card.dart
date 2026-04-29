import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/weather_model.dart';

class WeatherCardWidget extends StatelessWidget {
  final WeatherDay day;
  const WeatherCardWidget({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('EEEE, MMM d').format(day.date);
    final isToday = DateUtils.isSameDay(day.date, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: AppShapes.spaceSm),
      padding: const EdgeInsets.all(AppShapes.spaceMd),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primaryContainer.withValues(alpha: 0.3)
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        border: isToday
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          // Weather emoji
          Text(day.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: AppShapes.spaceMd),

          // Date + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dayLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: AppShapes.spaceXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppShapes.radiusFull,
                          ),
                        ),
                        child: Text(
                          'Today',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.onPrimary,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  day.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (day.precipitationMm > 0.5)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '💧 ${day.precipitationMm.toStringAsFixed(1)}mm',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Temperature
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${day.tempMax.round()}°',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppColors.onSurface),
              ),
              Text(
                '${day.tempMin.round()}°',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
