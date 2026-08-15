import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/store_vendor.dart';

void main() {
  group('store detection from the installer package', () {
    test('maps each supported store to its vendor', () {
      expect(
        StoreDetector.fromInstallerPackage('com.farsitel.bazaar'),
        StoreVendor.bazaar,
      );
      expect(
        StoreDetector.fromInstallerPackage('ir.mservices.market'),
        StoreVendor.myket,
      );
    });

    test('treats a sideloaded or unknown installer as unsupported', () {
      // نصب مستقیم APK / ADB → سیستم‌عامل هیچ نصب‌کننده‌ای ثبت نمی‌کند.
      expect(StoreDetector.fromInstallerPackage(''), StoreVendor.unknown);
      expect(StoreDetector.fromInstallerPackage(null), StoreVendor.unknown);
      expect(StoreDetector.fromInstallerPackage('   '), StoreVendor.unknown);
      // فروشگاه‌هایی که هنوز پشتیبانی نمی‌کنیم نباید به درگاه اشتباه بروند.
      expect(
        StoreDetector.fromInstallerPackage('com.android.vending'),
        StoreVendor.unknown,
      );
      expect(
        StoreDetector.fromInstallerPackage('com.example.unknownstore'),
        StoreVendor.unknown,
      );
    });

    test('is tolerant of casing and stray whitespace', () {
      expect(
        StoreDetector.fromInstallerPackage('  COM.FARSITEL.BAZAAR  '),
        StoreVendor.bazaar,
      );
      expect(
        StoreDetector.fromInstallerPackage('Ir.MServices.Market'),
        StoreVendor.myket,
      );
    });

    test('never confuses one store package with the other', () {
      // یک نام مشابه نباید درگاه اشتباه را باز کند.
      expect(
        StoreDetector.fromInstallerPackage('com.farsitel.bazaar.beta'),
        StoreVendor.unknown,
      );
      expect(
        StoreDetector.fromInstallerPackage('ir.mservices.market2'),
        StoreVendor.unknown,
      );
    });
  });

  group('billing availability', () {
    test('only known stores can take a payment', () {
      expect(StoreVendor.bazaar.supportsBilling, isTrue);
      expect(StoreVendor.myket.supportsBilling, isTrue);
      // بدون فروشگاه، خرید باید محترمانه رد شود نه اینکه خطای مبهم بدهد.
      expect(StoreVendor.unknown.supportsBilling, isFalse);
    });

    test('the package constants match the official store ids', () {
      expect(StoreDetector.bazaarPackage, 'com.farsitel.bazaar');
      expect(StoreDetector.myketPackage, 'ir.mservices.market');
    });
  });
}
