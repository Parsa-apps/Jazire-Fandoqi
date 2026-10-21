import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/island_cinema_style.dart';

/// سه نشانِ اصلیِ خانه که کودک «بدون خواندن» باید تشخیص بدهد.
enum IslandPathIcon {
  /// 🎮 دستهٔ بازی
  play,

  /// 📖 کتابِ بازِ آموزش (با «ا» و «۱»)
  learn,

  /// 📕 کتابِ داستانِ بسته با ستاره
  story,
}

/// 🎨 نشان‌های سه‌بعدیِ مسیرهای اصلی.
///
/// هر نشان با سه لایه کشیده می‌شود تا برجسته به نظر برسد:
/// سایهٔ زیر، بدنهٔ شیب‌دار، و هایلایتِ لبهٔ بالا. این کار ارزان‌تر و
/// تیزتر از ۱۲ آیکونِ PNG در شش چگالی است.
class PathIconPainter extends CustomPainter {
  const PathIconPainter({
    required this.icon,
    required this.baseColor,
    required this.deepColor,
  });

  final IslandPathIcon icon;
  final Color baseColor;
  final Color deepColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final unit = math.min(size.width, size.height);
    // سایهٔ نرمِ زیرِ نشان
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.90),
        width: unit * 0.72,
        height: unit * 0.13,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            deepColor.withOpacity(0.32),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, size.height * 0.90),
            width: unit * 0.72,
            height: unit * 0.13,
          ),
        ),
    );

    switch (icon) {
      case IslandPathIcon.play:
        _paintGamepad(canvas, size, unit);
      case IslandPathIcon.learn:
        _paintOpenBook(canvas, size, unit);
      case IslandPathIcon.story:
        _paintStoryBook(canvas, size, unit);
    }
  }

  Paint _body(Rect rect) => Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[baseColor, deepColor],
    ).createShader(rect);

  Paint get _highlight => Paint()
    ..color = Colors.white.withOpacity(0.42)
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  // ─── 🎮 دستهٔ بازی ───
  void _paintGamepad(Canvas canvas, Size size, double unit) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;
    final bodyW = unit * 0.86;
    final bodyH = unit * 0.46;
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: bodyW,
      height: bodyH,
    );

    // دسته‌های کناری
    for (final side in <double>[-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + side * bodyW * 0.40, cy + bodyH * 0.26),
          width: bodyW * 0.30,
          height: bodyH * 0.86,
        ),
        _body(rect),
      );
    }

    // بدنه
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(unit * 0.16)),
      _body(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(unit * 0.16)),
      Paint()
        ..color = Colors.white.withOpacity(0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = unit * 0.022,
    );

    // خطِ براقِ بالا
    canvas.drawLine(
      Offset(cx - bodyW * 0.30, cy - bodyH * 0.28),
      Offset(cx + bodyW * 0.06, cy - bodyH * 0.30),
      _highlight..strokeWidth = unit * 0.05,
    );

    // D-pad
    final padPaint = Paint()..color = Colors.white.withOpacity(0.92);
    final padX = cx - bodyW * 0.24;
    final padY = cy + bodyH * 0.02;
    final armLen = unit * 0.085;
    final armThick = unit * 0.062;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(padX, padY),
          width: armLen * 2,
          height: armThick,
        ),
        Radius.circular(armThick * 0.4),
      ),
      padPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(padX, padY),
          width: armThick,
          height: armLen * 2,
        ),
        Radius.circular(armThick * 0.4),
      ),
      padPaint,
    );

    // دو دکمهٔ رنگی
    final buttonRadius = unit * 0.055;
    canvas.drawCircle(
      Offset(cx + bodyW * 0.20, cy - bodyH * 0.10),
      buttonRadius,
      Paint()..color = IslandCinemaPalette.gold,
    );
    canvas.drawCircle(
      Offset(cx + bodyW * 0.32, cy + bodyH * 0.14),
      buttonRadius,
      Paint()..color = IslandCinemaPalette.mint,
    );
  }

  // ─── 📖 کتابِ باز: آموزش ───
  void _paintOpenBook(Canvas canvas, Size size, double unit) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.55;
    final pageW = unit * 0.36;
    final pageH = unit * 0.44;

    for (final side in <double>[-1.0, 1.0]) {
      final page = Path()
        ..moveTo(cx, cy - pageH * 0.44)
        ..quadraticBezierTo(
          cx + side * pageW * 0.62,
          cy - pageH * 0.62,
          cx + side * pageW,
          cy - pageH * 0.36,
        )
        ..lineTo(cx + side * pageW, cy + pageH * 0.42)
        ..quadraticBezierTo(
          cx + side * pageW * 0.60,
          cy + pageH * 0.20,
          cx,
          cy + pageH * 0.46,
        )
        ..close();

      canvas.drawPath(
        page,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              IslandCinemaPalette.paper,
              IslandCinemaPalette.goldLight.withOpacity(0.92),
            ],
          ).createShader(
            Rect.fromLTWH(cx - pageW, cy - pageH * 0.65, pageW * 2, pageH * 1.2),
          ),
      );

      // جلدِ زیرین (نمایِ ضخامت)
      canvas.drawPath(
        page,
        Paint()
          ..color = deepColor.withOpacity(0.30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = unit * 0.030,
      );

      // خطوطِ متنِ کتاب
      final linePaint = Paint()
        ..color = deepColor.withOpacity(0.38)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = unit * 0.026;
      for (var i = 0; i < 3; i++) {
        final y = cy - pageH * 0.10 + i * pageH * 0.16;
        canvas.drawLine(
          Offset(cx + side * pageW * 0.22, y),
          Offset(cx + side * pageW * 0.80, y - pageH * 0.03),
          linePaint,
        );
      }
    }

    // عطفِ کتاب
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - pageH * 0.44)
        ..lineTo(cx, cy + pageH * 0.46),
      Paint()
        ..color = deepColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = unit * 0.036,
    );

    // نشانه‌های «ا» (راست) و «۱» (چپ) — تفکیکِ آموزش از داستان
    final glyphPaint = Paint()
      ..color = deepColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = unit * 0.032;
    // «ا»: یک خطِ ایستاده
    canvas.drawLine(
      Offset(cx + pageW * 0.52, cy - pageH * 0.30),
      Offset(cx + pageW * 0.52, cy - pageH * 0.02),
      glyphPaint,
    );
    // «۱»: خطِ مورب با پایه
    canvas.drawLine(
      Offset(cx - pageW * 0.50, cy - pageH * 0.26),
      Offset(cx - pageW * 0.62, cy - pageH * 0.02),
      glyphPaint,
    );
  }

  // ─── 📕 کتابِ داستانِ بسته با ستاره ───
  void _paintStoryBook(Canvas canvas, Size size, double unit) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.54;
    final bookW = unit * 0.70;
    final bookH = unit * 0.62;
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: bookW,
      height: bookH,
    );

    // برآمدگیِ برگه‌ها (سمتِ راست)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.shift(Offset(unit * 0.035, 0)),
        Radius.circular(unit * 0.05),
      ),
      Paint()..color = IslandCinemaPalette.paper,
    );

    // جلد
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(unit * 0.06)),
      _body(rect),
    );

    // عطف
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(rect.left, rect.top, rect.left + unit * 0.09, rect.bottom),
        Radius.circular(unit * 0.05),
      ),
      Paint()..color = deepColor,
    );

    // خطِ براقِ جلد
    canvas.drawLine(
      Offset(rect.left + unit * 0.14, rect.top + unit * 0.10),
      Offset(rect.right - unit * 0.10, rect.top + unit * 0.06),
      _highlight..strokeWidth = unit * 0.035,
    );

    // ستاره
    _paintStar(
      canvas,
      Offset(cx + unit * 0.03, cy - unit * 0.02),
      unit * 0.15,
      Paint()..color = IslandCinemaPalette.gold,
    );

    // نشانکِ کتاب
    canvas.drawPath(
      Path()
        ..moveTo(cx + unit * 0.16, cy - bookH * 0.48)
        ..lineTo(cx + unit * 0.24, cy - bookH * 0.48)
        ..lineTo(cx + unit * 0.20, cy - bookH * 0.16)
        ..lineTo(cx + unit * 0.16, cy - bookH * 0.48)
        ..close(),
      Paint()..color = IslandCinemaPalette.mint,
    );
  }

  void _paintStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final angle = -math.pi / 2 + (i * math.pi / points);
      final r = i.isEven ? radius : radius * 0.44;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PathIconPainter oldDelegate) {
    return oldDelegate.icon != icon ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.deepColor != deepColor;
  }
}
