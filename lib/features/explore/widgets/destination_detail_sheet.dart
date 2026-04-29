import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/destination_model.dart';
import 'package:lookstrip/core/providers/chat_provider.dart';
import 'package:lookstrip/core/providers/trips_provider.dart';
import 'package:lookstrip/core/services/weather_service.dart';
import 'package:lookstrip/core/widgets/destination_map.dart';
import 'package:lookstrip/features/shell/main_shell.dart';

/// Bottom sheet with full destination details
class DestinationDetailSheet extends ConsumerWidget {
  final Destination destination;

  const DestinationDetailSheet({super.key, required this.destination});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
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
              // ─── Handle ───
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

              // ─── Map Hero area ───
              Padding(
                padding: const EdgeInsets.all(AppShapes.screenPadding),
                child: Stack(
                  children: [
                    DestinationMapWidget(
                      destinationName: destination.name,
                      height: 200,
                      zoom: 9,
                    ),
                    Positioned(
                      bottom: AppShapes.spaceSm,
                      right: AppShapes.spaceSm,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          destination.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppShapes.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Name & Rating ───
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 28,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.amberGlow,
                            borderRadius: BorderRadius.circular(
                              AppShapes.radiusFull,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppColors.onPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                destination.rating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppShapes.spaceXs),

                    // ─── Location ───
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${destination.country} • ${destination.continent}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppShapes.spaceLg),

                    // ─── Quick Info Row ───
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.calendar_month_rounded,
                          label: destination.bestSeason,
                        ),
                        const SizedBox(width: AppShapes.spaceSm),
                        _InfoChip(
                          icon: Icons.attach_money_rounded,
                          label: destination.priceLevel,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppShapes.spaceLg),

                    // ─── Description ───
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppShapes.spaceSm),
                    Text(
                      destination.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: AppShapes.spaceLg),

                    // ─── Categories ───
                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppShapes.spaceSm),
                    Wrap(
                      spacing: AppShapes.spaceSm,
                      runSpacing: AppShapes.spaceSm,
                      children: destination.categories.map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppShapes.spaceMd,
                            vertical: AppShapes.spaceSm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(
                              AppShapes.radiusFull,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.primary),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppShapes.spaceLg),

                    // ─── Weather Preview (live from Open-Meteo) ───
                    _WeatherPreview(destination: destination),

                    const SizedBox(height: AppShapes.spaceXl),

                    // ─── Action Buttons ───
                    SizedBox(
                      width: double.infinity,
                      height: AppShapes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          final tabSwitcher = TabSwitcher.of(context);
                          final shell = mainShellKey.currentState;
                          Navigator.pop(context);
                          // Send to AI Chat with destination prompt
                          ref
                              .read(chatProvider.notifier)
                              .sendMessage(
                                'Plan a detailed trip to ${destination.name}, ${destination.country}. '
                                'I love ${destination.categories.join(", ")}. '
                                'Best season is ${destination.bestSeason}. '
                                'Give me a day-by-day itinerary.',
                              );
                          // Switch to Chat tab
                          shell?.switchToTab(2);
                          if (shell == null) tabSwitcher?.switchTo(2);
                        },
                        child: Text('Plan a trip to ${destination.name} ✨'),
                      ),
                    ),

                    const SizedBox(height: AppShapes.spaceSm),

                    SizedBox(
                      width: double.infinity,
                      height: AppShapes.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {
                          final tabSwitcher = TabSwitcher.of(context);
                          final shell = mainShellKey.currentState;
                          // Create a trip for this destination
                          ref
                              .read(tripsProvider.notifier)
                              .createTrip(
                                destination: destination.name,
                                emoji: destination.emoji,
                                days: 5,
                              );
                          Navigator.pop(context);
                          // Switch to Trips tab to show the new trip
                          shell?.switchToTab(3);
                          if (shell == null) tabSwitcher?.switchTo(3);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppShapes.radiusFull,
                            ),
                          ),
                        ),
                        child: const Text('Save as Trip 🧳'),
                      ),
                    ),

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
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppShapes.spaceXs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}

/// Live weather preview fetched from Open-Meteo
class _WeatherPreview extends StatefulWidget {
  final Destination destination;
  const _WeatherPreview({required this.destination});

  @override
  State<_WeatherPreview> createState() => _WeatherPreviewState();
}

class _WeatherPreviewState extends State<_WeatherPreview> {
  List<dynamic>? _weather;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final forecast = await WeatherService().getForecast(
        widget.destination.name,
      );
      if (mounted) {
        setState(() {
          _weather = forecast;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Weather',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppShapes.spaceSm),
        if (_loading)
          const SizedBox(
            height: 60,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          )
        else if (_weather == null || _weather!.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppShapes.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppShapes.radiusMd),
            ),
            child: Row(
              children: [
                const Text('🌍', style: TextStyle(fontSize: 24)),
                const SizedBox(width: AppShapes.spaceSm),
                Text(
                  'Weather data unavailable',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _weather!.take(5).length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppShapes.spaceSm),
              itemBuilder: (context, index) {
                final day = _weather![index];
                return Container(
                  width: 70,
                  padding: const EdgeInsets.all(AppShapes.spaceSm),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? AppColors.primaryContainer.withValues(alpha: 0.4)
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                    border: index == 0
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(day.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        '${day.tempMax.round()}°',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${day.tempMin.round()}°',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
