import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 🏪 اپ روی چند فروشگاه (کافه‌بازار، مایکت، …) منتشر می‌شود و یک APK
/// واحد دارد. کاربرِ مایکت نباید هیچ‌جا اسم کافه‌بازار را ببیند و برعکس.
///
/// این تست، **متن‌های قابل‌نمایش** را در کل `lib/` می‌گردد و اگر کسی
/// دوباره نام یک فروشگاه را داخل رابط کاربری بنویسد، قرمز می‌شود.
/// کامنت‌ها آزادند: آن‌ها را کاربر نمی‌بیند و برای نگه‌داری کد لازم‌اند.
void main() {
  /// نام فروشگاه‌ها به شکلی که ممکن است در متن فارسی بیاید.
  const storeNames = <String>[
    'کافه‌بازار',
    'کافه بازار',
    'کافەبازار',
    'مایکت',
    'CafeBazaar',
    'Cafe Bazaar',
    'Myket',
  ];

  /// خطِ کد را از کامنت تشخیص می‌دهد (کامنت‌های `//` و `///`).
  bool isComment(String line) {
    final t = line.trimLeft();
    return t.startsWith('//') || t.startsWith('*') || t.startsWith('/*');
  }

  /// آیا این خط یک رشتهٔ متنی دارد؟ فقط رشته‌ها به کاربر نشان داده می‌شوند.
  bool hasStringLiteral(String line) =>
      line.contains("'") || line.contains('"');

  test('no store brand name appears in any user-visible string', () {
    final offenders = <String>[];

    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in dartFiles) {
      // این فایل‌ها عمداً نام فروشگاه را می‌شناسند:
      //  - store_vendor: منطق مسیریابی درگاه (شناسهٔ فنی)
      //  - store_listing: متن صفحهٔ «درباره» که مایکت صراحتاً نام و لینک
      //    خودش را در برنامه‌های درون‌پرداخت می‌خواهد.
      if (file.path.endsWith('store_vendor.dart')) continue;
      if (file.path.endsWith('store_listing.dart')) continue;

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (isComment(line)) continue;
        if (!hasStringLiteral(line)) continue;
        for (final name in storeNames) {
          if (line.contains(name)) {
            offenders.add('${file.path}:${i + 1} → $name');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'نام فروشگاه نباید در متنِ قابل‌نمایش باشد:\n'
          '${offenders.join('\n')}',
    );
  });

  test('the purchase button says only "خرید نسخه کامل"', () {
    final paywall =
        File('lib/features/shop/full_version_paywall.dart').readAsStringSync();

    expect(paywall.contains("'خرید نسخه کامل'"), isTrue,
        reason: 'متن دکمهٔ خرید باید دقیقاً «خرید نسخه کامل» باشد');
    // متن قدیمیِ وابسته به فروشگاه نباید برگردد.
    expect(paywall.contains('خرید امن از'), isFalse);
  });

  test('the app never hardcodes a single store gateway in Dart', () {
    // خرید باید از مسیر انتخاب خودکار درگاه برود، نه صدا زدن مستقیم یک
    // فروشگاه. (نام متد قدیمیِ openBazaarReview فقط به‌عنوان alias مانده.)
    final billing = File('lib/core/billing_service.dart').readAsStringSync();
    expect(billing.contains('openStoreReview'), isTrue);
    expect(billing.contains('openStoreDetails'), isTrue);

    final rating = File('lib/core/store_rating_service.dart').readAsStringSync();
    expect(rating.contains('openStoreReview'), isTrue,
        reason: 'امتیازدهی باید به فروشگاه نصب‌کننده برود');
  });

  test('about screen source never links to the publisher website', () {
    final about =
        File('lib/features/about/about_screen.dart').readAsStringSync();
    expect(about.contains('websiteUrl'), isFalse);
    expect(about.contains('github.io'), isFalse);
    expect(about.contains('ورود مستقیم به سایت'), isFalse);

    final card =
        File('lib/shared/widgets/parsa_website_card.dart').readAsStringSync();
    expect(card.contains('ورود مستقیم به سایت'), isFalse);
    expect(card.contains('github.io'), isFalse);
  });
}
