import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/billing_service.dart';
import 'package:jazireh_fandoghi/core/monetization.dart';

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

  test('billing channel rejects when native returns failure', () async {
    // شبیه‌سازی پاسخی که استور واقعی در حالت release برای خطا برمی‌گرداند
    const MethodChannel('kudake_iran/billing').setMockMethodCallHandler(
      (call) async => <String, Object?>{
        'success': false,
        'message': 'پرداخت تأیید نشد',
      },
    );
    final result = await BillingService.purchaseNonConsumable('full_version');
    expect(result.success, isFalse);
  });

  test('sandbox fallback activates only outside release', () async {
    // در تست kReleaseMode=false است؛ بدون هندلر نیتیو، fallback سندباکس باید فعال شود
    const MethodChannel('kudake_iran/billing').setMockMethodCallHandler(null);
    final result = await BillingService.purchaseNonConsumable('full_version');
    expect(result.success, isTrue);
    expect(result.message, contains('سندباکس'));
  });
}
