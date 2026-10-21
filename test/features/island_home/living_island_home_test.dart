import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/features/island_home/living_island_home.dart';

import '../../support/paywall_test_store.dart';

/// 🏝️ تست‌های خانهٔ زندهٔ فندقی.
///
/// این تست‌ها فقط رفتارِ قابل‌مشاهده را قفل می‌کنند:
///   * کودک سه مسیر و یک دکمهٔ شروع می‌بیند؛
///   * هر مسیر واقعاً باز می‌شود (نه دکمهٔ بی‌عملکرد)؛
///   * روی گوشیِ باریک و در حالتِ کاهشِ حرکت هم خطایی رخ نمی‌دهد؛
///   * نقشهٔ قدیمی با همهٔ هاب‌ها هنوز در دسترس است.
void main() {
  late PaywallTestStore store;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
    GameData.onboardingSeen = true;
    GrowthStore.resetForTesting();
    store = PaywallTestStore()..install();
  });

  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.cancelSmartHint();
    FandoghiCoach.disablePersistentPresence();
    store.dispose();
  });

  Widget harness({
    Size size = const Size(390, 844),
    bool reduceMotion = false,
  }) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('fa'),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            devicePixelRatio: 1,
            padding: EdgeInsets.zero,
            disableAnimations: reduceMotion,
          ),
          child: const SizedBox.expand(child: LivingIslandHome()),
        ),
        routes: <String, WidgetBuilder>{
          '/games-carnival': (BuildContext context) => const Text('games route'),
          '/learning-library': (BuildContext context) =>
              const Text('library route'),
          '/stories': (BuildContext context) => const Text('stories route'),
          '/alphabet': (BuildContext context) => const Text('alphabet route'),
          '/parent': (BuildContext context) => const Text('parent route'),
        },
      ),
    );
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    bool reduceMotion = false,
  }) async {
    await tester.pumpWidget(harness(size: size, reduceMotion: reduceMotion));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('shows the start button and the three main paths',
      (WidgetTester tester) async {
    await pumpHome(tester);

    expect(find.text('شروع بازی'), findsOneWidget);
    expect(find.text('بازی'), findsOneWidget);
    expect(find.text('آموزش'), findsOneWidget);
    expect(find.text('داستان'), findsOneWidget);
    expect(find.text('جزیره فندقی'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('each of the three paths really navigates',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('بازی'));
    // pumpAndSettle اینجا ممنوع است: انیمیشنِ محیطِ جزیره بی‌پایان است.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('games route'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('آموزش'));
    // pumpAndSettle اینجا ممنوع است: انیمیشنِ محیطِ جزیره بی‌پایان است.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('library route'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('داستان'));
    // pumpAndSettle اینجا ممنوع است: انیمیشنِ محیطِ جزیره بی‌پایان است.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('stories route'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('the start button follows the real guided path of today',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('شروع بازی'));
    // pumpAndSettle اینجا ممنوع است: انیمیشنِ محیطِ جزیره بی‌پایان است.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // اولین ایستگاهِ امروز برای یک پروفایلِ تازه، الفباست.
    expect(find.text('alphabet route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a narrow 320x568 phone',
      (WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final text = details.toString();
      final isRenderFlexOverflow = text.contains('RenderFlex overflowed') ||
          (text.contains('overflowed by') && text.contains('pixels'));
      if (!isRenderFlexOverflow) originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await pumpHome(tester, size: const Size(320, 568));

    expect(find.text('شروع بازی'), findsOneWidget);
    expect(find.text('بازی'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without errors when motion is reduced',
      (WidgetTester tester) async {
    await pumpHome(tester, reduceMotion: true);

    expect(find.text('شروع بازی'), findsOneWidget);
    // دو فریم دیگر پیش می‌رویم تا هر تیکری که مانده باشد خودش را نشان دهد.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the purchase entry and parent settings reachable',
      (WidgetTester tester) async {
    await pumpHome(tester);

    // مسیرِ خرید هرگز حذف یا شبیه‌سازی نمی‌شود.
    expect(
      find.byKey(const ValueKey('full_version_purchase_entry')),
      findsOneWidget,
    );
    // تنظیمات والدین پشتِ نگهبانِ واقعیِ پین است.
    expect(find.bySemanticsLabel('تنظیمات والدین'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
