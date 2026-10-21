import 'package:flutter/material.dart';

/// 📖 سوره‌های کوتاه برای کودکان
///
/// متنِ عربی با اعرابِ آشنا نوشته شده و ترجمه/معنیِ فارسی، ساده و کودکانه
/// است (نه تفسیر). این بخش عمداً **کامل رایگان** است: کتابِ مهربانی نباید
/// پشتِ پرداخت پنهان شود.
class QuranAyah {
  final int number;
  final String arabic;
  final String persian;

  const QuranAyah({
    required this.number,
    required this.arabic,
    required this.persian,
  });
}

class QuranSurah {
  final String id;
  final int number;
  final String name;
  final String meaning;
  final String place;
  final String kidMessage;
  final Color themeColor;
  final Color accentColor;
  final bool startsWithBismillah;
  final List<QuranAyah> ayahs;

  const QuranSurah({
    required this.id,
    required this.number,
    required this.name,
    required this.meaning,
    required this.place,
    required this.kidMessage,
    required this.themeColor,
    required this.accentColor,
    required this.ayahs,
    this.startsWithBismillah = true,
  });

  int get ayahCount => ayahs.length;
}

class QuranData {
  QuranData._();

  static const String bismillah = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  /// آدابِ کوتاه و قابل‌فهم برای کودک؛ بدون فتوا و بدون بارِ سنگین.
  static const List<String> etiquette = <String>[
    'با وضو و آرام شروع می‌کنیم.',
    'با صدای مهربان و آرام می‌خوانیم.',
    'به بزرگ‌ترها اجازه می‌دهیم اول بخوانند.',
    'بعد از خواندن، یک کارِ خوب انجام می‌دهیم.',
  ];

  static const List<QuranSurah> all = <QuranSurah>[
    QuranSurah(
      id: 'fatiha',
      number: 1,
      name: 'سورهٔ فاتحه',
      meaning: 'همان آغازِ روشن',
      place: 'مکی',
      kidMessage: 'الفاتحه آغازِ نماز است؛ در آن با خداوند حرف می‌زنیم.',
      themeColor: Color(0xFF0F5132),
      accentColor: Color(0xFFD4AF37),
      startsWithBismillah: false,
      ayahs: <QuranAyah>[
        QuranAyah(
          number: 1,
          arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          persian: 'به نامِ خداوندِ بخشندهٔ مهربان',
        ),
        QuranAyah(
          number: 2,
          arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          persian: 'ستایش برای خداوند، پروردگارِ همهٔ جهان‌هاست',
        ),
        QuranAyah(
          number: 3,
          arabic: 'الرَّحْمَٰنِ الرَّحِيمِ',
          persian: 'بخشندهٔ مهربان',
        ),
        QuranAyah(
          number: 4,
          arabic: 'مَالِكِ يَوْمِ الدِّينِ',
          persian: 'صاحبِ روزِ داوری',
        ),
        QuranAyah(
          number: 5,
          arabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          persian: 'تنها تو را می‌پرستیم و تنها از تو کمک می‌خواهیم',
        ),
        QuranAyah(
          number: 6,
          arabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          persian: 'ما را به راهِ راست راهنمایی کن',
        ),
        QuranAyah(
          number: 7,
          arabic:
              'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          persian:
              'راهِ کسانی که به آنان نعمت دادی؛ نه راهِ خشمگرفته‌ها و نه گمراهان',
        ),
      ],
    ),
    QuranSurah(
      id: 'ikhlas',
      number: 112,
      name: 'سورهٔ اخلاص',
      meaning: 'یکتاییِ خداوند',
      place: 'مکی',
      kidMessage: 'توحید یعنی خدا یکی است و هیچ‌کس مثلِ او نیست.',
      themeColor: Color(0xFF124E66),
      accentColor: Color(0xFF7FD1D9),
      ayahs: <QuranAyah>[
        QuranAyah(
          number: 1,
          arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          persian: 'بگو: او خداوندِ یکتاست',
        ),
        QuranAyah(
          number: 2,
          arabic: 'اللَّهُ الصَّمَدُ',
          persian: 'خداوندی که همه به او نیاز دارند',
        ),
        QuranAyah(
          number: 3,
          arabic: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          persian: 'نه فرزندی دارد و نه از کسی زاده شده است',
        ),
        QuranAyah(
          number: 4,
          arabic: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
          persian: 'و هیچ‌کس همتای او نیست',
        ),
      ],
    ),
    QuranSurah(
      id: 'falaq',
      number: 113,
      name: 'سورهٔ فلق',
      meaning: 'سپیدهٔ روشن',
      place: 'مکی',
      kidMessage: 'خواندنِ فلق، دلِ ما را آرام می‌کند و به خدا پناه می‌برد.',
      themeColor: Color(0xFF3B3468),
      accentColor: Color(0xFFF4C95D),
      ayahs: <QuranAyah>[
        QuranAyah(
          number: 1,
          arabic: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          persian: 'بگو: به پروردگارِ سپیده پناه می‌برم',
        ),
        QuranAyah(
          number: 2,
          arabic: 'مِن شَرِّ مَا خَلَقَ',
          persian: 'از بدیِ آنچه آفریده است',
        ),
        QuranAyah(
          number: 3,
          arabic: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          persian: 'و از بدیِ تاریکی وقتی فرا می‌رسد',
        ),
        QuranAyah(
          number: 4,
          arabic: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          persian: 'و از بدیِ آنان که در گره‌ها می‌دمند',
        ),
        QuranAyah(
          number: 5,
          arabic: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          persian: 'و از بدیِ حسود وقتی حسد می‌ورزد',
        ),
      ],
    ),
    QuranSurah(
      id: 'nas',
      number: 114,
      name: 'سورهٔ ناس',
      meaning: 'مردم',
      place: 'مکی',
      kidMessage: 'خداوند پروردگار و پادشاهِ همهٔ مردم است و از ما مراقبت می‌کند.',
      themeColor: Color(0xFF4A2545),
      accentColor: Color(0xFFE8B4B8),
      ayahs: <QuranAyah>[
        QuranAyah(
          number: 1,
          arabic: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          persian: 'بگو: به پروردگارِ مردم پناه می‌برم',
        ),
        QuranAyah(
          number: 2,
          arabic: 'مَلِكِ النَّاسِ',
          persian: 'پادشاهِ مردم',
        ),
        QuranAyah(
          number: 3,
          arabic: 'إِلَٰهِ النَّاسِ',
          persian: 'خدای مردم',
        ),
        QuranAyah(
          number: 4,
          arabic: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
          persian: 'از بدیِ وسوسه‌گرِ پنهان‌شونده',
        ),
        QuranAyah(
          number: 5,
          arabic: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
          persian: 'که در دل‌های مردم وسوسه می‌کند',
        ),
        QuranAyah(
          number: 6,
          arabic: 'مِنَ الْجِنَّةِ وَالنَّاسِ',
          persian: 'از جن و از انسان',
        ),
      ],
    ),
    QuranSurah(
      id: 'kawthar',
      number: 108,
      name: 'سورهٔ کوثر',
      meaning: 'خیرِ فراوان',
      place: 'مکی',
      kidMessage: 'خداوند به پیامبرِ مهربان، خیرِ فراوان هدیه داد.',
      themeColor: Color(0xFF1D4E4A),
      accentColor: Color(0xFFE9D8A6),
      ayahs: <QuranAyah>[
        QuranAyah(
          number: 1,
          arabic: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
          persian: 'همانا ما به تو خیرِ فراوان دادیم',
        ),
        QuranAyah(
          number: 2,
          arabic: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
          persian: 'پس برای پروردگارت نماز بخوان و قربانی کن',
        ),
        QuranAyah(
          number: 3,
          arabic: 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
          persian: 'همانا دشمنِ تو بی‌بهره است',
        ),
      ],
    ),
    QuranSurah(
      id: 'asr',
      number: 103,
      name: 'سورهٔ عصر',
      meaning: 'زمان',
      place: 'مکی',
      kidMessage: 'زمان را با ایمان، کارِ خوب، راستی و صبر پر کنیم.',
      themeColor: Color(0xFF5B4636),
      accentColor: Color(0xFFF2D0A4),
      ayahs: <QuranAyah>[
        QuranAyah(
          number: 1,
          arabic: 'وَالْعَصْرِ',
          persian: 'سوگند به عصر',
        ),
        QuranAyah(
          number: 2,
          arabic: 'إِنَّ الْإِنسَانَ لَفِي خُسْرٍ',
          persian: 'همانا انسان در زیان است',
        ),
        QuranAyah(
          number: 3,
          arabic:
              'إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ وَتَوَاصَوْا بِالصَّبْرِ',
          persian:
              'مگر کسانی که ایمان آوردند، کارهای نیک کردند و یکدیگر را به حق و صبر سفارش کردند',
        ),
      ],
    ),
    QuranSurah(
      id: 'fil',
      number: 105,
      name: 'سورهٔ فیل',
      meaning: 'فیل',
      place: 'مکی',
      kidMessage: 'خداوند خانهٔ کعبه را از آسیبِ یارانِ فیل حفظ کرد.',
      themeColor: Color(0xFF3E4A2E),
      accentColor: Color(0xFFC7D59F),
      ayahs: <QuranAyah>[
        QuranAyah(
          number: 1,
          arabic: 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ',
          persian: 'آیا ندیدی پروردگارت با یارانِ فیل چه کرد؟',
        ),
        QuranAyah(
          number: 2,
          arabic: 'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِي تَضْلِيلٍ',
          persian: 'آیا نقشهٔ آنان را باطل نکرد؟',
        ),
        QuranAyah(
          number: 3,
          arabic: 'وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ',
          persian: 'و پرندگانی گروه‌گروه بر آنان فرستاد',
        ),
        QuranAyah(
          number: 4,
          arabic: 'تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ',
          persian: 'که بر آنان سنگ‌هایی از گلِ سخت می‌افکندند',
        ),
        QuranAyah(
          number: 5,
          arabic: 'فَجَعَلَهُمْ كَعَصْفٍ مَّأْكُولٍ',
          persian: 'پس آنان را مانند کاهِ خورده‌شده قرار داد',
        ),
      ],
    ),
    QuranSurah(
      id: 'quraysh',
      number: 106,
      name: 'سورهٔ قریش',
      meaning: 'قریش',
      place: 'مکی',
      kidMessage: 'امنیت و روزی، نعمت‌های خدا هستند؛ شکرگزار باشیم.',
      themeColor: Color(0xFF62432F),
      accentColor: Color(0xFFE8C9A0),
      ayahs: <QuranAyah>[
        QuranAyah(
          number: 1,
          arabic: 'لِإِيلَافِ قُرَيْشٍ',
          persian: 'برای الفتِ قریش',
        ),
        QuranAyah(
          number: 2,
          arabic: 'إِيلَافِهِمْ رِحْلَةَ الشِّتَاءِ وَالصَّيْفِ',
          persian: 'الفتِ آنان در سفرِ زمستان و تابستان',
        ),
        QuranAyah(
          number: 3,
          arabic: 'فَلْيَعْبُدُوا رَبَّ هَٰذَا الْبَيْتِ',
          persian: 'پس باید پروردگارِ این خانه را بپرستند',
        ),
        QuranAyah(
          number: 4,
          arabic: 'الَّذِي أَطْعَمَهُم مِّن جُوعٍ وَآمَنَهُم مِّنْ خَوْفٍ',
          persian: 'خدایی که آنان را از گرسنگی سیر کرد و از ترس ایمن ساخت',
        ),
      ],
    ),
  ];

  /// سورهٔ امروز برای کارتِ «سورهٔ روز»؛ انتخاب بر پایهٔ روزِ هفته است تا
  /// در هر اجرا تغییر نکند و کودک فرصت کند با آن آشنا شود.
  static QuranSurah surahOfTheDay([DateTime? date]) {
    final day = (date ?? DateTime.now()).weekday; // ۱ = دوشنبه
    return all[(day - 1) % all.length];
  }

  static QuranSurah? byId(String id) {
    for (final surah in all) {
      if (surah.id == id) return surah;
    }
    return null;
  }
}
