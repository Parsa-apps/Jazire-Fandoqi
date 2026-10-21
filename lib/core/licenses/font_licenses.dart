import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// ⚖️ مجوزهای متن‌بازِ دارایی‌هایی که همراهِ برنامه توزیع می‌شوند.
///
/// فونتِ «Amiri» با مجوز SIL OFL 1.1 بسته شده است و این مجوز اجازه می‌دهد
/// فونت همراهِ اپ توزیع شود، به شرطی که متنِ پروانه هم همراهِ آن باشد.
/// فایل `assets/fonts/OFL-Amiri.txt` داخل بسته هست؛ این کلاس همان متن را
/// به «صفحهٔ مجوزها»ی خودِ Flutter معرفی می‌کند تا والد بتواند از داخل
/// برنامه (درباره و پشتیبانی ← حقوق و مجوزها) آن را بخواند.
///
/// ثبت فقط یک‌بار انجام می‌شود؛ فراخوانیِ دوباره هیچ مجوز تکراری‌ای اضافه
/// نمی‌کند و خطا هم نمی‌دهد.
abstract final class FontLicenses {
  /// مسیرِ فایلِ پروانه در بسته — در `pubspec.yaml` هم اعلام شده است.
  static const String amiriAsset = 'assets/fonts/OFL-Amiri.txt';

  /// نامِ خانوادهٔ فونت به همان شکلی که در `pubspec.yaml` آمده است.
  static const String amiriFamily = 'Amiri';

  static bool _registered = false;

  /// متنِ پروانه را از بسته می‌خواند؛ اگر دارایی در دسترس نباشد `null`
  /// برمی‌گرداند تا صفحهٔ مجوزها به‌خاطرِ یک فایلِ گم‌شده خطا ندهد.
  static Future<String?> readAmiriLicense() async {
    try {
      return await rootBundle.loadString(amiriAsset);
    } catch (_) {
      return null;
    }
  }

  /// متنِ پروانه را به `LicenseRegistry` اضافه می‌کند. باید پس از
  /// `WidgetsFlutterBinding.ensureInitialized()` صدا زده شود.
  static void register() {
    if (_registered) return;
    _registered = true;
    LicenseRegistry.addLicense(() async* {
      final String? amiri = await readAmiriLicense();
      if (amiri == null || amiri.trim().isEmpty) return;
      yield LicenseEntryWithLineBreaks(
        const <String>['Amiri (فونتِ متنِ قرآن)'],
        amiri,
      );
    });
  }

  /// فقط برای تست: ثبت را دوباره ممکن می‌کند.
  @visibleForTesting
  static void resetForTest() {
    _registered = false;
  }
}
