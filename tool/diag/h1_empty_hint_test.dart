// TEMPORARY diagnostic harness — deleted before the final build.
//
// H1: the 10s hint timer fires, but the hint text is empty, so FandoghiCoach.say
// returns immediately and the only visible change is the hint pulse on the
// correct option. If this hangs, the timer + pulse is the problem; if it
// completes, the `say()` call is required for the hang.
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

List<MiniGameRound> roundsWith(String hint) => <MiniGameRound>[
      MiniGameRound(
        prompt: '۱ + ۱ چند می‌شود؟',
        scene: '🧪',
        options: [
          MiniGameOption('۲', correct: true),
          MiniGameOption('۳'),
        ],
        hint: hint,
      ),
    ];

Future<void> pumpGame(WidgetTester tester, String hint) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      home: MiniGameScaffold(
        spec: spec(),
        roundFactory: () => roundsWith(hint),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUp(GameData.resetForTesting);

  tearDown(FandoghiCoach.clear);

  testWidgets('DIAG-H1: empty hint text — one 11s elapse across the timer',
      (tester) async {
    await pumpGame(tester, '');
    note('H1', 'before 11s elapse (empty hint)');
    await tester.pump(const Duration(seconds: 11));
    note('H1', 'after 11s elapse (empty hint)');
  });
}
