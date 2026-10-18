import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
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

  group('native vendor name mapping', () {
    // در release لایهٔ Dart تصمیمِ نیتیو (storeVendor) را می‌پرسد تا نصب‌های
    // دستی هم — وقتی فقط یک فروشگاه روی دستگاه نصب است — بتوانند خرید کنند.
    test('maps the names the native bridge returns', () {
      expect(StoreDetector.fromNativeVendorName('bazaar'), StoreVendor.bazaar);
      expect(StoreDetector.fromNativeVendorName('MYKET'), StoreVendor.myket);
      expect(
        StoreDetector.fromNativeVendorName(' unknown '),
        StoreVendor.unknown,
      );
    });

    test('returns null for unexpected values so the caller can fall back', () {
      expect(StoreDetector.fromNativeVendorName(''), isNull);
      expect(StoreDetector.fromNativeVendorName(null), isNull);
      expect(StoreDetector.fromNativeVendorName('google'), isNull);
    });
  });

  group('actual native bridge detection in every build mode', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('kudake_iran/billing');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    setUp(() => StoreDetector.debugOverride(null));
    tearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
      StoreDetector.debugOverride(null);
    });

    test('debug also reads the native vendor and caches the real decision', () async {
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls++;
        expect(call.method, 'storeVendor');
        return 'myket';
      });
      expect(await StoreDetector.detect(), StoreVendor.myket);
      expect(await StoreDetector.detect(), StoreVendor.myket);
      expect(calls, 1);
    });

    test('native unknown is never automatically replaced with Bazaar', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'storeVendor');
        return 'unknown';
      });
      expect(await StoreDetector.detect(), StoreVendor.unknown);
    });

    test('unrecognized native response uses the actual installer fallback', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        return call.method == 'installerPackage' ? StoreDetector.myketPackage : null;
      });
      expect(await StoreDetector.detect(), StoreVendor.myket);
    });

    test('missing native plugin stays unknown, including debug', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw MissingPluginException();
      });
      expect(await StoreDetector.detect(), StoreVendor.unknown);
    });
  });

  group('billing availability', () {
    test('each store-isolated build can take its own payment', () {
      // هر flavor فقط با درگاه فروشگاه خودش ساخته می‌شود؛ هر دو فروشگاه
      // رسمی مجازند، ولی نصب مستقیم/ناشناخته هیچ درگاهی ندارد.
      expect(StoreVendor.bazaar.supportsBilling, isTrue);
      expect(StoreVendor.myket.supportsBilling, isTrue);
      expect(StoreVendor.unknown.supportsBilling, isFalse);
    });

    test('store slugs match the native channel and receipt values', () {
      expect(StoreVendor.bazaar.slug, 'bazaar');
      expect(StoreVendor.myket.slug, 'myket');
      expect(StoreVendor.unknown.slug, '');
      expect(StoreVendor.isSupportedStoreSlug('bazaar'), isTrue);
      expect(StoreVendor.isSupportedStoreSlug('myket'), isTrue);
      for (final invalid in <String?>[null, '', 'BAZAAR', 'Myket', 'google']) {
        expect(StoreVendor.isSupportedStoreSlug(invalid), isFalse,
            reason: '$invalid');
      }
    });

    test('the package constants match the official store ids', () {
      expect(StoreDetector.bazaarPackage, 'com.farsitel.bazaar');
      expect(StoreDetector.myketPackage, 'ir.mservices.market');
    });
  });
}
