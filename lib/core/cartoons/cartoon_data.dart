import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎬 JAZIREH FANDOGHI — بانک جامع و فوق‌العاده پیشرفته کارتون‌ها و انیمیشن‌ها
/// ═══════════════════════════════════════════════════════════════

enum CartoonCategoryType {
  all,
  iranian,
  adventure,
  comedy,
  preschool,
  musical,
  classics,
  cinema,
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
  /// هش ویدیوی تأییدشده در آپارات — **تنها منبع مجاز پخش** (وایت‌لیست C2).
  final String? aparatHash;

  /// ⚠️ فقط برای مستندسازی/جستجوی دستی تیم محتوا نگه داشته شده است.
  /// از نسخهٔ ۶٫۲ هرگز برای پیدا کردن یا پخش ویدیو استفاده نمی‌شود؛ پخش
  /// خودکارِ «اولین نتیجهٔ جستجو» یک ریسک ایمنی برای کودک بود و حذف شد.
  final String? searchQuery;

  /// لینک مستقیم اختیاری — پیش از پخش باید از فیلتر دامنه/HTTPS عبور کند.
  final String? streamUrl;
  final String webUrl;
  final String coverEmoji;
  final String? coverAsset;
  final String catchphrase;
  final String triviaQuestion;
  final List<String> triviaOptions;
  final int triviaCorrectIndex;

  const CartoonEpisode({
    required this.id,
    required this.episodeNumber,
    required this.title,
    required this.duration,
    required this.description,
    this.aparatHash,
    this.searchQuery,
    this.streamUrl,
    required this.webUrl,
    required this.coverEmoji,
    this.coverAsset,
    this.catchphrase = '',
    this.triviaQuestion = '',
    this.triviaOptions = const [],
    this.triviaCorrectIndex = 0,
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
  final String? coverAsset;
  final Color themeColor;
  final LinearGradient gradient;
  final double rating;
  final String views;
  final String ageRating;
  final String learningGoal;
  final String badgeText;
  final String catchphrase;
  final bool isFeatured;
  final bool isNew;
  final bool isDubbed;
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
    this.coverAsset,
    required this.themeColor,
    required this.gradient,
    required this.rating,
    required this.views,
    required this.ageRating,
    required this.learningGoal,
    required this.badgeText,
    required this.catchphrase,
    this.isFeatured = false,
    this.isNew = false,
    this.isDubbed = true,
    required this.episodes,
  });
}

class CartoonRank {
  final int level;
  final String title;
  final String emoji;
  final int targetMinutes;
  final Color color;

  const CartoonRank({
    required this.level,
    required this.title,
    required this.emoji,
    required this.targetMinutes,
    required this.color,
  });

  static const List<CartoonRank> ranks = [
    CartoonRank(level: 1, title: 'نوآموز سینما', emoji: '🌱', targetMinutes: 0, color: Color(0xFF74B9FF)),
    CartoonRank(level: 2, title: 'تماشاگر برنزی', emoji: '🥉', targetMinutes: 15, color: Color(0xFFCD7F32)),
    CartoonRank(level: 3, title: 'تماشاگر نقره‌ای', emoji: '🥈', targetMinutes: 45, color: Color(0xFFBDC3C7)),
    CartoonRank(level: 4, title: 'تماشاگر طلایی', emoji: '🥇', targetMinutes: 90, color: Color(0xFFF1C40F)),
    CartoonRank(level: 5, title: 'سلطان کارتون', emoji: '👑', targetMinutes: 150, color: Color(0xFFE056FD)),
  ];

  static CartoonRank currentRank(int watchedMinutes) {
    CartoonRank current = ranks.first;
    for (final r in ranks) {
      if (watchedMinutes >= r.targetMinutes) {
        current = r;
      }
    }
    return current;
  }
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
      type: CartoonCategoryType.cinema,
      title: 'سینمایی و بلند',
      emoji: '🎬',
      color: Color(0xFFFF9F43),
    ),
    CartoonCategory(
      type: CartoonCategoryType.classics,
      title: 'افسانه‌ها و کهن',
      emoji: '📖',
      color: Color(0xFF0984E3),
    ),
  ];

  static final List<Cartoon> allCartoons = <Cartoon>[
    // 1. کوکوملون (CoComelon)
    Cartoon(
      id: 'cocomelon_fa',
      title: 'کوکوملون (CoComelon)',
      englishTitle: 'Cocomelon',
      characterName: 'جی‌جی، یویو، تام‌تام، مامان و بابا',
      category: CartoonCategoryType.preschool,
      categoryLabel: 'خردسالان و نوپا',
      description: 'کارتون جذاب و پرطرفدار کوکوملون درباره پسربچه شیرین و کنجکاوی به نام جی‌جی (JJ)، خواهرش یویو، برادرش تام‌تام و حیوانات مهربانشان است. جی‌جی و خانواده‌اش در هر قسمت ماجراهای روزمره، مهارت‌های زندگی، بهداشت فردی، دوستی و یادگیری الفبا را با داستان‌های شیرین، شاد و آموزنده تجربه می‌کنند.',
      coverEmoji: '🍉',
      coverAsset: 'assets/cartoons/cocomelon.webp',
      themeColor: Color(0xFFE84393),
      gradient: LinearGradient(
        colors: [Color(0xFFE84393), Color(0xFFFF7675)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 5.0,
      views: '۳۴۰ هزار تماشا',
      ageRating: '۲ تا ۶ سال',
      learningGoal: 'آهنگ‌های آموزشی، شستن دست، خواب، شمارش و مهارت‌های روزمره',
      badgeText: 'پرمخاطب‌ترین کودکانه',
      catchphrase: 'کوکوملون: با شعر و آهنگ، یادگیری برای بچه‌ها مثل بازی می‌شه! 🎶',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'coco_ep1',
          episodeNumber: 1,
          title: 'ترانه صبح بخیر و شستن دست و صورت',
          duration: '۱۴:۱۶',
          description: 'بیدار شدن صبح با آهنگ شاد و یادگیری شستن دست قبل از غذا.',
          aparatHash: 'v38wn',
          searchQuery: 'کوکوملون ترانه کودکانه صبح بخیر',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%DA%A9%D9%88%DA%A9%D9%88%D9%85%D9%84%D9%88%D9%86',
          coverEmoji: '🌞',
          triviaQuestion: 'کوکوملون به کودکان چه چیزی را با شعر یاد می‌دهد؟',
          triviaOptions: ['شستن دست و کارهای روزمره 🧼', 'رانندگی ماشین 🚗', 'آشپزی حرفه‌ای 🍳'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'coco_ep2',
          episodeNumber: 2,
          title: 'ترانه‌های شاد کودکانه (مجموعه)',
          duration: '۳۱:۲۹',
          description: 'بهترین آهنگ‌های کوکوملون در یک ویدیوی بلند و شاد.',
          aparatHash: 'vmquf44',
          searchQuery: 'انیمیشن کوکوملون طولانی ترانه کودکانه',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%DA%A9%D9%88%DA%A9%D9%88%D9%85%D9%84%D9%88%D9%86',
          coverEmoji: '🎵',
          triviaQuestion: 'کوکوملون برای چه گروه سنی مناسب است؟',
          triviaOptions: ['خردسالان و نوپا 👶', 'نوجوانان 🧑', 'بزرگسالان 🧑‍🦱'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'coco_ep3',
          episodeNumber: 3,
          title: 'آهنگ‌های کودکانه و نُت‌های شاد',
          duration: '۱۲:۰۰',
          description: 'مجموعه‌ای از نُت‌ها و ترانه‌های کوتاه برای خردسالان.',
          aparatHash: 'TavwM',
          searchQuery: 'کارتون کوکوملون ترانه های کودکانه',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%DA%A9%D9%88%DA%A9%D9%88%D9%85%D9%84%D9%88%D9%86',
          coverEmoji: '🎤',
          triviaQuestion: 'در کوکوملون بیشتر چه چیزی دیده می‌شود؟',
          triviaOptions: ['ترانه و رقص شاد کودکانه 💃', 'مسابقات اتومبیل‌رانی 🏎️', 'اخبار ورزشی ⚽'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 2. سگ‌های نگهبان (پاو پاترول)
    Cartoon(
      id: 'paw_patrol',
      title: 'سگ‌های نگهبان (پاو پاترول)',
      englishTitle: 'Paw Patrol',
      characterName: 'رایدر، چیس، مارشال، اسکای، راکی',
      category: CartoonCategoryType.adventure,
      categoryLabel: 'ماجراجویی و نجات',
      description: 'محبوب‌ترین کارتون نجات در جهان؛ رایدر و توله‌سگ‌های شجاع با ماشین‌ها و بالگردهایشان به کمک دوستان می‌شتابند. دوبله فارسی بسیار شاد.',
      coverEmoji: '🐾',
      coverAsset: 'assets/cartoons/paw_patrol.webp',
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
      catchphrase: 'رایدر: هیچ کاری نیست که نتونیم انجامش بدیم؛ سگ‌های نگهبان آماده‌ان! 🐾',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'paw_ep1',
          episodeNumber: 1,
          title: 'عملیات نجات بزرگ در خلیج',
          duration: '۱۱:۲۰',
          description: 'شهردار در دردسر افتاده و چیس و مارشال سریع‌ترین راه نجات را پیدا می‌کنند!',
          aparatHash: 'eQVFg',
          searchQuery: 'انیمیشن سگ های نگهبان دوبله فارسی قسمت',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%B3%DA%AF%D9%87%D8%A7%DB%8C+%D9%86%DA%AF%D9%87%D8%A8%D8%A7%D9%86',
          coverEmoji: '🚒',
          triviaQuestion: 'کدام سگ نگهبان با آب و نردبان آتش‌نشانی کمک می‌کند؟',
          triviaOptions: ['مارشال (Marshall) 🚒', 'چیس پلیس 👮', 'رابل بولدوزر 🚜'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'paw_ep2',
          episodeNumber: 2,
          title: 'سگ‌های نگهبان — قسمت‌های دوبله فارسی',
          duration: '۲۳:۲۴',
          description: 'مجموعه‌ای از قسمت‌های جذاب پاو پاترول با دوبله فارسی.',
          aparatHash: 'w9CPn',
          searchQuery: 'دانلود کارتون سگهای نگهبان پاوپاترول دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%B3%DA%AF%D9%87%D8%A7%DB%8C+%D9%86%DA%AF%D9%87%D8%A8%D8%A7%D9%86',
          coverEmoji: '🐶',
          triviaQuestion: 'رهبر تیم سگ‌های نگهبان کیست؟',
          triviaOptions: ['رایدر (Ryder) 🧒', 'مارشال 🐕', 'اسکای 🦅'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 3. باب اسفنجی
    Cartoon(
      id: 'spongebob',
      title: 'باب اسفنجی',
      englishTitle: 'SpongeBob SquarePants',
      characterName: 'باب اسفنجی، پاتریک، اختاپوس، آقا خرچنگی',
      category: CartoonCategoryType.comedy,
      categoryLabel: 'طنز و خنده‌دار',
      description: 'خنده‌دارترین و پرمخاطب‌ترین کارتون دنیا در اعماق اقیانوس بیکینی‌باتم با همبرگرهای خوشمزه و حباب‌بازی!',
      coverEmoji: '🧽',
      coverAsset: 'assets/cartoons/spongebob.webp',
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
      catchphrase: 'باب اسفنجی: من آماده‌ام! من آماده‌ام! هوراااا! 🧽',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'sponge_ep1',
          episodeNumber: 1,
          title: 'باب اسفنجی دوبله فارسی (جدید)',
          duration: '۱۱:۳۴',
          description: 'باب اسفنجی و دوستانش در زیردریایی بیکینی‌باتم شیطنت‌های بامزه می‌کنند.',
          aparatHash: 'unj6zlf',
          searchQuery: 'انیمیشن باب اسفنجی دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%A8%D8%A7%D8%A8+%D8%A7%D8%B3%D9%81%D9%86%D8%AC%DB%8C',
          coverEmoji: '🍔',
          triviaQuestion: 'بهترین و صمیمی‌ترین دوست باب اسفنجی کیست؟',
          triviaOptions: ['پاتریک ستاره دریایی ⭐', 'پلانکتون 🧪', 'گری حلزون 🐌'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 4. پپا پیگ فارسی
    Cartoon(
      id: 'peppa_pig',
      title: 'پپا پیگ فارسی',
      englishTitle: 'Peppa Pig',
      characterName: 'پپا، جورج، مامان و بابا خوک',
      category: CartoonCategoryType.preschool,
      categoryLabel: 'خردسالان و نوپا',
      description: 'انیمیشن آموزشی بسیار ملایم و پرمخاطب برای خردسالان. آموزش رفتارهای مؤدبانه، بازی‌های خانوادگی و کشف طبیعت با دوبله فارسی.',
      coverEmoji: '🐷',
      coverAsset: 'assets/cartoons/peppa_pig.webp',
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
      catchphrase: 'پپا: من عاشق پریدن توی چاله‌های گِل با چکمه‌های قرمزم هستم! 🐷',
      episodes: [
        CartoonEpisode(
          id: 'peppa_ep1',
          episodeNumber: 1,
          title: 'پپا پیگ — قسمت ۱ (دوبله)',
          duration: '۰۵:۲۰',
          description: 'پپا چکمه‌های قرمزش را می‌پوشد و با جورج یاد می‌گیرد بعد از بازی دست‌هایش را بشوید.',
          aparatHash: 'Pt63Z',
          searchQuery: 'کارتون پپا پیگ دوبله فارسی قسمت 1',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%BE%D8%A7+%D9%BE%DB%8C%DA%AF',
          coverEmoji: '👢',
          triviaQuestion: 'پپا برای پریدن در چاله‌های گِل چه می‌پوشد؟',
          triviaOptions: ['چکمه‌های مخصوص 👢', 'دمپایی 🩴', 'کفش مهمانی 👠'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'peppa_ep2',
          episodeNumber: 2,
          title: 'پپا پیگ — فصل ۱ (قسمت‌های بیشتر)',
          duration: '۱۱:۰۰',
          description: 'قسمت‌های بیشتر از ماجراهای پپا و خانواده‌اش با دوبله فارسی.',
          aparatHash: '4N5jD',
          searchQuery: 'پپاپیگ دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%BE%D8%A7+%D9%BE%DB%8C%DA%AF',
          coverEmoji: '🌈',
          triviaQuestion: 'برادر کوچک پپا چه نام دارد؟',
          triviaOptions: ['جورج (George) 👶', 'فردی 🐸', 'پدر خوک 🐽'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 5. بره ناقلا (شان)
    Cartoon(
      id: 'shaun_sheep',
      title: 'بره ناقلا (شان)',
      englishTitle: 'Shaun the Sheep',
      characterName: 'شان، بیتزر سگ مزرعه، تیموتی',
      category: CartoonCategoryType.comedy,
      categoryLabel: 'طنز و خنده‌دار',
      description: 'انیمیشن صامت و فوق‌العاده خنده‌دار و پرمخاطب بره زرنگ مزرعه که همیشه نقشه‌های هوشمندانه برای شاد کردن دوستانش می‌کشد.',
      coverEmoji: '🐑',
      coverAsset: 'assets/cartoons/shaun_sheep.webp',
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
      catchphrase: 'شان: بعععع! (با نقشه باهوشانه برای مزرعه!) 🐑',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'shaun_ep1',
          episodeNumber: 1,
          title: 'بره ناقلا — قسمت ۵۹',
          duration: '۰۶:۴۶',
          description: 'شان و گله در مزرعه نقشه‌ای بامزه می‌کشند و سگ مزرعه سعی دارد اوضاع را کنترل کند!',
          aparatHash: 'pZxo6',
          searchQuery: 'کارتون بره ناقلا قسمت',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%A8%D8%B1%D9%87+%D9%86%D8%A7%D9%82%D9%84%D8%A7',
          coverEmoji: '🌾',
          triviaQuestion: 'سگ نگهبان مزرعه چه نام دارد؟',
          triviaOptions: ['بیتزر (Bitzer) 🐕', 'تیموتی 🐑', 'شان 🐑'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'shaun_ep2',
          episodeNumber: 2,
          title: 'انیمیشن بره ناقلا (مجموعه)',
          duration: '۰۷:۰۰',
          description: 'یک قسمت دیگر از ماجراهای خنده‌دار شان و دوستانش.',
          aparatHash: 'c5XEb',
          searchQuery: 'انیمیشن بره ناقلا',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%A8%D8%B1%D9%87+%D9%86%D8%A7%D9%82%D9%84%D8%A7',
          coverEmoji: '💡',
          triviaQuestion: 'بره ناقلا در کجا زندگی می‌کند؟',
          triviaOptions: ['در یک مزرعه 🌾', 'در شهر 🏙️', 'در جنگل 🌲'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 6. پوکویو و دوستان
    Cartoon(
      id: 'pocoyo',
      title: 'پوکویو و دوستان',
      englishTitle: 'Pocoyo',
      characterName: 'پوکویو، پاتو اردک، الی فیل صورتی',
      category: CartoonCategoryType.preschool,
      categoryLabel: 'خردسالان و نوپا',
      description: 'پوکویو پسرک کنجکاو در دنیایی پر از شگفتی با دوستانش بازی و شادی می‌کند؛ یکی از پرمخاطب‌ترین کارتون‌های نوپایان با دوبله فارسی.',
      coverEmoji: '🎈',
      coverAsset: 'assets/cartoons/pocoyo.webp',
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
      catchphrase: 'پوکویو: بیایید با هم کشف کنیم و به صدای دنیا گوش بدیم! 🎈',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'poco_ep1',
          episodeNumber: 1,
          title: 'پوکویو دوبله فارسی — قسمت ۱',
          duration: '۰۷:۱۰',
          description: 'پوکویو با قاشق و کاسه یک ارکستر شاد راه می‌اندازد!',
          aparatHash: 'Ix6NB',
          searchQuery: 'کارتون پوکویو دوبله فارسی قسمت 1',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%88%DA%A9%D9%88%DB%8C%D9%88',
          coverEmoji: '🎺',
          triviaQuestion: 'الی دوست پوکویو چه حیوانی است؟',
          triviaOptions: ['فیل صورتی مهربان 🐘', 'اردک زرد 🦆', 'سگ قهوه‌ای 🐕'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'poco_ep2',
          episodeNumber: 2,
          title: 'پوکویو جدید — دوبله فارسی',
          duration: '۰۸:۰۰',
          description: 'قسمت‌های جدید پوکویو با دوبله شاد فارسی.',
          aparatHash: 'k17j35o',
          searchQuery: 'کارتون پوکویو جدید دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%88%DA%A9%D9%88%DB%8C%D9%88',
          coverEmoji: '🪀',
          triviaQuestion: 'پوکویو بیشتر چه کارهایی انجام می‌دهد؟',
          triviaOptions: ['کشف و بازی و شادی 🎈', 'مسابقه اتومبیل‌رانی 🏎️', 'آشپزی حرفه‌ای 🍳'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'poco_ep3',
          episodeNumber: 3,
          title: 'پوکویو با دوبله فارسی (بیشتر)',
          duration: '۰۹:۳۰',
          description: 'ماجراهای بیشتر از پوکویو و دوستانش.',
          aparatHash: 'scuzukr',
          searchQuery: 'کارتون پوکویو با دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%88%DA%A9%D9%88%DB%8C%D9%88',
          coverEmoji: '🌟',
          triviaQuestion: 'پوکویو کنجکاو است و دوست دارد چه کند؟',
          triviaOptions: ['کشف دنیای اطراف 🔍', 'فقط بخوابد 😴', 'فقط غذا بخورد 🍎'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 7. تام و جری
    Cartoon(
      id: 'tom_jerry',
      title: 'تام و جری',
      englishTitle: 'Tom and Jerry',
      characterName: 'تام گربه، جری موش، اسپایک',
      category: CartoonCategoryType.comedy,
      categoryLabel: 'طنز و خنده‌دار',
      description: 'پرطرفدارترین کارتون کلاسیک دنیا؛ دعوای بامزه و بی‌کلام گربه و موش که نسل‌ها را خندانده است.',
      coverEmoji: '🐭',
      coverAsset: 'assets/cartoons/tom_jerry.webp',
      themeColor: Color(0xFFE67E22),
      gradient: LinearGradient(
        colors: [Color(0xFFE67E22), Color(0xFFF39C12)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 5.0,
      views: '۲۸۰ هزار تماشا',
      ageRating: '۳+',
      learningGoal: 'طنز سالم، پیگیری هدف و خلاقیت',
      badgeText: 'کلاسیک جاویدان',
      catchphrase: 'تام و جری: دعوای ما فقط برای خنده‌ست! 🐭🐱',
      episodes: [
        CartoonEpisode(
          id: 'tom_ep1',
          episodeNumber: 1,
          title: 'تام و جری — کالکشن ۱۲۰ دقیقه‌ای',
          duration: '۴۵:۰۰',
          description: 'بهترین قسمت‌های تام و جری در یک ویدیوی بلند و خنده‌دار.',
          aparatHash: 'h66t00o',
          searchQuery: 'تام و جری کالکشن کامل',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%AA%D8%A7%D9%85+%D9%88+%D8%AC%D8%B1%DB%8C',
          coverEmoji: '🎬',
          triviaQuestion: 'در تام و جری کی موش است؟',
          triviaOptions: ['جری (Jerry) 🐭', 'تام 🐱', 'اسپایک 🐶'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'tom_ep2',
          episodeNumber: 2,
          title: 'کارتون تام و جری (قسمت)',
          duration: '۱۰:۰۰',
          description: 'یک قسمت جذاب و خنده‌دار از ماجراهای تام و جری.',
          aparatHash: 'w42222p',
          searchQuery: 'کارتون تام و جری',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%AA%D8%A7%D9%85+%D9%88+%D8%AC%D8%B1%DB%8C',
          coverEmoji: '😹',
          triviaQuestion: 'تام در این کارتون چه حیوانی است؟',
          triviaOptions: ['گربه 🐱', 'سگ 🐶', 'اردک 🦆'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 8. مینیون‌ها
    Cartoon(
      id: 'minions',
      title: 'مینیون‌ها',
      englishTitle: 'Minions',
      characterName: 'باب، کِوین، استیو و بقیه مینیون‌ها',
      category: CartoonCategoryType.comedy,
      categoryLabel: 'طنز و خنده‌دار',
      description: 'انیمیشن خنده‌دار و پرانرژی مینیون‌ها درباره موجودات زرد و بامزه‌ای مانند باب، کوین و استیو است که با زبان شیرین و شیطنت‌های بی‌پایان خود، اهمیت دوستی، همکاری گروهی و شادی را به نمایش می‌گذارند.',
      coverEmoji: '🍌',
      coverAsset: 'assets/cartoons/minions.webp',
      themeColor: Color(0xFFFDCB6E),
      gradient: LinearGradient(
        colors: [Color(0xFFFDCB6E), Color(0xFFE1B12C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۲۳۰ هزار تماشا',
      ageRating: '۴+',
      learningGoal: 'دوستی، همکاری و شادی ساده',
      badgeText: 'زردهای دوست‌داشتنی',
      catchphrase: 'مینیون‌ها: بانانااا! 🍌 (ما آماده‌ایم!)',
      episodes: [
        CartoonEpisode(
          id: 'minion_ep1',
          episodeNumber: 1,
          title: 'انیمیشن مینیون‌ها — دوبله فارسی',
          duration: '۰۸:۰۰',
          description: 'ماجراهای بامزه مینیون‌ها با دوبله فارسی.',
          aparatHash: '2cDv6',
          searchQuery: 'انیمیشن مینیون ها دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%85%DB%8C%D9%86%DB%8C%D9%88%D9%86%D9%87%D8%A7',
          coverEmoji: '🍌',
          triviaQuestion: 'مینیون‌ها چه غذایی را خیلی دوست دارند؟',
          triviaOptions: ['موز 🍌', 'پیتزا 🍕', 'هندوانه 🍉'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 9. بچه رئیس
    Cartoon(
      id: 'boss_baby',
      title: 'بچه رئیس',
      englishTitle: 'The Boss Baby',
      characterName: 'بچه رئیس، تیم برادر بزرگتر',
      category: CartoonCategoryType.cinema,
      categoryLabel: 'سینمایی و بلند',
      description: 'انیمیشن جذاب بچه رئیس درباره نوزادی باهوش با کت‌وشلوار و کراوات است که با برادر بزرگترش تیم، یک تیم مخفی و ماجراجویانه تشکیل می‌دهند. این کارتون مفهوم برادری، همکاری خانوادگی و مسئولیت را آموزش می‌دهد.',
      coverEmoji: '👶',
      coverAsset: 'assets/cartoons/boss_baby.webp',
      themeColor: Color(0xFF0984E3),
      gradient: LinearGradient(
        colors: [Color(0xFF0984E3), Color(0xFF6C5CE7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.8,
      views: '۱۵۵ هزار تماشا',
      ageRating: '۵+',
      learningGoal: 'برادری، مسئولیت‌پذیری و همکاری خانوادگی',
      badgeText: 'سینمایی پرمخاطب',
      catchphrase: 'بچه رئیس: اینجا من رئیم! گوش به زنگ باشید! 👶',
      episodes: [
        CartoonEpisode(
          id: 'boss_ep1',
          episodeNumber: 1,
          title: 'بچه رئیس — دوبله فارسی',
          duration: '۱۰:۰۰',
          description: 'ماجراهای بچه رئیس و برادرش با دوبله فارسی.',
          aparatHash: 'ascozv3',
          searchQuery: 'انیمیشن بچه رئیس دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%A8%DA%86%D9%87+%D8%B1%D8%A6%DB%8C%D8%B3',
          coverEmoji: '💼',
          triviaQuestion: 'بچه رئیس چه لباسی می‌پوشد؟',
          triviaOptions: ['کت‌وشلوار و کراوات 👔', 'لباس فضانوردی 🚀', 'لباس پلیس 👮'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'boss_ep2',
          episodeNumber: 2,
          title: 'کارتون بچه رئیس جدید — دوبله فارسی',
          duration: '۱۱:۰۰',
          description: 'قسمت‌های جدید بچه رئیس با دوبله شاد فارسی.',
          aparatHash: 'zmnha03',
          searchQuery: 'کارتون بچه رئیس دوبله فارسی جدید',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%A8%DA%86%D9%87+%D8%B1%D8%A6%DB%8C%D8%B3',
          coverEmoji: '📁',
          triviaQuestion: 'بچه رئیس با چه کسی همکاری می‌کند؟',
          triviaOptions: ['برادرش تیم 👦', 'یک گربه 🐱', 'یک فضایی 👽'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 10. مک‌کویین و ماشین‌ها
    Cartoon(
      id: 'cars_mcqueen',
      title: 'مک‌کویین و ماشین‌ها',
      englishTitle: 'Cars',
      characterName: 'مک‌کویین، ساتر، متر',
      category: CartoonCategoryType.adventure,
      categoryLabel: 'ماجراجویی و نجات',
      description: 'کارتون پرطرفدار ماشین‌ها درباره ماشین مسابقه‌ای سریع و مهربانی به نام لایتنینگ مک‌کویین و دوست وفادارش مِتِر است. مک‌کویین در جاده‌ها و مسابقات یاد می‌گیرد که دوستی و اخلاق مهم‌تر از پیروزی است.',
      coverEmoji: '🏎️',
      coverAsset: 'assets/cartoons/cars_mcqueen.webp',
      themeColor: Color(0xFFE74C3C),
      gradient: LinearGradient(
        colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۱۷۰ هزار تماشا',
      ageRating: '۴+',
      learningGoal: 'پشتکار، دوستی و رقابت سالم',
      badgeText: 'دوبله فارسی',
      catchphrase: 'مک‌کویین: سریع‌ترین راه برای بردن، دوستیه! 🏎️',
      episodes: [
        CartoonEpisode(
          id: 'cars_ep1',
          episodeNumber: 1,
          title: 'مک‌کویین — ماشین‌ها ۳ (دوبله فارسی)',
          duration: '۰۳:۳۵',
          description: 'سکانس‌هایی از انیمیشن ماشین‌ها ۳ با دوبله فارسی.',
          aparatHash: 'biyy8yy',
          searchQuery: 'مک کویین ماشین های ۳ دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%DA%A9%D8%A7%D8%B1%D8%AA%D9%88%D9%86+%D9%85%D8%A7%D8%B4%DB%8C%D9%86%D9%87%D8%A7',
          coverEmoji: '🚗',
          triviaQuestion: 'قهرمان این کارتون چه نام دارد؟',
          triviaOptions: ['مک‌کویین (McQueen) 🏎️', 'متر 🚕', 'ساتر 🚙'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'cars_ep2',
          episodeNumber: 2,
          title: 'کارتون ماشین‌بازی کودکانه — مک‌کویین',
          duration: '۰۴:۵۲',
          description: 'بهترین ماشین‌های رادیاتور مک‌کوئین برای کودکان.',
          aparatHash: '74MCc',
          searchQuery: 'کارتون ماشین بازی کودکانه ماشین مک کویین',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%DA%A9%D8%A7%D8%B1%D8%AA%D9%88%D9%86+%D9%85%D8%A7%D8%B4%DB%8C%D9%86%D9%87%D8%A7',
          coverEmoji: '🔧',
          triviaQuestion: 'مک‌کویین در چه مسابقه‌ای شرکت می‌کند؟',
          triviaOptions: ['مسابقه ماشین‌رانی 🏁', 'شنا 🏊', 'شطرنج ♟️'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 11. پاندای کونگ‌فوکار
    Cartoon(
      id: 'kungfu_panda',
      title: 'پاندای کونگ‌فوکار',
      englishTitle: 'Kung Fu Panda',
      characterName: 'پو، استاد شیفو، ببر، میمون',
      category: CartoonCategoryType.adventure,
      categoryLabel: 'ماجراجویی و نجات',
      description: 'انیمیشن سینمایی و شکوهمند پاندای کونگ‌فوکار درباره پو، پاندای مهربان و شکمویی است که با راهنمایی استاد شیفو و تمرین و پشتکار، به یک پهلوان شجاع و مدافع خوبی‌ها تبدیل می‌شود.',
      coverEmoji: '🐼',
      coverAsset: 'assets/cartoons/kungfu_panda.webp',
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
      catchphrase: 'پو: راز یک قهرمان بزرگ، قلب پاک و پشتکار است! 🐼',
      episodes: [
        CartoonEpisode(
          id: 'panda_ep1',
          episodeNumber: 1,
          title: 'پاندای کونگ‌فوکار — دوبله فارسی',
          duration: '۱۵:۲۰',
          description: 'پو متوجه می‌شود راز قدرت درون قلب هر کسی است که تلاش می‌کند.',
          aparatHash: 'p069coy',
          searchQuery: 'کارتون پاندای کونگ فو کار دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%BE%D8%A7%D9%86%D8%AF%D8%A7%DB%8C+%DA%A9%D9%88%D9%86%DA%AF+%D9%81%D9%88+%DA%A9%D8%A7%D8%B1',
          coverEmoji: '🥋',
          triviaQuestion: 'پو پاندای قهرمان چگونه به هدفش رسید؟',
          triviaOptions: ['با تمرین و ناامید نشدن 🥋', 'با تنبلی ❌', 'با تسلیم شدن ❌'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'panda_ep2',
          episodeNumber: 2,
          title: 'پاندای کونگ‌فوکار ۲ — ۷۲۰p HD',
          duration: '۱۰:۰۰',
          description: 'قسمت دوم ماجراهای پو با کیفیت HD و دوبله فارسی.',
          aparatHash: 'z80fm7p',
          searchQuery: 'پاندای کونگ فو کار 2 دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%BE%D8%A7%D9%86%D8%AF%D8%A7%DB%8C+%DA%A9%D9%88%D9%86%DA%AF+%D9%81%D9%88+%DA%A9%D8%A7%D8%B1',
          coverEmoji: '🐾',
          triviaQuestion: 'استاد پو در هنر رزم چه کسی است؟',
          triviaOptions: ['استاد شیفو 🦊', 'ببر 🐯', 'میمون 🐵'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 12. بن‌تن (Ben 10)
    Cartoon(
      id: 'ben10',
      title: 'بن‌تن (Ben 10)',
      englishTitle: 'Ben 10',
      characterName: 'بن، گوئن، پدربزرگ مکس',
      category: CartoonCategoryType.adventure,
      categoryLabel: 'ماجراجویی و نجات',
      description: 'کارتون اکشن و ماجراجویانه بن‌تن درباره پسر نوجوانی به نام بن است که با ساعت فضایی جادویی خود (اومنیتریکس) می‌تواند برای دفاع از مردم و زمین به قهرمانان مختلف تبدیل شود.',
      coverEmoji: '👾',
      coverAsset: 'assets/cartoons/ben10.webp',
      themeColor: Color(0xFF00CEC9),
      gradient: LinearGradient(
        colors: [Color(0xFF00CEC9), Color(0xFF0984E3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.8,
      views: '۱۴۰ هزار تماشا',
      ageRating: '۶+',
      learningGoal: 'شجاعت، تصمیم‌درست و مسئولیت‌پذیری',
      badgeText: 'اکشن و ماجراجویی',
      catchphrase: 'بن‌تن: با اومنیتریکس، هیچ دشمنی گزنده نیست! 👾',
      episodes: [
        CartoonEpisode(
          id: 'ben_ep1',
          episodeNumber: 1,
          title: 'بن‌تن ریبوت — قسمت ۱۰ (دوبله فارسی)',
          duration: '۱۱:۲۸',
          description: 'بن با قدرت‌های جدیدش با دشمنان مبارزه می‌کند.',
          aparatHash: 'vXxN6',
          searchQuery: 'بن تن ریبوت دوبله فارسی قسمت',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%A8%D9%86+%D8%AA%D9%86',
          coverEmoji: '🛸',
          triviaQuestion: 'بن با چه وسیله‌ای قدرت‌هایش را می‌گیرد؟',
          triviaOptions: ['ساعت اومنیتریکس ⌚', 'یک حلقه 💍', 'یک کلاه 🎩'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'ben_ep2',
          episodeNumber: 2,
          title: 'کارتون بن‌تن ۲۰۱۶ — دوبله فارسی',
          duration: '۱۰:۰۰',
          description: 'قسمت‌هایی از بن‌تن ۲۰۱۶ با دوبله فارسی.',
          aparatHash: '9WN7H',
          searchQuery: 'کارتون بن تن 2016 دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%A8%D9%86+%D8%AA%D9%86',
          coverEmoji: '🔥',
          triviaQuestion: 'همراه همیشگی بن کیست؟',
          triviaOptions: ['پسرخاله‌اش گوئن 🧒', 'یک گربه 🐱', 'یک سگ 🐕'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 13. شکرستان
    Cartoon(
      id: 'shekarestan',
      title: 'شکرستان',
      englishTitle: 'Shekarestan',
      characterName: 'بهلول، اسکندر کوچولو، خواجه فرزان',
      category: CartoonCategoryType.iranian,
      categoryLabel: 'ایرانی و آموزنده',
      description: 'محبوب‌ترین کارتون ایرانی با داستان‌های شیرین، طنز و آموزنده در شهر شکرستان و قصه‌های پر از حکمت و خنده.',
      coverEmoji: '🏰',
      coverAsset: 'assets/cartoons/shekarestan.webp',
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
      catchphrase: 'بهلول: ای قاضی محترم! باد آورده را باد می‌برد! 🏰',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'shekar_ep1',
          episodeNumber: 1,
          title: 'شکرستان قسمت ۱',
          duration: '۱۳:۴۰',
          description: 'صمد و خواجه الماس به دنبال گنجی در غار قدیمی شهر می‌گردند اما بهلول راه‌حل بهتری دارد!',
          aparatHash: 'vfvn9il',
          searchQuery: 'شکرستان قسمت 1',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%B4%DA%A9%D8%B1%D8%B3%D8%AA%D8%A7%D9%86',
          coverEmoji: '🗝️',
          triviaQuestion: 'در ماجرای غار، بهلول چه چیزی را بالاتر از طلا دانست؟',
          triviaOptions: ['عقل، دانایی و دوستی 💡', 'سنگ‌های براق 💎', 'تنهایی و سکوت 🤐'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'shekar_ep2',
          episodeNumber: 2,
          title: 'شکرستان فصل ۱ قسمت ۵ — سلطان موش‌ها',
          duration: '۱۴:۱۵',
          description: 'ماجرای خنده‌دار سلطان موش‌ها در شهر شکرستان.',
          aparatHash: 'qto57e8',
          searchQuery: 'شکرستان سلطان موش ها',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%B4%DA%A9%D8%B1%D8%B3%D8%AA%D8%A7%D9%86',
          coverEmoji: '🐭',
          triviaQuestion: 'بهلول در شکرستان بیشتر چه نقشی دارد؟',
          triviaOptions: ['قاضی دانا و راهنما 🧠', 'فرمانده جنگی ⚔️', 'تاجر ثروتمند 💰'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 14. پهلوانان
    Cartoon(
      id: 'pahlavanan',
      title: 'پهلوانان',
      englishTitle: 'Pahlavanan',
      characterName: 'پوریای ولی، یاور، صفی و مفرد',
      category: CartoonCategoryType.iranian,
      categoryLabel: 'ایرانی و آموزنده',
      description: 'محبوب‌ترین انیمیشن ایرانی درباره پوریای ولی و شاگردان وفادارش در زورخانه شهر خوارزم. آموزش جوانمردی، کمک به نیازمندان و ایستادگی در برابر ستم.',
      coverEmoji: '⚔️',
      coverAsset: 'assets/cartoons/pahlavanan.webp',
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
      badgeText: 'شاهکار انیمیشن ایران',
      catchphrase: 'پوریای ولی: تن و جان پاک دار و دل با خدا، مروت پیشه کن در هر کجا! ⚔️',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'pahla_ep1',
          episodeNumber: 1,
          title: 'پهلوانان قسمت ۱ — کباده پهلوان حیدر',
          duration: '۳۰:۲۰',
          description: 'پوریای ولی به شاگردانش یاد می‌دهد که قدرت واقعی در مهار خشم و کمک به ضعیفان است.',
          aparatHash: 'YmHI0',
          searchQuery: 'انیمیشن پهلوانان قسمت 1 کباده پهلوان حیدر',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%BE%D9%87%D9%84%D9%88%D8%A7%D9%86%D8%A7%D9%86',
          coverEmoji: '🛡️',
          triviaQuestion: 'پوریای ولی قدرت واقعی پهلوان را در چه می‌داند؟',
          triviaOptions: ['مهار خشم و دستگیری از نیازمندان 🛡️', 'فقط زور بازو 💪', 'پیروزی به هر قیمتی ❌'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 15. پسر دلفینی
    Cartoon(
      id: 'dolphin_boy',
      title: 'پسر دلفینی',
      englishTitle: 'Dolphin Boy',
      characterName: 'پسر دلفینی، سفیدبال، ناخدا مروارید',
      category: CartoonCategoryType.cinema,
      categoryLabel: 'سینمایی و بلند',
      description: 'پرمخاطب‌ترین انیمیشن سینمایی ایران درباره پسری که در آغوش دلفین‌های خلیج فارس بزرگ شد و برای نجات دریا با هیولای دریاها مبارزه می‌کند.',
      coverEmoji: '🐬',
      coverAsset: 'assets/cartoons/dolphin_boy.webp',
      themeColor: Color(0xFF00CEC9),
      gradient: LinearGradient(
        colors: [Color(0xFF00CEC9), Color(0xFF0984E3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 5.0,
      views: '۳۱۰ هزار تماشا',
      ageRating: '۴+',
      learningGoal: 'مهر مادر، شجاعت، دوستی با حیوانات و محیط زیست دریا',
      badgeText: 'سینمایی شاهکار',
      catchphrase: 'پسر دلفینی: دریا خانه ماست، با هم از آن مراقبت می‌کنیم! 🐬',
      isFeatured: true,
      episodes: [
        CartoonEpisode(
          id: 'dolphin_ep1',
          episodeNumber: 1,
          title: 'انیمیشن پسر دلفینی قسمت ۲',
          duration: '۲۰:۰۰',
          description: 'ماجراجویی پسر دلفینی در اعماق خلیج نیلگون.',
          aparatHash: '8p09E',
          searchQuery: 'انیمیشن پسر دلفینی قسمت',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%BE%D8%B3%D8%B1+%D8%AF%D9%84%D9%81%DB%8C%D9%86%DB%8C',
          coverEmoji: '🌊',
          triviaQuestion: 'پسر دلفینی در کنار چه موجوداتی بزرگ شد؟',
          triviaOptions: ['دلفین‌های مهربان 🐬', 'کوسه‌های خطرناک 🦈', 'اختاپوس‌ها 🐙'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'dolphin_ep2',
          episodeNumber: 2,
          title: 'فیلم سینمایی پسر دلفین کامل',
          duration: '۲۵:۰۰',
          description: 'نسخه کامل انیمیشن سینمایی پسر دلفینی.',
          aparatHash: 'zgd2h95',
          searchQuery: 'فیلم سینمایی پسر دلفین کامل',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%BE%D8%B3%D8%B1+%D8%AF%D9%84%D9%81%DB%8C%D9%86%DB%8C',
          coverEmoji: '💙',
          triviaQuestion: 'پسر دلفینی برای چه چیزی می‌جنگد؟',
          triviaOptions: ['نجات دریا و مادرش 🌊', 'جمع‌آوری طلا 💰', 'بردن مسابقه 🏆'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 16. لوپتو و کارگاه اسباب‌بازی
    Cartoon(
      id: 'loopeto',
      title: 'لوپتو و کارگاه اسباب‌بازی',
      englishTitle: 'Lupeto',
      characterName: 'علی، فرشته امید، اسباب‌بازی‌های زنده',
      category: CartoonCategoryType.cinema,
      categoryLabel: 'سینمایی و بلند',
      description: 'انیمیشن سینمایی و موزیکال ایرانی لوپتو درباره علی و کارگاه اسباب‌بازی‌های دست‌ساز ایرانی است. علی با خلاقیت، امید و شادی تلاش می‌کند تا با ساخت اسباب‌بازی‌های زیبا، لبخند را به کودکان هدیه کند.',
      coverEmoji: '🧸',
      coverAsset: 'assets/cartoons/loopeto.webp',
      themeColor: Color(0xFFE84393),
      gradient: LinearGradient(
        colors: [Color(0xFFE84393), Color(0xFFFF7675)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۱۷۵ هزار تماشا',
      ageRating: '۴+',
      learningGoal: 'امید، انگیزه، خودباوری و خلاقیت ساخت وسایل دستی',
      badgeText: 'موزیکال و پرانرژی',
      catchphrase: 'علی: با دست‌های خودمان زیباترین اسباب‌بازی‌ها را می‌سازیم! 🧸',
      episodes: [
        CartoonEpisode(
          id: 'loopeto_ep1',
          episodeNumber: 1,
          title: 'انیمیشن لوپتو (کامل)',
          duration: '۲۲:۱۵',
          description: 'اسباب‌بازی‌های دست‌ساز علی زنده می‌شوند و برای نجات کارگاه نقشه می‌کشند.',
          aparatHash: '9LytT',
          searchQuery: 'دانلود کامل انیمیشن لوپتو',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%84%D9%88%D9%BE%D8%AA%D9%88',
          coverEmoji: '🎨',
          triviaQuestion: 'اسباب‌بازی‌های لوپتو با چه چیزی ساخته می‌شدند؟',
          triviaOptions: ['با دست و عشق و خلاقیت 🧸🎨', 'با کامپیوتر 💻', 'با آهن‌پاره ⚙️'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 17. دیرین دیرین کودکانه
    Cartoon(
      id: 'dirin_dirin',
      title: 'دیرین دیرین کودکانه',
      englishTitle: 'Dirin Dirin',
      characterName: 'دیرین، دیرینو، حیوانات جنگل',
      category: CartoonCategoryType.iranian,
      categoryLabel: 'ایرانی و آموزنده',
      description: 'مجموعه انیمیشن‌های کوتاه و طنز ایرانی دیرین دیرین با شخصیت‌های بامزه، نکات مهم محیط‌زیستی، فرهنگ شهروندی، بازیافت و مهربانی با طبیعت را به زبان ساده و خنده‌دار آموزش می‌دهد.',
      coverEmoji: '🌿',
      coverAsset: 'assets/cartoons/dirin_dirin.webp',
      themeColor: Color(0xFF2ECC71),
      gradient: LinearGradient(
        colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.9,
      views: '۲۲۰ هزار تماشا',
      ageRating: '۳+',
      learningGoal: 'محیط‌زیست، بازیافت، رفتار شهروندی و مهربانی',
      badgeText: 'پیام‌آموز ایران',
      catchphrase: 'دیرین دیرین: زمین را برای فردا نگه داریم! 🌍',
      episodes: [
        CartoonEpisode(
          id: 'dirin_ep1',
          episodeNumber: 1,
          title: 'دیرین دیرین — فصل دوم (قسمت)',
          duration: '۰۱:۲۱',
          description: 'یک قسمت کوتاه و آموزنده از دیرین دیرین.',
          aparatHash: 'cpdwu',
          searchQuery: 'انیمیشن دیرین دیرین فصل دوم',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%AF%DB%8C%D8%B1%DB%8C%D9%86+%D8%AF%DB%8C%D8%B1%DB%8C%D9%86',
          coverEmoji: '🌱',
          triviaQuestion: 'پیام اصلی دیرین دیرین چیست؟',
          triviaOptions: ['محیط‌زیست و مهربانی 🌍', 'جنگ و دعوا ⚔️', 'ولخرجی 💸'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'dirin_ep2',
          episodeNumber: 2,
          title: 'دیرین دیرین — قسمت کوتاه دیگر',
          duration: '۰۱:۳۰',
          description: 'قسمت کوتاه دیگری با پیام آموزشی.',
          aparatHash: 'visdtjz',
          searchQuery: 'برنامه کودک کارتون حمام با داداشی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%AF%DB%8C%D8%B1%DB%8C%D9%86+%D8%AF%DB%8C%D8%B1%DB%8C%D9%86',
          coverEmoji: '♻️',
          triviaQuestion: 'دیرین دیرین کجا ساخته می‌شود؟',
          triviaOptions: ['ایران 🇮🇷', 'آمریکا 🇺🇸', 'ژاپن 🇯🇵'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 18. ببعی و ببعو
    Cartoon(
      id: 'babi_babo',
      title: 'ببعی و ببعو',
      englishTitle: 'Babi and Babo',
      characterName: 'ببعی سفید و ببعو سیاه',
      category: CartoonCategoryType.iranian,
      categoryLabel: 'ایرانی و آموزنده',
      description: 'کارتون شاد و آموزنده ایرانی ببعی و ببعو درباره دو بره کنجکاو و دوست‌داشتنی در مزرعه است که با کمک پدر و مادر خود، مهارت‌های روزمره زندگی، صبوری و همکاری را تمرین می‌کنند.',
      coverEmoji: '🐏',
      coverAsset: 'assets/cartoons/babi_babo.webp',
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
      catchphrase: 'ببعی: با مهربانی و صبوری، همه کارها آسان می‌شود! 🐑',
      episodes: [
        CartoonEpisode(
          id: 'babi_ep1',
          episodeNumber: 1,
          title: 'کارتون ببعی شبکه پویا — ببعی و ببعو',
          duration: '۰۸:۵۰',
          description: 'ببعی و ببعو برای تولد مادربزرگ توت‌فرنگی‌های جنگلی می‌چینند و با هم همکاری می‌کنند.',
          aparatHash: 'k9HyM',
          searchQuery: 'کارتون ببعی و ببعو شبکه پویا',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%A8%D8%A8%D8%B9%DB%8C+%D9%88+%D8%A8%D8%A8%D8%B9%D9%88',
          coverEmoji: '🍓',
          triviaQuestion: 'ببعی و ببعو برای چه کسی کیک توت‌فرنگی پختند؟',
          triviaOptions: ['مادربزرگ مهربان 👵', 'گرگ جنگل 🐺', 'روباه مکار 🦊'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'babi_ep2',
          episodeNumber: 2,
          title: 'انیمیشن ببعی ببعو — قسمت دیگر',
          duration: '۰۹:۳۱',
          description: 'قسمت دیگری از ماجراهای آموزنده ببعی و ببعو.',
          aparatHash: 'hLDwe',
          searchQuery: 'انیمیشن ببعی ببعو قسمت',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D8%A8%D8%A8%D8%B9%DB%8C+%D9%88+%D8%A8%D8%A8%D8%B9%D9%88',
          coverEmoji: '🌼',
          triviaQuestion: 'ببعی و ببعو چه جانورانی هستند؟',
          triviaOptions: ['بره / گوسفند 🐑', 'گربه 🐱', 'خرگوش 🐰'],
          triviaCorrectIndex: 0,
        ),
      ],
    ),

    // 19. وای فوق‌العاده (Super Why)
    Cartoon(
      id: 'super_why',
      title: 'وای فوق‌العاده (Super Why)',
      englishTitle: 'Super Why!',
      characterName: 'وای فوق‌العاده، واندر رد، خوک آلفا، پرنسس پرستو',
      category: CartoonCategoryType.preschool,
      categoryLabel: 'خردسالان و نوپا',
      description: 'کارتون آموزشی و محبوب وای فوق‌العاده (Super Why) درباره گروهی از دوستان در دهکدهٔ قصه‌هاست. آن‌ها با ورود به کتاب‌ها تبدیل به ابرقهرمانان خواندن می‌شوند و با حروف الفبا، کلمه‌سازی و خواندن، مشکلاتشان را حل می‌کنند. دوبله فارسی.',
      coverEmoji: '📚',
      coverAsset: 'assets/cartoons/super_why.webp',
      themeColor: Color(0xFF2ECC71),
      gradient: LinearGradient(
        colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      rating: 4.8,
      views: '۹۵ هزار تماشا',
      ageRating: '۳ تا ۶ سال',
      learningGoal: 'خواندن، حروف الفبا، واژه‌سازی و حل مسئله',
      badgeText: 'آموزش خواندن',
      catchphrase: 'وای فوق‌العاده: با قدرت خواندن، هر مشکلی حل می‌شه! 📚',
      isNew: true,
      episodes: [
        CartoonEpisode(
          id: 'swhy_ep1',
          episodeNumber: 1,
          title: 'وای فوق‌العاده — قسمت ۱ (فصل ۱)',
          duration: '۲۵:۱۱',
          description: 'جیل دائم برج خوک را می‌اندازد و خوک ناراحت است؛ ابرخوانندگان وارد کتاب می‌شوند تا با هم راه‌حل پیدا کنند.',
          aparatHash: 'n94bn15',
          searchQuery: 'وای فوق العاده Super Why قسمت 1 دوبله فارسی',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%88%D8%A7%DB%8C%20%D9%81%D9%88%D9%82%20%D8%A7%D9%84%D8%B9%D8%A7%D8%AF%D9%87',
          coverEmoji: '📖',
          triviaQuestion: 'دوستان در وای فوق‌العاده با چه مهارتی مشکلات را حل می‌کنند؟',
          triviaOptions: ['خواندن و کلمه‌سازی 📖', 'رانندگی 🚗', 'آشپزی 🍳'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'swhy_ep2',
          episodeNumber: 2,
          title: 'وای فوق‌العاده — قسمت ۱۲',
          duration: '۲۵:۱۱',
          description: 'یک قسمت آموزنده و شاد دیگر از ماجراهای ابرخوانندگان با دوبله فارسی.',
          aparatHash: 'rYdF5',
          searchQuery: 'انیمیشن سریالی وای فوق العاده Super Why قسمت 12',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%88%D8%A7%DB%8C%20%D9%81%D9%88%D9%82%20%D8%A7%D9%84%D8%B9%D8%A7%D8%AF%D9%87',
          coverEmoji: '🦸',
          triviaQuestion: 'شخصیت‌های وای فوق‌العاده کجا زندگی می‌کنند؟',
          triviaOptions: ['در دهکدهٔ قصه‌ها 🏘️', 'در فضا 🚀', 'در اعماق دریا 🌊'],
          triviaCorrectIndex: 0,
        ),
        CartoonEpisode(
          id: 'swhy_ep3',
          episodeNumber: 3,
          title: 'وای فوق‌العاده — قسمت ۴۶',
          duration: '۲۴:۰۹',
          description: 'قسمت دیگری از وای فوق‌العاده برای تمرین خواندن و یادگیری واژه‌های جدید.',
          aparatHash: 'mrvY9',
          searchQuery: 'انیمیشن سریالی وای فوق العاده Super Why قسمت 46',
          streamUrl: null,
          webUrl: 'https://www.aparat.com/result/%D9%88%D8%A7%DB%8C%20%D9%81%D9%88%D9%82%20%D8%A7%D9%84%D8%B9%D8%A7%D8%AF%D9%87',
          coverEmoji: '🔤',
          triviaQuestion: 'هدف اصلی کارتون وای فوق‌العاده چیست؟',
          triviaOptions: ['یاد دادن خواندن و الفبا 🔤', 'آموزش رانندگی 🚗', 'آموزش آشپزی 🍳'],
          triviaCorrectIndex: 0,
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
