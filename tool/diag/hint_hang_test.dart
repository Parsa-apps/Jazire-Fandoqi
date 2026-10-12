// TEMPORARY diagnostic harness — deleted before the final build.
//
// The real "Hint ظریف" test file hangs forever after the 10s idle hint fires.
// This harness pumps the same flow in small steps and reports after each one so
// the log shows exactly where it stops (the hang itself is last, so the earlier
// findings are already published).
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

const _spec = MiniGameSpec(
  title: 'بازی آزمایشی 🧪',
  gameId: 'بازی آزمایشی',
  skill: 'logic',
  missionId: 'logic',
  gradient: AppGradients.primary,
  introCoach: 'سلام! شروع کنیم',
  rewardCoach: 'تمام شد!',
  rounds: 3,
);

List<MiniGameRound> _fixedRounds() => <MiniGameRound>[
      MiniGameRound(
        prompt: '۱ + ۱ چند می‌شود؟',
        scene: '🧪',
        options: [
          MiniGameOption('۲', correct: true),
          MiniGameOption('۳'),
        ],
        hint: 'دوتا یکی دیگه اضافه کن',
      ),
      MiniGameRound(
        prompt: 'کدام میوه است؟',
        scene: '🍽️',
        options: [
          MiniGameOption('🍌', correct: true),
          MiniGameOption('🐱'),
        ],
        hint: 'زرد و خوشمزه!',
      ),
      MiniGameRound(
        prompt: 'همهٔ میوه‌ها را بگذار داخل سبد',
        scene: '🧺',
        options: [
          MiniGameOption('🍎', correct: true),
          MiniGameOption('🍌', correct: true),
          MiniGameOption('🐶'),
        ],
        hint: 'سیب و موز میوه‌اند',
        multiSelect: true,
      ),
    ];

Future<void> pumpGame(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      home: MiniGameScaffold(spec: _spec, roundFactory: _fixedRounds),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUp(GameData.resetForTesting);

  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('DIAG-C1: idle for 9 seconds (hint not yet due)', (tester) async {
    await pumpGame(tester);
    note('C1', 'mounted; pumping 9s');
    await tester.pump(const Duration(seconds: 9));
    note('C1', '9s pump finished; hint text shown=' 
        '${find.text('دوتا یکی دیگه اضافه کن').evaluate().length}');
  });

  testWidgets('DIAG-C2: idle past 10s (hint fires)', (tester) async {
    await pumpGame(tester);
    note('C2', 'mounted; pumping 10.5s');
    await tester.pump(const Duration(milliseconds: 10500));
    note('C2', '10.5s pump finished; coach=${FandoghiCoach.current.value?.text}');
    await tester.pump(const Duration(milliseconds: 500));
    note('C2', 'extra 0.5s pump finished');
  });

  testWidgets('DIAG-C3: hint blocked by a solved round', (tester) async {
    await pumpGame(tester);
    await tester.tap(find.text('۲'));
    await tester.pump(const Duration(milliseconds: 400));
    note('C3', 'round 1 solved; pumping 11s');
    await tester.pump(const Duration(seconds: 11));
    note('C3', '11s pump finished after solving (hint timer was re-armed)');
  });
}
