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

  // 🧪 [DEV-UNLOCK-BLOCK] تست‌های کد تست موقت — همراه بلوک حذف می‌شوند
  group('activateWithCode (تست موقت توسعه‌دهنده)', () {
    test('rejects empty and unknown codes', () async {
      expect(await Monetization.activateWithCode(''), isFalse);
      expect(await Monetization.activateWithCode('WRONG-CODE'), isFalse);
      expect(await Monetization.activateWithCode('FANDOGHI'), isFalse);
    });

    test('accepts a valid code', () async {
      expect(await Monetization.activateWithCode('FANDOGHI1404'), isTrue);
    });

    test('normalization handles persian digits, case and spaces', () async {
      expect(Monetization.normalizeUnlockCode('  fandoghi۱۴۰۴ '), 'FANDOGHI1404');
      expect(Monetization.normalizeUnlockCode('parsa٢٠٢٦'), 'PARSA2026');
      expect(await Monetization.activateWithCode('fandoghi۱۴۰۴'), isTrue);
    });
  });
}
