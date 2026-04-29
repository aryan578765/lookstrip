import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/trip_model.dart';
import 'package:lookstrip/core/providers/trip_detail_provider.dart';
import 'package:lookstrip/features/trips/widgets/flight_card.dart';
import 'package:lookstrip/features/trips/widgets/hotel_card.dart';
import 'package:lookstrip/features/trips/widgets/weather_card.dart';
import 'package:lookstrip/features/trips/widgets/budget_section.dart';
import 'package:lookstrip/features/trips/widgets/places_card.dart';
import 'package:lookstrip/features/trips/widgets/packing_list_widget.dart';
import 'package:lookstrip/features/trips/widgets/share_trip_sheet.dart';
import 'package:lookstrip/core/widgets/destination_map.dart';
import 'package:lookstrip/core/widgets/shimmer_card.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    // Kick off data loading
    Future.microtask(() {
      ref.read(tripDetailProvider(widget.trip).notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(tripDetailProvider(widget.trip));
    final trip = widget.trip;
    final dateRange =
        '${DateFormat('MMM d').format(trip.startDate)} – ${DateFormat('MMM d, yyyy').format(trip.endDate)}';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ─── Hero Header ───
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.surfaceContainer,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.onSurface,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    color: AppColors.onSurface,
                    size: 20,
                  ),
                ),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) =>
                      ShareTripSheet(tripId: trip.id, tripTitle: trip.title),
                ),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.surfaceContainer,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(trip.emoji, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: AppShapes.spaceSm),
                      Text(
                        trip.destination,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 28,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppShapes.spaceXs),
                      Text(
                        '$dateRange • ${trip.days} days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceMuted,
              dividerColor: AppColors.outline,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: '📋 Itinerary'),
                Tab(text: '✈️ Flights'),
                Tab(text: '🏨 Hotels'),
                Tab(text: '📍 Places'),
                Tab(text: '🌤️ Weather'),
                Tab(text: '💰 Budget'),
                Tab(text: '📦 Packing'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ItineraryTab(trip: trip),
            _FlightsTab(data: data, trip: trip),
            _HotelsTab(data: data, trip: trip),
            _PlacesTab(data: data, trip: trip),
            _WeatherTab(data: data, trip: trip),
            BudgetSection(data: data, trip: trip),
            PackingListWidget(trip: trip),
          ],
        ),
      ),
    );
  }
}

// ─── Itinerary Tab ───
class _ItineraryTab extends StatelessWidget {
  final Trip trip;
  const _ItineraryTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    if (trip.itinerary.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppShapes.spaceMd),
            Text(
              'No itinerary yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppShapes.screenPadding),
      itemCount: trip.itinerary.length + 1, // +1 for map
      itemBuilder: (context, index) {
        // First item is the map
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppShapes.spaceMd),
            child: DestinationMapWidget(
              destinationName: trip.destination,
              height: 180,
              zoom: 11,
            ),
          );
        }
        final day = trip.itinerary[index - 1];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Container(
              margin: const EdgeInsets.only(
                bottom: AppShapes.spaceSm,
                top: AppShapes.spaceMd,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppShapes.spaceMd,
                vertical: AppShapes.spaceXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppShapes.radiusFull),
              ),
              child: Text(
                'Day ${day.dayNumber} — ${day.title}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Activities
            ...day.activities.map(
              (activity) => Container(
                margin: const EdgeInsets.only(bottom: AppShapes.spaceSm),
                padding: const EdgeInsets.all(AppShapes.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppShapes.radiusSm),
                      ),
                      child: Center(
                        child: Text(
                          activity.time.isNotEmpty
                              ? activity.time.split(':').first
                              : '•',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppShapes.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (activity.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                activity.description,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Flights Tab ───
class _FlightsTab extends ConsumerWidget {
  final TripDetailData data;
  final Trip trip;
  const _FlightsTab({required this.data, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isLoadingFlights) {
      return ShimmerList(count: 3, builder: () => const ShimmerFlightCard());
    }

    if (data.flights.isEmpty && data.flightError != null) {
      return _RetryState(
        icon: Icons.flight_takeoff_rounded,
        title: 'Flight search unavailable',
        message: data.flightError!,
        onRetry: () =>
            ref.read(tripDetailProvider(trip).notifier).loadFlights(),
      );
    }

    if (data.flights.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppShapes.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✈️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppShapes.spaceMd),
              Text(
                'No flights found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppShapes.spaceXs),
              Text(
                'Flight search uses SerpApi.\nMake sure your API key is valid.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppShapes.screenPadding),
      itemCount: data.flights.length,
      itemBuilder: (context, index) =>
          FlightCardWidget(flight: data.flights[index]),
    );
  }
}

// ─── Hotels Tab ───
class _HotelsTab extends ConsumerWidget {
  final TripDetailData data;
  final Trip trip;
  const _HotelsTab({required this.data, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isLoadingHotels) {
      return ShimmerList(count: 3, builder: () => const ShimmerHotelCard());
    }

    if (data.hotels.isEmpty && data.hotelError != null) {
      return _RetryState(
        icon: Icons.hotel_rounded,
        title: 'Hotel search unavailable',
        message: data.hotelError!,
        onRetry: () => ref.read(tripDetailProvider(trip).notifier).loadHotels(),
      );
    }

    if (data.hotels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppShapes.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppShapes.spaceMd),
              Text(
                'No hotels found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppShapes.spaceXs),
              Text(
                'Hotel search uses SerpApi.\nResults will appear when available.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppShapes.screenPadding),
      itemCount: data.hotels.length,
      itemBuilder: (context, index) =>
          HotelCardWidget(hotel: data.hotels[index]),
    );
  }
}

// ─── Weather Tab ───
class _WeatherTab extends ConsumerWidget {
  final TripDetailData data;
  final Trip trip;
  const _WeatherTab({required this.data, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isLoadingWeather) {
      return ShimmerList(count: 5, builder: () => const ShimmerWeatherCard());
    }

    if (data.weather.isEmpty && data.weatherError != null) {
      return _RetryState(
        icon: Icons.cloud_queue_rounded,
        title: 'Weather unavailable',
        message: data.weatherError!,
        onRetry: () =>
            ref.read(tripDetailProvider(trip).notifier).loadWeather(),
      );
    }

    if (data.weather.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌤️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppShapes.spaceMd),
            Text(
              'Weather data unavailable',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppShapes.spaceXs),
            Text(
              'We couldn\'t find coordinates for this destination',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppShapes.screenPadding),
      itemCount: data.weather.length,
      itemBuilder: (context, index) =>
          WeatherCardWidget(day: data.weather[index]),
    );
  }
}

// ─── Places Tab (Restaurants + Attractions) ───
class _PlacesTab extends ConsumerWidget {
  final TripDetailData data;
  final Trip trip;
  const _PlacesTab({required this.data, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = data.isLoadingRestaurants || data.isLoadingAttractions;
    if (isLoading && data.restaurants.isEmpty && data.attractions.isEmpty) {
      return ShimmerList(count: 4, builder: () => const ShimmerPlacesCard());
    }

    if (data.restaurants.isEmpty &&
        data.attractions.isEmpty &&
        data.placesError != null) {
      return _RetryState(
        icon: Icons.place_rounded,
        title: 'Places unavailable',
        message: data.placesError!,
        onRetry: () {
          final notifier = ref.read(tripDetailProvider(trip).notifier);
          notifier.loadRestaurants();
          notifier.loadAttractions();
        },
      );
    }

    if (data.restaurants.isEmpty && data.attractions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppShapes.spaceMd),
            Text(
              'No places found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppShapes.spaceXs),
            Text(
              'Places search uses SerpApi.\nResults will appear when available.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppShapes.screenPadding),
      children: [
        // Restaurants section
        if (data.restaurants.isNotEmpty) ...[
          Row(
            children: [
              const Text('🍽️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppShapes.spaceXs),
              Text(
                'Restaurants',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(width: AppShapes.spaceXs),
              Text(
                '(${data.restaurants.length})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppShapes.spaceSm),
          ...data.restaurants.map((r) => RestaurantCardWidget(restaurant: r)),
          const SizedBox(height: AppShapes.spaceLg),
        ],

        // Attractions section
        if (data.attractions.isNotEmpty) ...[
          Row(
            children: [
              const Text('🏛️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppShapes.spaceXs),
              Text(
                'Things to Do',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(width: AppShapes.spaceXs),
              Text(
                '(${data.attractions.length})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppShapes.spaceSm),
          ...data.attractions.map((a) => AttractionCardWidget(attraction: a)),
        ],

        const SizedBox(height: AppShapes.spaceLg),
      ],
    );
  }
}

class _RetryState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _RetryState({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppShapes.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.onSurfaceMuted),
            const SizedBox(height: AppShapes.spaceMd),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppShapes.spaceXs),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppShapes.spaceMd),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
