import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/place_models.dart';

/// Card for restaurants from SerpApi
class RestaurantCardWidget extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantCardWidget({super.key, required this.restaurant});

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
          // Image or emoji
          ClipRRect(
            borderRadius: BorderRadius.circular(AppShapes.radiusSm),
            child: restaurant.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: restaurant.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _placeholder('🍽️'),
                    errorWidget: (_, _, _) => _placeholder('🍽️'),
                  )
                : _placeholder('🍽️'),
          ),
          const SizedBox(width: AppShapes.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (restaurant.rating > 0) ...[
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (restaurant.reviews > 0)
                        Text(
                          ' (${restaurant.reviews})',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceMuted),
                        ),
                      const SizedBox(width: AppShapes.spaceSm),
                    ],
                    if (restaurant.cuisine.isNotEmpty)
                      Expanded(
                        child: Text(
                          restaurant.cuisine,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                if (restaurant.address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      restaurant.address,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (restaurant.priceLevel.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppShapes.radiusFull),
              ),
              child: Text(
                restaurant.priceLevel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _placeholder(String emoji) {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.surfaceContainerHigh,
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
    );
  }
}

/// Card for attractions/things to do from SerpApi
class AttractionCardWidget extends StatelessWidget {
  final Attraction attraction;
  const AttractionCardWidget({super.key, required this.attraction});

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
          ClipRRect(
            borderRadius: BorderRadius.circular(AppShapes.radiusSm),
            child: attraction.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: attraction.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _placeholder('🏛️'),
                    errorWidget: (_, _, _) => _placeholder('🏛️'),
                  )
                : _placeholder('🏛️'),
          ),
          const SizedBox(width: AppShapes.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attraction.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (attraction.rating > 0) ...[
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        attraction.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (attraction.reviews > 0)
                        Text(
                          ' (${attraction.reviews})',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceMuted),
                        ),
                      const SizedBox(width: AppShapes.spaceSm),
                    ],
                    if (attraction.type.isNotEmpty)
                      Expanded(
                        child: Text(
                          attraction.type,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                if (attraction.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      attraction.description,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
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
    );
  }

  static Widget _placeholder(String emoji) {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.surfaceContainerHigh,
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
    );
  }
}
