// TEMPORARY diagnostic harness — deleted before the final build.
//
// P4: the real MiniGameScaffold, with the time advanced one second at a time and
// a note printed before each pump, so the log pinpoints the exact second that
// hangs.
//  P4a: hint is empty (FandoghiCoach.say returns immediately) — the pulse alone.
//  P4b: real hint text — pulse + toast + character.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MiniGameScaffold(
        spec: spec(),
        roundFactory: () => roundsWith(hint),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> slices(WidgetTester tester, String tag) async {
  for (var i = 1; i <= 11; i++) {
    note(tag, 'pump #$i begin');
    await tester.pump(const Duration(seconds: 1));
    note(tag, 'pump #$i done');
  }
}

void main() {
  setUp(GameData.resetForTesting);

  tearDown(FandoghiCoach.clear);

  testWidgets('DIAG-P4a: empty hint — second-by-second pumps',
      (tester) async {
    await pumpGame(tester, '');
    await slices(tester, 'P4a');
    note('P4a', 'finished — OK');
  });

  testWidgets('DIAG-P4b: real hint — second-by-second pumps',
      (tester) async {
    await pumpGame(tester, 'دوتا یکی دیگه اضافه کن');
    await slices(tester, 'P4b');
    final hintWidgets = find.text('دوتا یکی دیگه اضافه کن').evaluate().length;
    note('P4b', 'finished — OK; hint text widgets=$hintWidgets');
  });
}
