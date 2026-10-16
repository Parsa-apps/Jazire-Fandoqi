import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/monetization.dart';
import 'package:jazireh_fandoghi/features/shop/full_version_purchase_entry.dart';
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

  Widget host({bool compact = false}) => MaterialApp(
        home: Scaffold(
          body: Center(child: FullVersionPurchaseEntry(compact: compact)),
        ),
      );

  testWidgets('unpaid map entry shows a lock and opens the real paywall',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(compact: true));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('خرید نسخه کامل'), findsOneWidget);
    expect(find.text('نیمه رایگان • بقیه قفل'), findsOneWidget);
    expect(find.byType(AnimatedGoldLock), findsOneWidget);
    expect(store.calls, isNot(contains('purchase')));

    await tester.tap(find.byKey(const ValueKey('full_version_purchase_entry')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(store.calls, isNot(contains('purchase')),
        reason: 'بازشدن پنجره یا لمسِ قفل، خودش نباید خرید بسازد');

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(AnimatedGoldLock), findsOneWidget);
    expect(await Monetization.hasFullVersion(), isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('entry reacts to verified purchase and revocation without reopening',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('خرید نسخه کامل'), findsOneWidget);
    expect(find.byType(AnimatedGoldLock), findsOneWidget);

    store.purchaseResponse = PaywallTestStore.verifiedPurchase;
    expect(await Monetization.purchaseFullVersion(), isTrue);
    await tester.pump();
    expect(find.text('نسخه کامل فعال است'), findsOneWidget);
    expect(find.byType(AnimatedGoldLock), findsNothing);

    store.restoreResponse = PaywallTestStore.notOwned;
    expect(await Monetization.hasFullVersion(), isFalse);
    await tester.pump();
    expect(find.text('خرید نسخه کامل'), findsOneWidget);
    expect(find.byType(AnimatedGoldLock), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('map, parent home and support expose the purchase entry', () {
    for (final path in <String>[
      'lib/features/home/widgets/island_map/island_map_tab.dart',
      'lib/features/parent/tabs/parent_home_tab.dart',
      'lib/features/about/about_screen.dart',
    ]) {
      expect(File(path).readAsStringSync(), contains('FullVersionPurchaseEntry('),
          reason: path);
    }
  });
}
