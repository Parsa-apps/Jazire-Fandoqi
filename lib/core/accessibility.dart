import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ────────────────────────────────────────────────────────────
/// ♿ فاز ۱۷: دسترس‌پذیری
///
/// - حالت کوررنگی: جایگزینی جفت‌رنگ‌های مشکوک با پالت امن
/// - کنتراست بالا: نسخه تیره‌تر متن‌ها برای WCAG AA
/// - برچسب‌های Semantics فارسی برای اسکرین‌خوان‌ها
/// ────────────────────────────────────────────────────────────
class Accessibility {
  Accessibility._();

  /// آیا جفت‌رنگ برای کوررنگی (قرمز/سبز) امن است؟
  static bool isColorBlindSafePair(Color a, Color b) {
    final da = _deutanScore(a);
    final db = _deutanScore(b);
    // اگر دو رنگ بعد از شبیه‌سازی دوتران (شایع‌ترین) خیلی نزدیک شوند،
    // تفکیکشان برای کوررنگی سخت است.
    return (da - db).abs() > 0.35;
  }

  static double _deutanScore(Color c) {
    // تبدیل تقریبی به فضای ادراکی برای جداسازی سبز/قرمز. کانال‌های قدیمی
    // Color در Flutter 3.24 عدد ۰..۲۵۵ هستند، پس پیش از محاسبه نرمال می‌شوند.
    return (c.red / 255.0) * 0.7 +
        (c.green / 255.0) * 1.2 +
        (c.blue / 255.0) * 0.3;
  }

  /// اگر کنتراست کمتر از AA باشد، متن را تیره‌تر/روشن‌تر می‌کند.
  static Color ensureContrast(Color foreground, Color background,
      {double minRatio = 4.5}) {
    if (_contrastRatio(foreground, background) >= minRatio) return foreground;
    // متن تیره‌تر روی زمینه روشن
    final lumB = _relativeLuminance(background);
    return lumB > 0.4 ? const Color(0xFF1A1A2E) : Colors.white;
  }

  static double _contrastRatio(Color a, Color b) {
    final la = _relativeLuminance(a);
    final lb = _relativeLuminance(b);
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(Color c) {
    double lin(double v) {
      final s = v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
      return s;
    }

    return 0.2126 * lin(c.red / 255.0) +
        0.7152 * lin(c.green / 255.0) +
        0.0722 * lin(c.blue / 255.0);
  }

  /// برچسب Semantics فارسی برای آیتم‌های تعاملی.
  static Widget semantics({
    required String label,
    required Widget child,
    bool button = false,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      container: true,
      child: child,
    );
  }
}

/// رنگ‌های امن برای کوررنگی — جایگزین استفاده از رنگ خام در بازی‌های
/// رنگ‌محور (مثل بازی حافظه رنگی).
class ColorBlindSafePalette {
  static const List<Color> colors = <Color>[
    Color(0xFF1F77B4), // آبی
    Color(0xFFFF7F0E), // نارنجی
    Color(0xFF2CA02C), // سبز (با آبی قابل تفکیک)
    Color(0xFFD62728), // قرمز
    Color(0xFF9467BD), // بنفش
    Color(0xFF8C564B), // قهوه‌ای
    Color(0xFFE377C2), // صورتی
    Color(0xFF7F7F7F), // خاکستری
  ];

  /// آیا پالت بازی برای حالت کوررنگی امن است؟
  static bool isSafePair(int i, int j) =>
      Accessibility.isColorBlindSafePair(colors[i], colors[j]);
}
