import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// هر بیلد فقط با فروشگاه خودش پرداخت می‌کند. نام فروشگاه‌ها تنها در
/// store_vendor (شناسهٔ فنی) و store_listing (صفحهٔ پشتیبانی) مجاز است؛
/// متن پرداخت و رسید از StorePolicy می‌آید تا بیلد بازار «مایکت» و بیلد
/// مایکت «کافه‌بازار» نشان ندهد.
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

  test('store branding stays inside the approved vendor and support surfaces', () {
    final offenders = <String>[];

    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in dartFiles) {
      // این فایل‌ها عمداً نام فروشگاه را می‌شناسند:
      //  - store_vendor: شناسهٔ فنی flavorها (bazaar/myket)
      //  - store_listing: متن صفحهٔ «درباره» که هر فروشگاه صراحتاً نام و
      //    لینک خودش را در برنامه‌های درون‌پرداخت می‌خواهد.
      // بقیهٔ UI فقط از StorePolicy استفاده می‌کند و نام ثابت ندارد.
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

  test('payment and receipt status name the running store through StorePolicy', () {
    final paywall =
        File('lib/features/shop/full_version_paywall.dart').readAsStringSync();
    final status =
        File('lib/shared/widgets/purchase_access_status.dart').readAsStringSync();
    expect(paywall, contains('StorePolicy.paymentMethodLabel'));
    expect(paywall, contains('StorePolicy.finalPriceNotice'));
    expect(status, contains('StorePolicy.receiptVerifiedNotice'));
    expect(status, contains('StorePolicy.offlineReceiptVerifiedNotice'));
    expect(status, contains('StorePolicy.untrustedBuildNotice'));
  });

  group('Cafe Bazaar review compliance (store isolation)', () {
    // گزارش بررسی بازار: «پرداخت درون‌برنامه‌ای مارکت‌های دیگر —
    // ir.mservices.market.BILLING باید از برنامه حذف شود». این تست دقیقاً
    // همان چیزی را قفل می‌کند که باعث رد شدن نسخه شده بود.
    test('the Bazaar flavor strips the Myket billing permission', () {
      final manifest = File(
        'android/app/src/bazaar/AndroidManifest.xml',
      ).readAsStringSync();
      expect(
        manifest,
        contains('com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR'),
      );
      expect(manifest, contains('ir.mservices.market.BILLING'));
      expect(
        RegExp(
          r'<uses-permission\s+android:name="ir\.mservices\.market\.BILLING"'
          r'\s+tools:node="remove"\s*/>',
        ).hasMatch(manifest),
        isTrue,
        reason: 'مجوز پرداخت مایکت باید با tools:node="remove" حذف شود',
      );
      // هیچ اعلان مستقیمی از مجوز مایکت در flavor بازار نماند.
      expect(
        RegExp(
          r'<uses-permission\s+android:name="ir\.mservices\.market\.BILLING"\s*/>',
        ).hasMatch(manifest),
        isFalse,
      );
    });

    test('the Myket flavor strips the Bazaar billing permission', () {
      final manifest = File(
        'android/app/src/myket/AndroidManifest.xml',
      ).readAsStringSync();
      expect(
        RegExp(
          r'<uses-permission\s+android:name="com\.farsitel\.bazaar\.permission'
          r'\.PAY_THROUGH_BAZAAR"\s+tools:node="remove"\s*/>',
        ).hasMatch(manifest),
        isTrue,
      );
    });

    test('the Bazaar source set contains no Myket SDK reference', () {
      final offenders = <String>[];
      final bazaarSources = Directory('android/app/src/bazaar')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.kt'));
      for (final file in bazaarSources) {
        final text = file.readAsStringSync();
        if (text.contains('ir.myket.billingclient')) {
          offenders.add(file.path);
        }
      }
      expect(offenders, isEmpty,
          reason: 'SDK مایکت نباید در بیلد بازار وجود داشته باشد');
    });

    test('store dependencies are flavor-scoped, never shared', () {
      final gradle = File('android/app/build.gradle').readAsStringSync();
      expect(gradle, contains('bazaarImplementation "com.github.cafebazaar'));
      expect(gradle, contains('myketImplementation("com.github.myketstore'));
      // استفادهٔ مشترک از SDK فروشگاه‌ها، مجوز فروشگاه رقیب را وارد APK
      // می‌کند؛ این الگو نباید برگردد.
      expect(
        RegExp(r'^\s*implementation\s+"com\.github\.cafebazaar', multiLine: true)
            .hasMatch(gradle),
        isFalse,
      );
      expect(
        RegExp(
          r'^\s*implementation\s*\(?\s*"com\.github\.myketstore',
          multiLine: true,
        ).hasMatch(gradle),
        isFalse,
      );
    });
  });

  test('the rating section names only the shipping store', () {
    // گزارش بازار: متن «امتیاز به جزیره فندقی» نباید به فروشگاه دیگری
    // ارجاع بدهد. متن از StorePolicy می‌آید و عبارت مبهم «در فروشگاه»
    // (که مرورگر آن را به فروشگاه دیگر تعبیر کرد) حذف شده است.
    final about =
        File('lib/features/about/about_screen.dart').readAsStringSync();
    expect(about, contains('StorePolicy.ratingCardSubtitle'));
    expect(about, contains('StorePolicy.ratingDialogHint'));
    expect(about, isNot(contains('می‌توانید در فروشگاه هم به ما امتیاز بدهید')));
    expect(about, contains('StorePolicy.ensureResolved()'));

    final policy = File('lib/core/store_policy.dart').readAsStringSync();
    expect(policy, isNot(contains('در فروشگاه به ما امتیاز بدهید')));
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
