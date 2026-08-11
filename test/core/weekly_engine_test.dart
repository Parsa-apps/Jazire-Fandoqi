import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/core/growth/weekly_engine.dart';

void main() {
  setUp(() {
    GameData.resetForTesting();
    GrowthStore.resetForTesting();
  });

  test('weekly challenge is stable within the same week', () {
    final first = WeeklyEngine.currentChallenge();
    final second = WeeklyEngine.currentChallenge();
    expect(first.id, second.id);
  });

  test('progress only counts matching kinds and caps at target', () {
    final challenge = WeeklyEngine.currentChallenge();
    GrowthStore.weeklyChallengeProgress = 0;

    // یک دسته اشتباه نباید پیشرفت ایجاد کند.
    WeeklyEngine.progress('definitely-not-a-kind');
    expect(GrowthStore.weeklyChallengeProgress, 0);

    final kind = switch (challenge.id) {
      'life5' => 'life',
      'story3' => 'story',
      'alpha10' => 'alphabet',
      'learn40' => 'learn_minute',
      _ => 'correct',
    };
    WeeklyEngine.progress(kind, amount: challenge.target + 5);
    expect(GrowthStore.weeklyChallengeProgress, challenge.target);
    expect(WeeklyEngine.challengeDone, isTrue);
    expect(WeeklyEngine.challengeRatio, 1.0);
  });

  test('last7Days returns seven labeled rows', () {
    final rows = WeeklyEngine.last7Days();
    expect(rows.length, 7);
    for (final row in rows) {
      expect(row.$1, isNotEmpty);
      expect(row.$2, greaterThanOrEqualTo(0));
      expect(row.$3, greaterThanOrEqualTo(0));
      expect(row.$3, lessThanOrEqualTo(row.$2));
    }
  });

  test('learning chest needs 15 minutes and one claim per day', () {
    GrowthStore.learningChestMinutes = 0;
    expect(WeeklyEngine.canClaimLearningChest, isFalse);

    GrowthStore.learningChestMinutes = 15;
    expect(WeeklyEngine.canClaimLearningChest, isTrue);

    final coinsBefore = GameData.coins;
    expect(WeeklyEngine.claimLearningChest(), isTrue);
    expect(GameData.coins, coinsBefore + 15);
    expect(WeeklyEngine.claimLearningChest(), isFalse);
  });

  test('parent digest mentions learning minutes and never a network target', () {
    final digest = WeeklyEngine.buildParentDigest();
    expect(digest, contains('گزارش هفتگی جزیره فندقی'));
    expect(digest, contains('یادگیری'));
    expect(digest.contains('http'), isFalse);
  });
}
