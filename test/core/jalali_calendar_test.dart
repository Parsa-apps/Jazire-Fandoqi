import 'package:flutter_test/flutter_test.dart';

import 'package:amoozesh_fandoghi/core/jalali_calendar.dart';

void main() {
  test('Borkowski/Jalaali conversion matches reference dates', () {
    // ۶ تاریخ مرجع (تأییدشده)
    expect(
      (JalaliDate.fromGregorian(DateTime(1979, 2, 11)).year,
          JalaliDate.fromGregorian(DateTime(1979, 2, 11)).month,
          JalaliDate.fromGregorian(DateTime(1979, 2, 11)).day),
      (1357, 11, 22),
      reason: '۲۲ بهمن ۱۳۵۷',
    );
    expect(
      (JalaliDate.fromGregorian(DateTime(2024, 3, 20)).year,
          JalaliDate.fromGregorian(DateTime(2024, 3, 20)).month,
          JalaliDate.fromGregorian(DateTime(2024, 3, 20)).day),
      (1403, 1, 1),
      reason: 'نوروز ۱۴۰۳',
    );
    expect(
      (JalaliDate.fromGregorian(DateTime(2025, 3, 21)).year,
          JalaliDate.fromGregorian(DateTime(2025, 3, 21)).month,
          JalaliDate.fromGregorian(DateTime(2025, 3, 21)).day),
      (1404, 1, 1),
      reason: 'نوروز ۱۴۰۴',
    );
    expect(
      (JalaliDate.fromGregorian(DateTime(2026, 3, 21)).year,
          JalaliDate.fromGregorian(DateTime(2026, 3, 21)).month,
          JalaliDate.fromGregorian(DateTime(2026, 3, 21)).day),
      (1405, 1, 1),
      reason: 'نوروز ۱۴۰۵',
    );
    expect(
      (JalaliDate.fromGregorian(DateTime(2026, 8, 9)).year,
          JalaliDate.fromGregorian(DateTime(2026, 8, 9)).month,
          JalaliDate.fromGregorian(DateTime(2026, 8, 9)).day),
      (1405, 5, 18),
      reason: 'امروز (۱۸ مرداد ۱۴۰۵)',
    );
    expect(
      (JalaliDate.fromGregorian(DateTime(2016, 4, 11)).year,
          JalaliDate.fromGregorian(DateTime(2016, 4, 11)).month,
          JalaliDate.fromGregorian(DateTime(2016, 4, 11)).day),
      (1395, 1, 23),
      reason: 'مثال رسمی jalaali-js',
    );
  });

  test('leap year detection matches 1395 (leap) vs 1394 (common)', () {
    expect(JalaliDate.isLeapYear(1395), isTrue);
    expect(JalaliDate.isLeapYear(1394), isFalse);
  });

  test('month names are Persian and valid', () {
    final d = JalaliDate.fromGregorian(DateTime(2026, 8, 9));
    expect(d.monthName, 'مرداد');
    expect(d.format(), contains('مرداد'));
  });

  test('StreakCalendar covers exactly 7 days', () {
    final days = StreakCalendar.last7Days(<String>{});
    expect(days.length, 7);
  });
}
