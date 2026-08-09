import 'package:flutter_test/flutter_test.dart';

import 'package:amoozesh_fandoghi/core/ai_system.dart';
import 'package:amoozesh_fandoghi/core/game_data.dart';

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

  // ─────────── فاز ۴۰: جزیره‌سازی ───────────
  test('island decorations cost coins and persist per slot', () {
    GameData.coins = 20;
    expect(GameData.placeDecoration('s0-0', 'palm'), isTrue);
    expect(GameData.coins, 15);
    expect(GameData.islandDecorations['s0-0'], 'palm');

    // همان اسلات دوباره نمی‌شود
    expect(GameData.placeDecoration('s0-0', 'house'), isFalse);
    // بدون سکه کافی
    GameData.coins = 2;
    expect(GameData.placeDecoration('s1-1', 'star'), isFalse);

    GameData.removeDecoration('s0-0');
    expect(GameData.islandDecorations.containsKey('s0-0'), isFalse);
  });

  // ─────────── فاز ۵۲: مأموریت‌های جدید ───────────
  test('math and memory missions progress correctly', () {
    GameData.progressMission('math', amount: 3);
    expect(GameData.isMissionDone('math'), isTrue);
    GameData.progressMission('memory');
    expect(GameData.isMissionDone('memory'), isFalse);
    GameData.progressMission('memory');
    expect(GameData.isMissionDone('memory'), isTrue);
  });

  // ─────────── فاز ۷: مقیاس فونت ───────────
  test('textScale clamps to the accessible range', () {
    GameData.setTextScale(2.0);
    expect(GameData.textScale, 1.4);
    GameData.setTextScale(0.5);
    expect(GameData.textScale, 0.85);
  });

  // ─────────── فاز ۱۶: چپ‌دست ───────────
  test('left-handed preference persists', () {
    GameData.setLeftHanded(true);
    expect(GameData.isLeftHanded, isTrue);
  });

  // ─────────── فاز ۸۵: استرس ذخیره‌سازی ───────────
  test('500 rapid answers never exceed caps and stay stable', () {
    for (var i = 0; i < 500; i++) {
      GameData.recordAnswer(correct: true, skill: 'counting');
      GameData.addCoins(1);
    }
    expect(GameData.totalCorrect, 500);
    expect(GameData.coins, 500);
    expect(GameData.skills['counting'], 500);
    expect(GameData.level, greaterThanOrEqualTo(5));
  });
}

  // ─────────── فاز ۲۹: پاداش یک‌بار داستان (ضد farming) ───────────
  test('story reward is granted only once per story', () {
    expect(GameData.hasCompletedStory('helpful_rabbit'), isFalse);
    expect(GameData.markStoryCompleted('helpful_rabbit'), isTrue);
    expect(GameData.hasCompletedStory('helpful_rabbit'), isTrue);
    // بار دوم نباید پاداش بدهد
    expect(GameData.markStoryCompleted('helpful_rabbit'), isFalse);
  });
}
