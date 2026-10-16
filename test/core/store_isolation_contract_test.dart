import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 🔒 قراردادِ «جداسازی فروشگاه در زمان build».
///
/// این تست، ساختار پروژه را در سطح فایل بررسی می‌کند و تضمین می‌کند که:
///
///  ۱. هر SDK پرداخت فقط در flavor فروشگاه خودش اعلام شده باشد؛
///  ۲. هیچ «بازبسته‌بندی» (repack) یا جایگزینی دستی AAR در کار نباشد؛
///  ۳. هر flavor کلاس `MainActivity` و درگاه پرداخت خودش را داشته باشد و
///     source set مشترک هیچ ارجاعی به SDK فروشگاه نداشته باشد؛
///  ۴. کلید عمومی RSA هر فروشگاه فقط در flavor خودش تعریف شود.
///
/// دلیل: «پنهان‌کردن دکمهٔ پرداخت» کافی نیست؛ اگر SDK رقیب در آرتیفکت
/// بماند، فروشگاه آن را رد می‌کند. این تست جلوی برگشتِ ناخواسته را می‌گیرد.
void main() {
  final gradle = File('android/app/build.gradle').readAsStringSync();

  /// بخش `productFlavors { ... }` به‌همراه بلوک‌های داخلی‌اش.
  String flavorBlock(String name) {
    final start = gradle.indexOf('productFlavors {');
    expect(start, greaterThan(-1), reason: 'productFlavors یافت نشد');
    final section = gradle.substring(start);
    final nameStart = section.indexOf('$name {');
    expect(nameStart, greaterThan(-1), reason: 'flavor $name یافت نشد');
    // تا شروع flavor بعدی یا شروع بخش بعدی gradle.
    final nextName = name == 'bazaar' ? 'myket {' : 'signingConfigs';
    final end = section.indexOf(nextName, nameStart + 1);
    expect(end, greaterThan(-1), reason: 'پایان بلوک $name یافت نشد');
    return section.substring(nameStart, end);
  }

  group('وابستگی‌های Gradle', () {
    test('هر SDK پرداخت فقط به flavor خودش تعلق دارد', () {
      expect(
        gradle,
        contains('bazaarImplementation "com.github.cafebazaar.Poolakey:poolakey'),
        reason: 'Poolakey باید فقط در flavor بازار باشد',
      );
      expect(
        gradle,
        contains('myketImplementation("com.github.myketstore:myket-billing-client'),
        reason: 'Myket Billing Client باید فقط در flavor مایکت باشد',
      );
    });

    test('هیچ SDK پرداختی در بلوک مشترک dependencies نیست', () {
      // `implementation "com.github.cafebazaar...` یعنی SDK در هر دو بیلد.
      expect(
        gradle,
        isNot(contains('implementation "com.github.cafebazaar')),
        reason: 'Poolakey نباید در هر دو آرتیفکت حاضر باشد',
      );
      expect(
        gradle,
        isNot(contains('implementation("com.github.myketstore')),
        reason: 'SDK مایکت نباید در هر دو آرتیفکت حاضر باشد',
      );
    });

    test('تسک repackMyketAar حذف شده است', () {
      // بازبسته‌بندی AAR مایکت وقتی Poolakey هم‌زمان در کلاس‌پات بود لازم بود.
      // حالا که SDKها جدا شده‌اند، بازبسته‌بندی نه‌تنها لازم نیست بلکه
      // خطرناک است: کلاس‌های AIDL را از آرتیفکت مایکت حذف می‌کند.
      expect(
        gradle,
        isNot(contains('tasks.register("repackMyketAar")')),
        reason: 'تسک repackMyketAar باید حذف شود',
      );
      expect(
        gradle,
        isNot(contains('runtimeOnly files(repackMyketAar)')),
        reason: 'AAR بازبسته‌بندی‌شده نباید در runtime باشد',
      );
    });
  });

  group('کلیدهای RSA', () {
    test('کلید هر فروشگاه فقط در flavor خودش تعریف می‌شود', () {
      final bazaar = flavorBlock('bazaar');
      final myket = flavorBlock('myket');

      expect(bazaar, contains('BAZAAR_RSA_PUBLIC_KEY'));
      expect(bazaar, isNot(contains('MYKET_RSA_PUBLIC_KEY')));

      expect(myket, contains('MYKET_RSA_PUBLIC_KEY'));
      expect(myket, isNot(contains('BAZAAR_RSA_PUBLIC_KEY')));
    });

    test('کلیدها در defaultConfig مشترک نیستند', () {
      final defaultConfig = gradle.substring(
        gradle.indexOf('defaultConfig {'),
        gradle.indexOf('flavorDimensions'),
      );
      expect(defaultConfig, isNot(contains('BAZAAR_RSA_PUBLIC_KEY')));
      expect(defaultConfig, isNot(contains('MYKET_RSA_PUBLIC_KEY')));
    });
  });

  group('source set های اندروید', () {
    const kotlinDir = 'android/app/src';
    const pkg = 'com/parsaapps/amoozesh_fandoghi';

    test('هر flavor کلاس MainActivity و درگاه خودش را دارد', () {
      expect(
        File('$kotlinDir/bazaar/kotlin/$pkg/MainActivity.kt').existsSync(),
        isTrue,
        reason: 'MainActivity بازار باید در flavor بازار باشد',
      );
      expect(
        File('$kotlinDir/myket/kotlin/$pkg/MainActivity.kt').existsSync(),
        isTrue,
        reason: 'MainActivity مایکت باید در flavor مایکت باشد',
      );
      expect(
        File('$kotlinDir/bazaar/kotlin/$pkg/BazaarBilling.kt').existsSync(),
        isTrue,
      );
      expect(
        File('$kotlinDir/myket/kotlin/$pkg/MyketBilling.kt').existsSync(),
        isTrue,
      );
    });

    test('source set مشترک MainActivity یا SDK فروشگاه ندارد', () {
      expect(
        File('$kotlinDir/main/kotlin/$pkg/MainActivity.kt').existsSync(),
        isFalse,
        reason: 'MainActivity باید flavor-specific باشد',
      );
      for (final file in Directory('$kotlinDir/main/kotlin/$pkg').listSync()) {
        if (file is! File || !file.path.endsWith('.kt')) continue;
        final source = file.readAsStringSync();
        // فقط importها مهم‌اند؛ متنِ توضیحی داخل کامنت می‌تواند نام بستهٔ
        // SDK را داشته باشد (برای توضیح جداسازی).
        expect(
          source,
          isNot(contains('import ir.cafebazaar.poolakey')),
          reason: '${file.path} نباید SDK بازار را import کند',
        );
        expect(
          source,
          isNot(contains('import ir.myket.billingclient')),
          reason: '${file.path} نباید SDK مایکت را import کند',
        );
      }
    });

    test('کلاس فعالیت هر flavor فقط به فروشگاه خودش اشاره می‌کند', () {
      final bazaar = File('$kotlinDir/bazaar/kotlin/$pkg/MainActivity.kt')
          .readAsStringSync();
      final myket =
          File('$kotlinDir/myket/kotlin/$pkg/MainActivity.kt').readAsStringSync();

      expect(bazaar, contains('BuildConfig.BAZAAR_RSA_PUBLIC_KEY'));
      expect(bazaar, isNot(contains('MYKET_RSA_PUBLIC_KEY')));
      expect(bazaar, isNot(contains('ir.mservices.market')));

      expect(myket, contains('BuildConfig.MYKET_RSA_PUBLIC_KEY'));
      expect(myket, isNot(contains('BAZAAR_RSA_PUBLIC_KEY')));
      expect(myket, isNot(contains('com.farsitel.bazaar')));
    });
  });

  group('manifest', () {
    test('هر flavor فقط مجوز فروشگاه خودش را نگه می‌دارد', () {
      final bazaar =
          File('android/app/src/bazaar/AndroidManifest.xml').readAsStringSync();
      final myket =
          File('android/app/src/myket/AndroidManifest.xml').readAsStringSync();

      expect(bazaar, contains('com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR'));
      expect(myket, contains('ir.mservices.market.BILLING'));

      // مجوز رقیب باید صریحاً حذف شود (شبکهٔ ایمنی manifest merger).
      expect(bazaar, contains('ir.mservices.market.BILLING'));
      expect(bazaar, contains('tools:node="remove"'));
      expect(myket, contains('com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR'));
      expect(myket, contains('tools:node="remove"'));
    });
  });
}
