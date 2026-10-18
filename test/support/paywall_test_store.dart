import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/security/secure_store.dart';
import 'package:jazireh_fandoghi/core/monetization.dart';
import 'package:jazireh_fandoghi/core/store_vendor.dart';
import 'package:jazireh_fandoghi/data/datasources/hive_player_store.dart';

/// Explicit native-store mocks, never a production sandbox/fallback. A success
/// here stands for the RSA-verified response from the Android store SDK.
class PaywallTestStore {
  static const billing = MethodChannel('kudake_iran/billing');
  static const secureStore = MethodChannel('kudake_iran/secure_store');
  // Only this exact pair stands for native RSA verification in Dart tests.
  // Real signature / tamper / package / state checks run in JVM unit tests.
  static const signedData = '{"packageName":"com.parsaapps.amoozesh_fandoghi",'
      '"productId":"full_version","purchaseState":0,'
      '"purchaseToken":"verified-test-receipt","orderId":"verified-test-order"}';
  static const signature = 'explicit-native-verified-test-signature';
  static const verifiedPurchase = <String, Object?>{
    'success': true,
    'status': 'verified',
    'releaseVerified': true,
    'purchaseToken': 'verified-test-receipt',
    'orderId': 'verified-test-order',
    'productId': 'full_version',
    'store': 'myket',
    'purchaseState': 0,
    'signedData': signedData,
    'signature': signature,
  };
  static const notOwned = <String, Object?>{
    'success': false,
    'status': 'not_owned',
    'message': 'خرید نسخه کامل یافت نشد',
  };

  /// The same native-verified payload for the other store-isolated build.
  static Map<String, Object?> verifiedPurchaseFor(String store) =>
      <String, Object?>{...verifiedPurchase, 'store': store};

  /// Store reported by the mocked native bridge and embedded in receipts.
  String storeName = 'myket';

  StoreVendor get storeVendor => storeName == 'bazaar'
      ? StoreVendor.bazaar : StoreVendor.myket;

  Object? purchaseResponse = const <String, Object?>{
    'success': false,
    'message': 'پرداخت لغو شد',
  };
  Object? restoreResponse = notOwned;
  bool rejectReceiptVerification = false;
  bool trustedRelease = true;
  Future<Object?> Function()? restoreOverride;
  bool offline = false;
  final values = <String, String>{};
  final calls = <String>[];

  void install() {
    HivePlayerStore.useMemoryStorage(clear: true);
    SecureStore.resetForTesting();
    Monetization.resetForTesting();
    StoreDetector.debugOverride(storeVendor);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(billing, (call) async {
      calls.add(call.method);
      if (call.method == 'storeVendor') return storeName;
      if (!trustedRelease) {
        return <String, Object?>{
          'success': false,
          'status': 'untrusted_build',
          'message': 'نسخهٔ رسمی انتشار فروشگاه لازم است',
        };
      }
      if (call.method == 'verifyReceipt') {
        final args = call.arguments as Map;
        if (!rejectReceiptVerification &&
            args['signedData'] == signedData &&
            args['signature'] == signature && args['store'] == storeName) {
          return verifiedPurchaseFor(storeName);
        }
        return <String, Object?>{
          'success': false,
          'status': 'invalid_receipt',
          'message': 'امضای رسید معتبر نیست',
        };
      }
      if (offline) throw PlatformException(code: 'offline');
      switch (call.method) {
        case 'purchase':
          final response = purchaseResponse;
          if (response is Map &&
              response['status'] == 'verified' &&
              response['store'] == storeName) {
            // A real successful transaction also updates the store inventory.
            restoreResponse = response;
          }
          return response;
        case 'restore':
          final override = restoreOverride;
          return override != null ? await override() : restoreResponse;
        case 'consume':
          return <String, Object?>{'success': true, 'status': 'completed'};
        default:
          return null;
      }
    });
    messenger.setMockMethodCallHandler(secureStore, (call) async {
      final args = call.arguments as Map;
      final key = args['key'] as String;
      switch (call.method) {
        case 'read':
          return values[key];
        case 'write':
          values[key] = args['value'] as String;
          return null;
        case 'delete':
          values.remove(key);
          return null;
      }
      return null;
    });
  }

  void dispose() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(billing, null);
    messenger.setMockMethodCallHandler(secureStore, null);
    StoreDetector.debugOverride(null);
    SecureStore.resetForTesting();
    Monetization.resetForTesting();
  }
}

/// Ordinary widget tests have no Android store. Give them an explicit
/// unpurchased native response instead of depending on a debug-only entitlement
/// shortcut or leaving the real platform channel/timeout running in FakeAsync.
void setUpUnpurchasedStore() {
  late PaywallTestStore store;
  setUp(() {
    store = PaywallTestStore()..install();
  });
  tearDown(() => store.dispose());
}
