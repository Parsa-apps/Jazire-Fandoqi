import 'dart:math';
import 'package:flutter/material.dart';

// ─── Platform data model ────────────────────
class _PlatformData {
  final String emoji;
  final String name;
  final String route;
  final Color color;
  final int delay;
  final double relX;
  final double relY;

  _PlatformData(
    this.emoji, this.name, this.route, this.color,
    this.delay, this.relX, this.relY,
  );
}

// ═══════════════════════════════════════════════
// ☁️ DISTANT CLOUD PAINTER
// ═══════════════════════════════════════════════
class _DistantCloudPainter extends CustomPainter {
  final double progress;
  _DistantCloudPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final rng = Random(42);

    for (int i = 0; i < 4; i++) {
      final baseX = rng.nextDouble() * w;
      final speed = 10.0 + rng.nextDouble() * 15;
      final y = size.height * 0.05 + rng.nextDouble() * size.height * 0.15;
      final x = (baseX + progress * speed * 100) % (w + 200) - 100;
      final scale = 0.6 + rng.nextDouble() * 0.8;
      final opacity = 0.1 + rng.nextDouble() * 0.15;

      _drawCloud(canvas, x, y, scale, opacity);
    }
  }

  void _drawCloud(Canvas canvas, double x, double y, double s, double opacity) {
    final paint = Paint()..color = Colors.white.withOpacity(opacity);
    final r = 20 * s;
    canvas.drawCircle(Offset(x, y), r, paint);
    canvas.drawCircle(Offset(x + r * 0.8, y - r * 0.3), r * 0.7, paint);
    canvas.drawCircle(Offset(x + r * 1.5, y), r * 0.8, paint);
    canvas.drawCircle(Offset(x + r * 0.5, y + r * 0.2), r * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════
// ☁️ FOREGROUND CLOUD PAINTER
// ═══════════════════════════════════════════════
class _ForegroundCloudPainter extends CustomPainter {
  final double progress;
  _ForegroundCloudPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Large foreground clouds
    _drawBigCloud(canvas,
      x: (-50 + progress * 30 * 100) % (w + 300) - 150,
      y: h * 0.35,
      scale: 1.5,
      opacity: 0.12,
    );
    _drawBigCloud(canvas,
      x: (w * 0.6 + progress * 20 * 100) % (w + 300) - 150,
      y: h * 0.28,
      scale: 2.0,
      opacity: 0.08,
    );
  }

  void _drawBigCloud(Canvas canvas, {
    required double x, required double y,
    required double scale, required double opacity,
  }) {
    final paint = Paint()..color = Colors.white.withOpacity(opacity);
    final r = 40 * scale;
    canvas.drawCircle(Offset(x, y), r, paint);
    canvas.drawCircle(Offset(x + r, y - r * 0.3), r * 0.8, paint);
    canvas.drawCircle(Offset(x + r * 2, y), r * 0.9, paint);
    canvas.drawCircle(Offset(x + r * 0.5, y + r * 0.3), r * 0.6, paint);
    canvas.drawCircle(Offset(x + r * 1.5, y + r * 0.2), r * 0.7, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
