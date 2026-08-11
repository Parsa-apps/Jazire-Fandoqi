import '../game_data.dart';

/// سختی بر اساس سن + بازیابی مهربان بعد از اشتباه متوالی.
class AdaptiveCoach {
  AdaptiveCoach._();

  /// تعداد گزینه بر اساس سن: ۳–۴ → ۲، ۵–۶ → ۳، ۷+ → ۴
  static int optionCountForAge([int? age]) {
    final a = age ?? GameData.childAge;
    if (a <= 4) return 2;
    if (a <= 6) return 3;
    return 4;
  }

  static String hintAfterMistakes(int consecutiveWrong, String answer) {
    if (consecutiveWrong <= 0) return '';
    if (consecutiveWrong == 1) {
      return 'نزدیک بود! یک بار دیگر با آرامش نگاه کن 🌱';
    }
    if (consecutiveWrong == 2) {
      return 'راهنمایی فندقی: جواب چیزی شبیه «$answer» است. تو می‌توانی!';
    }
    return 'اشکالی ندارد؛ این یکی را با هم رد می‌کنیم و بعدی را می‌گیریم 🌈';
  }

  static bool shouldSkip(int consecutiveWrong) => consecutiveWrong >= 3;

  static int difficultyForAge([int? age]) {
    final a = age ?? GameData.childAge;
    if (a <= 4) return 1;
    if (a <= 6) return 2;
    return 3;
  }
}
