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

  group('🎵 موسیقی زمینهٔ مسیرهای جدید', () {
    test('شهر بازی و همهٔ بازی‌های تازه بخش games می‌گیرند', () {
      expect(BackgroundMusicObserver.sectionForRoute('/games-carnival'),
          'games');
      expect(BackgroundMusicObserver.sectionForRoute('/mini/first-letter'),
          'games');
      expect(BackgroundMusicObserver.sectionForRoute('/mini/word-builder'),
          'games');
      expect(BackgroundMusicObserver.sectionForRoute('/mini/counting'),
          'games');
      expect(BackgroundMusicObserver.sectionForRoute('/mini/visual-math'),
          'games');
      expect(BackgroundMusicObserver.sectionForRoute('/mini/big-small'),
          'games');
      expect(BackgroundMusicObserver.sectionForRoute('/mini/shape-match'),
          'games');
      expect(BackgroundMusicObserver.sectionForRoute('/mini/color-mix'),
          'games');
      expect(BackgroundMusicObserver.sectionForRoute('/mini/number-order'),
          'games');
      expect(BackgroundMusicObserver.sectionForRoute('/mini/odd-one'),
          'games');
      expect(BackgroundMusicObserver.sectionForRoute('/mini/sort-basket'),
          'games');
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
