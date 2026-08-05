import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// ☁️ SKY PAINTER — Animated Sky with Clouds
/// Gradient sky, floating clouds, sun rays
/// ═══════════════════════════════════════════════
class SkyPainter extends CustomPainter {
  final double progress; // animation 0..1
  final double scrollOffset; // parallax offset

  SkyPainter({
    required this.progress,
    this.scrollOffset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient
    _drawSkyGradient(canvas, w, h);

    // Sun with glow
    _drawSun(canvas, w, h);

    // Sun rays
    _drawSunRays(canvas, w, h);

    // Clouds (back layer - parallax slower)
    _drawCloud(canvas, w, h,
      baseX: -50 + (progress * 40) % (w + 200),
      y: h * 0.08,
      scale: 1.2,
      opacity: 0.25,
    );
    _drawCloud(canvas, w, h,
      baseX: w * 0.3 + (progress * 60) % (w + 200),
      y: h * 0.15,
      scale: 0.9,
      opacity: 0.3,
    );
    _drawCloud(canvas, w, h,
      baseX: w * 0.7 + (progress * 35) % (w + 200),
      y: h * 0.05,
      scale: 1.5,
      opacity: 0.2,
    );

    // Clouds (front layer - parallax faster)
    _drawCloud(canvas, w, h,
      baseX: w * 0.1 + (progress * 80) % (w + 200),
      y: h * 0.22,
      scale: 0.7,
      opacity: 0.4,
    );
    _drawCloud(canvas, w, h,
      baseX: w * 0.5 + (progress * 90) % (w + 200),
      y: h * 0.18,
      scale: 1.0,
      opacity: 0.35,
    );

    // Distant birds
    _drawBirds(canvas, w, h);
  }

  void _drawSkyGradient(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(0, 0, w, h);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A237E), // Deep blue top
          Color(0xFF4FC3F7), // Light blue mid
          Color(0xFF81D4FA), // Very light blue
          Color(0xFFB3E5FC), // Near horizon
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawSun(Canvas canvas, double w, double h) {
    final sunX = w * 0.8;
    final sunY = h * 0.12;
    final sunR = 35.0;

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withOpacity(0.3),
          Colors.orange.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: sunR * 3));
    canvas.drawCircle(Offset(sunX, sunY), sunR * 3, glowPaint);

    // Sun body
    canvas.drawCircle(
      Offset(sunX, sunY),
      sunR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF9C4),
            const Color(0xFFFFD54F),
            const Color(0xFFFFB300),
          ],
        ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: sunR)),
    );
  }

  void _drawSunRays(Canvas canvas, double w, double h) {
    final sunX = w * 0.8;
    final sunY = h * 0.12;
    final rayPhase = progress * 2 * pi;

    for (int i = 0; i < 12; i++) {
      final angle = (i * pi / 6) + rayPhase * 0.3;
      final length = 60 + sin(rayPhase + i) * 20;
      final opacity = 0.05 + sin(rayPhase + i * 0.5) * 0.03;

      canvas.drawLine(
        Offset(sunX + cos(angle) * 40, sunY + sin(angle) * 40),
        Offset(sunX + cos(angle) * length, sunY + sin(angle) * length),
        Paint()
          ..color = Colors.yellow.withOpacity(opacity)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawCloud(Canvas canvas, double w, double h, {
    required double baseX,
    required double y,
    required double scale,
    required double opacity,
  }) {
    // Wrap around screen
    final x = baseX % (w + 200) - 100;

    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity);

    // Cloud made of overlapping circles
    final s = scale * 30;
    canvas.drawCircle(Offset(x, y), s * 0.8, paint);
    canvas.drawCircle(Offset(x + s * 0.6, y - s * 0.3), s * 0.6, paint);
    canvas.drawCircle(Offset(x + s * 1.2, y), s * 0.7, paint);
    canvas.drawCircle(Offset(x + s * 0.4, y + s * 0.2), s * 0.5, paint);
    canvas.drawCircle(Offset(x + s * 0.9, y + s * 0.15), s * 0.55, paint);
  }

  void _drawBirds(Canvas canvas, double w, double h) {
    final rng = Random(77);
    final phase = progress * 2 * pi;

    for (int i = 0; i < 5; i++) {
      final baseX = (rng.nextDouble() * w + progress * (30 + i * 10)) % (w + 100) - 50;
      final baseY = h * 0.1 + rng.nextDouble() * h * 0.15;
      final wingPhase = sin(phase * 3 + i * 2);
      final birdSize = 4.0 + rng.nextDouble() * 3;

      final paint = Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(baseX - birdSize, baseY + wingPhase * birdSize * 0.5)
        ..quadraticBezierTo(baseX, baseY - birdSize * 0.8, baseX + birdSize, baseY + wingPhase * birdSize * 0.5);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
