import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
    expect(store.values[Monetization.signedReceiptKey], isNotNull);
    expect(store.values['entitlement.granted'], isNull);
    expect(await HivePlayerStore.readValue('has_full_version'), isFalse);
    SecureStore.resetForTesting(); // simulate a new process reading Keystore
    Monetization.resetForTesting();
    store.offline = true;
    expect(await Monetization.hasFullVersion(), isTrue);
    expect(Monetization.accessStatus.value, FullVersionAccessStatus.offlineVerified);
    expect(store.calls, contains('verifyReceipt'));
  });

  test('verified restore unlocks; no local flag is trusted', () async {
    store.restoreResponse = PaywallTestStore.verifiedPurchase;
    expect(await Monetization.restoreFullVersion(), isTrue);
    expect(await Monetization.hasFullVersion(), isTrue);
    expect(store.values[Monetization.signedReceiptKey], contains('signedData'));
    expect(store.values['entitlement.receipt_token'], isNull);
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

  test('a token-only success cannot create a signed receipt cache', () async {
    store.purchaseResponse = const <String, Object?>{
      'success': true,
      'purchaseToken': 'plausible-but-unverified-token',
    };
    expect(await Monetization.purchaseFullVersion(), isFalse);
    expect(store.values, isEmpty);
  });

  test('product, channel, state and signed fields must match the native contract',
      () async {
    for (final change in <Map<String, Object?>>[
      {'productId': 'coins_100'},
      {'store': 'bazaar'},
      {'purchaseState': 1},
      {'purchaseState': null},
      {'signedData': ''},
      {'signature': null},
      {'status': 'completed'},
    ]) {
      store.purchaseResponse = <String, Object?>{
        ...PaywallTestStore.verifiedPurchase,
        ...change,
      };
      expect(await Monetization.purchaseFullVersion(), isFalse,
          reason: change.keys.join(','));
      expect(store.values, isEmpty);
    }
  });

  test('even a constructed verified result must pass native signature validation',
      () async {
    const forged = BillingResult(
      success: true,
      status: BillingStatus.verified,
      productId: 'full_version',
      store: 'myket',
      purchaseState: 0,
      purchaseToken: 'forged-token',
      signedData: 'unsigned-data',
      signature: 'unsigned-signature',
    );
    expect(await Monetization.activateFullVersion(forged), isFalse);
    expect(store.calls, contains('verifyReceipt'));
    expect(store.values, isEmpty);
  });

  test('a versioned cache with an invalid signature never unlocks offline',
      () async {
    store.values[Monetization.signedReceiptKey] = jsonEncode({
      'schema': Monetization.receiptCacheSchema,
      'store': 'myket',
      'signedData': PaywallTestStore.signedData,
      'signature': 'tampered-signature',
    });
    store.offline = true;
    expect(await Monetization.hasFullVersion(), isFalse);
    expect(Monetization.accessStatus.value, FullVersionAccessStatus.needsRestore);
  });

  test('corrupt and incomplete cached receipt records fail closed', () async {
    store.offline = true;
    for (final record in ['not-json', '{}', '{"schema":2}', 'null', '[]']) {
      SecureStore.resetForTesting();
      store.values[Monetization.signedReceiptKey] = record;
      expect(await Monetization.hasFullVersion(), isFalse);
    }
  });

  test('concurrent screens share a single inventory query', () async {
    final results = await Future.wait([
      Monetization.hasFullVersion(),
      Monetization.hasFullVersion(),
      Monetization.hasFullVersion(),
    ]);
    expect(results, [false, false, false]);
    expect(store.calls.where((method) => method == 'restore'), hasLength(1));
  });

  test('an old inventory callback cannot revoke a newer verified purchase',
      () async {
    final started = Completer<void>();
    final reply = Completer<Object?>();
    store.restoreOverride = () {
      started.complete();
      return reply.future;
    };
    final oldCheck = Monetization.hasFullVersion();
    await started.future;
    store.purchaseResponse = PaywallTestStore.verifiedPurchase;
    expect(await Monetization.purchaseFullVersion(), isTrue);
    reply.complete(PaywallTestStore.notOwned);
    expect(await oldCheck, isTrue);
    expect(store.values[Monetization.signedReceiptKey], isNotNull);
    expect(Monetization.accessStatus.value, FullVersionAccessStatus.storeVerified);
  });

  test('revocation changes only entitlement data, not progress or parent PIN',
      () async {
    const progress = {'stars': 37, 'coins': 82, 'level': 4};
    await HivePlayerStore.writeValue('state_v1', progress);
    store.values['parent.pin.hash'] = 'keep-parent-pin';
    store.values['entitlement.granted'] = 'true';
    store.values['entitlement.receipt_token'] = 'stale-token';
    expect(await Monetization.hasFullVersion(), isFalse);
    expect(await HivePlayerStore.readValue('state_v1'), progress);
    expect(store.values['parent.pin.hash'], 'keep-parent-pin');
    expect(store.values['entitlement.granted'], isNull);
    expect(store.values['entitlement.receipt_token'], isNull);
  });

  test('Android no longer fabricates successful debug purchases', () {
    final source = File('android/app/src/main/kotlin/com/parsaapps/'
        'amoozesh_fandoghi/MainActivity.kt').readAsStringSync();
    expect(source, isNot(contains('sandbox-token')));
    expect(source, isNot(contains('if (isDebuggable())')));
  });
}
