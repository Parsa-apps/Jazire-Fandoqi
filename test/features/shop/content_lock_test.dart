import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/billing_service.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/core/learning_content/learning_topics.dart';
import 'package:jazireh_fandoghi/core/monetization.dart';
import 'package:jazireh_fandoghi/features/games/academy/academy_game.dart';
import 'package:jazireh_fandoghi/features/games/alphabet_academy/alphabet_academy_game.dart';
import 'package:jazireh_fandoghi/features/games/alphabet_academy/dictation_game.dart';
import 'package:jazireh_fandoghi/features/games/body_parts/body_parts_game.dart';
import 'package:jazireh_fandoghi/features/jobs/jobs_hub_screen.dart';
import 'package:jazireh_fandoghi/features/shop/content_lock.dart';
import 'package:jazireh_fandoghi/features/shop/game_access_gate.dart';
import 'package:jazireh_fandoghi/features/stage_map/stage_map_screen.dart';
import 'package:jazireh_fandoghi/features/stage_map/widgets/premium_stage_node.dart';
import 'package:jazireh_fandoghi/shared/widgets/magnetic_drag.dart';

import '../../support/paywall_test_store.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}

Future<void> _open(WidgetTester tester, Widget child,
    {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    home: Directionality(textDirection: TextDirection.rtl, child: child),
  ));
  await _pump(tester);
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  FandoghiCoach.clear();
  FandoghiCoach.cancelSmartHint();
  FandoghiCoach.disablePersistentPresence();
  await tester.pump(const Duration(seconds: 6));
}

Future<void> _buy(WidgetTester tester) async {
  final button = find.text('خرید نسخه کامل');
  await tester.ensureVisible(button);
  await _pump(tester);
  await tester.tap(button);
  await _pump(tester);
  await _pump(tester);
}

void main() {
  late PaywallTestStore store;
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
    GrowthStore.resetForTesting();
    GameData.soundEnabled = false;
    store = PaywallTestStore()..install();
  });
  tearDown(() {
    store.dispose();
    FandoghiCoach.clear();
    FandoghiCoach.cancelSmartHint();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('a locked destination never constructs or mounts its premium child', (tester) async {
    var mounts = 0;
    var builds = 0;
    await _open(tester, GameAccessGate.lazy(
      gameName: 'حافظه',
      childBuilder: () {
        builds++;
        return _Probe(onMounted: () => mounts++);
      },
    ));
    expect(builds, 0);
    expect(mounts, 0);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(await Monetization.hasFullVersion(), isFalse);
    await _dispose(tester);
  });

  testWidgets('an item cannot borrow a free game entitlement by matching its title',
      (tester) async {
    var mounts = 0;
    await _open(tester, GameAccessGate(
      gameName: 'اعداد', // A free game name, but NOT a free content item.
      isFree: false,
      child: _Probe(onMounted: () => mounts++),
    ));
    expect(mounts, 0);
    await _dispose(tester);
  });

  testWidgets('a verified purchaser can enter a premium destination', (tester) async {
    await Monetization.activateFullVersion(const BillingResult(
      success: true, purchaseToken: 'verified-test-receipt'));
    var mounts = 0;
    var builds = 0;
    await _open(tester, GameAccessGate.lazy(
      gameName: 'حافظه',
      childBuilder: () {
        builds++;
        return _Probe(onMounted: () => mounts++);
      },
    ));
    await _pump(tester);
    expect(builds, 1);
    expect(mounts, 1);
    await _dispose(tester);
  });

  testWidgets('a progression-unlocked paid stage still shows and enforces its payment lock',
      (tester) async {
    GameData.currentStage = 6; // The memory game, independent of progression.
    await _open(tester, const ProviderScope(child: StageMapScreen()));
    final sixth = find.byKey(const ValueKey('stage_payment_lock_6'));
    expect(tester.widget<LockedCardOverlay>(sixth).locked, isTrue);
    // The map has a fixed top bar. Align the node below it, not at y=0.
    await Scrollable.ensureVisible(tester.element(sixth), alignment: 0.4);
    await _pump(tester);
    final node = find.descendant(of: sixth, matching: find.byType(PremiumStageNode));
    expect(node.hitTestable(), findsOneWidget);
    await tester.tap(node.hitTestable());
    await _pump(tester);
    expect(find.text('خرید نسخه کامل'), findsOneWidget);
    expect(GameData.currentStage, 6);
    await _dispose(tester);
  });

  testWidgets('alphabet shows four paid bundles and their tap opens the paywall',
      (tester) async {
    await _open(tester, const AlphabetAcademyGame());
    final locks = tester.widgetList<LockedCardOverlay>(find.byType(LockedCardOverlay));
    expect(locks.where((overlay) => overlay.locked).length, 4);
    final fifthBundle = find.byKey(const ValueKey('alphabet_bundle_4'));
    await tester.ensureVisible(fifthBundle);
    await _pump(tester);
    await tester.tap(fifthBundle);
    await _pump(tester);
    expect(find.text('خرید نسخه کامل'), findsOneWidget);
    // Closing the paywall is not a purchase.
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await _pump(tester);
    expect(await Monetization.hasFullVersion(), isFalse);
    expect(tester.widgetList<LockedCardOverlay>(find.byType(LockedCardOverlay))
        .where((overlay) => overlay.locked).length, 4);
    await _dispose(tester);
  });

  testWidgets('alphabet search cannot make a late letter free or play its lesson',
      (tester) async {
    await _open(tester, const AlphabetAcademyGame());
    await tester.tap(find.text('الفبایی سنتی 🔤'));
    await _pump(tester);
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'یخ');
    await _pump(tester);
    final letter = find.byKey(const ValueKey('alphabet_letter_ی'));
    await tester.ensureVisible(letter);
    await _pump(tester);
    await tester.tap(letter);
    await _pump(tester);
    expect(find.text('خرید نسخه کامل'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await _pump(tester);
    // The lesson's audio ladder must be gated too, not just its picker.
    final sound = find.byKey(const ValueKey('literacy_step_0'));
    await tester.ensureVisible(sound);
    await _pump(tester);
    await tester.tap(sound);
    await _pump(tester);
    expect(find.text('خرید نسخه کامل'), findsOneWidget);
    expect(await Monetization.hasFullVersion(), isFalse);
    await _dispose(tester);
  });

  testWidgets('body game has three playable parts and three real locks', (tester) async {
    await _open(tester, const BodyPartsGame());
    expect(find.byType(MagneticDraggable), findsNWidgets(3));
    expect(tester.widgetList<LockedCardOverlay>(find.byType(LockedCardOverlay))
        .where((overlay) => overlay.locked).length, 3);
    final locked = find.byKey(const ValueKey('body_part_locked_3'));
    await tester.ensureVisible(locked);
    await tester.tap(locked);
    await _pump(tester);
    expect(find.text('خرید نسخه کامل'), findsOneWidget);
    expect(find.byKey(const ValueKey('body_part_target_3')), findsNothing);
    await _dispose(tester);
  });

  testWidgets('successful payment removes body locks immediately', (tester) async {
    GameData.parentUnlockedThisSession = true;
    store.purchaseResponse = PaywallTestStore.verifiedPurchase;
    await _open(tester, const BodyPartsGame());
    await tester.tap(find.byKey(const ValueKey('content_access_notice')));
    await _pump(tester);
    await _buy(tester);
    expect(await Monetization.hasFullVersion(), isTrue);
    expect(find.byKey(const ValueKey('content_access_notice')), findsNothing);
    expect(find.byType(MagneticDraggable), findsNWidgets(6));
    expect(find.byKey(const ValueKey('body_part_locked_3')), findsNothing);
    expect(tester.takeException(), isNull);
    await _dispose(tester);
  });

  testWidgets('cancelled payment leaves the body game locked', (tester) async {
    GameData.parentUnlockedThisSession = true; // Parent approval is not payment.
    await _open(tester, const BodyPartsGame());
    await tester.tap(find.byKey(const ValueKey('content_access_notice')));
    await _pump(tester);
    await _buy(tester);
    expect(find.text('پرداخت کامل نشد'), findsOneWidget);
    expect(await Monetization.hasFullVersion(), isFalse);
    expect(find.byType(MagneticDraggable), findsNWidgets(3));
    await _dispose(tester);
  });

  testWidgets('a paid job does not record progress without payment', (tester) async {
    final jobs = learningTopicById('jobs')!;
    final firstPaid = jobs.cards[jobs.cards.length ~/ 2];
    await _open(tester, const JobsHubScreen());
    final item = find.byKey(ValueKey('job_${firstPaid.id}'));
    await tester.scrollUntilVisible(item, 250,
        scrollable: find.byType(Scrollable).last);
    await _pump(tester);
    await tester.tap(item);
    await _pump(tester);
    expect(find.text('خرید نسخه کامل'), findsOneWidget);
    expect(GameData.skills['jobs'] ?? 0, 0);
    await _dispose(tester);
  });

  testWidgets('academy visibly explains its lock and excludes paid answers', (tester) async {
    final colors = learningTopicById('colors')!;
    await _open(tester, const AcademyGame(topicId: 'colors'),
        size: const Size(320, 640));
    expect(find.textContaining('۶ از ۱۲ رایگان؛ ۶ مورد قفل است'), findsOneWidget);
    for (final card in colors.cards.skip(colors.cards.length ~/ 2)) {
      expect(find.text(card.name), findsNothing, reason: card.name);
    }
    expect(tester.takeException(), isNull);
    await _dispose(tester);
  });

  testWidgets('dictation cannot pull a paid word into answers as a fallback', (tester) async {
    await _open(tester, const AlphabetDictationGame(
      words: ['آب', 'بابا', 'سیب', 'ایران'],
    ), size: const Size(320, 640));
    expect(find.textContaining('۲ از ۴ رایگان؛ ۲ مورد قفل است'), findsOneWidget);
    expect(find.text('سیب'), findsNothing);
    expect(find.text('ایران'), findsNothing);
    expect(find.text('آب'), findsOneWidget);
    expect(find.text('بابا'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _dispose(tester);
  });
}

class _Probe extends StatefulWidget {
  const _Probe({required this.onMounted});
  final VoidCallback onMounted;
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.onMounted();
  }
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('premium content'));
}
