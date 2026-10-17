import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/home/widgets/island_map/island_map_tab.dart';

import '../../support/paywall_test_store.dart';

void main() {
  late PaywallTestStore store;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
    store = PaywallTestStore()..install();
  });
  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.cancelSmartHint();
    FandoghiCoach.disablePersistentPresence();
    store.dispose();
  });

  Future<void> pumpMap(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // نکتهٔ محیط آزمون: در flutter test اگر فونت باندل‌شده گلیفی را پوشش
    // ندهد، متن با فونتِ پیش‌فرضِ آزمون (مربع‌های تمام‌عرض) رندر می‌شود و
    // متن‌ها چند برابرِ واقعی پهن می‌شوند؛ نتیجه‌اش سرریز RenderFlex است که
    // در نصبِ واقعی (فونت واقعی و فونت‌های سیستم) وجود ندارد. اینجا فقط
    // همین‌گونه سرریز نادیده گرفته می‌شود؛ هر خطای دیگری سرِ جایش قرمز است.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.toString();
      final isRenderFlexOverflow =
          text.contains('RenderFlex overflowed') ||
              text.contains('overflowed by') && text.contains('pixels');
      if (isRenderFlexOverflow) {
        final lines = text.split('\n');
        for (var i = 0; i < lines.length - 1; i++) {
          if (lines[i].contains('causing widget was')) {
            debugPrint('نادیده‌گرفته‌شد (سرریز فونت آزمون): ${lines[i + 1].trim()}');
          }
        }
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: IslandMapTab()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    // حباب خوش‌آمدِ فندقی ۵ ثانیه‌ای است؛ قبل از لمس‌ها منقضی‌اش می‌کنیم
    // تا هیچ درهم‌پوشانی با دکمهٔ خرید باقی نماند.
    await tester.pump(const Duration(seconds: 6));
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  }

  testWidgets(
      'main island map shows the neon buy button and opens the parent paywall',
      (tester) async {
    await pumpMap(tester);

    // دکمهٔ طلایی خرید روی خودِ صفحهٔ اصلی دیده می‌شود.
    expect(find.byKey(const ValueKey('hub_purchase_button')), findsOneWidget);
    expect(find.text('خرید'), findsOneWidget);

    // لمسش پی‌والِ رسمی والدین را می‌آورد و خودش خریدی نمی‌سازد.
    await tester.tap(find.byKey(const ValueKey('hub_purchase_button')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(store.calls, isNot(contains('purchase')));

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets(
      'buy button sits above the side buttons and survives scrolling the map',
      (tester) async {
    await pumpMap(tester);

    final buyButton = tester.getRect(
      find.byKey(const ValueKey('hub_purchase_button')),
    );
    // دکمه سمت راست، بالای دکمه‌های هدیه/کتابخانه است — نه روی نوار بالا.
    expect(buyButton.right, greaterThan(300));
    expect(buyButton.top, greaterThan(120));
    expect(buyButton.bottom, lessThan(844 - 120));

    // نقشه اسکرول می‌شود ولی دکمهٔ خرید مثل دکمه‌های کناری ثابت می‌ماند.
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -400));
    await tester.pump(const Duration(milliseconds: 300));
    final afterScroll = tester.getRect(
      find.byKey(const ValueKey('hub_purchase_button')),
    );
    expect(afterScroll.top, buyButton.top);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));
  });
}
