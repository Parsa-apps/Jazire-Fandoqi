import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🆕 تغییرات نسخهٔ ۷.۱.۰ «گواهی افتخار و شفافیت آنلاین» — جزیره فندقی
/// بعد از هر آپدیت یک‌بار به‌صورت خودکار نشان داده می‌شود.
/// ═══════════════════════════════════════════════════════════════
class WhatsNew {
  WhatsNew._();

  static const String version = '۷.۱.۰';
  static const String versionName = 'گواهی افتخار و شفافیت آنلاین';
  static const String buildNumber = '+۲۱';

  /// دسته‌بندی‌های تغییرات برای نمایش حرفه‌ای
  static const List<WhatsNewSection> sections = [
    WhatsNewSection(
      id: 'certificates',
      title: '📜 گواهی افتخار نقاط عطف سطح جزیره',
      emoji: '📜',
      color: Color(0xFFFDCB6E),
      items: [
        WhatsNewItem(
          emoji: '🎉',
          title: 'گواهی لقب‌های بزرگ',
          body: 'رسیدن به «دوست جزیره» (سطح ۳)، «سیاح جزیره» (سطح ۵)، «قهرمان جزیره» (سطح ۷) و «افسانه جزیره» (سطح ۹) حالا هرکدام یک گواهی افتخار با نام خودت باز می‌کند.',
        ),
        WhatsNewItem(
          emoji: '🖼️',
          title: 'جشن لحظهٔ رسیدن',
          body: 'درست وقتی به نقطهٔ عطف می‌رسی، گواهی‌ات با جشن نمایش داده می‌شود؛ متن گواهی را می‌شود برای استوری خانواده کپی کرد.',
        ),
        WhatsNewItem(
          emoji: '🏅',
          title: 'همه در کارنامهٔ افتخار',
          body: 'گواهی‌های جدید در کنار مدال‌ها در بخش «گواهی‌های افتخار» کارنامه جمع می‌شوند و همیشه قابل مشاهده‌اند.',
        ),
      ],
    ),
    WhatsNewSection(
      id: 'online-gate',
      title: '🌐 شفافیت آنلاین کارتون‌کده',
      emoji: '🌐',
      color: Color(0xFF29B6F6),
      items: [
        WhatsNewItem(
          emoji: '🚪',
          title: 'اعلان شفاف پیش از ورود',
          body: 'کارتون‌کده تنها بخش آنلاین بازی است؛ حالا قبل از ورود، یک اعلان شفاف نشان داده می‌شود که برای تماشا اینترنت لازم است.',
        ),
        WhatsNewItem(
          emoji: '🏝️',
          title: 'بازگشت آسان به جزیره',
          body: 'تا تأیید نکنی هیچ محتوای آنلاین باز نمی‌شود و «بازگشت به جزیرهٔ آفلاین» همیشه فقط یک لمس دور است.',
        ),
        WhatsNewItem(
          emoji: '📵',
          title: 'بدون تبلیغ، بدون ردیابی',
          body: 'پخش کارتون فقط از آپارات با فهرست سفید تأییدشده انجام می‌شود؛ بقیهٔ جزیره همیشه ۱۰۰٪ آفلاین می‌ماند.',
        ),
      ],
    ),
  ];
}

/// ───────────────────────────────────────────────────────────────
/// مدل داده
/// ───────────────────────────────────────────────────────────────
class WhatsNewSection {
  final String id;
  final String title;
  final String emoji;
  final Color color;
  final List<WhatsNewItem> items;
  const WhatsNewSection({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    required this.items,
  });
}

class WhatsNewItem {
  final String emoji;
  final String title;
  final String body;
  const WhatsNewItem({
    required this.emoji,
    required this.title,
    required this.body,
  });
}
