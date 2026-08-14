import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../gateway/learning_library_screen.dart';
import '../profile/profile_screen.dart';
import '../stage_map/stage_map_screen.dart';
import 'widgets/achievements_tab.dart';
import 'widgets/island_map/island_map_tab.dart';
import 'widgets/report_card_tab.dart';

/// ═══════════════════════════════════════════════
/// 🏠 HOME SCREEN — صفحه اصلی جزیره فندقی
/// نوار پایینی لوکس دقیقا مطابق طرح اسکرین‌شات
/// ═══════════════════════════════════════════════
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // تب خانه (مرکزی) تب پیش‌فرض شروع برنامه است
  int _currentTab = 2;
  final List<Widget?> _tabWidgets = List<Widget?>.filled(5, null);

  @override
  void initState() {
    super.initState();
    _tabWidgets[2] = IslandMapTab(
      onOpenStageMap: () => _openStageMapScreen(),
      onOpenBackpack: () => setState(() => _currentTab = 1),
      onOpenAchievements: () => setState(() => _currentTab = 0),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameData.playedGames.length >= 5 || GameData.streak >= 7) {
        FandoghiCoach.celebrate(
          'چه عالی که دوباره برگشتی! ادامه بده قهرمان 🌟',
        );
      }
    });
  }

  void _openStageMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StageMapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameStateProvider);

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

    final Widget widget = switch (index) {
      0 => const AchievementsTab(),
      1 => const LearningLibraryScreen(embedded: true),
      2 => IslandMapTab(
          onOpenStageMap: () => _openStageMapScreen(),
          onOpenBackpack: () => setState(() => _currentTab = 1),
          onOpenAchievements: () => setState(() => _currentTab = 0),
        ),
      3 => const ReportCardTab(),
      4 => const ProfileScreen(embedded: true),
      _ => IslandMapTab(
          onOpenStageMap: () => _openStageMapScreen(),
        ),
    };
    _tabWidgets[index] = widget;
    return widget;
  }

  // ─── نوار ناوبری پایینی دقیقا مطابق تصویر نمونه ──────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0277BD).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ۱. دستاوردها (سمت چپ)
              _navItem(
                index: 0,
                emoji: '🏆',
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFFFB300),
                label: 'دستاوردها',
              ),

              // ۲. کوله‌پشتی
              _navItem(
                index: 1,
                emoji: '🎒',
                icon: Icons.backpack_rounded,
                iconColor: const Color(0xFF1E88E5),
                label: 'کوله‌پشتی',
              ),

              // ۳. خانه (دکمه مرکزی شناور و برجسته با دایره آبی و آیکون خانه)
              _buildCenterHomeNav(),

              // ۴. کارنامه
              _navItem(
                index: 3,
                emoji: '📘',
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFF00ACC1),
                label: 'کارنامه',
              ),

              // ۵. داستان و پروفایل
              _navItem(
                index: 4,
                emoji: '👤',
                icon: Icons.person_rounded,
                iconColor: const Color(0xFF42A5F5),
                label: 'داستان',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── دکمه مرکزی خانه (برجسته و دایره‌ای) ──────────────────────
  Widget _buildCenterHomeNav() {
    final selected = _currentTab == 2;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        AudioService.tap();
        setState(() => _currentTab = 2);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // دایره با حاشیه آبی روشن و پس‌زمینه سفید و آیکون کلبه نارنجی
          Container(
            width: 58,
            height: 58,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? const Color(0xFF039BE5)
                    : const Color(0xFF81D4FA).withOpacity(0.8),
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (selected ? const Color(0xFF039BE5) : const Color(0xFF0288D1))
                      .withOpacity(0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _buildHomeHouseIcon(selected),
            ),
          )
              .animate(target: selected ? 1 : 0)
              .scale(begin: const Offset(0.96, 0.96), end: const Offset(1.06, 1.06), duration: 200.ms),

          Text(
            'خانه',
            style: AppFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: selected ? const Color(0xFF0277BD) : const Color(0xFF546E7A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeHouseIcon(bool selected) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC80).withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.home_rounded,
            size: 32,
            color: Color(0xFFE65100),
          ),
          Positioned(
            bottom: 6,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── آیتم‌های استاندارد نوار پایین ────────────────────────────
  Widget _navItem({
    required int index,
    required String emoji,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    final selected = _currentTab == index;
    final activeColor = iconColor;
    final inactiveColor = const Color(0xFF78909C);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        AudioService.tap();
        setState(() => _currentTab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected
                      ? activeColor.withOpacity(0.18)
                      : Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? activeColor.withOpacity(0.5) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: selected ? 22 : 20,
                      color: selected ? null : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppFonts.vazirmatn(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                color: selected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
