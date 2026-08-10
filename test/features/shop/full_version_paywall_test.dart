import 'package:flutter_test/flutter_test.dart';
import 'package:kudake_iran/lib/features/shop/full_version_paywall.dart';

void main() {
  group('Parent Gate — Digit Normalization', () {
    test('Normalizes Persian digits to English', () {
      expect(_normalizeDigits('۵ + ۳'), '5 + 3');
      expect(_normalizeDigits('۱۲۳۴۵۶۷۸۹۰'), '1234567890');
    });

    test('Keeps English digits unchanged', () {
      expect(_normalizeDigits('7 + 4'), '7 + 4');
    });

    test('Handles mixed content', () {
      expect(_normalizeDigits('عدد ۹ و ۸'), 'عدد 9 و 8');
    });
  });
}
