// TEMPORARY diagnostic harness — deleted before the final build.
//
// Investigates why the mini-game multi-select flow cannot find the
// "گذاشتم! ۲ تا 🧺" submit button: missed taps (hit-test) or a different count?
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/app/app_colors.dart';
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
  rounds: 1,
);

/// Only the multi-select round, so the flow is reachable in one step.
List<MiniGameRound> _multiSelectOnly() => <MiniGameRound>[
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

String _submitLabel(WidgetTester tester) {
  final texts = tester
      .widgetList<Text>(find.byType(Text))
      .map((w) => w.data ?? '')
      .where((d) => d.contains('گذاشتم') || d.contains('اول انتخاب'))
      .toList();
  return texts.isEmpty ? '(not found)' : texts.join(' | ');
}

String _labels(WidgetTester tester, List<String> wanted) {
  final found = tester
      .widgetList<Text>(find.byType(Text))
      .map((w) => w.data ?? '')
      .where(wanted.contains)
      .toList();
  return found.isEmpty ? '(none of $wanted)' : found.join(', ');
}

void main() {
  setUp(() {
    GameData.resetForTesting();
    // Any tap that cannot hit its widget becomes a hard failure with details.
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  testWidgets('DIAG-B1: multi-select picks and submit label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa')],
        home: MiniGameScaffold(spec: _spec, roundFactory: _multiSelectOnly),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    note('B1', 'initial submit label: ${_submitLabel(tester)}');
    note(
      'B1',
      'option emojis present: ${_labels(tester, ['🍎', '🍌', '🐶'])}',
    );

    for (final emoji in ['🍎', '🐶']) {
      final finder = find.text(emoji);
      final center = tester.getCenter(finder);
      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 200));
      note(
        'B1',
        'tapped $emoji at ${center.dx.toStringAsFixed(1)},'
        '${center.dy.toStringAsFixed(1)} -> ${_submitLabel(tester)}',
      );
    }

    note('B1', 'final submit label: ${_submitLabel(tester)}');
  });

  testWidgets('DIAG-B2: option hit test in a 800x600 viewport', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa')],
        home: MiniGameScaffold(spec: _spec, roundFactory: _multiSelectOnly),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    for (final emoji in ['🍎', '🍌', '🐶']) {
      final finder = find.text(emoji);
      final center = tester.getCenter(finder);
      final hit = tester.hitTestOnBinding(center);
      final hitPath = hit.path
          .map((entry) => entry.target.runtimeType.toString())
          .take(4)
          .join(' > ');
      note(
        'B2',
        '$emoji center=${center.dx.toStringAsFixed(1)},'
        '${center.dy.toStringAsFixed(1)} hitPath=$hitPath',
      );
    }
    note('B2', 'viewport=${tester.view.physicalSize} dpr=${tester.view.devicePixelRatio}');
  });
}
