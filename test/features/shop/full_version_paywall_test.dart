import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/features/shop/full_version_paywall.dart';

void main() {
  group('Parent Gate — Digit Normalization', () {
    test('Normalizes Persian digits to English', () {
      expect(normalizePaywallDigits('۵ + ۳'), '5 + 3');
      expect(normalizePaywallDigits('۱۲۳۴۵۶۷۸۹۰'), '1234567890');
    });

    test('Keeps English digits unchanged', () {
      expect(normalizePaywallDigits('7 + 4'), '7 + 4');
    });

    test('Handles mixed content', () {
      expect(normalizePaywallDigits('عدد ۹ و ۸'), 'عدد 9 و 8');
    });
  });

  test('paywall does not advertise a hard-coded price', () {
    final source =
        File('lib/features/shop/full_version_paywall.dart').readAsStringSync();

    expect(source, isNot(contains('49/000')));
    expect(source, isNot(contains('چهل و نه هزار تومان')));
    // The text is built at runtime from the installing store, so a Bazaar
    // build can never show the other market's name or a hard-coded amount.
    expect(source, contains('StorePolicy.finalPriceNotice'));
    expect(source, isNot(contains('مبلغ نهایی را مایکت')));
  });
}
