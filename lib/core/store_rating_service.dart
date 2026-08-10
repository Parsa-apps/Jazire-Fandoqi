import 'package:flutter/foundation.dart';
import '../data/datasources/hive_player_store.dart';
import 'billing_service.dart';
import 'game_data.dart';

/// ⭐ سرویس امتیازدهی هوشمند — پیشنهاد پریمیوم ۴۸
/// فقط بعد از ۳ برد + ۷ روز استفاده + حداکثر ۲ بار در ماه درخواست می‌دهد
/// هرگز اول بازی یا هنگام باخت مزاحم کودک/والد نمی‌شود.
class StoreRatingService {
  static const String _keyLastPrompt = 'rating_last_prompt_ms';
  static const String _keyPromptCount = 'rating_prompt_count';
  static const String _keyHasRated = 'rating_has_rated';

  /// آیا الان زمان مناسبی برای درخواست امتیاز است؟
  static Future<bool> shouldPrompt() async {
    // اگر قبلاً ۵ ستاره داده، دیگر نپرس
    final hasRated = await HivePlayerStore.readValue(_keyHasRated) as bool? ?? false;
    if (hasRated) return false;

    // فقط بعد از ۳ برد
    if (GameData.playedGames.length < 3) return false;

    // فقط بعد از ۳ روز از نصب (ساده: streak >= 2 یا playedGames >= 3)
    if (GameData.streak < 2 && GameData.playedGames.length < 5) return false;

    // حداکثر هر ۱۴ روز یک بار
    final lastMs = await HivePlayerStore.readValue(_keyLastPrompt) as int? ?? 0;
    if (lastMs > 0) {
      final daysSince = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastMs)).inDays;
      if (daysSince < 14) return false;
    }

    // حداکثر ۳ بار کلاً
    final count = await HivePlayerStore.readValue(_keyPromptCount) as int? ?? 0;
    if (count >= 3) return false;

    return true;
  }

  /// ثبت نمایش درخواست
  static Future<void> markPrompted() async {
    final count = await HivePlayerStore.readValue(_keyPromptCount) as int? ?? 0;
    await HivePlayerStore.writeValue(_keyPromptCount, count + 1);
    await HivePlayerStore.writeValue(_keyLastPrompt, DateTime.now().millisecondsSinceEpoch);
  }

  /// کاربر امتیاز داد
  static Future<void> markRated() async {
    await HivePlayerStore.writeValue(_keyHasRated, true);
  }

  /// درخواست امتیاز فقط در زمان طلایی
  static Future<bool> tryPromptIfEligible() async {
    if (!await shouldPrompt()) return false;
    await markPrompted();
    // باز کردن صفحه کافه‌بازار
    try {
      await BillingService.openBazaarReview();
      return true;
    } catch (_) {
      return false;
    }
  }
}
