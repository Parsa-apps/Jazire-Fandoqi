import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// اسناد فروشگاه باید با کد و نسخهٔ جاری یکی بمانند.
///
/// این تست نگهبانِ اصلاحات `docs(store)` است: ادعاهایی که یک بار در متن‌های
/// آمادهٔ انتشار غلط از آب درآمدند (حیوانات «بومی»، دیده‌نشدن دکمهٔ خرید،
/// نسخهٔ هدفِ کهنه و اسکرین‌شات‌های ۶.۲.۶ به‌عنوان مجموعهٔ نهایی) نباید
/// بی‌صدا به متن کپی‌پیست پنل برگردند. منبع نسخه `pubspec.yaml` است؛
/// هنگام ارتقای نسخه، اشاره‌گرهای `store/` و فایل «تغییرات این نسخه»ی
/// مایکت را هم با آن جلو ببرید.
void main() {
  test('publishable store copy does not repeat the corrected stale claims',
      () {
    const staleClaims = <String>[
      '۳۰ حیوان بومی ایران',
      '30 animals native to Iran',
      'کودک دکمه خرید نمی‌بیند',
      'کودک صفحه خرید را نمی‌بیند',
      'دکمهٔ خرید پشت قفل والدین است',
      'تقریباً رایگان',
    ];
    const publishableCopy = <String>[
      'store/bazaar/STORE_LISTING.md',
      'store/bazaar/TOZIHAT_KAMEL_FARSI.txt',
      'store/myket/STORE_LISTING.md',
    ];

    final offenders = <String>[];
    for (final path in publishableCopy) {
      final lines = File(path).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final claim in staleClaims) {
          if (!line.contains(claim)) continue;
          // جدول «حذف شد و چرا» در انتهای متن مایکت عمداً عبارت قدیمی را
          // نقل می‌کند تا دلیل حذفش ثبت بماند؛ آن نقلِ تاریخی متن انتشار نیست.
          final isHistoricalRemovalNote =
              path == 'store/myket/STORE_LISTING.md' &&
                  claim == '۳۰ حیوان بومی ایران' &&
                  line.contains('تغییر کرد');
          if (!isHistoricalRemovalNote) {
            offenders.add('$path:${i + 1} → $claim');
          }
        }
      }
    }

    expect(offenders, isEmpty,
        reason: 'ادعای کهنه در متن آمادهٔ انتشار فروشگاه:\n'
            '${offenders.join('\n')}');
  });

  test('current store pointers name the pubspec target version', () {
    final version = _pubspecVersion();
    final target = '${version.full}+${version.build}';
    const pointers = <String>[
      'store/myket/STORE_LISTING.md',
      'store/myket/README.md',
      'store/myket/SCREENSHOTS_PLAN_FA.md',
      'store/bazaar/STORE_LISTING.md',
      'store/bazaar/README.md',
      'CAFEBAZAAR_STORE_LISTING_FA.md',
      'MYKET_ASO_PLAN_FA.md',
    ];

    for (final path in pointers) {
      expect(File(path).readAsStringSync().contains(target), isTrue,
          reason: '$path باید نسخهٔ هدف فعلی ($target، از pubspec.yaml) را '
              'نام ببرد؛ اشاره‌گر کهنه یعنی متن نسخه‌ای توصیف می‌شود که '
              'کاربر نصب نمی‌کند');
    }

    final releaseNotes = 'RELEASE_NOTES_${version.major}_${version.minor}'
        '_${version.patch}_MYKET.md';
    expect(File('store/myket/$releaseNotes').existsSync(), isTrue,
        reason: 'برای نسخهٔ هدف باید متن آمادهٔ «تغییرات این نسخه» وجود '
            'داشته باشد: store/myket/$releaseNotes');
    for (final path in const [
      'store/myket/STORE_LISTING.md',
      'store/myket/README.md',
    ]) {
      expect(File(path).readAsStringSync().contains(releaseNotes), isTrue,
          reason: '$path باید فیلد «تغییرات این نسخه» را به $releaseNotes '
              'ارجاع دهد، نه به متن نسخهٔ قبلی');
    }
  });

  test('Bazaar has one publishable source and legacy texts say so', () {
    final bazaarListing =
        File('store/bazaar/STORE_LISTING.md').readAsStringSync();
    final bazaarReadme = File('store/bazaar/README.md').readAsStringSync();
    final legacyDraft =
        File('store/bazaar/TOZIHAT_KAMEL_FARSI.txt').readAsStringSync();
    final rootLegacy =
        File('CAFEBAZAAR_STORE_LISTING_FA.md').readAsStringSync();

    expect(bazaarListing.contains('مرجع واحد انتشار بازار همین فایل است'),
        isTrue,
        reason: 'متن بازار باید یک مرجع واحد انتشار داشته باشد');
    expect(bazaarListing.contains('عنوان بلندتر (فعلاً استفاده نشود)'), isTrue,
        reason: 'عنوان بلند بازار تا وقتی android:label همان نشده نباید '
            'به‌عنوان گزینهٔ آمادهٔ پنل عرضه شود');
    expect(bazaarListing.contains('android:label'), isTrue,
        reason: 'قید هم‌نامی عنوان فروشگاه با نام نصب‌شده باید کنار عنوان '
            'بلند بماند');

    expect(bazaarReadme.contains('مرجع واحد و متن آمادهٔ انتشار بازار'),
        isTrue,
        reason: 'README بازار باید مرجع واحد متن‌ها را معرفی کند');
    expect(bazaarReadme.contains('منبع انتشار نیست'), isTrue,
        reason: 'پیش‌نویس قدیمی TOZIHAT نباید با متن انتشار اشتباه گرفته شود');

    expect(rootLegacy.contains('سند تاریخی — متن کپی فعلی نیست'), isTrue,
        reason: 'فایل ریشهٔ بازار سند تاریخی است و باید همین را در صدر بگوید');
    expect(rootLegacy.contains('store/bazaar/STORE_LISTING.md'), isTrue,
        reason: 'سند تاریخی باید خواننده را به مرجع فعلی بازار بفرستد');

    expect(
        legacyDraft
            .contains('نیمهٔ اول بدون پرداخت باز است و نیمهٔ دوم با یک '
                'خرید دائمی باز می‌شود'),
        isTrue,
        reason: 'حتی پیش‌نویس قدیمی هم باید قانون نیمهٔ رایگان/نیمهٔ کامل را '
            'مثل مرجع واحد بگوید تا اگر اشتباهی کپی شد گمراه‌کننده نباشد');
  });

  test('the archived 6.2.6 screenshot set is not upload-ready copy', () {
    final bazaarReadme = File('store/bazaar/README.md').readAsStringSync();
    final myketReadme = File('store/myket/README.md').readAsStringSync();
    final screenshotsPlan =
        File('store/myket/SCREENSHOTS_PLAN_FA.md').readAsStringSync();
    final myketListing =
        File('store/myket/STORE_LISTING.md').readAsStringSync();

    expect(
        bazaarReadme.contains(
            'مجموعهٔ فعلی `upload/` نهایی نیست و برای نسخهٔ هدف آپلود نشود'),
        isTrue,
        reason: 'مجموعهٔ ۶.۲.۶ نباید به‌عنوان اسکرین‌شات نهایی نسخهٔ هدف '
            'معرفی شود');
    expect(bazaarReadme.contains('را دقیقاً با این ترتیب بارگذاری کنید'),
        isFalse,
        reason: 'دستور آپلود مستقیم مجموعهٔ آرشیوی نباید برگردد');
    expect(
        bazaarReadme.contains(
            'همین هشت فایل برای **مایکت** نیز قابل استفاده‌اند'),
        isFalse,
        reason: 'هشت فایل ۶.۲.۶ برای هیچ‌یک از دو فروشگاه در نسخهٔ هدف '
            'قابل استفاده نیستند');

    expect(myketReadme.contains('برای نسخهٔ هدف آپلود نشود'), isTrue,
        reason: 'README مایکت هم باید منسوخ‌بودن مجموعهٔ فعلی را صریح بگوید');
    expect(screenshotsPlan.contains('نباید آپلود شود'), isTrue,
        reason: 'طرح تصاویر باید آپلود مجموعهٔ قدیمی را ممنوع بداند');
    expect(myketListing.contains('نباید برای این نسخه آپلود شود'), isTrue,
        reason: 'جدول فیلدهای پنل مایکت باید کنار فیلد اسکرین‌شات همین '
            'هشدار را داشته باشد');
  });
}

({String major, String minor, String patch, String build, String full})
    _pubspecVersion() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final match = RegExp(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec);
  if (match == null) {
    throw StateError('pubspec.yaml باید `version: X.Y.Z+N` داشته باشد');
  }
  final major = match.group(1)!;
  final minor = match.group(2)!;
  final patch = match.group(3)!;
  return (
    major: major,
    minor: minor,
    patch: patch,
    build: match.group(4)!,
    full: '$major.$minor.$patch',
  );
}
