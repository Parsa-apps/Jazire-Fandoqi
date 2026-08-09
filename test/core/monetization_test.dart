import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amoozesh_fandoghi/core/billing_service.dart';
import 'package:amoozesh_fandoghi/core/monetization.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('activatePremium rejects failed store results', () async {
    final result = await Monetization.activatePremium(
      const BillingResult.failure('کاربر انصراف داد'),
    );
    expect(result, isFalse);
  });

  test('sandbox (debug) purchase activates premium', () async {
    final result = await Monetization.activatePremium(
      const BillingResult.sandbox(),
    );
    expect(result, isTrue);
  });

  test('billing channel falls back to failure when no native handler', () async {
    // بدون mock نیتیو، روشنچنل در تست خطا می‌دهد → باید failure برگردد
    const MethodChannel('kudake_iran/billing').setMockMethodCallHandler(null);
    final result = await BillingService.purchaseSubscription('sub_monthly');
    expect(result.success, isFalse);
  });
}
