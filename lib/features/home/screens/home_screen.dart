import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/providers/auth_provider.dart';
import 'package:lookstrip/core/providers/trips_provider.dart';
import 'package:lookstrip/core/providers/trip_detail_provider.dart';
import 'package:lookstrip/core/providers/connectivity_provider.dart';
import 'package:lookstrip/core/models/destination_model.dart';
import 'package:lookstrip/core/widgets/tap_scale.dart';
import 'package:lookstrip/features/explore/widgets/destination_detail_sheet.dart';
import 'package:lookstrip/features/trips/screens/trip_detail_screen.dart';
import 'package:lookstrip/features/shell/main_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final tripsState = ref.watch(tripsProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final userName = (user?.name.isNotEmpty == true) ? user!.name : 'Traveler';
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final upcomingTrips = tripsState.trips
        .where((t) => t.status != 'past' && !t.endDate.isBefore(startOfToday))
        .toList();

    // Get top-rated destinations for trending
    final trending = List.of(DestinationData.destinations)
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceContainer,
        onRefresh: () async {
          await ref.read(tripsProvider.notifier).syncNow();
        },
        child: CustomScrollView(
          slivers: [
            // ─── Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppShapes.screenPadding,
                  AppShapes.spaceLg,
                  AppShapes.screenPadding,
                  AppShapes.spaceMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppShapes.spaceXs),
                        Text(
                          userName,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 28,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Cloud sync status
                        if (tripsState.isSyncing)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              isOnline
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_off_rounded,
                              size: 18,
                              color: isOnline
                                  ? AppColors.success.withValues(alpha: 0.6)
                                  : AppColors.onSurfaceMuted,
                            ),
                          ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'T',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
            ),

            // ─── Search Bar ───
            SliverToBoxAdapter(
              child:
                  Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppShapes.screenPadding,
                          vertical: AppShapes.spaceSm,
                        ),
                        child: TapScale(
                          onTap: () => _switchToTab(context, 1),
                          child: Container(
                            height: AppShapes.searchBarHeight,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(
                                AppShapes.radiusFull,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: AppShapes.spaceMd),
                                Icon(
                                  Icons.search_rounded,
                                  color: AppColors.onSurfaceMuted,
                                  size: 22,
                                ),
                                const SizedBox(width: AppShapes.spaceSm),
                                Text(
                                  'Where to next?',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppColors.onSurfaceMuted,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.05, end: 0),
            ),

            // ─── Upcoming Trip Card ───
            if (upcomingTrips.isNotEmpty)
              SliverToBoxAdapter(
                child:
                    Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppShapes.screenPadding,
                            vertical: AppShapes.spaceMd,
                          ),
                          child: TapScale(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TripDetailScreen(
                                    trip: upcomingTrips.first,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppShapes.spaceMd),
                              decoration: BoxDecoration(
                                gradient: AppColors.amberGlow,
                                borderRadius: BorderRadius.circular(
                                  AppShapes.radiusLg,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    upcomingTrips.first.emoji,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                  const SizedBox(width: AppShapes.spaceMd),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Upcoming Trip',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppColors.onPrimary
                                                    .withValues(alpha: 0.8),
                                              ),
                                        ),
                                        Text(
                                          upcomingTrips.first.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: AppColors.onPrimary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          upcomingTrips.first.startDate.isAfter(
                                                startOfToday,
                                              )
                                              ? 'In ${upcomingTrips.first.startDate.difference(startOfToday).inDays} days'
                                              : 'Happening now',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.onPrimary
                                                    .withValues(alpha: 0.8),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: AppColors.onPrimary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .slideX(begin: 0.05, end: 0),
              ),

            // ─── Weather & Flights Preview ───
            if (upcomingTrips.isNotEmpty)
              SliverToBoxAdapter(
                child: _TripPreviewCard(
                  trip: upcomingTrips.first,
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              ),

            // ─── AI Card (if no upcoming trips) ───
            if (upcomingTrips.isEmpty)
              SliverToBoxAdapter(
                child:
                    Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppShapes.screenPadding,
                            vertical: AppShapes.spaceMd,
                          ),
                          child: TapScale(
                            onTap: () => _switchToTab(context, 2),
                            child: Container(
                              padding: const EdgeInsets.all(AppShapes.spaceMd),
                              decoration: BoxDecoration(
                                gradient: AppColors.amberGlow,
                                borderRadius: BorderRadius.circular(
                                  AppShapes.radiusLg,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '✨',
                                    style: TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(width: AppShapes.spaceMd),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Plan with AI',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: AppColors.onPrimary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: AppShapes.spaceXs,
                                        ),
                                        Text(
                                          'Chat with our AI to plan your perfect trip',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.onPrimary
                                                    .withValues(alpha: 0.8),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: AppColors.onPrimary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .slideX(begin: 0.05, end: 0),
              ),

            // ─── Section: Trending ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppShapes.screenPadding,
                  AppShapes.spaceSm,
                  AppShapes.screenPadding,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trending Destinations',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    GestureDetector(
                      onTap: () => _switchToTab(context, 1),
                      child: Text(
                        'See all',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppShapes.spaceMd),
            ),

            // ─── Destination Cards ───
            SliverToBoxAdapter(
              child: SizedBox(
                height: AppShapes.destinationCardHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppShapes.screenPadding,
                  ),
                  itemCount: trending.length > 8 ? 8 : trending.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppShapes.spaceMd),
                  itemBuilder: (context, index) {
                    final dest = trending[index];
                    return TapScale(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (_) =>
                                  DestinationDetailSheet(destination: dest),
                            );
                          },
                          child: _DestinationCard(
                            name: dest.name,
                            country: dest.country,
                            emoji: dest.emoji,
                            rating: dest.rating,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (400 + index * 80).ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppShapes.spaceLg),
            ),

            // ─── Quick Actions ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppShapes.screenPadding,
                ),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppShapes.spaceMd),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: AppShapes.chipHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppShapes.screenPadding,
                  ),
                  children: [
                    _QuickActionChip(
                      label: '✈️  Flights',
                      onTap: () => _switchToTab(context, 2),
                    ),
                    const SizedBox(width: AppShapes.spaceSm),
                    _QuickActionChip(
                      label: '🏨  Hotels',
                      onTap: () => _switchToTab(context, 2),
                    ),
                    const SizedBox(width: AppShapes.spaceSm),
                    _QuickActionChip(
                      label: '🍽️  Food',
                      onTap: () => _switchToTab(context, 1),
                    ),
                    const SizedBox(width: AppShapes.spaceSm),
                    _QuickActionChip(
                      label: '🗺️  Explore',
                      onTap: () => _switchToTab(context, 1),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 550.ms),
            ),

            // ─── Your Trip Stats ───
            if (tripsState.trips.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: SizedBox(height: AppShapes.spaceLg),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppShapes.screenPadding,
                  ),
                  child: Text(
                    'Your Travel Stats',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppShapes.spaceMd),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppShapes.screenPadding,
                  ),
                  child: Row(
                    children: [
                      _StatCard(
                        emoji: '🧳',
                        value: '${tripsState.trips.length}',
                        label: 'Total Trips',
                      ),
                      const SizedBox(width: AppShapes.spaceMd),
                      _StatCard(
                        emoji: '📅',
                        value:
                            '${tripsState.trips.fold<int>(0, (sum, t) => sum + t.days)}',
                        label: 'Days Planned',
                      ),
                      const SizedBox(width: AppShapes.spaceMd),
                      _StatCard(
                        emoji: '🌍',
                        value:
                            '${tripsState.trips.map((t) => t.destination).toSet().length}',
                        label: 'Destinations',
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 650.ms).slideY(begin: 0.05, end: 0),
              ),
            ],

            // Bottom padding for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  /// Navigate to a specific tab in MainShell
  void _switchToTab(BuildContext context, int index) {
    TabSwitcher.of(context)?.switchTo(index);
  }
}

// ─── Destination Card Widget ───
class _DestinationCard extends StatelessWidget {
  final String name;
  final String country;
  final String emoji;
  final double rating;

  const _DestinationCard({
    required this.name,
    required this.country,
    required this.emoji,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppShapes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Container(
            height: 130,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppShapes.radiusLg),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 48)),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(AppShapes.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 10,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppShapes.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppShapes.spaceXs),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      country,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Chip ───
class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        height: AppShapes.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppShapes.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppShapes.radiusFull),
          border: Border.all(color: AppColors.outline, width: 1),
        ),
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
      ),
    );
  }
}

// ─── Stat Card ───
class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppShapes.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.radiusMd),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: AppShapes.spaceXs),
            Text(
              value,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 24,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Live weather + flight preview for upcoming trip on home screen
class _TripPreviewCard extends ConsumerStatefulWidget {
  final dynamic trip;
  const _TripPreviewCard({required this.trip});

  @override
  ConsumerState<_TripPreviewCard> createState() => _TripPreviewCardState();
}

class _TripPreviewCardState extends ConsumerState<_TripPreviewCard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(tripDetailProvider(widget.trip).notifier);
      notifier.loadWeather();
      notifier.loadFlights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(tripDetailProvider(widget.trip));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppShapes.screenPadding),
      child: Row(
        children: [
          // Weather card
          Expanded(
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(AppShapes.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppShapes.radiusMd),
              ),
              child: data.isLoadingWeather
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : data.weather.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.weather.first.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.weather.first.tempMax.round()}° / ${data.weather.first.tempMin.round()}°',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Weather now',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceMuted),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🌤️', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                          'Weather',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceMuted),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: AppShapes.spaceSm),
          // Flight price card
          Expanded(
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(AppShapes.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppShapes.radiusMd),
              ),
              child: data.isLoadingFlights
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : data.flights.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('✈️', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                          'From \$${data.flights.map((f) => f.price).reduce((a, b) => a < b ? a : b).toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                        ),
                        Text(
                          '${data.flights.length} flights',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceMuted),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('✈️', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                          'Flights',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceMuted),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: AppShapes.spaceSm),
          // Budget estimate
          Expanded(
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(AppShapes.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppShapes.radiusMd),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    data.avgFlightPrice > 0
                        ? '\$${(data.avgFlightPrice + data.avgHotelPerNight * (widget.trip.days ?? 3)).toStringAsFixed(0)}'
                        : '—',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: data.avgFlightPrice > 0
                          ? AppColors.primary
                          : AppColors.onSurfaceMuted,
                    ),
                  ),
                  Text(
                    'Est. budget',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
