import 'game_data.dart';

class AI {
  static int difficulty() {
    if (GameData.successRate > 0.8) return 3;
    if (GameData.successRate > 0.5) return 2;
    return 1;
  }

  static String diffName() {
    switch (difficulty()) {
      case 3:
        return "سخت";
      case 2:
        return "متوسط";
      default:
        return "آسان";
    }
  }

  static String mascotMsg() {
    if (GameData.totalCorrect == 0) return "سلام! بیا بازی کنیم! 🎮";
    if (GameData.successRate > 0.8) return "آفرین نابغه! 🌟";
    if (GameData.successRate > 0.5) return "ادامه بده عالی میشی! 💪";
    return "اشکال نداره! تمرین کن! 🎯";
  }

  static String weakSkill() {
    var sorted = GameData.skills.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    Map<String, String> names = {
      'math': 'ریاضی',
      'alphabet': 'الفبا',
      'memory': 'حافظه',
      'colors': 'رنگ‌ها',
      'shapes': 'اشکال',
      'animals': 'حیوانات',
      'counting': 'شمارش',
      'pattern': 'الگو',
      'fruits': 'میوه‌ها',
      'concepts': 'مفاهیم',
      'vocab': 'لغات',
      'body': 'بدن',
      'vehicles': 'وسایل نقلیه',
      'time': 'زمان',
      'weather': 'آب و هوا',
      'emotions': 'احساسات',
      'jobs': 'شغل‌ها'
    };
    return names[sorted.first.key] ?? 'همه';
  }

  static bool fatigued(int mistakes, Duration time) =>
      mistakes > 5 && time.inMinutes > 15;
}
