import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/island_cinema_style.dart';
import 'island_scene_geometry.dart';

/// ═══════════════════════════════════════════════════════════════
/// ✨ لایهٔ ۴ — اتمسفر: پرتوِ نرم، گرده‌های درخشان، تاریک‌گوشه و
/// قابِ برگ‌هایِ پیش‌زمینه (عمقِ میدان)
///
/// قوانینِ ایمنیِ کودک که این لایه رعایت می‌کند:
///   * هیچ تندیِ نوری، چشمک‌زدن یا لرزش — بیشینهٔ شفافیت ۰٫۲۲؛
///   * حرکت‌ها آهسته و چرخه‌ای‌اند (بیش از ۱۴ ثانیه)؛
///   * در حالتِ کاهشِ حرکت، همهٔ ذرات ثابت می‌مانند.
/// ═══════════════════════════════════════════════════════════════
class IslandAtmospherePainter extends CustomPainter {
  const IslandAtmospherePainter({
    required this.phase,
    this.reduceMotion = false,
    this.sparkleCount = IslandCinemaMetrics.sparkleBudget,
  });

  final double phase;
  final bool reduceMotion;
  final int sparkleCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final geo = IslandSceneGeometry(size);

    _paintSunRays(canvas, geo);
    _paintSparkles(canvas, geo);
    _paintVignette(canvas, geo);
    _paintLeafFrame(canvas, geo);
  }

  /// پرتوهای بسیار ملایمِ خورشید (نه شعاعِ تیز و چشمک‌زن)
  void _paintSunRays(Canvas canvas, IslandSceneGeometry geo) {
    final center = geo.sunCenter;
    const rayCount = 6;
    for (var i = 0; i < rayCount; i++) {
      final angle = math.pi * (0.16 + i * 0.135);
      final sway = reduceMotion
          ? 0.0
          : math.sin(phase * 2 * math.pi + i * 0.8) * 0.035;
      final paint = Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            IslandCinemaPalette.sunGlow.withOpacity(0.22),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: geo.h * 0.36),
        );
      final half = 0.030 + sway;
      canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(
            center.dx + math.cos(angle - half) * geo.h * 0.40,
            center.dy + math.sin(angle - half) * geo.h * 0.40,
          )
          ..lineTo(
            center.dx + math.cos(angle + half) * geo.h * 0.40,
            center.dy + math.sin(angle + half) * geo.h * 0.40,
          )
          ..close(),
        paint,
      );
    }
  }

  /// گرده‌های درخشانِ شناور
  void _paintSparkles(Canvas canvas, IslandSceneGeometry geo) {
    final count = sparkleCount.clamp(0, IslandCinemaMetrics.sparkleBudget);
    for (var i = 0; i < count; i++) {
      // توزیعِ قطعی (بدون تصادف) تا بین فریم‌ها نپرد
      final seedX = (math.sin(i * 12.9898) * 43758.5453).abs() % 1.0;
      final seedY = (math.sin(i * 78.233) * 12345.6789).abs() % 1.0;
      final baseX = geo.w * (0.05 + seedX * 0.90);
      final baseY = geo.h * (0.08 + seedY * 0.62);

      final float = reduceMotion
          ? 0.0
          : math.sin((phase + i * 0.13) * 2 * math.pi) * geo.h * 0.022;
      final twinkle = reduceMotion
          ? 0.55
          : 0.35 + 0.35 * math.sin((phase + i * 0.21) * 2 * math.pi);
      final radius = math.max(1.4, geo.w * (0.0038 + (i % 3) * 0.0016));

      canvas.drawCircle(
        Offset(baseX, baseY + float),
        radius,
        Paint()
          ..color = IslandCinemaPalette.sparkle.withOpacity(0.22 * twinkle + 0.10),
        );
    }
  }

  /// تاریک‌گوشهٔ گرم برای تمرکزِ نگاه روی فندقی و دکمهٔ شروع
  void _paintVignette(Canvas canvas, IslandSceneGeometry geo) {
    final rect = Offset.zero & Size(geo.w, geo.h);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.18),
          radius: 1.05,
          colors: <Color>[
            Colors.transparent,
            IslandCinemaPalette.shade.withOpacity(0.06),
            IslandCinemaPalette.shade.withOpacity(0.26),
          ],
          stops: const <double>[0.45, 0.78, 1.0],
        ).createShader(rect),
    );
  }

  /// قابِ برگ‌هایِ پیش‌زمینه: فقط دو خوشه، تار و تیره، برای عمق
  void _paintLeafFrame(Canvas canvas, IslandSceneGeometry geo) {
    _leafCluster(
      canvas,
      Offset(-geo.w * 0.04, -geo.h * 0.02),
      geo.w * 0.34,
      -0.35,
      IslandCinemaPalette.forestDeep.withOpacity(0.62),
      geo,
    );
    _leafCluster(
      canvas,
      Offset(geo.w * 1.06, geo.h * 0.99),
      geo.w * 0.30,
      math.pi - 0.30,
      IslandCinemaPalette.forestDeep.withOpacity(0.55),
      geo,
    );
  }

  void _leafCluster(
    Canvas canvas,
    Offset anchor,
    double size,
    double rotation,
    Color color,
    IslandSceneGeometry geo,
  ) {
    final sway = reduceMotion
        ? 0.0
        : math.sin(phase * 2 * math.pi) * 0.025;
    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(rotation + sway);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[color, color.withOpacity(0.72)],
      ).createShader(Rect.fromLTWH(0, -size * 0.5, size, size));

    // ساقه
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(size * 0.45, -size * 0.10, size * 0.92, -size * 0.16),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(3.0, size * 0.045),
    );

    // برگچه‌ها
    for (var i = 0; i < 7; i++) {
      final t = i / 6;
      final x = size * (0.10 + t * 0.82);
      final y = -size * (0.02 + t * 0.14);
      final leafLen = size * (0.30 - t * 0.10);
      for (final side in <double>[-1.0, 1.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(x, y)
            ..quadraticBezierTo(
              x + leafLen * 0.55,
              y + side * leafLen * 0.62,
              x + leafLen * 0.95,
              y + side * leafLen * 0.18,
            )
            ..quadraticBezierTo(
              x + leafLen * 0.50,
              y + side * leafLen * 0.14,
              x,
              y,
            )
            ..close(),
          paint,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant IslandAtmospherePainter oldDelegate) {
    if (oldDelegate.reduceMotion != reduceMotion) return true;
    if (oldDelegate.sparkleCount != sparkleCount) return true;
    if (reduceMotion && oldDelegate.reduceMotion) return false;
    return oldDelegate.phase != phase;
  }
}
