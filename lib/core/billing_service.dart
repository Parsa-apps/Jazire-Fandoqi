import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'store_vendor.dart';

/// Distinguish a confirmed empty inventory from a temporarily unavailable store.
enum BillingStatus { verified, notOwned, unavailable, invalidReceipt, completed }

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
        signature = null;

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

  bool get hasStoreReceipt =>
      success &&
      status == BillingStatus.verified &&
      purchaseState == 0 &&
      (store == 'myket' || store == 'bazaar') &&
      (productId?.trim().isNotEmpty ?? false) &&
      (signedData?.trim().isNotEmpty ?? false) &&
      (signature?.trim().isNotEmpty ?? false) &&
      (purchaseToken?.trim().isNotEmpty ?? false) &&
      purchaseToken!.trim() != 'sandbox-token';

  bool hasReceiptFor(String expectedProductId) =>
      hasStoreReceipt && productId == expectedProductId;
}

/// پل ارتباطی با سیستم پرداخت درون‌برنامه‌ای فروشگاه‌های ایرانی
///
/// 🏪 چند-فروشگاهی: اپ هنگام اجرا تشخیص می‌دهد از کدام فروشگاه نصب شده
/// (`StoreDetector`) و لایهٔ نیتیو همان درگاه را صدا می‌زند — کافه‌بازار
/// با Poolakey و مایکت با Myket Billing Client. کاربر هیچ‌وقت نام
/// فروشگاه را نمی‌بیند و چیزی انتخاب نمی‌کند.
///
/// ارتباط از طریق MethodChannel با نام `kudake_iran/billing` انجام می‌شود.
/// ماژول نیتیو اندروید باید این متودها را پیاده‌سازی کند:
///
/// 1. `purchase`: ورودی `{productId: String, consumable: bool}`
///    خروجی: `{success: bool, purchaseToken: String?, orderId: String?, message: String?}`
/// 2. `consume`: ورودی `{purchaseToken: String}` برای مصرف‌کردنی‌ها
/// 3. `restore`: بدون ورودی؛ نتیجه‌ی یک اشتراک معتبر فعلی را با همان قالب
///    `purchase` برمی‌گرداند (یا `success: false` اگر خریدی نیست)
///
/// Missing plugins, malformed responses and unavailable stores always fail
/// closed, including debug/profile builds. Tests use explicit channel mocks;
/// there is no automatic successful purchase or restore in a shipped APK.
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
    // اگر اپ از فروشگاه پشتیبانی‌شده نصب نشده باشد (نصب مستقیم APK)،
    // هیچ درگاه پرداختی وجود ندارد. به‌جای خطای مبهم استور، پیام روشن
    // می‌دهیم. حالت ساخت هیچ‌وقت مجوز پرداخت محسوب نمی‌شود.
    final vendor = await StoreDetector.detect();
    if (!vendor.supportsBilling) {
      return const BillingResult.failure(
        'این نسخه از فروشگاه رسمی نصب نشده است؛ برای خرید، برنامه را از '
        'فروشگاهی که آن را دریافت کرده‌اید نصب کنید.',
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
