// TEMPORARY diagnostic harness — deleted before the final build.
//
// Narrow down (a) the exact pump that hangs once the 10s idle hint fires and
// (b) the real geometry of the multi-select options in the test viewport.
// Tests that are expected to hang are last, so the earlier findings are already
// published when the watchdog kills the run.
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

MiniGameSpec spec({required int rounds}) => MiniGameSpec(
      title: 'بازی آزمایشی 🧪',
      gameId: 'بازی آزمایشی',
      skill: 'logic',
      missionId: 'logic',
      gradient: AppGradients.primary,
      introCoach: 'سلام! شروع کنیم',
      rewardCoach: 'تمام شد!',
      rounds: rounds,
    );

List<MiniGameRound> multiSelectOnly({String hint = 'سیب و موز میوه‌اند'}) =>
    <MiniGameRound>[
      MiniGameRound(
        prompt: 'همهٔ میوه‌ها را بگذار داخل سبد',
        scene: '🧺',
        options: [
          MiniGameOption('🍎', correct: true),
          MiniGameOption('🍌', correct: true),
          MiniGameOption('🐶'),
        ],
        hint: hint,
        multiSelect: true,
      ),
    ];

List<MiniGameRound> firstRoundOnly() => <MiniGameRound>[
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

Future<void> pump(WidgetTester tester, List<MiniGameRound> rounds) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      home: MiniGameScaffold(
        spec: spec(rounds: rounds.length),
        roundFactory: () => rounds,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

String rect(WidgetTester tester, Finder finder) {
  final r = tester.getRect(finder);
  return 'L${r.left.round()} T${r.top.round()} '
      'R${r.right.round()} B${r.bottom.round()}';
}

void main() {
  setUp(GameData.resetForTesting);

  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('DIAG-D5: geometry of the multi-select round', (tester) async {
    await pump(tester, multiSelectOnly());
    note('D5', 'screen=${tester.view.physicalSize / tester.view.devicePixelRatio}');
    note('D5', 'wrap=${rect(tester, find.byType(Wrap))}');
    for (final emoji in ['🍎', '🍌', '🐶']) {
      note('D5', '$emoji ${rect(tester, find.text(emoji))}');
    }
    note(
      'D5',
      'scrollviews=${tester.widgetList(find.byType(Scrollable)).length} '
      'firstScroll=${rect(tester, find.byType(Scrollable).first)}',
    );
    note('D5', 'submit=${rect(tester, find.textContaining('انتخاب کن!'))}');
  });

  testWidgets('DIAG-D2: FandoghiCoach.say directly, then a short pump',
      (tester) async {
    await pump(tester, firstRoundOnly());
    note('D2', 'calling say');
    FandoghiCoach.say('دوتا یکی دیگه اضافه کن');
    note('D2', 'say returned; pumping 0.1s');
    await tester.pump(const Duration(milliseconds: 100));
    note('D2', 'short pump finished; coach=${FandoghiCoach.current.value?.text}');
  });

  testWidgets('DIAG-D4: empty hint text (coach silent) + 11s pump',
      (tester) async {
    await pump(tester, multiSelectOnly(hint: ''));
    note('D4', 'pumping 11s with an empty hint');
    await tester.pump(const Duration(seconds: 11));
    note('D4', '11s pump finished');
  });


  testWidgets('DIAG-D1: fine-grained pumps across the 10s hint',
      (tester) async {
    await pump(tester, firstRoundOnly());
    note('D1', 'pumping 9.5s');
    await tester.pump(const Duration(milliseconds: 9500));
    note('D1', '9.5s done; pumping 0.4s more');
    await tester.pump(const Duration(milliseconds: 400));
    note('D1', 'crossed 10s; pumping 0.1s more');
    await tester.pump(const Duration(milliseconds: 100));
    note('D1', 'done; hint text widgets=' 
        '${find.text('دوتا یکی دیگه اضافه کن').evaluate().length}');
  });

  testWidgets('DIAG-D3: 1s slices up to 12s', (tester) async {
    await pump(tester, firstRoundOnly());
    for (var i = 1; i <= 12; i++) {
      await tester.pump(const Duration(seconds: 1));
      note('D3', 'pump $i s finished');
    }
  });
}
