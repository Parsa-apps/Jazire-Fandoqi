import 'package:flutter/material.dart';

/// ────────────────────────────────────────────────────────────
/// 🌍 فاز ۷۹: رشته‌های چندزبانه پنهان (آماده‌سازی نسخه بین‌المللی
/// «Kids of Persia»). فعلاً فقط فارسی فعال است؛ انگلیسی مخفی
/// نگه داشته شده تا بعداً بدون بازنویسی UI فعال شود.
/// ────────────────────────────────────────────────────────────
class AppStrings {
  AppStrings._();

  static const Map<String, String> _fa = <String, String>{
    'appTitle': 'آموزش فندقی',
    'appTagline': 'یادگیری شاد برای کودکان ایران',
    'home': 'خانه',
    'island': 'جزیره',
    'map': 'نقشه',
    'shop': 'فروشگاه',
    'profile': 'پروفایل',
    'play': 'بازی',
    'back': 'برگشت',
    'retry': 'دوباره',
    'wellDone': 'آفرین!',
    'tryAgain': 'اشکال نداره، دوباره تلاش کن',
  };

  static const Map<String, String> _en = <String, String>{
    'appTitle': 'Kids of Persia',
    'appTagline': 'Joyful learning for Persian children',
    'home': 'Home',
    'island': 'Island',
    'map': 'Map',
    'shop': 'Shop',
    'profile': 'Profile',
    'play': 'Play',
    'back': 'Back',
    'retry': 'Retry',
    'wellDone': 'Well done!',
    'tryAgain': "It's okay, try again",
  };

  /// زبان فعال — تا فاز بین‌المللی فقط fa.
  static String get activeLocale => 'fa';

  static String t(String key) {
    final table = activeLocale == 'en' ? _en : _fa;
    return table[key] ?? key;
  }

  /// نمونه استفاده در Text: `Text(AppStrings.t('home'))`
  static String of(BuildContext context, String key) => t(key);
}
