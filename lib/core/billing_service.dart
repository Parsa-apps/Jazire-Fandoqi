import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// نتیجه یک عملیات پرداخت
///
/// [success] فقط زمانی true است که استور (کافه‌بازار/مایکت) خرید را
/// تایید کرده باشد. تا وقتی [success] true نشده، نباید هیچ دسترسی
/// ویژه‌ای در اپ فعال شود.
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

/// پل ارتباطی با سیستم پرداخت درون‌برنامه‌ای کافه‌بازار و مایکت
///
/// ارتباط از طریق MethodChannel با نام `kudake_iran/billing` انجام می‌شود.
/// ماژول نیتیو اندروید باید سه متود را پیاده‌سازی کند:
///
/// 1. `purchase`: ورودی `{productId: String, consumable: bool}`
///    خروجی: `{success: bool, purchaseToken: String?, orderId: String?, message: String?}`
/// 2. `consume`: ورودی `{purchaseToken: String}` برای مصرف‌کردنی‌ها
/// 3. `restore`: بدون ورودی؛ لیست خریدهای معتبر کاربر را برمی‌گرداند
///
/// در حالت توسعه (یا وقتی ماژول نیتیو نصب نیست) اگر [sandboxFallback]
/// فعال باشد، خریدها به‌صورت آزمایشی موفق در نظر گرفته می‌شوند تا کل
/// فلوی خرید قابل تست باشد. قبل از انتشار نسخه نهایی باید:
///   1. ماژول نیتیو متصل شود
///   2. `BillingService.sandboxFallback = false` تنظیم شود
///      (در بیلد release به‌صورت خودکار false است)
class BillingService {
  BillingService._();

  static const MethodChannel _channel = MethodChannel('kudake_iran/billing');

  /// حالت سندباکس: در بیلدهای debug خودکار روشن است و در release خاموش.
  /// برای تست نهایی قبل از انتشار می‌توان آن را دستی false کرد.
  static bool sandboxFallback = !kReleaseMode;

  /// خرید اشتراک (غیرمصرف‌شدنی) مثل کودک‌دانا پلاس
  static Future<BillingResult> purchaseSubscription(String productId) {
    return _invoke('purchase', productId, consumable: false);
  }

  /// خرید آیتم مصرف‌شدنی مثل بسته سکه یا ستاره
  static Future<BillingResult> purchaseConsumable(String productId) {
    return _invoke('purchase', productId, consumable: true);
  }

  /// بازیابی خریدهای قبلی کاربر
  static Future<BillingResult> restorePurchases() {
    return _invoke('restore', '');
  }

  static Future<BillingResult> _invoke(
    String method,
    String productId, {
    bool consumable = false,
  }) async {
    try {
      final dynamic raw = await _channel.invokeMethod<Object?>(method, <String, Object?>{
        'productId': productId,
        'consumable': consumable,
      });
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

  static BillingResult _parse(dynamic raw) {
    if (raw is Map) {
      final success = raw['success'] == true;
      final message = raw['message']?.toString() ?? '';
      if (success) {
        return BillingResult(
          success: true,
          purchaseToken: raw['purchaseToken']?.toString(),
          orderId: raw['orderId']?.toString(),
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
