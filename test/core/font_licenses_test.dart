import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/licenses/font_licenses.dart';

/// ⚖️ دارایی‌های فونت باید همراهِ پروانه‌شان باشند.
///
/// فونت Amiri با مجوز SIL OFL 1.1 توزیع می‌شود؛ اگر فایلِ پروانه از بسته
/// جا بیفتد، توزیعِ اپ از نظرِ مجوز مشکل دارد. این تست هم وجودِ فایل را
/// چک می‌کند هم این‌که مسیرِ معرفی‌شده به `LicenseRegistry` همان فایل است.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('فایل پروانهٔ Amiri در بسته خوانده می‌شود', () async {
    final text = await FontLicenses.readAmiriLicense();
    expect(text, isNotNull);
    expect(text!.length, greaterThan(1000));
    expect(text, contains('SIL OPEN FONT LICENSE'));
    expect(text.toUpperCase(), contains('AMIRI'));
  });

  test('ثبت مجوز تکرارپذیر است و استثنا نمی‌دهد', () {
    FontLicenses.resetForTest();
    expect(() => FontLicenses.register(), returnsNormally);
    expect(() => FontLicenses.register(), returnsNormally);
  });

  test('دارایی‌های بسته واقعاً در بستهٔ Flutter دیده می‌شوند', () async {
    final data = await rootBundle.load(FontLicenses.amiriAsset);
    expect(data.lengthInBytes, greaterThan(1000));
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    expect(manifest.listAssets(), contains(FontLicenses.amiriAsset));
    expect(
      manifest.listAssets(),
      contains('assets/fonts/Amiri-Regular.ttf'),
    );
  });
}
