import '../ai_system.dart';
import '../game_data.dart';
import '../jalali_calendar.dart';
import 'growth_store.dart';
import 'persian_digits.dart';

class WeeklyChallenge {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final int target;
  final String unit;

  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.target,
    required this.unit,
  });
}

/// چالش هفتگی، نمودار ۷ روزه، هدف والد و گزارش قابل اشتراک.
class WeeklyEngine {
  WeeklyEngine._();

  static const List<WeeklyChallenge> _pool = [
    WeeklyChallenge(
      id: 'life5',
      title: 'کاوشگر زندگی',
      emoji: '🧭',
      description: '۵ دور مهارت زندگی بازی کن',
      target: 5,
      unit: 'دور',
    ),
    WeeklyChallenge(
      id: 'story3',
      title: 'قصه‌خوان هفته',
      emoji: '📖',
      description: '۳ داستان کامل بخوان',
      target: 3,
      unit: 'داستان',
    ),
    WeeklyChallenge(
      id: 'alpha10',
      title: 'خوشنویس هفته',
      emoji: '✍️',
      description: '۱۰ تمرین الفبا انجام بده',
      target: 10,
      unit: 'تمرین',
    ),
    WeeklyChallenge(
      id: 'learn40',
      title: 'یادگیرنده طلایی',
      emoji: '🥇',
      description: '۴۰ دقیقه یادگیری واقعی (نه کارتون)',
      target: 40,
      unit: 'دقیقه',
    ),
    WeeklyChallenge(
      id: 'mix12',
      title: 'هفته رنگارنگ',
      emoji: '🌈',
      description: '۱۲ پاسخ درست در بازی‌های مختلف بده',
      target: 12,
      unit: 'پاسخ',
    ),
  ];

  static String get _weekId {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return GrowthStore.dateKey(monday);
  }

  static WeeklyChallenge currentChallenge() {
    final week = _weekId;
    if (GrowthStore.weeklyChallengeId.startsWith(week)) {
      final id = GrowthStore.weeklyChallengeId.substring(week.length + 1);
      for (final item in _pool) {
        if (item.id == id) return item;
      }
    }
    final index = week.hashCode.abs() % _pool.length;
    final chosen = _pool[index];
    GrowthStore.weeklyChallengeId = '$week.${chosen.id}';
    GrowthStore.weeklyChallengeProgress = 0;
    GrowthStore.save();
    return chosen;
  }

  static void progress(String challengeKind, {int amount = 1}) {
    final current = currentChallenge();
    final match = switch (current.id) {
      'life5' => challengeKind == 'life',
      'story3' => challengeKind == 'story',
      'alpha10' => challengeKind == 'alphabet',
      'learn40' => challengeKind == 'learn_minute',
      'mix12' => challengeKind == 'correct',
      _ => false,
    };
    if (!match || amount <= 0) return;
    if (GrowthStore.weeklyChallengeProgress >= current.target) return;
    GrowthStore.weeklyChallengeProgress += amount;
    if (GrowthStore.weeklyChallengeProgress > current.target) {
      GrowthStore.weeklyChallengeProgress = current.target;
    }
    GrowthStore.save();
    GrowthStore.changes.bump();
  }

  static double get challengeRatio {
    final current = currentChallenge();
    return (GrowthStore.weeklyChallengeProgress / current.target).clamp(0, 1);
  }

  static bool get challengeDone =>
      GrowthStore.weeklyChallengeProgress >= currentChallenge().target;

  /// ۷ روز اخیر: (برچسب شمسی کوتاه، دقیقه کل، دقیقه یادگیری)
  static List<(String label, int total, int learning)> last7Days() {
    final result = <(String, int, int)>[];
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = GrowthStore.dateKey(day);
      final jalali = JalaliDate.fromGregorian(day);
      result.add((
        PersianDigits.toFa(jalali.day),
        GrowthStore.dailyMinutes[key] ?? 0,
        GrowthStore.learningMinutes[key] ?? 0,
      ));
    }
    return result;
  }

  static int weekLearningMinutes() {
    var sum = 0;
    for (final row in last7Days()) {
      sum += row.$3;
    }
    return sum;
  }

  static int weekEntertainmentMinutes() {
    var sum = 0;
    final now = DateTime.now();
    for (var i = 0; i < 7; i++) {
      final key = GrowthStore.dateKey(now.subtract(Duration(days: i)));
      sum += GrowthStore.entertainmentMinutes[key] ?? 0;
    }
    return sum;
  }

  static bool get weeklyGoalMet =>
      weekLearningMinutes() >= GrowthStore.weeklyGoalMinutes;

  static bool get canClaimLearningChest {
    final today = GrowthStore.dateKey();
    return GrowthStore.learningChestMinutes >= 15 &&
        GrowthStore.learningChestDay != today;
  }

  static bool claimLearningChest({int reward = 15}) {
    if (!canClaimLearningChest) return false;
    GrowthStore.learningChestDay = GrowthStore.dateKey();
    GameData.addCoins(reward);
    GrowthStore.save();
    GrowthStore.changes.bump();
    return true;
  }

  static String buildParentDigest() {
    final name =
        GameData.childName.isNotEmpty ? GameData.childName : 'کودک شما';
    final jalali = JalaliDate.today();
    final learn = weekLearningMinutes();
    final fun = weekEntertainmentMinutes();
    final challenge = currentChallenge();
    final weak = AI.weakSkill();
    final rate = GameData.averageSuccessRate.toStringAsFixed(0);
    return '''
گزارش هفتگی جزیره فندقی
تاریخ: ${jalali.format()}
نام: $name  •  سن تقریبی: ${GameData.childAge}

زمان یادگیری این هفته: ${PersianDigits.minutes(learn)}
زمان سرگرمی (کارتون/بازی تند): ${PersianDigits.minutes(fun)}
نسبت یادگیری: ${learn + fun == 0 ? '—' : '${((learn / (learn + fun)) * 100).round()}٪'}

پاسخ درست کل: ${GameData.totalCorrect}
نرخ موفقیت: $rate٪
استریک: ${GameData.streak} روز
چالش هفته «${challenge.title}»: ${GrowthStore.weeklyChallengeProgress}/${challenge.target}

مهارت نیازمند تمرین: $weak
هدف والد: ${GrowthStore.weeklyGoalMinutes} دقیقه یادگیری — ${weeklyGoalMet ? 'انجام شد ✅' : 'هنوز نرسیده'}

پیشنهاد فندقی: اگر تمرینی ثبت شده، امروز همان «$weak» را کوتاه تمرین کنید.
— این گزارش فقط روی همین گوشی ساخته شده و جایی ارسال نمی‌شود.
''';
  }
}
