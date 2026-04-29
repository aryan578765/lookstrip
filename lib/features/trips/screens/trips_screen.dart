import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/providers/trips_provider.dart';
import 'package:lookstrip/core/models/trip_model.dart';
import 'package:lookstrip/core/widgets/tap_scale.dart';
import 'package:lookstrip/features/trips/widgets/trip_card.dart';
import 'package:lookstrip/features/trips/screens/trip_detail_screen.dart';
import 'package:lookstrip/features/trips/widgets/create_trip_sheet.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsState = ref.watch(tripsProvider);
    final filtered = tripsState.filteredTrips;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppShapes.screenPadding,
              AppShapes.spaceLg,
              AppShapes.screenPadding,
              AppShapes.spaceMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Trips',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 28,
                    color: AppColors.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showCreateTrip(context, ref),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppShapes.spaceMd,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.amberGlow,
                      borderRadius: BorderRadius.circular(AppShapes.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          color: AppColors.onPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: AppShapes.spaceXs),
                        Text(
                          'New Trip',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Tabs ───
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppShapes.screenPadding,
            ),
            child: Row(
              children: [
                _TabChip(
                  label: 'Upcoming',
                  isSelected: tripsState.activeTab == 'upcoming',
                  onTap: () =>
                      ref.read(tripsProvider.notifier).setTab('upcoming'),
                ),
                const SizedBox(width: AppShapes.spaceSm),
                _TabChip(
                  label: 'Past',
                  isSelected: tripsState.activeTab == 'past',
                  onTap: () => ref.read(tripsProvider.notifier).setTab('past'),
                ),
                const SizedBox(width: AppShapes.spaceSm),
                _TabChip(
                  label: 'All',
                  isSelected: tripsState.activeTab == 'all',
                  onTap: () => ref.read(tripsProvider.notifier).setTab('all'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppShapes.spaceMd),

          // ─── Content ───
          Expanded(
            child: tripsState.isEmpty
                ? _buildEmpty(context, ref)
                : filtered.isEmpty
                ? _buildNoResults(context)
                : RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surfaceContainer,
                    onRefresh: () async {
                      await ref.read(tripsProvider.notifier).syncNow();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppShapes.screenPadding,
                        0,
                        AppShapes.screenPadding,
                        120,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return TapScale(
                              onTap: () => _openTripDetail(
                                context,
                                ref,
                                filtered[index],
                              ),
                              child: TripCard(
                                trip: filtered[index],
                                onTap: () => _openTripDetail(
                                  context,
                                  ref,
                                  filtered[index],
                                ),
                                onDelete: () =>
                                    _deleteTrip(context, ref, filtered[index]),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (index * 80).ms)
                            .slideY(begin: 0.05, end: 0);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🧳', style: TextStyle(fontSize: 72)),
          const SizedBox(height: AppShapes.spaceLg),
          Text(
            'No trips yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppShapes.spaceSm),
          Text(
            'Start planning your next adventure\nwith our AI assistant',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppShapes.spaceLg),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => _showCreateTrip(context, ref),
              child: const Text('Create Trip ✨'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📭', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppShapes.spaceMd),
          Text(
            'No trips in this category',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  void _showCreateTrip(BuildContext context, WidgetRef ref) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CreateTripSheet(),
    );
  }

  void _openTripDetail(BuildContext context, WidgetRef ref, Trip trip) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)));
  }

  void _deleteTrip(BuildContext context, WidgetRef ref, Trip trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text('Delete trip?'),
        content: Text('Remove "${trip.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tripsProvider.notifier).deleteTrip(trip.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: AppShapes.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppShapes.spaceMd),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppShapes.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
