import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/ai_system.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';

void main() {
  setUp(() {
    GameData.resetForTesting();
  });

  test('adaptiveLevel gets harder after 3 correct, easier after 2 wrong', () {
    expect(AI.adaptiveLevel(), AI.difficulty());
    expect(AI.adaptiveLevel(recentCorrect: 3), greaterThanOrEqualTo(2));
    // با successRate پایین، difficulty=1 است؛ غلط → نباید زیر ۱ برود
    expect(AI.adaptiveLevel(recentWrong: 2), greaterThanOrEqualTo(1));
  });

  test('weakSkill is honest when the child has not practiced', () {
    expect(AI.hasAnyPractice, isFalse);
    expect(AI.weakSkill(), 'هنوز تمرینی ثبت نشده');
    expect(AI.weakSkillKey(), 'alphabet');
    expect(AI.predictOneMonth()['ریاضی'], 0);
  });

  test('weakSkill returns a skill name after real answers', () {
    GameData.recordAnswer(correct: true, skill: 'math');
    expect(AI.weakSkill(), isNotEmpty);
    expect(AI.skillNames.containsKey(AI.weakSkillKey()), isTrue);
  });

  test('suggestGames returns exactly 3 distinct games', () {
    final games = AI.suggestGames();
    expect(games.length, 3);
    expect(games.toSet().length, 3, reason: 'پیشنهادها نباید تکراری باشند');
  });

  test('buddyReply is rule-based, kind and never empty', () {
    expect(AI.buddyReply('سلام', childName: 'آرش'), contains('آرش'));
    expect(AI.buddyReply('خستم', childName: ''), isNotEmpty);
    expect(AI.buddyReply('هر چیزی', childName: 'سارا'), contains('سارا'));
  });

  test('encouragementAfterMistakes escalates kindly, never blames', () {
    expect(AI.encouragementAfterMistakes(0), isEmpty);
    expect(AI.encouragementAfterMistakes(2), contains('آسون‌تر'));
    expect(AI.encouragementAfterMistakes(3), contains('نفس عمیق'));
  });

  test('masteryOf starts near 0.5 for untouched skills', () {
    expect(AI.masteryOf('math'), closeTo(0.5, 0.05));
  });

  test('every skill maps to a suggested game (دور ۱۰)', () {
    // همه ۱۷ مهارت باید بازی پیشنهادی داشته باشند
    for (final skill in AI.skillNames.keys) {
      expect(AI.suggestGames(), isNotEmpty, reason: 'skill: $skill');
    }
    // پیشنهادها همیشه ۳ بازی متمایز برمی‌گردانند
    for (var i = 0; i < 10; i++) {
      final games = AI.suggestGames();
      expect(games.length, 3);
      expect(games.toSet().length, 3);
    }
  });
}
