import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// 🌊 WATER PAINTER — Animated Ocean Waves
/// Beautiful layered waves with transparency
/// ═══════════════════════════════════════════════
class WaterPainter extends CustomPainter {
  final double progress; // 0..1 animation value
  final double waterLevel; // 0..1 where water starts

  WaterPainter({
    required this.progress,
    this.waterLevel = 0.55,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final waterY = h * waterLevel;

    // Deep water gradient
    _drawDeepWater(canvas, w, h, waterY);

    // Wave layers (back to front)
    _drawWave(canvas, w, h, waterY, 
      amplitude: 18, frequency: 0.8, speed: 1.0, 
      color: const Color(0xFF1565C0).withOpacity(0.4),
      yOffset: 30,
    );
    _drawWave(canvas, w, h, waterY,
      amplitude: 14, frequency: 1.2, speed: -0.7,
      color: const Color(0xFF1976D2).withOpacity(0.5),
      yOffset: 15,
    );
    _drawWave(canvas, w, h, waterY,
      amplitude: 10, frequency: 1.5, speed: 1.3,
      color: const Color(0xFF2196F3).withOpacity(0.6),
      yOffset: 0,
    );
    _drawWave(canvas, w, h, waterY,
      amplitude: 8, frequency: 2.0, speed: -1.0,
      color: const Color(0xFF42A5F5).withOpacity(0.5),
      yOffset: -10,
    );

    // Foam/sparkle on water surface
    _drawWaterSparkles(canvas, w, waterY);

    // Light reflections
    _drawReflections(canvas, w, waterY);
  }

  void _drawDeepWater(Canvas canvas, double w, double h, double waterY) {
    final rect = Rect.fromLTWH(0, waterY, w, h - waterY);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1976D2).withOpacity(0.7),
          const Color(0xFF0D47A1).withOpacity(0.85),
          const Color(0xFF0A2472).withOpacity(0.95),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawWave(
    Canvas canvas, double w, double h, double waterY, {
    required double amplitude,
    required double frequency,
    required double speed,
    required Color color,
    required double yOffset,
  }) {
    final path = Path();
    final baseY = waterY + yOffset;
    final phase = progress * 2 * pi * speed;

    path.moveTo(0, h);
    for (double x = 0; x <= w; x += 2) {
      final y = baseY +
          sin((x / w * frequency * 2 * pi) + phase) * amplitude +
          sin((x / w * frequency * 1.3 * pi) + phase * 0.7) * (amplitude * 0.3);
      path.lineTo(x, y);
    }
    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawWaterSparkles(Canvas canvas, double w, double waterY) {
    final rng = Random(42);
    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * w;
      final y = waterY + rng.nextDouble() * 15;
      final phase = (progress * 2 * pi + rng.nextDouble() * 2 * pi);
      final opacity = (sin(phase) + 1) / 2 * 0.6;

      canvas.drawCircle(
        Offset(x, y + sin(phase * 0.5) * 3),
        2 + opacity * 2,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  void _drawReflections(Canvas canvas, double w, double waterY) {
    final rng = Random(123);
    for (int i = 0; i < 8; i++) {
      final x = rng.nextDouble() * w;
      final lineW = 20 + rng.nextDouble() * 40;
      final y = waterY + 20 + rng.nextDouble() * 40;
      final phase = progress * 2 * pi * (0.5 + rng.nextDouble() * 0.5);
      final opacity = (sin(phase) + 1) / 2 * 0.15;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, lineW, 2),
          const Radius.circular(1),
        ),
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
