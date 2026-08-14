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
    expect(find.text('حروف و صداها'), findsOneWidget);
    expect(find.text('علوم'), findsOneWidget);
    expect(find.text('بازی‌ها'), findsOneWidget);
    expect(find.text('هنر و خلاقیت'), findsOneWidget);

    // نوار ناوبری پایینی
    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('دستاوردها'), findsOneWidget);
    expect(find.text('کوله‌پشتی'), findsOneWidget);
    expect(find.text('کارنامه'), findsOneWidget);
    expect(find.text('داستان'), findsOneWidget);

    // دکمه‌های شناور کناری
    expect(find.text('هدایا'), findsOneWidget);
    expect(find.text('جزیره'), findsOneWidget);
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
  });

  testWidgets('gateway stays overflow-free on a narrow phone', (tester) async {
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
