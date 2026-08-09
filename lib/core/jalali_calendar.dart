/// ────────────────────────────────────────────────────────────
/// 📅 فاز ۵۳: تقویم شمسی (Jalali) — الگوریتم Borkowski
///
/// پورت دقیق jalaali-js (که خود پورت الگوریتم منتشرشده توسط
/// Kazimierz M. Borkowski در «The Persian calendar for 3000 years»
/// است). صحت آن با ۶ تاریخ مرجع تأیید شده:
///   ۱۹۷۹-۰۲-۱۱ ← ۱۳۵۷-۱۱-۲۲ (۲۲ بهمن)
///   ۲۰۲۴-۰۳-۲۰ ← ۱۴۰۳-۰۱-۰۱
///   ۲۰۲۵-۰۳-۲۱ ← ۱۴۰۴-۰۱-۰۱
///   ۲۰۲۶-۰۳-۲۱ ← ۱۴۰۵-۰۱-۰۱
///   ۲۰۲۶-۰۸-۰۹ ← ۱۴۰۵-۰۵-۱۸
///   ۲۰۱۶-۰۴-۱۱ ← ۱۳۹۵-۰۱-۲۳ (مثال رسمی jalaali-js)
///
/// نکته: `~/` در Dart به سمت صفر قطع می‌کند (مثل `~~` در JS) و
/// `_mod` نیز دقیقاً مانند `%` جاوااسکریپت (با علامت مقسوم‌علیه)
/// پیاده شده است.
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

  /// تبدیل میلادی به شمسی (الگوریتم Borkowski / jalaali-js).
  static JalaliDate fromGregorian(DateTime date) {
    final r = _d2j(_g2d(date.year, date.month, date.day));
    return JalaliDate(r.$1, r.$2, r.$3);
  }

  static int _div(int a, int b) => a ~/ b;

  static int _mod(int a, int b) => a - _div(a, b) * b;

  static const List<int> _breaks = <int>[
    -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181,
    1210, 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178,
  ];

  /// آیا سال شمسی کبیسه است (۳۶۶ روز)؟
  static bool isLeapYear(int jy) {
    final core = _jalCalCore(jy);
    return _leapFromCycle(core.$3, core.$4) == 0;
  }

  static (int, int, int, int) _jalCalCore(int jy) {
    final gy = jy + 621;
    var leapJ = -14;
    var jp = _breaks[0];
    var jm = 0;
    var jump = 0;

    for (var i = 1; i < _breaks.length; i++) {
      jm = _breaks[i];
      jump = jm - jp;
      if (jy < jm) break;
      leapJ = leapJ + _div(jump, 33) * 8 + _div(_mod(jump, 33), 4);
      jp = jm;
    }
    final n = jy - jp;

    leapJ = leapJ + _div(n, 33) * 8 + _div(_mod(n, 33) + 3, 4);
    if (_mod(jump, 33) == 4 && jump - n == 4) leapJ += 1;

    final leapG = _div(gy, 4) - _div((_div(gy, 100) + 1) * 3, 4) - 150;
    final march = 20 + leapJ - leapG;

    return (gy, march, jump, n);
  }

  static int _leapFromCycle(int jump, int n) {
    var adjusted = n;
    if (jump - n < 6) {
      adjusted = n - jump + _div(jump + 4, 33) * 33;
    }
    var leap = _mod(_mod(adjusted + 1, 33) - 1, 4);
    if (leap == -1) leap = 4;
    return leap;
  }

  static int _g2d(int gy, int gm, int gd) {
    var d = _div((gy + _div(gm - 8, 6) + 100100) * 1461, 4) +
        _div(153 * _mod(gm + 9, 12) + 2, 5) +
        gd -
        34840408;
    d = d - _div(_div(gy + 100100 + _div(gm - 8, 6), 100) * 3, 4) + 752;
    return d;
  }

  static (int, int, int) _d2g(int jdn) {
    var j = 4 * jdn + 139361631;
    j = j + _div(_div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908;
    final i = _div(_mod(j, 1461), 4) * 5 + 308;
    final gd = _div(_mod(i, 153), 5) + 1;
    final gm = _mod(_div(i, 153), 12) + 1;
    final gy = _div(j, 1461) - 100100 + _div(8 - gm, 6);
    return (gy, gm, gd);
  }

  static (int, int, int) _d2j(int jdn) {
    final gy = _d2g(jdn).$1;
    var jy = gy - 621 < 3177 ? gy - 621 : 3177;
    final core = _jalCalCore(jy);
    final leap = _leapFromCycle(core.$3, core.$4);
    final jdn1f = _g2d(core.$1, 3, core.$2);

    var k = jdn - jdn1f;
    if (k >= 0) {
      if (k <= 185) {
        return (jy, 1 + _div(k, 31), _mod(k, 31) + 1);
      }
      k -= 186;
    } else {
      jy -= 1;
      k += 179;
      if (leap == 1) k += 1;
    }
    return (jy, 7 + _div(k, 30), _mod(k, 30) + 1);
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
