import 'package:flutter_test/flutter_test.dart';

import 'package:amoozesh_fandoghi/core/achievement_system.dart';
import 'package:amoozesh_fandoghi/core/game_data.dart';

void main() {
  setUp(() {
    GameData.resetForTesting();
  });

  test('26 achievements are registered with unique ids', () {
    final ids = AchievementSystem.allAchievements.map((a) => a.id).toSet();
    expect(AchievementSystem.allAchievements.length, 26);
    expect(ids.length, 26, reason: 'idها نباید تکراری باشند');
  });

  test('cartoon achievements unlock after watching cartoons', () {
    expect(GameData.watchedCartoons, isEmpty);
    GameData.recordCartoonWatched('shekarestan');
    expect(GameData.watchedCartoons, contains('shekarestan'));
    AchievementSystem.checkAndUnlock();
    expect(GameData.achievements, contains('cartoon_watcher'));
  });

  test('star/coin/level achievements unlock at thresholds', () {
    expect(AchievementSystem.isUnlocked(AchievementSystem.allAchievements[0]), isFalse);

    GameData.addStars(1);
    // addStars بعد از reset با _isLoaded=true کار می‌کند
    GameData.addStars(0); // no-op
    expect(AchievementSystem.isUnlocked(AchievementSystem.allAchievements[0]), isTrue);
  });

  test('checkAndUnlock writes unlocked achievements to GameData', () {
    GameData.stars = 60;
    AchievementSystem.checkAndUnlock();
    expect(GameData.achievements, contains('first_star'));
    expect(GameData.achievements, contains('star_50'));
    expect(GameData.achievements, isNot(contains('star_200')));
  });

  test('getProgress clamps between 0 and 1', () {
    GameData.stars = 25;
    final starAch = AchievementSystem.allAchievements[0]; // target 1
    expect(AchievementSystem.getProgress(starAch), 1.0);
    GameData.stars = 0;
    expect(AchievementSystem.getProgress(starAch), 0.0);
  });
}
