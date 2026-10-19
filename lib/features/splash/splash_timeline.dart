import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// ─────────────────────────────────────────────────────────────
/// ⏱️ خطِ زمانِ اسپلش — همهٔ لایه‌ها از یک «زمان‌بند» می‌خوانند
///
/// `t` بین ۰ تا ۱ است و نشان می‌دهد کجای ورود سینمایی هستیم. این تبدیل
/// ساده اجازه می‌دهد ورود لوگو، عبور نور و ظاهرشدن نوار پیشرفت دقیقاً
/// روی هم هماهنگ شوند، بدون آنکه هر ویجت برای خودش زمان‌بندی جدا بسازد.
/// ─────────────────────────────────────────────────────────────
double splashPhase(double t, double begin, double end) {
  if (end <= begin) return t >= end ? 1 : 0;
  return ((t - begin) / (end - begin)).clamp(0.0, 1.0).toDouble();
}

/// مثل [splashPhase]، ولی با منحنی نرم (پیش‌فرض: easeOutCubic).
double splashCurve(
  double t,
  double begin,
  double end, [
  Curve curve = Curves.easeOutCubic,
]) {
  return curve.transform(splashPhase(t, begin, end));
}

/// موج نرم ۰→۱→۰ برای درخشش‌های پالسی.
double splashWave(double value) {
  return 0.5 - 0.5 * math.cos(value * 2 * math.pi);
}

/// میان‌یابی خطی امن.
double splashLerp(double a, double b, double t) => a + (b - a) * t;
