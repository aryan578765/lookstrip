import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/destination_model.dart';
import 'package:lookstrip/core/widgets/tap_scale.dart';
import 'package:lookstrip/features/explore/widgets/destination_card.dart';
import 'package:lookstrip/features/explore/widgets/destination_detail_sheet.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'All';
  String _selectedContinent = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  List<Destination> get _filteredDestinations {
    return DestinationData.filter(
      category: _selectedCategory,
      continent: _selectedContinent,
      searchQuery: _searchQuery,
    );
  }

  void _openDetail(Destination dest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DestinationDetailSheet(destination: dest),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredDestinations;

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
              children: [
                Expanded(
                  child: Text(
                    'Explore',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 28,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                // Continent filter
                GestureDetector(
                  onTap: () => _showContinentPicker(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppShapes.spaceMd,
                      vertical: AppShapes.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedContinent != 'All'
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppShapes.radiusFull),
                      border: Border.all(
                        color: _selectedContinent != 'All'
                            ? AppColors.primary
                            : AppColors.outline,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.public_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedContinent == 'All'
                              ? 'Region'
                              : _selectedContinent.replaceAll(
                                  RegExp(r'^[^\w]+\s*'),
                                  '',
                                ),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: _selectedContinent != 'All'
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Search Bar ───
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppShapes.screenPadding,
            ),
            child: Container(
              height: AppShapes.searchBarHeight,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppShapes.radiusFull),
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
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search destinations...',
                        hintStyle: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: AppColors.onSurfaceMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) => setState(() {
                        _searchQuery = v;
                        _isSearching = v.isNotEmpty;
                      }),
                    ),
                  ),
                  if (_isSearching)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(AppShapes.spaceSm),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.onSurfaceMuted,
                          size: 20,
                        ),
                      ),
                    ),
                  const SizedBox(width: AppShapes.spaceSm),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppShapes.spaceMd),

          // ─── Category Chips ───
          SizedBox(
            height: AppShapes.chipHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppShapes.screenPadding,
              ),
              itemCount: DestinationData.allCategories.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppShapes.spaceSm),
              itemBuilder: (context, index) {
                final cat = DestinationData.allCategories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppShapes.spaceMd,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppShapes.radiusFull),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outline,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppShapes.spaceMd),

          // ─── Results count ───
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppShapes.screenPadding,
            ),
            child: Text(
              '${results.length} destination${results.length != 1 ? 's' : ''} found',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
            ),
          ),

          const SizedBox(height: AppShapes.spaceSm),

          // ─── Destination Grid ───
          Expanded(
            child: results.isEmpty
                ? _buildEmpty(context)
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppShapes.screenPadding,
                      0,
                      AppShapes.screenPadding,
                      120,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppShapes.spaceMd,
                          crossAxisSpacing: AppShapes.spaceMd,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return TapScale(
                            onTap: () => _openDetail(results[index]),
                            child: DestinationCard(
                              destination: results[index],
                              onTap: () => _openDetail(results[index]),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: (index * 60).ms)
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1, 1),
                            duration: 400.ms,
                            delay: (index * 60).ms,
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppShapes.spaceMd),
          Text(
            'No destinations found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppShapes.spaceXs),
          Text(
            'Try a different search or category',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showContinentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.radiusLg),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppShapes.spaceMd),
                child: Text(
                  'Select Region',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const Divider(height: 1),
              ...DestinationData.continents.map((c) {
                final isSelected = _selectedContinent == c;
                return ListTile(
                  title: Text(c),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedContinent = c);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: AppShapes.spaceMd),
            ],
          ),
        );
      },
    );
  }
}
