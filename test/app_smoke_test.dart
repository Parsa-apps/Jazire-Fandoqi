import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/app_legal.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/about/about_screen.dart';
import 'package:jazireh_fandoghi/features/cartoons/cartoon_hub_screen.dart';
import 'package:jazireh_fandoghi/features/gateway/app_gateway_screen.dart';
import 'package:jazireh_fandoghi/features/home/home_screen.dart';

Future<void> _disposeAnimatedTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  FandoghiCoach.cancelSmartHint();
  FandoghiCoach.disablePersistentPresence();
  // Some animation packages use delayed futures that cannot be cancelled.
  // Advance fake time after disposal so those callbacks can finish harmlessly.
  await tester.pump(const Duration(seconds: 6));
}

Future<void> _scrollUntilContactsAreBuilt(WidgetTester tester) async {
  final outerScrollable = find.descendant(
    of: find.byType(ListView).first,
    matching: find.byType(Scrollable),
  ).first;
  final position = tester.state<ScrollableState>(outerScrollable).position;
  final email = find.text(AppLegal.supportEmail);
  final telegram = find.text(AppLegal.telegramHandle);

  for (var attempt = 0;
      attempt < 10 &&
          (email.evaluate().isEmpty || telegram.evaluate().isEmpty);
      attempt++) {
    final nextOffset = (position.pixels + 180)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    position.jumpTo(nextOffset);
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('home island screen renders all 6 learning & game hubs and navigation', (tester) async {
    GameData.resetForTesting();
    GameData.onboardingSeen = true;

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    // ۶ هاب اصلی جزیره فندقی
    expect(find.text('فارسی'), findsOneWidget);
    expect(find.text('ریاضی'), findsOneWidget);
    // Bubble labels intentionally stay short enough for the underwater map.
    expect(find.text('حروف'), findsOneWidget);
    expect(find.text('علوم'), findsOneWidget);
    expect(find.text('بازی‌ها'), findsOneWidget);
    expect(find.text('هنر'), findsOneWidget);
    expect(find.text('پروفایل من'), findsOneWidget);

    // نوار ناوبری پایینی
    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('دستاوردها'), findsOneWidget);
    expect(find.text('کوله‌پشتی'), findsOneWidget);
    expect(find.text('کارنامه'), findsOneWidget);
    expect(find.text('پروفایل'), findsOneWidget);

    // کنترل مستقل و همیشه‌در‌دسترس موسیقی
    expect(find.byKey(const Key('music-volume-control')), findsOneWidget);
    expect(find.byKey(const Key('music-volume-slider')), findsOneWidget);
    expect(find.text('صدای موسیقی'), findsOneWidget);

    // دکمه‌های شناور کناری (آیکونی، با برچسب دسترس‌پذیری)
    expect(find.bySemanticsLabel('هدیهٔ روزانه'), findsOneWidget);
    expect(find.bySemanticsLabel('کتابخانه'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('gateway opens the island world without overflow', (tester) async {
    GameData.resetForTesting();
    GameData.onboardingSeen = true;

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AppGatewayScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('فارسی'), findsOneWidget);
    expect(find.text('علوم'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('gateway stays overflow-free on a narrow phone', (tester) async {
    GameData.resetForTesting();
    GameData.onboardingSeen = true;
    GameData.classroomLightMode = false;
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AppGatewayScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('cartoon hub screen renders one island platform per cartoon', (tester) async {
    GameData.resetForTesting();

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CartoonHubScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('کارتون‌کده فندقی'), findsOneWidget);

    // First launch has a required parent disclosure. Dismiss it, then the
    // island map with one floating platform per cartoon must be visible.
    final disclosureButton = find.text('مطّلع شدم ✅');
    if (disclosureButton.evaluate().isNotEmpty) {
      await tester.tap(disclosureButton);
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(find.byKey(const ValueKey('cartoon_island_scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('cartoon_platform_0')), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
    expect(tester.takeException(), isNull);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('about screen hides the raw website address and exposes a direct link', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    expect(find.text(AppLegal.developerName), findsOneWidget);
    expect(find.text(AppLegal.websiteName), findsOneWidget);
    expect(find.text(AppLegal.websiteAddress), findsNothing);
    expect(find.byKey(const ValueKey('parsa_website_address')), findsNothing);
    expect(find.byKey(const ValueKey('parsa_website_link')), findsOneWidget);
    expect(find.text('ورود مستقیم به سایت'), findsOneWidget);

    // Keep scrolling the stable outer ListView until both adjacent contact
    // cards are built. A dynamic `Scrollable.first` can switch to a lazily
    // created nested scrollable and then disappear between two searches.
    await _scrollUntilContactsAreBuilt(tester);
    expect(find.text(AppLegal.supportEmail), findsOneWidget);
    expect(find.text(AppLegal.telegramHandle), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });
}
