import '../jalali_calendar.dart';
import 'growth_store.dart';

class SeasonalEvent {
  final String id;
  final String title;
  final String emoji;
  final String message;
  final int bonusCoins;

  const SeasonalEvent({
    required this.id,
    required this.title,
    required this.emoji,
    required this.message,
    required this.bonusCoins,
  });
}

/// رویدادهای تقویم شمسی + جمعهٔ رایگان برای یک دنیای ویژه.
class SeasonalEvents {
  SeasonalEvents._();

  static SeasonalEvent? current([JalaliDate? date]) {
    final d = date ?? JalaliDate.today();
    if (d.month == 1 && d.day >= 1 && d.day <= 13) {
      return const SeasonalEvent(
        id: 'nowruz',
        title: 'جشن نوروز',
        emoji: '🌸',
        message: 'سال نو مبارک! امروز مأموریت شکوفه: یک دور مهارت زندگی بازی کن و سکه نوروزی بگیر.',
        bonusCoins: 25,
      );
    }
    if (d.month == 9 && d.day == 30) {
      return const SeasonalEvent(
        id: 'yalda',
        title: 'شب یلدا',
        emoji: '🍉',
        message: 'یلدات مبارک! یک قصه بلند بخوان و هندوانهٔ سکه بگیر.',
        bonusCoins: 20,
      );
    }
    if (d.month == 7 && d.day == 16) {
      return const SeasonalEvent(
        id: 'mehregan',
        title: 'جشن مهرگان',
        emoji: '🍂',
        message: 'مهرگان مبارک! امروز مهربانی تمرین می‌کنیم — یک دور احساسات بازی کن.',
        bonusCoins: 18,
      );
    }
    if (d.month == 11 && d.day == 22) {
      return const SeasonalEvent(
        id: 'bahman22',
        title: '۲۲ بهمن',
        emoji: '🇮🇷',
        message: 'امروز یک دور جغرافیای ایران بازی کن و پرچم سکه بگیر.',
        bonusCoins: 15,
      );
    }
    return null;
  }

  /// جمعه ۱۸ تا شنبه ۱۲ — یک دنیای ویژه رایگان (مهارت زندگی).
  static bool isFamilyWeekend([DateTime? now]) {
    final t = now ?? DateTime.now();
    if (t.weekday == DateTime.friday && t.hour >= 18) return true;
    if (t.weekday == DateTime.saturday && t.hour < 12) return true;
    return false;
  }

  static bool claimSeasonalBonus() {
    final event = current();
    if (event == null) return false;
    final key = 'seasonal_${event.id}_${JalaliDate.today().year}';
    if (GrowthStore.completedLifeTopics.contains(key)) return false;
    GrowthStore.completedLifeTopics = [...GrowthStore.completedLifeTopics, key];
    GrowthStore.save();
    return true;
  }
}
