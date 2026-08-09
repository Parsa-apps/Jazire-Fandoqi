import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎬 KUDAKE IRAN — بانک جامع و جذاب کارتون‌ها و انیمیشن‌های کودکان
/// ═══════════════════════════════════════════════════════════════

enum CartoonCategoryType {
  all,
  iranian,
  adventure,
  comedy,
  preschool,
  musical,
  classics,
}

class CartoonCategory {
  final CartoonCategoryType type;
  final String title;
  final String emoji;
  final Color color;

  const CartoonCategory({
    required this.type,
    required this.title,
    required this.emoji,
    required this.color,
  });
}

class CartoonEpisode {
  final String id;
  final int episodeNumber;
  final String title;
  final String duration;
  final String description;
  final String streamUrl;
  final String webUrl;
  final String coverEmoji;

  const CartoonEpisode({
    required this.id,
    required this.episodeNumber,
    required this.title,
    required this.duration,
    required this.description,
    required this.streamUrl,
    required this.webUrl,
    required this.coverEmoji,
  });
}

class Cartoon {
  final String id;
  final String title;
  final String englishTitle;
  final String characterName;
  final CartoonCategoryType category;
  final String categoryLabel;
  final String description;
  final String coverEmoji;
  final Color themeColor;
  final LinearGradient gradient;
  final double rating;
  final String views;
  final String ageRating;
  final String learningGoal;
  final String badgeText;
  final bool isFeatured;
  final bool isNew;
  final List<CartoonEpisode> episodes;

  const Cartoon({
    required this.id,
    required this.title,
    required this.englishTitle,
    required this.characterName,
    required this.category,
    required this.categoryLabel,
    required this.description,
    required this.coverEmoji,
    required this.themeColor,
    required this.gradient,
    required this.rating,
    required this.views,
    required this.ageRating,
    required this.learningGoal,
    required this.badgeText,
    this.isFeatured = false,
    this.isNew = false,
    required this.episodes,
  });
}

class CartoonData {
  CartoonData._();

  static const List<CartoonCategory> categories = <CartoonCategory>[
    CartoonCategory(
      type: CartoonCategoryType.all,
      title: 'همه کارتون‌ها',
      emoji: '🌟',
      color: Color(0xFF6C5CE7),
    ),
    CartoonCategory(
      type: CartoonCategoryType.iranian,
      title: 'ایرانی و آموزنده',
      emoji: '🇮🇷',
      color: Color(0xFF00B894),
    ),
    CartoonCategory(
      type: CartoonCategoryType.adventure,
      title: 'ماجراجویی و نجات',
      emoji: '🐾',
      color: Color(0xFFFF7675),
    ),
    CartoonCategory(
      type: CartoonCategoryType.comedy,
      title: 'طنز و خنده‌دار',
      emoji: '😄',
      color: Color(0xFFFDCB6E),
    ),
    CartoonCategory(
      type: CartoonCategoryType.preschool,
      title: 'خردسالان و نوپا',
      emoji: '👶',
      color: Color(0xFF00CEC9),
    ),
    CartoonCategory(
      type: CartoonCategoryType.musical,
      title: 'موزیکال و شعر',
      emoji: '🎵',
      color: Color(0xFFE84393),
    ),
    CartoonCategory(
      type: CartoonCategoryType.classics,
      title: 'افسانه‌ها و کهن',
      emoji: '📖',
      color: Color(0xFF0984E3),
    ),
  ];

  static final List<Cartoon> allCartoons = <Cartoon>[
    // ۱. شکرستان
    const Cartoon(
      id: 'shekarestan',
      title: 'شکرستان',
      englishTitle: 'Shekarestan',
      characterName: 'بهلول، اسکندر، خواجه فرزان',
      category: CartoonCategoryType.iranian,
      categoryLabel: 'ایرانی و آموزنده',
      description:
          'داستان‌های شیرین، طنز و آموزنده در شهر شکرستان با بهلول دانا، اسکندر کوچولو و قصه‌های پر از حکمت و خنده.',
      coverEmoji: '🏰',
      themeColor: Color(0xFFFF8E53),
      gradient: LinearGradient(
        colors: [Color(0xFFFF8E53), Color(0xFFFF6B6B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 5.0,
      views: '۸۵ هزار تماشا',
      ageRating: '۴+',
      learningGoal: 'حکمت، راستگویی، حل مسئله و شوخ‌طبعی سالم',
      badgeText: 'محبوب‌ترین ایرانی',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'shekar_ep1',
          episodeNumber: 1,
          title: 'راز گنج پنهان شکرستان',
          duration: '۱۳:۴۰',
          description: 'صمد و خواجه الماس به دنبال گنجی در غار قدیمی شهر می‌گردند اما بهلول راه‌حل بهتری دارد!',
          streamUrl: 'https://www.aparat.com/v/kudak_shekarestan_1',
          webUrl: 'https://www.aparat.com/result/%D8%B4%DA%A9%D8%B1%D8%B3%D8%AA%D8%A7%D9%86',
          coverEmoji: '🗝️',
        ),
        CartoonEpisode(
          id: 'shekar_ep2',
          episodeNumber: 2,
          title: 'دزد ناشی و قاضی باهوش',
          duration: '۱۴:۱۵',
          description: 'ماجرای خنده‌دار دزدی که خودش را لو می‌دهد و قضاوت حکیمانه بهلول دانا.',
          streamUrl: 'https://www.aparat.com/v/kudak_shekarestan_2',
          webUrl: 'https://www.aparat.com/result/%D8%B4%DA%A9%D8%B1%D8%B3%D8%AA%D8%A7%D9%86',
          coverEmoji: '⚖️',
        ),
        CartoonEpisode(
          id: 'shekar_ep3',
          episodeNumber: 3,
          title: 'پرنده سخنگوی اسکندر',
          duration: '۱۲:۵۰',
          description: 'اسکندر یک طوطی پیدا می‌کند که همه رازها را فاش می‌کند و ماجرای خنده‌داری راه می‌اندازد.',
          streamUrl: 'https://www.aparat.com/v/kudak_shekarestan_3',
          webUrl: 'https://www.aparat.com/result/%D8%B4%DA%A9%D8%B1%D8%B3%D8%AA%D8%A7%D9%86',
          coverEmoji: '🦜',
        ),
      ],
    ),

    // ۲. پهلوانان
    const Cartoon(
      id: 'pahlavanan',
      title: 'پهلوانان',
      englishTitle: 'Pahlavanan',
      characterName: 'پوریای ولی، یاور، صفی و مفرد',
      category: CartoonCategoryType.iranian,
      categoryLabel: 'ایرانی و آموزنده',
      description:
          'ماجراهای پوریای ولی و شاگردان وفادارش در زورخانه شهر خوارزم. آموزش جوانمردی، کمک به نیازمندان و ایستادگی در برابر ستم.',
      coverEmoji: '⚔️',
      themeColor: Color(0xFF00B894),
      gradient: LinearGradient(
        colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۱۲۰ هزار تماشا',
      ageRating: '۵+',
      learningGoal: 'جوانمردی، شجاعت، مروت و احترام به بزرگ‌ترها',
      badgeText: 'شاهکار انیمیشن',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'pahla_ep1',
          episodeNumber: 1,
          title: 'پیمان جوانمردی و زورخانه',
          duration: '۲۱:۳۰',
          description: 'پوریای ولی به شاگردانش یاد می‌دهد که قدرت واقعی در مهار خشم و کمک به ضعیفان است.',
          streamUrl: 'https://www.aparat.com/v/kudak_pahlavanan_1',
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%87%D9%84%D9%88%D8%A7%D9%86%D8%A7%D9%86',
          coverEmoji: '🛡️',
        ),
        CartoonEpisode(
          id: 'pahla_ep2',
          episodeNumber: 2,
          title: 'نجات کاروان داروها',
          duration: '۲۰:۴۵',
          description: 'شاگردان پوریا برای رساندن داروی بیماران به کوهستان می‌روند و با راهزنان روبرو می‌شوند.',
          streamUrl: 'https://www.aparat.com/v/kudak_pahlavanan_2',
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%87%D9%84%D9%88%D8%A7%D9%86%D8%A7%D9%86',
          coverEmoji: '🐎',
        ),
      ],
    ),

    // ۳. سگ‌های نگهبان (گشت پنجه‌ای)
    const Cartoon(
      id: 'paw_patrol',
      title: 'سگ‌های نگهبان',
      englishTitle: 'Paw Patrol',
      characterName: 'رایدر، چیس، مارشال، اسکای',
      category: CartoonCategoryType.adventure,
      categoryLabel: 'ماجراجویی و نجات',
      description:
          'رایدر و توله‌سگ‌های نجات‌بخش و شجاع در شهر خلیج ماجراها به کمک دوستانشان می‌شتابند. دوبله فارسی بسیار شاد و جذاب.',
      coverEmoji: '🐾',
      themeColor: Color(0xFF0984E3),
      gradient: LinearGradient(
        colors: [Color(0xFF0984E3), Color(0xFF74B9FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 5.0,
      views: '۲۱۰ هزار تماشا',
      ageRating: '۳+',
      learningGoal: 'همکاری گروهی، مسئولیت‌پذیری و آمادگی در حوادث',
      badgeText: 'دوبله اختصاصی',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'paw_ep1',
          episodeNumber: 1,
          title: 'عملیات نجات بزرگ در خلیج',
          duration: '۱۱:۲۰',
          description: 'شهردار گودوی در دردسر افتاده و چیس و مارشال سریع‌ترین راه نجات را پیدا می‌کنند!',
          streamUrl: 'https://www.aparat.com/v/kudak_pawpatrol_1',
          webUrl: 'https://www.aparat.com/result/%D8%B3%DA%AF%D9%87%D8%A7%DB%8C+%D9%86%DA%AF%D9%87%D8%A8%D8%A7%D9%86',
          coverEmoji: '🚒',
        ),
        CartoonEpisode(
          id: 'paw_ep2',
          episodeNumber: 2,
          title: 'اسکای و پرواز در آسمان بارانی',
          duration: '۱۲:۱۰',
          description: 'پرواز نجات هوایی اسکای برای پیدا کردن اردک‌های گم‌شده در جنگل سرسبز.',
          streamUrl: 'https://www.aparat.com/v/kudak_pawpatrol_2',
          webUrl: 'https://www.aparat.com/result/%D8%B3%DA%AF%D9%87%D8%A7%DB%8C+%D9%86%DA%AF%D9%87%D8%A8%D8%A7%D9%86',
          coverEmoji: '🚁',
        ),
        CartoonEpisode(
          id: 'paw_ep3',
          episodeNumber: 3,
          title: 'رابل و ساخت پل رنگین‌کمان',
          duration: '۱۰:۵۰',
          description: 'سگ‌های نگهبان برای عبور قطار حیوانات یک پل زیبا و مستحکم می‌سازند.',
          streamUrl: 'https://www.aparat.com/v/kudak_pawpatrol_3',
          webUrl: 'https://www.aparat.com/result/%D8%B3%DA%AF%D9%87%D8%A7%DB%8C+%D9%86%DA%AF%D9%87%D8%A8%D8%A7%D9%86',
          coverEmoji: '🏗️',
        ),
      ],
    ),

    // ۴. باب اسفنجی شلوار مکعبی
    const Cartoon(
      id: 'spongebob',
      title: 'باب اسفنجی',
      englishTitle: 'SpongeBob SquarePants',
      characterName: 'باب اسفنجی، پاتریک، اختاپوس',
      category: CartoonCategoryType.comedy,
      categoryLabel: 'طنز و خنده‌دار',
      description:
          'خنده‌دارترین و شادترین کارتون دنیا در اعماق اقیانوس بیکینی باتم با همبرگرهای خوشمزه رستوران خرچنگ و حباب‌بازی!',
      coverEmoji: '🧽',
      themeColor: Color(0xFFF1C40F),
      gradient: LinearGradient(
        colors: [Color(0xFFF1C40F), Color(0xFFE67E22)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۱۹۵ هزار تماشا',
      ageRating: '۴+',
      learningGoal: 'شادی، انرژی مثبت، خوش‌بینی و دوستی پایدار',
      badgeText: 'پر از خنده',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'sponge_ep1',
          episodeNumber: 1,
          title: 'همبرگر خرچنگی جادویی',
          duration: '۱۱:۴۰',
          description: 'پلانکتون نقشه جدیدی برای دزدیدن فرمول سری می‌کشد ولی باب اسفنجی با مهربانی او را شگفت‌زده می‌کند!',
          streamUrl: 'https://www.aparat.com/v/kudak_spongebob_1',
          webUrl: 'https://www.aparat.com/result/%D8%A8%D8%A7%D8%A8+%D8%A7%D8%B3%D9%81%D9%86%D8%AC%DB%8C',
          coverEmoji: '🍔',
        ),
        CartoonEpisode(
          id: 'sponge_ep2',
          episodeNumber: 2,
          title: 'حباب‌های خندان پاتریک',
          duration: '۱۰:۳۰',
          description: 'مسابقه خنده‌دار حباب درست کردن باب اسفنجی و پاتریک با اشکال حیوانات دریایی.',
          streamUrl: 'https://www.aparat.com/v/kudak_spongebob_2',
          webUrl: 'https://www.aparat.com/result/%D8%A8%D8%A7%D8%A8+%D8%A7%D8%B3%D9%81%D9%86%D8%AC%DB%8C',
          coverEmoji: '🫧',
        ),
      ],
    ),

    // ۵. بره ناقلا (Shaun the Sheep)
    const Cartoon(
      id: 'shaun_sheep',
      title: 'بره ناقلا',
      englishTitle: 'Shaun the Sheep',
      characterName: 'شان، بیتزر سگ مزرعه، تیموتی',
      category: CartoonCategoryType.comedy,
      categoryLabel: 'طنز و خنده‌دار',
      description:
          'انیمیشن صامت و فوق‌العاده خنده‌دار بره زرنگ مزرعه که همیشه نقشه‌های هوشمندانه برای شاد کردن دوستانش می‌کشد.',
      coverEmoji: '🐑',
      themeColor: Color(0xFF6C5CE7),
      gradient: LinearGradient(
        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.8,
      views: '۱۴۰ هزار تماشا',
      ageRating: 'همه سنین',
      learningGoal: 'خلاقیت در حل مسئله، هوش هیجانی و همدلی',
      badgeText: 'شاد و بدون کلام',
      episodes: [
        CartoonEpisode(
          id: 'shaun_ep1',
          episodeNumber: 1,
          title: 'جشن تولد در انبار مزرعه',
          duration: '۰۷:۱۵',
          description: 'گوسفندها برای کشاورز یک جشن غافلگیرکننده می‌گیرند و سگ مزرعه سعی دارد اوضاع را کنترل کند!',
          streamUrl: 'https://www.aparat.com/v/kudak_shaun_1',
          webUrl: 'https://www.aparat.com/result/%D8%A8%D8%B1%D9%87+%D9%86%D8%A7%D9%82%D9%84%D8%A7',
          coverEmoji: '🎂',
        ),
        CartoonEpisode(
          id: 'shaun_ep2',
          episodeNumber: 2,
          title: 'مسابقه تراکتورهای پرنده',
          duration: '۰۶:۵۰',
          description: 'شان و دوستانش تراکتور مزرعه را با بادکنک‌ها به پرواز درمی‌آورند!',
          streamUrl: 'https://www.aparat.com/v/kudak_shaun_2',
          webUrl: 'https://www.aparat.com/result/%D8%A8%D8%B1%D9%87+%D9%86%D8%A7%D9%82%D9%84%D8%A7',
          coverEmoji: '🚜',
        ),
      ],
    ),

    // ۶. پپا پیگ (دوبله فارسی)
    const Cartoon(
      id: 'peppa_pig',
      title: 'پپا پیگ فارسی',
      englishTitle: 'Peppa Pig',
      characterName: 'پپا، جورج، مامان و بابا',
      category: CartoonCategoryType.preschool,
      categoryLabel: 'خردسالان و نوپا',
      description:
          'انیمیشن آموزشی بسیار ملایم و جذاب برای خردسالان. آموزش رفتارهای مؤدبانه، بازی‌های خانوادگی و کشف طبیعت.',
      coverEmoji: '🐷',
      themeColor: Color(0xFFFA709A),
      gradient: LinearGradient(
        colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۱۶۰ هزار تماشا',
      ageRating: '۲ تا ۶ سال',
      learningGoal: 'مهارت‌های اجتماعی، بهداشت فردی و ارتباط با خانواده',
      badgeText: 'آموزنده خردسالان',
      episodes: [
        CartoonEpisode(
          id: 'peppa_ep1',
          episodeNumber: 1,
          title: 'پریدن در چاله‌های گِل شاد',
          duration: '۰۵:۲۰',
          description: 'پپا چکمه‌های قرمزش را می‌پوشد و با جورج یاد می‌گیرد بعد از بازی دست‌هایش را بشوید.',
          streamUrl: 'https://www.aparat.com/v/kudak_peppa_1',
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%BE%D8%A7+%D9%BE%DB%8C%DA%AF',
          coverEmoji: '👢',
        ),
        CartoonEpisode(
          id: 'peppa_ep2',
          episodeNumber: 2,
          title: 'دوچرخه‌سواری بدون چرخ کمکی',
          duration: '۰۵:۴۵',
          description: 'پپا با تشویق بابا پیگ یاد می‌گیرد چطور تعادلش را روی دوچرخه حفظ کند.',
          streamUrl: 'https://www.aparat.com/v/kudak_peppa_2',
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%BE%D8%A7+%D9%BE%DB%8C%DA%AF',
          coverEmoji: '🚲',
        ),
      ],
    ),

    // ۷. دیرین دیرین کودکانه
    const Cartoon(
      id: 'dirin_dirin',
      title: 'دیرین دیرین کودکانه',
      englishTitle: 'Dirin Dirin Kids',
      characterName: 'وی، قرامیس، کله‌گنده‌ها',
      category: CartoonCategoryType.iranian,
      categoryLabel: 'ایرانی و آموزنده',
      description:
          'انیمیشن‌های کوتاه و بسیار خنده‌دار ایرانی با آموزش‌های شهری، محیط زیست، صرفه‌جویی و نظم برای بچه‌ها.',
      coverEmoji: '🦖',
      themeColor: Color(0xFF00CEC9),
      gradient: LinearGradient(
        colors: [Color(0xFF00CEC9), Color(0xFF55EFC4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.8,
      views: '۷۵ هزار تماشا',
      ageRating: '۴+',
      learningGoal: 'حفظ محیط زیست، تفکیک زباله و صرفه‌جویی در انرژی',
      badgeText: 'انیمیشن ایرانی',
      episodes: [
        CartoonEpisode(
          id: 'dirin_ep1',
          episodeNumber: 1,
          title: 'شهر تمیز و درختان سبز',
          duration: '۰۲:۳۰',
          description: 'ماجرای خنده‌دار کاشتن نهال و مراقبت از گل‌های شهر دیرین دیرین.',
          streamUrl: 'https://www.aparat.com/v/kudak_dirin_1',
          webUrl: 'https://www.aparat.com/result/%D8%AF%DB%8C%D8%B1%DB%8C%D9%86+%D8%AF%DB%8C%D8%B1%DB%8C%D9%86',
          coverEmoji: '🌳',
        ),
        CartoonEpisode(
          id: 'dirin_ep2',
          episodeNumber: 2,
          title: 'قطره قطره آب زندگیست',
          duration: '۰۲:۲۰',
          description: 'داستان نجات شیر آب چکه کننده توسط قهرمانان کوچولوی دیرین دیرین.',
          streamUrl: 'https://www.aparat.com/v/kudak_dirin_2',
          webUrl: 'https://www.aparat.com/result/%D8%AF%DB%8C%D8%B1%DB%8C%D9%86+%D8%AF%DB%8C%D8%B1%DB%8C%D9%86',
          coverEmoji: '💧',
        ),
      ],
    ),

    // ۸. تام و جری
    const Cartoon(
      id: 'tom_jerry',
      title: 'تام و جری',
      englishTitle: 'Tom and Jerry',
      characterName: 'تام گربه و جری موش باهوش',
      category: CartoonCategoryType.comedy,
      categoryLabel: 'طنز و خنده‌دار',
      description:
          'محبوب‌ترین کارتون خاطره‌انگیز تاریخ! تعقیب و گریزهای خنده‌دار، موسیقی‌های شاهکار و شوخی‌های جذاب موش و گربه.',
      coverEmoji: '🐱',
      themeColor: Color(0xFFE17055),
      gradient: LinearGradient(
        colors: [Color(0xFFE17055), Color(0xFFFF7675)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 5.0,
      views: '۳۰۰ هزار تماشا',
      ageRating: 'همه سنین',
      learningGoal: 'سرگرمی، درک ریتم و شوخ‌طبعی حرکتی',
      badgeText: 'نوستالژی طلایی',
      episodes: [
        CartoonEpisode(
          id: 'tom_ep1',
          episodeNumber: 1,
          title: 'کنسرت پیانو در آشپزخانه',
          duration: '۰۷:۴۰',
          description: 'تام کت‌وشلوار می‌پوشد تا پیانو بنوازد اما جری داخل پیانو زندگی می‌کند!',
          streamUrl: 'https://www.aparat.com/v/kudak_tomjerry_1',
          webUrl: 'https://www.aparat.com/result/%D8%AA%D8%A7%D9%85+%D9%88+%D8%AC%D8%B1%DB%8C',
          coverEmoji: '🎹',
        ),
        CartoonEpisode(
          id: 'tom_ep2',
          episodeNumber: 2,
          title: 'تله پنیر جادویی و اردک کوچولو',
          duration: '۰۶:۵۵',
          description: 'یک جوجه اردک کوچولو وارد خانه می‌شود و جری از او در برابر تام محافظت می‌کند.',
          streamUrl: 'https://www.aparat.com/v/kudak_tomjerry_2',
          webUrl: 'https://www.aparat.com/result/%D8%AA%D8%A7%D9%85+%D9%88+%D8%AC%D8%B1%DB%8C',
          coverEmoji: '🧀',
        ),
      ],
    ),

    // ۹. ماشین‌ها و مک‌کویین
    const Cartoon(
      id: 'cars_mcqueen',
      title: 'مک‌کویین و ماشین‌ها',
      englishTitle: 'Cars',
      characterName: 'لایتنینگ مک‌کویین، ماتر باوفا',
      category: CartoonCategoryType.adventure,
      categoryLabel: 'ماجراجویی و نجات',
      description:
          'سرعت، هیجان و دوستی در پیست مسابقه رادیاتور اسپرینگز. یادگیری این که برنده واقعی کسی است که دوستان باوفا دارد.',
      coverEmoji: '🏎️',
      themeColor: Color(0xFFD63031),
      gradient: LinearGradient(
        colors: [Color(0xFFD63031), Color(0xFFFF7675)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۱۸۰ هزار تماشا',
      ageRating: '۴+',
      learningGoal: 'صداقت در رقابت، وفاداری و کار تیمی',
      badgeText: 'پر از هیجان',
      episodes: [
        CartoonEpisode(
          id: 'cars_ep1',
          episodeNumber: 1,
          title: 'مسابقه بزرگ در دره ستاره‌ها',
          duration: '۱۲:۳۰',
          description: 'مک‌کویین به ماتر یاد می‌دهد چطور با سرعت دنده‌عقب رانندگی کند و مسابقه را ببرد!',
          streamUrl: 'https://www.aparat.com/v/kudak_cars_1',
          webUrl: 'https://www.aparat.com/result/%DA%A9%D8%A7%D8%B1%D8%AA%D9%88%D9%86+%D9%85%D8%A7%D8%B4%DB%8C%D9%86%D9%87%D8%A7',
          coverEmoji: '🏆',
        ),
      ],
    ),

    // ۱۰. بچه رئیس
    const Cartoon(
      id: 'boss_baby',
      title: 'بچه رئیس',
      englishTitle: 'The Boss Baby',
      characterName: 'بچه رئیس و تیم',
      category: CartoonCategoryType.comedy,
      categoryLabel: 'طنز و خنده‌دار',
      description:
          'یک نوزاد بامزه با کت و شلوار و کیف اداری که مأموریت‌های مخفی کودکانه را فرماندهی می‌کند!',
      coverEmoji: '👶',
      themeColor: Color(0xFF2C3E50),
      gradient: LinearGradient(
        colors: [Color(0xFF2C3E50), Color(0xFF4B6584)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.8,
      views: '۱۵۰ هزار تماشا',
      ageRating: '۵+',
      learningGoal: 'مهر برادر و خواهری، همکاری و تخیل خلاق',
      badgeText: 'کمدی هیجانی',
      episodes: [
        CartoonEpisode(
          id: 'boss_ep1',
          episodeNumber: 1,
          title: 'مأموریت شیشه‌شیر طلایی',
          duration: '۱۴:۰۰',
          description: 'بچه رئیس و تیم برای محافظت از اسباب‌بازی‌های اتاق بازی یک نقشه فوق‌العاده می‌کشند.',
          streamUrl: 'https://www.aparat.com/v/kudak_bossbaby_1',
          webUrl: 'https://www.aparat.com/result/%D8%A8%DA%86%D9%87+%D8%B1%D8%A6%DB%8C%D8%B3',
          coverEmoji: '🍼',
        ),
      ],
    ),

    // ۱۱. مینیون‌ها
    const Cartoon(
      id: 'minions',
      title: 'مینیون‌ها',
      englishTitle: 'Minions',
      characterName: 'کوین، استوارت، باب کوچولو',
      category: CartoonCategoryType.comedy,
      categoryLabel: 'طنز و خنده‌دار',
      description:
          'موجودات زرد و پرانرژی که عاشق موز و خندیدن هستند و کارهای بامزه‌شان همه را به خنده می‌اندازد.',
      coverEmoji: '🍌',
      themeColor: Color(0xFFF39C12),
      gradient: LinearGradient(
        colors: [Color(0xFFF39C12), Color(0xFFF1C40F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۲۲۰ هزار تماشا',
      ageRating: 'همه سنین',
      learningGoal: 'شادی، تخیل و شوخ‌طبعی کودکانه',
      badgeText: 'فوق‌العاده شاد',
      episodes: [
        CartoonEpisode(
          id: 'minion_ep1',
          episodeNumber: 1,
          title: 'موزهای جادویی و مسابقه دوچرخه',
          duration: '۰۴:۲۰',
          description: 'باب یک موز بزرگ پیدا می‌کند و برای تقسیم آن با دوستانش یک مسابقه خنده‌دار راه می‌افتد.',
          streamUrl: 'https://www.aparat.com/v/kudak_minions_1',
          webUrl: 'https://www.aparat.com/result/%D9%85%DB%8C%D9%86%DB%8C%D9%88%D9%86%D9%87%D8%A7',
          coverEmoji: '🍌',
        ),
      ],
    ),

    // ۱۲. کوکوملون و ترانه‌های شاد فارسی
    const Cartoon(
      id: 'cocomelon_fa',
      title: 'ترانه‌های شاد کوکوملون',
      englishTitle: 'Cocomelon Persian',
      characterName: 'جی‌جی، یویو، تام‌تام',
      category: CartoonCategoryType.musical,
      categoryLabel: 'موزیکال و شعر',
      description:
          'شعرها و ترانه‌های ریتمیک شاد و آموزنده فارسی برای کودکان. یادگیری سلام، تشکر، مسواک زدن و پوشیدن لباس.',
      coverEmoji: '🍉',
      themeColor: Color(0xFF00B894),
      gradient: LinearGradient(
        colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 5.0,
      views: '۲۵۰ هزار تماشا',
      ageRating: '۱ تا ۵ سال',
      learningGoal: 'مهارت‌های فردی روزمره، شعرخوانی و ریتم موزیکال',
      badgeText: 'شعر و آهنگ شاد',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'coco_ep1',
          episodeNumber: 1,
          title: 'ترانه صبح بخیر و شستن دست و صورت',
          duration: '۰۳:۴۵',
          description: 'یک ترانه شاد برای بیدار شدن با لبخند و مسواک زدن تمیز دندان‌ها.',
          streamUrl: 'https://www.aparat.com/v/kudak_cocomelon_1',
          webUrl: 'https://www.aparat.com/result/%DA%A9%D9%88%DA%A9%D9%88%D9%85%D9%84%D9%88%D9%86+%D9%81%D8%A7%D8%B1%D8%B3%DB%8C',
          coverEmoji: '☀️',
        ),
        CartoonEpisode(
          id: 'coco_ep2',
          episodeNumber: 2,
          title: 'شعر رنگین‌کمان و میوه‌های خوشمزه',
          duration: '۰۳:۳۰',
          description: 'یادگیری رنگ میوه‌ها (سیب قرمز، موز زرد، پرتقال نارنجی) با آواز شاد.',
          streamUrl: 'https://www.aparat.com/v/kudak_cocomelon_2',
          webUrl: 'https://www.aparat.com/result/%DA%A9%D9%88%DA%A9%D9%88%D9%85%D9%84%D9%88%D9%86+%D9%81%D8%A7%D8%B1%D8%B3%DB%8C',
          coverEmoji: '🌈',
        ),
      ],
    ),

    // ۱۳. کارتون موزیکال الفبای فارسی
    const Cartoon(
      id: 'alphabet_song_cartoon',
      title: 'ترانه‌های موزیکال الفبا',
      englishTitle: 'Alphabet Songs',
      characterName: 'فندقی و حروف الفبا',
      category: CartoonCategoryType.musical,
      categoryLabel: 'موزیکال و شعر',
      description:
          'انیمیشن‌های شاد و آهنگین برای یادگیری آسان ۳۲ حرف الفبای شیرین فارسی با مثال‌های کودکانه و جذاب.',
      coverEmoji: '🔤',
      themeColor: Color(0xFF9B59B6),
      gradient: LinearGradient(
        colors: [Color(0xFF9B59B6), Color(0xFFE056FD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 5.0,
      views: '۱۶۵ هزار تماشا',
      ageRating: '۴ تا ۸ سال',
      learningGoal: 'آموزش الفبای فارسی، صداها و کلمه‌سازی شاد',
      badgeText: 'آموزش الفبا با شعر',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'alph_ep1',
          episodeNumber: 1,
          title: 'آهنگ شاد الفبا از الف تا خ',
          duration: '۰۴:۱۵',
          description: 'آ مثل آب، ب مثل باران، پ مثل پروانه با تصاویر متحرک و آواز.',
          streamUrl: 'https://www.aparat.com/v/kudak_alphabet_1',
          webUrl: 'https://www.aparat.com/result/%D8%A7%D9%84%D9%81%D8%A8%D8%A7%DB%8C+%D9%81%D8%A7%D8%B1%D8%B3%DB%8C+%DA%A9%D9%88%D8%AF%DA%A9%D8%A7%D9%86%D9%87',
          coverEmoji: '🦋',
        ),
        CartoonEpisode(
          id: 'alph_ep2',
          episodeNumber: 2,
          title: 'آهنگ شاد الفبا از د تا ی',
          duration: '۰۴:۳۰',
          description: 'د مثل دلفین، ر مثل رنگین‌کمان، ی مثل یاسمن در دنیای شعر.',
          streamUrl: 'https://www.aparat.com/v/kudak_alphabet_2',
          webUrl: 'https://www.aparat.com/result/%D8%A7%D9%84%D9%81%D8%A8%D8%A7%DB%8C+%D9%81%D8%A7%D8%B1%D8%B3%DB%8C+%DA%A9%D9%88%D8%AF%DA%A9%D8%A7%D9%86%D9%87',
          coverEmoji: '🐬',
        ),
      ],
    ),

    // ۱۴. کارتون موزیکال اعداد و شمارش
    const Cartoon(
      id: 'numbers_song_cartoon',
      title: 'ترانه‌های شاد شمارش اعداد',
      englishTitle: 'Counting Songs',
      characterName: 'فندقی و جوجه‌ها',
      category: CartoonCategoryType.musical,
      categoryLabel: 'موزیکال و شعر',
      description:
          'شمارش اعداد ۱ تا ۲۰ با شعر، ریتم و حیوانات بامزه که بازی می‌کنند و عددها را به خاطر می‌سپارند.',
      coverEmoji: '🔢',
      themeColor: Color(0xFFE67E22),
      gradient: LinearGradient(
        colors: [Color(0xFFE67E22), Color(0xFFF39C12)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۱۱۰ هزار تماشا',
      ageRating: '۳ تا ۷ سال',
      learningGoal: 'شمارش اعداد، مفهوم جمع و ترتیب عددی',
      badgeText: 'شمارش موزیکال',
      episodes: [
        CartoonEpisode(
          id: 'num_ep1',
          episodeNumber: 1,
          title: 'شمارش ۱۰ ستاره در آسمان شب',
          duration: '۰۳:۲۰',
          description: 'یک، دو، سه تا ده ستاره درخشان با ملودی آرامش‌بخش.',
          streamUrl: 'https://www.aparat.com/v/kudak_numbers_1',
          webUrl: 'https://www.aparat.com/result/%D8%B4%D9%85%D8%A7%D8%B1%D8%B4+%D8%A7%D8%B9%D8%AF%D8%A7%D8%AF+%DA%A9%D9%88%D8%AF%DA%A9%D8%A7%D9%86%D9%87',
          coverEmoji: '⭐',
        ),
      ],
    ),

    // ۱۵. ببعی و ببعو
    const Cartoon(
      id: 'babi_babo',
      title: 'ببعی و ببعو',
      englishTitle: 'Babi and Babo',
      characterName: 'ببعی سفید و ببعو سیاه',
      category: CartoonCategoryType.iranian,
      categoryLabel: 'ایرانی و آموزنده',
      description:
          'انیمیشن پرطرفدار شبکه پویا درباره دو بره دوست‌داشتنی که با کنجکاوی و کمک پدر و مادر مهارت‌های زندگی را یاد می‌گیرند.',
      coverEmoji: '🐑',
      themeColor: Color(0xFF1ABC9C),
      gradient: LinearGradient(
        colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۱۳۵ هزار تماشا',
      ageRating: '۳ تا ۷ سال',
      learningGoal: 'همکاری، صبوری، احترام به دیگران و حل مسئله',
      badgeText: 'محبوب شبکه کودک',
      episodes: [
        CartoonEpisode(
          id: 'babi_ep1',
          episodeNumber: 1,
          title: 'کیک توت‌فرنگی مادر بزرگ',
          duration: '۰۸:۴۵',
          description: 'ببعی و ببعو برای تولد مادربزرگ توت‌فرنگی‌های جنگلی می‌چینند و با هم همکاری می‌کنند.',
          streamUrl: 'https://www.aparat.com/v/kudak_babibabo_1',
          webUrl: 'https://www.aparat.com/result/%D8%A8%D8%A8%D8%B9%DB%8C+%D9%88+%D8%A8%D8%A8%D8%B9%D9%88',
          coverEmoji: '🍓',
        ),
      ],
    ),

    // ۱۶. پوکویو (Pocoyo)
    const Cartoon(
      id: 'pocoyo',
      title: 'پوکویو و دوستان',
      englishTitle: 'Pocoyo',
      characterName: 'پوکویو، پاتو اردک، الی فیل صورتی',
      category: CartoonCategoryType.preschool,
      categoryLabel: 'خردسالان و نوپا',
      description:
          'پوکویو پسر کوچولوی کنجکاو در دنیایی پر از شگفتی‌ها، اشکال و رنگ‌ها با دوستانش بازی و شادی می‌کند.',
      coverEmoji: '🎈',
      themeColor: Color(0xFF3498DB),
      gradient: LinearGradient(
        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.8,
      views: '۱۱۵ هزار تماشا',
      ageRating: '۲ تا ۵ سال',
      learningGoal: 'کشف محیط اطراف، بازی با رنگ‌ها و کنترل احساسات',
      badgeText: 'ویژه نوپایان',
      episodes: [
        CartoonEpisode(
          id: 'poco_ep1',
          episodeNumber: 1,
          title: 'صدای موسیقی در جعبه جادویی',
          duration: '۰۷:۱۰',
          description: 'پوکویو با قاشق و کاسه یک ارکستر شاد راه می‌اندازد!',
          streamUrl: 'https://www.aparat.com/v/kudak_pocoyo_1',
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%88%DA%A9%D9%88%DB%8C%D9%88',
          coverEmoji: '🎺',
        ),
      ],
    ),

    // ۱۷. پاندای کونگ‌فوکار
    const Cartoon(
      id: 'kungfu_panda',
      title: 'پاندای کونگ‌فوکار',
      englishTitle: 'Kung Fu Panda',
      characterName: 'پو، استاد شیفو، ببر، میمون',
      category: CartoonCategoryType.adventure,
      categoryLabel: 'ماجراجویی و نجات',
      description:
          'پاندا شجاع و مهربان با تمرین و پشتکار یاد می‌گیرد که هر کسی با تلاش و باور به خود می‌تواند یک قهرمان بزرگ باشد.',
      coverEmoji: '🐼',
      themeColor: Color(0xFFE74C3C),
      gradient: LinearGradient(
        colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۱۷۰ هزار تماشا',
      ageRating: '۵+',
      learningGoal: 'پشتکار، اعتماد به نفس و مهربانی با همه',
      badgeText: 'قهرمان شجاع',
      episodes: [
        CartoonEpisode(
          id: 'panda_ep1',
          episodeNumber: 1,
          title: 'راز کتیبه اژدهای مهربان',
          duration: '۱۵:۲۰',
          description: 'پو متوجه می‌شود راز قدرت درون قلب هر کسی است که تلاش می‌کند.',
          streamUrl: 'https://www.aparat.com/v/kudak_panda_1',
          webUrl: 'https://www.aparat.com/result/%D9%BE%D8%A7%D9%86%D8%AF%D8%A7%DB%8C+%DA%A9%D9%88%D9%86%DA%AF+%D9%81%D9%88+%DA%A9%D8%A7%D8%B1',
          coverEmoji: '🥋',
        ),
      ],
    ),

    // ۱۸. داستان‌های کهن شاهنامه و کلیله و دمنه
    const Cartoon(
      id: 'persian_classics',
      title: 'داستان‌های کهن ایران',
      englishTitle: 'Persian Classics',
      characterName: 'سیمرغ دانا، زال، رستم دستان',
      category: CartoonCategoryType.classics,
      categoryLabel: 'افسانه‌ها و کهن',
      description:
          'انیمیشن‌های زیبا از داستان‌های پر افتخار شاهنامه فردوسی و حکایت‌های آموزنده کلیله و دمنه به زبان ساده کودکانه.',
      coverEmoji: '🦅',
      themeColor: Color(0xFF8E44AD),
      gradient: LinearGradient(
        colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 5.0,
      views: '۹۰ هزار تماشا',
      ageRating: '۵+',
      learningGoal: 'آشنایی با فرهنگ کهن، راستی، دانایی و وفاداری',
      badgeText: 'فرهنگ و ادب ایران',
      episodes: [
        CartoonEpisode(
          id: 'classic_ep1',
          episodeNumber: 1,
          title: 'سیمرغ و نجات زال در کوه قاف',
          duration: '۱۶:۳۰',
          description: 'پرنده افسانه‌ای مهربان که زال را در آشیانه‌اش بزرگ کرد و راز پر جادویی را به او داد.',
          streamUrl: 'https://www.aparat.com/v/kudak_shahnameh_1',
          webUrl: 'https://www.aparat.com/result/%D8%AF%D8%A7%D8%B3%D8%AA%D8%A7%D9%86%D9%87%D8%A7%DB%8C+%D8%B4%D8%A7%D9%87%D9%86%D8%A7%D9%85%D9%87+%D8%A8%D8%B1%D8%A7%DB%8C+%DA%A9%D9%88%D8%AF%DA%A9%D8%A7%D9%86',
          coverEmoji: '🪶',
        ),
        CartoonEpisode(
          id: 'classic_ep2',
          episodeNumber: 2,
          title: 'حکایت شیر دانا و خرگوش باهوش',
          duration: '۱۰:۲۰',
          description: 'داستان آموزنده کلیله و دمنه درباره پیروزی فکر و عقل بر زور و خشونت.',
          streamUrl: 'https://www.aparat.com/v/kudak_kelileh_1',
          webUrl: 'https://www.aparat.com/result/%DA%A9%D9%84%DB%8C%D9%84%D9%87+%D9%88+%D8%AF%D9%85%D9%86%D9%87+%DA%A9%D9%88%D8%AF%DA%A9%D8%A7%D9%86',
          coverEmoji: '🦁',
        ),
      ],
    ),
  ];

  static Cartoon? getCartoonById(String id) {
    for (final c in allCartoons) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<Cartoon> getFeatured() {
    return allCartoons.where((c) => c.isFeatured).toList();
  }

  static List<Cartoon> getByCategory(CartoonCategoryType cat) {
    if (cat == CartoonCategoryType.all) return allCartoons;
    return allCartoons.where((c) => c.category == cat).toList();
  }

  static List<Cartoon> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allCartoons;
    return allCartoons.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.englishTitle.toLowerCase().contains(q) ||
          c.characterName.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.categoryLabel.toLowerCase().contains(q);
    }).toList();
  }
}
