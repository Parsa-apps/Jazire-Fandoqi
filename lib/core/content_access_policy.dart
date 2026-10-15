import 'cartoons/cartoon_data.dart';
import 'learning_content/children_stories_data.dart';
import 'learning_content/lullabies_data.dart';
import 'literacy/decodable_stories.dart';

/// The single source of truth for partially-free content collections.
///
/// Item identity is checked against each collection's canonical order. This
/// keeps filtering, searching, and featured carousels from accidentally making
/// a premium item free just because it appears first in a filtered list.
abstract final class ContentAccessPolicy {
  static const int freeCartoonCount = 2;
  static const int freeStoryCount = 2;
  static const int freeLullabyCount = 2;
  static const int freeAlphabetTopRowCount = 8;
  /// شمارش ۱ تا ۱۰ هستهٔ ریاضی اول دبستان است و نباید پشت پرداخت قفل شود.
  static const int freeNumberCount = 10;

  /// مسیرهای بازی/هاب که بدون خرید کامل باید باز بمانند.
  ///
  /// این فهرست برای درگاه‌های ورودی و محافظ مسیر یکسان است؛ محتوای چندبخشی
  /// مثل داستان، کارتون، لالایی، الفبا و اعداد در خود صفحه هم قفل‌های ریزتر
  /// دارد و رایگان‌بودن هاب، محتوای پریمیوم داخل آن را رایگان نمی‌کند.
  static const Set<String> freeGameNames = <String>{
    'الفبا',
    'اعداد',
    'رنگ‌ها',
    'ستاره‌گیری',
    'حباب‌ترکان',
    'نقاشی',
    'چوب‌خط',
    'ارزش مکانی',
    'محور اعداد',
    'تقارن',
    'قاب ده‌تایی',
    'تمساح',
    'ساعت',
    'جمع',
    'املا',
    'شهر بازی‌ها',
    'حرف اول',
    'شمارش خوش',
    'بزرگ و کوچک',
    'ترتیب اعداد',
    'متفاوت را پیدا کن',
    // این دو مورد در هاب‌ها رایگان تعریف شده بودند اما از allowlist مسیر جا افتاده بودند.
    'اشکال',
    'مسابقه',
    // هاب‌های رایگان یا ترکیبی؛ قفل آیتم‌های پولی درون آن‌ها برقرار می‌ماند.
    'داستان',
    'لالایی',
    'کتابخانه',
    'آلبوم نقاشی',
    'استیکر',
  };

  /// آکادمی‌های مستقیم: رنگ و شکل رایگان‌اند؛ آکادمی اعداد شامل ۱ تا ۲۰
  /// است و باید از مسیر NumbersHub باز شود تا ۱۱ تا ۲۰ پشت خرید بماند.
  /// هر topic ناشناخته نیز به‌صورت پیش‌فرض پریمیوم محسوب می‌شود.
  static const Set<String> _freeAcademyTopicIds = <String>{'colors', 'shapes'};

  static bool isGameFree(String gameName) => freeGameNames.contains(gameName);

  static bool isAcademyTopicFree(String topicId) =>
      _freeAcademyTopicIds.contains(topicId);

  static bool isCartoonFree(String id) => _isAmongFirst(
        id,
        CartoonData.allCartoons.map((item) => item.id),
        freeCartoonCount,
      );

  static bool isStoryFree(String id) {
    if (DecodableStories.isDecodableId(id)) return true;
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

  static bool isAlphabetLessonFree(int index) =>
      index >= 0 && index < freeAlphabetTopRowCount;

  static bool isNumberFree(int number) =>
      number >= 1 && number <= freeNumberCount;

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
