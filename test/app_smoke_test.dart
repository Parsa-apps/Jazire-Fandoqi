import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:amoozesh_fandoghi/core/app_legal.dart';
import 'package:amoozesh_fandoghi/core/game_data.dart';
import 'package:amoozesh_fandoghi/features/about/about_screen.dart';
import 'package:amoozesh_fandoghi/features/cartoons/cartoon_hub_screen.dart';
import 'package:amoozesh_fandoghi/features/gateway/app_gateway_screen.dart';
import 'package:amoozesh_fandoghi/features/home/home_screen.dart';

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

  testWidgets('gateway screen renders dual portals for cartoons and learning', (tester) async {
    GameData.resetForTesting();
    GameData.onboardingSeen = true;

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AppGatewayScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('کارتون‌کده و سینما'), findsOneWidget);
    expect(find.text('دنیای بازی و آموزش'), findsOneWidget);
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
