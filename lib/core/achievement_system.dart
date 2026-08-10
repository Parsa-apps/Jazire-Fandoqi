import 'game_data.dart';

/// =======================================================
/// 🏆 PREMIUM ACHIEVEMENT SYSTEM V2 — ۵۰ مدال پریمیوم
/// پیشنهاد ۳۴ — از ۲۶ به ۵۰ مدال با انیمیشن و دسته‌بندی
/// =======================================================

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int target;
  final String type;
  final String category; // برای فیلتر UI

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.target,
    required this.type,
    this.category = 'عمومی',
  });
}

class AchievementSystem {
  static final List<Achievement> allAchievements = <Achievement>[
    // ── ستاره ──
    const Achievement(id: 'first_star', title: 'اولین ستاره', description: 'اولین ستاره‌ات رو گرفتی!', emoji: '⭐', target: 1, type: 'stars', category: 'ستاره'),
    const Achievement(id: 'star_10', title: 'ده‌تایی', description: '۱۰ ستاره جمع کردی', emoji: '🌟', target: 10, type: 'stars', category: 'ستاره'),
    const Achievement(id: 'star_50', title: 'جمع‌کننده ستاره', description: '۵۰ ستاره جمع کردی!', emoji: '🌟', target: 50, type: 'stars', category: 'ستاره'),
    const Achievement(id: 'star_100', title: 'صدتایی', description: '۱۰۰ ستاره!', emoji: '💫', target: 100, type: 'stars', category: 'ستاره'),
    const Achievement(id: 'star_200', title: 'استاد ستاره‌ها', description: '۲۰۰ ستاره جمع کردی!', emoji: '✨', target: 200, type: 'stars', category: 'ستاره'),
    const Achievement(id: 'star_500', title: 'کهکشان', description: '۵۰۰ ستاره — کهکشان از آن توست!', emoji: '🌌', target: 500, type: 'stars', category: 'ستاره'),
    // ── پاسخ درست ──
    const Achievement(id: 'correct_50', title: 'تیرانداز', description: '۵۰ جواب درست دادی', emoji: '🎯', target: 50, type: 'correct', category: 'دانش'),
    const Achievement(id: 'correct_100', title: 'کودک باهوش', description: '۱۰۰ جواب درست دادی', emoji: '🧠', target: 100, type: 'correct', category: 'دانش'),
    const Achievement(id: 'correct_200', title: 'نابغه', description: '۲۰۰ جواب درست', emoji: '🤓', target: 200, type: 'correct', category: 'دانش'),
    const Achievement(id: 'correct_500', title: 'یادگیرنده برتر', description: '۵۰۰ جواب درست دادی', emoji: '📚', target: 500, type: 'correct', category: 'دانش'),
    const Achievement(id: 'correct_1000', title: 'افسانه دانش', description: '۱۰۰۰ جواب درست — افسانه‌ای!', emoji: '👑', target: 1000, type: 'correct', category: 'دانش'),
    // ── استریک ──
    const Achievement(id: 'streak_3', title: '۳ روز پیاپی', description: '۳ روز متوالی بازی کردی', emoji: '🔥', target: 3, type: 'streak', category: 'پشتکار'),
    const Achievement(id: 'streak_7', title: 'هفته طلایی', description: '۷ روز متوالی بازی کردی', emoji: '🔥🔥', target: 7, type: 'streak', category: 'پشتکار'),
    const Achievement(id: 'streak_14', title: 'دو هفته', description: '۱۴ روز پشت سر هم', emoji: '⚡', target: 14, type: 'streak', category: 'پشتکار'),
    const Achievement(id: 'streak_30', title: 'ماه پیوسته', description: '۳۰ روز متوالی بازی کردی', emoji: '👑', target: 30, type: 'streak', category: 'پشتکار'),
    const Achievement(id: 'streak_60', title: 'فصل طلایی', description: '۶۰ روز — یک فصل کامل!', emoji: '🏆', target: 60, type: 'streak', category: 'پشتکار'),
    // ── سکه ──
    const Achievement(id: 'coin_200', title: 'پس‌انداز', description: '۲۰۰ سکه', emoji: '🪙', target: 200, type: 'coins', category: 'ثروت'),
    const Achievement(id: 'coin_500', title: 'ثروتمند', description: '۵۰۰ سکه جمع کردی', emoji: '💰', target: 500, type: 'coins', category: 'ثروت'),
    const Achievement(id: 'coin_1000', title: 'سرمایه‌دار', description: '۱۰۰۰ سکه جمع کردی', emoji: '💎', target: 1000, type: 'coins', category: 'ثروت'),
    const Achievement(id: 'coin_2000', title: 'گنج بزرگ', description: '۲۰۰۰ سکه!', emoji: '🏴‍☠️', target: 2000, type: 'coins', category: 'ثروت'),
    const Achievement(id: 'coin_5000', title: 'میلیونر کوچولو', description: '۵۰۰۰ سکه جمع کردی', emoji: '🤑', target: 5000, type: 'coins', category: 'ثروت'),
    // ── لول ──
    const Achievement(id: 'level_3', title: 'نوآموز', description: 'به لول ۳ رسیدی', emoji: '🌱', target: 3, type: 'level', category: 'لول'),
    const Achievement(id: 'level_5', title: 'یادگیرنده', description: 'به لول ۵ رسیدی', emoji: '⭐', target: 5, type: 'level', category: 'لول'),
    const Achievement(id: 'level_7', title: 'کاوشگر', description: 'لول ۷', emoji: '🧭', target: 7, type: 'level', category: 'لول'),
    const Achievement(id: 'level_10', title: 'قهرمان آموزش', description: 'به لول ۱۰ رسیدی', emoji: '🚀', target: 10, type: 'level', category: 'لول'),
    const Achievement(id: 'level_15', title: 'قهرمان بزرگ', description: 'لول ۱۵', emoji: '🦸', target: 15, type: 'level', category: 'لول'),
    const Achievement(id: 'level_20', title: 'استاد بزرگ', description: 'به لول ۲۰ رسیدی', emoji: '👑', target: 20, type: 'level', category: 'لول'),
    const Achievement(id: 'level_30', title: 'افسانه', description: 'لول ۳۰ — افسانه‌ای!', emoji: '🌟', target: 30, type: 'level', category: 'لول'),
    // ── کلکسیون ──
    const Achievement(id: 'collector', title: 'کلکسیونر', description: '۵ آیتم خریدی', emoji: '🎁', target: 5, type: 'items', category: 'کلکسیون'),
    const Achievement(id: 'mega_collector', title: 'مگا کلکسیونر', description: '۱۰ آیتم خریدی', emoji: '🧸', target: 10, type: 'items', category: 'کلکسیون'),
    const Achievement(id: 'ultra_collector', title: 'ابر کلکسیونر', description: '۲۰ آیتم', emoji: '🎀', target: 20, type: 'items', category: 'کلکسیون'),
    // ── بازی‌ها ──
    const Achievement(id: 'game_explorer', title: 'کاوشگر بازی‌ها', description: '۵ بازی مختلف رو امتحان کردی', emoji: '🎮', target: 5, type: 'games', category: 'بازی'),
    const Achievement(id: 'game_master', title: 'استاد بازی‌ها', description: '۱۰ بازی مختلف', emoji: '🕹️', target: 10, type: 'games', category: 'بازی'),
    const Achievement(id: 'game_legend', title: 'افسانه بازی', description: '۱۶ بازی — همه را امتحان کردی!', emoji: '🏆', target: 16, type: 'games', category: 'بازی'),
    // ── آموزشی تخصصی ──
    const Achievement(id: 'alphabet_master', title: 'استاد الفبا', description: 'الفبا را تمرین کردی', emoji: '🔤', target: 1, type: 'alphabet', category: 'آموزش'),
    const Achievement(id: 'alphabet_10', title: 'خوشنویس', description: '۱۰ حرف را نوشتی', emoji: '✍️', target: 10, type: 'alphabet', category: 'آموزش'),
    const Achievement(id: 'math_50', title: 'ریاضیدان', description: '۵۰ امتیاز ریاضی گرفتی', emoji: '🧮', target: 50, type: 'math', category: 'آموزش'),
    const Achievement(id: 'math_100', title: 'نابغه ریاضی', description: '۱۰۰ امتیاز ریاضی', emoji: '🔢', target: 100, type: 'math', category: 'آموزش'),
    const Achievement(id: 'memory_king', title: 'شاه حافظه', description: 'بازی حافظه را کامل کردی', emoji: '🧠', target: 1, type: 'memory', category: 'آموزش'),
    const Achievement(id: 'memory_10', title: 'حافظه فولادی', description: '۱۰ بار حافظه', emoji: '🧠', target: 10, type: 'memory', category: 'آموزش'),
    const Achievement(id: 'artist', title: 'هنرمند', description: 'یک نقاشی ذخیره کردی', emoji: '🎨', target: 1, type: 'artist', category: 'هنر'),
    const Achievement(id: 'artist_10', title: 'پیکاسو کوچولو', description: '۱۰ نقاشی', emoji: '🖌️', target: 10, type: 'artist', category: 'هنر'),
    const Achievement(id: 'story_teller', title: 'قصه‌گو', description: 'یک داستان تعاملی خواندی', emoji: '📖', target: 1, type: 'stories', category: 'قصه'),
    const Achievement(id: 'story_lover', title: 'عاشق قصه', description: '۱۰ داستان', emoji: '📚', target: 10, type: 'stories', category: 'قصه'),
    const Achievement(id: 'cartoon_watcher', title: 'عاشق کارتون', description: 'یک کارتون تماشا کردی!', emoji: '🎬', target: 1, type: 'cartoons', category: 'کارتون'),
    const Achievement(id: 'cartoon_fan', title: 'سینمادوست کوچولو', description: '۵ کارتون مختلف تماشا کردی!', emoji: '🍿', target: 5, type: 'cartoons', category: 'کارتون'),
    // ── جدید: حیوانات ایران ──
    const Achievement(id: 'animal_5', title: 'دوست حیوانات', description: '۵ حیوان ایران را شناختی', emoji: '🦁', target: 5, type: 'animals', category: 'حیوانات'),
    const Achievement(id: 'animal_15', title: 'حامی حیات‌وحش', description: '۱۵ حیوان', emoji: '🐆', target: 15, type: 'animals', category: 'حیوانات'),
    const Achievement(id: 'animal_30', title: 'دانشنامه حیوانات', description: '۳۰ حیوان — همه را شناختی!', emoji: '🌿', target: 30, type: 'animals', category: 'حیوانات'),
    // ── لالایی و جزیره ──
    const Achievement(id: 'lullaby_1', title: 'خواب شیرین', description: 'یک لالایی گوش دادی', emoji: '🌙', target: 1, type: 'lullaby', category: 'لالایی'),
    const Achievement(id: 'island_1', title: 'معمار جزیره', description: 'اولین تزئین جزیره', emoji: '🏝️', target: 1, type: 'island', category: 'جزیره'),
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
        return GameData.ownedItems.length >= achievement.target || GameData.stickers.length >= achievement.target;
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
        return (GameData.skills['vocab'] ?? 0) >= achievement.target || (GameData.skills['stories'] ?? 0) >= achievement.target;
      case 'cartoons':
        return GameData.watchedCartoons.length >= achievement.target;
      case 'animals':
        return (GameData.skills['animals'] ?? 0) >= achievement.target;
      case 'lullaby':
        return (GameData.skills['lullaby'] ?? 0) >= achievement.target || GameData.watchedCartoons.length >= achievement.target;
      case 'island':
        return GameData.islandDecorations.length >= achievement.target;
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
        return ((GameData.missionProgress['drawing'] ?? 0) / achievement.target).clamp(0.0, 1.0).toDouble();
      case 'stories':
        return ((GameData.skills['vocab'] ?? 0) / achievement.target).clamp(0.0, 1.0).toDouble();
      case 'cartoons':
        return (GameData.watchedCartoons.length / achievement.target).clamp(0.0, 1.0);
      case 'animals':
        return ((GameData.skills['animals'] ?? 0) / achievement.target).clamp(0.0, 1.0).toDouble();
      case 'lullaby':
        return ((GameData.skills['lullaby'] ?? 0) / achievement.target).clamp(0.0, 1.0).toDouble();
      case 'island':
        return (GameData.islandDecorations.length / achievement.target).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }
}
