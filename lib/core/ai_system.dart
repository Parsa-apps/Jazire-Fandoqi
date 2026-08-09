import 'dart:math';

import 'game_data.dart';

/// ────────────────────────────────────────────────────────────
/// 🤖 فاز ۴۱-۵۰: موتور هوش مصنوعی آفلاین
///
/// - تخمین مهارت با استنتاج بیزین ساده (آلفا-بتا)
/// - سختی تطبیقی (فاز ۴۲): ۳ درست → سخت‌تر، ۲ غلط → آسان‌تر
/// - تشخیص خستگی/ناراحتی (فاز ۴۵) و ضد اعتیاد (فاز ۵۰)
/// - پیشنهاد ۳ بازی روزانه بر اساس مهارت ضعیف (فاز ۴۶)
/// - همه‌چیز on-device؛ هیچ دیتایی خارج نمی‌شود (فاز ۴۹)
/// ────────────────────────────────────────────────────────────
class AI {
  /// آلفا/بتای اولیه — وقتی کودک تازه شروع کرده، همه مهارت‌ها
  /// برابر «متوسط» تخمین زده می‌شوند نه صفر.
  static const double _alpha0 = 4.0;
  static const double _beta0 = 4.0;

  static double _skillMean(int correctCount) {
    // میانگین توزیع Beta(α₀+success, β₀) برای هر مهارت؛
    // شکست‌ها به‌صورت سراسری (successRate) لحاظ می‌شوند.
    final alpha = _alpha0 + correctCount;
    final beta = _beta0;
    return alpha / (alpha + beta);
  }

  /// احتمال تسلط کودک روی یک مهارت (۰..۱).
  static double masteryOf(String skill) {
    final count = GameData.skills[skill] ?? 0;
    return _skillMean(count);
  }

  static int difficulty() {
    if (GameData.successRate > 0.8) return 3;
    if (GameData.successRate > 0.5) return 2;
    return 1;
  }

  static String diffName() {
    switch (difficulty()) {
      case 3:
        return 'سخت';
      case 2:
        return 'متوسط';
      default:
        return 'آسان';
    }
  }

  /// فاز ۴۲: سختی تطبیقی دور بعدی.
  /// `recentCorrect` = درست‌های متوالی اخیر؛ `recentWrong` = غلط‌های متوالی.
  static int adaptiveLevel({int recentCorrect = 0, int recentWrong = 0}) {
    if (recentWrong >= 2) return max(1, difficulty() - 1);
    if (recentCorrect >= 3) return min(3, difficulty() + 1);
    return difficulty();
  }

  static String mascotMsg() {
    if (GameData.totalCorrect == 0) return 'سلام! بیا بازی کنیم! 🎮';
    if (GameData.successRate > 0.8) return 'آفرین نابغه! 🌟';
    if (GameData.successRate > 0.5) return 'ادامه بده عالی می‌شی! 💪';
    return 'اشکال نداره! تمرین کن! 🎯';
  }

  static String weakSkill() {
    final sorted = GameData.skills.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final names = skillNames;
    return names[sorted.first.key] ?? 'همه';
  }

  static String weakSkillKey() {
    final sorted = GameData.skills.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.first.key;
  }

  static const Map<String, String> skillNames = {
    'math': 'ریاضی',
    'alphabet': 'الفبا',
    'memory': 'حافظه',
    'colors': 'رنگ‌ها',
    'shapes': 'اشکال',
    'animals': 'حیوانات',
    'counting': 'شمارش',
    'pattern': 'الگو',
    'fruits': 'میوه‌ها',
    'concepts': 'مفاهیم',
    'vocab': 'لغات',
    'body': 'بدن',
    'vehicles': 'وسایل نقلیه',
    'time': 'زمان',
    'weather': 'آب و هوا',
    'emotions': 'احساسات',
    'jobs': 'شغل‌ها',
  };

  static const Map<String, String> _gameBySkill = {
    'math': 'مسابقه',
    'alphabet': 'الفبا',
    'memory': 'حافظه',
    'colors': 'رنگ‌ها',
    'shapes': 'اشکال',
    'animals': 'حیوانات',
    'counting': 'اعداد',
    'pattern': 'الگو',
    'fruits': 'میوه‌ها',
    'concepts': 'مفاهیم',
    'vocab': 'حیوانات',
    'body': 'بدن',
    'emotions': 'احساسات',
    'jobs': 'شغل‌ها',
  };

  static bool fatigued(int mistakes, Duration time) =>
      mistakes > 5 && time.inMinutes > 15;

  // ───────────── فاز ۴۵: تشخیص احساس کودک ─────────────

  /// اگر کودک پشت سر هم غلط زده، پیام «بریم بازی آسون‌تر» به‌جای سرزنش.
  static String encouragementAfterMistakes(int consecutiveWrong) {
    if (consecutiveWrong <= 0) return '';
    if (consecutiveWrong == 1) {
      return 'اشکال نداره! همین نزدیکی بود؛ یک بار دیگر 🌱';
    }
    if (consecutiveWrong == 2) {
      return 'بیا با هم یک بازی آسون‌تر امتحان کنیم؛ تمرین، تو را قوی می‌کند 💪';
    }
    return 'همه چیز خوب است عزیزم؛ یک نفس عمیق و دوباره 🌈';
  }

  /// آیا کودک ناراحت/خسته است؟ (برای فاز ۵۰)
  static bool needsBreak() {
    if (GameData.isDailyLimitReached) return true;
    return GameData.todayPlaySeconds > 20 * 60; // ۲۰ دقیقه بی‌وقفه
  }

  // ───────────── فاز ۴۶: پیشنهاد بازی هوشمند ─────────────

  /// سه بازی پیشنهادی امروز: ضعیف‌ترین مهارت + دو مهارت تصادفی
  /// از بازی‌های اخیراً کمتر انجام‌شده.
  static List<String> suggestGames() {
    final suggestions = <String>[];
    final weak = weakSkillKey();
    suggestions.add(_gameBySkill[weak] ?? 'الفبا');
    final pool = _gameBySkill.values.toSet()..remove(suggestions.first);
    final played = GameData.playedGames.toSet();
    final unplayed = pool.where((g) => !played.contains(g)).toList();
    final rng = Random();
    while (suggestions.length < 3 && (unplayed.isNotEmpty || pool.isNotEmpty)) {
      final source = unplayed.isNotEmpty ? unplayed : pool.toList();
      final pick = source[rng.nextInt(source.length)];
      if (!suggestions.contains(pick)) suggestions.add(pick);
      unplayed.remove(pick);
    }
    return suggestions;
  }

  /// فاز ۴۷: پیش‌بینی یک ماه آینده (روند ساده با شیب مهارت‌ها).
  static Map<String, double> predictOneMonth() {
    final result = <String, double>{};
    GameData.skills.forEach((key, value) {
      final progress = value >= 10 ? 0.9 : value / 10;
      result[skillNames[key] ?? key] = (progress * 100).clamp(5.0, 98.0);
    });
    return result;
  }

  /// فاز ۴۸: پاسخ دوست خیالی — گفتگوی ساده قانون‌محور (Rule-based).
  static String buddyReply(String input, {required String childName}) {
    final text = input.trim();
    final name = childName.isNotEmpty ? childName : 'دوست من';
    if (text.isEmpty) return 'سلام $name! من فندقی‌ام؛ حرف بزن تا گوش بدهم 🌰';
    if (text.contains('سلام') || text.contains('درود')) {
      return 'سلام $name! چه حالی داری امروز؟ 😊';
    }
    if (text.contains('خوبم') || text.contains('خوب')) {
      return 'چه عالی! من هم امروز خیلی شادم 🎉';
    }
    if (text.contains('خستم') || text.contains('خسته')) {
      return 'بیا یک کم استراحت کنیم؛ حتی قهرمان‌ها هم استراحت لازم دارند 😴';
    }
    if (text.contains('بازی') || text.contains('بازی کنیم')) {
      return 'ایده عالی! من مسابقه و حباب‌ترکان را خیلی دوست دارم؛ تو کدام را بیشتر دوست داری؟ 🎮';
    }
    if (text.contains('غمگین') || text.contains('ناراحت')) {
      return 'ناراحتی اشکالی ندارد $name؛ من کنارت هستم و یک قصه بامزه بلدم. بخواهی برایت می‌گویم 📖';
    }
    if (text.contains('متشکرم') || text.contains('مرسی')) {
      return 'خواهش می‌کنم! دوستی با تو برای من لذت‌بخش است 🤗';
    }
    if (text.contains('خداحافظ') || text.contains('بای')) {
      return 'خداحافظ $name! فردا دوباره با هم بازی می‌کنیم؛ منتظرتم 🌙';
    }
    if (text.contains('چیست') || text.contains('چیه')) {
      return 'سوال خوبی است! اگر بخواهی می‌توانیم با هم جوابش را پیدا کنیم 🔍';
    }
    return 'جالبه $name! بیشتر برام تعریف کن؛ من عاشق گوش دادن هستم 👂';
  }
}
