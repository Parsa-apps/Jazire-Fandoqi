import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🏪 فروشگاهی که اپ از آن نصب شده است.
///
/// اپ روی چند فروشگاه ایرانی منتشر می‌شود و هر کدام سرویس پرداخت
/// درون‌برنامه‌ای خودش را دارد. کاربر نباید نام فروشگاه را جایی ببیند یا
/// انتخاب کند؛ خودِ اپ هنگام اجرا تشخیص می‌دهد از کجا نصب شده و همان
/// درگاه را صدا می‌زند.
///
/// از نسخهٔ 6.2.1+2 هر بیلد release مخصوص یک فروشگاه ساخته می‌شود
/// (flavor بیلد: `bazaar` / `myket`) — بیلد مایکت کتابخانهٔ پرداخت بازار
/// را ندارد تا permission اختصاصی آن در APK نباشد. در بیلد release، flavor
/// ملاک قطعی تشخیص است؛ تشخیص نصب‌کننده فقط برای بیلدهای بدون flavor
/// (راستی‌آزمایی) باقی مانده است.
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

/// تشخیص فروشگاه نصب‌کننده و انتخاب خودکار درگاه پرداخت.
///
/// در بیلد release منبع حقیقت، flavor بیلد است که لایهٔ نیتیو از طریق
/// `storeFlavor` گزارش می‌دهد (هر APK فقط برای همان فروشگاه ساخته و امضا
/// می‌شود). در بیلدهای بدون flavor، منبع حقیقت
/// `PackageManager.getInstallSourceInfo()` در سمت اندروید است (روی اندروید
/// ۱۱+، و `getInstallerPackageName()` روی نسخه‌های قدیمی‌تر).
/// نتیجه یک‌بار کش می‌شود چون در طول اجرای اپ تغییر نمی‌کند.
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

  /// فروشگاهی که اپ از آن نصب شده است.
  ///
  /// در حالت debug عمداً کافه‌بازار برگردانده می‌شود تا فلوی خرید در
  /// سندباکس قابل تست بماند (نصب از Android Studio installer ندارد).
  static Future<StoreVendor> detect() async {
    if (_cached != null) return _cached!;
    if (!kReleaseMode) {
      _cached = StoreVendor.bazaar;
      return _cached!;
    }
    // 🏪 بیلد release مخصوص یک فروشگاه ساخته می‌شود (flavor). اگر flavor
    // معلوم باشد همان فروشگاه قطعی است و نیازی به تشخیص نصب‌کننده نیست —
    // این کار تضمین می‌کند بیلد مایکت (که Poolakey را ندارد) هرگز به
    // درگاه بازار مسیردهی نشود.
    final flavorVendor = fromFlavor(await _nativeFlavor());
    if (flavorVendor != null) {
      _cached = flavorVendor;
      return _cached!;
    }
    // بیلد بدون flavor (مثل خروجی راستی‌آزمایی CI): مثل قبل از نصب‌کننده.
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

  /// نگاشت خالصِ «flavor بیلد → فروشگاه». بیلدهای release با دو flavor جدا
  /// ساخته می‌شوند تا APK مایکت حاوی permission اختصاصی پرداخت کافه‌بازار
  /// نباشد (مایکت چنین APKهایی را رد می‌کند). مقدار null یعنی بیلد بدون
  /// flavor و باید مثل قبل از نصب‌کننده تشخیص داد.
  static StoreVendor? fromFlavor(String? flavor) {
    final id = (flavor ?? '').trim().toLowerCase();
    if (id == 'bazaar') return StoreVendor.bazaar;
    if (id == 'myket') return StoreVendor.myket;
    return null;
  }

  /// flavor بیلد از سمت نیتیو؛ خالی یعنی بیلد بدون flavor (یا کانال در
  /// دسترس نبود). هر خطایی نادیده گرفته می‌شود چون تشخیص نصب‌کننده
  /// fallback قابل قبولی است.
  static Future<String> _nativeFlavor() async {
    try {
      final value = await _channel
          .invokeMethod<String>('storeFlavor')
          .timeout(const Duration(seconds: 4));
      return (value ?? '').trim().toLowerCase();
    } catch (_) {
      return '';
    }
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
