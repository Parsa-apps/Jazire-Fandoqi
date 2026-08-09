/// ────────────────────────────────────────────────────────────
/// 📅 فاز ۵۳: تقویم شمسی (Jalali) — الگوریتم استاندارد
///
/// تبدیل میلادی ↔ شمسی برای نمایش تاریخ و تقویم streak کودک.
/// ────────────────────────────────────────────────────────────
class JalaliDate {
  final int year;
  final int month; // ۱..۱۲
  final int day; // ۱..۳۱

  const JalaliDate(this.year, this.month, this.day);

  /// نام فارسی ماه.
  String get monthName {
    const names = <String>[
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
      'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
    ];
    return names[month - 1];
  }

  /// تبدیل میلادی به شمسی — الگوریتم استاندارد (jalali).
  static JalaliDate fromGregorian(DateTime date) {
    final gy = date.year;
    final gm = date.month;
    final gd = date.day;

    // روزهای سپری‌شده از مبدأ
    final gy2 = (gm > 2) ? gy + 1 : gy;
    var gdn = 355666 + (365 * gy) + ((gy2 + 3) ~/ 4) - ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) + gd + ((367 * gm - 362) ~/ 12);
    gdn = gdn + (gm > 2 ? (isLeapYear(gy) ? -1 : -2) : 0);

    var jdn = gdn - 79;
    final jdnShift = (jdn ~/ 12053).toInt();
    jdn += jdnShift;
    var jy = 979 + (jdn - (jdn ~/ 33) * 33) ~/ 4;
    if (jdn % 33 == 33 - (jdnShift % 4)) jy += 1;

    var jm = (jdn - jy * 365 - (jy ~/ 33) * 8) ~/ 31;
    var jd = jdn - jy * 365 - (jy ~/ 33) * 8 - jm * 31;
    if (jm >= 7) {
      jd = jdn - jy * 365 - (jy ~/ 33) * 8 - 186 - (jm - 7) * 30;
      jm = jm + 1;
    }
    if (jd <= 0) {
      jy -= 1;
      jm = 12;
      jd = jd + (isLeapYear(jy) ? 30 : 29);
    }
    if (jm <= 0) {
      jy -= 1;
      jm = 12;
    }
    return JalaliDate(jy, jm, jd);
  }

  static bool isLeapYear(int year) {
    final mod = ((year + 1) % 33) % 4;
    return mod == 0 || mod == 1;
  }

  /// تاریخ امروز شمسی.
  static JalaliDate today() => fromGregorian(DateTime.now());

  String format() => '$day $monthName $year';
}

/// راهنمای گام‌های ۷ روزه (برای تقویم streak).
class StreakCalendar {
  /// آخرین ۷ روز به‌صورت شمسی با پرچم بازی‌کردن.
  static List<(JalaliDate, bool)> last7Days(Set<String> playedDates) {
    final result = <(JalaliDate, bool)>[];
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final jalali = JalaliDate.fromGregorian(day);
      final key = '${day.year}-${day.month}-${day.day}';
      result.add((jalali, playedDates.contains(key)));
    }
    return result;
  }
}
