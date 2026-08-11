import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/games/puzzle/puzzle_game.dart';

void main() {
  setUp(GameData.resetForTesting);

  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('puzzle offers the four child-friendly piece sizes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PuzzleGame()),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('پازل جادویی 🧩'), findsOneWidget);
    expect(find.text('4 تکه'), findsOneWidget);
    expect(find.text('6 تکه'), findsOneWidget);
    expect(find.text('9 تکه'), findsOneWidget);
    expect(find.text('12 تکه'), findsOneWidget);
  });

  testWidgets('changing the size resets progress without leaving the game',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PuzzleGame()),
    );
    await tester.pump();

    await tester.tap(find.text('9 تکه'));
    await tester.pump();

    expect(find.text('0/9'), findsOneWidget);
    expect(find.text('پازل جادویی 🧩'), findsOneWidget);
  });
}
