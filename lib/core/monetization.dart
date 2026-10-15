import 'package:flutter/foundation.dart';

import '../data/datasources/hive_player_store.dart';
import 'billing_service.dart';
import 'security/secure_store.dart';

/// One-time full-version entitlement. The store is the authority in release;
/// the Keystore-backed grant keeps the purchase working offline and makes a
/// plaintext file edit unable to forge premium access.
///
/// 🔐 مدل امنیتی (v6.3):
///  - در release، مرجع واقعی همان فروشگاهی است که اپ از آن نصب شده
///    (کافه‌بازار یا مایکت) — بازیابی خرید با تأیید امضای RSA رسید.
///  - بعد از تأیید استور، گرنت + توکن رسید در SecureStore (Android Keystore)
///    ذخیره می‌شود؛ دستکاری فایل Hive دیگر نمی‌تواند پریمیوم جعل کند.
///  - در حالت آفلاین، فقط گرنت Keystore که پیش‌تر با پاسخ معتبر فروشگاه
///    ذخیره شده قبول می‌شود. فلگ و توکن قدیمی Hive به‌تنهایی هرگز مرجع نیستند؛
///    کاربران قدیمی باید هنگام اتصال از خود فروشگاه بازیابی کنند.
class Monetization {
  static const String _fullVersionKey = 'has_full_version';
  static const String _receiptTokenKey = 'full_version_receipt_token';
  static const String _receiptOrderKey = 'full_version_receipt_order';
  static const String productIdFullVersion = 'full_version';

  // Keystore-backed grant keys (native SecureStore).
  static const String _grantKey = 'entitlement.granted';
  static const String _grantTokenKey = 'entitlement.receipt_token';
  static const String _grantOrderKey = 'entitlement.receipt_order';

  /// آخرین پیام خطای خرید/بازیابی برای نمایش در UI (مثلاً «پرداخت لغو شد»).
  /// خالی یعنی خطایی نبوده. هر تلاش جدید این مقدار را بازنشانی می‌کند.
  static String lastPurchaseError = '';

  static Future<bool> hasFullVersion() async {
    if (!kReleaseMode) {
      final cached = await HivePlayerStore.readValue(_fullVersionKey);
      return cached is bool && cached;
    }
    // ۱) استور مرجع است: بازیابی خرید با تأیید امضا.
    final restored = await BillingService.restorePurchases();
    if (restored.success) {
      if (restored.purchaseToken?.isNotEmpty ?? false) {
        await _storeGrant(token: restored.purchaseToken!, orderId: restored.orderId);
        await _clearLegacyKeys();
        return true;
      }
      // استور در دسترس است ولی خریدی ثبت نشده → قطعاً پریمیوم نیست،
      // حتی اگر کسی فایل‌ها را با فلگ جعلی دستکاری کرده باشد.
      return false;
    }
    // ۲) استور پاسخ معتبر نداده → فقط گرنتی که قبلاً در Keystore ذخیره
    //    شده پذیرفته می‌شود. دادهٔ قدیمی Hive قابل‌ویرایش است و شکلِ ظاهری
    //    یک توکن هم اثبات امضای فروشگاه نیست؛ بنابراین هیچ‌کدام به‌تنهایی
    //    نباید در release دسترسی پولی بدهند.
    return _isGranted();
  }

  static Future<bool> activateFullVersion(BillingResult result) async {
    if (!result.success) {
      lastPurchaseError = result.message.isNotEmpty
          ? result.message
          : 'پرداخت توسط فروشگاه تأیید نشد';
      return false;
    }
    if (kReleaseMode) {
      // یک خرید release بدون رسید استور قابل قبول نیست.
      if (result.purchaseToken == null || result.purchaseToken!.isEmpty) {
        lastPurchaseError = 'رسید خرید از فروشگاه دریافت نشد';
        return false;
      }
      await _storeGrant(token: result.purchaseToken!, orderId: result.orderId);
      await _clearLegacyKeys();
      lastPurchaseError = '';
      return true;
    }
    // حالت توسعه/تست: فلگ محلی کافی است.
    await HivePlayerStore.writeValue(_fullVersionKey, true);
    lastPurchaseError = '';
    return true;
  }

  static Future<bool> restoreFullVersion() async {
    final result = await BillingService.restorePurchases();
    lastPurchaseError = result.success ? '' : (result.message.isNotEmpty ? result.message : '');
    return activateFullVersion(result);
  }

  static Future<bool> purchaseFullVersion() async {
    final result = await BillingService.purchaseNonConsumable(productIdFullVersion);
    lastPurchaseError = result.success ? '' : (result.message.isNotEmpty ? result.message : '');
    return activateFullVersion(result);
  }

  /// Compatibility aliases kept while feature screens migrate to the permanent model.
  static Future<bool> isPremium() => hasFullVersion();
  static Future<bool> activatePremium(BillingResult result) => activateFullVersion(result);
  static Future<bool> restorePremium() => restoreFullVersion();

  // ── گرنت Keystore ────────────────────────────────────────────────────────

  static Future<void> _storeGrant({required String token, String? orderId}) async {
    await SecureStore.write(_grantKey, 'true');
    await SecureStore.write(_grantTokenKey, token);
    if (orderId != null && orderId.isNotEmpty) {
      await SecureStore.write(_grantOrderKey, orderId);
    }
  }

  static Future<bool> _isGranted() async {
    final granted = await SecureStore.read(_grantKey);
    if (granted != 'true') return false;
    final token = await SecureStore.read(_grantTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// پاک‌سازی داده‌های قدیمی فقط پس از تأیید موفق از خود فروشگاه؛ این
  /// مقادیر هرگز برای اعطای entitlement در release استفاده نمی‌شوند.
  static Future<void> _clearLegacyKeys() async {
    await HivePlayerStore.writeValue(_fullVersionKey, false);
    await HivePlayerStore.writeValue(_receiptTokenKey, '');
    await HivePlayerStore.writeValue(_receiptOrderKey, '');
  }
}
