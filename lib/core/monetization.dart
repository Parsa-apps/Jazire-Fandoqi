import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/datasources/hive_player_store.dart';
import 'billing_service.dart';

/// One-time full-version entitlement. The store is the authority in release;
/// local storage only improves the offline experience after a verified restore.
class Monetization {
  static const String _fullVersionKey = 'has_full_version';
  static const String _receiptTokenKey = 'full_version_receipt_token';
  static const String productIdFullVersion = 'full_version';

  static Future<bool> hasFullVersion() async {
    final cached = await HivePlayerStore.readValue(_fullVersionKey);
    if (!kReleaseMode) return cached is bool && cached;
    final restored = await BillingService.restorePurchases();
    if (!restored.success || restored.purchaseToken?.isEmpty != false) return false;
    await HivePlayerStore.writeValue(_receiptTokenKey, restored.purchaseToken!);
    await HivePlayerStore.writeValue(_fullVersionKey, true);
    return true;
  }

  static Future<bool> activateFullVersion(BillingResult result) async {
    if (!result.success) return false;
    if (kReleaseMode && (result.purchaseToken == null || result.purchaseToken!.isEmpty)) {
      return false;
    }
    await HivePlayerStore.writeValue(_fullVersionKey, true);
    if (result.purchaseToken?.isNotEmpty == true) {
      await HivePlayerStore.writeValue(_receiptTokenKey, result.purchaseToken!);
    }
    return true;
  }

  static Future<bool> restoreFullVersion() async =>
      activateFullVersion(await BillingService.restorePurchases());

  static Future<bool> purchaseFullVersion() async =>
      activateFullVersion(await BillingService.purchaseNonConsumable(productIdFullVersion));

  /// Compatibility aliases kept while feature screens migrate to the permanent model.
  static Future<bool> isPremium() => hasFullVersion();
  static Future<bool> activatePremium(BillingResult result) => activateFullVersion(result);
  static Future<bool> restorePremium() => restoreFullVersion();
}
