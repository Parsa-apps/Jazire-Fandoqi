import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════
/// 🎶 POEMS DATA — شعرهای کودکانه و ریتمیک جزیره فندقی
///
/// همهٔ شعرها متنِ اورجینالِ کودکانه هستند (نه بازنویسی آثار
/// دارای حق نشر)؛ کوتاه، خوش‌آهنگ و با یک پیام تربیتی نرم.
///
/// صوت:
///   مسیر پیش‌فرض هر شعر `assets/audio/poems/poem_<id>.mp3` است.
///   وقتی فایل ضبط‌شده (خوانش بچگانه) داخل اپ باشد همان پخش می‌شود؛
///   در غیر این صورت صفحهٔ شعر با TTS فارسیِ دستگاه متن را می‌خواند
///   (همان الگوی fallback قصه‌ها). پس هیچ شعری بدون صدا نمی‌ماند.
/// ═══════════════════════════════════════════════════════

class Poem {
  final String id;
  final String title;
  final String subtitle;
  final String coverEmoji;
  final Color themeColor;
  final LinearGradient gradient;

  /// بیت‌ها/خطوط شعر برای نمایش و خوانش.
  final List<String> lines;

  /// پیام کوتاه تربیتی پایین صفحه.
  final String message;

  /// برچسب سنی پیشنهادی (فقط نمایشی).
  final String ageLabel;

  const Poem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverEmoji,
    required this.themeColor,
    required this.gradient,
    required this.lines,
    required this.message,
    this.ageLabel = '۳ تا ۸ سال',
  });

  /// مسیر فایل خوانش ضبط‌شده — اگر وجود نداشته باشد صفحه از TTS استفاده می‌کند.
  String get audioAsset => 'assets/audio/poems/poem_$id.mp3';

  /// متن کامل برای خوانش TTS (بدون خط خالی، با مکث کوتاه بین خطوط).
  String get spokenText => lines.where((line) => line.trim().isNotEmpty).join('. ');
}

class PoemsData {
  static const List<Poem> all = <Poem>[
    Poem(
      id: 'ball',
      title: 'توپ قلقلی',
      subtitle: 'بازی و تحرک، شادی بچه‌ها',
      coverEmoji: '⚽',
      themeColor: Color(0xFF2E7D32),
      gradient: LinearGradient(
        colors: [Color(0xFF1B5E20), Color(0xFF81C784)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      lines: <String>[
        'توپ قلقلی، گرد و قشنگ',
        'روی زمین، می‌زنی قشنگ',
        'یک بزنم، هوا بری',
        'تو بچرخی، من بپرم',
        'بازی با تو، خنده داره',
        'سالم و شاد، می‌مونه یار',
      ],
      message: 'بازی و تحرک روزانه، بدن را قوی و دل را شاد می‌کند.',
    ),
    Poem(
      id: 'rain',
      title: 'باران بهاری',
      subtitle: 'صدای نرم باران و سبزی طبیعت',
      coverEmoji: '🌧️',
      themeColor: Color(0xFF0277BD),
      gradient: LinearGradient(
        colors: [Color(0xFF01579B), Color(0xFF4FC3F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      lines: <String>[
        'نم نم بارون، می‌باره',
        'روی گل‌ها، می‌چکه',
        'ابر سفید، گریه می‌کنه',
        'باغچه‌ها رو، سیراب می‌کنه',
        'قطره قطره، دونه دونه',
        'سبز می‌شه، هر دونه',
      ],
      message: 'آب باران هدیه‌ای است که به گل‌ها و درختان زندگی می‌بخشد.',
    ),
    Poem(
      id: 'cat',
      title: 'گربه کوچولو',
      subtitle: 'مهربانی با حیوان‌ها',
      coverEmoji: '🐱',
      themeColor: Color(0xFFEF6C00),
      gradient: LinearGradient(
        colors: [Color(0xFFE65100), Color(0xFFFFCC80)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      lines: <String>[
        'گربه نازم، میو میو',
        'پنجه نرم، مو به مو',
        'می‌پره آروم، از دیوار',
        'می‌نشینه، کنار یار',
        'یک کاسه شیر، براش بذار',
        'نوازشش کن، بی‌آزار',
      ],
      message: 'با حیوان‌ها مهربان باشیم و از غذا و آب مواظبتشان کنیم.',
    ),
    Poem(
      id: 'mother',
      title: 'دست‌های مادر',
      subtitle: 'سپاس از مهر مادر',
      coverEmoji: '💐',
      themeColor: Color(0xFFC2185B),
      gradient: LinearGradient(
        colors: [Color(0xFF880E4F), Color(0xFFF48FB1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      lines: <String>[
        'دست مادر، مثل گل',
        'گرم و نرم، مثل دل',
        'می‌کشه دستم، رو سرِ من',
        'می‌خونه قصه، برای من',
        'ممنونم، ای مادرِ من',
        'بهترینی، در کل جهان',
      ],
      message: 'سپاس‌گزاری از مهر مادر و پدر، از اولین خوبی‌های کودکی است.',
    ),
    Poem(
      id: 'star',
      title: 'ستاره‌ها',
      subtitle: 'نشانه‌های زیبای آسمان شب',
      coverEmoji: '⭐',
      themeColor: Color(0xFF5E35B1),
      gradient: LinearGradient(
        colors: [Color(0xFF311B92), Color(0xFF9575CD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      lines: <String>[
        'شده شب، آسمان تیره',
        'ستاره‌ها، هر یکی چیره',
        'چشمک می‌زنن، از دور',
        'مثل چراغ، روی بلور',
        'ماه هم، اومده بالا',
        'شب قشنگه، با این‌ها',
      ],
      message: 'آسمان شب پر از نشانه‌های زیباست؛ کنجکاوی‌ات را حفظ کن.',
    ),
    Poem(
      id: 'spring',
      title: 'بهار آمد',
      subtitle: 'نو شدن طبیعت و شکوفه‌ها',
      coverEmoji: '🌸',
      themeColor: Color(0xFFD81B60),
      gradient: LinearGradient(
        colors: [Color(0xFFAD1457), Color(0xFFF8BBD0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      lines: <String>[
        'بهار اومد، خوش اومد',
        'سرما رفت، گل در اومد',
        'درختا، شکوفه کردن',
        'پرستوها، برگشتن',
        'بوی خاک، توی هوا',
        'شادی اومده، همه‌جا',
      ],
      message: 'هر بهار یادآور شروع دوباره و زیبایی طبیعت است.',
    ),
    Poem(
      id: 'butterfly',
      title: 'پروانه رنگی',
      subtitle: 'آزادی و لطافت پرواز',
      coverEmoji: '🦋',
      themeColor: Color(0xFF00838F),
      gradient: LinearGradient(
        colors: [Color(0xFF006064), Color(0xFF80DEEA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      lines: <String>[
        'پروانه، با بال رنگی',
        'می‌پره، شاد و قشنگی',
        'روی گل، می‌شینه آروم',
        'می‌چشه، شهد گلون',
        'بال‌هات، نقاشی‌ان',
        'لطیف و نرم، مثل بارون',
      ],
      message: 'موجودات ظریف را با احتیاط نگاه کنیم؛ طبیعت امانت است.',
    ),
    Poem(
      id: 'fandoghi',
      title: 'فندقی شاد',
      subtitle: 'یادگیری در کنار دوست فندقی',
      coverEmoji: '🌰',
      themeColor: Color(0xFFF57C00),
      gradient: LinearGradient(
        colors: [Color(0xFFE65100), Color(0xFFFFB74D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      lines: <String>[
        'فندقی، دوست کوچیک',
        'هم‌بازی، هم درس و فیک',
        'با هم حرف، یاد می‌گیریم',
        'شعر و قصه، می‌گیریم',
        'هر روز، یک چیزِ نو',
        'شاد و خندون، پیش همو',
      ],
      message: 'یادگیری وقتی شاد باشد، هیچ‌وقت فراموش نمی‌شود.',
    ),
  ];

  static Poem? byId(String id) {
    for (final poem in all) {
      if (poem.id == id) return poem;
    }
    return null;
  }
}
