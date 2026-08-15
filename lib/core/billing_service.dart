import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'store_vendor.dart';

/// نتیجه یک عملیات پرداخت
///
/// [success] فقط زمانی true است که فروشگاه خرید را تایید کرده باشد.
/// تا وقتی [success] true نشده، نباید هیچ دسترسی ویژه‌ای در اپ فعال شود.
class BillingResult {
  final bool success;
  final String? purchaseToken;
  final String? orderId;
  final String message;

  const BillingResult({
    required this.success,
    this.purchaseToken,
    this.orderId,
    this.message = '',
  });

  const BillingResult.failure(this.message)
      : success = false,
        purchaseToken = null,
        orderId = null;

  const BillingResult.sandbox()
      : success = true,
        purchaseToken = null,
        orderId = null,
        message = 'خرید آزمایشی (حالت سندباکس)';
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
/// در حالت توسعه (یا وقتی ماژول نیتیو نصب نیست) اگر [sandboxFallback]
/// فعال باشد، خریدها به‌صورت آزمایشی موفق در نظر گرفته می‌شوند تا کل
/// فلوی خرید قابل تست باشد. قبل از انتشار نسخه نهایی باید:
///   1. ماژول نیتیو متصل شود
///   2. بیلد release واقعی ساخته شود؛ fallback در release به‌صورت compile-time خاموش است
class BillingService {
  BillingService._();

  static const MethodChannel _channel = MethodChannel('kudake_iran/billing');

  /// سندباکس فقط در debug فعال است و از کد release قابل روشن‌کردن نیست.
  static bool get sandboxFallback => !kReleaseMode;

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
    if (kReleaseMode &&
        result.success &&
        (result.purchaseToken == null || result.purchaseToken!.isEmpty)) {
      return const BillingResult.failure('توکن خرید مصرف‌شدنی دریافت نشد');
    }
    return result;
  }

  /// بازیابی خریدهای قبلی کاربر
  static Future<BillingResult> restorePurchases() {
    return _invoke('restore', '');
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
      if (sandboxFallback) return const BillingResult.sandbox();
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
    if (method != 'restore' && productId.trim().isEmpty) {
      return const BillingResult.failure('شناسه محصول نامعتبر است');
    }
    // اگر اپ از فروشگاه پشتیبانی‌شده نصب نشده باشد (نصب مستقیم APK)،
    // هیچ درگاه پرداختی وجود ندارد. به‌جای خطای مبهم استور، پیام روشن
    // می‌دهیم. در debug این بررسی رد می‌شود تا سندباکس کار کند.
    if (kReleaseMode && !(await StoreDetector.detect()).supportsBilling) {
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
      final dynamic raw = await _channel.invokeMethod<Object?>(method, arguments);
      return _parse(raw);
    } on MissingPluginException {
      // ماژول نیتیو استور نصب نیست؛ در حالت توسعه خرید آزمایشی موفق است
      if (sandboxFallback) return const BillingResult.sandbox();
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

  /// نام قدیمی؛ برای سازگاری با کدهای قبلی نگه داشته شده است.
  @Deprecated('Use openStoreReview')
  static Future<void> openBazaarReview() => openStoreReview();

  /// فروشگاهی که اپ از آن نصب شده است (برای تصمیم‌های UI مثل
  /// نمایش/پنهان‌کردن دکمهٔ امتیازدهی).
  static Future<StoreVendor> currentVendor() => StoreDetector.detect();

  static BillingResult _parse(dynamic raw, {bool requireReceipt = true}) {
    if (raw is Map) {
      final success = raw['success'] == true;
      final message = raw['message']?.toString() ?? '';
      if (success) {
        final token = raw['purchaseToken']?.toString();
        final orderId = raw['orderId']?.toString();
        // A release purchase is not trusted without a store receipt/token.
        // Debug sandbox responses are the only permitted exception.
        if (kReleaseMode &&
            requireReceipt &&
            (token == null || token.isEmpty) &&
            (orderId == null || orderId.isEmpty)) {
          return const BillingResult.failure('رسید خرید از استور دریافت نشد');
        }
        return BillingResult(
          success: true,
          purchaseToken: token,
          orderId: orderId,
          message: message,
        );
      }
      return BillingResult.failure(
        message.isEmpty ? 'پرداخت انجام نشد' : message,
      );
    }
    if (sandboxFallback) return const BillingResult.sandbox();
    return const BillingResult.failure('پاسخ نامعتبر از سرویس پرداخت');
  }
}
