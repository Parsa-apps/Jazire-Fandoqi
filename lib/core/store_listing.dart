import 'store_vendor.dart';

/// لینک و نام صفحهٔ برنامه در همان فروشگاهی که این بیلد برایش ساخته شده.
///
/// مایکت برای برنامه‌های «درون‌پرداخت» اجازهٔ ارجاع کاربر به وب‌سایت ناشر
/// را نمی‌دهد و صراحتاً می‌خواهد نام و لینک مایکت در بخش «درباره و
/// پشتیبانی» باشد. اینتنت رسمی:
/// `myket://details?id=[PACKAGE_NAME]`
/// ([مستند مایکت](https://myket.ir/kb/pages/open-application-page-in-myket/)).
///
/// کافه‌بازار هم صفحهٔ برنامه را با `bazaar://details?id=` باز می‌کند تا
/// بیلد بازار به سایت ناشر نرود.
class StoreListing {
  StoreListing._();

  static const String packageName = 'com.parsaapps.amoozesh_fandoghi';

  static const String myketName = 'مایکت';
  static const String bazaarName = 'کافه‌بازار';

  static const String kicker = 'صفحهٔ رسمی برنامه در فروشگاه';

  /// فروشگاهی که این بیلد برایش ساخته شده (از کانال ساخت).
  static StoreVendor get buildVendor => StoreDetector.buildVendor;

  /// آیا این فروشگاه همان فروشگاهِ خودِ این بیلد است؟
  ///
  /// در بیلدهای فروشگاه فقط فروشگاهِ خودمان مجاز است؛ لینک یا دکمهٔ فروشگاه
  /// رقیب هرگز نباید در رابط کاربری دیده شود. برای بیلدهای محلی (بدون کانال
  /// ساخت) محدودیتی اعمال نمی‌شود.
  static bool isOwnStore(StoreVendor vendor) {
    final own = buildVendor;
    if (own == StoreVendor.unknown) return true;
    return vendor == own;
  }

  static bool hasStorePage(StoreVendor vendor) =>
      vendor.supportsBilling && isOwnStore(vendor);

  static String displayName(StoreVendor vendor) {
    switch (vendor) {
      case StoreVendor.myket:
        return myketName;
      case StoreVendor.bazaar:
        return bazaarName;
      case StoreVendor.unknown:
        return '';
    }
  }

  static String buttonLabel(StoreVendor vendor) {
    switch (vendor) {
      case StoreVendor.myket:
        return 'ورود به صفحه برنامه در مایکت';
      case StoreVendor.bazaar:
        return 'ورود به صفحه برنامه در کافه‌بازار';
      case StoreVendor.unknown:
        return '';
    }
  }

  /// اینتنت باز کردن صفحهٔ اطلاعات برنامه داخل اپ فروشگاه.
  static String detailsDeepLink(StoreVendor vendor) {
    switch (vendor) {
      case StoreVendor.myket:
        return 'myket://details?id=$packageName';
      case StoreVendor.bazaar:
        return 'bazaar://details?id=$packageName';
      case StoreVendor.unknown:
        return '';
    }
  }

  /// صفحهٔ وبِ خودِ فروشگاه (نه سایت ناشر) برای وقتی اپ فروشگاه نصب نیست.
  static String detailsWebUrl(StoreVendor vendor) {
    switch (vendor) {
      case StoreVendor.myket:
        return 'https://myket.ir/app/$packageName';
      case StoreVendor.bazaar:
        return 'https://cafebazaar.ir/app/$packageName';
      case StoreVendor.unknown:
        return '';
    }
  }
}
