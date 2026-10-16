import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 🧾 متنِ صفحهٔ «درباره و پشتیبانی» برای *والد* است، نه برای توسعه‌دهنده.
///
/// این تست سه اشتباه تکرارشونده را می‌گیرد که در نسخهٔ منتشرشدهٔ ۶.۲.۶ دیده شد:
///
///  ۱) نشتِ نامِ فایل داخلی به رابط کاربری («متن سیاست حریم خصوصی در فایل
///     PRIVACY_POLICY_FA.md…») — چیزی که برای والد بی‌معناست و در بازبینی
///     فروشگاه نشانهٔ متنِ ناتمام است.
///  ۲) برچسبی که نصبِ رایگانِ برنامه را «پریمیوم» معرفی کند، درست در
///     پایین صفحه‌ای که خودِ فروشگاه هم «نصب رایگان» را وعده می‌دهد.
///  ۳) نبودِ مسیر «بازیابی خرید» در صفحه‌ای که والد برای پشتیبانی باز
///     می‌کند (این ورودی در ۶.۲.۶ بود و در ۷.۱ حذف شده بود).
///
/// بررسی متن فقط روی رشته‌های داخل کد انجام می‌شود تا کامنت‌ها و مسیرِ
/// فایل‌های import (که خودشان پسوند دارند) رد نشوند.
void main() {
  final source =
      File('lib/features/about/about_screen.dart').readAsStringSync();
  // مسیرهای import خودشان رشته‌اند؛ برای بررسی «متنِ نمایشی» باید کنار
  // گذاشته شوند، وگرنه نامِ فایل‌های پروژه هم متنِ نمایشی شمرده می‌شوند.
  final withoutImports = source.replaceAll(
    RegExp(r'^\s*(import|export|part)\s+.*$', multiLine: true),
    '',
  );
  final userFacingText = _stringLiterals(withoutImports).join('\n');

  test('no internal file name leaks into the about screen', () {
    final fileNames = RegExp(
      r'[A-Za-z0-9_\-]+\.(md|txt|json|yaml|yml|dart|kt|gradle|properties)',
    ).allMatches(userFacingText).map((m) => m.group(0)!).toSet();

    expect(fileNames, isEmpty,
        reason: 'نامِ فایل داخلی نباید در رابط کاربریِ منتشرشده دیده شود:\n'
            '${fileNames.join('\n')}');
  });

  test('the about screen does not label the free install as premium', () {
    expect(userFacingText.contains('پریمیوم'), isFalse,
        reason: 'نصب برنامه رایگان است؛ برچسب «پریمیوم» در صفحهٔ درباره '
            'با وعدهٔ فروشگاه ناسازگار است.');
  });

  test('the about screen offers a parent-gated purchase restore', () {
    expect(source.contains('بازیابی خرید'), isTrue,
        reason: 'والدی که برنامه را حذف و دوباره نصب کرده باید از همین صفحه '
            'بتواند خریدش را بازیابی کند.');
    expect(source.contains('requestParentAccess'), isTrue,
        reason: 'بازیابی باید پشت دروازهٔ والد باشد، دقیقاً مثل خودِ خرید.');
  });

  test('the about screen identifies both the version and build number', () {
    expect(source, contains('PersianDigits.toFa(GrowthStore.appVersion)'));
    expect(source, contains('WhatsNew.buildNumber'));
  });

  test('the about screen never links to the publisher website', () {
    // برنامه‌های درون‌پرداختِ مایکت نباید کاربر را به سایت ناشر ببرند.
    expect(source.contains('websiteUrl'), isFalse);
    expect(source.contains('github.io'), isFalse);
    expect(source.contains('ورود مستقیم به سایت'), isFalse);
  });
}

/// همهٔ رشته‌های داخل کد را بیرون می‌کشد (تک‌گیومه و دوگیومه).
List<String> _stringLiterals(String source) {
  // رشتهٔ سه‌گیومهٔ خام: داخلش می‌شود هم «'» و هم «"» را بدون escape
  // نگه داشت. (رشتهٔ خام دوتایی با «\"» زودتر از حد بسته می‌شد.)
  final pattern = RegExp(
    r'''(?:'(?:[^'\\\n]|\\.)*'|"(?:[^"\\\n]|\\.)*")''',
  );
  return pattern
      .allMatches(source)
      .map((m) => m.group(0)!)
      .where((literal) => literal.length > 2)
      .toList();
}
