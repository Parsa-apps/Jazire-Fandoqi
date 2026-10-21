import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 🧭 نگهبانِ مسیرهای «دسته‌بندی‌ها»
///
/// باگِ اصلی این بود: کارت‌های کتابخانه به مسیرهایی مثل `/wildlife` و
/// `/science-lab` می‌رفتند که هیچ‌کدام در `main.dart` ثبت نشده بودند و کاربر
/// به صفحهٔ «صفحه پیدا نشد» می‌رسید. این تست هر مسیرِ کارت را با کلیدِ واقعیِ
/// جدول مسیرها مقایسه می‌کند تا هیچ کارتی دوباره به مسیرِ ناشناخته نرود.
void main() {
  final librarySource =
      File('lib/features/gateway/learning_library_screen.dart')
          .readAsStringSync();
  final mainSource = File('lib/main.dart').readAsStringSync();

  final cardRoutes = RegExp(r"route: '([^']+)'")
      .allMatches(librarySource)
      .map((match) => match.group(1)!)
      .toList();

  final registeredRoutes = RegExp(r"^        '([^']+)': \(context\)", multiLine: true)
      .allMatches(mainSource)
      .map((match) => match.group(1)!)
      .toSet();

  test('همهٔ کارت‌های دسته‌بندی‌ها مسیرِ ثبت‌شده دارند', () {
    expect(cardRoutes, hasLength(16));
    for (final route in cardRoutes) {
      expect(
        registeredRoutes,
        contains(route),
        reason: 'کارتِ «$route» به مسیرِ ثبت‌نشده می‌رود و کاربر صفحهٔ '
            '«صفحه پیدا نشد» را می‌بیند.',
      );
    }
  });

  test('مسیرهای تازهٔ کتابخانه دقیقاً یک بار ثبت شده‌اند', () {
    for (final route in <String>[
      '/wildlife',
      '/basics',
      '/emotions',
      '/stage-map',
      '/art-studio',
      '/coloring',
      '/poems',
      '/quran',
      '/science-lab',
    ]) {
      final occurrences = RegExp(
        "^        '${RegExp.escape(route)}': \\(context\\)",
        multiLine: true,
      ).allMatches(mainSource).length;
      expect(occurrences, 1, reason: '$route باید یک بار ثبت شود');
    }
  });

  test('درِ هاب‌های نیمه‌رایگان باز است و قفل در خودِ صفحه اعمال می‌شود', () {
    for (final route in <String>[
      '/art-studio',
      '/coloring',
      '/poems',
      '/quran',
      '/science-lab',
    ]) {
      final start = mainSource.indexOf("'$route': (context)");
      expect(start, greaterThan(-1), reason: route);
      final block = mainSource.substring(
        start,
        (start + 420).clamp(0, mainSource.length).toInt(),
      );
      expect(block, contains('isFree: true'), reason: route);
      expect(block, contains('GameAccessGate('), reason: route);
    }
  });

  test('هاب‌های موجودِ کارت‌های قدیمی هم به محافظِ مسیر وصل‌اند', () {
    for (final entry in <String, String>{
      '/wildlife': "'حیوانات'",
      '/basics': "'مفاهیم'",
      '/emotions': "'احساسات'",
    }.entries) {
      final start = mainSource.indexOf("'${entry.key}': (context)");
      expect(start, greaterThan(-1), reason: entry.key);
      final block = mainSource.substring(
        start,
        (start + 260).clamp(0, mainSource.length).toInt(),
      );
      expect(block, contains('GameAccessGate('), reason: entry.key);
      expect(block, contains('gameName: ${entry.value}'), reason: entry.key);
    }
  });
}
