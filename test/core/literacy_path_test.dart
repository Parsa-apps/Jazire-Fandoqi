import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/literacy/handwriting_eval.dart';
import 'package:jazireh_fandoghi/core/literacy/literacy_path.dart';

void main() {
  test('literacy path is sound then syllable then word then sentence', () {
    final unit = LiteracyUnit.forLesson('ب', 'بابا');
    expect(unit.syllable, 'با');
    expect(unit.word, 'بابا');
    expect(unit.sentence, contains('بابا'));
    expect(unit.soundHint, contains('ب'));
  });

  test('او and ای are not reduced to bare alef', () {
    expect(LiteracyUnit.firstLetter('او و'), 'او');
    expect(LiteracyUnit.firstLetter('ایـ ی'), 'ای');
    expect(LiteracyUnit.forLesson('او و', 'توت').letter, 'او');
    expect(LiteracyUnit.forLesson('ایـ ی', 'ایران').letter, 'ای');
    expect(HandwritingEval.familyOf('او و'), 'و');
    expect(HandwritingEval.familyOf('ایـ ی'), 'ی');
    expect(HandwritingEval.familyOf('خوا'), 'خ');
  });

  test('bundle sentences only use letters the child has met', () {
    expect(LiteracyUnit.forLesson('آ ا', 'آب').sentence, 'بابا آب داد.');
    expect(LiteracyUnit.forLesson('ظ', 'ظرف').sentence, contains('ظرف'));
  });

  test('spaced review waits 1 then 3 then 7 days', () {
    expect(AlphabetReview.gapDaysFor(1), 1);
    expect(AlphabetReview.gapDaysFor(2), 3);
    expect(AlphabetReview.gapDaysFor(3), 7);
    expect(
      AlphabetReview.isDue(passCount: 1, lastDay: '2026-08-16', today: '2026-08-16'),
      isFalse,
    );
    expect(
      AlphabetReview.isDue(passCount: 1, lastDay: '2026-08-16', today: '2026-08-17'),
      isTrue,
    );
    expect(
      AlphabetReview.isDue(passCount: 3, lastDay: '2026-08-16', today: '2026-08-18'),
      isFalse,
    );
    expect(
      AlphabetReview.isDue(passCount: 3, lastDay: '2026-08-16', today: '2026-08-23'),
      isTrue,
    );
  });

  test('handwriting rejects a tap and a stroke that ignores the green dot', () {
    const start = Offset(200, 40);
    final tooShort = <Offset>[const Offset(200, 40), const Offset(202, 42)];
    final short = HandwritingEval.evaluate(
      letter: 'ب',
      points: tooShort,
      start: start,
      baselineY: 180,
    );
    expect(short.passed, isFalse);
    expect(short.failReason, contains('کوتاه'));

    final away = List<Offset>.generate(
      20,
      (i) => Offset(20.0 + i, 160.0),
    );
    final missedStart = HandwritingEval.evaluate(
      letter: 'ب',
      points: away,
      start: start,
      baselineY: 180,
    );
    expect(missedStart.startedAtDot, isFalse);
    expect(missedStart.failReason, contains('نقطه سبز'));
  });

  test('a scribble far from the demo path is rejected when a guide is given', () {
    const start = Offset(220, 80);
    final demo = <Offset>[
      const Offset(220, 80),
      const Offset(140, 100),
      const Offset(80, 160),
    ];
    final scribble = List<Offset>.generate(24, (i) {
      return Offset(20.0 + i * 2.0, 20.0);
    });
    final result = HandwritingEval.evaluate(
      letter: 'ب',
      points: scribble,
      start: start,
      baselineY: 160,
      demoPath: demo,
    );
    expect(result.startedAtDot, isFalse);
    expect(result.followsPath, isFalse);
    expect(result.passed, isFalse);
  });

  test('a right-to-left stroke from the green dot can pass geometry for ب', () {
    const start = Offset(220, 80);
    final points = List<Offset>.generate(24, (i) {
      return Offset(220 - i * 6.0, 80 + i * 3.5);
    });
    final result = HandwritingEval.evaluate(
      letter: 'ب',
      points: points,
      start: start,
      baselineY: 160,
    );
    expect(result.longEnough, isTrue);
    expect(result.startedAtDot, isTrue);
    expect(result.directionOk, isTrue);
    expect(result.sitsOnBaseline, isTrue);
    expect(result.passed, isTrue);
  });

  test('three accepted writes make a letter fluent and schedule review', () {
    GameData.resetForTesting();
    expect(GameData.recordAlphabetPass('g1-0-0', today: '2026-08-16'), 1);
    expect(GameData.isAlphabetMastered('g1-0-0'), isTrue);
    expect(GameData.isAlphabetFluent('g1-0-0'), isFalse);
    expect(GameData.recordAlphabetPass('g1-0-0', today: '2026-08-16'), 2);
    expect(GameData.recordAlphabetPass('g1-0-0', today: '2026-08-16'), 3);
    expect(GameData.isAlphabetFluent('g1-0-0'), isTrue);
    expect(GameData.isAlphabetDueForReview('g1-0-0', today: '2026-08-17'), isFalse);
    expect(GameData.isAlphabetDueForReview('g1-0-0', today: '2026-08-23'), isTrue);
    expect(GameData.dueAlphabetReviewKeys(today: '2026-08-23'), ['g1-0-0']);
  });

  test('writing stays locked until sound, syllable and word are heard in order', () {
    final ladder = LiteracyLadder();
    expect(ladder.canWrite, isFalse);
    expect(ladder.hear(LiteracyLadder.word), isFalse);
    expect(ladder.hear(LiteracyLadder.sound), isTrue);
    expect(ladder.canWrite, isFalse);
    expect(ladder.hear(LiteracyLadder.word), isFalse);
    expect(ladder.hear(LiteracyLadder.syllable), isTrue);
    expect(ladder.hear(LiteracyLadder.word), isTrue);
    expect(ladder.canWrite, isTrue);
    expect(ladder.finished, isFalse);
    expect(ladder.hear(LiteracyLadder.sentence), isTrue);
    expect(ladder.finished, isTrue);
    expect(LiteracyUnit.firstLetter('او و'), 'او');
  });

  test('dictation words come from the literacy path, never empty or emoji', () {
    final words = LiteracyUnit.dictationWords();
    expect(words.length, greaterThanOrEqualTo(8));
    expect(words, contains('بابا'));
    expect(words, contains('سیب'));
    expect(words.every((w) => w.length >= 2), isTrue);
    expect(words.every((w) => !w.contains('🍎')), isTrue);
  });
}
