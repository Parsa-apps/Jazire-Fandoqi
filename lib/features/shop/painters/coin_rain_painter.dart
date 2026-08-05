import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// 🌧️ COIN RAIN PAINTER — Purchase Celebration
/// Golden coins rain + sparkle explosion
/// ═══════════════════════════════════════════════
class CoinRainPainter extends CustomPainter {
  final double progress; // 0..1
  final Offset center;
  final List<_CoinParticle> _coins;
  final List<_Sparkle> _sparkles;
  final _rng = Random(42);

  CoinRainPainter({
    required this.progress,
    required this.center,
  })  : _coins = List.generate(30, (i) => _CoinParticle(
          x: Random(i).nextDouble() * 400 - 200,
          speed: 80 + Random(i).nextDouble() * 120,
          size: 12 + Random(i).nextDouble() * 10,
          rotation: Random(i).nextDouble() * 2 * pi,
          rotSpeed: Random(i).nextDouble() * 4 - 2,
          delay: Random(i).nextDouble() * 0.3,
        )),
        _sparkles = List.generate(20, (i) => _Sparkle(
          angle: Random(i + 50).nextDouble() * 2 * pi,
          speed: 60 + Random(i + 50).nextDouble() * 140,
          size: 3 + Random(i + 50).nextDouble() * 5,
          delay: Random(i + 50).nextDouble() * 0.1,
        ));

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    // ─── SPARKLE EXPLOSION ───
    _drawSparkles(canvas, size);

    // ─── COIN RAIN ───
    _drawCoins(canvas, size);
  }

  void _drawSparkles(Canvas canvas, Size size) {
    for (final s in _sparkles) {
      final t = ((progress - s.delay) / (1 - s.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final opacity = (1 - t).clamp(0.0, 1.0);
      final dist = s.speed * t;
      final x = center.dx + cos(s.angle) * dist;
      final y = center.dy + sin(s.angle) * dist - 50 * t;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 4);

      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFD700),
          const Color(0xFFFF8E53),
          t,
        )!.withOpacity(opacity);

      // Star shape
      _drawStar(canvas, s.size * (1 - t * 0.5), paint);

      canvas.restore();
    }
  }

  void _drawCoins(Canvas canvas, Size size) {
    for (final c in _coins) {
      final t = ((progress - c.delay) / (1 - c.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = center.dx + c.x;
      final y = -50 + c.speed * t * 3;
      final opacity = (1 - t * 0.7).clamp(0.0, 1.0);

      if (y > size.height + 50) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.rotation + c.rotSpeed * t * 5);

      // Coin body
      final coinPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(opacity),
            const Color(0xFFFFA000).withOpacity(opacity),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: c.size));

      canvas.drawCircle(Offset.zero, c.size, coinPaint);

      // Coin border
      canvas.drawCircle(
        Offset.zero,
        c.size,
        Paint()
          ..color = const Color(0xFFB8860B).withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Coin shine
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(-c.size * 0.2, -c.size * 0.2),
          width: c.size * 0.6,
          height: c.size * 0.4,
        ),
        Paint()..color = Colors.white.withOpacity(0.3 * opacity),
      );

      // Coin symbol
      final tp = TextPainter(
        text: TextSpan(
          text: '💰',
          style: TextStyle(fontSize: c.size * 0.8),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final outer = Offset(cos(angle) * size, sin(angle) * size);
      final inner = Offset(cos(angle + pi / 4) * size * 0.3, sin(angle + pi / 4) * size * 0.3);
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CoinParticle {
  final double x, speed, size, rotation, rotSpeed, delay;
  _CoinParticle({
    required this.x,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotSpeed,
    required this.delay,
  });
}

class _Sparkle {
  final double angle, speed, size, delay;
  _Sparkle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.delay,
  });
}

/// ═══════════════════════════════════════════════
/// ✨ ITEM GLOW PAINTER — Purchased item glow
/// Pulsing glow effect around an item
/// ═══════════════════════════════════════════════
class ItemGlowPainter extends CustomPainter {
  final Color color;
  final double progress; // 0..1 pulsing

  ItemGlowPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy);
    final glowR = r + 10 + sin(progress * 2 * pi) * 8;

    canvas.drawCircle(
      Offset(cx, cy),
      glowR,
      Paint()
        ..color = color.withOpacity(0.15 + sin(progress * 2 * pi) * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
