import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/core/startup/startup_coordinator.dart';
import 'package:jazireh_fandoghi/features/splash/splash_screen.dart';

/// ⏭️ ردکردنِ اسپلش باید امن باشد:
///   * تا راه‌اندازیِ واقعی تمام نشده، هیچ لمسی برنامه را باز نمی‌کند؛
///   * بعد از اتمام، یک لمس فوراً وارد برنامه می‌شود.
void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
    GameData.onboardingSeen = true;
    GrowthStore.resetForTesting();
    GrowthStore.lastWhatsNewVersion = GrowthStore.appVersion;
  });

  Widget harness(StartupCoordinator coordinator) {
    return MaterialApp(
      locale: const Locale('fa'),
      home: SplashScreen(coordinator: coordinator),
      routes: <String, WidgetBuilder>{
        '/tutorial': (BuildContext context) => const Text('tutorial'),
        '/gateway': (BuildContext context) => const Text('gateway'),
        '/whats-new': (BuildContext context) => const Text('whats-new'),
        '/security-blocked': (BuildContext context) => const Text('blocked'),
      },
    );
  }

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    int frames = 40,
  }) async {
    for (var i = 0; i < frames && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('a tap cannot enter the app before startup really finishes',
      (WidgetTester tester) async {
    final gate = Completer<void>();
    final coordinator = StartupCoordinator(
      securityCheck: false,
      steps: <StartupStep>[
        StartupStep(
          id: 'prepare',
          weight: 1,
          timeout: const Duration(seconds: 30),
          run: () => gate.future,
        ),
      ],
    );

    await tester.pumpWidget(harness(coordinator));
    await tester.pump(const Duration(milliseconds: 200));

    // چند لمس در حالی که هنوز آماده نیستیم
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byType(SplashScreen));
      await tester.pump(const Duration(milliseconds: 120));
    }

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('gateway'), findsNothing);

    gate.complete();
    await pumpUntil(tester, find.text('gateway'));
    expect(find.text('gateway'), findsOneWidget);
  });

  testWidgets('after startup completes, a tap enters immediately',
      (WidgetTester tester) async {
    final coordinator = StartupCoordinator(
      securityCheck: false,
      steps: <StartupStep>[
        StartupStep(id: 'fast', weight: 1, run: () async {}),
      ],
    );

    await tester.pumpWidget(harness(coordinator));
    // زمانِ کافی می‌دهیم تا مرحلهٔ واقعیِ راه‌اندازی تمام شود؛ حداقل
    // زمانِ نمایشِ اسپلش هنوز نگذشته است.
    await tester.pump(const Duration(milliseconds: 600));

    // هنوز حداقل زمانِ نمایش نگذشته است.
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.tap(find.byType(SplashScreen));
    await pumpUntil(tester, find.text('gateway'), frames: 12);

    expect(find.text('gateway'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
