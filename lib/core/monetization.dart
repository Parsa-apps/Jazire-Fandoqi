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

  // ──────────────────────────────────────────────────────────────────
  // 🧪 [DEV-UNLOCK-BLOCK] فعال‌سازی موقت با کد — فقط برای تست سازنده
  //
  // TODO(REMOVE-BEFORE-BAZAAR-RELEASE): قبل از انتشار نسخه نهایی در
  // کافه‌بازار، کل این بلوک و بخش «کد تخفیف» در
  // lib/features/shop/full_version_paywall.dart را کامل حذف کن
  // (جست‌وجو: DEV-UNLOCK-BLOCK). هرکس کد را داشته باشد نسخه کامل را
  // رایگان فعال می‌کند؛ پس نباید وارد بیلد انتشار شود.
  // ──────────────────────────────────────────────────────────────────
  static const String _devUnlockKey = 'dev_unlocked_code_v1';

  /// کدهای معتبر فعال‌سازی آفلاین (به بزرگی/کوچکی حروف و ارقام فارسی حساس نیست)
  static const Set<String> _devUnlockCodes = {'FANDOGHI1404', 'PARSA2026'};

  /// نرمال‌سازی ورودی کد: حذف فاصله و خط‌تیره‌ی اطراف، تبدیل ارقام
  /// فارسی/عربی به لاتین و یکدست‌کردن حروف بزرگ.
  static String normalizeUnlockCode(String raw) {
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = raw.trim();
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(persian[i], '$i').replaceAll(arabic[i], '$i');
    }
    return result.toUpperCase();
  }

  /// اعتبارسنجی کد؛ در صورت صحت، نسخه کامل به‌صورت محلی فعال می‌شود.
  static Future<bool> activateWithCode(String rawCode) async {
    final code = normalizeUnlockCode(rawCode);
    if (code.isEmpty || !_devUnlockCodes.contains(code)) return false;
    await HivePlayerStore.writeValue(_fullVersionKey, true);
    await HivePlayerStore.writeValue(_devUnlockKey, code);
    return true;
  }

  /// آیا قبلاً با کد تست فعال شده؟ (در debug و release هر دو به رسمیت شناخته
  /// می‌شود تا بیلد APK گیت‌هاب هم برای تست باز باشد — همین است که باید قبل
  /// از انتشار حذف شود.)
  static Future<bool> hasDevUnlock() async {
    final stored = await HivePlayerStore.readValue(_devUnlockKey);
    return stored is String && _devUnlockCodes.contains(stored);
  }
  // ──────────────────── پایان [DEV-UNLOCK-BLOCK] ────────────────────

  static Future<bool> hasFullVersion() async {
    // 🧪 [DEV-UNLOCK-BLOCK]: کد تست — قبل از انتشار حذف شود
    if (await hasDevUnlock()) return true;
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
