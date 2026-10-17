import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/monetization.dart';
import 'package:jazireh_fandoghi/features/shop/hub_purchase_button.dart';
import 'package:jazireh_fandoghi/shared/widgets/animated_gold_lock.dart';

import '../../support/paywall_test_store.dart';

void main() {
  late PaywallTestStore store;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
    store = PaywallTestStore()..install();
  });
  tearDown(() => store.dispose());

  Widget host() => MaterialApp(
        home: Scaffold(
          body: const Center(child: HubPurchaseChip()),
        ),
      );

  final haloBoxFinder = find.byWidgetPredicate(
    (w) =>
        w is DecoratedBox &&
        w.decoration is BoxDecoration &&
        ((w.decoration as BoxDecoration).boxShadow ?? const []).isNotEmpty,
  );

  testWidgets('unpaid hub chip is a visible buy button with a neon halo',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('خرید'), findsOneWidget);
    expect(find.byType(AnimatedGoldLock), findsOneWidget);
    // هالهٔ نئونی تا وقتی خرید تأیید نشده دور دکمه می‌درخشد.
    expect(haloBoxFinder, findsOneWidget);

    // تنفّس هاله نباید کل دکمه را هر فریم بازسازی کند؛ درخشش جلوی دکمه
    // نمی‌آید و لمس همان دکمه است.
    final glowBefore = tester.widget<DecoratedBox>(haloBoxFinder);
    await tester.pump(const Duration(milliseconds: 400));
    final glowMid = tester.widget<DecoratedBox>(haloBoxFinder);
    expect(
      (glowMid.decoration as BoxDecoration).boxShadow!.first.color,
      isNot(
        (glowBefore.decoration as BoxDecoration).boxShadow!.first.color,
      ),
      reason: 'هالهٔ نئونی باید آرام نفس بکشد (تغییر رنگ/شدت در طول زمان)',
    );

    // بازکردنِ مسیر خرید خودش خریدی نمی‌سازد.
    await tester.tap(find.byKey(const ValueKey('hub_purchase_button')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(store.calls, isNot(contains('purchase')));

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(BottomSheet), findsNothing);
    expect(await Monetization.hasFullVersion(), isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('after a verified purchase the halo turns off and the chip stops selling',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('خرید'), findsOneWidget);
    expect(haloBoxFinder, findsOneWidget);

    store.purchaseResponse = PaywallTestStore.verifiedPurchase;
    expect(await Monetization.purchaseFullVersion(), isTrue);
    await tester.pump();

    expect(find.text('فعال'), findsOneWidget);
    expect(find.text('خرید'), findsNothing);
    expect(find.byType(AnimatedGoldLock), findsNothing);
    // بعد از خرید تأییدشده، هالهٔ نئونی خاموش می‌شود؛ دکمهٔ سبز آرام است.
    expect(haloBoxFinder, findsNothing);

    // نسخهٔ کامل فعال است؛ لمسِ دکمه نباید پی‌وال یا خریدِ تازه‌ای بسازد.
    final callsBefore = store.calls.length;
    await tester.tap(find.byKey(const ValueKey('hub_purchase_button')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BottomSheet), findsNothing);
    expect(store.calls.length, callsBefore);
    expect(await Monetization.hasFullVersion(), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
