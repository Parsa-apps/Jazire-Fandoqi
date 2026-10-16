import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/datasources/hive_player_store.dart';
import 'billing_service.dart';
import 'security/secure_store.dart';

enum FullVersionAccessStatus {
  checking,
  free,
  needsRestore,
  untrustedBuild,
  storeVerified,
  offlineVerified;

  bool get isVerified =>
      this == storeVerified || this == offlineVerified;
}

/// Permanent ownership requires a signed store receipt, not a historic local
/// grant. Offline access re-verifies the saved JSON/signature with native RSA.
/// An authoritative empty inventory revokes it; unavailable stores do not.
class Monetization {
  static const String productIdFullVersion = BillingService.fullVersionProductId;
  static const int receiptCacheSchema = 2;
  static const String signedReceiptKey = 'entitlement.signed_receipt.v2';

  static const _legacySecureKeys = <String>[
    'entitlement.granted',
    'entitlement.receipt_token',
    'entitlement.receipt_order',
  ];
  static final _accessStatus =
      ValueNotifier<FullVersionAccessStatus>(FullVersionAccessStatus.checking);
  static ValueListenable<FullVersionAccessStatus> get accessStatus => _accessStatus;

  static Future<bool>? _pendingCheck;
  static int _revision = 0;
  static bool _lastDecision = false;
  static String lastPurchaseError = '';

  /// Coalesce inventory queries from simultaneously mounting hubs. The SDK
  /// must not be asked to set up / query itself several times concurrently.
  static Future<bool> hasFullVersion() {
    final pending = _pendingCheck;
    if (pending != null) return pending;
    final revision = _revision;
    late final Future<bool> check;
    check = _checkAccess(revision).whenComplete(() {
      if (identical(_pendingCheck, check)) _pendingCheck = null;
    });
    _pendingCheck = check;
    return check;
  }

  static Future<bool> _checkAccess(int revision) async {
    final restored = await BillingService.restorePurchases();
    if (revision != _revision) return _lastDecision;
    if (restored.status == BillingStatus.untrustedBuild) {
      // Never erase a genuine receipt merely because this APK is not the
      // official release. It still must not unlock any paid destination.
      return _publish(FullVersionAccessStatus.untrustedBuild);
    }
    if (restored.hasMyketFullVersionReceipt) {
      final accepted = await _acceptReceipt(restored, expectedRevision: revision);
      if (accepted || revision != _revision) return _lastDecision;
      return _revoke(revision, FullVersionAccessStatus.needsRestore);
    }
    if (restored.status == BillingStatus.notOwned) {
      return _revoke(revision, FullVersionAccessStatus.free);
    }
    if (restored.status == BillingStatus.invalidReceipt) {
      return _revoke(revision, FullVersionAccessStatus.needsRestore);
    }

    // Only a receipt whose signature is checked again may survive offline.
    // Do not promote a legacy true/nonempty-token pair into a verified cache.
    final saved = await SecureStore.read(signedReceiptKey);
    if (revision != _revision) return _lastDecision;
    if (saved != null) {
      final proof = await _verifySavedReceipt(saved);
      if (revision != _revision) return _lastDecision;
      return _publish(proof.hasMyketFullVersionReceipt
          ? FullVersionAccessStatus.offlineVerified
          : FullVersionAccessStatus.needsRestore);
    }
    final oldGrant = await SecureStore.read('entitlement.granted');
    if (revision != _revision) return _lastDecision;
    return _publish(oldGrant == 'true'
        ? FullVersionAccessStatus.needsRestore
        : FullVersionAccessStatus.free);
  }

  static Future<BillingResult> _verifySavedReceipt(String saved) async {
    try {
      final record = jsonDecode(saved);
      if (record is Map &&
          record['schema'] == receiptCacheSchema &&
          record['signedData'] is String &&
          record['signature'] is String &&
          record['store'] == 'myket') {
        return BillingService.verifyFullVersionReceipt(
          signedData: record['signedData'] as String,
          signature: record['signature'] as String,
          store: record['store'] as String,
        );
      }
    } catch (_) {
      // Corrupt or legacy local data is never an entitlement.
    }
    return const BillingResult.failure(
      'رسید ذخیره‌شده نیاز به بازیابی دارد',
      status: BillingStatus.invalidReceipt,
    );
  }

  static Future<bool> activateFullVersion(BillingResult result) =>
      _acceptReceipt(result);

  static Future<bool> _acceptReceipt(
    BillingResult result, {
    int? expectedRevision,
  }) async {
    if (!result.hasMyketFullVersionReceipt) {
      lastPurchaseError = result.message.isNotEmpty
          ? result.message : 'رسید امضاشدهٔ نسخهٔ کامل دریافت نشد';
      return false;
    }
    // This also protects callers constructing BillingResult themselves: the
    // native verifier re-derives ownership from signed bytes, not these fields.
    final proof = await BillingService.verifyFullVersionReceipt(
      signedData: result.signedData!,
      signature: result.signature!,
      store: result.store!,
    );
    if (expectedRevision != null && expectedRevision != _revision) {
      return _lastDecision;
    }
    if (!proof.hasMyketFullVersionReceipt) {
      lastPurchaseError = 'امضای رسید نسخهٔ کامل تأیید نشد';
      return false;
    }
    final revision = ++_revision;
    _pendingCheck = null;
    _lastDecision = true;
    // One atomic encrypted record: a partially written grant cannot unlock.
    await SecureStore.write(signedReceiptKey, jsonEncode(<String, Object?>{
      'schema': receiptCacheSchema,
      'store': proof.store,
      'signedData': proof.signedData,
      'signature': proof.signature,
    }));
    await _clearLegacyKeys();
    if (revision != _revision) return _lastDecision;
    lastPurchaseError = '';
    return _publish(FullVersionAccessStatus.storeVerified);
  }

  static Future<bool> _revoke(
    int expectedRevision,
    FullVersionAccessStatus status,
  ) async {
    if (expectedRevision != _revision) return _lastDecision;
    final revision = ++_revision;
    _pendingCheck = null;
    _lastDecision = false;
    await SecureStore.delete(signedReceiptKey);
    await _clearLegacyKeys();
    if (revision != _revision) return _lastDecision;
    return _publish(status);
  }

  static Future<bool> restoreFullVersion() async {
    final revision = _revision;
    final result = await BillingService.restorePurchases();
    if (revision != _revision) return _lastDecision;
    if (result.status == BillingStatus.notOwned ||
        result.status == BillingStatus.invalidReceipt) {
      await _revoke(revision, result.status == BillingStatus.notOwned
          ? FullVersionAccessStatus.free : FullVersionAccessStatus.needsRestore);
    }
    return _acceptReceipt(result);
  }

  static Future<bool> purchaseFullVersion() async =>
      _acceptReceipt(await BillingService.purchaseNonConsumable(productIdFullVersion));

  static Future<bool> isPremium() => hasFullVersion();
  static Future<bool> activatePremium(BillingResult result) => activateFullVersion(result);
  static Future<bool> restorePremium() => restoreFullVersion();

  static bool _publish(FullVersionAccessStatus status) {
    _lastDecision = status.isVerified;
    _accessStatus.value = status;
    return _lastDecision;
  }

  /// Only obsolete entitlement keys are touched, never progress, PIN or coins.
  static Future<void> _clearLegacyKeys() async {
    for (final key in _legacySecureKeys) {
      await SecureStore.delete(key);
    }
    await HivePlayerStore.writeValue('has_full_version', false);
    await HivePlayerStore.writeValue('full_version_receipt_token', '');
    await HivePlayerStore.writeValue('full_version_receipt_order', '');
  }

  @visibleForTesting
  static void resetForTesting() {
    _revision++;
    _pendingCheck = null;
    _lastDecision = false;
    lastPurchaseError = '';
    _accessStatus.value = FullVersionAccessStatus.checking;
  }
}
