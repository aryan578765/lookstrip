import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/services/app_config.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';

class ConfigurationScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const ConfigurationScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final issues = AppConfig.configurationIssues;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppShapes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppShapes.space3xl),
              Text(
                'LooksTrip',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 34,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppShapes.spaceSm),
              Text(
                'Configuration needs attention',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppShapes.spaceMd),
              Text(
                'The app can continue in offline/demo mode, but these features need configuration before production use.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppShapes.spaceLg),
              ...issues.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: AppShapes.spaceSm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppShapes.spaceSm),
                      Expanded(
                        child: Text(
                          issue,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: AppShapes.buttonHeight,
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Continue in offline mode'),
                ),
              ),
              const SizedBox(height: AppShapes.spaceSm),
              Text(
                'Use .env.example for local setup. API secrets belong on the backend proxy, not inside the mobile app.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
