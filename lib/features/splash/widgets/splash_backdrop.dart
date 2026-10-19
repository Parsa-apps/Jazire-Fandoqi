import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/parsa_brand.dart';
import '../splash_timeline.dart';

/// ─────────────────────────────────────────────────────────────
/// 🌌 پس‌زمینهٔ سینمایی اسپلش
///
/// مشکیِ عمیق + هالهٔ آبی نئونی در مرکز + بازتاب فلزی طلایی روی «کف»
/// + وینیت نرم برای عمق. همهٔ لایه‌ها با یک شیدر شعاعی کشیده می‌شوند؛
/// هیچ تصویر سنگین یا Blur سراسری‌ای در هر فریم ساخته نمی‌شود، بنابراین
/// هزینهٔ رندر روی گوشی‌های ضعیف هم پایین می‌ماند.
/// ─────────────────────────────────────────────────────────────
class SplashBackdrop extends StatelessWidget {
  const SplashBackdrop({
    super.key,
    required this.master,
    required this.ambient,
    required this.repaint,
    required this.reduceMotion,
  });

  final Animation<double> master;
  final Animation<double> ambient;

  /// یک Listenable مشترک که هر دو کنترلر را پوشش می‌دهد و بدون بازسازی
  /// ویجت‌ها فقط بوم را دوباره رنگ می‌کند.
  final Listenable repaint;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _BackdropPainter(
          master: master,
          ambient: ambient,
          repaint: repaint,
          reduceMotion: reduceMotion,
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required this.master,
    required this.ambient,
    required Listenable repaint,
    required this.reduceMotion,
  }) : super(repaint: repaint);

  final Animation<double> master;
  final Animation<double> ambient;
  final bool reduceMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = master.value;
    final core = reduceMotion
        ? 1.0
        : splashCurve(t, 0.0, 0.26, Curves.easeOutCubic);
    final pulse = reduceMotion ? 0.35 : splashWave(ambient.value);

    // پایه: مشکی عمیق (OLED-friendly).
    canvas.drawRect(Offset.zero & size, Paint()..color = ParsaBrand.ink);

    // ۱) نور آبیِ مرکزی که از صفر گسترش می‌یابد.
    final center = Offset(w * 0.5, h * 0.42);
    _radial(
      canvas,
      center,
      size.shortestSide * (0.06 + 0.34 * core),
      <Color>[
        ParsaBrand.electricBlue.withOpacity(0.20 * core),
        ParsaBrand.neonBlue.withOpacity(0.08 * core),
        Colors.transparent,
      ],
      const <double>[0.0, 0.38, 1.0],
    );

    // ۲) هالهٔ آبیِ بزرگ و آرام بالای صفحه — عمق سه‌بعدی.
    _radial(
      canvas,
      Offset(w * 0.5, h * 0.30),
      w * 0.92,
      <Color>[
        ParsaBrand.deepBlue.withOpacity(0.34 * core + 0.035 * pulse),
        ParsaBrand.electricBlue.withOpacity(0.05 * core),
        Colors.transparent,
      ],
      const <double>[0.0, 0.45, 1.0],
    );

    // ۳) بازتاب فلزی طلایی روی کف، هماهنگ با تاج و حاشیهٔ لوگو.
    canvas.save();
    canvas.translate(w * 0.5, h * 0.665);
    canvas.scale(1.0, 0.24);
    _radial(
      canvas,
      Offset.zero,
      w * 0.48,
      <Color>[
        ParsaBrand.gold.withOpacity(0.075 * core + 0.015 * pulse),
        ParsaBrand.deepGold.withOpacity(0.035 * core),
        Colors.transparent,
      ],
      const <double>[0.0, 0.42, 1.0],
    );
    canvas.restore();

    // ۴) یک انعکاس موربِ بسیار محو فلزی روی کل قاب.
    final streak = ui.Gradient.linear(
      Offset(0, h * 0.15),
      Offset(w, h * 0.75),
      <Color>[
        Colors.transparent,
        ParsaBrand.gold.withOpacity(0.028 * core),
        ParsaBrand.iceBlue.withOpacity(0.022 * core),
        Colors.transparent,
      ],
      const <double>[0.18, 0.42, 0.58, 0.9],
    );
    canvas.drawRect(Offset.zero & size, Paint()..shader = streak);

    // ۵) ذرات بسیار ریز غبار نور در کل قاب (محدود و محو).
    if (!reduceMotion) _dust(canvas, size, t, ambient.value * 0.6);

    // ۶) وینیت: لبه‌ها را می‌گیرد تا مرکز بدرخشد و عمق حس شود.
    _radial(
      canvas,
      Offset(w * 0.5, h * 0.5),
      size.longestSide * 0.74,
      <Color>[
        Colors.transparent,
        Colors.transparent,
        Colors.black.withOpacity(0.62),
      ],
      const <double>[0.0, 0.52, 1.0],
    );
  }

  void _dust(Canvas canvas, Size size, double t, double ambientValue) {
    final appear = splashCurve(t, 0.0, 0.35);
    if (appear <= 0.01) return;
    final paint = Paint()..blendMode = BlendMode.plus;
    for (var i = 0; i < 14; i++) {
      final seed = i * 2.399963;
      final x = (0.5 +
              0.46 * math.cos(seed * 3.7 + ambientValue * 0.35) *
                  (0.55 + 0.45 * math.sin(seed))) *
          size.width;
      final y = (0.42 +
              0.40 * math.sin(seed * 2.9 + ambientValue * 0.28) *
                  (0.6 + 0.4 * math.cos(seed * 1.3))) *
          size.height;
      final twinkle = 0.35 + 0.65 * splashWave(ambientValue + i * 0.11);
      final radius = 0.55 + (i % 3) * 0.35;
      paint.color = (i % 4 == 0 ? ParsaBrand.gold : ParsaBrand.iceBlue)
          .withOpacity(0.12 * appear * twinkle);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _radial(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> colors,
    List<double> stops,
  ) {
    if (radius <= 0) return;
    final paint = Paint()
      ..shader = ui.Gradient.radial(center, radius, colors, stops);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) {
    return oldDelegate.reduceMotion != reduceMotion ||
        oldDelegate.master != master ||
        oldDelegate.ambient != ambient;
  }
}
