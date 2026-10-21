/// 🧭 فهرستِ واحدِ مسیرهای داخلیِ برنامه.
///
/// چرا این فایل لازم است؟
/// مسیرها در `main.dart` ثبت می‌شوند، ولی بعضی مقصدها از **حافظهٔ دستگاه**
/// خوانده می‌شوند: «ادامه با فندقی» (`GrowthStore.lastRoute`) و چیپ‌های
/// «اخیراً» (`GrowthStore.recentRoutes`). این مقدارها از نسخهٔ قبلیِ برنامه
/// باقی می‌مانند؛ اگر در آپدیت بعدی مسیری حذف یا تغییر نام بدهد، کودک با
/// لمسِ همان کارت به صفحهٔ «این مسیر فعلاً در دسترس نیست» می‌رسد.
///
/// این کلاس همان فهرست را در زمانِ اجرا در اختیار می‌گذارد تا پیش از
/// ناوبری، معتبر بودنِ مسیر سنجیده شود. هیچ تغییری در نوعِ ثبتِ مسیرها در
/// `main.dart` لازم نیست؛ تستِ `test/core/route_registry_test.dart` این فهرست
/// را با خودِ `main.dart` مقایسه می‌کند و اگر یکی از این دو عقب بماند،
/// تست قرمز می‌شود.
abstract final class AppRoutes {
  /// مسیر پیش‌فرضِ امن برای هر بازگشت.
  static const String home = '/home';

  /// مسیرهای ثابتی که در `routes:` یا با `name == '...'` در
  /// `onGenerateRoute` ثبت شده‌اند. با تست هم‌گام نگه داشته می‌شود.
  static const Set<String> exact = <String>{
    '/',
    '/security-blocked',
    '/tutorial',
    '/gateway',
    '/gateway-first-entry',
    '/learning-library',
    '/animals',
    '/numbers',
    '/math/tally',
    '/math/place-value',
    '/math/number-line',
    '/math/symmetry',
    '/math/ten-frame',
    '/math/compare',
    '/math/clock',
    '/math/add',
    '/dictation',
    '/jobs',
    '/concepts',
    '/sel',
    '/cartoons',
    '/stories',
    '/stories/read',
    '/lullabies',
    '/home',
    '/drawing-album',
    '/alphabet',
    '/memory_match',
    '/bubble_pop',
    '/star_catch',
    '/colors_lab',
    '/puzzle',
    '/math_race',
    '/pattern',
    '/games-carnival',
    '/mini/first-letter',
    '/mini/word-builder',
    '/mini/counting',
    '/mini/visual-math',
    '/mini/big-small',
    '/mini/shape-match',
    '/mini/color-mix',
    '/mini/number-order',
    '/mini/odd-one',
    '/mini/sort-basket',
    '/sound_match',
    '/body_parts',
    '/island_builder',
    '/buddy_chat',
    '/stickers',
    '/parent',
    '/about',
    '/privacy',
    '/life-skills',
    '/search',
    '/weekly-report',
    '/certificates',
    '/vocabulary',
    '/whats-new',
    '/parent-booklet',
    '/wildlife',
    '/basics',
    '/emotions',
    '/stage-map',
    '/art-studio',
    '/coloring',
    '/poems',
    '/quran',
    '/science-lab',
    '/cartoon_player',
  };

  /// پیشوندهایی که `onGenerateRoute` به‌صورت پویا می‌سازد
  /// (`/game/<name>`، `/story/<id>`، ...).
  static const List<String> prefixes = <String>[
    '/game/',
    '/story/',
    '/cartoon/',
    '/life-skills/',
    '/lullaby/',
    '/academy/',
  ];

  /// آیا این نام، مسیری درونِ برنامه است که `onGenerateRoute` یا جدولِ
  /// `routes` آن را می‌شناسد؟
  ///
  /// برای مسیرهای ذخیره‌شده در حافظه استفاده می‌شود؛ مسیرِ ناشناخته نباید
  /// هرگز به صفحهٔ «مسیر پیدا نشد» برسد.
  static bool isKnown(String? route) {
    if (route == null) return false;
    final value = route.trim();
    if (value.isEmpty) return false;
    if (exact.contains(value)) return true;
    for (final prefix in prefixes) {
      if (value.startsWith(prefix) && value.length > prefix.length) {
        return true;
      }
    }
    return false;
  }

  /// نسخهٔ امنِ یک مسیرِ ذخیره‌شده؛ اگر معتبر نباشد `null` برمی‌گردد.
  static String? sanitize(String? route) => isKnown(route) ? route!.trim() : null;

  /// مسیرِ معتبر، یا خانه به‌عنوان مقصدِ امن.
  static String resolveOrHome(String? route) => sanitize(route) ?? home;
}
