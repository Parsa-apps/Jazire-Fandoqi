import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/app_legal.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/about/about_screen.dart';
import 'package:jazireh_fandoghi/features/cartoons/cartoon_hub_screen.dart';
import 'package:jazireh_fandoghi/features/gateway/app_gateway_screen.dart';
import 'package:jazireh_fandoghi/features/home/home_screen.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('home dashboard renders the core child actions', (tester) async {
    GameData.resetForTesting();
    GameData.onboardingSeen = true;

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('ماموریت‌های امروز'), findsOneWidget);
    expect(find.text('بازی‌های سریع'), findsOneWidget);
    expect(find.text('دسته‌بندی بازی‌ها'), findsOneWidget);
  });

  testWidgets('gateway renders prioritized primary and secondary actions', (tester) async {
    GameData.resetForTesting();
    GameData.onboardingSeen = true;

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AppGatewayScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    final cartoon = find.text('سینما کارتون');
    final stories = find.text('قصه‌خانه');
    final learning = find.text('بازی و یادگیری');

    expect(cartoon, findsOneWidget);
    expect(stories, findsOneWidget);
    expect(learning, findsOneWidget);
    expect(find.text('لالایی‌های شب'), findsOneWidget);
    expect(find.text('پروفایل من'), findsOneWidget);
    expect(find.text('درباره ما'), findsOneWidget);
    expect(find.textContaining('کتابخانه یادگیری'), findsOneWidget);

    // اولویت بصری منوی اصلی باید دقیقاً کارتون ← قصه ← بازی و یادگیری باشد.
    expect(
      tester.getTopLeft(cartoon).dy,
      lessThan(tester.getTopLeft(stories).dy),
    );
    expect(
      tester.getTopLeft(stories).dy,
      lessThan(tester.getTopLeft(learning).dy),
    );

    final cartoonSize = tester.getSize(
      find.byKey(const Key('gateway.cartoon')),
    );
    final storySize = tester.getSize(
      find.byKey(const Key('gateway.stories')),
    );
    final learningSize = tester.getSize(
      find.byKey(const Key('gateway.learning')),
    );
    expect(cartoonSize.height, greaterThan(storySize.height));
    expect(storySize.height, greaterThan(learningSize.height));
  });

  testWidgets('gateway stays overflow-free on a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AppGatewayScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
  });

  testWidgets('cartoon hub screen renders cartoon sections and categories', (tester) async {
    GameData.resetForTesting();

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CartoonHubScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('کارتون‌کده فندقی'), findsOneWidget);
    expect(find.text('همه کارتون‌ها'), findsOneWidget);
  });

  testWidgets('about screen exposes the supplied publisher details', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    expect(find.text(AppLegal.developerName), findsOneWidget);
    expect(find.text(AppLegal.supportEmail), findsOneWidget);
    expect(find.text(AppLegal.telegramHandle), findsOneWidget);
  });
}
