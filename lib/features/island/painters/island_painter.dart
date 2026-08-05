import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// 🏝️ ISLAND PAINTER — Floating Island
/// Main island with grass, rocks, trees, waterfall
/// ═══════════════════════════════════════════════
class IslandPainter extends CustomPainter {
  final double progress;   // animation 0..1 (looping)
  final double floatY;     // floating offset

  IslandPainter({
    required this.progress,
    this.floatY = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final islandY = h * 0.42 + floatY;

    // ─── WATERFALL from island bottom ───
    _drawWaterfall(canvas, cx, islandY + 60, h);

    // ─── ISLAND SHADOW (on water) ───
    _drawIslandShadow(canvas, cx, h * 0.58);

    // ─── ROCKS (bottom of island) ───
    _drawRockBase(canvas, cx, islandY);

    // ─── GRASS TOP ───
    _drawGrassTop(canvas, cx, islandY);

    // ─── TREES ───
    _drawTree(canvas, cx - 60, islandY - 35, scale: 1.0);
    _drawTree(canvas, cx + 50, islandY - 30, scale: 0.8);
    _drawTree(canvas, cx - 20, islandY - 45, scale: 1.2);

    // ─── BUSHES ───
    _drawBush(canvas, cx - 90, islandY - 8, 25);
    _drawBush(canvas, cx + 80, islandY - 5, 20);
    _drawBush(canvas, cx + 10, islandY - 10, 18);

    // ─── FLOWERS ───
    _drawFlowers(canvas, cx, islandY, progress);

    // ─── BUTTERFLIES ───
    _drawButterflies(canvas, cx, islandY, progress);

    // ─── SPARKLES ───
    _drawSparkles(canvas, cx, islandY, progress);
  }

  // ─── WATERFALL ──────────────────────────────
  void _drawWaterfall(Canvas canvas, double cx, double startY, double h) {
    final waterfallW = 12.0;
    final endY = h * 0.58;
    final phase = progress * 2 * pi;

    // Main waterfall stream
    for (int layer = 0; layer < 3; layer++) {
      final offset = layer * 2.0;
      final opacity = 0.3 - layer * 0.08;
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFF4FC3F7),
          const Color(0xFF81D4FA),
          layer / 3,
        )!.withOpacity(opacity);

      final path = Path();
      path.moveTo(cx - waterfallW / 2 + offset, startY);

      for (double y = startY; y <= endY; y += 4) {
        final progress = (y - startY) / (endY - startY);
        final wobble = sin(progress * 8 + phase) * (2 + progress * 3);
        final spread = progress * 6;
        path.lineTo(cx - waterfallW / 2 + wobble - spread + offset, y);
      }
      for (double y = endY; y >= startY; y -= 4) {
        final p = (y - startY) / (endY - startY);
        final wobble = sin(p * 8 + phase) * (2 + p * 3);
        final spread = p * 6;
        path.lineTo(cx + waterfallW / 2 + wobble + spread + offset, y);
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // Splash at bottom
    for (int i = 0; i < 6; i++) {
      final splashPhase = phase + i * 1.0;
      final splashX = cx + sin(splashPhase) * 15;
      final splashY = endY - 5 + cos(splashPhase * 0.7) * 3;
      final splashR = 3 + sin(splashPhase * 1.5) * 2;
      canvas.drawCircle(
        Offset(splashX, splashY),
        splashR,
        Paint()..color = Colors.white.withOpacity(0.3),
      );
    }
  }

  // ─── ISLAND SHADOW ─────────────────────────
  void _drawIslandShadow(Canvas canvas, double cx, double y) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, y), width: 220, height: 20),
      Paint()..color = Colors.black.withOpacity(0.08),
    );
  }

  // ─── ROCK BASE ─────────────────────────────
  void _drawRockBase(Canvas canvas, double cx, double y) {
    final path = Path();

    // Main rock shape
    path.moveTo(cx - 120, y + 15);
    path.quadraticBezierTo(cx - 130, y + 50, cx - 90, y + 80);
    path.quadraticBezierTo(cx - 40, y + 110, cx, y + 100);
    path.quadraticBezierTo(cx + 40, y + 110, cx + 90, y + 80);
    path.quadraticBezierTo(cx + 130, y + 50, cx + 120, y + 15);
    path.close();

    // Rock gradient
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF8D6E63),
            const Color(0xFF6D4C41),
            const Color(0xFF5D4037),
            const Color(0xFF4E342E),
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ).createShader(Rect.fromLTWH(cx - 130, y + 15, 260, 90)),
    );

    // Rock texture lines
    final linePaint = Paint()
      ..color = const Color(0xFF3E2723).withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(cx - 80, y + 30)
        ..quadraticBezierTo(cx - 50, y + 45, cx - 90, y + 60),
      linePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + 30, y + 25)
        ..quadraticBezierTo(cx + 60, y + 50, cx + 40, y + 70),
      linePaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - 20, y + 40)
        ..quadraticBezierTo(cx + 10, y + 60, cx - 10, y + 85),
      linePaint,
    );

    // Moss patches
    _drawMoss(canvas, cx - 70, y + 35, 15);
    _drawMoss(canvas, cx + 50, y + 30, 12);
    _drawMoss(canvas, cx - 10, y + 50, 10);
  }

  void _drawMoss(Canvas canvas, double x, double y, double r) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: r * 2, height: r),
      Paint()..color = const Color(0xFF558B2F).withOpacity(0.25),
    );
  }

  // ─── GRASS TOP ─────────────────────────────
  void _drawGrassTop(Canvas canvas, double cx, double y) {
    // Main grass surface
    final grassPath = Path();
    grassPath.moveTo(cx - 125, y + 15);
    grassPath.quadraticBezierTo(cx - 120, y - 5, cx - 80, y - 10);
    grassPath.quadraticBezierTo(cx - 40, y - 18, cx, y - 15);
    grassPath.quadraticBezierTo(cx + 40, y - 18, cx + 80, y - 10);
    grassPath.quadraticBezierTo(cx + 120, y - 5, cx + 125, y + 15);
    grassPath.quadraticBezierTo(cx + 80, y + 8, cx, y + 5);
    grassPath.quadraticBezierTo(cx - 80, y + 8, cx - 125, y + 15);
    grassPath.close();

    canvas.drawPath(
      grassPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF66BB6A),
            const Color(0xFF43A047),
            const Color(0xFF388E3C),
          ],
        ).createShader(Rect.fromLTWH(cx - 125, y - 18, 250, 35)),
    );

    // Grass blades on top edge
    final rng = Random(42);
    for (int i = 0; i < 40; i++) {
      final gx = cx - 110 + rng.nextDouble() * 220;
      final gy = y - 12 + rng.nextDouble() * 5;
      final bladeH = 8 + rng.nextDouble() * 12;
      final bladeLean = (rng.nextDouble() - 0.5) * 8;

      canvas.drawLine(
        Offset(gx, gy),
        Offset(gx + bladeLean, gy - bladeH),
        Paint()
          ..color = Color.lerp(
            const Color(0xFF4CAF50),
            const Color(0xFF81C784),
            rng.nextDouble(),
          )!.withOpacity(0.7)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // ─── TREES ─────────────────────────────────
  void _drawTree(Canvas canvas, double x, double y, {required double scale}) {
    final s = scale;

    // Trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 4 * s, y - 30 * s, 8 * s, 35 * s),
        Radius.circular(3 * s),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFF6D4C41), const Color(0xFF4E342E)],
        ).createShader(Rect.fromLTWH(x - 4 * s, y - 30 * s, 8 * s, 35 * s)),
    );

    // Foliage layers
    _drawFoliage(canvas, x, y - 35 * s, 28 * s, const Color(0xFF2E7D32));
    _drawFoliage(canvas, x - 5 * s, y - 45 * s, 22 * s, const Color(0xFF388E3C));
    _drawFoliage(canvas, x + 3 * s, y - 55 * s, 18 * s, const Color(0xFF43A047));
  }

  void _drawFoliage(Canvas canvas, double x, double y, double r, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          Color.lerp(color, Colors.black, 0.2)!,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r));

    canvas.drawCircle(Offset(x, y), r, paint);
    canvas.drawCircle(Offset(x - r * 0.5, y + r * 0.3), r * 0.7, paint);
    canvas.drawCircle(Offset(x + r * 0.5, y + r * 0.2), r * 0.65, paint);
    canvas.drawCircle(Offset(x, y - r * 0.4), r * 0.6, paint);
  }

  // ─── BUSHES ────────────────────────────────
  void _drawBush(Canvas canvas, double x, double y, double r) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF66BB6A),
          const Color(0xFF388E3C),
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r));

    canvas.drawCircle(Offset(x, y), r, paint);
    canvas.drawCircle(Offset(x - r * 0.6, y + r * 0.1), r * 0.7, paint);
    canvas.drawCircle(Offset(x + r * 0.6, y + r * 0.15), r * 0.65, paint);
  }

  // ─── FLOWERS ───────────────────────────────
  void _drawFlowers(Canvas canvas, double cx, double y, double anim) {
    final flowers = [
      {'x': -80.0, 'y': -12.0, 'color': const Color(0xFFFF5252), 'size': 5.0},
      {'x': -40.0, 'y': -14.0, 'color': const Color(0xFFFFD740), 'size': 4.0},
      {'x': 30.0, 'y': -13.0, 'color': const Color(0xFFE040FB), 'size': 5.0},
      {'x': 70.0, 'y': -10.0, 'color': const Color(0xFF40C4FF), 'size': 4.5},
      {'x': -10.0, 'y': -16.0, 'color': const Color(0xFFFF6E40), 'size': 4.0},
      {'x': 50.0, 'y': -11.0, 'color': const Color(0xFFB388FF), 'size': 3.5},
    ];

    for (final f in flowers) {
      final fx = cx + (f['x'] as double);
      final fy = y + (f['y'] as double);
      final fs = f['size'] as double;
      final fc = f['color'] as Color;
      final sway = sin(anim * 2 * pi + fx * 0.1) * 2;

      // Stem
      canvas.drawLine(
        Offset(fx, fy),
        Offset(fx + sway * 0.5, fy + 8),
        Paint()
          ..color = const Color(0xFF4CAF50)
          ..strokeWidth = 1.5,
      );

      // Petals
      for (int p = 0; p < 5; p++) {
        final angle = (p * 2 * pi / 5) + anim * pi;
        canvas.drawCircle(
          Offset(fx + cos(angle) * fs + sway, fy + sin(angle) * fs),
          fs * 0.6,
          Paint()..color = fc.withOpacity(0.8),
        );
      }

      // Center
      canvas.drawCircle(
        Offset(fx + sway, fy),
        fs * 0.35,
        Paint()..color = Colors.yellow,
      );
    }
  }

  // ─── BUTTERFLIES ───────────────────────────
  void _drawButterflies(Canvas canvas, double cx, double y, double anim) {
    final butterflies = [
      {'x': -100.0, 'y': -60.0, 'color': const Color(0xFFFF80AB)},
      {'x': 80.0, 'y': -80.0, 'color': const Color(0xFFB388FF)},
      {'x': -30.0, 'y': -100.0, 'color': const Color(0xFF80D8FF)},
    ];

    for (int i = 0; i < butterflies.length; i++) {
      final b = butterflies[i];
      final bx = cx + (b['x'] as double) + sin(anim * 2 * pi + i * 2) * 20;
      final by = y + (b['y'] as double) + cos(anim * 2 * pi + i * 1.5) * 10;
      final bc = b['color'] as Color;
      final wingPhase = sin(anim * 6 * pi + i * 3);
      final wingAngle = wingPhase * 0.5;

      canvas.save();
      canvas.translate(bx, by);

      // Left wing
      canvas.save();
      canvas.rotate(-wingAngle);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-4, 0), width: 10, height: 7),
        Paint()..color = bc.withOpacity(0.7),
      );
      canvas.restore();

      // Right wing
      canvas.save();
      canvas.rotate(wingAngle);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(4, 0), width: 10, height: 7),
        Paint()..color = bc.withOpacity(0.7),
      );
      canvas.restore();

      // Body
      canvas.drawCircle(Offset.zero, 2, Paint()..color = const Color(0xFF424242));

      canvas.restore();
    }
  }

  // ─── SPARKLES ──────────────────────────────
  void _drawSparkles(Canvas canvas, double cx, double y, double anim) {
    final rng = Random(99);
    for (int i = 0; i < 12; i++) {
      final sx = cx - 100 + rng.nextDouble() * 200;
      final sy = y - 80 + rng.nextDouble() * 60;
      final phase = anim * 2 * pi + rng.nextDouble() * 2 * pi;
      final opacity = (sin(phase) + 1) / 2 * 0.6;
      final sparkSize = 2 + sin(phase) * 1;

      if (opacity > 0.1) {
        _drawStar4(canvas, Offset(sx, sy), sparkSize, opacity);
      }
    }
  }

  void _drawStar4(Canvas canvas, Offset center, double size, double opacity) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
