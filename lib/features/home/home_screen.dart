import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import '../../core/game_data.dart';
import '../island/island_screen.dart';
import '../stage_map/stage_map_screen.dart';
import '../profile/profile_screen.dart';
import '../shop/shop_screen.dart';
import 'widgets/dashboard_tab.dart';

/// ═══════════════════════════════════════════════
/// 🏠 HOME SCREEN — Professional Dashboard
/// Beautiful parallax, glass cards, animated nav
/// ═══════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int _currentTab = 0;
  final List<Widget?> _tabWidgets = List<Widget?>.filled(5, null);

  @override
  void initState() {
    super.initState();
    _tabWidgets[0] = const DashboardTab();
    GameData.changes.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GameData.changes.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: List<Widget>.generate(5, _tabFor),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _tabFor(int index) {
    final existing = _tabWidgets[index];
    if (existing != null) return existing;
    final widget = switch (index) {
      1 => const LearningIsland(embedded: true),
      2 => const StageMapScreen(embedded: true),
      3 => const ShopScreen(embedded: true),
      4 => const ProfileScreen(embedded: true),
      _ => const DashboardTab(),
    };
    _tabWidgets[index] = widget;
    return widget;
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'خانه'),
              _navItem(1, Icons.explore_rounded, 'جزیره'),
              _navItemCenter(),
              _navItem(3, Icons.card_giftcard_rounded, 'جایزه'),
              _navItem(4, Icons.person_rounded, 'پروفایل'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentTab == index;
    final inactiveColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : AppColors.textLight;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentTab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : inactiveColor,
                size: selected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.primary : inactiveColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    ).animate(target: selected ? 1 : 0)
        .scaleXY(begin: 0.95, end: 1.0, duration: 200.ms);
  }

  Widget _navItemCenter() {
    final selected = _currentTab == 2;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _currentTab = 2);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: selected
              ? AppGradients.sunset
              : AppGradients.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (selected ? AppColors.sunset1 : AppColors.primary)
                  .withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.map_rounded,
          color: Colors.white,
          size: selected ? 30 : 28,
        ),
      )
          .animate(
            onPlay: (c) => c.repeat(reverse: true),
          )
          .moveY(
            begin: 0,
            end: -4,
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
    );
  }

}
