import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/app/island_cinema_style.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/features/home/home_screen.dart';
import 'package:jazireh_fandoghi/features/home/widgets/island_map/island_map_tab.dart';
import 'package:jazireh_fandoghi/features/island_home/living_island_home.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/hero_cheer_burst_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/widgets/daily_goal_card.dart';
import 'package:jazireh_fandoghi/features/island_home/widgets/fandoqi_hero.dart';
import 'package:jazireh_fandoghi/features/island_home/widgets/fandoqi_speech_bubble.dart';
import 'package:jazireh_fandoghi/features/island_home/widgets/island_scene.dart';
import 'package:jazireh_fandoghi/features/island_home/widgets/primary_start_button.dart';
import 'package:jazireh_fandoghi/shared/widgets/html_web_view.dart';

import '../../support/paywall_test_store.dart';

/// 🏝️ تست‌های خانهٔ زندهٔ فندقی.
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
    GrowthStore.reduceMotion = false;
    store.dispose();
  });

  Widget harness({
    Size size = const Size(390, 844),
    EdgeInsets padding = EdgeInsets.zero,
    bool reduceMotion = false,
  }) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('fa'),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            devicePixelRatio: 1,
            padding: padding,
            disableAnimations: reduceMotion,
          ),
          child: const SizedBox.expand(child: LivingIslandHome()),
        ),
        routes: <String, WidgetBuilder>{
          '/games-carnival': (BuildContext context) =>
              const Text('games route'),
          '/learning-library': (BuildContext context) =>
              const Text('library route'),
          '/stories': (BuildContext context) => const Text('stories route'),
          '/alphabet': (BuildContext context) => const Text('alphabet route'),
          '/math/add': (BuildContext context) => const Text('math route'),
          '/parent': (BuildContext context) => const Text('parent route'),
        },
      ),
    );
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    EdgeInsets padding = EdgeInsets.zero,
    bool reduceMotion = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      harness(size: size, padding: padding, reduceMotion: reduceMotion),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets(
      'shows the start button, daily goal card, speech bubble and paths',
      (WidgetTester tester) async {
    await pumpHome(tester);

    expect(find.text('شروع بازی'), findsOneWidget);
    expect(find.text('شروع ماجراجویی'), findsOneWidget);
    expect(find.text('بازی'), findsOneWidget);
    expect(find.text('آموزش'), findsOneWidget);
    expect(find.text('داستان'), findsOneWidget);
    expect(find.text('جزیره فندقی'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('living_island_daily_goal_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('living_island_speech_bubble')),
      findsOneWidget,
    );
    expect(find.byType(DailyGoalCard), findsOneWidget);
    expect(find.byType(FandoqiSpeechBubble), findsOneWidget);
    expect(find.text('۰ از ۴'), findsOneWidget);

    final hero = tester.widget<FandoqiHero>(find.byType(FandoqiHero));
    expect(hero.imageOpacity, 0.0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the invisible hero cheers and updates the speech bubble',
      (WidgetTester tester) async {
    await pumpHome(tester);

    final initialBubble = tester
        .widget<FandoqiSpeechBubble>(find.byType(FandoqiSpeechBubble))
        .message;

    await tester.tap(find.byType(FandoqiHero));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    final updatedBubble = tester
        .widget<FandoqiSpeechBubble>(find.byType(FandoqiSpeechBubble))
        .message;
    expect(updatedBubble, isNot(equals(initialBubble)));

    final cheerPaints = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(FandoqiHero),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((CustomPaint p) => p.painter)
        .whereType<HeroCheerBurstPainter>();
    expect(cheerPaints, hasLength(1));

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('daily goal card reflects real progress and opens today station',
      (WidgetTester tester) async {
    GameData.markTodayStation('literacy');
    await pumpHome(tester);

    expect(find.text('۱ از ۴'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('living_island_daily_goal_card')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('math route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'keeps invisible FandoqiHero tap area aligned with baked squirrel '
      'across aspect ratios and status-bar insets',
      (WidgetTester tester) async {
    final cases = <(Size, EdgeInsets)>[
      (const Size(320, 568), EdgeInsets.zero),
      (const Size(390, 844), const EdgeInsets.only(top: 47)),
      (const Size(412, 915), const EdgeInsets.only(top: 28)),
      (const Size(1024, 1366), const EdgeInsets.only(top: 24)),
      (const Size(800, 600), EdgeInsets.zero),
    ];

    for (final (viewport, inset) in cases) {
      await pumpHome(tester, size: viewport, padding: inset);

      final expected = IslandScene.bakedSquirrelRect(viewport);
      final goalRect = tester.getRect(find.byType(DailyGoalCard));
      final bubbleRect = tester.getRect(find.byType(FandoqiSpeechBubble));
      final actual = tester.getRect(find.byType(FandoqiHero));
      final startRect = tester.getRect(find.byType(PrimaryStartButton));

      expect(goalRect.bottom, lessThan(bubbleRect.top));
      expect(bubbleRect.bottom, lessThanOrEqualTo(actual.top));
      expect(actual.left, closeTo(expected.left.clamp(0.0, viewport.width), 1));
      expect(
        actual.right,
        closeTo(expected.right.clamp(0.0, viewport.width), 1),
      );
      expect(actual.top, closeTo(expected.top, 1.5));
      expect(actual.bottom, lessThanOrEqualTo(startRect.top));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('each of the three paths really navigates',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('بازی'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('games route'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('آموزش'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('library route'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('داستان'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('stories route'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('the start button follows the real guided path of today',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('شروع بازی'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('alphabet route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PrimaryStartButton pulses to ~1.04 on 2400ms loop and honors '
      'GrowthStore.reduceMotion', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: PrimaryStartButton(onTap: () {}),
        ),
      ),
    );
    await tester.pump();

    double currentScale() {
      final transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(PrimaryStartButton),
          matching: find.byType(Transform),
        ),
      );
      return transform.transform.storage[0];
    }

    expect(currentScale(), closeTo(1.0, 0.002));

    // نیمهٔ چرخهٔ ۲۴۰۰ میلی‌ثانیه‌ای (۱۲۰۰ms): اوجِ مقیاس روی ~۱٫۰۴
    await tester.pump(const Duration(milliseconds: 1200));
    expect(currentScale(), closeTo(1.04, 0.003));

    // پایانِ چرخهٔ ۲۴۰۰ میلی‌ثانیه‌ای: بازگشتِ نرم به ۱٫۰۰
    await tester.pump(const Duration(milliseconds: 1200));
    expect(currentScale(), closeTo(1.0, 0.003));

    // فعال‌سازیِ GrowthStore.reduceMotion بدون تغییر MediaQuery
    GrowthStore.setReduceMotion(true);
    await tester.pump();
    expect(currentScale(), closeTo(1.0, 0.001));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(currentScale(), closeTo(1.0, 0.001));
  });

  testWidgets('HomeScreen removes hidden HtmlWebView layers behind opaque tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(HtmlWebView), findsNothing);
    expect(tester.takeException(), isNull);

    await _disposeAnimatedTree(tester);
  });

  test('preserves original IslandCinemaMotion timings verbatim', () {
    expect(IslandCinemaMotion.ambientLoop, const Duration(seconds: 14));
    expect(IslandCinemaMotion.heroEntrance, const Duration(milliseconds: 900));
    expect(IslandCinemaMotion.heroBreath, const Duration(milliseconds: 3400));
    expect(IslandCinemaMotion.heroBlink, const Duration(milliseconds: 150));
    expect(IslandCinemaMotion.heroCheer, const Duration(milliseconds: 1150));
    expect(IslandCinemaMotion.pressIn, const Duration(milliseconds: 90));
    expect(IslandCinemaMotion.pressOut, const Duration(milliseconds: 220));
  });

  testWidgets('the island map chip opens the classic map',
      (WidgetTester tester) async {
    await pumpHome(tester);

    final chip = find.byKey(const ValueKey<String>('living_island_map_chip'));
    expect(chip, findsOneWidget);
    await tester.ensureVisible(chip);
    await tester.pump();
    await tester.tap(chip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byType(IslandMapTab), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('renders without overflow on a narrow 320x568 phone',
      (WidgetTester tester) async {
    await pumpHome(tester, size: const Size(320, 568));

    expect(find.text('شروع بازی'), findsOneWidget);
    expect(find.text('بازی'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without errors when motion is reduced',
      (WidgetTester tester) async {
    await pumpHome(tester, reduceMotion: true);

    expect(find.text('شروع بازی'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the purchase entry and parent settings reachable',
      (WidgetTester tester) async {
    await pumpHome(tester);

    expect(
      find.byKey(const ValueKey('full_version_purchase_entry')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('تنظیمات والدین'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _disposeAnimatedTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  FandoghiCoach.cancelSmartHint();
  FandoghiCoach.disablePersistentPresence();
  await tester.pump(const Duration(seconds: 6));
}
