import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🏪 فروشگاهی که اپ برای آن ساخته شده است.
///
/// اپ روی دو فروشگاه ایرانی منتشر می‌شود و هر کدام سرویس پرداخت
/// درون‌برنامه‌ای **مستقلِ** خودش را دارد. در خرید و بازی‌ها نام فروشگاه
/// نشان داده نمی‌شود و کاربر چیزی انتخاب نمی‌کند؛ خودِ اپ از روی کانال ساخت
/// (`STORE_CHANNEL` / `BuildConfig.STORE_CHANNEL`) درگاه را انتخاب می‌کند.
/// تنها استثنا صفحهٔ «درباره و پشتیبانی» است که به‌خاطر قانون درون‌پرداخت
/// مایکت باید نام و لینک همان فروشگاه را نشان بدهد، نه وب‌سایت ناشر.
///
/// 🔒 جداسازی در زمان build: هر آرتیفکت فقط SDK فروشگاه خودش را دارد؛
/// بنابراین «انتخاب درگاه» یک تصمیمِ زمان‌ساخت است، نه زمان‌اجرا.
enum StoreVendor {
  /// کافه‌بازار (`com.farsitel.bazaar`) → پرداخت با Poolakey.
  bazaar,

  /// مایکت (`ir.mservices.market`) → پرداخت با Myket Billing Client.
  myket,

  /// نصب مستقیم APK، ADB، یا فروشگاهی که پشتیبانی نمی‌شود.
  /// در این حالت درگاه پرداختی وجود ندارد و خرید باید محترمانه رد شود.
  unknown;

  /// آیا برای این حالت درگاه پرداخت فعالی داریم؟
  bool get supportsBilling => this != StoreVendor.unknown;
}

/// تشخیص فروشگاهِ همین بیلد و انتخاب خودکار درگاه پرداخت.
///
/// منبعِ قطعی، **کانال ساخت** است:
///
///  1. `STORE_CHANNEL` که با `--dart-define=STORE_CHANNEL=bazaar|myket` به
///     لایهٔ Dart داده می‌شود و با `BuildConfig.STORE_CHANNEL` در اندروید
///     هم‌راستاست.
///  2. اگر dart-define نبود (مثلاً اجرای محلیِ `flutter run`)، از لایهٔ
///     نیتیو پرسیده می‌شود (`storeVendor`) که همان `BuildConfig` را
///     برمی‌گرداند.
///  3. فقط اگر هیچ‌کدام در دسترس نبود (نبود پل نیتیو)، از بستهٔ نصب‌کنندهٔ
///     سیستم‌عامل استفاده می‌شود تا دست‌کم رابط کاربری فروشگاه درست باشد.
///
/// ⚠️ نکتهٔ امنیتی: بستهٔ نصب‌کننده را نمی‌توان جعل کرد (سیستم‌عامل آن را
/// ثبت می‌کند)، ولی این مقدار فقط برای **مسیریابیِ نمایش** استفاده می‌شود،
/// نه اعطای دسترسی. اعتبارسنجی واقعی خرید همچنان با رسید امضاشدهٔ خود
/// فروشگاه انجام می‌شود (`Monetization`).
class StoreDetector {
  StoreDetector._();

  static const MethodChannel _channel = MethodChannel('kudake_iran/billing');

  /// بستهٔ رسمی هر فروشگاه.
  static const String bazaarPackage = 'com.farsitel.bazaar';
  static const String myketPackage = 'ir.mservices.market';

  /// کانال ساخت این بیلد.
  ///
  /// با `--dart-define=STORE_CHANNEL=bazaar|myket` مقدار می‌گیرد. خالی یعنی
  /// بیلد محلی که فروشگاهی برایش تعیین نشده (در آن حالت از لایهٔ نیتیو
  /// پرسیده می‌شود).
  static const String buildChannel =
      String.fromEnvironment('STORE_CHANNEL', defaultValue: '');

  static StoreVendor? _cached;

  /// آخرین مقدار تشخیص‌داده‌شده (بدون فراخوانی مجدد نیتیو).
  static StoreVendor? get cached => _cached;

  /// فروشگاهی که این بیلد برایش ساخته شده (بر اساس کانال ساخت).
  ///
  /// اگر کانال ساخت تنظیم نشده باشد [StoreVendor.unknown] برمی‌گردد.
  static StoreVendor get buildVendor =>
      fromChannelName(buildChannel) ?? StoreVendor.unknown;

  /// فروشگاهی که اپ باید با درگاه آن کار کند.
  ///
  /// ترتیب اولویت: کانال ساخت → لایهٔ نیتیو → بستهٔ نصب‌کننده.
  static Future<StoreVendor> detect() async {
    if (_cached != null) return _cached!;

    // ۱) کانال ساخت: قطعی‌ترین منبع و همان چیزی که نیتیو اجرا می‌کند.
    final fromBuild = fromChannelName(buildChannel);
    if (fromBuild != null) {
      _cached = fromBuild;
      return _cached!;
    }

    // ۲) لایهٔ نیتیو: همان `BuildConfig.STORE_CHANNEL` را می‌دهد.
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

    // ۳) آخرین تلاش: فقط بستهٔ نصب‌کننده.
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

  /// نگاشت کانال ساخت (`bazaar`/`myket`) به enum.
  ///
  /// مقدار ناشناخته `null` برمی‌گرداند تا caller به منبع بعدی برود.
  @visibleForTesting
  static StoreVendor? fromChannelName(String? channel) {
    switch ((channel ?? '').trim().toLowerCase()) {
      case 'bazaar':
        return StoreVendor.bazaar;
      case 'myket':
        return StoreVendor.myket;
    }
    return null;
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
  @visibleForTesting
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
