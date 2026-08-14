import 'package:flutter/material.dart';

import 'cartoons/cartoon_data.dart';
import 'learning_content/children_stories_data.dart';
import 'learning_content/lullabies_data.dart';
import 'learning_content/stories.dart';
import 'monetization.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🔐 CONTENT ACCESS — یک مرجع واحد برای «چه چیزی رایگان است؟»
///
/// قبلاً قانون رایگان/پولی در چند فایل پخش بود (پی‌وال، گیتِ بازی‌ها،
/// شیت هاب‌ها) و هر صفحه سلیقه‌ای رفتار می‌کرد. حالا همهٔ قوانین
/// نسخهٔ رایگان اینجاست تا هم قابل بازبینی باشد و هم هیچ صفحه‌ای
/// جا نیفتد.
///
/// قوانین نسخهٔ رایگان (۶٫۳):
///  • کارتون‌ها: فقط ۲ مورد اول
///  • قصه‌ها: فقط ۲ مورد اول
///  • الفبا: فقط ردیف اول حروف (۸ حرف)
///  • فارسی: «واژگان» و «صدا» کاملاً قفل
///  • لالایی: فقط ۲ مورد اول
///  • علوم: همهٔ موارد قفل
///  • ریاضی/اعداد: فقط ۲ عدد اول
/// ═══════════════════════════════════════════════════════════════
class ContentAccess {
  ContentAccess._();

  /// تعداد موارد رایگان در هر بخش.
  static const int freeCartoons = 2;
  static const int freeStories = 2;
  static const int freeLullabies = 2;
  static const int freeNumbers = 2;

  /// «فقط یک ردیف بالا» = ۸ حرف اول (چیدمان پیکر حروف ۸ ستونه است).
  static const int alphabetRowSize = 8;
  static const int freeAlphabetLetters = alphabetRowSize;

  /// بخش‌هایی که در نسخهٔ رایگان کاملاً قفل‌اند (مسیر → نام نمایشی).
  static const Map<String, String> lockedRoutes = <String, String>{
    '/vocabulary': 'گنجینه واژگان',
    '/sound_match': 'بازی صداها',
    '/animals': 'دانشنامه حیوانات',
    '/body_parts': 'اعضای بدن',
    '/life-skills': 'مهارت‌های زندگی',
    '/concepts': 'مفاهیم علوم',
    '/jobs': 'شغل‌ها',
    '/sel': 'دنیای احساسات',
  };

  /// نام بازی‌هایی که در نسخهٔ رایگان قفل‌اند (برای `GameAccessGate`).
  static const Set<String> lockedGameNames = <String>{
    'واژگان',
    'صدا',
    'حیوانات',
    'بدن',
    'مهارت زندگی',
    'مفاهیم',
    'شغل‌ها',
    'احساسات',
  };

  /// بازی‌هایی که همچنان در نسخهٔ رایگان باز می‌مانند (همان مجموعهٔ
  /// قبلیِ `GameAccessGate`؛ عمداً گسترده‌تر نشده تا درآمد کم نشود).
  /// توجه: «الفبا» و «اعداد» باز می‌شوند ولی داخلشان فقط ردیف اول
  /// حروف و دو عدد اول قابل استفاده است.
  static const Set<String> freeGameNames = <String>{
    'الفبا',
    'اعداد',
    'رنگ‌ها',
    'اشکال',
    'نقاشی',
    'ستاره‌گیری',
    'حباب‌ترکان',
  };

  // ── وضعیت خرید (کش‌شده) ──────────────────────────────────────────
  static bool _premium = false;
  static bool get isPremium => _premium;

  /// نسخهٔ کامل را از منبع معتبر می‌خواند و کش می‌کند.
  /// در startup و بعد از هر خرید/بازیابی صدا زده می‌شود.
  static Future<bool> refresh() async {
    try {
      _premium = await Monetization.hasFullVersion();
    } catch (_) {
      // خطای استور نباید اپ کودک را قفل/باز اشتباه کند؛ مقدار قبلی می‌ماند.
    }
    return _premium;
  }

  /// برای صفحه‌هایی که همان اول ویترین را می‌کشند: اگر وضعیت خرید بعد
  /// از خواندنِ استور عوض شد، صفحه یک‌بار دوباره ساخته می‌شود. بدون این،
  /// یک کاربرِ خریدار ممکن بود لحظه‌ای قفل‌ها را ببیند.
  static Future<void> refreshThen(VoidCallback onChanged) async {
    final before = _premium;
    await refresh();
    if (before != _premium) onChanged();
  }

  // ── قوانین هر بخش ────────────────────────────────────────────────

  static bool isCartoonUnlocked(String cartoonId) {
    if (_premium) return true;
    final index =
        CartoonData.allCartoons.indexWhere((c) => c.id == cartoonId);
    return index >= 0 && index < freeCartoons;
  }

  static bool isStoryUnlocked(String storyId) {
    if (_premium) return true;
    final index =
        ChildrenStoriesData.allStories.indexWhere((s) => s.id == storyId);
    if (index >= 0) return index < freeStories;
    // داستان‌های تعاملی (/story/<id>) لیست جداگانه‌ای دارند.
    final interactive =
        interactiveStories.indexWhere((s) => s.id == storyId);
    return interactive >= 0 && interactive < freeStories;
  }

  static bool isLullabyUnlocked(String lullabyId) {
    if (_premium) return true;
    final index = LullabiesData.all.indexWhere((l) => l.id == lullabyId);
    return index >= 0 && index < freeLullabies;
  }

  /// حرف الفبا با شمارهٔ صفر-پایه.
  static bool isLetterUnlocked(int letterIndex) =>
      _premium || letterIndex < freeAlphabetLetters;

  /// عدد ۱ تا ۲۰ (ورودی خودِ عدد است، نه اندیس).
  static bool isNumberUnlocked(int number) => _premium || number <= freeNumbers;

  static bool isRouteUnlocked(String route) =>
      _premium || !lockedRoutes.containsKey(route);

  static bool isGameUnlocked(String gameName) {
    if (_premium) return true;
    if (lockedGameNames.contains(gameName)) return false;
    return freeGameNames.contains(gameName);
  }
}

/// قفل شیشه‌ای روی کارت‌های پولی — یک ظاهر مشترک در همهٔ بخش‌ها،
/// تا کودک/والد سریع بفهمد این مورد بخشی از نسخهٔ کامل است.
class PremiumLockOverlay extends StatelessWidget {
  const PremiumLockOverlay({
    super.key,
    this.label = 'نسخه کامل',
    this.borderRadius = 20,
    this.iconSize = 28,
    this.compact = false,
  });

  final String label;
  final double borderRadius;
  final double iconSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            color: Colors.black.withOpacity(0.55),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(compact ? 6 : 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFFFC107).withOpacity(0.7),
                        width: 1.5),
                  ),
                  child: Icon(Icons.lock_rounded,
                      color: const Color(0xFFFFD54F), size: iconSize),
                ),
                if (!compact) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// نوار کوچکِ «در نسخه رایگان چند مورد اول باز است» — بالای هر ویترین.
/// وقتی نسخهٔ کامل فعال باشد هیچ‌چیز نشان نمی‌دهد.
class FreeTierNotice extends StatelessWidget {
  const FreeTierNotice({super.key, required this.freeCount, required this.itemLabel});

  final int freeCount;
  final String itemLabel;

  @override
  Widget build(BuildContext context) {
    if (ContentAccess.isPremium) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_rounded, color: Color(0xFFFFD54F), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'در نسخه رایگان فقط $freeCount $itemLabel اول باز است؛ بقیه با نسخه کامل باز می‌شوند.',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
