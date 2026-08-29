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

  static bool hasStorePage(StoreVendor vendor) => vendor.supportsBilling;

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
