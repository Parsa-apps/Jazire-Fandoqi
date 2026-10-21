import 'package:flutter/material.dart';

/// 📖 شعرهای کودکانهٔ جزیرهٔ فندقی
///
/// هر شعر اورجینال است و برای همین پروژه نوشته شده؛ بنابراین هیچ متنِ
/// دارای حقِ نشر از کتاب‌های دیگر بازنشر نمی‌شود.
///
/// هر خط `beats` دارد: تعداد ضربه‌هایی که کودک با شعر می‌زند. این عدد
/// برای بازی «ریتم بزن» استفاده می‌شود و عمداً ساده و قابل‌شمارش است.
class PoemLine {
  final String text;
  final int beats;

  const PoemLine(this.text, {required this.beats});
}

class KidsPoem {
  final String id;
  final String title;
  final String emoji;
  final String theme;
  final String message;
  final Color themeColor;
  final Color accentColor;
  final List<PoemLine> lines;

  /// پرسشِ قافیه/معنا همراه سه گزینه و پاسخ درست.
  final String question;
  final List<String> options;
  final String answer;

  const KidsPoem({
    required this.id,
    required this.title,
    required this.emoji,
    required this.theme,
    required this.message,
    required this.themeColor,
    required this.accentColor,
    required this.lines,
    required this.question,
    required this.options,
    required this.answer,
  });

  int get totalBeats => lines.fold<int>(0, (sum, line) => sum + line.beats);

  String get fullText => lines.map((line) => line.text).join('\n');
}

class PoemsData {
  PoemsData._();

  static const List<KidsPoem> all = <KidsPoem>[
    KidsPoem(
      id: 'poem_sparrow_rain',
      title: 'گنجشک و باران',
      emoji: '🌧️',
      theme: 'طبیعت',
      message: 'وقتی باران می‌آید، برگ‌های درختان چترِ کوچکِ پرنده‌ها می‌شوند.',
      themeColor: Color(0xFF1E6F8C),
      accentColor: Color(0xFF6FD0E8),
      lines: <PoemLine>[
        PoemLine('گنجشکِ کوچک، روی درخت', beats: 5),
        PoemLine('می‌خواند آواز، شاد و خوشبخت', beats: 6),
        PoemLine('باران که آمد، چترش کجاست؟', beats: 6),
        PoemLine('برگِ درختان، چترِ خداست', beats: 6),
        PoemLine('زیرِ دو برگِ سبز و نرم', beats: 5),
        PoemLine('می‌ماند خشک و گرم و گرم', beats: 6),
      ],
      question: 'در این شعر، چترِ گنجشک چیست؟',
      options: <String>['برگِ درختان', 'کلاهِ قرمز', 'یک چترِ بزرگ'],
      answer: 'برگِ درختان',
    ),
    KidsPoem(
      id: 'poem_moon_star',
      title: 'ماه و ستاره',
      emoji: '🌙',
      theme: 'آسمان',
      message: 'ماه و ستاره‌ها نگهبانِ خوابِ آرامِ ما هستند.',
      themeColor: Color(0xFF233A7A),
      accentColor: Color(0xFF8FA7FF),
      lines: <PoemLine>[
        PoemLine('ماهِ شب، بالای بام', beats: 4),
        PoemLine('می‌خندد آرام و تمام', beats: 5),
        PoemLine('ستاره‌ها، چشمک‌زنان', beats: 5),
        PoemLine('می‌گویند: «شب‌بخیر، مهربان»', beats: 6),
        PoemLine('در آسمانِ نیلیِ ما', beats: 5),
        PoemLine('روشن بمان، ای ماهِ زیبا', beats: 6),
      ],
      question: 'ماه در شعر، کجا نشسته است؟',
      options: <String>['بالای بام', 'زیرِ آب', 'روی درخت'],
      answer: 'بالای بام',
    ),
    KidsPoem(
      id: 'poem_red_apple',
      title: 'سیبِ سرخ',
      emoji: '🍎',
      theme: 'خوردنی‌ها',
      message: 'سیب، هدیهٔ سلامتی است؛ میوهٔ تازه بخور و شاد باش.',
      themeColor: Color(0xFF9B2C2C),
      accentColor: Color(0xFFFF8A80),
      lines: <PoemLine>[
        PoemLine('سیبِ سرخ و شیرین، بالای شاخه', beats: 6),
        PoemLine('مثلِ یک ستاره، روشن و تازه', beats: 6),
        PoemLine('باغبان با دستِ مهربان', beats: 5),
        PoemLine('سیب را هدیه می‌دهد به مهمان', beats: 7),
        PoemLine('یک گاز از سیب، شادی و خنده', beats: 6),
        PoemLine('سیب یعنی سلامتی، تازه و زنده', beats: 7),
      ],
      question: 'سیب در شعر چه چیزی به ما می‌دهد؟',
      options: <String>['سلامتی', 'خواب‌آلودگی', 'ترس'],
      answer: 'سلامتی',
    ),
    KidsPoem(
      id: 'poem_toothbrush',
      title: 'مسواکِ کوچک',
      emoji: '🪥',
      theme: 'سلامتی',
      message: 'مسواکِ کوچک، دوستِ دندان‌های ماست؛ صبح و شب با او دندان‌ها را تمیز کنیم.',
      themeColor: Color(0xFF0E7490),
      accentColor: Color(0xFF67E8F9),
      lines: <PoemLine>[
        PoemLine('مسواکِ کوچک، رفیقِ من', beats: 5),
        PoemLine('هر شب می‌آید، پیشِ من', beats: 5),
        PoemLine('بالا و پایین، چپ و راست', beats: 5),
        PoemLine('دندانِ من را پاک می‌کند', beats: 6),
        PoemLine('صبح که بیدار می‌شوم', beats: 5),
        PoemLine('اول سراغش می‌روم', beats: 5),
        PoemLine('لبخندِ من، برق می‌زند', beats: 5),
        PoemLine('مسواکِ من، شاد می‌زند', beats: 5),
      ],
      question: 'مسواک چه کاری برای دندان‌ها می‌کند؟',
      options: <String>['پاکشان می‌کند', 'رنگشان می‌کند', 'خوابشان می‌کند'],
      answer: 'پاکشان می‌کند',
    ),
    KidsPoem(
      id: 'poem_my_shoes',
      title: 'کفش‌های من',
      emoji: '👟',
      theme: 'نظم',
      message: 'هر چیز جای خودش را دارد؛ کفش‌ها را جفت و مرتب کنار هم بگذار.',
      themeColor: Color(0xFF6D28D9),
      accentColor: Color(0xFFC4B5FD),
      lines: <PoemLine>[
        PoemLine('کفشِ چپ، کفشِ راست', beats: 5),
        PoemLine('هر کدام، جایِ خود است', beats: 5),
        PoemLine('صبح، با یک لبخند', beats: 4),
        PoemLine('می‌پوشم، شاد و بلند', beats: 5),
        PoemLine('می‌دوم با کفش‌هایم', beats: 5),
        PoemLine('توپ می‌زنم، من و پایم', beats: 6),
        PoemLine('شب که شد، کنارِ هم', beats: 5),
        PoemLine('می‌گذارم، مرتب و رام', beats: 6),
      ],
      question: 'بعد از بازی، کفش‌ها را کجا می‌گذاریم؟',
      options: <String>['کنارِ هم، مرتب', 'وسطِ کوچه', 'روی تخت'],
      answer: 'کنارِ هم، مرتب',
    ),
    KidsPoem(
      id: 'poem_colorful_fish',
      title: 'ماهیِ رنگین',
      emoji: '🐟',
      theme: 'طبیعت',
      message: 'آبِ پاک، خانهٔ ماهی است؛ زباله را در آب نریزیم.',
      themeColor: Color(0xFF0369A1),
      accentColor: Color(0xFF7DD3FC),
      lines: <PoemLine>[
        PoemLine('ماهیِ رنگین، در آبِ روان', beats: 6),
        PoemLine('شنا می‌کند، شاد و روان', beats: 5),
        PoemLine('دُم می‌زند، حباب می‌کند', beats: 6),
        PoemLine('با سنگ‌ها، بازی می‌کند', beats: 6),
        PoemLine('آبِ پاک، خانهٔ اوست', beats: 5),
        PoemLine('مراقبش باشیم، او دوستِ ماست', beats: 7),
      ],
      question: 'خانهٔ ماهی در شعر کجاست؟',
      options: <String>['آبِ پاک', 'روی درخت', 'زیرِ خاک'],
      answer: 'آبِ پاک',
    ),
    KidsPoem(
      id: 'poem_spring',
      title: 'بهار آمد',
      emoji: '🌸',
      theme: 'فصل‌ها',
      message: 'بهار با گل و پرنده می‌آید؛ به طبیعت سلام کنیم.',
      themeColor: Color(0xFF166534),
      accentColor: Color(0xFF86EFAC),
      lines: <PoemLine>[
        PoemLine('بهار آمد، با گلِ سرخ', beats: 5),
        PoemLine('پرنده خواند، روی درخت', beats: 5),
        PoemLine('شکوفه داد، هر شاخه', beats: 4),
        PoemLine('زمین خندید، در هر گوشه', beats: 5),
        PoemLine('بیا به باغ، با هم برویم', beats: 6),
        PoemLine('گل و پرنده، با هم ببینیم', beats: 6),
      ],
      question: 'در بهار، درخت‌ها چه می‌کنند؟',
      options: <String>['شکوفه می‌دهند', 'برف می‌بارند', 'می‌خوابند'],
      answer: 'شکوفه می‌دهند',
    ),
    KidsPoem(
      id: 'poem_mom',
      title: 'مامان',
      emoji: '💛',
      theme: 'خانواده',
      message: 'مامان همیشه کنارِ ماست؛ با یک بغل و یک «دوستت دارم» خوشحالش کنیم.',
      themeColor: Color(0xFF9D174D),
      accentColor: Color(0xFFF9A8D4),
      lines: <PoemLine>[
        PoemLine('مامانِ من، مهربان', beats: 4),
        PoemLine('مثلِ باران، مثلِ نان', beats: 4),
        PoemLine('وقتی خسته می‌شوم', beats: 5),
        PoemLine('بغلِ او، خانهٔ من', beats: 5),
        PoemLine('دستِ او، گرم و نرم', beats: 4),
        PoemLine('قلبِ من، شاد و گرم', beats: 4),
        PoemLine('مامان، دوستت دارم', beats: 5),
        PoemLine('همیشه کنارِ تو هستم', beats: 6),
      ],
      question: 'بغلِ مامان در شعر، مثل چه چیزی است؟',
      options: <String>['خانه', 'مدرسه', 'بازی'],
      answer: 'خانه',
    ),
    KidsPoem(
      id: 'poem_cloud',
      title: 'ابرِ پنبه‌ای',
      emoji: '☁️',
      theme: 'آسمان',
      message: 'باران از ابر می‌آید و زمینِ تشنه را شاد می‌کند.',
      themeColor: Color(0xFF1E40AF),
      accentColor: Color(0xFFBFDBFE),
      lines: <PoemLine>[
        PoemLine('ابرِ سفیدِ پنبه‌ای، در آسمان', beats: 7),
        PoemLine('می‌رقصد آرام، با بادِ مهربان', beats: 7),
        PoemLine('قطره‌قطره، باران می‌شود', beats: 6),
        PoemLine('زمینِ تشنه، شادان می‌شود', beats: 6),
        PoemLine('بعد از باران، خورشید می‌آید', beats: 7),
        PoemLine('رنگین‌کمان، لبخند می‌آورد', beats: 7),
      ],
      question: 'باران از کجا می‌آید؟',
      options: <String>['از ابر', 'از درخت', 'از سنگ'],
      answer: 'از ابر',
    ),
    KidsPoem(
      id: 'poem_kindness',
      title: 'چراغِ مهربانی',
      emoji: '🕯️',
      theme: 'مهربانی',
      message: 'مهربانی کوچک است، اما می‌تواند دنیا را روشن کند.',
      themeColor: Color(0xFF92400E),
      accentColor: Color(0xFFFCD34D),
      lines: <PoemLine>[
        PoemLine('یک کارِ خوب، یک لبخند', beats: 5),
        PoemLine('مثلِ چراغ، روشن و بلند', beats: 6),
        PoemLine('دستِ یک دوست را بگیر', beats: 5),
        PoemLine('قلبِ او را شاد کن', beats: 5),
        PoemLine('مهربانی، دانهٔ کوچک', beats: 5),
        PoemLine('در دلِ ما می‌کارد', beats: 5),
        PoemLine('بعد از آن، گل می‌شود', beats: 5),
        PoemLine('دنیا پر از گل می‌شود', beats: 6),
      ],
      question: 'مهربانی در شعر به چه چیزی تشبیه شده است؟',
      options: <String>['چراغ', 'سنگ', 'ابر'],
      answer: 'چراغ',
    ),
  ];

  static KidsPoem? byId(String id) {
    for (final poem in all) {
      if (poem.id == id) return poem;
    }
    return null;
  }
}
