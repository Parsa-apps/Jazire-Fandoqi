import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/store_policy.dart';
import 'package:jazireh_fandoghi/core/store_vendor.dart';

/// 🏪 قرارداد «هر بیلد فقط فروشگاه خودش را نام می‌برد».
///
/// بیلد کافه‌بازار نباید هیچ‌جا «مایکت» نشان بدهد و برعکس. متن‌ها از
/// StorePolicy ساخته می‌شوند تا این قانون به‌جای تکرارِ رشتهٔ ثابت در
/// صفحه‌ها، یک منبع واحد داشته باشد.
void main() {
  tearDown(() => StoreDetector.debugOverride(null));

  test('a Bazaar build names only Cafe Bazaar in payment copy', () {
    StoreDetector.debugOverride(StoreVendor.bazaar);
    expect(StorePolicy.storeName, 'کافه‌بازار');
    expect(StorePolicy.paymentMethodLabel, 'در پرداخت کافه‌بازار');
    expect(StorePolicy.finalPriceNotice, contains('کافه‌بازار'));
    expect(StorePolicy.untrustedBuildNotice, contains('کافه‌بازار'));
    expect(StorePolicy.receiptVerifiedNotice, contains('کافه‌بازار'));
    expect(StorePolicy.offlineReceiptVerifiedNotice, contains('کافه‌بازار'));
    for (final text in <String>[
      StorePolicy.storeName,
      StorePolicy.paymentMethodLabel,
      StorePolicy.finalPriceNotice,
      StorePolicy.untrustedBuildNotice,
      StorePolicy.receiptVerifiedNotice,
      StorePolicy.offlineReceiptVerifiedNotice,
    ]) {
      expect(text, isNot(contains('مایکت')), reason: text);
    }
  });

  test('a Myket build names only Myket in payment copy', () {
    StoreDetector.debugOverride(StoreVendor.myket);
    expect(StorePolicy.storeName, 'مایکت');
    expect(StorePolicy.paymentMethodLabel, 'در پرداخت مایکت');
    expect(StorePolicy.finalPriceNotice, contains('مایکت'));
    for (final text in <String>[
      StorePolicy.storeName,
      StorePolicy.paymentMethodLabel,
      StorePolicy.finalPriceNotice,
      StorePolicy.untrustedBuildNotice,
      StorePolicy.receiptVerifiedNotice,
      StorePolicy.offlineReceiptVerifiedNotice,
    ]) {
      expect(text, isNot(contains('کافه‌بازار')), reason: text);
    }
  });

  test('before detection the copy stays neutral instead of guessing a store', () {
    StoreDetector.debugOverride(null);
    expect(StorePolicy.storeName, 'فروشگاه');
    expect(StorePolicy.paymentMethodLabel, contains('فروشگاه'));
    expect(StorePolicy.finalPriceNotice, contains('فروشگاه'));
    expect(StorePolicy.finalPriceNotice, isNot(contains('مایکت')));
    expect(StorePolicy.finalPriceNotice, isNot(contains('کافه‌بازار')));
  });

  test('the paywall never hard-codes a store name or an amount', () {
    final source =
        File('lib/features/shop/full_version_paywall.dart').readAsStringSync();
    for (final forbidden in <String>[
      "'مایکت'",
      "'کافه‌بازار'",
      'در پرداخت مایکت',
      'مبلغ نهایی را مایکت',
      '49,000',
      '490,000',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
    }
    expect(source, contains('StorePolicy.paymentMethodLabel'));
    expect(source, contains('StorePolicy.finalPriceNotice'));
  });
}
