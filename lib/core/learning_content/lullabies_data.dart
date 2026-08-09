import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════
/// 🌙 LULLABIES DATA — لالایی‌های آرام برای خواب کودکان
/// ۱۰ لالایی شیرین، آرامبخش، با متن کودکانه و تصویر اختصاصی
/// ═══════════════════════════════════════════════════════

enum LullabyMood { calm, dreamy, nature, sweet }

class Lullaby {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String coverEmoji;
  final String coverAsset;
  final String audioAsset;
  final String duration;
  final Color themeColor;
  final LinearGradient gradient;
  final List<String> lyrics;
  final String lullabyMessage;
  final LullabyMood mood;

  const Lullaby({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.coverEmoji,
    required this.coverAsset,
    required this.audioAsset,
    required this.duration,
    required this.themeColor,
    required this.gradient,
    required this.lyrics,
    required this.lullabyMessage,
    required this.mood,
  });
}

class LullabiesData {
  static const List<Lullaby> all = [
    // ۱. لالایی ماه و ستاره
    Lullaby(
      id: 'lullaby_moon_stars',
      title: 'لالایی ماه و ستاره',
      subtitle: 'خواب زیر نور مهتاب نقره‌ای',
      description: 'ماه نقره‌ای بالای سرت نگهبانی می‌دهد و ستاره‌ها برایت چشمک می‌زنند.',
      coverEmoji: '🌙',
      coverAsset: 'assets/lullabies/lullaby_moon_stars.png',
      audioAsset: 'assets/audio/lullabies/lullaby_moon_stars.mp3',
      duration: '۲:۳۰',
      themeColor: Color(0xFF3949AB),
      gradient: LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      mood: LullabyMood.dreamy,
      lyrics: [
        'لا لا لا، گلِ نازم بخواب',
        'ماهِ قشنگ، نگهبونِ توئه',
        'ستاره‌ها، چشمک می‌زنن',
        'خوابِ شیرین، مهمونِ توئه',
        '',
        'چشماتو ببند، آروم بگیر',
        'قصه‌ی ماه، تو گوشته',
        'فردا صبح، خورشید میاد',
        'دنیا پر از شادیه',
      ],
      lullabyMessage: 'ماه و ستاره‌ها همیشه مراقب خواب شیرین تو هستند.',
    ),

    // ۲. خرس کوچولوی خواب‌آلود
    Lullaby(
      id: 'lullaby_sleepy_bear',
      title: 'خرس کوچولوی خواب‌آلود',
      subtitle: 'خرسی که عسلش را خورد و خوابید',
      description: 'خرس کوچولویی بعد از یک روز بازی، کنار مامانش به خواب می‌رود.',
      coverEmoji: '🐻',
      coverAsset: 'assets/lullabies/lullaby_sleepy_bear.png',
      audioAsset: 'assets/audio/lullabies/lullaby_sleepy_bear.mp3',
      duration: '۲:۱۵',
      themeColor: Color(0xFF8D6E63),
      gradient: LinearGradient(colors: [Color(0xFF4E342E), Color(0xFFA1887F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      mood: LullabyMood.calm,
      lyrics: [
        'لا لا لا، خرسِ نازم بخواب',
        'عسل خوردی، حالا بخواب',
        'مامان خرسه، پیشته',
        'بغلِ گرم، همیشه هست',
        '',
        'چشمِ قشنگتو ببند',
        'خوابِ پنبه‌ای ببین',
        'فردا باز، بازی کنیم',
        'تو باغِ سبز و نازنین',
      ],
      lullabyMessage: 'آغوش گرم خانواده، امن‌ترین جای خواب است.',
    ),

    // ۳. باران آرام
    Lullaby(
      id: 'lullaby_gentle_rain',
      title: 'لالایی باران آرام',
      subtitle: 'صدای نم‌نم باران روی پنجره',
      description: 'باران آرام روی شیشه می‌بارد و تو را به خوابی عمیق می‌برد.',
      coverEmoji: '🌧️',
      coverAsset: 'assets/lullabies/lullaby_gentle_rain.png',
      audioAsset: 'assets/audio/lullabies/lullaby_gentle_rain.mp3',
      duration: '۲:۴۰',
      themeColor: Color(0xFF0288D1),
      gradient: LinearGradient(colors: [Color(0xFF01579B), Color(0xFF4FC3F7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      mood: LullabyMood.nature,
      lyrics: [
        'نم نم بارون، رو شیشه',
        'می‌زنه آروم، همیشه',
        'لا لا لا، بخواب عزیزم',
        'بارون برات، لالایی می‌خونه',
        '',
        'ابرِ سفید، خوابه خوابه',
        'چک چک آب، مثلِ خوابه',
        'چشماتو ببند، گوش کن',
        'بارونِ ناز، برات می‌خونه',
      ],
      lullabyMessage: 'صدای طبیعت، آرام‌ترین لالایی جهان است.',
    ),

    // ۴. قایق خواب
    Lullaby(
      id: 'lullaby_dream_boat',
      title: 'قایق خواب',
      subtitle: 'سفر با قایق کوچک روی دریای آرام',
      description: 'قایق کوچکت روی دریای آرام می‌لغزد و تو را به سرزمین خواب می‌برد.',
      coverEmoji: '⛵',
      coverAsset: 'assets/lullabies/lullaby_dream_boat.png',
      audioAsset: 'assets/audio/lullabies/lullaby_dream_boat.mp3',
      duration: '۲:۲۰',
      themeColor: Color(0xFF00ACC1),
      gradient: LinearGradient(colors: [Color(0xFF006064), Color(0xFF4DD0E1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      mood: LullabyMood.dreamy,
      lyrics: [
        'قایقِ کوچیک، رو آبه',
        'می‌بره تو رو، به خوابه',
        'لا لا لا، بخواب گلم',
        'دریا آرومه، بخواب',
        '',
        'موجِ کوچیک، تاب می‌ده',
        'خوابِ قشنگ، خواب می‌ده',
        'چشمِ نازت، ببند عزیزم',
        'فردا صبح، بیدار میشی',
      ],
      lullabyMessage: 'هر شب سفری آرام به سرزمین رویاهای شیرین داری.',
    ),

    // ۵. فرشته نگهبان
    Lullaby(
      id: 'lullaby_guardian_angel',
      title: 'فرشته نگهبان',
      subtitle: 'فرشته‌ای که بالای سرت می‌ماند',
      description: 'فرشته مهربان با بال‌های سفید، تمام شب نگهبان خواب توست.',
      coverEmoji: '👼',
      coverAsset: 'assets/lullabies/lullaby_guardian_angel.png',
      audioAsset: 'assets/audio/lullabies/lullaby_guardian_angel.mp3',
      duration: '۲:۳۵',
      themeColor: Color(0xFFFFB74D),
      gradient: LinearGradient(colors: [Color(0xFFF57C00), Color(0xFFFFCC80)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      mood: LullabyMood.sweet,
      lyrics: [
        'فرشته‌ی ناز، بال داره',
        'پیشِ توئه، بیداره',
        'لا لا لا، نترس عزیزم',
        'فرشته مراقبته',
        '',
        'بالِ سفید، نرم و لطیف',
        'سایه‌ش رو، سرت می‌ندازه',
        'خوابِ آروم، ببین گلم',
        'صبحِ قشنگ، در انتظاره',
      ],
      lullabyMessage: 'تو تنها نیستی؛ فرشته مهربان همیشه کنارت است.',
    ),

    // ۶. باغ گل‌ها
    Lullaby(
      id: 'lullaby_flower_garden',
      title: 'لالایی باغ گل‌ها',
      subtitle: 'خوابیدن میان عطر گل‌های رنگارنگ',
      description: 'در باغی پر از گل رز و یاس، نسیم آرام لالایی می‌خواند.',
      coverEmoji: '🌸',
      coverAsset: 'assets/lullabies/lullaby_flower_garden.png',
      audioAsset: 'assets/audio/lullabies/lullaby_flower_garden.mp3',
      duration: '۲:۲۵',
      themeColor: Color(0xFFE91E63),
      gradient: LinearGradient(colors: [Color(0xFFAD1457), Color(0xFFF48FB1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      mood: LullabyMood.sweet,
      lyrics: [
        'گلِ رزِ قشنگ، خوابه',
        'عطرِ یاس، تو خوابه',
        'لا لا لا، بخواب گلم',
        'باغِ گل، خوابه خوابه',
        '',
        'پروانه‌ها، خوابیدن',
        'زنبورا هم، خوابیدن',
        'تو هم بخواب، نازنینم',
        'فردا گل‌ها، بیدار میشن',
      ],
      lullabyMessage: 'عطر گل‌ها و نسیم، خواب را شیرین‌تر می‌کند.',
    ),

    // ۷. گهواره چوبی
    Lullaby(
      id: 'lullaby_wooden_cradle',
      title: 'گهواره چوبی',
      subtitle: 'تابِ آرام گهواره مامان',
      description: 'گهواره چوبی آرام تاب می‌خورد و مامان برایت لالایی می‌خواند.',
      coverEmoji: '🪵',
      coverAsset: 'assets/lullabies/lullaby_wooden_cradle.png',
      audioAsset: 'assets/audio/lullabies/lullaby_wooden_cradle.mp3',
      duration: '۲:۱۰',
      themeColor: Color(0xFF6D4C41),
      gradient: LinearGradient(colors: [Color(0xFF3E2723), Color(0xFFBCAAA4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      mood: LullabyMood.calm,
      lyrics: [
        'گهواره تاب می‌خوره',
        'مامان لالایی می‌خونه',
        'لا لا لا، بخواب عزیزم',
        'مامان پیشته، نترسی',
        '',
        'تاب تاب، تابِ قشنگ',
        'خوابِ ناز، خوابِ قشنگ',
        'چشماتو ببند، بخواب',
        'فردا باز، بازی کنیم',
      ],
      lullabyMessage: 'تاب گهواره و صدای مامان، گرم‌ترین لالایی است.',
    ),

    // ۸. پرنده کوچک
    Lullaby(
      id: 'lullaby_little_bird',
      title: 'پرنده کوچک',
      subtitle: 'جوجه‌ای که در لانه‌اش خوابید',
      description: 'پرنده کوچک در لانه گرمش، زیر پرهای مامانش به خواب رفته.',
      coverEmoji: '🐦',
      coverAsset: 'assets/lullabies/lullaby_little_bird.png',
      audioAsset: 'assets/audio/lullabies/lullaby_little_bird.mp3',
      duration: '۲:۲۰',
      themeColor: Color(0xFF43A047),
      gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF81C784)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      mood: LullabyMood.nature,
      lyrics: [
        'جوجه‌ی کوچیک، تو لونه',
        'خوابیده پیشِ مامانش',
        'لا لا لا، تو هم بخواب',
        'مثلِ جوجه، ناز و آروم',
        '',
        'مامان پرنده، بال داره',
        'گرم نگهت می‌داره',
        'چشماتو ببند، بخواب',
        'خوابِ پرنده، ببین',
      ],
      lullabyMessage: 'مثل پرنده کوچک در آغوش گرم خانواده بخواب.',
    ),

    // ۹. دریا و صدف
    Lullaby(
      id: 'lullaby_ocean_shell',
      title: 'دریا و صدف',
      subtitle: 'صدای آرام موج و صدف دریایی',
      description: 'موج‌های آرام دریا و صدف‌های سفید، لالایی دریا را می‌خوانند.',
      coverEmoji: '🐚',
      coverAsset: 'assets/lullabies/lullaby_ocean_shell.png',
      audioAsset: 'assets/audio/lullabies/lullaby_ocean_shell.mp3',
      duration: '۲:۴۵',
      themeColor: Color(0xFF0097A7),
      gradient: LinearGradient(colors: [Color(0xFF006064), Color(0xFF80DEEA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      mood: LullabyMood.nature,
      lyrics: [
        'دریا آرومه، موج میاد',
        'صدفِ قشنگ، خواب میاد',
        'لا لا لا، بخواب گلم',
        'دریا برات، لالایی می‌خونه',
        '',
        'شن‌های نرم، گرم و لطیف',
        'ماه رو آب، می‌تابه',
        'چشمِ نازت، ببند عزیزم',
        'خوابِ دریا، ببین',
      ],
      lullabyMessage: 'صدای موج دریا، آرامش را به قلبت می‌آورد.',
    ),

    // ۱۰. فندقی و خواب شیرین
    Lullaby(
      id: 'lullaby_fandoghi_sleep',
      title: 'فندقی و خواب شیرین',
      subtitle: 'فندقی هم خوابش میاد',
      description: 'فندقی بعد از یک روز پر از بازی و یادگیری، حالا وقت خواب شیرین است.',
      coverEmoji: '🌰',
      coverAsset: 'assets/lullabies/lullaby_fandoghi_sleep.png',
      audioAsset: 'assets/audio/lullabies/lullaby_fandoghi_sleep.mp3',
      duration: '۲:۳۰',
      themeColor: Color(0xFFFF8F00),
      gradient: LinearGradient(colors: [Color(0xFFE65100), Color(0xFFFFB74D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      mood: LullabyMood.sweet,
      lyrics: [
        'فندقی ناز، خوابش میاد',
        'چشماشو، می‌بنده',
        'لا لا لا، تو هم بخواب',
        'فندقی پیشته، بخواب',
        '',
        'امروز خیلی، بازی کردیم',
        'خیلی چیزا، یاد گرفتیم',
        'حالا وقتِ، خوابِ نازه',
        'فردا باز، بیدار میشیم',
      ],
      lullabyMessage: 'فندقی هم مثل تو خواب شیرین می‌بیند — شب بخیر کوچولوی نازم!',
    ),
  ];

  static Lullaby? byId(String id) {
    for (final l in all) {
      if (l.id == id) return l;
    }
    return null;
  }
}
