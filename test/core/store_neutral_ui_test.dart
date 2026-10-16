import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The production release explicitly uses Myket for payments. Only payment
/// information, release notes and store support may name it; educational UI
/// stays neutral and must never promote a competing billing gateway.
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

  const myketPaymentSurfaces = <String>{
    'lib/core/billing_service.dart',
    'lib/core/growth/whats_new.dart',
    'lib/features/shop/full_version_paywall.dart',
    'lib/shared/widgets/purchase_access_status.dart',
  };

  test('store branding stays inside the approved Myket payment and support surfaces', () {
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
            final path = file.path.replaceAll('\\', '/');
            if ((name == 'مایکت' || name == 'Myket') &&
                myketPaymentSurfaces.contains(path)) {
              continue;
            }
            offenders.add('${file.path}:${i + 1} → $name');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'نام فروشگاه خارج از سطح مجاز پرداخت/پشتیبانی آمده است:\n'
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

  test('store support actions still use the native bridge', () {
    // Review/details links remain native actions, not alternate payment flows.
    final billing = File('lib/core/billing_service.dart').readAsStringSync();
    expect(billing.contains('openStoreReview'), isTrue);
    expect(billing.contains('openStoreDetails'), isTrue);

    final rating = File('lib/core/store_rating_service.dart').readAsStringSync();
    expect(rating.contains('openStoreReview'), isTrue,
        reason: 'امتیازدهی باید به فروشگاه نصب‌کننده برود');
  });

  test('payment and receipt status explicitly identify Myket, not another gateway', () {
    final paywall =
        File('lib/features/shop/full_version_paywall.dart').readAsStringSync();
    final status =
        File('lib/shared/widgets/purchase_access_status.dart').readAsStringSync();
    expect(paywall, contains('در پرداخت مایکت'));
    expect(status, contains('رسید امضاشدهٔ مایکت تأیید شد'));
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
