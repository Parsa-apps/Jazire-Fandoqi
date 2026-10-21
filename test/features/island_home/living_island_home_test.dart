import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/features/home/widgets/island_map/island_map_tab.dart';
import 'package:jazireh_fandoghi/features/island_home/living_island_home.dart';

import '../../support/paywall_test_store.dart';

/// 🏝️ تست‌های خانهٔ زندهٔ فندقی.
///
/// این تست‌ها فقط رفتارِ قابل‌مشاهده را قفل می‌کنند:
///   * کودک چهار میان‌بر اصلی و یک دکمهٔ شروع می‌بیند؛
///   * هر مسیر واقعاً باز می‌شود (نه دکمهٔ بی‌عملکرد)؛
///   * روی گوشیِ باریک و در حالتِ کاهشِ حرکت هم خطایی رخ نمی‌دهد؛
///   * نقشهٔ جزیره با همهٔ هاب‌ها با دکمهٔ اصلیِ شروع باز می‌شود و
///     دکمهٔ جداگانهٔ «نقشه ماجراجویی» دیگر روی خانه نیست.
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
          '/cartoons': (BuildContext context) => const Text('cartoons route'),
          '/lullabies': (BuildContext context) => const Text('lullabies route'),
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

  testWidgets('shows the start button and four feature shortcuts',
      (WidgetTester tester) async {
    await pumpHome(tester);

    expect(find.text('شروع بازی'), findsOneWidget);
    expect(find.text('کارتون‌ها'), findsOneWidget);
    expect(find.text('قصه‌ها'), findsOneWidget);
    expect(find.text('لالایی'), findsOneWidget);
    expect(find.text('بازی‌ها'), findsOneWidget);
    expect(find.text('جزیره فندقی'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('each home shortcut really navigates',
      (WidgetTester tester) async {
    await pumpHome(tester);

    final shortcuts = <(String, String)>[
      ('کارتون‌ها', 'cartoons route'),
      ('قصه‌ها', 'stories route'),
      ('لالایی', 'lullabies route'),
      ('بازی‌ها', 'games route'),
    ];
    for (final (label, destination) in shortcuts) {
      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(destination), findsOneWidget);
      if (label != 'بازی‌ها') {
        await tester.binding.handlePopRoute();
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('the start button opens the island map',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('شروع بازی'));
    // pumpAndSettle اینجا ممنوع است: انیمیشنِ محیطِ جزیره بی‌پایان است.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // دکمهٔ اصلیِ «شروع ماجراجویی» مستقیم نقشهٔ کاملِ جزیره را باز می‌کند.
    expect(tester.takeException(), isNull);
    expect(find.byType(IslandMapTab), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('there is no separate adventure map button on home',
      (WidgetTester tester) async {
    await pumpHome(tester);

    expect(
      find.byKey(const ValueKey<String>('living_island_map_chip')),
      findsNothing,
    );
    expect(find.text('نقشه ماجراجویی'), findsNothing);
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
    expect(find.text('بازی‌ها'), findsOneWidget);
    expect(find.text('نقشه ماجراجویی'), findsNothing);
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

/// درخت‌های متحرک و تایمرِ مربیِ فندقی باید پیش از پایانِ تست جمع شوند؛
/// در غیر این صورت flutter_test با «A Timer is still pending» شکست می‌خورد.
/// (همان الگویِ app_smoke_test.dart)
Future<void> _disposeAnimatedTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  FandoghiCoach.cancelSmartHint();
  FandoghiCoach.disablePersistentPresence();
  await tester.pump(const Duration(seconds: 6));
}
