import 'package:flutter/material.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/achievement_system.dart';
import '../../core/premium_animations.dart';
import '../home/widgets/premium_card.dart';

/// =======================================================
/// 🏆 PREMIUM ACHIEVEMENTS SCREEN
/// =======================================================
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlocked = AchievementSystem.getUnlockedAchievements();
    final all = AchievementSystem.allAchievements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدال‌ها و دستاوردها'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: all.length,
        itemBuilder: (context, index) {
          final ach = all[index];
          final isUnlocked = unlocked.contains(ach);
          final progress = AchievementSystem.getProgress(ach);

          return PremiumCard(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Premium Image Badge
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isUnlocked 
                        ? const Color(0xFFFFD700).withOpacity(0.15)
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      isUnlocked 
                          ? 'assets/premium/medal_gold.png' 
                          : 'assets/premium/star_badge.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
                const SizedBox(width: 18),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ach.title,
                        style: AppFonts.vazirmatn(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isUnlocked ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ach.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUnlocked ? Colors.black54 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar
                      if (!isUnlocked)
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFFFFD700),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(10),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'دستیابی شد! ✅',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (80 * index).ms).slideY(begin: 0.2);
        },
      ),
    );
  }
}