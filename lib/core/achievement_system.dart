import 'game_data.dart';

/// =======================================================
/// 🏆 PREMIUM ACHIEVEMENT SYSTEM — فاز ۵۴ (۲۴ مدال)
/// =======================================================

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int target;
  final String type; // 'stars', 'correct', 'streak', 'coins', 'level', 'games', 'items'

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
  static final List<Achievement> allAchievements = <Achievement>[
    const Achievement(id: 'first_star', title: 'اولین ستاره', description: 'اولین ستاره‌ات رو گرفتی!', emoji: '⭐', target: 1, type: 'stars'),
    const Achievement(id: 'star_50', title: 'جمع‌کننده ستاره', description: '۵۰ ستاره جمع کردی!', emoji: '🌟', target: 50, type: 'stars'),
    const Achievement(id: 'star_200', title: 'استاد ستاره‌ها', description: '۲۰۰ ستاره جمع کردی!', emoji: '✨', target: 200, type: 'stars'),
    const Achievement(id: 'correct_50', title: 'تیرانداز', description: '۵۰ جواب درست دادی', emoji: '🎯', target: 50, type: 'correct'),
    const Achievement(id: 'correct_100', title: 'کودک باهوش', description: '۱۰۰ جواب درست دادی', emoji: '🧠', target: 100, type: 'correct'),
    const Achievement(id: 'correct_500', title: 'یادگیرنده برتر', description: '۵۰۰ جواب درست دادی', emoji: '📚', target: 500, type: 'correct'),
    const Achievement(id: 'streak_3', title: '۳ روز پیاپی', description: '۳ روز متوالی بازی کردی', emoji: '🔥', target: 3, type: 'streak'),
    const Achievement(id: 'streak_7', title: 'هفته طلایی', description: '۷ روز متوالی بازی کردی', emoji: '🔥🔥', target: 7, type: 'streak'),
    const Achievement(id: 'streak_30', title: 'ماه پیوسته', description: '۳۰ روز متوالی بازی کردی', emoji: '👑', target: 30, type: 'streak'),
    const Achievement(id: 'coin_500', title: 'ثروتمند', description: '۵۰۰ سکه جمع کردی', emoji: '💰', target: 500, type: 'coins'),
    const Achievement(id: 'coin_1000', title: 'سرمایه‌دار', description: '۱۰۰۰ سکه جمع کردی', emoji: '💎', target: 1000, type: 'coins'),
    const Achievement(id: 'coin_5000', title: 'میلیونر کوچولو', description: '۵۰۰۰ سکه جمع کردی', emoji: '🤑', target: 5000, type: 'coins'),
    const Achievement(id: 'level_3', title: 'نوآموز', description: 'به لول ۳ رسیدی', emoji: '🌱', target: 3, type: 'level'),
    const Achievement(id: 'level_5', title: 'یادگیرنده', description: 'به لول ۵ رسیدی', emoji: '⭐', target: 5, type: 'level'),
    const Achievement(id: 'level_10', title: 'قهرمان آموزش', description: 'به لول ۱۰ رسیدی', emoji: '🚀', target: 10, type: 'level'),
    const Achievement(id: 'level_20', title: 'استاد بزرگ', description: 'به لول ۲۰ رسیدی', emoji: '👑', target: 20, type: 'level'),
    const Achievement(id: 'collector', title: 'کلکسیونر', description: '۵ آیتم خریدی', emoji: '🎁', target: 5, type: 'items'),
    const Achievement(id: 'mega_collector', title: 'مگا کلکسیونر', description: '۱۰ آیتم خریدی', emoji: '🧸', target: 10, type: 'items'),
    const Achievement(id: 'game_explorer', title: 'کاوشگر بازی‌ها', description: '۵ بازی مختلف رو امتحان کردی', emoji: '🎮', target: 5, type: 'games'),
    const Achievement(id: 'alphabet_master', title: 'استاد الفبا', description: 'الفبا را تمرین کردی', emoji: '🔤', target: 1, type: 'alphabet'),
    const Achievement(id: 'math_50', title: 'ریاضیدان', description: '۵۰ امتیاز ریاضی گرفتی', emoji: '🧮', target: 50, type: 'math'),
    const Achievement(id: 'memory_king', title: 'شاه حافظه', description: 'بازی حافظه را کامل کردی', emoji: '🧠', target: 1, type: 'memory'),
    const Achievement(id: 'artist', title: 'هنرمند', description: 'یک نقاشی ذخیره کردی', emoji: '🎨', target: 1, type: 'artist'),
    const Achievement(id: 'story_teller', title: 'قصه‌گو', description: 'یک داستان تعاملی خواندی', emoji: '📖', target: 1, type: 'stories'),
  ];

  /// بررسی خودکار همه مدال‌ها و باز کردن مدال‌های جدید.
  static void checkAndUnlock() {
    for (final ach in allAchievements) {
      if (isUnlocked(ach) && !GameData.achievements.contains(ach.id)) {
        GameData.unlockAch(ach.id);
      }
    }
  }

  static List<Achievement> getUnlockedAchievements() {
    return allAchievements.where(isUnlocked).toList();
  }

  static bool isUnlocked(Achievement achievement) {
    switch (achievement.type) {
      case 'stars':
        return GameData.stars >= achievement.target;
      case 'correct':
        return GameData.totalCorrect >= achievement.target;
      case 'streak':
        return GameData.streak >= achievement.target;
      case 'coins':
        return GameData.coins >= achievement.target;
      case 'level':
        return GameData.level >= achievement.target;
      case 'items':
        return GameData.ownedItems.length >= achievement.target ||
            GameData.stickers.length >= achievement.target;
      case 'games':
        return GameData.playedGames.length >= achievement.target;
      case 'alphabet':
        return (GameData.skills['alphabet'] ?? 0) >= achievement.target;
      case 'math':
        return (GameData.skills['math'] ?? 0) >= achievement.target;
      case 'memory':
        return (GameData.skills['memory'] ?? 0) >= achievement.target;
      case 'artist':
        return (GameData.missionProgress['drawing'] ?? 0) >= achievement.target;
      case 'stories':
        return (GameData.skills['vocab'] ?? 0) >= achievement.target;
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
      case 'coins':
        return (GameData.coins / achievement.target).clamp(0.0, 1.0);
      case 'level':
        return (GameData.level / achievement.target).clamp(0.0, 1.0);
      case 'items':
        return ((GameData.ownedItems.length + GameData.stickers.length) / achievement.target).clamp(0.0, 1.0);
      case 'games':
        return (GameData.playedGames.length / achievement.target).clamp(0.0, 1.0);
      case 'alphabet':
        return ((GameData.skills['alphabet'] ?? 0) / achievement.target).clamp(0.0, 1.0);
      case 'math':
        return ((GameData.skills['math'] ?? 0) / achievement.target).clamp(0.0, 1.0);
      case 'memory':
        return ((GameData.skills['memory'] ?? 0) / achievement.target).clamp(0.0, 1.0);
      case 'artist':
        return 1.0;
      case 'stories':
        return ((GameData.skills['vocab'] ?? 0) / achievement.target).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }
}
