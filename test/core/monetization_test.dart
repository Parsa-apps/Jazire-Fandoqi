import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/billing_service.dart';
import 'package:jazireh_fandoghi/core/monetization.dart';
import 'package:jazireh_fandoghi/core/security/secure_store.dart';
import 'package:jazireh_fandoghi/core/store_vendor.dart';
import 'package:jazireh_fandoghi/data/datasources/hive_player_store.dart';

import '../support/paywall_test_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PaywallTestStore store;

  setUp(() {
    store = PaywallTestStore()..install();
    Monetization.lastPurchaseError = '';
  });
  tearDown(() => store.dispose());

  test('a fresh install stays locked without a purchase', () async {
    expect(await Monetization.hasFullVersion(), isFalse);
    expect(store.values, isEmpty);
  });

  test('old debug flags/receipts cannot unlock an updated installation', () async {
    await HivePlayerStore.writeValue('has_full_version', true);
    await HivePlayerStore.writeValue('full_version_receipt_token', 'sandbox-token');
    await HivePlayerStore.writeValue('full_version_receipt_order', 'sandbox-order');
    expect(await Monetization.hasFullVersion(), isFalse);
  });

  test('a failed or cancelled purchase never grants access', () async {
    expect(await Monetization.purchaseFullVersion(), isFalse);
    expect(await Monetization.hasFullVersion(), isFalse);
    expect(store.values, isEmpty);
    expect(Monetization.lastPurchaseError, contains('لغو'));
  });

  test('failed restore does not create a purchase', () async {
    expect(await Monetization.restoreFullVersion(), isFalse);
    expect(await Monetization.hasFullVersion(), isFalse);
    expect(store.values, isEmpty);
  });

  test('missing native plugin fails closed for purchase, restore and consume', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(PaywallTestStore.billing, null);
    expect((await BillingService.purchaseNonConsumable('full_version')).success, isFalse);
    expect((await BillingService.restorePurchases()).success, isFalse);
    expect((await BillingService.consumePurchase('receipt')).success, isFalse);
    expect(await Monetization.hasFullVersion(), isFalse);
  });

  test('unknown store cannot activate a purchase, even in a debug build', () async {
    store.purchaseResponse = PaywallTestStore.verifiedPurchase;
    StoreDetector.debugOverride(StoreVendor.unknown);
    expect(await Monetization.purchaseFullVersion(), isFalse);
    expect(store.calls, isNot(contains('purchase')));
    expect(store.values, isEmpty);
  });

  test('malformed native responses are never successful', () async {
    for (final response in <Object?>[null, true, 'ok', <String, Object?>{},
      <String, Object?>{'success': 'true', 'purchaseToken': 'receipt'},
      <String, Object?>{'success': true, 'purchaseToken': 42},
      <String, Object?>{'success': true, 'purchaseToken': true},
    ]) {
      store.purchaseResponse = response;
      expect(await Monetization.purchaseFullVersion(), isFalse,
          reason: '$response');
      expect(store.values, isEmpty);
    }
  });

  test('success without a real receipt is rejected in every build mode', () async {
    for (final token in <String?>[null, '', '   ', 'sandbox-token']) {
      store.purchaseResponse = <String, Object?>{
        'success': true,
        'purchaseToken': token,
        // An order id on its own is not a signed store purchase token.
        'orderId': 'some-order',
      };
      expect(await Monetization.purchaseFullVersion(), isFalse, reason: '$token');
      expect(await Monetization.activateFullVersion(BillingResult(
        success: true, purchaseToken: token, orderId: 'some-order',
      )), isFalse);
      expect(store.values, isEmpty);
    }
  });

  test('a verified store purchase unlocks and survives an offline restart', () async {
    store.purchaseResponse = PaywallTestStore.verifiedPurchase;
    expect(await Monetization.purchaseFullVersion(), isTrue);
    expect(store.values['entitlement.granted'], 'true');
    expect(await HivePlayerStore.readValue('has_full_version'), isFalse);
    SecureStore.resetForTesting(); // simulate a new process reading Keystore
    store.offline = true;
    expect(await Monetization.hasFullVersion(), isTrue);
  });

  test('verified restore unlocks; no local flag is trusted', () async {
    store.restoreResponse = PaywallTestStore.verifiedPurchase;
    expect(await Monetization.restoreFullVersion(), isTrue);
    expect(await Monetization.hasFullVersion(), isTrue);
    expect(store.values['entitlement.receipt_token'], 'verified-test-receipt');
  });

  test('a stale sandbox Keystore grant is rejected offline too', () async {
    store.values.addAll(<String, String>{
      'entitlement.granted': 'true',
      'entitlement.receipt_token': 'sandbox-token',
    });
    store.offline = true;
    expect(await Monetization.hasFullVersion(), isFalse);
  });

  test('an unversioned Keystore grant cannot unlock an unpaid offline update',
      () async {
    store.values.addAll(<String, String>{
      'entitlement.granted': 'true',
      'entitlement.receipt_token': 'previous-placeholder-receipt',
      'entitlement.receipt_order': 'previous-placeholder-order',
    });
    store.offline = true;
    expect(await Monetization.hasFullVersion(), isFalse);
  });

  test('a store-confirmed missing purchase revokes an earlier cached grant',
      () async {
    store.purchaseResponse = PaywallTestStore.verifiedPurchase;
    expect(await Monetization.purchaseFullVersion(), isTrue);
    store.restoreResponse = const <String, Object?>{
      'success': false,
      'status': 'not_owned',
      'message': 'خرید نسخه کامل یافت نشد',
    };
    expect(await Monetization.hasFullVersion(), isFalse);
    SecureStore.resetForTesting();
    store.offline = true;
    expect(await Monetization.hasFullVersion(), isFalse);
  });

  test('Android no longer fabricates successful debug purchases', () {
    final source = File('android/app/src/main/kotlin/com/parsaapps/'
        'amoozesh_fandoghi/MainActivity.kt').readAsStringSync();
    expect(source, isNot(contains('sandbox-token')));
    expect(source, isNot(contains('if (isDebuggable())')));
  });
}
