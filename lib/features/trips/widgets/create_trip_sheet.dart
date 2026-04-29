import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/providers/trips_provider.dart';

/// Bottom sheet for creating a new trip with AI-generated itinerary
class CreateTripSheet extends ConsumerStatefulWidget {
  const CreateTripSheet({super.key});

  @override
  ConsumerState<CreateTripSheet> createState() => _CreateTripSheetState();
}

class _CreateTripSheetState extends ConsumerState<CreateTripSheet> {
  String _selectedDestination = '';
  String _selectedEmoji = '🌍';
  int _selectedDays = 5;
  final _customController = TextEditingController();
  bool _useCustom = false;

  final _destinations = [
    ('Tokyo', '🗼'),
    ('Bali', '🏝️'),
    ('Paris', '🗼'),
    ('Santorini', '🏛️'),
    ('New York', '🗽'),
    ('Maldives', '🏖️'),
    ('Barcelona', '🇪🇸'),
    ('Swiss Alps', '🏔️'),
    ('Cape Town', '🇿🇦'),
    ('Sydney', '🇦🇺'),
    ('Seoul', '🇰🇷'),
    ('Marrakech', '🇲🇦'),
  ];

  String get _finalDestination =>
      _useCustom ? _customController.text.trim() : _selectedDestination;
  bool get _isValid => _finalDestination.isNotEmpty;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripsState = ref.watch(tripsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppShapes.radius2xl),
            ),
          ),
          child: tripsState.isGenerating
              ? _buildGenerating(context, tripsState)
              : _buildForm(context, scrollController),
        );
      },
    );
  }

  Widget _buildGenerating(BuildContext context, TripsState tripsState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppShapes.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppShapes.spaceLg),
            Text(
              '✨ AI is planning your trip',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppShapes.spaceSm),
            Text(
              tripsState.generatingMessage ?? 'Generating itinerary...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppShapes.spaceXs),
            Text(
              'Finding real restaurants, attractions & hidden gems',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppShapes.spaceLg),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(tripsProvider.notifier).cancelGeneration(),
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Cancel generation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: AppShapes.spaceMd),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.onSurfaceMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(AppShapes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a Trip',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 26,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppShapes.spaceXs),
              Text(
                'AI will generate a real day-by-day itinerary',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppShapes.spaceLg),

              // ─── Destination grid ───
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Where to?',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _useCustom = !_useCustom;
                      if (!_useCustom) _customController.clear();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _useCustom
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(
                          AppShapes.radiusFull,
                        ),
                        border: Border.all(
                          color: _useCustom
                              ? AppColors.primary
                              : AppColors.outline,
                        ),
                      ),
                      child: Text(
                        _useCustom ? '📋 Pick from list' : '✏️ Custom',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _useCustom
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppShapes.spaceSm),

              if (_useCustom) ...[
                TextField(
                  controller: _customController,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'Enter any destination...',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ] else ...[
                Wrap(
                  spacing: AppShapes.spaceSm,
                  runSpacing: AppShapes.spaceSm,
                  children: _destinations.map((d) {
                    final isSelected = _selectedDestination == d.$1;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedDestination = d.$1;
                        _selectedEmoji = d.$2;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppShapes.spaceMd,
                          vertical: AppShapes.spaceSm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer
                              : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(
                            AppShapes.radiusFull,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.outline,
                          ),
                        ),
                        child: Text(
                          '${d.$2} ${d.$1}',
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
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: AppShapes.spaceLg),

              // ─── Days selector ───
              Text(
                'How many days?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppShapes.spaceMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DayButton(
                    label: '-',
                    onTap: () => setState(() {
                      if (_selectedDays > 1) _selectedDays--;
                    }),
                  ),
                  const SizedBox(width: AppShapes.spaceLg),
                  Text(
                    '$_selectedDays',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppShapes.spaceLg),
                  _DayButton(
                    label: '+',
                    onTap: () => setState(() {
                      if (_selectedDays < 30) _selectedDays++;
                    }),
                  ),
                ],
              ),
              Center(
                child: Text(
                  'days',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: AppShapes.spaceXl),

              // ─── Create button ───
              SizedBox(
                width: double.infinity,
                height: AppShapes.buttonHeight,
                child: ElevatedButton(
                  onPressed: !_isValid
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final created = await ref
                              .read(tripsProvider.notifier)
                              .createTrip(
                                destination: _finalDestination,
                                emoji: _useCustom ? '🌍' : _selectedEmoji,
                                days: _selectedDays,
                              );
                          if (!mounted) return;
                          final notice = ref
                              .read(tripsProvider)
                              .generationNotice;
                          if (notice != null) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(notice)),
                            );
                          }
                          if (created) navigator.pop();
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Generate with AI'),
                      const SizedBox(width: AppShapes.spaceSm),
                      const Text('✨', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppShapes.spaceSm),
              Center(
                child: Text(
                  'AI will create a real itinerary with specific places',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ),

              const SizedBox(height: AppShapes.spaceLg),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DayButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label == '+' ? 'Increase days' : 'Decrease days',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outline),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                color: AppColors.onSurface,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
