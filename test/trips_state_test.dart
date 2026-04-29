import 'package:flutter_test/flutter_test.dart';
import 'package:lookstrip/core/models/trip_model.dart';
import 'package:lookstrip/core/providers/trips_provider.dart';

void main() {
  test('TripsState treats status=past as past even when dates overlap', () {
    final now = DateTime.now();
    final trip = Trip(
      id: 'trip-1',
      title: 'Local test trip',
      destination: 'Paris',
      emoji: '',
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 1)),
      status: 'past',
      days: 3,
      itinerary: const [],
      createdAt: now,
    );

    final upcoming = TripsState(trips: [trip]);
    final past = TripsState(trips: [trip], activeTab: 'past');

    expect(upcoming.filteredTrips, isEmpty);
    expect(past.filteredTrips, hasLength(1));
  });
}
