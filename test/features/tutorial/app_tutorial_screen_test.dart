import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/tutorial/app_tutorial_screen.dart';

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

    expect(find.text('من فندقی‌ام؛ راهنمای همیشگی تو'), findsOneWidget);
    expect(find.byKey(const ValueKey('tutorial_finish')), findsNothing);

    // Android/system back is deliberately blocked while the walkthrough runs.
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AppTutorialScreen), findsOneWidget);

    // Skip means "jump to the final choice", not exit the tutorial.
    await tester.tap(find.byKey(const ValueKey('tutorial_skip')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('فندقی همیشه کنار تو می‌ماند'), findsOneWidget);
    expect(find.byKey(const ValueKey('tutorial_finish')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('checked final choice suppresses future walkthroughs',
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

    await tester.tap(find.byKey(const ValueKey('tutorial_skip')));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.byKey(const ValueKey('tutorial_do_not_show')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tutorial_finish')));
    await tester.pumpAndSettle();

    expect(GameData.tutorialDoNotShow, isTrue);
    expect(find.text('جزیره'), findsOneWidget);
  });

  testWidgets('unchecked final choice keeps replay enabled', (tester) async {
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

    await tester.tap(find.byKey(const ValueKey('tutorial_skip')));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.byKey(const ValueKey('tutorial_finish')));
    await tester.pumpAndSettle();

    expect(GameData.tutorialDoNotShow, isFalse);
    expect(find.text('جزیره'), findsOneWidget);
  });
}
