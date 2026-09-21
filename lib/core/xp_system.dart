import 'dart:math' as math;

import 'growth/persian_digits.dart';

/// ═══════════════════════════════════════════════════════════════
/// ⭐ سیستم تجربه (XP) — نسخه ۷.۰.۰ «جزیره زنده»
///
/// «سطح جزیره» سنجهٔ واقعی یادگیری است، نه خرج‌کردن سکه:
///  - هر پاسخ درست: +۲ XP
///  - هر تلاش (حتی اشتباه): +۱ XP — تلاش هرگز تنبیه نمی‌شود
///  - تکمیل مرحله: +۱۰ XP | داستان: +۵ | نقاشی: +۳ | لالایی: +۲
///  - پایان هر بازی: +۵
///
/// اصول کودک‌پسند:
///  - XP هرگز کم نمی‌شود (بدون استرس و بدون قمار)
///  - منحنی ملایم: سطح بعدی کمی دورتر است، نه غیرممکن
///  - این کلاس ریاضیات خالص است؛ ثبت و ذخیره در GameData انجام می‌شود
/// ═══════════════════════════════════════════════════════════════
class XpSystem {
  XpSystem._();

  // ── نرخ کسب XP ──────────────────────────────────────────────
  static const int xpPerCorrect = 2;
  static const int xpPerAttempt = 1;
  static const int xpPerStage = 10;
  static const int xpPerStory = 5;
  static const int xpPerDrawing = 3;
  static const int xpPerLullaby = 2;
  static const int xpPerGameFinish = 5;

  /// حداکثر سطح معنادار برای لقب‌ها (بالاتر از این، لقب آخر تکرار می‌شود).
  static const int maxTitledLevel = 9;

  /// کل XP لازم برای «رسیدن» به سطح [level].
  /// سطح ۱ رایگان است؛ سطح ۲ = ۵۰، سطح ۳ = ۱۵۰، سطح ۴ = ۳۰۰، ...
  static int xpToReach(int level) {
    if (level <= 1) return 0;
    // ۲۵ × n × (n−۱) → رشد درجه‌دوِ ملایم و دل‌نشین
    return 25 * level * (level - 1);
  }

  /// سطح فعلی برای مقدار XP داده‌شده (همیشه ≥ ۱).
  static int levelFor(int xp) {
    if (xp < 0) xp = 0;
    // حل معادلهٔ ۲۵·n²−۲۵·n−xp ≤ ۰ → n = (۱+√(۱+۴xp/۲۵))/۲
    final n = (1 + math.sqrt(1 + 4 * xp / 25)) / 2;
    return math.max(1, n.floor());
  }

  /// XP باقیمانده تا سطح بعد.
  static int xpToNextLevel(int xp) {
    final next = levelFor(xp) + 1;
    return math.max(0, xpToReach(next) - xp);
  }

  /// پیشرفت ۰٫٫۱ در سطح فعلی — برای نوار پیشرفت.
  static double progressInLevel(int xp) {
    final level = levelFor(xp);
    final from = xpToReach(level);
    final to = xpToReach(level + 1);
    if (to <= from) return 1;
    return ((xp - from) / (to - from)).clamp(0.0, 1.0);
  }

  /// لقب کودکانهٔ هر سطح — فندقی همراه کودک بزرگ می‌شود.
  static const List<String> _levelTitles = <String>[
    'جوجه فندقی', // ۱
    'فندقی کوچولو', // ۲
    'دوست جزیره', // ۳
    'کاشف کوچک', // ۴
    'سیاح جزیره', // ۵
    'دلیل فندقی', // ۶
    'قهرمان جزیره', // ۷
    'استاد جزیره', // ۸
    'افسانه جزیره', // ۹
  ];

  static String titleForLevel(int level) {
    if (level <= 1) return _levelTitles[0];
    if (level >= _levelTitles.length) return _levelTitles.last;
    return _levelTitles[level - 1];
  }

  /// برای نمایش در UI با ارقام فارسی.
  static String levelLabel(int level) =>
      'سطح ${PersianDigits.toFa(level)} — ${titleForLevel(level)}';
}
