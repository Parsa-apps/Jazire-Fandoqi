// TEMPORARY diagnostic harness — deleted before the final build.
//
// H2a (first, expected to pass): the real hint with the time advanced in one
// second steps — the shape the fixed mini_game_scaffold_test now uses.
// H2b (last, expected to hang if a single long elapse is the culprit): the
// same round with one 11s elapse.
//
// Whichever test is running when the log stops is the one that hangs, so this
// file pins down whether slicing the pump is enough.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_models.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_scaffold.dart';

void note(String tag, String message) {
  final escaped = message
      .replaceAll('%', '%25')
      .replaceAll('\r', '%0D')
      .replaceAll('\n', '%0A');
  print('::error title=DIAG $tag::$escaped');
}

MiniGameSpec spec() => const MiniGameSpec(
      title: 'بازی آزمایشی 🧪',
      gameId: 'بازی آزمایشی',
      skill: 'logic',
      missionId: 'logic',
      gradient: AppGradients.primary,
      introCoach: 'سلام! شروع کنیم',
      rewardCoach: 'تمام شد!',
      rounds: 1,
    );

List<MiniGameRound> rounds() => <MiniGameRound>[
      MiniGameRound(
        prompt: '۱ + ۱ چند می‌شود؟',
        scene: '🧪',
        options: [
          MiniGameOption('۲', correct: true),
          MiniGameOption('۳'),
        ],
        hint: 'دوتا یکی دیگه اضافه کن',
      ),
    ];

Future<void> pumpGame(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      home: MiniGameScaffold(spec: spec(), roundFactory: rounds),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUp(GameData.resetForTesting);

  tearDown(FandoghiCoach.clear);

  testWidgets('DIAG-H2a: real hint — eleven one-second pumps',
      (tester) async {
    await pumpGame(tester);
    for (var i = 0; i < 11; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    final hintWidgets = find.text('دوتا یکی دیگه اضافه کن').evaluate().length;
    note('H2a', 'eleven 1s pumps finished; hint text widgets=$hintWidgets');
  });

  testWidgets('DIAG-H2b: real hint — one 11s elapse', (tester) async {
    await pumpGame(tester);
    note('H2b', 'before 11s elapse (real hint)');
    await tester.pump(const Duration(seconds: 11));
    note('H2b', 'after 11s elapse (real hint)');
  });
}
