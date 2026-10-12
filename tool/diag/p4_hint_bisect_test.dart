// TEMPORARY diagnostic harness — deleted before the final build.
//
// P4: the real MiniGameScaffold with the time advanced one second at a time.
// Every step is written to diag-logs/p4-progress.log (uploaded as an artifact
// by the workflow) so the last line survives even when the test hangs.
//  P4a: hint is empty — the pulse + rebuild only.
//  P4b: real hint text — pulse + rebuild + coach toast.
import 'dart:io';

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

final List<String> _trace = <String>[];

/// چاپ + نوشتن هم‌زمان در فایل: خروجی print یک تستِ معلق تا پایان تست به لاگ
/// نمی‌رسد، ولی این فایل بلافاصله روی دیسک می‌نشیند و همراه artifact آپلود
/// می‌شود (پس آخرین خطش معلوم می‌کند کار در کدام مرحله قفل شده است).
void step(String tag, String message) {
  final line = '[DIAG $tag] $message';
  _trace.add(line);
  print(line);
  try {
    const path = 'diag-logs/p4-progress.log';
    final file = File(path);
    if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
    file.writeAsStringSync('${_trace.join('\n')}\n');
  } catch (_) {
    // فقط تشخیصی — اگر نوشتن نشد (مثلاً روی دستگاه) اهمیتی ندارد
  }
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
  step('mount', 'pumpWidget begin');
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
  step('mount', 'pumpWidget done');
  await tester.pump(const Duration(milliseconds: 100));
  step('mount', 'first pump done');
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
