import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/growth/persian_digits.dart';

void main() {
  test('toFa converts latin digits and keeps other characters', () {
    expect(PersianDigits.toFa(12), '۱۲');
    expect(PersianDigits.toFa('3 coins'), '۳ coins');
    expect(PersianDigits.toFa('۴۵'), '۴۵');
    expect(PersianDigits.toFa(0), '۰');
  });

  test('toEn converts persian and arabic digits back to latin', () {
    expect(PersianDigits.toEn('۱۲۳'), '123');
    expect(PersianDigits.toEn('٤٥٦'), '456');
    expect(PersianDigits.toEn('abc'), 'abc');
  });

  test('parseInt safely handles persian input', () {
    expect(PersianDigits.parseInt('۲۵'), 25);
    expect(PersianDigits.parseInt('not a number'), isNull);
  });

  test('minutes formats with persian digits', () {
    expect(PersianDigits.minutes(12), '۱۲ دقیقه');
  });
}
