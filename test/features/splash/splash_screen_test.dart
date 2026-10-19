import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jazireh_fandoghi/app/parsa_brand.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/core/startup/startup_coordinator.dart';
import 'package:jazireh_fandoghi/features/splash/splash_screen.dart';
import 'package:jazireh_fandoghi/features/splash/widgets/splash_brand.dart';

/// 🎬 تست‌های صفحهٔ آغازین سینمایی.
///
/// دو قرارداد مهم:
///  ۱. تا آماده‌شدنِ واقعیِ برنامه (پایان مراحل) صفحه جابه‌جا نمی‌شود.
///  ۲. هرگز روی اسپلش قفل نمی‌شود؛ خطا/تأخیر به ورودِ ایمن تبدیل می‌شود.
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

  /// اسپلش عمداً از تایمرهای واقعی استفاده می‌کند؛ به‌جای یک `pumpAndSettle`
  /// (که با انیمیشن بی‌پایان هاله هرگز به پایان نمی‌رسد) چند فریم جلو می‌بریم
  /// تا مسیر بعدی ساخته شود.
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    int frames = 48,
  }) async {
    for (var i = 0; i < frames && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('shows the official brand mark and waits for real readiness',
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
    await tester.pump(const Duration(milliseconds: 120));

    expect(
      find.byKey(const ValueKey<String>('parsa_splash_logo')),
      findsOneWidget,
    );
    expect(find.text('در حال آماده‌سازی...'), findsOneWidget);
    expect(find.text(ParsaBrand.poweredBy), findsOneWidget);

    // ۵ ثانیه با کارِ واقعیِ تمام‌نشده: هنوز باید روی اسپلش باشیم.
    await tester.pump(const Duration(seconds: 5));
    expect(
      find.byKey(const ValueKey<String>('parsa_splash_progress')),
      findsOneWidget,
    );
    expect(find.text('gateway'), findsNothing);

    gate.complete();
    await pumpUntil(tester, find.text('gateway'));

    expect(find.text('gateway'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('percentage follows the weighted real steps',
      (WidgetTester tester) async {
    final gate = Completer<void>();
    final coordinator = StartupCoordinator(
      securityCheck: false,
      steps: <StartupStep>[
        StartupStep(id: 'first', weight: 0.5, run: () async {}),
        StartupStep(
          id: 'second',
          weight: 0.5,
          timeout: const Duration(seconds: 30),
          run: () => gate.future,
        ),
      ],
    );

    await tester.pumpWidget(harness(coordinator));
    await tester.pump(const Duration(milliseconds: 600));

    // مرحلهٔ اول تمام شده و مرحلهٔ دوم هنوز نه: دقیقاً نیمه.
    expect(find.text('۵۰٪'), findsOneWidget);
    expect(find.text('۱۰۰٪'), findsNothing);

    gate.complete();
    await pumpUntil(tester, find.text('gateway'));
    expect(find.text('gateway'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a tampered build is routed to the security screen',
      (WidgetTester tester) async {
    final coordinator = StartupCoordinator(
      securityCheck: true,
      securityProbe: () async => true,
      steps: <StartupStep>[
        StartupStep(id: 'prepare', weight: 0.8, run: () async {}),
      ],
    );

    await tester.pumpWidget(harness(coordinator));
    await pumpUntil(tester, find.text('blocked'));

    expect(find.text('blocked'), findsOneWidget);
    expect(find.text('gateway'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('fits a narrow 320x568 phone without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final coordinator = StartupCoordinator(
      securityCheck: false,
      steps: <StartupStep>[
        StartupStep(id: 'fast', weight: 1, run: () async {}),
      ],
    );

    await tester.pumpWidget(harness(coordinator));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey<String>('parsa_splash_logo')),
      findsOneWidget,
    );

    await pumpUntil(tester, find.text('gateway'));
    expect(find.text('gateway'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('keeps the mark square and proportionate on a tablet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1366);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final coordinator = StartupCoordinator(
      securityCheck: false,
      steps: <StartupStep>[
        StartupStep(id: 'fast', weight: 1, run: () async {}),
      ],
    );

    await tester.pumpWidget(harness(coordinator));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);

    // هیچ کشیدگی/برشی: قاب لوگو دقیقاً مربع می‌ماند و تصویر با BoxFit.contain
    // رسم می‌شود، پس روی صفحهٔ بزرگ فقط بزرگ‌تر می‌شود.
    final markSize = tester.getSize(find.byType(SplashBrand));
    expect(markSize.width, closeTo(markSize.height, 0.01));
    expect(markSize.width, greaterThan(280));
    expect(markSize.width, lessThan(1024 * 0.55));

    final image = tester.widget<Image>(
      find
          .descendant(
            of: find.byType(SplashBrand),
            matching: find.byType(Image),
          )
          .first,
    );
    expect(image.fit, BoxFit.contain);

    await pumpUntil(tester, find.text('gateway'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion shortens the entrance but still reveals the app',
      (WidgetTester tester) async {
    final coordinator = StartupCoordinator(
      securityCheck: false,
      steps: <StartupStep>[
        StartupStep(id: 'fast', weight: 1, run: () async {}),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SplashScreen(coordinator: coordinator),
        ),
        routes: <String, WidgetBuilder>{
          '/gateway': (BuildContext context) => const Text('gateway'),
        },
      ),
    );

    await pumpUntil(tester, find.text('gateway'), frames: 20);

    expect(find.text('gateway'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
