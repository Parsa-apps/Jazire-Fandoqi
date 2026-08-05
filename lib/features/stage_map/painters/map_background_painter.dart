import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// 🗺️ MAP BACKGROUND PAINTER
/// Grass terrain with hills, trees, clouds
/// ═══════════════════════════════════════════════
class MapBackgroundPainter extends CustomPainter {
  final double scrollY;
  final double animValue;

  MapBackgroundPainter({
    required this.scrollY,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient
    _drawSky(canvas, w, h);

    // Distant mountains (parallax slow)
    _drawMountains(canvas, w, h, scrollY * 0.1);

    // Clouds
    _drawClouds(canvas, w, h);

    // Rolling hills background (parallax medium)
    _drawHills(canvas, w, h, scrollY * 0.2);

    // Grass texture overlay
    _drawGrassOverlay(canvas, w, h);
  }

  void _drawSky(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF64B5F6),
            Color(0xFF90CAF9),
            Color(0xFFBBDEFB),
            Color(0xFFE8F5E9),
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ).createShader(rect),
    );
  }

  void _drawMountains(Canvas canvas, double w, double h, double parallax) {
    // Far mountains
    final mPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF7986CB).withOpacity(0.4),
          const Color(0xFF5C6BC0).withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.2, w, h * 0.2));

    final mPath = Path();
    mPath.moveTo(0, h * 0.4);
    for (double x = 0; x <= w; x += 2) {
      final y = h * 0.35 +
          sin((x + parallax) * 0.008) * 30 +
          sin((x + parallax) * 0.003) * 50;
      mPath.lineTo(x, y);
    }
    mPath.lineTo(w, h * 0.5);
    mPath.lineTo(0, h * 0.5);
    mPath.close();
    canvas.drawPath(mPath, mPaint);

    // Near mountains
    final m2Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF81C784).withOpacity(0.5),
          const Color(0xFF66BB6A).withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.3, w, h * 0.15));

    final m2Path = Path();
    m2Path.moveTo(0, h * 0.45);
    for (double x = 0; x <= w; x += 2) {
      final y = h * 0.42 +
          sin((x + parallax * 1.5) * 0.01) * 20 +
          sin((x + parallax * 1.5) * 0.005) * 35;
      m2Path.lineTo(x, y);
    }
    m2Path.lineTo(w, h * 0.55);
    m2Path.lineTo(0, h * 0.55);
    m2Path.close();
    canvas.drawPath(m2Path, m2Paint);
  }

  void _drawClouds(Canvas canvas, double w, double h) {
    final clouds = [
      {'x': 0.1, 'y': 0.05, 's': 1.2, 'speed': 8.0},
      {'x': 0.4, 'y': 0.08, 's': 0.9, 'speed': 12.0},
      {'x': 0.7, 'y': 0.03, 's': 1.5, 'speed': 6.0},
      {'x': 0.9, 'y': 0.12, 's': 0.7, 'speed': 10.0},
    ];

    for (final c in clouds) {
      final cx = ((c['x'] as double) * w + animValue * (c['speed'] as double) * 10) % (w + 200) - 100;
      final cy = (c['y'] as double) * h;
      final s = (c['s'] as double) * 25;
      final paint = Paint()..color = Colors.white.withOpacity(0.6);

      canvas.drawCircle(Offset(cx, cy), s, paint);
      canvas.drawCircle(Offset(cx + s * 0.7, cy - s * 0.3), s * 0.7, paint);
      canvas.drawCircle(Offset(cx + s * 1.3, cy), s * 0.8, paint);
      canvas.drawCircle(Offset(cx + s * 0.4, cy + s * 0.2), s * 0.5, paint);
    }
  }

  void _drawHills(Canvas canvas, double w, double h, double parallax) {
    final hillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF81C784).withOpacity(0.3),
          const Color(0xFF66BB6A).withOpacity(0.2),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.4, w, h * 0.15));

    final hillPath = Path();
    hillPath.moveTo(0, h * 0.55);
    for (double x = 0; x <= w; x += 2) {
      final y = h * 0.5 +
          sin((x + parallax) * 0.015) * 25 +
          sin((x + parallax * 0.7) * 0.008) * 15;
      hillPath.lineTo(x, y);
    }
    hillPath.lineTo(w, h * 0.65);
    hillPath.lineTo(0, h * 0.65);
    hillPath.close();
    canvas.drawPath(hillPath, hillPaint);
  }

  void _drawGrassOverlay(Canvas canvas, double w, double h) {
    // Subtle grass pattern
    final rng = Random(42);
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * w;
      final y = h * 0.5 + rng.nextDouble() * h * 0.5;
      final bladeH = 4 + rng.nextDouble() * 6;
      final lean = (rng.nextDouble() - 0.5) * 3;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + lean, y - bladeH),
        Paint()
          ..color = const Color(0xFF4CAF50).withOpacity(0.08)
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
