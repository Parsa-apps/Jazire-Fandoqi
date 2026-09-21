import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🆕 تغییرات نسخه ۷.۰.۰ «جزیره زنده» — جزیره فندقی
/// بعد از هر آپدیت یک‌بار به‌صورت خودکار نشان داده می‌شود.
/// ═══════════════════════════════════════════════════════════════
class WhatsNew {
  WhatsNew._();

  static const String version = '۷.۰.۰';
  static const String versionName = 'جزیره زنده';
  static const String buildNumber = '+۲۰';

  /// دسته‌بندی‌های تغییرات برای نمایش حرفه‌ای
  static const List<WhatsNewSection> sections = [
    WhatsNewSection(
      id: 'carnival',
      title: '🎪 شهر بازی‌های تازه',
      emoji: '🎪',
      color: Color(0xFF00BCD4),
      items: [
        WhatsNewItem(
          emoji: '🎉',
          title: '۱۰ بازی آموزشی جدید',
          body: 'حرف اول، کلمه‌ساز، شمارش خوش، جمع تصویری، بزرگ و کوچک، جورچین شکل‌ها، ترکیب رنگ، ترتیب اعداد، متفاوت را پیدا کن و سبد دسته‌بندی.',
        ),
        WhatsNewItem(
          emoji: '🏕️',
          title: 'سکوی جدید روی نقشهٔ جزیره',
          body: 'چادر رنگرنگ کارناوال کنار لالایی روی جزیره ساخته شد؛ لمسش کن و وارد شهر بازی‌های تازه شو!',
        ),
        WhatsNewItem(
          emoji: '💡',
          title: 'راهنمای مهربان در بازی‌ها',
          body: 'اگر چند ثانیه معطل بمانی، فندقی یک راهنمای ظریف نشان می‌دهد؛ و اشتباه فقط یعنی «تقریباً! دوباره امتحان کنیم 😊».',
        ),
      ],
    ),
    WhatsNewSection(
      id: 'progress',
      title: '⭐ سطح جزیره؛ پیشرفت واقعی',
      emoji: '⭐',
      color: Color(0xFFFDCB6E),
      items: [
        WhatsNewItem(
          emoji: '🐿️',
          title: 'سیستم تجربه (XP) و سطح جزیره',
          body: 'از این نسخه هر یادگیری، بازی و تلاش «تجربه» می‌آورد: از «جوجه فندقی» تا «افسانه جزیره». پیشرفت قبلی‌ات هم با افتخار منتقل شد!',
        ),
        WhatsNewItem(
          emoji: '🏅',
          title: 'مدال‌های جدید',
          body: 'کاشف جزیره، استاد اعداد، استاد کلمه‌ها، استاد شکل‌ها، استاد رنگ‌ها، کارآگاه کوچک و استاد منطق به جعبهٔ مدال‌ها اضافه شدند.',
        ),
        WhatsNewItem(
          emoji: '🎯',
          title: 'مأموریت‌های روزانهٔ بیشتر',
          body: 'سه مأموریت تازه: «کلمه بساز»، «بشمار و مرتب کن» و «کارآگاه منطق باش».',
        ),
      ],
    ),
    WhatsNewSection(
      id: 'island',
      title: '🌅 جزیرهٔ زنده‌تر',
      emoji: '🌅',
      color: Color(0xFFE17055),
      items: [
        WhatsNewItem(
          emoji: '🌇',
          title: 'غروب طلایی جزیره',
          body: 'چرخهٔ روز جزیره چهار فاز شد: صبح، ظهر، غروب طلایی و شب؛ آسمان و خورشید نرم و آرام تغییر می‌کنند.',
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
