import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/achievement_system.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/core/xp_system.dart';
import 'package:jazireh_fandoghi/data/datasources/hive_player_store.dart';

void main() {
  setUp(() {
    GameData.resetForTesting();
  });

  group('XpSystem ریاضیات خالص', () {
    test('سطح ۱ رایگان است و آستانه‌ها با فرمول ۲۵·n·(n-۱) رشد می‌کنند', () {
      expect(XpSystem.xpToReach(1), 0);
      expect(XpSystem.xpToReach(2), 50);
      expect(XpSystem.xpToReach(3), 150);
      expect(XpSystem.xpToReach(4), 300);
    });

    test('levelFor وارستهٔ xpToReach است (بدون پرش سطح)', () {
      for (var xp = 0; xp <= 5000; xp += 7) {
        final level = XpSystem.levelFor(xp);
        expect(level, greaterThanOrEqualTo(1));
        expect(XpSystem.xpToReach(level), lessThanOrEqualTo(xp));
        expect(XpSystem.xpToReach(level + 1), greaterThan(xp));
      }
    });

    test('XP منفی همیشه سطح ۱ می‌دهد', () {
      expect(XpSystem.levelFor(-100), 1);
      expect(XpSystem.progressInLevel(-5), 0.0);
    });

    test('پیشرفت در سطح بین ۰ و ۱ است و لقب‌ها در محدوده می‌مانند', () {
      for (var xp = 0; xp <= 6000; xp += 13) {
        final p = XpSystem.progressInLevel(xp);
        expect(p, inInclusiveRange(0.0, 1.0));
      }
      expect(XpSystem.titleForLevel(1), 'جوجه فندقی');
      expect(XpSystem.titleForLevel(3), 'دوست جزیره');
      expect(XpSystem.titleForLevel(9), 'افسانه جزیره');
      expect(XpSystem.titleForLevel(50), 'افسانه جزیره');
      expect(XpSystem.titleForLevel(0), 'جوجه فندقی');
    });

    test('xpToNextLevel هرگز منفی نیست', () {
      expect(XpSystem.xpToNextLevel(0), 50);
      expect(XpSystem.xpToNextLevel(50), 100);
      expect(XpSystem.xpToNextLevel(1000000), greaterThanOrEqualTo(0));
    });
  });

  group('GameData ثبت XP', () {
    test('پاسخ درست ۲ و تلاش اشتباه ۱ تجربه می‌دهد', () {
      GameData.recordAnswer(correct: true, skill: 'logic');
      expect(GameData.xp, XpSystem.xpPerCorrect);

      GameData.recordAnswer(correct: false, skill: 'logic');
      expect(GameData.xp, XpSystem.xpPerCorrect + XpSystem.xpPerAttempt);
    });

    test('addXp ارتقای سطح را برمی‌گرداند و سنجهٔ جزیره را جلو می‌برد', () {
      expect(GameData.islandLevel, 1);
      // ۵۰ XP = آستانهٔ سطح ۲
      var leveled = false;
      var added = 0;
      while (added < 50) {
        leveled = GameData.addXp(10) || leveled;
        added += 10;
      }
      expect(GameData.xp, 50);
      expect(GameData.islandLevel, 2);
      expect(leveled, isTrue);
      expect(GameData.islandLevelTitle, 'فندقی کوچولو');
      expect(GameData.islandLevelProgress, 0.0);
    });

    test('تکمیل مرحله XP می‌دهد و در اسنپ‌شات ذخیره می‌شود', () {
      final before = GameData.xp;
      GameData.completeStage('stage_v7', stageNumber: 1);
      expect(GameData.xp, before + XpSystem.xpPerStage);

      // برون‌بری/درون‌ریزی (بکاپ والدین) باید XP را حفظ کند
      final exported = GameData.exportChildProgress();
      expect(exported.containsKey('xp'), isTrue);
      expect(exported['xp'], GameData.xp);
    });

    test('مدال‌های XP با رشد تجربه باز می‌شوند', () {
      GameData.addXp(100);
      expect(GameData.achievements.contains('xp_100'), isTrue);

      GameData.addXp(900); // جمعاً ۱۰۰۰
      expect(GameData.achievements.contains('xp_500'), isTrue);
      expect(GameData.achievements.contains('xp_1000'), isTrue);
      expect(GameData.achievements.contains('xp_2500'), isFalse);
    });

    test('مدال منطق با مهارت logic باز می‌شود', () {
      for (var i = 0; i < 10; i++) {
        GameData.recordAnswer(correct: true, skill: 'logic');
      }
      expect(GameData.skills['logic'], 10);
      final logicAch = AchievementSystem.allAchievements
          .firstWhere((a) => a.id == 'logic_10');
      expect(AchievementSystem.isUnlocked(logicAch), isTrue);
    });
  });

  group('مهاجرت امن از نسخهٔ ۶.۲.۶ (بدون کلید xp)', () {
    test('اسنپ‌شات قدیمی Hive از ستاره و سکه بذر XP می‌گیرد', () async {
      // شبیه‌سازی دقیق دادهٔ کاربر نسخهٔ ۶.۲.۶: بدون کلید 'xp'
      await HivePlayerStore.writeSnapshot(<String, Object?>{
        'stars': 40,
        'c': 230,
        'l': 3,
        's': 5,
        'tc': 90,
        'tw': 30,
        'childName': 'آرا',
        'childAge': 6,
        'onboardingSeen': true,
        'sn': true,
        'tl': 60,
        'dm': 2,
        'missionDay': '2026-09-20',
      });
      await GameData.reload();

      // بذر: ۴۰×۵ + ۲۳۰ = ۴۳۰ — پیشرفت قبلی کودک نابود نشده
      expect(GameData.xp, 430);
      expect(GameData.islandLevel, XpSystem.levelFor(430));
      expect(GameData.stars, 40);
      expect(GameData.coins, 230);
      expect(GameData.childName, 'آرا');
    });

    test('اسنپ‌شات نسخه ۷ XP را دست‌نخورده نگه می‌دارد', () async {
      await HivePlayerStore.writeSnapshot(<String, Object?>{
        'xp': 77,
        'stars': 5,
        'c': 120,
        'l': 2,
      });
      await GameData.reload();
      expect(GameData.xp, 77);
      expect(GameData.islandLevel, XpSystem.levelFor(77));
    });

    test('بذر مهاجرت سقف ۵۰۰۰ دارد (بدون جهش بی‌نهایت سطح)', () async {
      await HivePlayerStore.writeSnapshot(<String, Object?>{
        'stars': 100000,
        'c': 100000,
        'l': 1,
      });
      await GameData.reload();
      expect(GameData.xp, 5000);
    });
  });

  test('نسخهٔ برنامه و تازه‌های نسخه همگام هستند', () {
    expect(GrowthStore.appVersion, '7.1.0');
  });
}
