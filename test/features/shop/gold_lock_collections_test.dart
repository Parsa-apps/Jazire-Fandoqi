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
import 'package:jazireh_fandoghi/features/games/mini_games/games_carnival_screen.dart';
import 'package:jazireh_fandoghi/features/shop/game_access_gate.dart';
import 'package:jazireh_fandoghi/shared/widgets/child_touch_target.dart';
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
        '${collection.prefix}: a stale local grant must not hide the paid-half locks',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      store.values.addAll(<String, String>{
        'entitlement.granted': 'true',
        'entitlement.receipt_token': 'previous-placeholder-receipt',
      });
      store.offline = true;

      await tester.pumpWidget(MaterialApp(home: collection.screen));
      await tester.pump(const Duration(milliseconds: 600));
      // ۲ قفلِ غیرِسکو متعلق به مسیر خریدِ همیشه‌نویدبار است: چیپ طلایی
      // «خرید» نوار بالا + کارت خرید پایین صفحه. قفلِ سکوها همان نیمهٔ پولی
      // می‌ماند و این تست حضورِ راه خرید را هم گارت می‌کند.
      const entryLocks = 2;
      expect(
        find.byKey(const ValueKey('hub_purchase_button')),
        findsOneWidget,
        reason: 'دکمهٔ خرید نسخهٔ کامل باید در هاب دیده شود',
      );
      expect(
        find.byKey(const ValueKey('full_version_purchase_entry')),
        findsOneWidget,
        reason: 'کارت خرید نسخهٔ کامل باید پایین هاب دیده شود',
      );
      expect(find.byType(AnimatedGoldLock),
          findsNWidgets(collection.total - collection.total ~/ 2 + entryLocks));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

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
      // قفل‌های دو مسیر خرید همیشه‌نویدبار (چیپ بالا + کارت پایین) جمع می‌شوند؛
      // گارتِ دقیقِ نیمهٔ پولی، پایین‌تر روی تک‌تک سکوها اعمال می‌شود.
      const entryLocks = 2;
      expect(find.byType(AnimatedGoldLock),
          findsNWidgets(collection.total - freeCount + entryLocks));
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
      await tester.pump();
      expect(find.byType(AnimatedGoldLock), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(MaterialApp(home: collection.screen));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(AnimatedGoldLock), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('carnival keeps word builder locked with a stale local grant',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.values.addAll(<String, String>{
      'entitlement.granted': 'true',
      'entitlement.receipt_token': 'previous-placeholder-receipt',
    });
    store.offline = true;
    var paidGameBuilds = 0;
    await tester.pumpWidget(MaterialApp(
      home: const GamesCarnivalScreen(),
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => GameAccessGate.lazy(
          gameName: 'کلمه‌ساز',
          isFree: false,
          childBuilder: () {
            paidGameBuilds++;
            return const Scaffold(body: Text('PAID_GAME_CONTENT'));
          },
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    const expectedLocks = {
      'حرف اول': false,
      'کلمه‌ساز': true,
      'شمارش خوش': false,
      'جمع تصویری': true,
      'بزرگ و کوچک': false,
      'جورچین شکل‌ها': true,
      'ترکیب رنگ': true,
      'ترتیب اعداد': false,
      'متفاوت را پیدا کن': false,
      'سبد دسته‌بندی': true,
    };
    for (final entry in expectedLocks.entries) {
      await tester.scrollUntilVisible(find.text(entry.key), 220,
          scrollable: find.byType(Scrollable).last);
      await tester.pump(const Duration(milliseconds: 50));
      final card = find.ancestor(
        of: find.text(entry.key),
        matching: find.byType(ChildTouchTarget),
      );
      expect(find.descendant(
        of: card,
        matching: find.byType(AnimatedGoldLock),
      ), entry.value ? findsOneWidget : findsNothing, reason: entry.key);
    }
    await tester.scrollUntilVisible(find.text('کلمه‌ساز'), -220,
        scrollable: find.byType(Scrollable).last);
    await tester.pump(const Duration(milliseconds: 200));
    final wordBuilder = find.ancestor(
      of: find.text('کلمه‌ساز'),
      matching: find.byType(ChildTouchTarget),
    );
    expect(wordBuilder, findsOneWidget);
    expect(find.descendant(
      of: wordBuilder,
      matching: find.byType(AnimatedGoldLock),
    ), findsOneWidget);
    // Text visibility alone can leave the card centre behind the fixed XP
    // header. Centre the actual hit target and require a real pointer hit.
    await Scrollable.ensureVisible(tester.element(wordBuilder), alignment: 0.5);
    await tester.pump(const Duration(milliseconds: 200));
    expect(wordBuilder.hitTestable(), findsOneWidget);
    await tester.tap(wordBuilder.hitTestable());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(paidGameBuilds, 0);
    expect(find.text('PAID_GAME_CONTENT'), findsNothing);
    expect(find.byType(GameAccessGate), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
