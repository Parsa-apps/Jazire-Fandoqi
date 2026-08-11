import 'dart:math';

import 'game_data.dart';

/// ═══════════════════════════════════════════════════════════
/// 🩺 PARENTAL HEALTH & SAFETY RADAR — رادار سلامت و ایمنی کودک
/// پیشنهاد جدید شماره ۵ — مانیتورینگ بهداشت چشم و زمان استفاده
/// ═══════════════════════════════════════════════════════════
class ParentalHealthRadar {
  ParentalHealthRadar._();

  /// بررسی لزوم استراحت چشم (قانون ۲۰-۲۰-۲۰: هر ۲۰ دقیقه بازی)
  static bool get needsEyeRest {
    final playSeconds = GameData.todayPlaySeconds;
    return playSeconds > 0 && (playSeconds % 1200 < 30);
  }

  /// دریافت پیام توصیه سلامت برای والدین
  static String getHealthRecommendation() {
    final minutes = GameData.todayPlayMinutes;
    if (minutes > 60) {
      return 'کودک شما امروز بیش از ۱ ساعت بازی کرده است. توصیه می‌شود کمی فعالیت بدنی یا بازی در فضای باز داشته باشد 🌳';
    } else if (minutes > 30) {
      return 'زمان بازی امروز در حد ایده‌آل است. برای سلامت چشم، استراحت کوتاه پیشنهاد می‌شود 👀';
    } else {
      return 'زمان استفاده امروز عالی و کاملاً مناسب سن کودک است ⭐';
    }
  }

  /// امتیاز سلامت و تعادل بازی (از ۱۰۰)
  static int getHealthScore() {
    final minutes = GameData.todayPlayMinutes;
    if (minutes <= 30) return 100;
    if (minutes <= 60) return 85;
    if (minutes <= 90) return 65;
    return max(40, 100 - (minutes - 30));
  }
}
