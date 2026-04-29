import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/providers/auth_provider.dart';
import 'package:lookstrip/core/providers/trips_provider.dart';
import 'package:lookstrip/core/services/app_preferences.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/features/auth/screens/phone_input_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _departureAirport = 'DEL';
  String _currency = 'USD';

  static const _travelStyles = [
    'Beach & Relaxation',
    'Adventure & Sports',
    'Culture & History',
    'Food & Culinary',
    'Wellness & Spa',
    'Nightlife & Party',
    'Nature & Wildlife',
    'Shopping & City',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final airport = await AppPreferences.getDepartureAirport();
    final currency = await AppPreferences.getPreferredCurrency();
    if (!mounted) return;
    setState(() {
      _departureAirport = airport;
      _currency = currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tripsState = ref.watch(tripsProvider);
    final userName = (user?.name.isNotEmpty == true) ? user!.name : 'Traveler';
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;
    final totalTrips = tripsState.trips.length;
    final totalDestinations = tripsState.trips
        .map((t) => t.destination)
        .toSet()
        .length;
    final totalDays = tripsState.trips.fold<int>(0, (sum, t) => sum + t.days);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppShapes.screenPadding,
                AppShapes.spaceLg,
                AppShapes.screenPadding,
                AppShapes.spaceLg,
              ),
              child: Text(
                'Profile',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 36,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppShapes.spaceMd),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppShapes.spaceXs),
                  Text(
                    isLoggedIn
                        ? (user?.phone ?? '')
                        : 'Sign in to save your trips',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppShapes.spaceLg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppShapes.screenPadding,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppShapes.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppShapes.radiusLg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Trips', value: '$totalTrips'),
                    Container(width: 1, height: 40, color: AppColors.outline),
                    _StatItem(
                      label: 'Destinations',
                      value: '$totalDestinations',
                    ),
                    Container(width: 1, height: 40, color: AppColors.outline),
                    _StatItem(label: 'Days', value: '$totalDays'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppShapes.spaceLg),
            if (user != null && user.travelStyles.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppShapes.screenPadding,
                ),
                child: Text(
                  'Your Travel Style',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppShapes.spaceSm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppShapes.screenPadding,
                ),
                child: Wrap(
                  spacing: AppShapes.spaceSm,
                  runSpacing: AppShapes.spaceSm,
                  children: user.travelStyles.map((style) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppShapes.spaceMd,
                        vertical: AppShapes.spaceXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppShapes.radiusFull,
                        ),
                      ),
                      child: Text(
                        style,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppShapes.spaceLg),
            ],
            _SettingsSection(
              title: 'Preferences',
              items: [
                _SettingsItem(
                  icon: Icons.palette_outlined,
                  label: 'Travel Style',
                  trailing: user?.travelStyles.isNotEmpty == true
                      ? '${user!.travelStyles.length} selected'
                      : 'Not set',
                  onTap: () => _editTravelStyles(user?.travelStyles ?? []),
                ),
                _SettingsItem(
                  icon: Icons.flight_takeoff_rounded,
                  label: 'Home Airport',
                  trailing: _departureAirport,
                  onTap: _editDepartureAirport,
                ),
                _SettingsItem(
                  icon: Icons.currency_exchange_rounded,
                  label: 'Currency',
                  trailing: _currency,
                  onTap: _editCurrency,
                ),
                _SettingsItem(
                  icon: Icons.language_rounded,
                  label: 'Language',
                  trailing: 'English',
                  onTap: () => _showInfo(
                    'Language',
                    'English is currently the supported app language.',
                  ),
                ),
              ],
            ),
            _SettingsSection(
              title: 'App',
              items: [
                _SettingsItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => _showInfo(
                    'Notifications',
                    'Trip reminders will be enabled after notification scheduling is added.',
                  ),
                ),
                _SettingsItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () => _showInfo(
                    'Help & Support',
                    'For now, check the project README for setup and troubleshooting details.',
                  ),
                ),
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About LooksTrip',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'LooksTrip',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        'AI-powered trip planning with local-first storage.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppShapes.spaceLg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppShapes.screenPadding,
              ),
              child: isLoggedIn
                  ? SizedBox(
                      width: double.infinity,
                      height: AppShapes.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () async {
                          await ref.read(authProvider.notifier).signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const PhoneInputScreen(),
                              ),
                              (_) => false,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: const Text('Sign Out'),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: AppShapes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const PhoneInputScreen(),
                            ),
                            (_) => false,
                          );
                        },
                        child: const Text('Sign In'),
                      ),
                    ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Future<void> _editTravelStyles(List<String> currentStyles) async {
    final selected = currentStyles.toSet();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Travel Style'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _travelStyles.map((style) {
                    return CheckboxListTile(
                      value: selected.contains(style),
                      contentPadding: EdgeInsets.zero,
                      title: Text(style),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selected.add(style);
                          } else {
                            selected.remove(style);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selected.toList()),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;
    await ref.read(authProvider.notifier).updateTravelStyles(result);
    _showSnack('Travel style updated');
  }

  Future<void> _editDepartureAirport() async {
    final controller = TextEditingController(text: _departureAirport);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Home Airport'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 3,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'IATA code',
            helperText: 'Use a 3-letter airport code, for example JFK or DEL.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.length != 3) return;
    await AppPreferences.setDepartureAirport(normalized);
    if (!mounted) return;
    setState(() => _departureAirport = normalized);
    _showSnack('Home airport updated');
  }

  Future<void> _editCurrency() async {
    final controller = TextEditingController(text: _currency);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferred Currency'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 3,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Currency code',
            helperText: 'Use an ISO code such as USD, INR, EUR, or GBP.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.length != 3) return;
    await AppPreferences.setPreferredCurrency(normalized);
    if (!mounted) return;
    setState(() => _currency = normalized);
    _showSnack('Currency updated');
  }

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppShapes.spaceXs),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppShapes.screenPadding,
            AppShapes.spaceMd,
            AppShapes.screenPadding,
            AppShapes.spaceSm,
          ),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppShapes.screenPadding,
      ),
      leading: Icon(icon, color: AppColors.onSurfaceVariant, size: 22),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: AppShapes.spaceXs),
              child: Text(
                trailing!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.onSurfaceMuted,
            size: 20,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
