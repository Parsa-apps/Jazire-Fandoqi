import 'package:flutter/material.dart';
import 'game_data.dart';

/// =======================================================
/// 🏆 PREMIUM ACHIEVEMENT SYSTEM
/// =======================================================

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int target;
  final String type; // 'stars', 'correct', 'streak', 'games'

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.target,
    required this.type,
  });
}

class AchievementSystem {
  static final List<Achievement> allAchievements = [
    const Achievement(
      id: 'first_star',
      title: 'اولین ستاره',
      description: 'اولین ستاره‌ات رو گرفتی!',
      emoji: '⭐',
      target: 1,
      type: 'stars',
    ),
    const Achievement(
      id: 'star_collector',
      title: 'جمع‌کننده ستاره',
      description: '۵۰ ستاره جمع کردی!',
      emoji: '🌟',
      target: 50,
      type: 'stars',
    ),
    const Achievement(
      id: 'star_master',
      title: 'استاد ستاره‌ها',
      description: '۲۰۰ ستاره جمع کردی!',
      emoji: '✨',
      target: 200,
      type: 'stars',
    ),
    const Achievement(
      id: 'smart_kid',
      title: 'کودک باهوش',
      description: '۱۰۰ جواب درست دادی',
      emoji: '🧠',
      target: 100,
      type: 'correct',
    ),
    const Achievement(
      id: 'super_learner',
      title: 'یادگیرنده برتر',
      description: '۳۰۰ جواب درست دادی',
      emoji: '📚',
      target: 300,
      type: 'correct',
    ),
    const Achievement(
      id: 'streak_3',
      title: '۳ روز پیاپی',
      description: '۳ روز متوالی بازی کردی',
      emoji: '🔥',
      target: 3,
      type: 'streak',
    ),
    const Achievement(
      id: 'streak_7',
      title: 'هفته طلایی',
      description: '۷ روز متوالی بازی کردی',
      emoji: '🔥🔥',
      target: 7,
      type: 'streak',
    ),
    const Achievement(
      id: 'game_explorer',
      title: 'کاوشگر بازی‌ها',
      description: '۵ بازی مختلف رو امتحان کردی',
      emoji: '🎮',
      target: 5,
      type: 'games',
    ),
  ];

  static List<Achievement> getUnlockedAchievements() {
    final unlocked = <Achievement>[];
    for (final ach in allAchievements) {
      if (isUnlocked(ach)) unlocked.add(ach);
    }
    return unlocked;
  }

  static bool isUnlocked(Achievement achievement) {
    switch (achievement.type) {
      case 'stars':
        return GameData.stars >= achievement.target;
      case 'correct':
        return GameData.totalCorrect >= achievement.target;
      case 'streak':
        return GameData.streak >= achievement.target;
      case 'games':
        return GameData.playedGames.length >= achievement.target;
      default:
        return false;
    }
  }

  static double getProgress(Achievement achievement) {
    switch (achievement.type) {
      case 'stars':
        return (GameData.stars / achievement.target).clamp(0.0, 1.0);
      case 'correct':
        return (GameData.totalCorrect / achievement.target).clamp(0.0, 1.0);
      case 'streak':
        return (GameData.streak / achievement.target).clamp(0.0, 1.0);
      case 'games':
        return (GameData.playedGames.length / achievement.target).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }
}