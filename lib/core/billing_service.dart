import 'dart:async';

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

  /// The native store SDK has already verified the receipt's signature.
  /// Empty receipts and tokens from older automatic sandbox builds are never
  /// proof of payment, in any build mode.
  bool get hasStoreReceipt =>
      purchaseToken != null &&
      purchaseToken!.trim().isNotEmpty &&
      purchaseToken!.trim() != 'sandbox-token';
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
    debugPrint('[Billing] $method → success=${result.success}'
        '${result.message.isEmpty ? '' : ' | ${result.message}'}');
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
    if (!(await StoreDetector.detect()).supportsBilling) {
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
      return _parse(raw);
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

  static BillingResult _parse(dynamic raw, {bool requireReceipt = true}) {
    if (raw is Map) {
      final success = raw['success'] == true;
      final message = raw['message']?.toString() ?? '';
      if (success) {
        final token = raw['purchaseToken'] is String
            ? raw['purchaseToken'] as String : null;
        final orderId = raw['orderId'] is String
            ? raw['orderId'] as String : null;
        final result = BillingResult(
          success: true,
          purchaseToken: token,
          orderId: orderId,
          message: message,
        );
        if (requireReceipt && !result.hasStoreReceipt) {
          return const BillingResult.failure('رسید خرید از استور دریافت نشد');
        }
        return result;
      }
      return BillingResult.failure(
        message.isEmpty ? 'پرداخت انجام نشد' : message,
      );
    }
    return const BillingResult.failure('پاسخ نامعتبر از سرویس پرداخت');
  }
}
