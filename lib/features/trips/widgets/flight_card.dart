import 'package:flutter/material.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/flight_model.dart';

class FlightCardWidget extends StatelessWidget {
  final Flight flight;
  const FlightCardWidget({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppShapes.spaceMd),
      padding: const EdgeInsets.all(AppShapes.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppShapes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Airline + Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppShapes.radiusSm),
                    ),
                    child: const Center(
                      child: Text('✈️', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: AppShapes.spaceSm),
                  Text(
                    flight.airline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppShapes.radiusFull),
                ),
                child: Text(
                  '\$${flight.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppShapes.spaceMd),

          // Route visualization
          Row(
            children: [
              // Departure
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.departureTime.isNotEmpty
                          ? flight.departureTime
                          : '--:--',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      flight.departureAirport,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Flight line
              Expanded(
                child: Column(
                  children: [
                    Text(
                      flight.duration,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: AppColors.outline),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.flight,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: Container(height: 1, color: AppColors.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flight.stopsLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: flight.stops == 0
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrival
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      flight.arrivalTime.isNotEmpty
                          ? flight.arrivalTime
                          : '--:--',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      flight.arrivalAirport,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
