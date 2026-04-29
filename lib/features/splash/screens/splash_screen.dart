import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/providers/auth_provider.dart';
import 'package:lookstrip/core/services/onboarding_service.dart';
import 'package:lookstrip/features/onboarding/screens/onboarding_screen.dart';
import 'package:lookstrip/features/auth/screens/phone_input_screen.dart';
import 'package:lookstrip/features/shell/main_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navigationTimer;
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;

  // Glow pulse
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleUp = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Pulsing glow behind globe
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    _controller.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 2500), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    // Check auth
    await ref.read(authProvider.notifier).checkAuthState();
    final authState = ref.read(authProvider);

    if (!mounted) return;

    if (authState.isAuthenticated) {
      _goTo(MainShell(key: mainShellKey));
    } else {
      final hasSeen = await OnboardingService.hasSeenOnboarding();
      if (!mounted) return;
      if (hasSeen) {
        _goTo(const PhoneInputScreen());
      } else {
        _goTo(const OnboardingScreen());
      }
    }
  }

  void _goTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleUp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Globe with pulsing glow
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: _glowAnimation.value * 0.4,
                            ),
                            blurRadius: 40 + (_glowAnimation.value * 20),
                            spreadRadius: 5 + (_glowAnimation.value * 10),
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: const Text('🌍', style: TextStyle(fontSize: 72)),
                ),
                const SizedBox(height: 24),
                // App name
                Text(
                  'LooksTrip',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 36,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI-Powered Travel',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                // Loading dots
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
