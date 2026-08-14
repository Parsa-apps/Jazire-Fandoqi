import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🆕 تغییرات نسخه ۶.۲.۱ «جزیره فندقی»
/// بعد از هر آپدیت یک‌بار به‌صورت خودکار نشان داده می‌شود.
/// ═══════════════════════════════════════════════════════════════
class WhatsNew {
  WhatsNew._();

  static const String version = '۶.۲.۱';
  static const String versionName = 'جزیره فندقی';
  static const String buildNumber = '+۱۴';

  /// دسته‌بندی‌های تغییرات برای نمایش حرفه‌ای
  static const List<WhatsNewSection> sections = [
    WhatsNewSection(
      id: 'icon',
      title: 'ظاهر تازهٔ جزیره',
      emoji: '🎨',
      color: Color(0xFF6C5CE7),
      items: [
        WhatsNewItem(
          emoji: '🌴',
          title: 'آیکون جدید اپ',
          body: 'فندقی با یک گردوی سه‌بعدی بامزه روی جزیره‌ای با نخل و بلوک‌های الفبا (ب، ا، پ، ۲، ۳) در کنارتان است.',
        ),
        WhatsNewItem(
          emoji: '🌈',
          title: 'صفحه شروع هماهنگ',
          body: 'صفحهٔ بارگذاری اپ هم با رنگ‌های جدید آبی-آسمانی به‌روزرسانی شد.',
        ),
      ],
    ),
    WhatsNewSection(
      id: 'safety',
      title: 'شفاف‌سازی و امنیت کودک',
      emoji: '🛡️',
      color: Color(0xFF00B894),
      items: [
        WhatsNewItem(
          emoji: '📡',
          title: 'اعلام صریح وضعیت آنلاین/آفلاین',
          body: 'بنری دائمی در بالای کارتون‌کده که منبع پخش (آپارات) و نیاز به اینترنت را شفاف اعلام می‌کند.',
        ),
        WhatsNewItem(
          emoji: '👨‍👩‍👧',
          title: 'اطلاع‌رسانی به والدین در اولین ورود',
          body: 'در اولین مراجعه به کارتون‌کده، دیالوگی برای والدین نمایش داده می‌شود که توضیح می‌دهد کدام بخش‌ها آنلاین هستند و چرا.',
        ),
        WhatsNewItem(
          emoji: '📋',
          title: 'کارت «شفاف‌سازی محتوای آنلاین» در پنل والدین',
          body: 'به‌همراه دکمه‌های گزارش محتوا و نمایش مجدد اطلاعیه، برای مطابقت کامل با آیین‌نامهٔ کافه‌بازار.',
        ),
        WhatsNewItem(
          emoji: '🔒',
          title: 'بروزرسانی سیاست حریم خصوصی',
          body: 'توضیح دقیق دلایل دسترسی اینترنت، فهرست سفید هش‌های آپارات، و نبود تبلیغ/ردیابی/analytics.',
        ),
      ],
    ),
    WhatsNewSection(
      id: 'content',
      title: 'محتوا و تجربهٔ کودک',
      emoji: '🎬',
      color: Color(0xFFFF7675),
      items: [
        WhatsNewItem(
          emoji: '🍿',
          title: 'کارتون‌کده پایدارتر',
          body: 'پخش کارتون‌ها همچنان از سرویس معتبر ایرانی آپارات و فقط از هش‌های تأییدشده؛ بدون جستجوی آزاد، بدون لینک خروجی.',
        ),
        WhatsNewItem(
          emoji: '⭐',
          title: 'سیستم رتبهٔ تماشاگر',
          body: 'از «نوآموز سینما» تا «سلطان کارتون» — با تماشای سالم و آموزنده رتبه بگیرید.',
        ),
      ],
    ),
    WhatsNewSection(
      id: 'promise',
      title: 'تعهد ما به شما',
      emoji: '💛',
      color: Color(0xFFFDCB6E),
      items: [
        WhatsNewItem(
          emoji: '🚫',
          title: 'بدون تبلیغ، بدون ردیابی',
          body: 'هیچ‌گونه تبلیغ شخص ثالث، فایربیس/آنالیتیکس، یا جمع‌آوری اطلاعات کودک در اپ وجود ندارد.',
        ),
        WhatsNewItem(
          emoji: '📴',
          title: 'بیشترِ اپ کاملاً آفلاین',
          body: 'آموزش الفبا و اعداد، بازی‌ها، داستان‌ها، لالایی‌ها، فلش‌کارت‌ها، رنگ‌ها، اشکال و نقاشی — همه بدون اینترنت کار می‌کنند.',
        ),
        WhatsNewItem(
          emoji: '📮',
          title: 'پشتیبانی پاسخ‌گو',
          body: 'اگر محتوای نامناسبی دیدید، از پنل والدین یا تلگرام پشتیبانی گزارش دهید تا در اولین فرصت اصلاح شود.',
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
