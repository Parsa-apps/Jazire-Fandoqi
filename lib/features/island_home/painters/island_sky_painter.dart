import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/island_cinema_style.dart';
import 'island_scene_geometry.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌤️ لایهٔ ۱ — آسمان، خورشید، ابرها و کوه‌های دوردست
///
/// این لایه کاملاً ایستاست ([shouldRepaint] همیشه `false`) تا یک
/// گرادیانِ سنگین در هر فریم دوباره رسم نشود؛ روی گوشیِ ضعیف فقط
/// یک‌بار رسم می‌شود و بعد در حافظهٔ GPU می‌ماند.
/// ═══════════════════════════════════════════════════════════════
class IslandSkyPainter extends CustomPainter {
  const IslandSkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final geo = IslandSceneGeometry(size);
    final rect = Offset.zero & size;

    // ── ۱. گرادیانِ آسمان ──
    canvas.drawRect(
      rect,
      Paint()
        ..shader = IslandCinemaGradients.sky.createShader(
          Rect.fromLTWH(0, 0, size.width, geo.horizon + size.height * 0.02),
        ),
    );

    // ── ۲. خورشید: هاله، قرص و درخششِ مرکزی ──
    _paintSun(canvas, geo);

    // ── ۳. کوه‌های دوردستِ مه‌آلود ──
    _paintRidges(canvas, geo);

    // ── ۴. ابرهای نرم ──
    _paintCloud(canvas, geo, 0.16, 0.105, 1.00);
    _paintCloud(canvas, geo, 0.52, 0.055, 0.72);
    _paintCloud(canvas, geo, 0.88, 0.155, 0.58);
  }

  void _paintSun(Canvas canvas, IslandSceneGeometry geo) {
    final center = geo.sunCenter;
    final radius = geo.sunRadius;

    // هالهٔ بسیار ملایم — هرگز تند و چشمک‌زن
    canvas.drawCircle(
      center,
      radius * 3.4,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            IslandCinemaPalette.sunHalo.withOpacity(0.34),
            IslandCinemaPalette.sunGlow.withOpacity(0.14),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.42, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 3.4)),
    );

    canvas.drawCircle(
      center,
      radius * 1.35,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            IslandCinemaPalette.sunGlow.withOpacity(0.75),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.35)),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = IslandCinemaPalette.sunCore,
    );
    canvas.drawCircle(
      center,
      radius * 0.62,
      Paint()..color = Colors.white.withOpacity(0.85),
    );
  }

  void _paintRidges(Canvas canvas, IslandSceneGeometry geo) {
    final baseY = geo.horizon;

    // ردیفِ دور
    final far = Path()
      ..moveTo(0, baseY)
      ..lineTo(0, baseY - geo.h * 0.075)
      ..quadraticBezierTo(
        geo.w * 0.14,
        baseY - geo.h * 0.175,
        geo.w * 0.30,
        baseY - geo.h * 0.055,
      )
      ..quadraticBezierTo(
        geo.w * 0.46,
        baseY + geo.h * 0.010,
        geo.w * 0.62,
        baseY - geo.h * 0.110,
      )
      ..quadraticBezierTo(
        geo.w * 0.80,
        baseY - geo.h * 0.185,
        geo.w * 1.0,
        baseY - geo.h * 0.050,
      )
      ..lineTo(geo.w, baseY)
      ..close();
    canvas.drawPath(
      far,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            IslandCinemaPalette.ridgeFar.withOpacity(0.85),
            IslandCinemaPalette.ridgeFar.withOpacity(0.35),
          ],
        ).createShader(Rect.fromLTWH(0, baseY - geo.h * 0.19, geo.w, geo.h * 0.2)),
    );

    // ردیفِ نزدیک‌تر و کمی تیره‌تر
    final near = Path()
      ..moveTo(0, baseY)
      ..lineTo(0, baseY - geo.h * 0.030)
      ..quadraticBezierTo(
        geo.w * 0.22,
        baseY - geo.h * 0.105,
        geo.w * 0.44,
        baseY - geo.h * 0.020,
      )
      ..quadraticBezierTo(
        geo.w * 0.68,
        baseY + geo.h * 0.035,
        geo.w * 1.0,
        baseY - geo.h * 0.065,
      )
      ..lineTo(geo.w, baseY)
      ..close();
    canvas.drawPath(
      near,
      Paint()..color = IslandCinemaPalette.ridgeNear.withOpacity(0.55),
    );
  }

  void _paintCloud(
    Canvas canvas,
    IslandSceneGeometry geo,
    double xFactor,
    double yFactor,
    double scale,
  ) {
    final cx = geo.w * xFactor;
    final cy = geo.h * yFactor;
    final unit = math.min(geo.w, geo.h) * 0.055 * scale;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withOpacity(0.96),
          Colors.white.withOpacity(0.62),
        ],
      ).createShader(Rect.fromLTWH(-unit * 2.4, -unit * 1.2, unit * 4.8, unit * 2.4));

    final cloud = Path()
      ..addOval(Rect.fromCircle(center: Offset(-unit * 0.95, unit * 0.14), radius: unit * 0.72))
      ..addOval(Rect.fromCircle(center: Offset(unit * 0.10, -unit * 0.24), radius: unit * 0.98))
      ..addOval(Rect.fromCircle(center: Offset(unit * 1.15, unit * 0.22), radius: unit * 0.70))
      ..addOval(Rect.fromCircle(center: Offset(unit * 0.05, unit * 0.52), radius: unit * 0.86));
    canvas.drawPath(cloud, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant IslandSkyPainter oldDelegate) => false;
}
