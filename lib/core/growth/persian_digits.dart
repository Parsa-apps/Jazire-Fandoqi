/// تبدیل ارقام لاتین ↔ فارسی/عربی برای نمایش کودک‌پسند و ورودی والد.
class PersianDigits {
  PersianDigits._();

  static const List<String> fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  static const List<String> ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  /// هر عدد یا رشته را با ارقام فارسی برمی‌گرداند.
  static String toFa(Object value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (final rune in raw.runes) {
      final ch = String.fromCharCode(rune);
      final idx = int.tryParse(ch);
      if (idx != null && idx >= 0 && idx <= 9) {
        buffer.write(fa[idx]);
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  /// ارقام فارسی و عربی را به لاتین تبدیل می‌کند (برای parse امن).
  static String toEn(String input) {
    var result = input.trim();
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(fa[i], '$i').replaceAll(ar[i], '$i');
    }
    return result;
  }

  static int? parseInt(String input) => int.tryParse(toEn(input));

  /// دقیقه را به «۱۲ دقیقه» با رقم فارسی تبدیل می‌کند.
  static String minutes(int value) => '${toFa(value)} دقیقه';
}
