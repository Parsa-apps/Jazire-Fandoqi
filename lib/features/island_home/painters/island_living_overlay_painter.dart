import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lightweight moving details above the opaque home artwork. Coordinates follow
/// the asset's centered BoxFit.cover, so water never drifts onto the mascot.
class IslandLivingOverlayPainter extends CustomPainter {
  IslandLivingOverlayPainter({
    required this.animation,
    this.reduceMotion = false,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final bool reduceMotion;

  static const artworkSize = Size(1072, 1920);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scale = math.max(
      size.width / artworkSize.width,
      size.height / artworkSize.height,
    );
    final t = reduceMotion ? 0.0 : animation.value;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(
      (size.width - artworkSize.width * scale) / 2,
      (size.height - artworkSize.height * scale) / 2,
    );
    canvas.scale(scale);
    _rainbow(canvas, t);
    _sun(canvas, t);
    _clouds(canvas, t);
    _water(canvas, t);
    _birds(canvas, t);
    canvas.restore();
  }

  void _rainbow(Canvas canvas, double t) {
    const colors = <Color>[
      Color(0xFFFF8585), Color(0xFFFFBD75), Color(0xFFFFEB92),
      Color(0xFF9AE3AC), Color(0xFF88D9FF), Color(0xFFA4B3FF),
      Color(0xFFD4A6EF),
    ];
    final opacity = 0.23 + 0.05 * math.sin(t * 2 * math.pi);
    for (var i = 0; i < colors.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(510, 625), radius: 350 - i * 10.0),
        math.pi, math.pi, false,
        Paint()
          ..color = colors[i].withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11,
      );
    }
  }

  void _sun(Canvas canvas, double t) {
    const center = Offset(825, 165);
    canvas.drawCircle(
      center, 112,
      Paint()..shader = const RadialGradient(
        colors: <Color>[Color(0x80FFF1AC), Color(0x00FFF1AC)],
      ).createShader(Rect.fromCircle(center: center, radius: 112)),
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(t * 2 * math.pi);
    final ray = Paint()
      ..color = const Color(0xFFFFE7A0).withOpacity(0.7)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      canvas.drawLine(
        Offset(math.cos(a) * 54, math.sin(a) * 54),
        Offset(math.cos(a) * 69, math.sin(a) * 69), ray,
      );
    }
    canvas.restore();
    canvas.drawCircle(center, 41, Paint()..color = const Color(0xFFFFEAA4));
    canvas.drawCircle(
      center + const Offset(-9, -10), 25,
      Paint()..color = const Color(0xFFFFF5CB).withOpacity(0.7),
    );
  }

  void _clouds(Canvas canvas, double t) {
    for (var i = 0; i < 4; i++) {
      // Clouds wrap only while completely outside the artwork.
      final x = ((i * 0.29 + t) % 1.0) * 1492 - 210;
      final y = 160.0 + (i % 3) * 105;
      final scale = 0.65 + (i % 3) * 0.16;
      canvas.save();
      canvas.translate(x, y + math.sin(t * 2 * math.pi + i) * 8);
      canvas.scale(scale);
      final cloud = Path()
        ..addOval(Rect.fromCenter(center: const Offset(0, 15), width: 218, height: 57))
        ..addOval(Rect.fromCircle(center: const Offset(-46, -5), radius: 38))
        ..addOval(Rect.fromCircle(center: const Offset(10, -25), radius: 50))
        ..addOval(Rect.fromCircle(center: const Offset(63, 0), radius: 34));
      canvas.drawPath(
        cloud,
        Paint()..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xD9FFFFFF), Color(0x55E2F7FF)],
        ).createShader(const Rect.fromLTWH(-110, -75, 220, 120)),
      );
      canvas.restore();
    }
  }

  void _water(Canvas canvas, double t) {
    // Central channel only: excludes cliffs, boat and foreground character.
    canvas.save();
    canvas.clipPath(Path()
      ..moveTo(370, 710)
      ..lineTo(720, 710)
      ..lineTo(670, 795)
      ..lineTo(510, 795)
      ..lineTo(510, 880)
      ..lineTo(760, 915)
      ..lineTo(790, 1010)
      ..lineTo(330, 1010)
      ..lineTo(300, 895)
      ..lineTo(370, 795)
      ..close());
    for (var i = 0; i < 27; i++) {
      final depth = i / 26;
      final y = 711 + depth * 310;
      final x = 270 + ((i * 73.0) % 460);
      final drift = math.sin(t * 4 * math.pi + i * 1.4);
      final path = Path()..moveTo(x, y + drift * 3);
      path.quadraticBezierTo(
        x + 22, y - 4 + drift * 3,
        x + 45 + depth * 35, y + drift * 3,
      );
      canvas.drawPath(path, Paint()
        ..color = Colors.white.withOpacity(0.12 + 0.10 * (0.5 + 0.5 * drift))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + depth * 1.8
        ..strokeCap = StrokeCap.round);
    }
    canvas.restore();

    // Falling highlights on the existing right-hand waterfall.
    for (var i = 0; i < 9; i++) {
      final progress = (t * 6 + i / 9) % 1.0;
      final x = 991 - progress * 29 + (i % 3) * 7;
      final y = 765 + progress * 148;
      canvas.drawLine(Offset(x, y), Offset(x - 2, y + 16),
        Paint()
          ..color = Colors.white.withOpacity(0.25 * math.sin(progress * math.pi))
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    }
  }

  void _birds(Canvas canvas, double t) {
    final paint = Paint()
      ..color = const Color(0xFF327C9D).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final x = ((t + i * 0.07) % 1) * 1232 - 80;
      final y = 440 + i * 24.0 + math.sin(t * 2 * math.pi) * 16;
      final wing = 5 + math.sin(t * 12 * math.pi + i) * 4;
      canvas.drawPath(Path()
        ..moveTo(x - 13, y - wing)
        ..quadraticBezierTo(x - 5, y - wing, x, y)
        ..quadraticBezierTo(x + 5, y - wing, x + 13, y - wing), paint);
    }
  }

  @override
  bool shouldRepaint(covariant IslandLivingOverlayPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.reduceMotion != reduceMotion;
}
