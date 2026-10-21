import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/island_cinema_style.dart';
import 'island_scene_geometry.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌊 لایهٔ ۲ — دریای فیروزه‌ایِ زنده
///
/// موج‌ها با چند منحنیِ سینوسیِ ساده کشیده می‌شوند، نه با تصویر و نه
/// با فیزیکِ سنگین: هزینهٔ هر فریم فقط چند `Path` است، بنابراین روی
/// گوشیِ میان‌رده هم ۶۰ فریم می‌ماند.
///
/// [phase] مقداری است بین ۰ و ۱ که ویجتِ صحنه از یک کنترلرِ واحد
/// می‌گیرد؛ سرعتِ موج‌ها فقط با این مقدار تنظیم می‌شود.
/// ═══════════════════════════════════════════════════════════════
class IslandSeaPainter extends CustomPainter {
  const IslandSeaPainter({required this.phase, this.reduceMotion = false});

  /// پیشرفتِ چرخهٔ محیط (۰ تا ۱)
  final double phase;

  /// در حالتِ کاهشِ حرکت، موج‌ها ثابت می‌مانند
  final bool reduceMotion;

  static const int _waveCount = 7;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final geo = IslandSceneGeometry(size);
    final top = geo.horizon;
    final rect = Rect.fromLTWH(0, top, size.width, size.height - top);

    // ── ۱. بدنهٔ آب ──
    canvas.drawRect(
      rect,
      Paint()..shader = IslandCinemaGradients.sea.createShader(rect),
    );

    // ── ۲. درخششِ خورشید روی آب (ستونِ برق) ──
    _paintSunGlitter(canvas, geo, rect);

    // ── ۳. موج‌های موازی ──
    for (var i = 0; i < _waveCount; i++) {
      final t = i / (_waveCount - 1);
      _paintWave(canvas, geo, rect, t);
    }

    // ── ۴. تاریک‌شدنِ عمقِ پایینِ کادر (عمقِ میدان) ──
    canvas.drawRect(
      Rect.fromLTRB(
        rect.left,
        rect.bottom - geo.h * 0.16,
        rect.right,
        rect.bottom,
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            IslandCinemaPalette.seaDeep.withOpacity(0.55),
          ],
        ).createShader(
          Rect.fromLTRB(
            rect.left,
            rect.bottom - geo.h * 0.16,
            rect.right,
            rect.bottom,
          ),
        ),
    );
  }

  void _paintSunGlitter(Canvas canvas, IslandSceneGeometry geo, Rect rect) {
    final cx = geo.sunCenter.dx;
    final halfWidth = geo.w * 0.115;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          IslandCinemaPalette.sunCore.withOpacity(0.42),
          IslandCinemaPalette.sunGlow.withOpacity(0.16),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromLTRB(
          cx - halfWidth,
          rect.top,
          cx + halfWidth,
          rect.top + geo.h * 0.34,
        ),
      );

    canvas.drawPath(
      Path()
        ..moveTo(cx - geo.w * 0.012, rect.top)
        ..lineTo(cx + geo.w * 0.012, rect.top)
        ..lineTo(cx + halfWidth, rect.top + geo.h * 0.34)
        ..lineTo(cx - halfWidth, rect.top + geo.h * 0.34)
        ..close(),
      paint,
    );

    // خطوطِ برقِ کوتاه که با موج بالا و پایین می‌روند
    final dashPaint = Paint()
      ..color = IslandCinemaPalette.foam.withOpacity(0.55)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.2, geo.w * 0.005);

    for (var i = 0; i < 6; i++) {
      final t = i / 5;
      final y = rect.top + geo.h * (0.035 + t * 0.25);
      final drift = reduceMotion
          ? 0.0
          : math.sin((phase * 2 * math.pi) + i * 1.7) * geo.w * 0.012;
      final half = geo.w * (0.018 + t * 0.055);
      canvas.drawLine(
        Offset(cx - half + drift, y),
        Offset(cx + half + drift, y),
        dashPaint,
      );
    }
  }

  void _paintWave(Canvas canvas, IslandSceneGeometry geo, Rect rect, double t) {
    final y = rect.top + (rect.height - geo.h * 0.02) * t + geo.h * 0.012;
    final amplitude = geo.h * (0.0035 + t * 0.0125);
    final wavelength = geo.w * (0.55 + t * 0.35);
    final drift = reduceMotion ? 0.0 : phase * wavelength;
    final alpha = 0.10 + t * 0.20;

    final path = Path();
    path.moveTo(rect.left - wavelength, y);
    for (var x = rect.left - wavelength;
        x <= rect.right + wavelength;
        x += wavelength / 12) {
      final value = math.sin(((x + drift) / wavelength) * 2 * math.pi);
      path.lineTo(x, y + value * amplitude);
    }

    final strokePaint = Paint()
      ..color = IslandCinemaPalette.foam.withOpacity(alpha)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, geo.h * (0.0018 + t * 0.0042));
    canvas.drawPath(path, strokePaint);

    // موجِ دومِ هم‌فاز و کمی پایین‌تر: حسِ لایه‌لایه‌بودنِ آب
    if (t > 0.45) {
      final soft = Paint()
        ..color = IslandCinemaPalette.seaFar.withOpacity(alpha * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(1.0, geo.h * 0.0026);
      canvas.drawPath(path.shift(Offset(0, amplitude * 1.6)), soft);
    }
  }

  @override
  bool shouldRepaint(covariant IslandSeaPainter oldDelegate) {
    if (oldDelegate.reduceMotion != reduceMotion) return true;
    if (reduceMotion && oldDelegate.reduceMotion) return false;
    return oldDelegate.phase != phase;
  }
}
