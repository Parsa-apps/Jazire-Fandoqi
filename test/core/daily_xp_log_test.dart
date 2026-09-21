import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/parent_insights.dart';

void main() {
  setUp(GameData.resetForTesting);

  group('🌟 دفتر تجربهٔ روزانه (نسخه ۷)', () {
    test('addXp تجربهٔ امروز را تجمیع می‌کند', () {
      GameData.addXp(2);
      GameData.addXp(3);
      expect(GameData.dailyXpLog.length, 1);
      expect(GameData.dailyXpLog.values.first, 5);
    });

    test('ورودی‌های قدیمی‌تر از ۱۴ روز هرس می‌شوند', () {
      GameData.dailyXpLog['2019-01-01'] = 40;
      GameData.dailyXpLog['2020-06-15'] = 60;
      GameData.addXp(7);
      expect(GameData.dailyXpLog.containsKey('2019-01-01'), isFalse);
      expect(GameData.dailyXpLog.containsKey('2020-06-15'), isFalse);
      expect(GameData.dailyXpLog.values.first, 7);
    });

    test('کلیدهای خراب هم‌زمان با هرس پاک می‌شوند', () {
      GameData.dailyXpLog['not-a-date'] = 10;
      GameData.addXp(1);
      expect(GameData.dailyXpLog.containsKey('not-a-date'), isFalse);
    });

    test('اسنپ‌شات ۶.x بدون dxp → دفتر خالی، بدون خطا (مهاجرت امن)', () {
      GameData.importChildProgress(<String, Object?>{
        'stars': 20,
        'c': 30,
        'xp': 100,
      });
      expect(GameData.xp, 100);
      expect(GameData.dailyXpLog, isEmpty);
    });

    test('دفتر همراه کودک در export/import سوییچ می‌شود', () {
      GameData.addXp(12);
      final exported = GameData.exportChildProgress();
      expect(exported.containsKey('dxp'), isTrue);
      expect((exported['dxp'] as Map).values.first, 12);

      // سوییچ به کودک دیگر و برگشت
      GameData.resetChildProgressKeepingParent();
      expect(GameData.dailyXpLog, isEmpty);
      GameData.importChildProgress(exported);
      expect(GameData.dailyXpLog.values.first, 12);
    });

    test('ریست پروفایل کودک دفتر را صفر می‌کند', () {
      GameData.addXp(25);
      GameData.resetChildProgressKeepingParent();
      expect(GameData.xp, 0);
      expect(GameData.dailyXpLog, isEmpty);
    });
  });

  group('📈 روند تجربه در پنل والدین', () {
    test('xpTrend هفت روز با برچسب و مقدار درست برمی‌گرداند', () {
      GameData.addXp(9);
      final trend = ParentInsights.xpTrend();
      expect(trend.length, 7);
      expect(trend.last.xp, 9); // امروز = آخرین ستون
      expect(trend.take(6).every((d) => d.xp == 0), isTrue);
      expect(trend.every((d) => d.label.isNotEmpty), isTrue);
      expect(ParentInsights.weekXp, 9);
    });

    test('خلاصهٔ حالت خالی والدپسند است (بدون فشار)', () {
      expect(ParentInsights.xpTrendSummary(), contains('🌱'));
    });

    test('خلاصه با داده، مجموع هفته را با ارقام فارسی می‌گوید', () {
      GameData.addXp(15);
      final summary = ParentInsights.xpTrendSummary();
      expect(summary, contains('۱۵'));
      expect(summary, isNot(contains('🌱')));
    });
  });
}
