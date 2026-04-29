import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/services/onboarding_service.dart';
import 'package:lookstrip/features/auth/screens/phone_input_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      emoji: '🤖',
      title: 'Plan Smarter\nwith AI',
      description:
          'Tell us your dream destination and our AI builds\nyour perfect day-by-day itinerary',
    ),
    _OnboardingData(
      emoji: '👥',
      title: 'Travel\nTogether',
      description:
          'Share trips with friends and family.\nCollaborate in real-time on your next adventure',
    ),
    _OnboardingData(
      emoji: '🌍',
      title: 'Explore the\nWorld',
      description:
          'Discover flights, hotels, restaurants and\nhidden gems — all in one app',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await OnboardingService.markOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PhoneInputScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Skip button ───
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  AppShapes.spaceSm,
                  AppShapes.screenPadding,
                  0,
                ),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),

            // ─── Page content ───
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppShapes.screenPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji illustration
                        Text(page.emoji, style: const TextStyle(fontSize: 96)),
                        const SizedBox(height: AppShapes.space2xl),
                        // Title
                        Text(
                          page.title,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 32,
                            color: AppColors.onSurface,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppShapes.spaceMd),
                        // Description
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ─── Dot indicators ───
            Padding(
              padding: const EdgeInsets.only(bottom: AppShapes.spaceMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppColors.primary
                          : AppColors.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Next / Get Started button ───
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppShapes.screenPadding,
                0,
                AppShapes.screenPadding,
                AppShapes.spaceLg,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppShapes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String emoji;
  final String title;
  final String description;

  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.description,
  });
}
