import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/tutorial/app_tutorial_screen.dart';

/// Advances past an animation that is started by the interaction just before
/// it. The first tick of a freshly started controller is zero-length, so a
/// single `pump(700ms)` would leave the page transition standing on page 1.
Future<void> settleSlide(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
  });

  testWidgets('tutorial cannot be dismissed before its final slide',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const AppTutorialScreen(),
        routes: {
          '/gateway': (_) => const Scaffold(body: Text('جزیره')),
          '/gateway-first-entry': (_) =>
              const Scaffold(body: Text('جزیره')),
        },
      ),
    );

    expect(find.text('به جزیره فندقی خوش آمدی'), findsOneWidget);
    expect(find.byKey(const ValueKey('tutorial_finish')), findsNothing);

    // Android/system back is deliberately blocked while the walkthrough runs.
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AppTutorialScreen), findsOneWidget);

    // Skip means "jump to the final choice", not exit the tutorial.
    await tester.tap(find.byKey(const ValueKey('tutorial_skip')));
    await settleSlide(tester);
    expect(find.text('ماجراجویی را شروع کن!'), findsOneWidget);
    expect(find.byKey(const ValueKey('tutorial_finish')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('finishing tutorial always suppresses future walkthroughs',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const AppTutorialScreen(),
        routes: {
          '/gateway': (_) => const Scaffold(body: Text('جزیره')),
          '/gateway-first-entry': (_) =>
              const Scaffold(body: Text('جزیره')),
        },
      ),
    );

    // Skip to final slide and finish
    await tester.tap(find.byKey(const ValueKey('tutorial_skip')));
    await settleSlide(tester);
    await tester.tap(find.byKey(const ValueKey('tutorial_finish')));
    await tester.pumpAndSettle();

    expect(GameData.tutorialDoNotShow, isTrue);
    expect(GameData.onboardingSeen, isTrue);
    expect(find.text('جزیره'), findsOneWidget);
  });

  testWidgets('tutorial has exactly 2 slides', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const AppTutorialScreen(),
        routes: {
          '/gateway': (_) => const Scaffold(body: Text('جزیره')),
          '/gateway-first-entry': (_) =>
              const Scaffold(body: Text('جزیره')),
        },
      ),
    );

    // First slide shows "1 از 2"
    expect(find.text('1 از 2'), findsOneWidget);
    expect(find.text('به جزیره فندقی خوش آمدی'), findsOneWidget);

    // Go to next slide
    await tester.tap(find.byKey(const ValueKey('tutorial_next')));
    await settleSlide(tester);

    // Second slide shows "2 از 2" and is the final slide
    expect(find.text('2 از 2'), findsOneWidget);
    expect(find.text('ماجراجویی را شروع کن!'), findsOneWidget);
    expect(find.byKey(const ValueKey('tutorial_finish')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
