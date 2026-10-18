import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🏪 فروشگاهی که اپ از آن نصب شده است.
///
/// اپ برای هر فروشگاه یک بیلد جدا دارد و هر بیلد فقط سرویس پرداخت
/// درون‌برنامه‌ای همان فروشگاه را در خود دارد. کاربر چیزی انتخاب نمی‌کند؛
/// خودِ اپ از روی flavor ساخت (`STORE_CHANNEL`) درگاه را انتخاب می‌کند.
/// تنها استثنا صفحهٔ «درباره و پشتیبانی» است که طبق قانون هر دو فروشگاه
/// باید نام و لینک همان فروشگاه را نشان بدهد، نه وب‌سایت ناشر.
enum StoreVendor {
  /// کافه‌بازار (`com.farsitel.bazaar`) → پرداخت با Poolakey.
  bazaar,

  /// مایکت (`ir.mservices.market`) → پرداخت با Myket Billing Client.
  myket,

  /// نصب مستقیم APK، ADB، یا فروشگاهی که پشتیبانی نمی‌شود.
  /// در این حالت درگاه پرداختی وجود ندارد و خرید باید محترمانه رد شود.
  unknown;

  /// هر بیلد فقط با درگاه فروشگاه خودش پرداخت می‌کند: flavor «bazaar» با
  /// Poolakey و flavor «myket» با Myket Billing. نصب مستقیم/ناشناخته هیچ
  /// درگاهی ندارد.
  bool get supportsBilling => this != StoreVendor.unknown;

  /// شناسهٔ فنی فروشگاه؛ همان رشته‌ای که رسید امضاشده و لایهٔ نیتیو
  /// (`BuildConfig.STORE_CHANNEL`) استفاده می‌کنند. برای `unknown` خالی است.
  String get slug => switch (this) {
        StoreVendor.bazaar => 'bazaar',
        StoreVendor.myket => 'myket',
        StoreVendor.unknown => '',
      };

  /// آیا این رشته یکی از فروشگاه‌های رسمیِ پشتیبانی‌شده است؟
  ///
  /// مقایسه عمداً دقیق و case-sensitive است تا مقدار ساختگی مثل `BAZAAR`
  /// هرگز با رسید فروشگاه اشتباه گرفته نشود.
  static bool isSupportedStoreSlug(String? slug) =>
      slug == StoreVendor.bazaar.slug || slug == StoreVendor.myket.slug;
}

/// تشخیص فروشگاه نصب‌کننده و انتخاب خودکار درگاه پرداخت.
///
/// در release **مرجع نهایی لایهٔ نیتیو است** (متد `storeVendor`): دقیقاً همان
/// درگاهی که فراخوانی‌های purchase/restore با آن اجرا می‌شوند. منطق نیتیو
/// (`StoreVendor.resolve`) اول بستهٔ نصب‌کننده را از
/// `PackageManager.getInstallSourceInfo()` می‌پرسد و اگر ناشناخته بود (نصب
/// مستقیم APK) ولی فقط **یکی** از دو فروشگاه روی دستگاه نصب باشد، همان را
/// انتخاب می‌کند. این لایهٔ Dart باید همان تصمیم را بگیرد تا کاربرِ نصب
/// دستی هم بتواند خرید/بازیابی کند؛ اگر نیتیو در دسترس نبود به
/// `installerPackage` برمی‌گردیم. نتیجه یک‌بار کش می‌شود چون در طول اجرای
/// اپ تغییر نمی‌کند.
///
/// ⚠️ نکتهٔ امنیتی: بستهٔ نصب‌کننده را نمی‌توان جعل کرد (سیستم‌عامل آن را
/// ثبت می‌کند)، ولی این مقدار فقط برای **مسیریابی** استفاده می‌شود، نه
/// اعطای دسترسی. اعتبارسنجی واقعی خرید همچنان با رسید امضاشدهٔ خود
/// فروشگاه انجام می‌شود (`Monetization`).
class StoreDetector {
  StoreDetector._();

  static const MethodChannel _channel = MethodChannel('kudake_iran/billing');

  /// بستهٔ رسمی هر فروشگاه.
  static const String bazaarPackage = 'com.farsitel.bazaar';
  static const String myketPackage = 'ir.mservices.market';

  static StoreVendor? _cached;

  /// آخرین مقدار تشخیص‌داده‌شده (بدون فراخوانی مجدد نیتیو).
  static StoreVendor? get cached => _cached;

  /// مقدار همگام برای متن‌های UI. اگر هنوز تشخیص انجام نشده باشد،
  /// `unknown` برمی‌گردد و متن‌ها به واژهٔ عمومی «فروشگاه» می‌روند؛ هیچ‌وقت
  /// نام فروشگاه رقیب به کاربر نشان داده نمی‌شود.
  static StoreVendor get lastKnown => _cached ?? StoreVendor.unknown;

  /// فروشگاهی که اپ باید با درگاه آن کار کند.
  ///
  /// در همهٔ حالت‌های ساخت، درگاه واقعی از لایهٔ نیتیو خوانده می‌شود.
  static Future<StoreVendor> detect() async {
    if (_cached != null) return _cached!;
    // ۱) نظر لایهٔ نیتیو — همان resolve() با fallback «تنها فروشگاه
    //    نصب‌شده» برای نصب‌های دستی. با timeout تا هیچ‌وقت فلوی خرید
    //    منتظر نماند.
    try {
      final name = (await _channel
                  .invokeMethod<String>('storeVendor')
                  .timeout(const Duration(seconds: 4)) ??
              '')
          .trim()
          .toLowerCase();
      final mapped = fromNativeVendorName(name);
      if (mapped != null) {
        _cached = mapped;
        return _cached!;
      }
    } catch (_) {
      // نیتیو جواب نداد؛ fallback پایین.
    }
    // ۲) fallback: فقط بستهٔ نصب‌کننده.
    String installer = '';
    try {
      installer = (await _channel
                  .invokeMethod<String>('installerPackage')
                  .timeout(const Duration(seconds: 4)) ??
              '')
          .trim()
          .toLowerCase();
    } catch (_) {
      installer = '';
    }
    _cached = fromInstallerPackage(installer);
    return _cached!;
  }

  /// نگاشت نامِ برگشته از نیتیو (`bazaar`/`myket`/`unknown`) به enum.
  /// مقدار ناشناخته `null` برمی‌گرداند تا caller به fallback برود.
  @visibleForTesting
  static StoreVendor? fromNativeVendorName(String? name) {
    switch ((name ?? '').trim().toLowerCase()) {
      case 'bazaar':
        return StoreVendor.bazaar;
      case 'myket':
        return StoreVendor.myket;
      case 'unknown':
        return StoreVendor.unknown;
    }
    return null;
  }

  /// نگاشت خالصِ «بستهٔ نصب‌کننده → فروشگاه». جدا نگه داشته شده تا بدون
  /// نیاز به دستگاه اندروید تست شود.
  static StoreVendor fromInstallerPackage(String? installerPackage) {
    final id = (installerPackage ?? '').trim().toLowerCase();
    if (id.isEmpty) return StoreVendor.unknown;
    if (id == bazaarPackage) return StoreVendor.bazaar;
    if (id == myketPackage) return StoreVendor.myket;
    return StoreVendor.unknown;
  }

  /// فقط برای تست.
  @visibleForTesting
  static void debugOverride(StoreVendor? vendor) => _cached = vendor;
}
