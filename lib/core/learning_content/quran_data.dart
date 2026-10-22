import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════
/// 🕌 QURAN DATA — قرآن کودک: سوره‌های کوتاه جزء ۳۰
///
/// متن عربی با اعراب کامل و معنی ساده و کودک‌فهم فارسی برای
/// هر آیه. تلاوت فقط از فایل‌های ضبط‌شدهٔ رسمی پخش می‌شود:
///   assets/audio/quran/quran_<id>.mp3
///
/// ⚠️ خط‌مشی صوتی: برخلاف شعر، برای متن عربیِ قرآن هرگز به
/// TTS دستگاه نمی‌افتیم (تلفظ نادرستِ اعراب و لحن نامناسب
/// مجاز نیست). اگر فایل تلاوت هنوز داخل اپ نباشد، صفحه متن و
/// معنی را نشان می‌دهد و دکمهٔ صدا وضعیت «به‌زودی» می‌گیرد.
/// ═══════════════════════════════════════════════════════

class SurahVerse {
  /// متن عربی اعراب‌دار آیه.
  final String arabic;

  /// معنی ساده و کودک‌فهم فارسی.
  final String meaning;

  const SurahVerse({required this.arabic, required this.meaning});
}

class Surah {
  final String id;

  /// نام عربی سوره (مثلاً سُورَةُ الإِخْلَاص).
  final String arabicName;

  /// نام فارسی سوره.
  final String persianName;

  /// مکی یا مدنی.
  final String revelation;

  final String coverEmoji;
  final Color themeColor;
  final LinearGradient gradient;

  /// آیه‌ها (به ترتیب، بدون بسمهٔ سرصفحه).
  final List<SurahVerse> verses;

  /// آیا بسمه به‌صورت سرصفحهٔ جدا نشان داده شود؟
  /// در فاتحه بسمه خودش آیهٔ اول است؛ پس سرصفحه ندارد.
  final bool showBasmalaHeader;

  const Surah({
    required this.id,
    required this.arabicName,
    required this.persianName,
    required this.revelation,
    required this.coverEmoji,
    required this.themeColor,
    required this.gradient,
    required this.verses,
    this.showBasmalaHeader = true,
  });

  /// بسمه‌الله الرحمن الرحیم برای سرصفحهٔ سوره‌ها.
  static const String basmala = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  int get verseCount => verses.length;

  /// مسیر فایل تلاوت رسمی (ممکن است هنوز باندل نشده باشد).
  String get audioAsset => 'assets/audio/quran/quran_$id.mp3';

  String get subtitle => '$revelation · ${verses.length} آیه';
}

class QuranData {
  static const List<Surah> all = <Surah>[
    // ۱) حمد
    Surah(
      id: 'fatiha',
      arabicName: 'سُورَةُ الفَاتِحَة',
      persianName: 'سوره حمد',
      revelation: 'مکی',
      coverEmoji: '🕌',
      themeColor: Color(0xFF00695C),
      gradient: LinearGradient(
        colors: [Color(0xFF004D40), Color(0xFF80CBC4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      showBasmalaHeader: false,
      verses: <SurahVerse>[
        SurahVerse(
          arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          meaning: 'به نام خدای مهربانِ بخشنده.',
        ),
        SurahVerse(
          arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          meaning: 'همهٔ ستایش‌ها مخصوص خداست؛ پروردگار همهٔ جهانیان.',
        ),
        SurahVerse(
          arabic: 'الرَّحْمَٰنِ الرَّحِيمِ',
          meaning: 'خدایی که بسیار مهربان و بخشنده است.',
        ),
        SurahVerse(
          arabic: 'مَالِكِ يَوْمِ الدِّينِ',
          meaning: 'صاحب و پادشاه روز جزا.',
        ),
        SurahVerse(
          arabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          meaning: 'فقط تو را می‌پرستیم و فقط از تو کمک می‌گیریم.',
        ),
        SurahVerse(
          arabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          meaning: 'ما را به راه راست هدایت کن.',
        ),
        SurahVerse(
          arabic:
              'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          meaning: 'راه کسانی که به آن‌ها نعمت دادی؛ نه راه گمراهان.',
        ),
      ],
    ),

    // ۲) اخلاص
    Surah(
      id: 'ikhlas',
      arabicName: 'سُورَةُ الإِخْلَاص',
      persianName: 'سوره اخلاص',
      revelation: 'مکی',
      coverEmoji: '☝️',
      themeColor: Color(0xFF1565C0),
      gradient: LinearGradient(
        colors: [Color(0xFF0D47A1), Color(0xFF90CAF9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      verses: <SurahVerse>[
        SurahVerse(
          arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          meaning: 'بگو: او خدای یکتا است.',
        ),
        SurahVerse(
          arabic: 'اللَّهُ الصَّمَدُ',
          meaning: 'خدایی که همه به او نیاز دارند و او از همه بی‌نیاز است.',
        ),
        SurahVerse(
          arabic: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          meaning: 'نه فرزندی دارد و نه فرزند کسی است.',
        ),
        SurahVerse(
          arabic: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
          meaning: 'و هیچ‌کس مانند و همتای او نیست.',
        ),
      ],
    ),

    // ۳) فلق
    Surah(
      id: 'falaq',
      arabicName: 'سُورَةُ الفَلَق',
      persianName: 'سوره فلق',
      revelation: 'مکی',
      coverEmoji: '🌅',
      themeColor: Color(0xFF6A1B9A),
      gradient: LinearGradient(
        colors: [Color(0xFF4A148C), Color(0xFFCE93D8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      verses: <SurahVerse>[
        SurahVerse(
          arabic: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          meaning: 'بگو: به پروردگار سپیده‌دم پناه می‌برم.',
        ),
        SurahVerse(
          arabic: 'مِن شَرِّ مَا خَلَقَ',
          meaning: 'از شرّ هر چیزی که آفریده است.',
        ),
        SurahVerse(
          arabic: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          meaning: 'و از شرّ شبِ تاریک وقتی فرا می‌رسد.',
        ),
        SurahVerse(
          arabic: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          meaning: 'و از شرّ کسانی که در گره‌ها می‌دمند.',
        ),
        SurahVerse(
          arabic: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          meaning: 'و از شرّ حسود وقتی حسادت می‌کند.',
        ),
      ],
    ),

    // ۴) ناس
    Surah(
      id: 'nas',
      arabicName: 'سُورَةُ النَّاس',
      persianName: 'سوره ناس',
      revelation: 'مکی',
      coverEmoji: '🤲',
      themeColor: Color(0xFF283593),
      gradient: LinearGradient(
        colors: [Color(0xFF1A237E), Color(0xFF9FA8DA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      verses: <SurahVerse>[
        SurahVerse(
          arabic: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          meaning: 'بگو: به پروردگار مردم پناه می‌برم.',
        ),
        SurahVerse(
          arabic: 'مَلِكِ النَّاسِ',
          meaning: 'پادشاه و سرپرست مردم.',
        ),
        SurahVerse(
          arabic: 'إِلَٰهِ النَّاسِ',
          meaning: 'معبود و خدای مردم.',
        ),
        SurahVerse(
          arabic: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
          meaning: 'از شرّ وسوسه‌گری که عقب می‌نشیند.',
        ),
        SurahVerse(
          arabic: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
          meaning: 'همان که در سینه‌های مردم وسوسه می‌کند.',
        ),
        SurahVerse(
          arabic: 'مِنَ الْجِنَّةِ وَالنَّاسِ',
          meaning: 'چه از جنس پنهان و چه از جنس مردم.',
        ),
      ],
    ),

    // ۵) کوثر
    Surah(
      id: 'kawthar',
      arabicName: 'سُورَةُ الكَوْثَر',
      persianName: 'سوره کوثر',
      revelation: 'مکی',
      coverEmoji: '💧',
      themeColor: Color(0xFF00838F),
      gradient: LinearGradient(
        colors: [Color(0xFF006064), Color(0xFF80DEEA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      verses: <SurahVerse>[
        SurahVerse(
          arabic: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
          meaning: 'ما به تو کوثر (خیر و نعمت فراوان) عطا کردیم.',
        ),
        SurahVerse(
          arabic: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
          meaning: 'پس برای پروردگارت نماز بخوان و قربانی کن.',
        ),
        SurahVerse(
          arabic: 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
          meaning: 'همان که با تو دشمنی دارد، خود بی‌نام و نشان است.',
        ),
      ],
    ),

    // ۶) عصر
    Surah(
      id: 'asr',
      arabicName: 'سُورَةُ العَصْر',
      persianName: 'سوره عصر',
      revelation: 'مکی',
      coverEmoji: '⏳',
      themeColor: Color(0xFFAD1457),
      gradient: LinearGradient(
        colors: [Color(0xFF880E4F), Color(0xFFF48FB1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      verses: <SurahVerse>[
        SurahVerse(
          arabic: 'وَالْعَصْرِ',
          meaning: 'سوگند به زمان.',
        ),
        SurahVerse(
          arabic: 'إِنَّ الْإِنسَانَ لَفِي خُسْرٍ',
          meaning: 'که انسان‌ها همه در زیان هستند.',
        ),
        SurahVerse(
          arabic:
              'إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ وَتَوَاصَوْا بِالصَّبْرِ',
          meaning:
              'مگر کسانی که ایمان آوردند و کار خوب انجام دادند و همدیگر را به حق و صبر سفارش کردند.',
        ),
      ],
    ),

    // ۷) نصر
    Surah(
      id: 'nasr',
      arabicName: 'سُورَةُ النَّصْر',
      persianName: 'سوره نصر',
      revelation: 'مدنی',
      coverEmoji: '🕊️',
      themeColor: Color(0xFF2E7D32),
      gradient: LinearGradient(
        colors: [Color(0xFF1B5E20), Color(0xFFA5D6A7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      verses: <SurahVerse>[
        SurahVerse(
          arabic: 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
          meaning: 'وقتی یاری خدا و پیروزی فرا می‌رسد.',
        ),
        SurahVerse(
          arabic:
              'وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا',
          meaning: 'و می‌بینی مردم دسته‌دسته به دین خدا وارد می‌شوند.',
        ),
        SurahVerse(
          arabic:
              'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ ۚ إِنَّهُ كَانَ تَوَّابًا',
          meaning: 'پس با ستایش پروردگارت تسبیح بگو و از او آمرزش بخواه که بسیار توبه‌پذیر است.',
        ),
      ],
    ),

    // ۸) فیل
    Surah(
      id: 'fil',
      arabicName: 'سُورَةُ الفِيل',
      persianName: 'سوره فیل',
      revelation: 'مکی',
      coverEmoji: '🐘',
      themeColor: Color(0xFF4E342E),
      gradient: LinearGradient(
        colors: [Color(0xFF3E2723), Color(0xFFBCAAA4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      verses: <SurahVerse>[
        SurahVerse(
          arabic: 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ',
          meaning: 'آیا ندیدی پروردگارت با اصحاب فیل چه کرد؟',
        ),
        SurahVerse(
          arabic: 'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِي تَضْلِيلٍ',
          meaning: 'آیا نقشه‌شان را بی‌اثر و گمراه‌کننده نساخت؟',
        ),
        SurahVerse(
          arabic: 'وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ',
          meaning: 'و پرندگانی دسته‌دسته بر سرشان فرستاد.',
        ),
        SurahVerse(
          arabic: 'تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ',
          meaning: 'که با سنگ‌هایی از گل پخته به آن‌ها حمله می‌کردند.',
        ),
        SurahVerse(
          arabic: 'فَجَعَلَهُمْ كَعَصْفٍ مَّأْكُولٍ',
          meaning: 'پس آن‌ها را مثل کاه جویده‌شده در هم شکست.',
        ),
      ],
    ),
  ];

  static Surah? byId(String id) {
    for (final surah in all) {
      if (surah.id == id) return surah;
    }
    return null;
  }

  /// تعداد کل آیات (برای تست‌های صحت داده).
  static int get totalVerses =>
      all.fold<int>(0, (sum, surah) => sum + surah.verseCount);
}
