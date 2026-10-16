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

  testWidgets('unpaid hub chip is a visible buy button that opens the paywall',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('خرید'), findsOneWidget);
    expect(find.byType(AnimatedGoldLock), findsOneWidget);

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

  testWidgets('after a verified purchase the chip flips to فعال and stops selling',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('خرید'), findsOneWidget);

    store.purchaseResponse = PaywallTestStore.verifiedPurchase;
    expect(await Monetization.purchaseFullVersion(), isTrue);
    await tester.pump();

    expect(find.text('فعال'), findsOneWidget);
    expect(find.text('خرید'), findsNothing);
    expect(find.byType(AnimatedGoldLock), findsNothing);

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
