import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/security/secure_store.dart';
import 'package:jazireh_fandoghi/core/store_vendor.dart';
import 'package:jazireh_fandoghi/data/datasources/hive_player_store.dart';

/// Explicit native-store mocks, never a production sandbox/fallback. A success
/// here stands for the RSA-verified response from the Android store SDK.
class PaywallTestStore {
  static const billing = MethodChannel('kudake_iran/billing');
  static const secureStore = MethodChannel('kudake_iran/secure_store');
  static const verifiedPurchase = <String, Object?>{
    'success': true,
    'purchaseToken': 'verified-test-receipt',
    'orderId': 'verified-test-order',
  };

  Object? purchaseResponse = const <String, Object?>{
    'success': false,
    'message': 'پرداخت لغو شد',
  };
  Object? restoreResponse = const <String, Object?>{
    'success': false,
    'message': 'خریدی ثبت نشده',
  };
  bool offline = false;
  final values = <String, String>{};
  final calls = <String>[];

  void install() {
    HivePlayerStore.useMemoryStorage(clear: true);
    SecureStore.resetForTesting();
    StoreDetector.debugOverride(StoreVendor.myket);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(billing, (call) async {
      calls.add(call.method);
      if (call.method == 'storeVendor') return 'myket';
      if (offline) throw PlatformException(code: 'offline');
      switch (call.method) {
        case 'purchase':
          return purchaseResponse;
        case 'restore':
          return restoreResponse;
        case 'consume':
          return <String, Object?>{'success': true};
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
  }
}
