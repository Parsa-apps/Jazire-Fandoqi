import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _HomeState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentTab = 0;
  late AnimationController _navCtrl;

  @override
  void initState() {
    super.initState();
    _navCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _navCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: [
          const DashboardTab(),
          _buildIslandPlaceholder(),
          _buildMapPlaceholder(),
          _buildPrizePlaceholder(),
          _buildProfilePlaceholder(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                color: selected ? AppColors.primary : AppColors.textLight,
                size: selected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.primary : AppColors.textLight,
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

  // Placeholder tabs for island, map, prize, profile
  Widget _buildIslandPlaceholder() => const LearningIsland();
  Widget _buildMapPlaceholder() => const StageMapScreen();
  Widget _buildPrizePlaceholder() => const ShopScreen();
  Widget _buildProfilePlaceholder() => const ProfileScreen();
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white.withOpacity(0.8)),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.vazirmatn(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
