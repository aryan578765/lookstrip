import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/trip_model.dart';
import 'package:lookstrip/core/models/expense_model.dart';
import 'package:lookstrip/core/providers/trip_detail_provider.dart';
import 'package:lookstrip/core/providers/expense_provider.dart';
import 'package:lookstrip/features/trips/widgets/add_expense_sheet.dart';

String _formatMoney(double amount, String currency) {
  if (currency == 'USD') return '\$${amount.toStringAsFixed(0)}';
  return '${amount.toStringAsFixed(0)} $currency';
}

/// Budget breakdown section for trip detail
class BudgetSection extends ConsumerWidget {
  final TripDetailData data;
  final Trip trip;

  const BudgetSection({super.key, required this.data, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expState = ref.watch(expenseProvider(trip.id));
    final actualSpent = expState.total;
    final budgetProfile = _BudgetProfile.forDestination(trip.destination);
    final avgFlight = data.avgFlightPrice > 0
        ? data.avgFlightPrice
        : budgetProfile.flightFallback;
    final avgHotel = data.avgHotelPerNight > 0
        ? data.avgHotelPerNight
        : budgetProfile.hotelPerNight;
    final totalHotel = avgHotel * trip.days;
    final dailyFood = budgetProfile.foodPerDay;
    final dailyTransport = budgetProfile.transportPerDay;
    final dailyActivities = budgetProfile.activitiesPerDay;
    final totalFood = dailyFood * trip.days;
    final totalTransport = dailyTransport * trip.days;
    final totalActivities = dailyActivities * trip.days;
    final totalEstimate =
        avgFlight + totalHotel + totalFood + totalTransport + totalActivities;

    final localCurrency = data.localCurrency;
    final rate = data.exchangeRate;
    final displayEstimate = localCurrency != 'USD' && rate != null
        ? totalEstimate * rate
        : totalEstimate;
    final remaining = displayEstimate - actualSpent;
    final isOverBudget = remaining < 0;

    return ListView(
      padding: const EdgeInsets.all(AppShapes.screenPadding),
      children: [
        // Total estimate
        Container(
          padding: const EdgeInsets.all(AppShapes.spaceLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.primaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(AppShapes.radiusLg),
          ),
          child: Column(
            children: [
              Text(
                'Estimated Total',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppShapes.spaceXs),
              Text(
                totalEstimate > 0
                    ? _formatMoney(displayEstimate, localCurrency)
                    : 'Calculating...',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (rate != null && localCurrency != 'USD')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '≈ ${(totalEstimate * rate).toStringAsFixed(0)} $localCurrency',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: AppShapes.spaceSm),
              Text(
                '${trip.days} days in ${trip.destination}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),

        // Actual spending section
        if (actualSpent > 0) ...[
          const SizedBox(height: AppShapes.spaceMd),
          Container(
            padding: const EdgeInsets.all(AppShapes.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppShapes.radiusMd),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actually Spent',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      _formatMoney(actualSpent, localCurrency),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: isOverBudget ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isOverBudget ? 'Over by' : 'Remaining',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      _formatMoney(remaining.abs(), localCurrency),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: !isOverBudget ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppShapes.spaceLg),

        // Breakdown
        Text(
          'Cost Breakdown',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppShapes.spaceMd),

        _BudgetRow(
          icon: '✈️',
          label: 'Flights (avg)',
          amount: avgFlight,
          subtitle: data.avgFlightPrice > 0
              ? '${data.flights.length} options found'
              : 'Destination-based estimate',
          color: const Color(0xFF3B82F6),
        ),
        _BudgetRow(
          icon: '🏨',
          label: 'Hotels (${trip.days} nights)',
          amount: totalHotel,
          subtitle: data.avgHotelPerNight > 0
              ? '\$${avgHotel.toStringAsFixed(0)}/night avg'
              : '\$${avgHotel.toStringAsFixed(0)}/night estimate',
          color: const Color(0xFF8B5CF6),
        ),
        _BudgetRow(
          icon: '🍽️',
          label: 'Food & Dining',
          amount: totalFood,
          subtitle: '\$${dailyFood.toStringAsFixed(0)}/day estimated',
          color: const Color(0xFFF59E0B),
        ),
        _BudgetRow(
          icon: '🚕',
          label: 'Transport',
          amount: totalTransport,
          subtitle: '\$${dailyTransport.toStringAsFixed(0)}/day estimated',
          color: const Color(0xFF10B981),
        ),
        _BudgetRow(
          icon: 'ðŸŽ¡',
          label: 'Activities',
          amount: totalActivities,
          subtitle: '\$${dailyActivities.toStringAsFixed(0)}/day estimated',
          color: const Color(0xFFEC4899),
        ),

        const SizedBox(height: AppShapes.spaceLg),

        // Visual bar chart
        if (totalEstimate > 0) ...[
          Text(
            'Spending Distribution',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppShapes.spaceMd),
          _BarSegment(
            segments: [
              if (avgFlight > 0)
                ('Flights', avgFlight / totalEstimate, const Color(0xFF3B82F6)),
              if (totalHotel > 0)
                ('Hotels', totalHotel / totalEstimate, const Color(0xFF8B5CF6)),
              ('Food', totalFood / totalEstimate, const Color(0xFFF59E0B)),
              (
                'Transport',
                totalTransport / totalEstimate,
                const Color(0xFF10B981),
              ),
              (
                'Activities',
                totalActivities / totalEstimate,
                const Color(0xFFEC4899),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppShapes.spaceLg),

        // Currency info
        if (localCurrency != 'USD') ...[
          Container(
            padding: const EdgeInsets.all(AppShapes.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppShapes.radiusMd),
            ),
            child: Row(
              children: [
                const Text('💱', style: TextStyle(fontSize: 24)),
                const SizedBox(width: AppShapes.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1 USD = ${rate?.toStringAsFixed(2) ?? '...'} $localCurrency',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Live exchange rate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppShapes.spaceLg),

        // Disclaimer
        Text(
          '* Budget estimates are approximate. Live SerpApi prices are used when available; otherwise LooksTrip falls back to destination-specific estimates for lodging, food, transport, and activities.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceMuted,
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: AppShapes.spaceLg),

        // Recent expenses
        if (expState.expenses.isNotEmpty) ...[
          Text(
            'Recent Expenses',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppShapes.spaceMd),
          ...expState.expenses
              .take(5)
              .map(
                (e) => Container(
                  margin: const EdgeInsets.only(bottom: AppShapes.spaceXs),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppShapes.spaceMd,
                    vertical: AppShapes.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppShapes.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Text(
                        Expense.emojiFor(e.category),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: AppShapes.spaceSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.note ?? Expense.labelFor(e.category),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatMoney(e.amount, e.currency),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: AppShapes.spaceMd),
        ],

        // Add expense button
        SizedBox(
          width: double.infinity,
          height: AppShapes.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddExpenseSheet(tripId: trip.id),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Expense 💸'),
          ),
        ),

        const SizedBox(height: AppShapes.spaceLg),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String icon;
  final String label;
  final double amount;
  final String subtitle;
  final Color color;

  const _BudgetRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppShapes.spaceSm),
      padding: const EdgeInsets.all(AppShapes.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppShapes.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppShapes.radiusSm),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: AppShapes.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount > 0 ? '\$${amount.toStringAsFixed(0)}' : '—',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: amount > 0
                  ? AppColors.onSurface
                  : AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarSegment extends StatelessWidget {
  final List<(String, double, Color)> segments;
  const _BarSegment({required this.segments});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppShapes.radiusFull),
          child: SizedBox(
            height: 14,
            child: Row(
              children: segments
                  .map(
                    (s) => Expanded(
                      flex: (s.$2 * 100).round().clamp(1, 100),
                      child: Container(color: s.$3),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: AppShapes.spaceSm),
        // Legend
        Wrap(
          spacing: AppShapes.spaceMd,
          runSpacing: AppShapes.spaceXs,
          children: segments
              .map(
                (s) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.$3,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${s.$1} ${(s.$2 * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _BudgetProfile {
  final double flightFallback;
  final double hotelPerNight;
  final double foodPerDay;
  final double transportPerDay;
  final double activitiesPerDay;

  const _BudgetProfile({
    required this.flightFallback,
    required this.hotelPerNight,
    required this.foodPerDay,
    required this.transportPerDay,
    required this.activitiesPerDay,
  });

  factory _BudgetProfile.forDestination(String destination) {
    final value = destination.toLowerCase();
    if (_containsAny(value, ['india', 'delhi', 'mumbai', 'jaipur', 'goa'])) {
      return const _BudgetProfile(
        flightFallback: 320,
        hotelPerNight: 55,
        foodPerDay: 24,
        transportPerDay: 14,
        activitiesPerDay: 18,
      );
    }
    if (_containsAny(value, ['thailand', 'bali', 'vietnam', 'indonesia'])) {
      return const _BudgetProfile(
        flightFallback: 520,
        hotelPerNight: 75,
        foodPerDay: 32,
        transportPerDay: 18,
        activitiesPerDay: 28,
      );
    }
    if (_containsAny(value, ['paris', 'london', 'rome', 'europe'])) {
      return const _BudgetProfile(
        flightFallback: 780,
        hotelPerNight: 170,
        foodPerDay: 70,
        transportPerDay: 35,
        activitiesPerDay: 45,
      );
    }
    if (_containsAny(value, ['new york', 'los angeles', 'usa', 'canada'])) {
      return const _BudgetProfile(
        flightFallback: 650,
        hotelPerNight: 190,
        foodPerDay: 75,
        transportPerDay: 42,
        activitiesPerDay: 50,
      );
    }
    return const _BudgetProfile(
      flightFallback: 600,
      hotelPerNight: 110,
      foodPerDay: 45,
      transportPerDay: 24,
      activitiesPerDay: 32,
    );
  }

  static bool _containsAny(String value, List<String> tokens) {
    return tokens.any(value.contains);
  }
}
