import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/routing/app_routes.dart';

/// 🧭 نگهبانِ مسیرها
///
/// صفحهٔ «این مسیر فعلاً در دسترس نیست» فقط وقتی می‌آید که
/// `Navigator` نامی را بشناسد که نه در جدولِ `routes` است و نه
/// `onGenerateRoute` آن را می‌سازد. این تست دو طرف را با هم مقایسه می‌کند:
///
///   ۱. فهرستِ `AppRoutes` (که در زمانِ اجرا برای اعتبارسنجی مسیرهای
///      ذخیره‌شده استفاده می‌شود) با خودِ `lib/main.dart`.
///   ۲. همهٔ مقصدهای ثابتِ داخلِ `lib/` (کارت‌ها، دکمه‌ها، داده‌ها) با
///      فهرستِ مسیرهای ثبت‌شده.
///
/// اگر کسی مسیری را در `main.dart` اضافه/حذف کند یا کارتی به مسیرِ
/// ناموجود اشاره کند، این تست قرمز می‌شود — پیش از آن‌که کودک آن را ببیند.
void main() {
  late String mainSource;
  late Set<String> registered;
  late Set<String> dynamicPrefixes;

  /// نام‌های ثابتِ داخلِ `routes:` و `name == '...'`های `onGenerateRoute`.
  Set<String> readRegistered(String source) {
    final start = source.indexOf('routes: <String, WidgetBuilder>{');
    final end = source.indexOf('onGenerateRoute', start);
    expect(start, greaterThan(0), reason: 'جدولِ routes در main.dart پیدا نشد');
    expect(end, greaterThan(start), reason: 'onGenerateRoute پیدا نشد');
    final mapBlock = source.substring(start, end);
    final keys = RegExp(r"^        '([^']+)': \(context\)", multiLine: true)
        .allMatches(mapBlock)
        .map((m) => m.group(1)!)
        .toSet();

    final generated =
        source.substring(source.indexOf('onGenerateRoute'), source.length);
    final exactFromGenerator = RegExp(r"name == '([^']+)'")
        .allMatches(generated)
        .map((m) => m.group(1)!)
        .toSet();

    return <String>{...keys, ...exactFromGenerator};
  }

  Set<String> readPrefixes(String source) {
    final generated =
        source.substring(source.indexOf('onGenerateRoute'), source.length);
    return RegExp(r"name\.startsWith\('([^']+)'\)")
        .allMatches(generated)
        .map((m) => m.group(1)!)
        .toSet();
  }

  /// همهٔ فایل‌های Dart داخلِ `lib/`.
  List<File> libFiles() {
    return Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  /// آیا این متنِ مسیر (که ممکن است شاملِ «${...}» باشد) قابلِ شناخته‌شدن است؟
  bool isResolvable(String raw) {
    final route = raw.trim();
    if (route.isEmpty || !route.startsWith('/')) return true;
    if (AppRoutes.exact.contains(route)) return true;
    if (AppRoutes.isKnown(route)) return true;
    // الگوی پویا مثل `/story/${story.id}` یا `/cartoon/${cartoon.id}`:
    final dynamicStart = route.indexOf(r'${');
    if (dynamicStart > 0) {
      final prefix = route.substring(0, dynamicStart);
      return AppRoutes.prefixes.any(prefix.startsWith);
    }
    return false;
  }

  setUpAll(() {
    mainSource = File('lib/main.dart').readAsStringSync();
    registered = readRegistered(mainSource);
    dynamicPrefixes = readPrefixes(mainSource);
  });

  group('فهرستِ مسیرها', () {
    test('AppRoutes دقیقاً همان مسیرهای main.dart است', () {
      expect(
        AppRoutes.exact.difference(registered),
        isEmpty,
        reason: 'این مسیرها در AppRoutes هستند ولی main.dart آن‌ها را ندارد; '
            'یا از main.dart حذف شده‌اند یا اشتباه تایپ شده‌اند.',
      );
      expect(
        registered.difference(AppRoutes.exact),
        isEmpty,
        reason: 'این مسیرها در main.dart ثبت شده‌اند ولی در AppRoutes نیستند; '
            'AppRoutes باید هم‌گام بماند.',
      );
    });

    test('پیشوندهای پویا هم‌خوان هستند', () {
      expect(AppRoutes.prefixes.toSet(), dynamicPrefixes);
    });

    test('هر ۱۶ کارتِ «دسته‌بندی‌ها» مقصدِ واقعی دارد', () {
      final library =
          File('lib/features/gateway/learning_library_screen.dart')
              .readAsStringSync();
      final routes = RegExp(r"route: '([^']+)'")
          .allMatches(library)
          .map((m) => m.group(1)!)
          .toList();
      expect(routes, hasLength(16));
      expect(routes.toSet(), hasLength(16), reason: 'مسیر تکراری بین کارت‌ها');
      for (final route in routes) {
        expect(
          AppRoutes.isKnown(route),
          isTrue,
          reason: 'کارتِ «$route» به مسیرِ ثبت‌نشده می‌رود',
        );
      }
    });
  });

  group('مقصدهای داخلِ lib', () {
    test('هیچ route:/nextRoute: به مسیرِ ناشناخته اشاره نمی‌کند', () {
      final problems = <String>[];
      final pattern = RegExp(
        r"\b(?:route|nextRoute|targetRoute|initialRoute)\s*:\s*'([^']+)'",
      );
      for (final file in libFiles()) {
        final source = file.readAsStringSync();
        for (final match in pattern.allMatches(source)) {
          final route = match.group(1)!;
          if (!isResolvable(route)) {
            problems.add('${file.path}: $route');
          }
        }
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('همهٔ فراخوانی‌های pushNamed با نامِ ثابت، مقصدِ واقعی دارند', () {
      final problems = <String>[];
      final pattern = RegExp(
        r"push(?:Replacement)?Named(?:AndRemoveUntil)?\s*\(\s*"
        r"(?:context\s*,\s*)?'([^']+)'",
        multiLine: true,
      );
      for (final file in libFiles()) {
        final source = file.readAsStringSync();
        for (final match in pattern.allMatches(source)) {
          final route = match.group(1)!;
          if (!isResolvable(route)) {
            problems.add('${file.path}: $route');
          }
        }
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('مسیرهای ذخیره‌شده پیش از ناوبری اعتبارسنجی می‌شوند', () {
      // «ادامه با فندقی» و چیپ‌های «اخیراً» از حافظهٔ دستگاه می‌آیند و
      // می‌توانند از نسخهٔ قبلیِ برنامه باقی مانده باشند.
      final strip = File('lib/features/growth/widgets/growth_home_strip.dart')
          .readAsStringSync();
      expect(strip, contains('AppRoutes.isKnown('));
      expect(strip, contains('AppRoutes.sanitize('));

      final store = File('lib/core/growth/growth_store.dart').readAsStringSync();
      expect(store, contains('AppRoutes.sanitize('));
      expect(store, contains('AppRoutes.isKnown('));
    });
  });

  group('اعتبارسنجیِ مسیر', () {
    test('مسیرهای ثبت‌شده پذیرفته می‌شوند', () {
      for (final route in AppRoutes.exact) {
        expect(AppRoutes.isKnown(route), isTrue, reason: route);
      }
      expect(AppRoutes.isKnown('/game/الفبا'), isTrue);
      expect(AppRoutes.isKnown('/life-skills/traffic'), isTrue);
      expect(AppRoutes.isKnown('/story/story_1'), isTrue);
    });

    test('مسیرِ ناشناخته و رشته‌های ناقص رد می‌شوند', () {
      for (final bad in <String>[
        '',
        '   ',
        'home',
        '/homee',
        '/wildlife/extra',
        '/learning_library',
        '/coloring/',
        '/game/',
        '/poems/extra/deep',
        'https://example.com/home',
        'null',
      ]) {
        expect(AppRoutes.isKnown(bad), isFalse, reason: '«$bad» نباید معتبر باشد');
      }
      expect(AppRoutes.isKnown(null), isFalse);
      // فاصلهٔ اضافیِ ذخیره‌شده مشکلی نیست؛ مسیر تمیز می‌شود.
      expect(AppRoutes.isKnown('  /home  '), isTrue);
      expect(AppRoutes.sanitize('/home'), '/home');
      expect(AppRoutes.sanitize('/does-not-exist'), isNull);
      expect(AppRoutes.sanitize('  '), isNull);
    });
  });
}
