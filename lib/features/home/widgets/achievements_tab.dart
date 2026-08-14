import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_fonts.dart';
import '../../../core/achievement_system.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../../../presentation/providers/game_state_provider.dart';
import '../../../shared/widgets/premium_daily_missions.dart';
import '../../../shared/widgets/premium_streak_calendar.dart';
import 'daily_gifts_dialog.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🏆 ACHIEVEMENTS TAB — تب دستاوردها، مدال‌ها، ماموریت‌ها و استریک
/// ═══════════════════════════════════════════════════════════════
class AchievementsTab extends ConsumerStatefulWidget {
  const AchievementsTab({super.key});

  @override
  ConsumerState<AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends ConsumerState<AchievementsTab> {
  @override
  Widget build(BuildContext context) {
    ref.watch(gameStateProvider);
    final allAch = AchievementSystem.allAchievements;
    final unlockedCount = GameData.achievements.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── هدر دستاوردها ──
              _buildHeader(unlockedCount, allAch.length),

              const SizedBox(height: 16),

              // ── تقویم استریک روزانه ──
              PremiumStreakCalendar(
                onHeartIceTap: () {
                  if (GameData.streak == 0) {
                    if (GameData.activateIceHeart()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🧊 قلب یخی فعال شد! ۵۰ سکه کسر شد')),
                      );
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('برای قلب یخی به ۵۰ سکه نیاز داری 🪙')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('🔥 استریک ${GameData.streak} روزه‌ات عالیه! ادامه بده!')),
                    );
                  }
                },
                onCalendarTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📅 ۷ روز ماجراجویی اخیر ثبت شد!')),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── ماموریت‌های امروز ──
              _sectionTitle('🎁 مأموریت‌های طلایی امروز'),
              const SizedBox(height: 8),
              PremiumDailyMissions(
                onClaimChest: () {
                  if (GameData.claimDailyMissionChest()) {
                    showDailyGiftsDialog(context, onRewardClaimed: () {
                      if (mounted) setState(() {});
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // ── کلکسیون مدال‌ها و افتخارات ──
              _sectionTitle('🏅 کلکسیون مدال‌ها و افتخارات'),
              const SizedBox(height: 10),
              _buildTrophiesGrid(allAch),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int unlocked, int total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8F00).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تالار افتخارات من',
                  style: AppFonts.vazirmatn(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$unlocked از $total مدال قهرمانی کسب شده',
                  style: AppFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.vazirmatn(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildTrophiesGrid(List<Achievement> list) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final ach = list[i];
        final isUnlocked = GameData.achievements.contains(ach.id);

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            AudioService.tap();
            FandoghiCoach.instruction(
              isUnlocked
                  ? 'آفرین! مدال «${ach.title}» رو کسب کردی! 🏆'
                  : 'برای گرفتن مدال «${ach.title}»: ${ach.description} 🎯',
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isUnlocked
                    ? const Color(0xFFFFB300)
                    : Colors.grey.shade300,
                width: isUnlocked ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isUnlocked
                      ? const Color(0xFFFFB300).withOpacity(0.2)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ach.emoji,
                  style: TextStyle(
                    fontSize: 32,
                    color: isUnlocked ? null : Colors.grey.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ach.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isUnlocked
                        ? const Color(0xFF2C3E50)
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isUnlocked ? 'کسب شده ✅' : 'قفل 🔒',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? const Color(0xFF4CAF50) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
