import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/features/coloring/coloring_book_screen.dart';
import 'package:jazireh_fandoghi/features/music/music_studio_screen.dart';
import 'package:jazireh_fandoghi/features/poems/poems_hub_screen.dart';
import 'package:jazireh_fandoghi/features/quran/quran_kids_screen.dart';
import 'package:jazireh_fandoghi/features/science/science_lab_screen.dart';
import 'package:jazireh_fandoghi/features/shop/content_lock.dart';

import '../support/paywall_test_store.dart';

/// 🚪 دودِ هاب‌های تازه
///
/// هر پنج هابِ «دسته‌بندی‌ها» باید بدون استثنا باز شوند؛ این تست جلوی
/// برگشتِ باگِ «صفحه پیدا نشد» و شکستنِ فریمِ اول را می‌گیرد.
void main() {
  setUpUnpurchasedStore();
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });
  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.cancelSmartHint();
    FandoghiCoach.disablePersistentPresence();
  });

  /// آیتم‌های نیمهٔ پولی معمولاً پایین‌تر از فریمِ اول‌اند و
  /// `GridView.builder` تنبل می‌سازد؛ تا دیده‌شدنِ قفل اسکرول می‌کنیم تا
  /// نتیجه به ارتفاعِ دقیقِ دستگاه وابسته نباشد.
  Future<void> expectPaidHalfLocked(WidgetTester tester) async {
    final badge = find.byType(LockedItemBadge);
    for (var i = 0; i < 8 && badge.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(badge, findsWidgets);
  }

  /// هاب را بالا می‌آورد، [verify] را **قبل از** پاک‌کردنِ درخت اجرا
  /// می‌کند و بعد همه‌چیز را تمیز می‌بندد.
  ///
  /// پیش‌تر بررسی‌ها بعد از پایانِ این تابع انجام می‌شد، یعنی وقتی
  /// `SizedBox.shrink` جای درخت را گرفته بود و هیچ ویجتی روی صفحه نبود؛
  /// به همین دلیل قفل‌ها «پیدا نمی‌شدند».
  Future<void> pumpHub(
    WidgetTester tester,
    Widget hub,
    String title, {
    Future<void> Function()? verify,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(home: hub));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text(title), findsWidgets, reason: title);
    await verify?.call();
    expect(tester.takeException(), isNull, reason: title);

    await tester.pumpWidget(const SizedBox.shrink());
    FandoghiCoach.clear();
    FandoghiCoach.cancelSmartHint();
    FandoghiCoach.disablePersistentPresence();
    await tester.pump(const Duration(seconds: 6));
  }

  testWidgets('استودیوی موسیقی باز می‌شود', (tester) async {
    await pumpHub(tester, const MusicStudioScreen(), 'استودیوی موسیقی');
  });

  testWidgets('کتاب رنگ‌آمیزی باز می‌شود و نیمهٔ پولی را قفل می‌کند',
      (tester) async {
    await pumpHub(
      tester,
      const ColoringBookScreen(),
      'کتابِ رنگ‌آمیزی',
      verify: () => expectPaidHalfLocked(tester),
    );
  });

  testWidgets('شعرستان باز می‌شود و نیمهٔ پولی را قفل می‌کند', (tester) async {
    await pumpHub(
      tester,
      const PoemsHubScreen(),
      'شعرستانِ فندقی',
      verify: () => expectPaidHalfLocked(tester),
    );
  });

  testWidgets('قرآنِ کودک کامل رایگان باز می‌شود', (tester) async {
    await pumpHub(
      tester,
      const QuranKidsScreen(),
      'قرآنِ کودک',
      verify: () => expect(find.byType(LockedItemBadge), findsNothing),
    );
  });

  testWidgets('آزمایشگاه علوم باز می‌شود و نیمهٔ پولی را قفل می‌کند',
      (tester) async {
    await pumpHub(
      tester,
      const ScienceLabScreen(),
      'آزمایشگاهِ علوم',
      verify: () => expectPaidHalfLocked(tester),
    );
  });
}
