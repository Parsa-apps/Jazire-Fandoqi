import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/games/alphabet_academy/alphabet_academy_game.dart';
import 'package:jazireh_fandoghi/features/games/math/tally_marks_game.dart';
import 'package:jazireh_fandoghi/features/games/math/place_value_game.dart';
import 'package:jazireh_fandoghi/features/games/math/number_line_game.dart';
import 'package:jazireh_fandoghi/features/games/math/symmetry_game.dart';
import 'package:jazireh_fandoghi/features/games/math/ten_frame_game.dart';
import 'package:jazireh_fandoghi/features/games/math/compare_crocodile_game.dart';
import 'package:jazireh_fandoghi/features/games/math/clock_hour_game.dart';
import 'package:jazireh_fandoghi/features/games/math/add_subtract_game.dart';
import 'package:jazireh_fandoghi/features/games/alphabet_academy/dictation_game.dart';
import 'package:jazireh_fandoghi/shared/widgets/handwriting_score_overlay.dart';

Future<void> _disposeAnimatedTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  FandoghiCoach.cancelSmartHint();
  FandoghiCoach.disablePersistentPresence();
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  setUp(() {
    GameData.resetForTesting();
  });

  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('AlphabetAcademyGame renders Grade 1 mode and letters', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AlphabetAcademyGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('آکادمی الفبا و اول دبستان 🔤'), findsOneWidget);
    expect(find.text('کتاب اول دبستان 📚'), findsOneWidget);
    expect(find.text('الفبایی سنتی 🔤'), findsOneWidget);
    expect(find.textContaining('اول صدا، هجا و کلمه را بشنو'), findsOneWidget);
    expect(find.byKey(const ValueKey('literacy_step_0')), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('TallyMarksGame renders target and action button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TallyMarksGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('بازی چوب‌خط اول دبستان 🥢'), findsOneWidget);
    expect(find.text('چوب‌خط بکش 🥢 (+۱)'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('PlaceValueGame renders place value columns', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlaceValueGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('جدول ارزش مکانی 🧮'), findsOneWidget);
    expect(find.text('ده‌تایی‌ها (۱۰)'), findsOneWidget);
    expect(find.text('یکی‌ها (۱)'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('NumberLineGame renders jumping number line', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NumberLineGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('محور اعداد جهنده 🐸'), findsOneWidget);
    expect(find.text('جهش به جلو (+۱)'), findsOneWidget);
    expect(find.text('جهش به عقب (-۱)'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('TenFrameGame renders classroom ten-frame', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TenFrameGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('قاب ده‌تایی 🟥'), findsOneWidget);
    expect(find.textContaining('هدف: عدد'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('CompareCrocodileGame renders compare choices', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CompareCrocodileGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('تمساح بزرگ‌تر و کوچک‌تر 🐊'), findsOneWidget);
    expect(find.textContaining('مساوی'), findsOneWidget);
    expect(find.textContaining('عدد سمت چپ بزرگ‌تر است'), findsOneWidget);
    expect(find.textContaining('عدد سمت راست بزرگ‌تر است'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('AddSubtractGame shows first-grade addition', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddSubtractGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('جمع و تفریق تا ۲۰ ➕'), findsOneWidget);
    expect(find.textContaining('= ؟'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('ClockHourGame asks the hour', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ClockHourGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('ساعت کامل 🕐'), findsOneWidget);
    expect(find.text('ساعت چند است؟'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('HandwritingScoreOverlay shows mastery count and sentence', (tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HandwritingScoreOverlay(
              score: 0.9,
              letter: 'ب',
              passed: true,
              masteryCount: 2,
              sentence: 'بابا آب داد.',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('قبولی'), findsWidgets);
    expect(find.textContaining('بابا آب داد.'), findsWidgets);
    expect(find.textContaining('جمله'), findsWidgets);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('AlphabetDictationGame starts with listen prompt', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AlphabetDictationGame(words: ['آب', 'بابا', 'سیب']),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('کدام کلمه را شنیدی؟'), findsOneWidget);
    expect(find.text('دوباره بشنو'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });

  testWidgets('SymmetryGame renders symmetry grid and red line', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SymmetryGame(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('بازی تقارن اول دبستان 🦋'), findsOneWidget);

    await _disposeAnimatedTree(tester);
  });
}
