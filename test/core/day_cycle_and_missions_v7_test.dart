import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/app/app_theme.dart';
import 'package:jazireh_fandoghi/core/background_music_observer.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';

void main() {
  setUp(GameData.resetForTesting);

  group('🌅 چرخهٔ روز چهاره‌فازی (نسخه ۷)', () {
    test('مرزهای ساعت درست کار می‌کنند', () {
      expect(AppTheme.cycleForHour(5), DayCycle.night);
      expect(AppTheme.cycleForHour(6), DayCycle.morning);
      expect(AppTheme.cycleForHour(11), DayCycle.morning);
      expect(AppTheme.cycleForHour(12), DayCycle.noon);
      expect(AppTheme.cycleForHour(16), DayCycle.noon);
      expect(AppTheme.cycleForHour(17), DayCycle.sunset);
      expect(AppTheme.cycleForHour(18), DayCycle.sunset);
      expect(AppTheme.cycleForHour(19), DayCycle.night);
      expect(AppTheme.cycleForHour(23), DayCycle.night);
      expect(AppTheme.cycleForHour(0), DayCycle.night);
    });

    test('هر ۲۴ ساعت دقیقاً چهار فاز دیده می‌شود', () {
      final phases = <DayCycle>{
        for (var h = 0; h < 24; h++) AppTheme.cycleForHour(h),
      };
      expect(phases, containsAll(<DayCycle>[
        DayCycle.morning,
        DayCycle.noon,
        DayCycle.sunset,
        DayCycle.night,
      ]));
      expect(phases.length, 4);
    });
  });

  group('🎯 مأموریت‌های روزانهٔ جدید (نسخه ۷)', () {
    test('سه مأموریت تازه ثبت و تکمیل می‌شوند', () {
      expect(GameData.missionTargets.containsKey('words'), isTrue);
      expect(GameData.missionTargets.containsKey('counting'), isTrue);
      expect(GameData.missionTargets.containsKey('logic'), isTrue);

      GameData.progressMission('words');
      GameData.progressMission('words');
      expect(GameData.isMissionDone('words'), isTrue);

      GameData.progressMission('counting');
      expect(GameData.isMissionDone('counting'), isFalse);
      GameData.progressMission('counting');
      expect(GameData.isMissionDone('counting'), isTrue);
    });

    test('صندوق مأموریت همچنان با ۳ مأموریت کامل باز می‌شود', () {
      GameData.progressMission('logic', amount: 2);
      GameData.progressMission('words', amount: 2);
      GameData.progressMission('counting', amount: 2);
      expect(GameData.dailyMissions, greaterThanOrEqualTo(3));
      expect(GameData.canClaimDailyMissionChest, isTrue);
    });

    test('نقشهٔ مأموریت بیش از هدف نمی‌رود', () {
      GameData.progressMission('logic', amount: 99);
      expect(GameData.missionValue('logic'), GameData.missionTargets['logic']);
    });
  });

  group('🎵 موسیقی پس‌زمینه فقط روی صفحهٔ اصلی', () {
    test('دروازه و خانه تنها مسیرهایی هستند که موسیقی home می‌گیرند', () {
      expect(BackgroundMusicObserver.sectionForRoute('/gateway'), 'home');
      expect(BackgroundMusicObserver.sectionForRoute('/home'), 'home');
    });

    test('بازی‌ها و همهٔ بخش‌های دیگر هیچ موسیقی پس‌زمینه‌ای نمی‌گیرند', () {
      expect(BackgroundMusicObserver.sectionForRoute('/games-carnival'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/mini/first-letter'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/mini/word-builder'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/mini/counting'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/mini/visual-math'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/mini/big-small'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/mini/shape-match'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/mini/color-mix'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/mini/number-order'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/mini/odd-one'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/mini/sort-basket'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/cartoons'), isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/stories'), isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/learning-library'),
          isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/lullabies'), isNull);
      // بخش‌های جدید شعر و قرآن هم موسیقی پس‌زمینه ندارند (فقط صدای محتوا).
      expect(BackgroundMusicObserver.sectionForRoute('/poems'), isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/poem/ball'), isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/quran'), isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/surah/ikhlas'), isNull);
    });
  });

  group('🧒 مهارت منطق در گزارش‌ها', () {
    test('مهارت logic ثبت و در آمار رادار دیده می‌شود', () {
      for (var i = 0; i < 7; i++) {
        GameData.recordAnswer(correct: true, skill: 'logic');
      }
      expect(GameData.skills['logic'], 7);
      expect(GameData.topSkills['logic'], 7);
    });
  });
}
