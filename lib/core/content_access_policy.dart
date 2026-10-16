import 'cartoons/cartoon_data.dart';
import 'growth/life_skills_data.dart';
import 'learning_content/children_stories_data.dart';
import 'learning_content/learning_topics.dart';
import 'learning_content/lullabies_data.dart';
import 'literacy/decodable_stories.dart';

/// The single source of truth for partially-free content collections.
///
/// ⚖️ سیاست «نیمهٔ رایگان، نیمهٔ نسخهٔ کامل»:
/// هر مجموعهٔ محتوایی به ترتیب کتابِ خودش، نیمهٔ اول را رایگان می‌دهد و
/// نیمهٔ دوم با یک خرید دائمی باز می‌شود. هدف: والد قبل از خرید یک تجربهٔ
/// واقعی و کامل ببیند (نه دموی چند ثانیه‌ای) و در عین حال نیمهٔ دوم محتوا
/// ارزش پرداخت داشته باشد.
///
/// استثناهای عامدانه (هر کدام دلیل آموزشی دارد، نه تجاری):
///  • اعداد ۱ تا ۱۰ — هستهٔ کتاب ریاضی اول دبستان است و نباید قفل شود
///    (۱۱ تا ۲۰ با نسخهٔ کامل باز می‌شود). همین‌جا از ابتدا نیمه‌نیمه بود.
///  • آلبوم استیکر — بخشی از اقتصاد سکهٔ درون‌برنامه است؛ استیکر با سکه
///    خریده می‌شود و قفل‌کردن آلبوم، آیتم خریداری‌شده را بی‌مصرف می‌کند.
///  • هاب‌هایی که داخلشان محتوای نیمه‌رایگان دارند (قصه، لالایی، مهارت زندگی،
///    شهر بازی‌ها، اعداد، کتابخانه) درِ ورودشان رایگان می‌ماند تا کاربر به
///    نیمهٔ رایگان همان مجموعه برسد؛ قفل محتوای پولی داخل خود صفحه اعمال می‌شود.
///
/// Item identity is checked against each collection's canonical order. This
/// keeps filtering, searching, and featured carousels from accidentally making
/// a premium item free just because it appears first in a filtered list.
abstract final class ContentAccessPolicy {
  // ── مجموعه‌های نیمه‌نیمه ─────────────────────────────────────────────────
  /// ۱۹ کارتون → نیمهٔ اول (۹ کارتون) رایگان.
  ///
  /// عدد ۹ از خودِ فهرست کانونی درآمده است: `CartoonData.allCartoons` ۱۹ عضو
  /// دارد، پس «نیمهٔ اول» ۹ کارتون است و ۱۰ کارتون قفل می‌ماند. این عدد
  /// عمداً به سقفِ نصف گرد نشده تا هرگز اکثریتِ کارتون‌ها رایگان نشود
  /// (ویدیو هم پهنای باند مصرف می‌کند و هم وابسته به آپارات است).
  static const int freeCartoonCount = 9;

  /// ۱۰ قصهٔ تعاملی → ۵ قصه رایگان.
  static const int freeStoryCount = 5;

  /// ۱۰ لالایی → ۵ لالایی رایگان.
  static const int freeLullabyCount = 5;

  /// ۱۰ دنیای مهارت زندگی → ۵ دنیا رایگان.
  static const int freeLifeSkillCount = 5;

  // ── الفبا ───────────────────────────────────────────────────────────────
  /// حالت «الفبایی سنتی» (۳۳ نشانه): نیمهٔ اول (۱۶ نشانه) رایگان.
  ///
  /// ⚖️ قانونِ نصف/نصف: پیش از این فقط ۸ نشانه رایگان بود (۲۴٪ کل) و این با
  /// قانون نمی‌خواند؛ نیمهٔ ۳۳ نشانه یعنی ۱۶ نشانه.
  static const int freeAlphabetTopRowCount = 16;

  /// حالت کلاس اول (پیش‌فرض، ۳۸ درس در ۸ بسته): نیمهٔ بسته‌ها رایگان → ۴ بسته.
  ///
  /// ⚠️ پیش از این، رایگان‌بودن با شمارهٔ **درس داخل بسته** سنجیده می‌شد و
  /// چون بسته‌ها ۴ تا ۹ درس دارند، عملاً ۳۷ درس از ۳۸ درس برای کاربر رایگان
  /// باز می‌ماند. اکنون سنجش با شمارهٔ بسته انجام می‌شود.
  /// ⚖️ بعد از آن اصلاح فقط ۲ بسته (۲۵٪) رایگان مانده بود — یعنی الفبا برخلاف
  /// بقیهٔ مجموعه‌ها حدود ۷۵٪ پولی بود؛ حالا ۴ بسته از ۸ بسته آزاد است.
  static const int freeAlphabetBundleCount = 4;

  // ── اعداد ───────────────────────────────────────────────────────────────
  /// شمارش ۱ تا ۱۰ هستهٔ ریاضی اول دبستان است و نباید پشت پرداخت قفل شود.
  static const int freeNumberCount = 10;

  // ── بازی‌ها و فعالیت‌های جزیره ───────────────────────────────────────────
  /// مسیرهای بازی/هاب که بدون خرید کامل باید باز بمانند.
  ///
  /// این فهرست برای درگاه‌های ورودی و محافظ مسیر یکسان است؛ محتوای چندبخشی
  /// مثل داستان، کارتون، لالایی، الفبا و اعداد در خود صفحه هم قفل‌های ریزتر
  /// دارد و رایگان‌بودن هاب، محتوای پریمیوم داخل آن را رایگان نمی‌کند.
  ///
  /// توزیع هاب‌ها با این فهرست (۱۹ از ۳۵ فعالیت ≈ ۵۴٪ رایگان):
  ///  فارسی ۳/۵ · ریاضی ۴/۸ · حروف ۳/۴ · کاوش ۲/۴ · شهربازی ۴/۸ · هنر ۴/۶
  static const Set<String> freeGameNames = <String>{
    // فارسی و ادبیات
    'الفبا',
    'املا',
    'داستان', // هاب قصه؛ ۵ از ۱۰ قصه داخلش رایگان است
    'کتابخانه',
    // ریاضی
    'اعداد', // هاب اعداد؛ ۱ تا ۱۰ داخلش رایگان است
    'جمع',
    'مسابقه',
    'تمساح',
    // ابزارهای شمارش‌سطحِ اول دبستان رایگان می‌مانند تا کاربر رایگان بتواند
    // همان ۱ تا ۱۰ را واقعاً تمرین کند؛ ابزارهای سطح بالاتر (قاب ده‌تایی،
    // ساعت، ارزش مکانی، تقارن) با نسخهٔ کامل باز می‌شوند.
    'چوب‌خط',
    'محور اعداد',
    // حروف و صداها
    'حباب‌ترکان',
    // کاوش و علوم
    'مهارت زندگی', // هاب مهارت زندگی؛ ۵ از ۱۰ دنیا داخلش رایگان است
    'بدن',
    'احساسات',
    // شهر بازی‌ها (۵ بازی رایگان کارناوال + هابش)
    'شهر بازی‌ها',
    'حرف اول',
    'شمارش خوش',
    'بزرگ و کوچک',
    'ترتیب اعداد',
    'متفاوت را پیدا کن',
    // هنر و خلاقیت
    'رنگ‌ها',
    'اشکال',
    // «میوه» نامی است که کارتِ داشبورد و مسیر `/game/میوه` با آن گیت می‌شوند.
    // آکادمی همان موضوع (`fruits`) از ابتدا در `_freeAcademyTopicIds` رایگان
    // بود و متن فروشگاه هم «میوه‌ها» را در بخش رایگان می‌آورد؛ این نام جا
    // افتاده بود و کارت را بی‌دلیل قفل می‌کرد.
    'میوه',
    'لالایی', // هاب لالایی؛ ۵ از ۱۰ لالایی داخلش رایگان است
    'استیکر', // آلبوم استیکر با سکهٔ درون‌برنامه خریده می‌شود (استثنای بالا)
    // ── مجموعه‌هایی که حالا خودشان نیمه‌رایگان شده‌اند ──────────────────
    // درِ ورودِ این مجموعه‌ها باید باز بماند تا کاربر به نیمهٔ رایگانشان
    // برسد؛ قفلِ نیمهٔ دوم داخل خود صفحه (روی تک‌تک آیتم‌ها) اعمال می‌شود.
    'حیوانات', // ۱۵ حیوان از ۳۰ — بقیه با نسخهٔ کامل
    'شغل‌ها', // ۱۰ شغل از ۲۰ — بقیه با نسخهٔ کامل
    'مفاهیم', // ۸ مفهوم از ۱۶ — بقیه با نسخهٔ کامل
    'واژگان', // نیمهٔ اولِ واژه‌های ثبت‌شده — بقیه با نسخهٔ کامل
  };

  /// Every known academy has a free half. AcademyGame limits both questions
  /// and distractors to allowedTopicCards; an unknown topic stays locked.
  static bool isAcademyTopicFree(String topicId) =>
      learningTopicById(topicId) != null;

  static bool isGameFree(String gameName) =>
      freeGameNames.contains(gameName == 'میوه‌ها' ? 'میوه' : gameName);

  static bool isCartoonFree(String id) => _isAmongFirst(
        id,
        CartoonData.allCartoons.map((item) => item.id),
        freeCartoonCount,
      );

  static bool isStoryFree(String id) {
    if (DecodableStories.isDecodableId(id)) {
      return isFreeHalfItem(id, DecodableStories.all.map((story) => story.id));
    }
    return _isAmongFirst(
      id,
      ChildrenStoriesData.allStories.map((item) => item.id),
      freeStoryCount,
    );
  }

  static bool isLullabyFree(String id) => _isAmongFirst(
        id,
        LullabiesData.all.map((item) => item.id),
        freeLullabyCount,
      );

  /// نیمهٔ اول دنیاهای مهارت زندگی (به ترتیب کتاب) رایگان است.
  ///
  /// بر پایهٔ `id` سنجیده می‌شود، نه `title`؛ چون عنوان‌ها ممکن است ویرایش
  /// شوند و نباید قفل محتوا با تغییر متن بشکند.
  static bool isLifeSkillFree(String id) => _isAmongFirst(
        id,
        LifeSkillsData.topics.map((topic) => topic.id),
        freeLifeSkillCount,
      );

  /// رایگان‌بودن درس‌های حالت «الفبایی سنتی» (۳۳ نشانه).
  static bool isAlphabetLessonFree(int index) =>
      index >= 0 && index < freeAlphabetTopRowCount;

  /// A filtered/search result retains its canonical lesson index.
  static bool isAlphabetLetterFree(String letter, List<String> orderedLetters) =>
      isAlphabetLessonFree(orderedLetters.indexOf(letter));

  /// رایگان‌بودن یک بستهٔ کلاس اول (حالت پیش‌فرض).
  static bool isAlphabetBundleFree(int bundleIndex) =>
      bundleIndex >= 0 && bundleIndex < freeAlphabetBundleCount;

  static bool isNumberFree(int number) =>
      number >= 1 && number <= freeNumberCount;

  // ── قاعدهٔ عمومی «نیمهٔ اولِ هر مجموعهٔ مرتّب» ───────────────────────────
  /// قانونِ نصف/نصف برای هر مجموعه‌ای که هنوز ثابتِ اختصاصی ندارد.
  ///
  /// `orderedIds` باید **ترتیبِ کتاب** (ترتیبِ کانونیِ داده) باشد، نه ترتیبِ
  /// نمایش: فیلتر، جست‌وجو و دسته‌بندی نباید بتوانند یک آیتمِ پولی را به صدرِ
  /// فهرست بیاورند و رایگانش کنند. شناسهٔ ناشناخته همیشه قفل است (fail-closed)
  /// تا افزوده‌شدنِ محتوای جدید هرگز نشت نسازد.
  static bool isFreeHalfItem(String id, Iterable<String> orderedIds) =>
      _isAmongFirst(id, orderedIds, orderedIds.length ~/ 2);

  /// آیا این کارتِ یک موضوعِ یادگیری (حیوانات، شغل‌ها، مفاهیم، احساسات،
  /// رنگ‌ها، شکل‌ها، بدن، میوه) رایگان است؟
  static bool isTopicCardFree(LearningTopic topic, String cardId) =>
      isFreeHalfItem(cardId, topic.cards.map((card) => card.id));

  /// کارت‌هایی از این موضوع که کاربر مجاز به دیدن/تمرین آن‌هاست.
  ///
  /// برای بازی‌هایی که کارت‌ها را تصادفی بیرون می‌کشند (`AcademyGame`): pool
  /// را به نیمهٔ رایگان محدود می‌کند تا نیمهٔ پولی در قالبِ «شانسِ تصادفی»
  /// در دسترس قرار نگیرد.
  static List<LearningCard> allowedTopicCards(
    LearningTopic topic, {
    required bool hasFullVersion,
  }) {
    if (hasFullVersion) return topic.cards;
    final free = topic.cards.length ~/ 2;
    return topic.cards.take(free).toList(growable: false);
  }

  static bool _isAmongFirst(
    String id,
    Iterable<String> orderedIds,
    int freeCount,
  ) {
    var index = 0;
    for (final candidate in orderedIds) {
      if (candidate == id) return index < freeCount;
      index++;
    }
    return false;
  }
}
