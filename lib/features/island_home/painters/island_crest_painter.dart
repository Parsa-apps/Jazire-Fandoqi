import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/island_cinema_style.dart';

/// 🌰 نشانِ «جزیره فندقی»: فندقی (بلوط) با کلاهک و دو برگِ بلوط.
///
/// برداری کشیده می‌شود تا در هر اندازه‌ای — از آیکونِ ۲۴ پیکسل تا
/// تابلویِ بالای صفحهٔ اصلی — تیز و خوانا بماند و هیچ فایلی به APK
/// اضافه نکند.
class IslandCrestPainter extends CustomPainter {
  const IslandCrestPainter({this.acornColor});

  /// رنگِ بدنهٔ فندقی؛ پیش‌فرض نارنجیِ شخصیت است
  final Color? acornColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final bodyTop = h * 0.40;
    final bodyBottom = h * 0.94;
    final bodyHalfWidth = w * 0.235;

    _paintLeaves(canvas, size, cx, bodyTop, bodyHalfWidth);

    // ── بدنهٔ فندقی ──
    final body = Path()
      ..moveTo(cx - bodyHalfWidth, bodyTop)
      ..quadraticBezierTo(
        cx - bodyHalfWidth * 1.12,
        bodyBottom - h * 0.10,
        cx,
        bodyBottom,
      )
      ..quadraticBezierTo(
        cx + bodyHalfWidth * 1.12,
        bodyBottom - h * 0.10,
        cx + bodyHalfWidth,
        bodyTop,
      )
      ..close();

    final bodyRect =
        Rect.fromLTRB(cx - bodyHalfWidth * 1.2, bodyTop, cx + bodyHalfWidth * 1.2, bodyBottom);
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            (acornColor ?? IslandCinemaPalette.fandoqi).withOpacity(0.92),
            acornColor ?? IslandCinemaPalette.fandoqi,
            IslandCinemaPalette.fandoqiDeep,
          ],
          stops: const <double>[0.0, 0.42, 1.0],
        ).createShader(bodyRect),
    );

    // خطِ روشنِ روی بدنه (متریال)
    canvas.drawPath(
      Path()
        ..moveTo(cx - bodyHalfWidth * 0.52, bodyTop + h * 0.09)
        ..quadraticBezierTo(
          cx - bodyHalfWidth * 0.62,
          bodyBottom - h * 0.16,
          cx - bodyHalfWidth * 0.16,
          bodyBottom - h * 0.075,
        ),
      Paint()
        ..color = Colors.white.withOpacity(0.42)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(1.4, w * 0.045),
    );

    // ── کلاهک ──
    final capTop = h * 0.20;
    final capBottom = bodyTop + h * 0.10;
    final capHalf = bodyHalfWidth * 1.14;
    final cap = Path()
      ..moveTo(cx - capHalf, capBottom)
      ..quadraticBezierTo(cx - capHalf * 1.05, capTop, cx, capTop)
      ..quadraticBezierTo(cx + capHalf * 1.05, capTop, cx + capHalf, capBottom)
      ..quadraticBezierTo(cx, capBottom + h * 0.055, cx - capHalf, capBottom)
      ..close();

    canvas.drawPath(
      cap,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            IslandCinemaPalette.wood,
            IslandCinemaPalette.woodShade,
          ],
        ).createShader(
          Rect.fromLTRB(cx - capHalf, capTop, cx + capHalf, capBottom + h * 0.06),
        ),
    );

    // بافتِ کلاهک با چند خطِ کوتاه
    final texturePaint = Paint()
      ..color = IslandCinemaPalette.woodDeep.withOpacity(0.42)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, w * 0.022);
    for (var i = 0; i < 4; i++) {
      final t = i / 3;
      final x = cx - capHalf * 0.72 + t * capHalf * 1.44;
      canvas.drawLine(
        Offset(x, capTop + h * 0.045),
        Offset(x, capBottom - h * 0.012),
        texturePaint,
      );
    }

    // ── ساقه ──
    canvas.drawLine(
      Offset(cx, capTop - h * 0.005),
      Offset(cx, capTop - h * 0.085),
      Paint()
        ..color = IslandCinemaPalette.woodDeep
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(1.6, w * 0.05),
    );
  }

  void _paintLeaves(
    Canvas canvas,
    Size size,
    double cx,
    double bodyTop,
    double bodyHalfWidth,
  ) {
    for (final side in <double>[-1.0, 1.0]) {
      canvas.save();
      canvas.translate(cx + side * bodyHalfWidth * 0.92, bodyTop + size.height * 0.06);
      canvas.rotate(side * 0.55);

      final leafW = size.width * 0.225;
      final leafH = size.height * 0.155;
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(leafW * 0.55, -leafH * 0.95, leafW, -leafH * 0.12)
        ..quadraticBezierTo(leafW * 0.52, leafH * 0.62, 0, 0)
        ..close();

      canvas.drawPath(
        leaf,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              IslandCinemaPalette.meadowLight,
              IslandCinemaPalette.forest,
            ],
          ).createShader(
            Rect.fromLTWH(0, -leafH, leafW, leafH * 1.7),
          ),
      );

      // رگبرگ
      canvas.drawLine(
        Offset(0, 0),
        Offset(leafW * 0.92, -leafH * 0.14),
        Paint()
          ..color = IslandCinemaPalette.forestDeep.withOpacity(0.45)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(1.0, size.width * 0.018),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant IslandCrestPainter oldDelegate) {
    return oldDelegate.acornColor != acornColor;
  }
}
