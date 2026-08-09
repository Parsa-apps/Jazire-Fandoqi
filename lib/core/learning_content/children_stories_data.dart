import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📚 CHILDREN STORIES DATA — قصه‌خانه مصور و آموزشی کودکان (نسخه پیشرفته)
/// ۱۰ داستان کامل، مصور، همراه با کلمات طلایی و مسابقه درک مطلب
/// ═══════════════════════════════════════════════════════════════

enum StoryCategoryType {
  all,
  friendship,
  nature,
  adventure,
  morals,
}

class StoryCategoryInfo {
  final StoryCategoryType type;
  final String title;
  final String emoji;
  final Color color;

  const StoryCategoryInfo({
    required this.type,
    required this.title,
    required this.emoji,
    required this.color,
  });
}

class StoryVocabularyWord {
  final String word;
  final String emoji;
  final String meaning;

  const StoryVocabularyWord({
    required this.word,
    required this.emoji,
    required this.meaning,
  });
}

class StoryQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const StoryQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class ChildrenStoryPage {
  final int pageNumber;
  final String title;
  final String text;
  final String? imageAsset;
  final String fallbackEmoji;
  final String interactiveQuestion;
  final List<StoryVocabularyWord> goldenWords;

  const ChildrenStoryPage({
    required this.pageNumber,
    required this.title,
    required this.text,
    this.imageAsset,
    required this.fallbackEmoji,
    required this.interactiveQuestion,
    this.goldenWords = const [],
  });
}

class ChildrenStory {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String coverEmoji;
  final String? coverAsset;
  final StoryCategoryType category;
  final String categoryLabel;
  final String readingTime;
  final String moralMessage;
  final Color themeColor;
  final LinearGradient gradient;
  final List<ChildrenStoryPage> pages;
  final List<StoryQuizQuestion> quizQuestions;
  final bool isFeatured;

  const ChildrenStory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.coverEmoji,
    this.coverAsset,
    required this.category,
    required this.categoryLabel,
    required this.readingTime,
    required this.moralMessage,
    required this.themeColor,
    required this.gradient,
    required this.pages,
    required this.quizQuestions,
    this.isFeatured = false,
  });
}

class ChildrenStoriesData {
  static const List<StoryCategoryInfo> categories = [
    StoryCategoryInfo(
      type: StoryCategoryType.all,
      title: 'همه داستان‌ها',
      emoji: '📚',
      color: Color(0xFF5C6BC0),
    ),
    StoryCategoryInfo(
      type: StoryCategoryType.friendship,
      title: 'دوستی و مهربانی',
      emoji: '🤝',
      color: Color(0xFF7E57C2),
    ),
    StoryCategoryInfo(
      type: StoryCategoryType.nature,
      title: 'طبیعت و حیوانات',
      emoji: '🌲',
      color: Color(0xFF43A047),
    ),
    StoryCategoryInfo(
      type: StoryCategoryType.adventure,
      title: 'ماجراجویی و شجاعت',
      emoji: '🚀',
      color: Color(0xFFFB8C00),
    ),
    StoryCategoryInfo(
      type: StoryCategoryType.morals,
      title: 'پند و اخلاق',
      emoji: '🌟',
      color: Color(0xFFE91E63),
    ),
  ];

  static const List<ChildrenStory> allStories = [
    // ──────────────────────────────────────────────
    // ۱. فندقی و خرس کوچولوی مهربان
    // ──────────────────────────────────────────────
    ChildrenStory(
      id: 'story_bear_friendship',
      title: 'فندقی و خرس کوچولوی مهربان',
      subtitle: 'ماجرای ساختن پل دوستی در جنگل سبز',
      description: 'فندقی در یک روز آفتابی در جنگل با خرس کوچولویی آشنا می‌شود که می‌خواهد از رودخانه خروشان عبور کند. آن‌ها با همکاری هم پلی زیبا می‌سازند.',
      coverEmoji: '🐻',
      coverAsset: 'assets/stories/story_1_page_1.png',
      category: StoryCategoryType.friendship,
      categoryLabel: 'دوستی و مهربانی',
      readingTime: '۴ دقیقه',
      moralMessage: 'همکاری و کمک به دوستان، کارهای سخت را آسان و شیرین می‌کند.',
      themeColor: Color(0xFF8D6E63),
      gradient: LinearGradient(
        colors: [Color(0xFF6D4C41), Color(0xFFA1887F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isFeatured: true,
      pages: [
        ChildrenStoryPage(
          pageNumber: 1,
          title: 'دیدار در کنار رودخانه خروشان',
          text: 'یک روز صبح زود، وقتی خورشید طلایی تازه به درختان جنگل تابیده بود، فندقی کوله‌پشتی کوچکش را برداشت تا در جنگل قدم بزند. صدای آواز پرندگان و عطر گل‌های وحشی همه‌جا را پر کرده بود. ناگهان در کنار رودخانه، خرس کوچولویی به نام «پشمالو» را دید که ناراحت نشسته است. پشمالو گفت: «فندقی جان! کندوی عسل من آن طرف رودخانه است، اما آب رودخانه خیلی تند و عمیق است و من نمی‌توانم عبور کنم!» فندقی لبخندی زد و گفت: «نگران نباش، ما با هم یک راه خوب پیدا می‌کنیم.»',
          imageAsset: 'assets/stories/story_1_page_1.png',
          fallbackEmoji: '🐻',
          interactiveQuestion: 'اگر تو جای فندقی بودی، چه پیشنهادی به خرس کوچولو می‌دادی؟',
          goldenWords: [
            StoryVocabularyWord(word: 'خروشان', emoji: '🌊', meaning: 'آب تند، پر سر و صدا و پرقدرت'),
            StoryVocabularyWord(word: 'کوله‌پشتی', emoji: '🎒', meaning: 'کیفی که روی شانه و پشت قرار می‌گیرد'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 2,
          title: 'ساختن پل چوبی با همکاری هم',
          text: 'فندقی و پشمالو تصمیم گرفتند با شاخه‌های خشک و محکم درختان افتاده، یک پل قوی بسازند. فندقی شاخه‌های کوچک‌تر را جمع می‌کرد و پشمالو با دست‌های قوی خود تنه‌های بزرگ را کنار هم قرار می‌داد. آن‌ها با بندهای گیاهی شاخه‌ها را محکم به هم گره زدند. هر بار که خسته می‌شدند، به هم امید می‌دادند و می‌خندیدند. بعد از یک ساعت تلاش، پل چوبی و زیبای آن‌ها آماده شد. پرندگان جنگل روی شاخه‌ها نشستند و برای کار گروهی آن‌ها آواز خواندند.',
          imageAsset: 'assets/stories/story_1_page_2.png',
          fallbackEmoji: '🪵',
          interactiveQuestion: 'چرا کار کردن با دوستان، سریع‌تر از کار تنهایی پیش می‌رود؟',
          goldenWords: [
            StoryVocabularyWord(word: 'همکاری', emoji: '🤝', meaning: 'کار کردن با هم برای رسیدن به یک هدف مشترک'),
            StoryVocabularyWord(word: 'امیدواری', emoji: '🌟', meaning: 'باور داشتن به اینکه اتفاق‌های خوب می‌افتد'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 3,
          title: 'جشن عسل و شیرینی دوستی',
          text: 'پشمالو با خوشحالی و آرامش از روی پل عبور کرد و کندوی عسل تازه و معطرش را آورد. او به فندقی گفت: «بدون کمک و فکر عالی تو، هرگز نمی‌توانستم به اینجا برسم! این عسل شیرین هدیه دوستی ماست.» فندقی و پشمالو زیر سایه درخت بلوط نشستند و با هم عسل خوردند. فندقی فهمید که شیرین‌ترین چیز در دنیا، داشتن یک دوست خوب و کمک کردن به دیگران است.',
          imageAsset: 'assets/stories/story_1_page_3.png',
          fallbackEmoji: '🍯',
          interactiveQuestion: 'آخرین باری که به یکی از دوستان یا خانواده‌ات کمک کردی کی بود؟',
          goldenWords: [
            StoryVocabularyWord(word: 'معطر', emoji: '🌸', meaning: 'خوشبو و دارای عطر شیرین'),
            StoryVocabularyWord(word: 'هدیه', emoji: '🎁', meaning: 'چیزی که با عشق به کسی می‌دهیم'),
          ],
        ),
      ],
      quizQuestions: [
        StoryQuizQuestion(
          question: 'فندقی و خرس کوچولو برای عبور از رودخانه چه چیزی ساختند؟',
          options: ['یک پل چوبی 🪵', 'یک قایق کاغذی ⛵', 'یک بادکنک بزرگ 🎈'],
          correctIndex: 0,
          explanation: 'آفرین! آن‌ها با هم از شاخه‌ها و تنه‌های درخت یک پل چوبی محکم ساختند.',
        ),
        StoryQuizQuestion(
          question: 'پشمالو به عنوان هدیه دوستی چه چیزی به فندقی داد؟',
          options: ['هویج تازه 🥕', 'عسل شیرین 🍯', 'سیب سرخ 🍎'],
          correctIndex: 1,
          explanation: 'دقیقا! پشمالو کندوی عسل شیرین و خوشمزه‌اش را با فندقی تقسیم کرد.',
        ),
      ],
    ),

    // ──────────────────────────────────────────────
    // ۲. سفر پروانه طلایی به باغ گل‌ها
    // ──────────────────────────────────────────────
    ChildrenStory(
      id: 'story_golden_butterfly',
      title: 'سفر پروانه طلایی به باغ گل‌ها',
      subtitle: 'قصه شجاعت و صبر یک کرم ابریشم کوچک',
      description: 'کرم ابریشم کوچکی به نام «حنا» آرزو داشت پرواز کند. او با صبر در برابر باران و باد مقاومت کرد تا روزی به پروانه‌ای درخشان تبدیل شد.',
      coverEmoji: '🦋',
      coverAsset: 'assets/stories/story_2_page_3.png',
      category: StoryCategoryType.adventure,
      categoryLabel: 'ماجراجویی و شجاعت',
      readingTime: '۴ دقیقه',
      moralMessage: 'با صبر و تلاش، بزرگ‌ترین آرزوها هم به حقیقت تبدیل می‌شوند.',
      themeColor: Color(0xFFAB47BC),
      gradient: LinearGradient(
        colors: [Color(0xFF8E24AA), Color(0xFFCE93D8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isFeatured: true,
      pages: [
        ChildrenStoryPage(
          pageNumber: 1,
          title: 'آرزوی بزرگ حنا کوچولو',
          text: 'حنا، کرم ابریشم سبز و کوچکی بود که روی برگ‌های پهن درخت توت زندگی می‌کرد. او هر روز به پرندگان و زنبورها نگاه می‌کرد که آزادانه در آسمان آبی پرواز می‌کردند. حنا با خودش می‌گفت: «چقدر شگفت‌انگیز است که بتوانی باغ‌های دوردست را از بالا ببینی!» بعضی از حشره‌ها به او می‌گفتند: «تو خیلی کوچکی، همیشه روی همین برگ‌ها خواهی ماند.» اما حنا در قلبش می‌دانست که روزی نوبت پرواز او هم می‌رسد.',
          imageAsset: 'assets/stories/story_2_page_1.png',
          fallbackEmoji: '🐛',
          interactiveQuestion: 'بزرگ‌ترین آرزوی تو چیست که دوست داری به آن برسی؟',
          goldenWords: [
            StoryVocabularyWord(word: 'آرزو', emoji: '✨', meaning: 'خواستن یک اتفاق زیبا برای آینده'),
            StoryVocabularyWord(word: 'شگفت‌انگیز', emoji: '🤩', meaning: 'بسیار جالب و هیجان‌انگیز'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 2,
          title: 'مقاومت در روز بارانی و سرد',
          text: 'یک روز عصر، باران بهاری و باد شدیدی شروع به وزیدن کرد. قطره‌های درشت باران برگ‌ها را تکان می‌دادند. حنا با شجاعت خودش را به ساقه درخت چسباند و یک پیله ابریشمی گرم و نرم دور خودش بافت. درون پیله تاریک و ساکت بود، اما حنا نمی‌ترسید. او با صبر انتظار کشید و می‌دانست که برای بزرگ شدن و تغییر کردن، گاهی باید صبور بود و سختی‌ها را تحمل کرد.',
          imageAsset: 'assets/stories/story_2_page_2.png',
          fallbackEmoji: '🌧️',
          interactiveQuestion: 'وقتی با یک کار سخت یا انتظار طولانی روبرو می‌شوی چه کار می‌کنی؟',
          goldenWords: [
            StoryVocabularyWord(word: 'پیله', emoji: '🧶', meaning: 'خانه‌ای کوچک و ابریشمی برای رشد کردن'),
            StoryVocabularyWord(word: 'صبور', emoji: '🧘', meaning: 'کسی که آرامش دارد و عجله نمی‌کند'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 3,
          title: 'پرواز به سوی گل‌های رز',
          text: 'چند روز بعد، خورشید گرم و مهربان دوباره تابید. پیله حنا آرام‌آرام باز شد و او بال‌های طلایی و زیبایش را باز کرد. حنا دیگر کرم ابریشم کوچک نبود؛ او به یک پروانه طلایی خیره‌کننده تبدیل شده بود! وقتی به پرواز درآمد، نسیم او را به سمت باغ گل‌های رز و نیلوفر برد. گل‌ها با شادی به حنا خوش‌آمد گفتند. حنا فهمید که صبر و امیدواری، زیباترین پاداش‌ها را به همراه دارد.',
          imageAsset: 'assets/stories/story_2_page_3.png',
          fallbackEmoji: '🦋',
          interactiveQuestion: 'چرا صبر کردن باعث موفقیت‌های بزرگ می‌شود؟',
          goldenWords: [
            StoryVocabularyWord(word: 'خیره‌کننده', emoji: '🌟', meaning: 'بسیار زیبا و درخشان'),
            StoryVocabularyWord(word: 'نسیم', emoji: '🍃', meaning: 'باد ملایم، خنک و دلنشین'),
          ],
        ),
      ],
      quizQuestions: [
        StoryQuizQuestion(
          question: 'حنا در ابتدای داستان چه حیوانی بود؟',
          options: ['یک کرم ابریشم سبز 🐛', 'یک کفشدوزک قرمز 🐞', 'یک زنبور عسل 🐝'],
          correctIndex: 0,
          explanation: 'آفرین! حنا یک کرم ابریشم کوچک و بااراده بود.',
        ),
        StoryQuizQuestion(
          question: 'حنا بعد از صبر کردن در پیله به چه چیزی تبدیل شد؟',
          options: ['یک پرنده کوچک 🐦', 'یک پروانه طلایی 🦋', 'یک گل نیلوفر 🌸'],
          correctIndex: 1,
          explanation: 'دقیقا! او بال‌های طلایی درآورد و تبدیل به پروانه‌ای زیبا شد.',
        ),
      ],
    ),

    // ──────────────────────────────────────────────
    // ۳. موش‌موشی و راز دانه هلو
    // ──────────────────────────────────────────────
    ChildrenStory(
      id: 'story_peach_seed',
      title: 'موش‌موشی و راز دانه هلو',
      subtitle: 'داستان مراقبت از زمین و درختکاری',
      description: 'موش‌موشی دانه صورتی یک هلو را در دشت پیدا می‌کند. او به جای دور انداختن، آن را می‌کارد و با مهر از آن مراقبت می‌کند.',
      coverEmoji: '🍑',
      coverAsset: 'assets/stories/story_3_page_3.png',
      category: StoryCategoryType.nature,
      categoryLabel: 'طبیعت و حیوانات',
      readingTime: '۴ دقیقه',
      moralMessage: 'مراقبت از طبیعت و کاشتن درخت، زمین را برای همه زیباتر می‌کند.',
      themeColor: Color(0xFF43A047),
      gradient: LinearGradient(
        colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isFeatured: false,
      pages: [
        ChildrenStoryPage(
          pageNumber: 1,
          title: 'پیدا کردن دانه جادویی در دشت',
          text: 'موش‌موشی در حال بازی در دشت سرسبز بود که ناگهان چشمش به یک دانه درشت و چوبی افتاد. دانه، هسته یک هلوی شیرین بود که کسی آن را جا گذاشته بود. موش‌موشی دانه را بو کرد و با خودش گفت: «اگر این دانه را زیر خاک پنهان کنم و به آن آب بدهم، شاید یک روز درخت زیبایی شود!» او با پنجه‌های کوچکش گودالی نرم کند و دانه را با مهربانی در دل خاک گذاشت.',
          imageAsset: 'assets/stories/story_3_page_1.png',
          fallbackEmoji: '🌱',
          interactiveQuestion: 'آیا تا به حال دانه یا گلی را در گلدان یا باغچه کاشته‌ای؟',
          goldenWords: [
            StoryVocabularyWord(word: 'هسته', emoji: '🌰', meaning: 'دانه سفت وسط میوه‌ها مثل هلو و زردآلو'),
            StoryVocabularyWord(word: 'گودال', emoji: '🕳️', meaning: 'چاله‌ای کوچک که در خاک کنده می‌شود'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 2,
          title: 'آبیاری روزانه و انتظار سبز',
          text: 'هر روز صبح، موش‌موشی با آب‌پاش کوچکش به سراغ باغچه می‌رفت. او آب تازه چشمه را پای خاک می‌ریخت و حتی برای دانه کوچک شعر می‌خواند. روزها گذشت؛ ابتدا هیچ خبری نبود، اما یک روز صبح، دو جوانه سبز و کوچک از زیر خاک بیرون آمدند! موش‌موشی از خوشحالی فریاد زد: «سلام جوانه کوچولو! به دنیا خوش آمدی.» او اطراف جوانه را تمیز کرد تا نور خورشید به خوبی به آن برسد.',
          imageAsset: 'assets/stories/story_3_page_2.png',
          fallbackEmoji: '🌿',
          interactiveQuestion: 'گیاهان برای رشد کردن به چه چیزهایی نیاز دارند؟',
          goldenWords: [
            StoryVocabularyWord(word: 'آبیاری', emoji: '💧', meaning: 'آب دادن به گیاهان و درخت‌ها'),
            StoryVocabularyWord(word: 'جوانه', emoji: '🌱', meaning: 'برگ و ساقه تازه و کوچکی که از خاک بیرون می‌آید'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 3,
          title: 'درخت پربار و شادی حیوانات جنگل',
          text: 'با گذشت زمان، آن جوانه کوچک به درختی تنومند با شکوفه‌های صورتی و سپس هلوهای آبدار و شیرین تبدیل شد! موش‌موشی همه دوستانش؛ سنجاب، خرگوش و پرنده‌ها را دعوت کرد تا از میوه‌های درخت بخورند. درختی که با محبت و صبر موش‌موشی کاشته شده بود، اکنون سایه و خوراکی همه حیوانات شده بود. همه از موش‌موشی به خاطر کار ارزشمندش تشکر کردند.',
          imageAsset: 'assets/stories/story_3_page_3.png',
          fallbackEmoji: '🍑',
          interactiveQuestion: 'کاشتن درخت چه فایده‌هایی برای حیوانات و انسان‌ها دارد؟',
          goldenWords: [
            StoryVocabularyWord(word: 'تنومند', emoji: '🌳', meaning: 'بزرگ، قوی و محکم'),
            StoryVocabularyWord(word: 'شکوفه', emoji: '🌸', meaning: 'گل‌های زیبای درختان میوه در فصل بهار'),
          ],
        ),
      ],
      quizQuestions: [
        StoryQuizQuestion(
          question: 'موش‌موشی در دشت چه دانه‌ای را پیدا کرد؟',
          options: ['هسته یک هلو 🍑', 'دانه هندوانه 🍉', 'دانه گندم 🌾'],
          correctIndex: 0,
          explanation: 'آفرین! او هسته یک هلوی شیرین را پیدا کرد و در خاک کاشت.',
        ),
        StoryQuizQuestion(
          question: 'موش‌موشی برای رشد کردن جوانه چه کارهایی کرد؟',
          options: ['هر روز به آن آب داد و مراقبت کرد 💧', 'آن را در تاریکی گذاشت 🌑', 'فراموش کرد به آن سر بزند ❌'],
          correctIndex: 0,
          explanation: 'دقیقا! او هر روز آب تازه چشمه را پای جوانه می‌ریخت و با مهربانی مواظبش بود.',
        ),
      ],
    ),

    // ──────────────────────────────────────────────
    // ۴. سنجاب کوچولو و گردوهای گمشده
    // ──────────────────────────────────────────────
    ChildrenStory(
      id: 'story_squirrel_walnuts',
      title: 'سنجاب کوچولو و گردوهای گمشده',
      subtitle: 'داستان راستگویی و امانت‌داری',
      description: 'سنجاب کوچولو سبدی پر از گردوهای طلایی پیدا می‌کند. او با اینکه خیلی گرسنه است، تصمیم می‌گیرد صاحب واقعی آن را پیدا کند.',
      coverEmoji: '🐿️',
      coverAsset: 'assets/stories/story_4_page_1.png',
      category: StoryCategoryType.morals,
      categoryLabel: 'پند و اخلاق',
      readingTime: '۴ دقیقه',
      moralMessage: 'راستگویی و امانت‌داری، حس اعتماد و دوستی را در دل‌ها ایجاد می‌کند.',
      themeColor: Color(0xFFD84315),
      gradient: LinearGradient(
        colors: [Color(0xFFBF360C), Color(0xFFFF7043)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isFeatured: false,
      pages: [
        ChildrenStoryPage(
          pageNumber: 1,
          title: 'سبد پر از گردو در پاییز رنگارنگ',
          text: 'فصل پاییز بود و برگ‌های زرد و نارنجی جنگل را پوشانده بودند. «فندق‌چه»، سنجاب کوچک و باهوش، به دنبال آذوقه زمستانی می‌گشت. ناگهان زیر درخت کهنسال افرا، سبدی کوچک پر از گردوهای درشت و طلایی دید! شکم فندق‌چه غارغار می‌کرد و دلش می‌خواست همه گردوها را به خانه ببرد. اما ایستاد و فکر کرد: «این گردوها مال من نیست. حتماً کسی با زحمت زیاد آن‌ها را جمع کرده است.»',
          imageAsset: 'assets/stories/story_4_page_1.png',
          fallbackEmoji: '🐿️',
          interactiveQuestion: 'وقتی چیزی پیدا می‌کنی که مال تو نیست، بهترین کار چیست؟',
          goldenWords: [
            StoryVocabularyWord(word: 'آذوقه', emoji: '🌰', meaning: 'غذایی که برای زمستان یا روزهای بعد ذخیره می‌شود'),
            StoryVocabularyWord(word: 'کهنسال', emoji: '🌳', meaning: 'درخت یا موجودی که بسیار قدیمی و باسابقه است'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 2,
          title: 'جستجو برای پیدا کردن صاحب سبد',
          text: 'فندق‌چه سبد را برداشته و در سراسر جنگل راه افتاد. او از دارکوب پرسید: «آیا شما سبد گردو گم کرده‌اید؟» دارکوب گفت: «نه عزیزم، غذای من حشرات درختان است.» سپس از خرگوش پرسید، اما خرگوش هم گفت که دنبال هویج است. سرانجام به خانه جغد پیر دانا رسید. جغد پیر با دیدن سبد اشک در چشمانش جمع شد و گفت: «اوه! این گردوها غذای زمستانی من بود که وقتی بالم درد می‌کرد اینجا جا گذاشتم.»',
          fallbackEmoji: '🦉',
          interactiveQuestion: 'چرا فندق‌چه تسلیم نشد و به پرسیدن ادامه داد؟',
          goldenWords: [
            StoryVocabularyWord(word: 'صاحب', emoji: '🏡', meaning: 'کسی که وسیله یا چیزی متعلق به اوست'),
            StoryVocabularyWord(word: 'دانا', emoji: '🦉', meaning: 'فرد باهوش و با تجربه که چیزهای زیادی می‌داند'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 3,
          title: 'پاداش صداقت و قلب مهربان',
          text: 'جغد پیر از صداقت و امانت‌داری سنجاب کوچولو آن‌قدر خوشحال شد که نیمی از گردوها را به عنوان پاداش به او هدیه داد و گفت: «تو درستکارترین سنجاب جنگل هستی!» از آن روز به بعد، جغد دانا و فندق‌چه دوستان صمیمی شدند و همه حیوانات جنگل به فندق‌چه اعتماد کامل داشتند. راستگویی باعث شد او هم غذا به دست آورد و هم یک دوست عالی پیدا کند.',
          fallbackEmoji: '🌰',
          interactiveQuestion: 'چه حسی به آدم دست می‌دهد وقتی کار درست را انجام می‌دهد؟',
          goldenWords: [
            StoryVocabularyWord(word: 'صداقت', emoji: '💖', meaning: 'راستگو بودن و کار درست را انجام دادن'),
            StoryVocabularyWord(word: 'امانت‌داری', emoji: '🤝', meaning: 'مواظبت کردن از وسایل دیگران و پس دادن به موقع'),
          ],
        ),
      ],
      quizQuestions: [
        StoryQuizQuestion(
          question: 'صاحب واقعی سبد گردوها چه کسی بود؟',
          options: ['جغد پیر و دانا 🦉', 'خرگوش سفید 🐰', 'دارکوب پرنده 🐦'],
          correctIndex: 0,
          explanation: 'آفرین! سبد گردوها متعلق به جغد پیر بود که وقتی بالش درد می‌کرد آن را جا گذاشته بود.',
        ),
        StoryQuizQuestion(
          question: 'جغد پیر بعد از پس گرفتن گردوها چه کاری انجام داد؟',
          options: ['نصف گردوها را به سنجاب هدیه داد 🎁', 'هیچ چیزی نگفت ❌', 'ناراحت شد 🙁'],
          correctIndex: 0,
          explanation: 'دقیقا! جغد از صداقت سنجاب خوشحال شد و نیمی از گردوها را به عنوان پاداش به او داد.',
        ),
      ],
    ),

    // ──────────────────────────────────────────────
    // ۵. جشن بزرگ حیوانات در جنگل شکرستان
    // ──────────────────────────────────────────────
    ChildrenStory(
      id: 'story_forest_party',
      title: 'جشن بزرگ حیوانات در جنگل شکرستان',
      subtitle: 'قصه کار تیمی و همدلی حیوانات',
      description: 'حیوانات جنگل شکرستان تصمیم می‌گیرند جشن پاییزی برگزار کنند. هرکدام با استعداد ویژه خود در آماده‌سازی جشن شرکت می‌کنند.',
      coverEmoji: '🎉',
      coverAsset: 'assets/stories/story_5_page_1.png',
      category: StoryCategoryType.friendship,
      categoryLabel: 'دوستی و مهربانی',
      readingTime: '۴ دقیقه',
      moralMessage: 'هر کسی استعداد خاصی دارد و با اتحاد، کارهای شگفت‌انگیزی انجام می‌شود.',
      themeColor: Color(0xFFE91E63),
      gradient: LinearGradient(
        colors: [Color(0xFFC2185B), Color(0xFFF06292)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isFeatured: true,
      pages: [
        ChildrenStoryPage(
          pageNumber: 1,
          title: 'جلسه برنامه‌ریزی جشن پاییزی',
          text: 'در قلب جنگل شکرستان، همه حیوانات دور هم جمع شدند تا جشن سالانه پاییز را برگزار کنند. گوزن گفت: «ما به تزیینات، غذای خوشمزه و موسیقی زنده نیاز داریم!» خرگوش کوچولو گفت: «اما چطور این همه کار را تا غروب انجام دهیم؟» فندقی جلو آمد و گفت: «اگر هر کس کاری که در آن ماهر است را انجام دهد، جشن ما بی‌نظیر می‌شود.» همه حیوانات با هیجان موافقت کردند.',
          imageAsset: 'assets/stories/story_5_page_1.png',
          fallbackEmoji: '🦌',
          interactiveQuestion: 'تو در چه کاری مهارت داری که می‌توانی به دوستانت کمک کنی؟',
          goldenWords: [
            StoryVocabularyWord(word: 'سالانه', emoji: '📅', meaning: 'جشن یا اتفاقی که هر سال یک بار برگزار می‌شود'),
            StoryVocabularyWord(word: 'ماهر', emoji: '⭐', meaning: 'کسی که کاری را خیلی خوب و حرفه‌ای بلد است'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 2,
          title: 'تقسیم کار و تلاش هماهنگ',
          text: 'سنجاب‌ها با سرعت ریسه‌های گل و میوه را روی درختان آویزان کردند. خرس مهربان میزهای بزرگ چوبی را چید و سبدهای تمشک را روی آن‌ها گذاشت. پرنده‌ها نت‌های موسیقی را تمرین کردند و کرم‌های شب‌تاب قول دادند که شب جشن، نور کافی برای رقص و شادی ایجاد کنند. هیچ کس بیکار نبود و همه با لبخند و انرژی برای خوشحالی جمع تلاش می‌کردند.',
          imageAsset: 'assets/stories/story_5_page_2.png',
          fallbackEmoji: '🎨',
          interactiveQuestion: 'چرا تقسیم کار باعث می‌شود کسی خسته نشود؟',
          goldenWords: [
            StoryVocabularyWord(word: 'ریسه', emoji: '🎉', meaning: 'چراغ‌ها یا گل‌های رنگارنگی که برای تزیین آویزان می‌کنند'),
            StoryVocabularyWord(word: 'شب‌تاب', emoji: '✨', meaning: 'حشره‌های کوچکی که شب‌ها از خودشان نور می‌دهند'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 3,
          title: 'شبی پر از خنده، نور و آواز',
          text: 'وقتی شب فرا رسید، جنگل شکرستان مانند یک سرزمین رؤیایی می‌درخشید. حیوانات دست در دست هم دور آتش رقصیدند و آواز خواندند. همه فهمیدند که هیچ حیوانی به تنهایی نمی‌توانست چنین جشن بزرگی را برپا کند، اما وقتی همه با هم همدل و متحد باشند، شادترین لحظات ساخته می‌شود. آن شب تا مدت‌ها در یاد همه حیوانات جنگل ماند.',
          imageAsset: 'assets/stories/story_5_page_3.png',
          fallbackEmoji: '🌟',
          interactiveQuestion: 'بهترین جشنی که تا به حال با خانواده یا دوستانت داشته‌ای چه بود؟',
          goldenWords: [
            StoryVocabularyWord(word: 'همدل', emoji: '💖', meaning: 'کسانی که با مهربانی با هم هم‌فکر و دوست هستند'),
            StoryVocabularyWord(word: 'متحد', emoji: '🤝', meaning: 'کسانی که دست به دست هم می‌دهند تا موفق شوند'),
          ],
        ),
      ],
      quizQuestions: [
        StoryQuizQuestion(
          question: 'کرم‌های شب‌تاب چه مسئولیتی در جشن بر عهده گرفتند؟',
          options: ['ایجاد نور برای رقص و شادی شبانه ✨', 'چیدن میزهای میوه 🍇', 'خواندن آواز 🎶'],
          correctIndex: 0,
          explanation: 'آفرین! کرم‌های شب‌تاب با نور درخشان خود جنگل را برای جشن روشن کردند.',
        ),
        StoryQuizQuestion(
          question: 'راز موفقیت حیوانات در برگزاری جشن بزرگ چه بود؟',
          options: ['تقسیم کار و همکاری با هم 🤝', 'اینکه یک نفر تنهایی همه کارها را کرد ❌', 'عجله کردن و دعوا 🙁'],
          correctIndex: 0,
          explanation: 'دقیقا! هر حیوان کاری را که در آن ماهر بود انجام داد و با هم یک جشن عالی ساختند.',
        ),
      ],
    ),

    // ──────────────────────────────────────────────
    // ۶. اردک کوچولو که می‌خواست پرواز کند
    // ──────────────────────────────────────────────
    ChildrenStory(
      id: 'story_duck_swim',
      title: 'اردک کوچولو که می‌خواست پرواز کند',
      subtitle: 'داستان خودشناسی و پذیرش توانایی‌ها',
      description: 'اردک زرد کوچکی به نام «حنایی» غصه می‌خورد که چرا مثل عقاب پرواز نمی‌کند، تا اینکه استعداد بی‌نظیرش در شنا را کشف کرد.',
      coverEmoji: '🦆',
      coverAsset: 'assets/stories/story_6_page_3.png',
      category: StoryCategoryType.adventure,
      categoryLabel: 'ماجراجویی و شجاعت',
      readingTime: '۴ دقیقه',
      moralMessage: 'هر موجودی توانایی منحصربه‌فرد خودش را دارد؛ خودت را با دیگران مقایسه نکن.',
      themeColor: Color(0xFF0288D1),
      gradient: LinearGradient(
        colors: [Color(0xFF01579B), Color(0xFF29B6F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isFeatured: false,
      pages: [
        ChildrenStoryPage(
          pageNumber: 1,
          title: 'نگاه به آسمان و آرزوی پرواز بلند',
          text: 'حنایی، جوجه‌اردک زرد و بامزه‌ای بود که در کنار برکه زندگی می‌کرد. او هر روز عقاب‌ها و شاهین‌ها را می‌دید که در اوج آسمان پرواز می‌کردند. حنایی بال‌های کوتاهش را تکان می‌داد، اما فقط چند قدم بالاتر از زمین می‌پرید و بعد می‌افتاد. او غمگین کنار برکه نشست و گفت: «چرا من نمی‌توانم مثل پرنده‌های بزرگ پرواز کنم؟ آیا من پرنده ضعیفی هستم؟»',
          imageAsset: 'assets/stories/story_6_page_1.png',
          fallbackEmoji: '🦆',
          interactiveQuestion: 'آیا تا به حال دوست داشته‌ای کاری را انجام دهی که دیگران انجام می‌دهند؟',
          goldenWords: [
            StoryVocabularyWord(word: 'برکه', emoji: '🌊', meaning: 'حوضچه یا استخر طبیعی آب در دل طبیعت'),
            StoryVocabularyWord(word: 'اوج', emoji: '🦅', meaning: 'بالاترین نقطه آسمان'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 2,
          title: 'گفتگو با قو دانای برکه',
          text: 'قو سفید و دانای برکه آرام به سوی حنایی شنا کرد و گفت: «حنایی جان، آسمان جای زیبای عقاب است، اما آیا تا به حال دیده‌ای عقاب بتواند در آب‌های زلال شنا کند و زیر آب شیرجه بزند؟ خداوند به هر کدام از ما استعدادی داده است.» سپس از حنایی خواست که همراه او وارد برکه آبی و آرام شود.',
          imageAsset: 'assets/stories/story_6_page_2.png',
          fallbackEmoji: '🦢',
          interactiveQuestion: 'به نظر تو چه تفاوتی بین اردک و عقاب وجود دارد؟',
          goldenWords: [
            StoryVocabularyWord(word: 'زلال', emoji: '💧', meaning: 'آب بسیار تمیز، شفاف و روشن'),
            StoryVocabularyWord(word: 'استعداد', emoji: '⭐', meaning: 'توانایی ویژه‌ای که در وجود هر نفر قرار دارد'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 3,
          title: 'رقص در آب و شادی کشف استعداد',
          text: 'حنایی وارد برکه شد و پاهای پرده‌دارش را تکان داد. او مثل یک قایق کوچک و سریع روی آب سر خورد! او می‌توانست به راحتی شیرجه بزند و نیلوفرهای آبی را تماشا کند. حنایی خندید و فهمید که شاید در آسمان بلند نپرد، اما در برکه بهترین و سریع‌ترین شناگر است! او یاد گرفت که خودش را دوست داشته باشد و به توانایی‌هایش افتخار کند.',
          imageAsset: 'assets/stories/story_6_page_3.png',
          fallbackEmoji: '🌊',
          interactiveQuestion: 'تو چه ویژگی خاصی داری که تو را منحصر‌به‌فرد می‌کند؟',
          goldenWords: [
            StoryVocabularyWord(word: 'پرده‌دار', emoji: '🦆', meaning: 'پاهایی مثل اردک که برای شنا کردن در آب عالی هستند'),
            StoryVocabularyWord(word: 'افتخار', emoji: '🏆', meaning: 'حس سربلندی و خوشحالی از توانایی‌ها و کارهای خوب'),
          ],
        ),
      ],
      quizQuestions: [
        StoryQuizQuestion(
          question: 'چه کسی به حنایی کمک کرد تا استعداد اصلی‌اش را بشناسد؟',
          options: ['قو سفید و دانای برکه 🦢', 'عقاب آسمان 🦅', 'سنجاب جنگل 🐿️'],
          correctIndex: 0,
          explanation: 'آفرین! قو مهربان او را به داخل برکه برد تا شیرجه زدن و شنا کردنش را ببیند.',
        ),
        StoryQuizQuestion(
          question: 'حنایی چه استعدادی داشت که عقاب‌ها نداشتند؟',
          options: ['شنا کردن سریع و شیرجه زدن در آب زلال 🌊', 'دویدن روی کوه 🏔️', 'خوابیدن روی درخت 🌲'],
          correctIndex: 0,
          explanation: 'دقیقا! حنایی بهترین شناگر برکه بود و با شادی در آب شنا می‌کرد.',
        ),
      ],
    ),

    // ──────────────────────────────────────────────
    // ۷. آوازخوان کوچولوی شهر پرنده‌ها
    // ──────────────────────────────────────────────
    ChildrenStory(
      id: 'story_singer_bird',
      title: 'آوازخوان کوچولوی شهر پرنده‌ها',
      subtitle: 'غلبه بر خجالت و ابراز هنر',
      description: 'سار کوچولو صدای بسیار زیبایی داشت اما از خواندن در جمع خجالت می‌کشید. دوستانش به او اعتماد به نفس دادند تا در کنسرت جنگل بخواند.',
      coverEmoji: '🐦',
      coverAsset: 'assets/stories/story_7_page_3.png',
      category: StoryCategoryType.morals,
      categoryLabel: 'پند و اخلاق',
      readingTime: '۴ دقیقه',
      moralMessage: 'اعتماد به نفس و باور به خود، زیبایی‌های درونی ما را به دنیا نشان می‌دهد.',
      themeColor: Color(0xFFF57C00),
      gradient: LinearGradient(
        colors: [Color(0xFFE65100), Color(0xFFFFB74D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isFeatured: false,
      pages: [
        ChildrenStoryPage(
          pageNumber: 1,
          title: 'آواز پنهانی روی شاخه شکوفه‌ها',
          text: 'در شهر پرنده‌ها، «ساراک» پرنده کوچک و سرخ‌رنگی بود که وقتی تنها بود، زیباترین آوازهای جنگل را می‌خواند. اما به محض اینکه پرنده‌های دیگر نزدیک می‌شدند، او ساکت می‌شد و پشت برگ‌ها پنهان می‌شد. او می‌ترسید که صدایش به اندازه کافی خوب نباشد یا دیگران به او بخندند. فندقی آواز ساراک را شنید و گفت: «صدای تو مثل باران بهاری دلنشین است!»',
          imageAsset: 'assets/stories/story_7_page_1.png',
          fallbackEmoji: '🎶',
          interactiveQuestion: 'آیا تا به حال از نشان دادن نقاشی یا هنرت به دیگران خجالت کشیده‌ای؟',
          goldenWords: [
            StoryVocabularyWord(word: 'دلنشین', emoji: '🌸', meaning: 'چیزی که بسیار شیرین و خوشایند قلب است'),
            StoryVocabularyWord(word: 'پنهان', emoji: '🍃', meaning: 'مخفی شدن و در دید دیگران نبودن'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 2,
          title: 'دعوت به کنسرت بزرگ جنگل',
          text: 'جشنواره موسیقی جنگل نزدیک بود. فندقی از ساراک خواست تا به عنوان خواننده ویژه در صحنه حاضر شود. ساراک اول گفت: «نه، قلبم تند می‌تپد و می‌ترسم!» اما فندقی به او گفت: «ترسیدن طبیعی است، اما وقتی چشمانت را ببندی و با عشق بخوانی، همه با تو همراه می‌شوند. ما همه تشویقت می‌کنیم.»',
          imageAsset: 'assets/stories/story_7_page_2.png',
          fallbackEmoji: '🎤',
          interactiveQuestion: 'چطور می‌توانیم به دوستی که خجالت می‌کشد امید و شجاعت بدهیم؟',
          goldenWords: [
            StoryVocabularyWord(word: 'جشنواره', emoji: '🎪', meaning: 'مراسم شاد و بزرگی که هنرمندان هنر خود را نشان می‌دهند'),
            StoryVocabularyWord(word: 'شجاعت', emoji: '🦁', meaning: 'انجام دادن کار درست حتی وقتی کمی می‌ترسیم'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 3,
          title: 'تشویق پرشور حیوانات و شادی ساراک',
          text: 'روز کنسرت فرا رسید. ساراک روی شاخه اصلی ایستاد؛ ابتدا نفس عمیقی کشید و سپس شروع به خواندن کرد. صدای دلنشین او در تمام جنگل پیچید. همه حیوانات ساکت شدند و با شگفتی گوش کردند. در پایان آواز، صدای دست زدن و تشویق حیوانات آسمان را پر کرد! ساراک با خوشحالی تعظیم کرد و فهمید که شجاعت یعنی غلبه بر ترس.',
          imageAsset: 'assets/stories/story_7_page_3.png',
          fallbackEmoji: '👏',
          interactiveQuestion: 'چه احساسی داری وقتی دوستانت تو را تشویق می‌کنند؟',
          goldenWords: [
            StoryVocabularyWord(word: 'تشویق', emoji: '👏', meaning: 'دست زدن و تحسین کردن کارهای خوب دیگران'),
            StoryVocabularyWord(word: 'تعظیم', emoji: '🌟', meaning: 'خم شدن مؤدبانه برای تشکر از بینندگان'),
          ],
        ),
      ],
      quizQuestions: [
        StoryQuizQuestion(
          question: 'چرا ساراک در ابتدا آواز نمی‌خواند؟',
          options: ['خجالت می‌کشید و می‌ترسید دیگران به او بخندند 🙈', 'صدایش را دوست نداشت 🙁', 'خوابش می‌آمد 😴'],
          correctIndex: 0,
          explanation: 'آفرین! ساراک پرنده خجالتی بود، اما با کمک فندقی شجاعت پیدا کرد.',
        ),
        StoryQuizQuestion(
          question: 'وقتی ساراک در کنسرت آواز خواند حیوانات چه کار کردند؟',
          options: ['با شگفتی گوش دادند و او را پرشور تشویق کردند 👏', 'از جنگل رفتند ❌', 'ساکت ماندند 🙁'],
          correctIndex: 0,
          explanation: 'دقیقا! همه حیوانات با دست زدن و شادی از صدای زیبای او تشکر کردند.',
        ),
      ],
    ),

    // ──────────────────────────────────────────────
    // ۸. فندقی و راز سیاره الماس
    // ──────────────────────────────────────────────
    ChildrenStory(
      id: 'story_diamond_planet',
      title: 'فندقی و راز سیاره الماس',
      subtitle: 'سفر فضایی شگفت‌انگیز برای کشف دانایی',
      description: 'فندقی با موشک مقوایی و تخیل قوی خود به سیاره‌های دور سفر می‌کند و کشف می‌کند که ارزشمندترین الماس جهان، دانش و مهربانی است.',
      coverEmoji: '🚀',
      coverAsset: 'assets/stories/story_8_page_1.png',
      category: StoryCategoryType.adventure,
      categoryLabel: 'ماجراجویی و شجاعت',
      readingTime: '۴ دقیقه',
      moralMessage: 'دانش، یادگیری و کتاب خواندن، ارزشمندترین گنج‌های جهان هستند.',
      themeColor: Color(0xFF3949AB),
      gradient: LinearGradient(
        colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isFeatured: true,
      pages: [
        ChildrenStoryPage(
          pageNumber: 1,
          title: 'ساخت موشک فضایی در اتاق بازی',
          text: 'یک شب پرستاره، فندقی با جعبه‌های مقوایی، چسب و رنگ‌های درخشان یک موشک فضایی ساخت. او کلاه فضانوردی‌اش را گذاشت و گفت: «شماره معکوس: ۳، ۲، ۱... پرتاب!» با قدرت تخیل، موشک فندقی به سوی آسمان شب و میان ستارگان چشمک‌زن پرواز کرد. او از کنار ماه نقره‌ای و سیارک‌های رنگارنگ عبور کرد تا به سیاره‌ای ناشناخته رسید.',
          imageAsset: 'assets/stories/story_8_page_1.png',
          fallbackEmoji: '🌌',
          interactiveQuestion: 'اگر یک موشک فضایی داشتی، دوست داشتی به کدام سیاره سفر کنی؟',
          goldenWords: [
            StoryVocabularyWord(word: 'تخیل', emoji: '💭', meaning: 'تصور کردن چیزهای زیبا و شگفت‌انگیز در ذهن'),
            StoryVocabularyWord(word: 'سیارک', emoji: '☄️', meaning: 'سنگ‌های فضایی کوچک که در آسمان حرکت می‌کنند'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 2,
          title: 'فرود روی سیاره درخشان و عجیب',
          text: 'سیاره جدید پر از کوه‌های بلوری و نورهای رنگین‌کمانی بود. فندقی ربات مهربانی به نام «بیت‌بیت» را دید. بیت‌بیت گفت: «به سیاره الماس خوش آمدی! آیا می‌دانی بزرگ‌ترین گنج این سیاره کجاست؟» فندقی فکر کرد شاید گنج، سنگ‌های الماس درخشان باشد، اما بیت‌بیت او را به یک کتابخانه بزرگ بلوری راهنمایی کرد.',
          fallbackEmoji: '💎',
          interactiveQuestion: 'به نظر تو چرا کتابخانه را گنجینه می‌نامند؟',
          goldenWords: [
            StoryVocabularyWord(word: 'بلوری', emoji: '💎', meaning: 'درخشان و شفاف مثل الماس و شیشه'),
            StoryVocabularyWord(word: 'گنجینه', emoji: '👑', meaning: 'جایی که باارزش‌ترین گنج‌ها نگهداری می‌شود'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 3,
          title: 'کشف ارزشمندترین گنجینه جهان',
          text: 'بیت‌بیت کتاب‌های پر از علم، داستان‌های شگفت‌انگیز و نقشه‌های ستارگان را به فندقی نشان داد و گفت: «الماس‌های واقعی، دانستنی‌هایی هستند که در قلب و ذهن ما می‌درخشند و هیچ‌کس نمی‌تواند آن‌ها را از ما بگیرد.» فندقی با خوشحالی کتابی جدید خواند و با کوله‌باری از دانایی به خانه برگشت تا آموخته‌هایش را با دوستانش به اشتراک بگذارد.',
          fallbackEmoji: '📖',
          interactiveQuestion: 'کدام کتاب یا داستان را بیشتر از همه دوست داری و چرا؟',
          goldenWords: [
            StoryVocabularyWord(word: 'دانایی', emoji: '🧠', meaning: 'یاد گرفتن علم و آگاهی از جهان اطراف'),
            StoryVocabularyWord(word: 'اشتراک', emoji: '🤝', meaning: 'قسمت کردن علم و شادی‌ها با دوستان'),
          ],
        ),
      ],
      quizQuestions: [
        StoryQuizQuestion(
          question: 'بزرگ‌ترین گنج در سیاره الماس چه بود؟',
          options: ['کتاب‌ها و دانایی در کتابخانه بلوری 📖', 'سنگ‌های طلا 💰', 'اسباب‌بازی‌های برقی 🤖'],
          correctIndex: 0,
          explanation: 'آفرین! بیت‌بیت به فندقی یاد داد که دانش و کتاب خواندن باارزش‌ترین گنج است.',
        ),
        StoryQuizQuestion(
          question: 'فندقی موشک فضایی‌اش را با چه وسایلی ساخت؟',
          options: ['جعبه‌های مقوایی، رنگ و تخیل قوی 🚀', 'آهن و بنزین ⛽', 'چوب درخت 🪵'],
          correctIndex: 0,
          explanation: 'دقیقا! او با خلاقیت و جعبه‌های مقوایی به آسمان‌ها سفر کرد.',
        ),
      ],
    ),

    // ──────────────────────────────────────────────
    // ۹. قطره باران مهربان و گل سرخ تشنه
    // ──────────────────────────────────────────────
    ChildrenStory(
      id: 'story_raindrop_rose',
      title: 'قطره باران مهربان و گل سرخ تشنه',
      subtitle: 'داستان ایثار، بخشندگی و چرخه طبیعت',
      description: 'قطره باران کوچکی از ابر بالا صدای تشنگی گل سرخ را می‌شنود. او برای کمک به زمین می‌بارد و باغ را شاداب می‌کند.',
      coverEmoji: '💧',
      category: StoryCategoryType.nature,
      categoryLabel: 'طبیعت و حیوانات',
      readingTime: '۴ دقیقه',
      moralMessage: 'بخشندگی و ایثار، شادی را به زندگی دیگران هدیه می‌دهد.',
      themeColor: Color(0xFF00ACC1),
      gradient: LinearGradient(
        colors: [Color(0xFF006064), Color(0xFF4DD0E1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isFeatured: false,
      pages: [
        ChildrenStoryPage(
          pageNumber: 1,
          title: 'زندگی روی ابر پنبه‌ای و سفید',
          text: '«چک‌چک» قطره باران شفاف و بازیگوشی بود که همراه دوستانش روی یک ابر سفید و نرم در آسمان زندگی می‌کرد. آن‌ها همراه باد به شهرهای مختلف سفر می‌کردند و دشت‌ها را از بالا تماشا می‌کردند. یک روز گرم تابستان، وقتی ابر از روی باغی عبور می‌کرد، چک‌چک صدای ضعیفی از زمین شنید.',
          fallbackEmoji: '☁️',
          interactiveQuestion: 'به نظر تو ابرها چگونه در آسمان تشکیل می‌شوند؟',
          goldenWords: [
            StoryVocabularyWord(word: 'شفاف', emoji: '💧', meaning: 'روشن و زلال که نور از آن عبور می‌کند'),
            StoryVocabularyWord(word: 'بازیگوش', emoji: '😄', meaning: 'شاد، پرانرژی و دوست‌دار بازی'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 2,
          title: 'صدای گل سرخ تشنه در باغچه',
          text: 'چک‌چک به پایین نگاه کرد و گل سرخ زیبایی را دید که برگ‌هایش از شدت گرما و تشنگی خم شده بودند. گل سرخ گفت: «ای کاش قطره بارانی می‌بارید تا دوباره شاداب شوم.» بعضی قطره‌ها می‌گفتند: «اگر بباریم، دیگر روی ابر راحت نیستیم.» اما چک‌چک گفت: «من می‌روم تا به گل سرخ زندگی بدهم!»',
          fallbackEmoji: '🌹',
          interactiveQuestion: 'چرا کمک کردن به گیاهان و موجودات زنده مهم است؟',
          goldenWords: [
            StoryVocabularyWord(word: 'شاداب', emoji: '🌹', meaning: 'تازه، سرزنده و زیبا'),
            StoryVocabularyWord(word: 'ایثار', emoji: '💖', meaning: 'گذشتن از راحتی خود برای کمک به دیگران'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 3,
          title: 'بارش شادی و پیدایش رنگین‌کمان',
          text: 'چک‌چک با مهربانی به سمت زمین پرید و روی گلبرگ گل سرخ نشست. گل سرخ آب تازه را نوشید و با شادابی گلبرگ‌های زیبایش را باز کرد. خورشید که مهربانی چک‌چک را دید، نورش را تاباند و یک رنگین‌کمان هفت‌رنگ و باشکوه در آسمان ایجاد کرد. چک‌چک فهمید که بخشیدن و کمک به دیگران، زیباترین لحظات را می‌سازد.',
          fallbackEmoji: '🌈',
          interactiveQuestion: 'رنگین‌کمان از چه رنگ‌هایی درست شده است؟',
          goldenWords: [
            StoryVocabularyWord(word: 'باشکوه', emoji: '🌈', meaning: 'بسیار بزرگ، باعظمت و خیره‌کننده'),
            StoryVocabularyWord(word: 'بخشندگی', emoji: '🌟', meaning: 'هدیه دادن شادی به دیگران با قلب مهربان'),
          ],
        ),
      ],
      quizQuestions: [
        StoryQuizQuestion(
          question: 'چک‌چک برای کمک به گل سرخ چه کاری کرد؟',
          options: ['از ابر پایین پرید و به گل سرخ آب داد 💧', 'روی ابر خوابید 😴', 'از باغ دور شد ❌'],
          correctIndex: 0,
          explanation: 'آفرین! او با شجاعت و مهربانی بارید و گل سرخ را شاداب کرد.',
        ),
        StoryQuizQuestion(
          question: 'بعد از بارش چک‌چک و تابش خورشید چه چیزی در آسمان پدیدار شد؟',
          options: ['یک رنگین‌کمان هفت‌رنگ و باشکوه 🌈', 'برف سنگین ❄️', 'باد طوفانی 🌪️'],
          correctIndex: 0,
          explanation: 'دقیقا! خورشید نورش را تاباند و یک رنگین‌کمان زیبا در آسمان درخشید.',
        ),
      ],
    ),

    // ──────────────────────────────────────────────
    // ۱۰. لاک‌پشت دانا و مسابقه جنگل
    // ──────────────────────────────────────────────
    ChildrenStory(
      id: 'story_turtle_race',
      title: 'لاک‌پشت دانا و مسابقه جنگل',
      subtitle: 'قصه پشتکار، تمرکز و ناامید نشدن',
      description: 'لاک‌پشت دانا در مسابقه دویدن با حیوانات سریع شرکت می‌کند. او با تمرکز، قدم‌های پیوسته و ناامید نشدن موفق می‌شود.',
      coverEmoji: '🐢',
      category: StoryCategoryType.morals,
      categoryLabel: 'پند و اخلاق',
      readingTime: '۴ دقیقه',
      moralMessage: 'پشتکار و ادامه دادن مسیر حتی با قدم‌های کوچک، رمز رسیدن به هدف است.',
      themeColor: Color(0xFF689F38),
      gradient: LinearGradient(
        colors: [Color(0xFF33691E), Color(0xFF8BC34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isFeatured: false,
      pages: [
        ChildrenStoryPage(
          pageNumber: 1,
          title: 'ثبت‌نام در مسابقه بزرگ جنگل سبز',
          text: 'مسابقه سالانه دویدن در جنگل سبز برگزار می‌شد. خرگوش سریع، آهو و روباه در خط شروع ایستاده بودند. وقتی «سبزک»، لاک‌پشت آرام و دانا هم ثبت‌نام کرد، بعضی حیوانات با تعجب گفتند: «سبزک! تو خیلی آرام حرکت می‌کنی، چطور می‌خواهی تا بالای تپه برسی؟» سبزک با لبخند گفت: «مهم این است که با تمام توانم تلاش کنم و هرگز در میانه راه ناامید نشوم.»',
          fallbackEmoji: '🏁',
          interactiveQuestion: 'به نظر تو آیا فقط برنده شدن در مسابقه مهم است یا تلاش کردن؟',
          goldenWords: [
            StoryVocabularyWord(word: 'پشتکار', emoji: '🐢', meaning: 'ادامه دادن تلاش و ناامید نشدن از کارها'),
            StoryVocabularyWord(word: 'استقامت', emoji: '💪', meaning: 'توانایی مقاومت و ادامه دادن در مسیرهای طولانی'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 2,
          title: 'قدم‌های استوار و تمرکز روی مسیر',
          text: 'سوت مسابقه زده شد و دوندگان سریع مثل باد دور شدند. در میانه راه، خرگوش که مطمئن بود برنده می‌شود، زیر درخت خوابید تا استراحت کند. روباه هم حواسش به تمشک‌های جنگلی پرت شد. اما سبزک بدون اینکه حواسش پرت شود یا خسته شود، قدم‌به‌قدم با آرامش و استقامت به مسیر ادامه داد.',
          fallbackEmoji: '🐢',
          interactiveQuestion: 'چرا حواس‌پرتی باعث می‌شود از هدفمان دور شویم؟',
          goldenWords: [
            StoryVocabularyWord(word: 'تمرکز', emoji: '🎯', meaning: 'حواس خود را روی یک هدف مهم جمع کردن'),
            StoryVocabularyWord(word: 'استوار', emoji: '🌟', meaning: 'محکم، ثابت‌قدم و امیدوار'),
          ],
        ),
        ChildrenStoryPage(
          pageNumber: 3,
          title: 'عبور افتخارآمیز از خط پایان و تشویق همه',
          text: 'وقتی حیوانات متوجه شدند، سبزک با همان قدم‌های آرام اما پیوسته، به خط پایان نزدیک شده بود! همه تماشاگران برای تشویق او ایستادند و دست زدند. سبزک از خط پایان عبور کرد و نشان استقامت جنگل را گرفت. او به همه یاد داد که موفقیت به سرعت نیست؛ بلکه به پشتکار، امید و ادامه دادن است.',
          fallbackEmoji: '🏆',
          interactiveQuestion: 'چه کاری هست که با تمرین و صبر توانسته‌ای در آن موفق شوی؟',
          goldenWords: [
            StoryVocabularyWord(word: 'پیوسته', emoji: '🔄', meaning: 'بدون وقفه، مرتب و ادامه‌دار'),
            StoryVocabularyWord(word: 'افتخارآمیز', emoji: '🏆', meaning: 'کاری که باعث خوشحالی و سربلندی همه می‌شود'),
          ],
        ),
      ],
      quizQuestions: [
        StoryQuizQuestion(
          question: 'چرا خرگوش در مسابقه از لاک‌پشت عقب افتاد؟',
          options: ['زیر درخت خوابش برد و حواسش پرت شد 😴', 'تند دوید و برنده شد 🐰', 'مسابقه را فراموش کرد ❌'],
          correctIndex: 0,
          explanation: 'آفرین! خرگوش مغرور شد و خوابید، اما لاک‌پشت بدون وقفه به مسیر ادامه داد.',
        ),
        StoryQuizQuestion(
          question: 'مهم‌ترین درس لاک‌پشت دانا در مسابقه چه بود؟',
          options: ['پشتکار و ناامید نشدن مهم‌تر از سرعت است 🐢', 'همیشه باید سریع دوید 🏃', 'نباید در مسابقه شرکت کرد ❌'],
          correctIndex: 0,
          explanation: 'دقیقا! با قدم‌های کوچک اما پیوسته و با امیدواری می‌توان به هر هدفی رسید.',
        ),
      ],
    ),
  ];

  static List<ChildrenStory> getByCategory(StoryCategoryType category) {
    if (category == StoryCategoryType.all) {
      return allStories;
    }
    return allStories.where((s) => s.category == category).toList();
  }

  static ChildrenStory? getStoryById(String id) {
    for (final story in allStories) {
      if (story.id == id) return story;
    }
    return null;
  }

  static List<ChildrenStory> getFeaturedStories() {
    return allStories.where((s) => s.isFeatured).toList();
  }
}
