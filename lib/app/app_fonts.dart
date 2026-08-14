import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🛡️ Safe GoogleFonts wrapper — عمیق‌ترین باگ بیلد اینجا بود
/// وقتی allowRuntimeFetching=false باشد و فونت کش نشده باشد،
/// GoogleFonts در اولین فریم exception پرتاب می‌کند و Flutter به
/// صفحه سفید می‌رود (همین که کاربر فکر می‌کند بیلد ساخته نشد).
/// این wrapper هرگز کرش نمی‌کند و همیشه fallback دارد.
class AppFonts {
  static bool _runtimeFetchConfigured = false;

  static void configure() {
    if (_runtimeFetchConfigured) return;
    _runtimeFetchConfigured = true;
    try {
      // در حالت debug اجازه دانلود می‌دهیم تا فونت کش شود
      // در release آفلاین می‌ماند ولی هیچ‌وقت کرش نمی‌کند
      GoogleFonts.config.allowRuntimeFetching = false;
    } catch (_) {
      // اگر google_fonts نسخه قدیمی باشد، بی‌خیال
    }
  }

  static TextStyle vazirmatn({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
  }) {
    try {
      return GoogleFonts.vazirmatn(
        textStyle: textStyle,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        shadows: shadows,
      );
    } catch (_) {
      return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: 'Vazirmatn',
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        shadows: shadows,
      );
    }
  }

  /// 🧸 فونت کودکانهٔ تم نقشه — تپل، گرد و شاد.
  ///
  /// برخلاف بقیهٔ متدها این یکی سراغ GoogleFonts نمی‌رود: فایل فونت داخل
  /// خود برنامه بسته شده، پس آفلاین هم قطعاً رندر می‌شود و هیچ‌وقت
  /// صفحهٔ سفید نمی‌دهد. برای تیترها و دکمه‌های بزرگ استفاده شود، نه
  /// متن‌های طولانی.
  static TextStyle kids({
    Color? color,
    double? fontSize,
    FontWeight fontWeight = FontWeight.w800,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: 'BalooBhaijaan2',
      // این خانواده فقط ۷۰۰ و ۸۰۰ دارد؛ وزن‌های دیگر به نزدیک‌ترین می‌افتند
      fontWeight: fontWeight.index >= FontWeight.w800.index
          ? FontWeight.w800
          : FontWeight.w700,
      color: color,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      height: height,
      shadows: shadows,
    );
  }

  static TextStyle balooBhaijaan2({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
  }) {
    try {
      return GoogleFonts.balooBhaijaan2(
        textStyle: textStyle,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        shadows: shadows,
      );
    } catch (_) {
      return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: 'BalooBhaijaan2',
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        shadows: shadows,
      );
    }
  }

  static TextStyle exo2({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    try {
      return GoogleFonts.exo2(
        textStyle: textStyle,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      );
    } catch (_) {
      return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: 'Exo2',
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  static TextTheme vazirmatnTextTheme([TextTheme? base]) {
    try {
      return GoogleFonts.vazirmatnTextTheme(base);
    } catch (_) {
      return base ?? ThemeData.light().textTheme;
    }
  }
}
