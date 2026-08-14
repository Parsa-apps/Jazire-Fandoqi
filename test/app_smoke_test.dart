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
import 'package:jazireh_fandoghi/features/profile/profile_editor.dart';

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

    final cartoon = find.text('کارتون');
    final stories = find.text('داستان');
    final learning = find.text('بازی و یادگیری');

    expect(cartoon, findsOneWidget);
    expect(stories, findsOneWidget);
    expect(learning, findsOneWidget);
    expect(find.text('لالایی‌های شب'), findsOneWidget);
    expect(find.text('پروفایل من'), findsOneWidget);
    expect(find.text('درباره ما'), findsOneWidget);
    expect(find.textContaining('کتابخانه یادگیری'), findsOneWidget);

    // کارتون و داستان روی یک ردیف‌اند؛ بازی و یادگیری زیر آن‌هاست.
    expect(
      tester.getTopLeft(cartoon).dy,
      closeTo(tester.getTopLeft(stories).dy, 24),
    );
    expect(
      tester.getTopLeft(cartoon).dy,
      lessThan(tester.getTopLeft(learning).dy),
    );
    expect(find.byKey(const Key('gateway.cartoon')), findsOneWidget);
    expect(find.byKey(const Key('gateway.stories')), findsOneWidget);
    expect(find.byKey(const Key('gateway.learning')), findsOneWidget);
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

  testWidgets('profile editor exposes a stable gallery action', (tester) async {
    GameData.resetForTesting();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showProfileEditor(context),
              child: const Text('ویرایش'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ویرایش'));
    await tester.pumpAndSettle();

    expect(find.text('ویرایش پروفایل'), findsOneWidget);
    expect(find.text('انتخاب از گالری'), findsOneWidget);
    expect(find.text('ذخیره تغییرات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('about screen mirrors the public Parsa Apps page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.pump();

    expect(find.text('درباره پارسا اپس'), findsOneWidget);
    expect(find.text(AppLegal.developerName), findsOneWidget);
    expect(find.text('🎯 ماموریت ما'), findsOneWidget);
    expect(find.text('💡 چرا پارسا اپس؟'), findsOneWidget);
    expect(find.text('🚀 اپلیکیشن‌های در راه انتشار'), findsOneWidget);
    expect(find.text('باغ الفبا'), findsOneWidget);
    expect(find.text('نگارخانه فندقی'), findsOneWidget);
    expect(find.text('📬 ارتباط مستقیم با مدیریت'), findsOneWidget);
    expect(find.text('تلگرام'), findsOneWidget);
    expect(find.text('ایمیل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
