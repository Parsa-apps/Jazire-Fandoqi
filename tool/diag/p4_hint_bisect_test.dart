// TEMPORARY diagnostic harness — deleted before the final build.
//
// P4: the real MiniGameScaffold with the time advanced one second at a time.
// Every step is a *plain* print (not a workflow command) so the chunked log
// annotations keep working; the last line of the log therefore shows exactly
// which second never finished.
//  P4a: hint is empty — the pulse + rebuild only.
//  P4b: real hint text — pulse + rebuild + coach toast.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_models.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_scaffold.dart';

void step(String tag, String message) => print('[DIAG $tag] $message');

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

String where(WidgetTester tester) {
  final animate = find.byType(Animate).evaluate().length;
  final tickers = tester.binding.transientCallbackCount;
  final text = FandoghiCoach.current.value?.text ?? '(none)';
  return 'animate=$animate tickers=$tickers coach=$text';
}

Future<void> slices(WidgetTester tester, String tag) async {
  for (var i = 1; i <= 12; i++) {
    step(tag, 'pump #$i begin — before: ${where(tester)}');
    await tester.pump(const Duration(seconds: 1));
    step(tag, 'pump #$i done  — after:  ${where(tester)}');
  }
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
  });

  tearDown(FandoghiCoach.clear);

  testWidgets('DIAG-P4a: empty hint — second-by-second pumps', (tester) async {
    await pumpGame(tester, '');
    await slices(tester, 'P4a');
    step('P4a', 'finished — OK');
  });

  testWidgets('DIAG-P4b: real hint — second-by-second pumps', (tester) async {
    await pumpGame(tester, 'دوتا یکی دیگه اضافه کن');
    await slices(tester, 'P4b');
    step('P4b', 'finished — OK');
  });
}
