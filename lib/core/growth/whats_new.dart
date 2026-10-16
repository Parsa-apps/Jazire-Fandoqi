import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🆕 تغییرات نسخهٔ ۷.۵.۲ «قفل‌های طلایی متحرک» — جزیره فندقی
/// بعد از هر آپدیت یک‌بار به‌صورت خودکار نشان داده می‌شود.
/// ═══════════════════════════════════════════════════════════════
class WhatsNew {
  WhatsNew._();

  static const String version = '۷.۵.۲';
  static const String versionName = 'قفل‌های طلایی متحرک';
  static const String buildNumber = '+۲۴';

  /// دسته‌بندی‌های تغییرات برای نمایش حرفه‌ای
  static const List<WhatsNewSection> sections = [
    WhatsNewSection(
      id: 'animated-gold-locks',
      title: '🔐 قفل‌های طلایی متحرک',
      emoji: '🔐',
      color: Color(0xFFD99415),
      items: [
        WhatsNewItem(
          emoji: '✨',
          title: 'قفل‌های براق روی بخش‌های نسخهٔ کامل',
          body: 'بخش‌های قفل حالا یک قفل طلایی با حرکت آرام و برق ملایم دارند؛ لمس همان بخش، مسیر امن خرید والدین را باز می‌کند.',
        ),
        WhatsNewItem(
          emoji: '💛',
          title: 'سبک، آفلاین و سازگار با کاهش حرکت',
          body: 'قفل‌ها بدون دانلود تصویر کار می‌کنند و با فعال‌بودن کاهش حرکت ثابت می‌مانند. قانون نیمهٔ رایگان و بازشدن پس از پرداخت معتبر تغییری نکرده است.',
        ),
      ],
    ),
    WhatsNewSection(
      id: 'payment-lock-fix',
      title: '🔒 اصلاح قفل‌های پرداخت',
      emoji: '🔒',
      color: Color(0xFF5D4037),
      items: [
        WhatsNewItem(
          emoji: '🔤',
          title: 'قفل واقعی بسته‌ها و جست‌وجوی الفبا',
          body: 'چهار بستهٔ اول رایگان است و چهار بستهٔ بعدی با نسخهٔ کامل باز می‌شود؛ جست‌وجو و مرور هم قفل را دور نمی‌زنند.',
        ),
        WhatsNewItem(
          emoji: '🧍',
          title: 'بدن و حواس هم نیمه‌رایگان شد',
          body: 'سه عضو رایگان و سه عضو با نسخهٔ کامل؛ قفل‌ها از ابتدا دیده می‌شوند و پس از تأیید پرداخت برداشته می‌شوند.',
        ),
        WhatsNewItem(
          emoji: '🛡️',
          title: 'بدون خرید آزمایشی خودکار',
          body: 'فلگ‌های قدیمیِ آزمایشی دیگر دسترسی نمی‌دهند. خرید واقعیِ قبلی با بازیابی فروشگاه حفظ می‌شود و پیشرفت کودک پاک نمی‌شود.',
        ),
      ],
    ),
    WhatsNewSection(
      id: 'fair-access',
      title: '⚖️ هر بخش نیمه رایگان، نیمه نسخهٔ کامل',
      emoji: '⚖️',
      color: Color(0xFF7E57C2),
      items: [
        WhatsNewItem(
          emoji: '🔓',
          title: 'نیمهٔ اول هر مجموعه همیشه رایگان',
          body: 'قصه‌ها، لالایی‌ها، کارتون‌ها، اعداد، حیوانات، شغل‌ها، مفاهیم، احساسات و مهارت زندگی: نیمهٔ اول هر کدام را می‌توانی بدون هیچ پرداختی ببینی و بازی کنی.',
        ),
        WhatsNewItem(
          emoji: '🔒',
          title: 'نیمهٔ دوم با یک خرید همیشگی',
          body: 'نیمهٔ دوم هر مجموعه با یک خریدِ یک‌باره باز می‌شود. روی هر آیتمِ قفل‌شده یک نشانِ کوچک قفل می‌بینی، پس همیشه می‌دانی چه چیزی با خرید باز می‌شود.',
        ),
        WhatsNewItem(
          emoji: '🛡️',
          title: 'رفع یک نشتِ مهم',
          body: 'در نسخه‌های قبل، نیمهٔ پولیِ «مهارت زندگی» بدون پرداخت باز می‌ماند. این راه کاملاً بسته شد و همهٔ بخش‌ها حالا فقط از یک درِ یکپارچه اجازه می‌گیرند.',
        ),
      ],
    ),
    WhatsNewSection(
      id: 'half-collections',
      title: '🦁 مجموعه‌های تازه‌نیمه‌شده',
      emoji: '🦁',
      color: Color(0xFF26A69A),
      items: [
        WhatsNewItem(
          emoji: '🐾',
          title: 'حیوانات ایران: ۱۵ از ۳۰ رایگان',
          body: 'دایرةالمعارف حیوانات حالا از ابتدا باز است و نیمهٔ اولش رایگان قابل تماشاست؛ بقیه با نسخهٔ کامل.',
        ),
        WhatsNewItem(
          emoji: '👷',
          title: 'شغل‌ها ۱۰ از ۲۰ · مفاهیم ۸ از ۱۶',
          body: 'این دو دنیا هم نیمه‌نیمه شدند: اول رایگان امتحان کن، بعد اگر خواستی همه را باز کن.',
        ),
        WhatsNewItem(
          emoji: '🔤',
          title: 'الفبا دو برابر رایگان شد',
          body: 'در الفبای کلاس‌اول به‌جای ۲ بسته، حالا ۴ بسته از ۸ بسته رایگان است؛ در حالت الفبای سنتی هم ۱۶ نشانه از ۳۳.',
        ),
      ],
    ),
    WhatsNewSection(
      id: 'trust',
      title: '🛡️ امنیت و اطمینانِ پرداخت',
      emoji: '🛡️',
      color: Color(0xFF42A5F5),
      items: [
        WhatsNewItem(
          emoji: '🏪',
          title: 'فقط تأییدِ فروشگاه باز می‌کند',
          body: 'هیچ بخش پولی بدون تأییدِ رسمیِ فروشگاه باز نمی‌شود؛ اگر پاسخِ فروشگاه نرسد، بخش پولی قفل می‌ماند تا اشتباهی چیزی رایگان نماند.',
        ),
        WhatsNewItem(
          emoji: '👨‍👩‍👧',
          title: 'خرید فقط برای مامان و بابا',
          body: 'پیامِ خرید پشتِ درِ والدین است و کودک به‌تنهایی نمی‌تواند خریدی انجام بدهد.',
        ),
        WhatsNewItem(
          emoji: '📵',
          title: 'همان قولِ همیشگی',
          body: 'بدون تبلیغ، بدون ردیابی، بدون ارسال دادهٔ کودک — ۱۰۰٪ آفلاین (به‌جز کارتون‌ها با اعلام شفاف).',
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
