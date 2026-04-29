import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/providers/auth_provider.dart';
import 'package:lookstrip/features/shell/main_shell.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final Set<String> _selectedStyles = {};
  bool _saving = false;

  static const _travelStyles = [
    ('🏖️', 'Beach & Relaxation'),
    ('🏔️', 'Adventure & Sports'),
    ('🏛️', 'Culture & History'),
    ('🍽️', 'Food & Culinary'),
    ('🧘', 'Wellness & Spa'),
    ('🎉', 'Nightlife & Party'),
    ('🌿', 'Nature & Wildlife'),
    ('🛍️', 'Shopping & City'),
  ];

  Future<void> _completeSetup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving) return;

    setState(() => _saving = true);
    await ref
        .read(authProvider.notifier)
        .completeProfile(name: name, travelStyles: _selectedStyles.toList());
    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShell(key: mainShellKey)),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppShapes.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppShapes.space2xl),

              // ─── Title ───
              Text(
                'Set Up Your\nProfile',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 30,
                  color: AppColors.onSurface,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: AppShapes.spaceSm),

              Text(
                'Tell us a bit about yourself',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppShapes.spaceXl),

              // ─── Avatar ───
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: AppShapes.spaceLg),

              // ─── Name input ───
              Text(
                'What\'s your name?',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppShapes.spaceSm),
              SizedBox(
                height: AppShapes.inputHeight,
                child: TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              const SizedBox(height: AppShapes.spaceLg),

              // ─── Travel style section ───
              Text(
                'Pick your travel style',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppShapes.spaceXs),
              Text(
                'Select all that apply',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppShapes.spaceMd),

              // ─── Style chips ───
              Wrap(
                spacing: AppShapes.spaceSm,
                runSpacing: AppShapes.spaceSm,
                children: _travelStyles.map((style) {
                  final isSelected = _selectedStyles.contains(style.$2);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedStyles.remove(style.$2);
                        } else {
                          _selectedStyles.add(style.$2);
                        }
                      });
                    },
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
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(style.$1, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: AppShapes.spaceSm),
                          Text(
                            style.$2,
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
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppShapes.space2xl),

              // ─── Complete button ───
              SizedBox(
                width: double.infinity,
                height: AppShapes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _nameController.text.trim().isNotEmpty && !_saving
                      ? _completeSetup
                      : null,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text('Complete Setup'),
                ),
              ),

              const SizedBox(height: AppShapes.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}
