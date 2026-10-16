import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/children_stories_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/lullabies_data.dart';
import 'package:jazireh_fandoghi/core/monetization.dart';
import 'package:jazireh_fandoghi/features/cartoons/cartoon_hub_screen.dart';
import 'package:jazireh_fandoghi/features/lullabies/lullaby_hub_screen.dart';
import 'package:jazireh_fandoghi/features/stories/stories_hub_screen.dart';
import 'package:jazireh_fandoghi/shared/widgets/animated_gold_lock.dart';

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

  final collections = [
    (
      prefix: 'story',
      total: ChildrenStoriesData.allStories.length,
      screen: const StoriesHubScreen(),
    ),
    (
      prefix: 'lullaby',
      total: LullabiesData.all.length,
      screen: const LullabyHubScreen(),
    ),
    (
      prefix: 'cartoon',
      total: CartoonData.allCartoons.length,
      screen: const CartoonHubScreen(),
    ),
  ];

  for (final collection in collections) {
    testWidgets(
        '${collection.prefix}: only the paid half has gold locks; verified purchase removes them',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(home: collection.screen));
      await tester.pump(const Duration(milliseconds: 600));
      final freeCount = collection.total ~/ 2;
      expect(find.byType(AnimatedGoldLock),
          findsNWidgets(collection.total - freeCount));
      for (var i = 0; i < collection.total; i++) {
        final platform = find.byKey(
          ValueKey('${collection.prefix}_platform_$i'),
        );
        expect(platform, findsOneWidget);
        expect(
          find.descendant(
            of: platform,
            matching: find.byType(AnimatedGoldLock),
          ),
          i < freeCount ? findsNothing : findsOneWidget,
          reason: 'platform $i must match the half-free policy',
        );
      }
      expect(tester.takeException(), isNull);

      // Only the explicit verified native-store fixture may grant access.
      store.purchaseResponse = PaywallTestStore.verifiedPurchase;
      expect(await Monetization.purchaseFullVersion(), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(MaterialApp(home: collection.screen));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(AnimatedGoldLock), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
