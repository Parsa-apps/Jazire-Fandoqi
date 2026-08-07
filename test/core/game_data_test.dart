import 'package:flutter_test/flutter_test.dart';

import 'package:kudakeiran/core/ai_system.dart';
import 'package:kudakeiran/core/game_data.dart';

void main() {
  setUp(() {
    GameData.resetForTesting();
  });

  test('answer tracking updates missions, skills and success rate', () {
    for (var i = 0; i < 5; i++) {
      GameData.recordAnswer(correct: true, skill: 'alphabet');
    }
    GameData.recordAnswer(correct: false, skill: 'alphabet');

    expect(GameData.totalCorrect, 5);
    expect(GameData.totalWrong, 1);
    expect(GameData.missionValue('questions'), 5);
    expect(GameData.dailyMissions, 1);
    expect(GameData.skills['alphabet'], 6);
    expect(GameData.successRate, closeTo(5 / 6, 0.0001));
  });

  test('stage rewards are idempotent and advance the next stage', () {
    expect(
      GameData.completeStage('stage_1', stageNumber: 1),
      isTrue,
    );
    expect(GameData.currentStage, 2);
    expect(GameData.stars, 3);
    expect(GameData.prizeBoxTokens, 1);

    expect(
      GameData.completeStage('stage_1', stageNumber: 1),
      isFalse,
    );
    expect(GameData.stars, 3);
    expect(GameData.prizeBoxTokens, 1);
  });

  test('time limit reports the remaining play time', () {
    GameData.setTimeLimitMinutes(15);
    GameData.addPlayTime(seconds: 14 * 60 + 59);
    expect(GameData.isDailyLimitReached, isFalse);
    expect(GameData.remainingPlaySeconds, 1);

    GameData.addPlayTime();
    expect(GameData.isDailyLimitReached, isTrue);
    expect(GameData.remainingPlaySeconds, 0);
  });

  test('AI difficulty uses the current success rate', () {
    expect(AI.difficulty(), 1);
    for (var i = 0; i < 9; i++) {
      GameData.recordAnswer(correct: true);
    }
    expect(AI.difficulty(), 3);
    expect(AI.weakSkill(), isNotEmpty);
  });
}
