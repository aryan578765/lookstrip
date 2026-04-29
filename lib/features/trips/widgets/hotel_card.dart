import 'package:flutter/material.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/hotel_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HotelCardWidget extends StatelessWidget {
  final Hotel hotel;
  const HotelCardWidget({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppShapes.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppShapes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel image
          if (hotel.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppShapes.radiusLg),
              ),
              child: CachedNetworkImage(
                imageUrl: hotel.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  height: 140,
                  color: AppColors.surfaceContainerHigh,
                  child: const Center(
                    child: Text('🏨', style: TextStyle(fontSize: 32)),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  height: 140,
                  color: AppColors.surfaceContainerHigh,
                  child: const Center(
                    child: Text('🏨', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppShapes.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + type
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hotel.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppShapes.spaceSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppShapes.radiusFull,
                        ),
                      ),
                      child: Text(
                        hotel.priceLabel,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppShapes.spaceXs),

                // Rating + reviews
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hotel.ratingLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hotel.reviews > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${hotel.reviews} reviews)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ],
                ),

                if (hotel.address.isNotEmpty) ...[
                  const SizedBox(height: AppShapes.spaceXs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.onSurfaceMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.address,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Amenities
                if (hotel.amenities.isNotEmpty) ...[
                  const SizedBox(height: AppShapes.spaceSm),
                  Wrap(
                    spacing: AppShapes.spaceXs,
                    runSpacing: AppShapes.spaceXs,
                    children: hotel.amenities
                        .take(4)
                        .map(
                          (a) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(
                                AppShapes.radiusFull,
                              ),
                            ),
                            child: Text(
                              a,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
