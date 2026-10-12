// TEMPORARY diagnostic harness — deleted before the final build.
//
// P7: mount the real MiniGameScaffold with one piece removed at a time, always
// stopping the frame pipeline at EnginePhase.build (the phase where the hang
// was observed). Each attempt writes its result to diag-logs/p7-progress.log:
// a "PASS" line means that mount completed, a hanging mount simply never writes
// its line — so the last line names the last configuration that worked.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_models.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_scaffold.dart';

final List<String> _trace = <String>[];

void step(String message) {
  _trace.add(message);
  print('[P7] $message');
  try {
    final file = File('diag-logs/p7-progress.log');
    if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
    file.writeAsStringSync('${_trace.join('\n')}\n');
  } catch (_) {}
}

Widget realScaffold() => MiniGameScaffold(
      spec: const MiniGameSpec(
        title: 'بازی آزمایشی 🧪',
        gameId: 'بازی آزمایشی',
        skill: 'logic',
        missionId: 'logic',
        gradient: AppGradients.primary,
        introCoach: 'سلام! شروع کنیم',
        rewardCoach: 'تمام شد!',
        rounds: 1,
      ),
      roundFactory: () => <MiniGameRound>[
        MiniGameRound(
          prompt: '۱ + ۱ چند می‌شود؟',
          scene: '🧪',
          options: [
            MiniGameOption('۲', correct: true),
            MiniGameOption('۳'),
          ],
          hint: 'دوتا یکی دیگه اضافه کن',
        ),
      ],
    );

Widget host(Widget child) => MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );

/// The failing configuration is last, so every earlier configuration still runs.
const List<List<String>> _attempts = <List<String>>[
  ['options'],
  ['card'],
  ['pulse'],
  ['touch'],
  ['scene'],
  ['sceneAnimate'],
  ['header'],
  ['prompt'],
  ['roundLabel'],
  <String>['sceneAnimate', 'card', 'header'], // everything decorative at once
  <String>[], // control — expected to hang
];

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    diagSkipPieces = <String>{};
    GameData.resetForTesting();
  });

  tearDown(FandoghiCoach.clear);

  for (var i = 0; i < _attempts.length; i++) {
    final skip = _attempts[i];
    final label = skip.isEmpty ? 'control' : skip.join('+');
    testWidgets('P7-$i skip=$label', (tester) async {
      diagSkipPieces = skip.toSet();
      step('attempt $i ($label): begin');
      await tester.pumpWidget(host(realScaffold()), phase: EnginePhase.build);
      step('attempt $i ($label): mounted OK');
      await tester.pump(const Duration(milliseconds: 100), EnginePhase.build);
      step('attempt $i ($label): PASS');
    });
  }
}
