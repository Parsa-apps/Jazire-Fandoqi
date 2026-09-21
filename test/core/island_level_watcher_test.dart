import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/island_level_watcher.dart';

void main() {
  setUp(GameData.resetForTesting);

  group('🎉 نگهبان جشن ارتقای سطح جزیره (نسخه ۷)', () {
    test('قبل از arm هیچ جشنی نمی‌گیرد (بارگذاری/مهاجرت اولیه)', () {
      final events = <String>[];
      final watcher = IslandLevelWatcher(
        onLevelUp: (from, to) => events.add('$from→$to'),
      );
      // پرش بزرگ حین بارگذاری — شبیه مهاجرت ۶.x
      GameData.addXp(200);
      watcher.handleChange();
      expect(events, isEmpty);
    });

    test('ارتقای واقعی پیشرفت → دقیقاً یک جشن با from/to درست', () {
      final events = <String>[];
      final watcher = IslandLevelWatcher(
        onLevelUp: (from, to) => events.add('$from→$to'),
      );
      watcher.arm();
      expect(GameData.addXp(60), isTrue); // 50 = مرز سطح ۲
      watcher.handleChange();
      expect(events, ['1→2']);
    });

    test('کسب تجربهٔ کمتر از مرز → بدون جشن', () {
      final events = <String>[];
      final watcher = IslandLevelWatcher(
        onLevelUp: (from, to) => events.add('$from→$to'),
      );
      watcher.arm();
      GameData.addXp(10);
      watcher.handleChange();
      expect(events, isEmpty);
    });

    test('دو ارتقای پشت‌سرهم: دومی در فاصلهٔ حداقلی بی‌صدا می‌ماند', () {
      final events = <String>[];
      var now = DateTime(2026, 1, 1);
      final watcher = IslandLevelWatcher(
        onLevelUp: (from, to) => events.add('$from→$to'),
        clock: () => now,
      );
      watcher.arm();
      GameData.addXp(60); // سطح ۲
      watcher.handleChange();
      GameData.addXp(200); // سطح ۳ (مرز ۱۵۰)
      watcher.handleChange();
      expect(events, ['1→2']);

      // بعد از گذشت فاصلهٔ حداقلی، ارتقای بعدی دوباره جشن می‌گیرد
      now = now.add(const Duration(seconds: 91));
      GameData.addXp(150); // سطح ۴ (مرز ۳۰۰)
      watcher.handleChange();
      expect(events, ['1→2', '3→4']);
    });

    test('تعویض کامل پروفایل (خواهر/برادر یا بکاپ) → بدون جشن؛ پیشرفت بعدی سالم', () {
      final events = <String>[];
      final watcher = IslandLevelWatcher(
        onLevelUp: (from, to) => events.add('$from→$to'),
      );
      watcher.arm();

      // سوییچ به پروفایل با XP بالا — نباید جشن بگیرد
      GameData.importChildProgress({'xp': 550}); // سطح ۵
      watcher.handleChange();
      expect(events, isEmpty);

      // کودکِ همان پروفایل پیشرفت می‌کند → جشن با خط پایهٔ درست
      GameData.addXp(250); // ۸۰۰ ≥ مرز ۷۵۰ → سطح ۶
      watcher.handleChange();
      expect(events, ['5→6']);
    });

    test('پایین آمدن سطح (ریست دستی) → بدون جشن، خط پایه دنبال می‌کند', () {
      final events = <String>[];
      final watcher = IslandLevelWatcher(
        onLevelUp: (from, to) => events.add('$from→$to'),
      );
      GameData.addXp(550); // سطح ۵ — هنوز arm نشده، بی‌صدا
      watcher.arm();
      GameData.resetChildProgressKeepingParent(); // نسل بالا می‌رود
      watcher.handleChange();
      expect(GameData.islandLevel, 1);
      expect(events, isEmpty);

      GameData.addXp(60);
      watcher.handleChange();
      expect(events, ['1→2']);
    });
  });
}
