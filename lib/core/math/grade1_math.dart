import 'dart:math';

import '../growth/persian_digits.dart';

/// قانون معلم کلاس اول ایران: شمارش و جمع/تفریق تا ۲۰؛ ضرب و عدد بزرگ‌تر نه.
class Grade1Math {
  Grade1Math._();

  static const int maxNumber = 20;
  static const int minNumber = 0;

  /// ارزش مکانی اول دبستان: ۱۱ تا ۲۰ + چند عدد زیر ده برای یکی‌ها.
  static const List<int> placeValueTargets = [11, 14, 16, 20, 8, 13, 19, 15];

  static bool isInRange(int value) =>
      value >= minNumber && value <= maxNumber;

  static bool isValidAdd(int a, int b) =>
      isInRange(a) && isInRange(b) && isInRange(a + b);

  static bool isValidSubtract(int a, int b) =>
      isInRange(a) && isInRange(b) && a >= b && isInRange(a - b);

  static String equation(int a, String op, int b) =>
      '${PersianDigits.toFa(a)} $op ${PersianDigits.toFa(b)} = ؟';

  static String number(int value) => PersianDigits.toFa(value);

  /// سطح ۱ تا ۱۰، سطح ۲ تا ۲۰، سطح ۳ نزدیک بیست — هرگز ضرب و هرگز بالای ۲۰.
  static (int, int, String) nextAddOrSubtract({
    Random? random,
    int level = 2,
  }) {
    final rng = random ?? Random();
    final cap = level <= 1 ? 10 : maxNumber;
    for (var i = 0; i < 48; i++) {
      final preferAdd = level <= 1 || rng.nextBool();
      if (preferAdd) {
        final a = rng.nextInt(cap + 1);
        final b = rng.nextInt(cap + 1 - a);
        if (isValidAdd(a, b) && a + b <= cap) return (a, b, '+');
      } else {
        final a = rng.nextInt(cap + 1);
        final b = a == 0 ? 0 : rng.nextInt(a + 1);
        if (isValidSubtract(a, b)) return (a, b, '-');
      }
    }
    return level <= 1 ? (2, 3, '+') : (8, 6, '+');
  }

  /// تجزیهٔ ارزش مکانی مثل کتاب: ۱۴ = یک ده و چهار یکی.
  static String placeValuePhrase(int value) {
    if (value <= 0) return PersianDigits.toFa(0);
    if (value < 10) return '${PersianDigits.toFa(value)} یکی';
    if (value == 10) return 'یک ده';
    if (value == 20) return 'دو ده';
    final tens = value ~/ 10;
    final ones = value % 10;
    final tensWord = tens == 1 ? 'یک ده' : '${PersianDigits.toFa(tens)} ده';
    if (ones == 0) return tensWord;
    return '$tensWord و ${PersianDigits.toFa(ones)} یکی';
  }
}
