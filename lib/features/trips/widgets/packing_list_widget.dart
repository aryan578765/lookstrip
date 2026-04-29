import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/packing_model.dart';
import 'package:lookstrip/core/models/trip_model.dart';
import 'package:lookstrip/core/services/packing_service.dart';

/// Packing provider state
class PackingState {
  final List<PackingItem> items;
  final bool isLoading;
  final bool isGenerating;

  const PackingState({
    this.items = const [],
    this.isLoading = false,
    this.isGenerating = false,
  });

  int get totalItems => items.length;
  int get packedItems => items.where((i) => i.isPacked).count;
  double get progress => totalItems == 0 ? 0 : packedItems / totalItems;

  PackingState copyWith({
    List<PackingItem>? items,
    bool? isLoading,
    bool? isGenerating,
  }) {
    return PackingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

/// Packing notifier
class PackingNotifier extends StateNotifier<PackingState> {
  final String tripId;
  final Trip trip;
  final PackingService _service = PackingService();

  PackingNotifier(this.tripId, this.trip) : super(const PackingState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _service.getItems(tripId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleItem(String itemId, bool isPacked) async {
    // Optimistic update
    final updated = state.items.map((i) {
      if (i.id == itemId) return i.copyWith(isPacked: isPacked);
      return i;
    }).toList();
    state = state.copyWith(items: updated);

    await _service.toggleItem(itemId, isPacked);
  }

  Future<void> addItem(String name, String category) async {
    final item = await _service.addItem(tripId, name, category);
    state = state.copyWith(items: [...state.items, item]);
  }

  Future<void> deleteItem(String itemId) async {
    state = state.copyWith(
      items: state.items.where((i) => i.id != itemId).toList(),
    );
    await _service.deleteItem(itemId);
  }

  Future<void> generateWithAI() async {
    state = state.copyWith(isGenerating: true);
    try {
      final items = await _service.generatePackingList(trip);
      state = state.copyWith(items: items, isGenerating: false);
    } catch (_) {
      state = state.copyWith(isGenerating: false);
    }
  }
}

/// Riverpod family provider
final packingProvider =
    StateNotifierProvider.family<PackingNotifier, PackingState, Trip>(
      (ref, trip) => PackingNotifier(trip.id, trip),
    );

// ─── Extension for count ───
extension _IterableCount<T> on Iterable<T> {
  int get count => length;
}

/// Packing list tab widget
class PackingListWidget extends ConsumerStatefulWidget {
  final Trip trip;
  const PackingListWidget({super.key, required this.trip});

  @override
  ConsumerState<PackingListWidget> createState() => _PackingListWidgetState();
}

class _PackingListWidgetState extends ConsumerState<PackingListWidget> {
  final _addController = TextEditingController();
  final String _addCategory = 'general';

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packState = ref.watch(packingProvider(widget.trip));
    final notifier = ref.read(packingProvider(widget.trip).notifier);

    if (packState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (packState.items.isEmpty && !packState.isGenerating) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppShapes.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📦', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppShapes.spaceMd),
              Text(
                'No packing list yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppShapes.spaceXs),
              Text(
                'Generate a smart packing list using AI based on your destination and trip duration.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppShapes.spaceLg),
              SizedBox(
                width: double.infinity,
                height: AppShapes.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => notifier.generateWithAI(),
                  child: const Text('Generate with AI ✨'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (packState.isGenerating) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppShapes.spaceMd),
            Text('AI is generating your packing list...'),
          ],
        ),
      );
    }

    // Group items by category
    final grouped = <String, List<PackingItem>>{};
    for (final item in packState.items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(AppShapes.screenPadding),
      children: [
        // Progress bar
        Container(
          padding: const EdgeInsets.all(AppShapes.spaceMd),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${packState.packedItems} of ${packState.totalItems} packed',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    '${(packState.progress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppShapes.spaceSm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppShapes.radiusFull),
                child: LinearProgressIndicator(
                  value: packState.progress,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    packState.progress >= 1.0
                        ? Colors.green
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppShapes.spaceMd),

        // Add custom item
        Container(
          padding: const EdgeInsets.all(AppShapes.spaceSm),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppShapes.radiusMd),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addController,
                  decoration: const InputDecoration(
                    hintText: 'Add custom item...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppShapes.spaceSm,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final name = _addController.text.trim();
                  if (name.isEmpty) return;
                  notifier.addItem(name, _addCategory);
                  _addController.clear();
                },
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppShapes.spaceLg),

        // Categories
        ...grouped.entries.map((entry) {
          final catEmoji = PackingItem.emojiFor(entry.key);
          final catLabel = PackingItem.labelFor(entry.key);
          final items = entry.value;
          final packedCount = items.where((i) => i.isPacked).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(catEmoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: AppShapes.spaceXs),
                  Text(catLabel, style: Theme.of(context).textTheme.labelLarge),
                  const Spacer(),
                  Text(
                    '$packedCount/${items.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppShapes.spaceXs),
              ...items.map(
                (item) => Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red.withValues(alpha: 0.2),
                    child: const Icon(Icons.delete_rounded, color: Colors.red),
                  ),
                  onDismissed: (_) => notifier.deleteItem(item.id),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: item.isPacked,
                      onChanged: (v) =>
                          notifier.toggleItem(item.id, v ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Text(
                      item.itemName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: item.isPacked
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isPacked
                            ? AppColors.onSurfaceMuted
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppShapes.spaceMd),
            ],
          );
        }),
      ],
    );
  }
}
