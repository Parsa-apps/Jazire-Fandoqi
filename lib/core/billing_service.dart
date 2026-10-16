import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'store_vendor.dart';

/// Distinguish a confirmed empty inventory from a temporarily unavailable store.
enum BillingStatus {
  verified, notOwned, unavailable, invalidReceipt, completed, untrustedBuild,
}

/// A token or success flag alone is never proof of ownership. Signed receipt
/// data must also have passed the native RSA / package / product / state check.
class BillingResult {
  const BillingResult({
    required this.success,
    this.purchaseToken,
    this.orderId,
    this.message = '',
    this.status = BillingStatus.unavailable,
    this.productId,
    this.store,
    this.purchaseState,
    this.signedData,
    this.signature,
    this.releaseVerified = false,
  });

  const BillingResult.failure(
    this.message, {
    this.status = BillingStatus.unavailable,
  })  : success = false,
        purchaseToken = null,
        orderId = null,
        productId = null,
        store = null,
        purchaseState = null,
        signedData = null,
        signature = null,
        releaseVerified = false;

  final bool success;
  final String? purchaseToken;
  final String? orderId;
  final String message;
  final BillingStatus status;
  final String? productId;
  final String? store;
  final int? purchaseState;
  final String? signedData;
  final String? signature;
  final bool releaseVerified;

  bool get hasStoreReceipt =>
      success &&
      releaseVerified &&
      status == BillingStatus.verified &&
      purchaseState == 0 &&
      store == 'myket' &&
      (productId?.trim().isNotEmpty ?? false) &&
      (signedData?.trim().isNotEmpty ?? false) &&
      (signature?.trim().isNotEmpty ?? false) &&
      (purchaseToken?.trim().isNotEmpty ?? false) &&
      purchaseToken!.trim() != 'sandbox-token';

  bool hasReceiptFor(String expectedProductId) =>
      hasStoreReceipt && productId == expectedProductId;

  bool get hasMyketFullVersionReceipt =>
      hasReceiptFor(BillingService.fullVersionProductId) && store == 'myket';
}

/// Production Myket billing bridge. Native validates the APK's release
/// certificate before purchase, restore or offline receipt verification.
/// A completed purchase needs signed data, product/package/state validation
/// and native release attestation; debug/demo/local flags never unlock it.
/// Unit/widget tests provide explicit channel mocks outside the shipped app.
class BillingService {
  BillingService._();

  static const MethodChannel _channel = MethodChannel('kudake_iran/billing');
  static const String fullVersionProductId = 'full_version';

  /// خرید دائمی و غیرمصرف‌شدنی نسخه کامل.
  static Future<BillingResult> purchaseNonConsumable(String productId) {
    return _invoke('purchase', productId, consumable: false);
  }

  /// نام قدیمی برای سازگاری با نسخه‌های قبلی؛ در مدل جدید اشتراک وجود ندارد.
  @Deprecated('Use purchaseNonConsumable')
  static Future<BillingResult> purchaseSubscription(String productId) =>
      purchaseNonConsumable(productId);

  /// خرید آیتم مصرف‌شدنی مثل بسته سکه یا ستاره
  static Future<BillingResult> purchaseConsumable(String productId) async {
    final result = await _invoke('purchase', productId, consumable: true);
    if (result.success && !result.hasStoreReceipt) {
      return const BillingResult.failure('توکن خرید مصرف‌شدنی دریافت نشد');
    }
    return result;
  }

  /// بازیابی خریدهای قبلی کاربر
  static Future<BillingResult> restorePurchases() {
    return _invoke('restore', fullVersionProductId);
  }

  /// Verify a saved signed receipt locally, without an inventory/network call.
  /// The native bridge chooses the build's store key and requires full_version,
  /// this app's package and purchaseState == 0. Old cached flags cannot pass.
  static Future<BillingResult> verifyFullVersionReceipt({
    required String signedData,
    required String signature,
    required String store,
  }) async {
    if (store != 'myket') {
      return const BillingResult.failure(
        'نسخهٔ کامل فقط با رسید معتبر مایکت فعال می‌شود',
        status: BillingStatus.invalidReceipt,
      );
    }
    try {
      final raw = await _channel.invokeMethod<Object?>(
        'verifyReceipt',
        <String, Object?>{
          'signedData': signedData,
          'signature': signature,
          'store': store,
        },
      );
      return _parse(
        raw,
        expectedProductId: fullVersionProductId,
        expectedStore: store,
      );
    } catch (_) {
      return const BillingResult.failure(
        'تأیید رسید ذخیره‌شده ممکن نیست؛ بازیابی خرید را انجام دهید',
        status: BillingStatus.invalidReceipt,
      );
    }
  }

  /// مصرف‌کردن خرید مصرف‌شدنی. موجودی فقط بعد از موفقیت این متد باید
  /// به کودک داده شود؛ در غیر این صورت یک خرید ممکن است دوباره اعطا شود.
  static Future<BillingResult> consumePurchase(String purchaseToken) async {
    if (purchaseToken.trim().isEmpty) {
      return const BillingResult.failure('شناسه خرید نامعتبر است');
    }
    try {
      final dynamic raw = await _channel.invokeMethod<Object?>(
        'consume',
        <String, Object?>{'purchaseToken': purchaseToken},
      );
      return _parse(raw, requireReceipt: false);
    } on MissingPluginException {
      return const BillingResult.failure('سرویس پرداخت استور در دسترس نیست');
    } on PlatformException catch (e) {
      return BillingResult.failure(e.message ?? 'تأیید خرید انجام نشد');
    } catch (_) {
      return const BillingResult.failure('خطای ناشناخته در تأیید خرید');
    }
  }

  static Future<BillingResult> _invoke(
    String method,
    String productId, {
    bool consumable = false,
  }) async {
    final result = await _run(method, productId, consumable: consumable);
    // لاگ تشخیصی برای دیباگ روی دستگاه (logcat)؛ توکن/رسید خرید هرگز لاگ
    // نمی‌شود. اگر خرید یا بازیابی «بی‌صدا» شکست خورد، ردپای آن این‌جاست.
    debugPrint('[Billing] $method → success=${result.success} '
        'status=${result.status.name}');
    return result;
  }

  static Future<BillingResult> _run(
    String method,
    String productId, {
    bool consumable = false,
  }) async {
    if (method != 'restore' && productId.trim().isEmpty) {
      return const BillingResult.failure('شناسه محصول نامعتبر است');
    }
    final vendor = await StoreDetector.detect();
    if (!vendor.supportsBilling) {
      return const BillingResult.failure(
        'خرید و فعال‌سازی فقط در نسخهٔ رسمی انتشار مایکت امکان‌پذیر است',
        status: BillingStatus.untrustedBuild,
      );
    }
    try {
      final arguments = method == 'restore'
          ? null
          : <String, Object?>{
              'productId': productId,
              'consumable': consumable,
            };
      var invocation = _channel.invokeMethod<Object?>(method, arguments);
      // بازیابی یک کوئری خالص است و نباید هرگز بی‌پایان منتظر بماند؛
      // اگر SDK فروشگاه callback ندهد، کاربر باید پیام بگیرد نه سکوت.
      // (خرید timeout ندارد چون کاربر ممکن است دقیقه‌ها در صفحهٔ پرداخت
      // فروشگاه بماند.)
      if (method == 'restore') {
        invocation = invocation.timeout(const Duration(seconds: 25));
      }
      final dynamic raw = await invocation;
      return _parse(
        raw,
        expectedProductId: productId,
        expectedStore: vendor.name,
      );
    } on TimeoutException {
      return const BillingResult.failure(
        'پاسخ فروشگاه به‌موقع نرسید؛ اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.',
      );
    } on MissingPluginException {
      return const BillingResult.failure('سرویس پرداخت استور در دسترس نیست');
    } on PlatformException catch (e) {
      // استور خطا داده (انصراف کاربر، قطع اینترنت، موجودی ناکافی و...)
      return BillingResult.failure(e.message ?? 'پرداخت انجام نشد');
    } catch (_) {
      return const BillingResult.failure('خطای ناشناخته در پرداخت');
    }
  }

  /// باز کردن صفحهٔ ثبت نظر و امتیاز در **همان فروشگاهی که اپ از آن نصب
  /// شده** است. لایهٔ نیتیو خودش intent مناسب را می‌سازد؛ اگر فروشگاه
  /// ناشناخته باشد کاری انجام نمی‌شود.
  static Future<bool> openStoreReview() async {
    try {
      final result = await _channel.invokeMethod<bool>('openStoreReview');
      return result == true;
    } catch (_) {
      // نادیده گرفتن خطا در محیط‌های فاقد فروشگاه
      return false;
    }
  }

  /// باز کردن صفحهٔ اطلاعات برنامه در همان فروشگاه (اینتنت رسمی
  /// `myket://details?id=` / `bazaar://details?id=`). برای بخش درباره و
  /// پشتیبانی؛ وب‌سایت ناشر هرگز باز نمی‌شود.
  static Future<bool> openStoreDetails() async {
    try {
      final result = await _channel.invokeMethod<bool>('openStoreDetails');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  /// نام قدیمی؛ برای سازگاری با کدهای قبلی نگه داشته شده است.
  @Deprecated('Use openStoreReview')
  static Future<void> openBazaarReview() => openStoreReview();

  /// فروشگاهی که اپ از آن نصب شده است (برای تصمیم‌های UI مثل
  /// نمایش/پنهان‌کردن دکمهٔ امتیازدهی).
  static Future<StoreVendor> currentVendor() => StoreDetector.detect();

  static BillingResult _parse(
    dynamic raw, {
    bool requireReceipt = true,
    String? expectedProductId,
    String? expectedStore,
  }) {
    if (raw is! Map) {
      return const BillingResult.failure('پاسخ نامعتبر از سرویس پرداخت');
    }
    final message = raw['message'] is String ? raw['message'] as String : '';
    final status = switch (raw['status']) {
      'verified' => BillingStatus.verified,
      'not_owned' => BillingStatus.notOwned,
      'invalid_receipt' => BillingStatus.invalidReceipt,
      'completed' => BillingStatus.completed,
      'untrusted_build' => BillingStatus.untrustedBuild,
      _ => BillingStatus.unavailable,
    };
    if (raw['success'] != true) {
      return BillingResult.failure(
        message.isEmpty ? 'پرداخت انجام نشد' : message,
        status: status,
      );
    }
    final result = BillingResult(
      success: true,
      purchaseToken: raw['purchaseToken'] is String
          ? raw['purchaseToken'] as String : null,
      orderId: raw['orderId'] is String ? raw['orderId'] as String : null,
      message: message,
      status: status,
      productId: raw['productId'] is String ? raw['productId'] as String : null,
      store: raw['store'] is String ? raw['store'] as String : null,
      purchaseState: raw['purchaseState'] is int
          ? raw['purchaseState'] as int : null,
      signedData: raw['signedData'] is String ? raw['signedData'] as String : null,
      signature: raw['signature'] is String ? raw['signature'] as String : null,
      releaseVerified: raw['releaseVerified'] == true,
    );
    if (requireReceipt &&
        (!result.hasStoreReceipt ||
            (expectedProductId != null && result.productId != expectedProductId) ||
            (expectedStore != null && result.store != expectedStore))) {
      return const BillingResult.failure(
        'رسید امضاشدهٔ معتبر از فروشگاه دریافت نشد',
        status: BillingStatus.invalidReceipt,
      );
    }
    return result;
  }
}
