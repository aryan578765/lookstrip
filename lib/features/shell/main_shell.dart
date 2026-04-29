import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/widgets/offline_banner.dart';
import 'package:lookstrip/features/home/screens/home_screen.dart';
import 'package:lookstrip/features/explore/screens/explore_screen.dart';
import 'package:lookstrip/features/chat/screens/chat_screen.dart';
import 'package:lookstrip/features/trips/screens/trips_screen.dart';
import 'package:lookstrip/features/profile/screens/profile_screen.dart';

/// Global key to access MainShell from anywhere
final mainShellKey = GlobalKey<MainShellState>();

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    ExploreScreen(),
    ChatScreen(),
    TripsScreen(),
    ProfileScreen(),
  ];

  /// Public method to switch tabs from child screens
  void switchToTab(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return TabSwitcher(
      switchTo: switchToTab,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            IndexedStack(index: _currentIndex, children: _screens),
            // Offline banner overlays on top
            const Positioned(top: 0, left: 0, right: 0, child: OfflineBanner()),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: AppColors.surfaceContainer,
      elevation: 0,
      child: SizedBox(
        height: AppShapes.navBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
              label: 'Home',
              isSelected: _currentIndex == 0,
              onTap: () => _onTabTapped(0),
            ),
            _NavItem(
              icon: PhosphorIcons.compass(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.compass(PhosphorIconsStyle.fill),
              label: 'Explore',
              isSelected: _currentIndex == 1,
              onTap: () => _onTabTapped(1),
            ),
            _NavItem(
              icon: PhosphorIcons.chatCircleDots(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.chatCircleDots(PhosphorIconsStyle.fill),
              label: 'Chat',
              isSelected: _currentIndex == 2,
              onTap: () => _onTabTapped(2),
            ),
            _NavItem(
              icon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
              label: 'Trips',
              isSelected: _currentIndex == 3,
              onTap: () => _onTabTapped(3),
            ),
            _NavItem(
              icon: PhosphorIcons.userCircle(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
              label: 'Profile',
              isSelected: _currentIndex == 4,
              onTap: () => _onTabTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}

/// InheritedWidget for tab switching from any child screen
class TabSwitcher extends InheritedWidget {
  final void Function(int) switchTo;

  const TabSwitcher({super.key, required this.switchTo, required super.child});

  static TabSwitcher? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabSwitcher>();
  }

  @override
  bool updateShouldNotify(TabSwitcher oldWidget) => false;
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bouncing icon
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Active dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
