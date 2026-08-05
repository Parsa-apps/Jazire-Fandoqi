import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// 🎉 Particle Celebration Effect
/// Beautiful confetti/particle explosion
/// ═══════════════════════════════════════════════
class ParticleCelebration extends StatefulWidget {
  final bool trigger;
  final int particleCount;
  final List<Color> colors;
  final Duration duration;

  const ParticleCelebration({
    super.key,
    this.trigger = false,
    this.particleCount = 30,
    this.colors = const [
      Color(0xFFFFD700),
      Color(0xFFFF6B6B),
      Color(0xFF6C5CE7),
      Color(0xFF00CEC9),
      Color(0xFFFF8E53),
      Color(0xFFA29BFE),
    ],
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ParticleCelebration> createState() => _ParticleState();
}

class _ParticleState extends State<ParticleCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  List<_Particle> _particles = [];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _particles.clear());
        }
      });
  }

  @override
  void didUpdateWidget(ParticleCelebration old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) _burst();
  }

  void _burst() {
    _particles = List.generate(widget.particleCount, (_) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = _rng.nextDouble() * 200 + 100;
      return _Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 150,
        color: widget.colors[_rng.nextInt(widget.colors.length)],
        size: _rng.nextDouble() * 8 + 4,
        shape: _rng.nextInt(3), // 0=circle, 1=square, 2=star
        rotation: _rng.nextDouble() * 2 * pi,
        rotSpeed: _rng.nextDouble() * 8 - 4,
      );
    });
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        if (_particles.isEmpty) return const SizedBox.shrink();
        return CustomPaint(
          painter: _ParticlePainter(_particles, _ctrl.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double vx, vy, size, rotation, rotSpeed;
  Color color;
  int shape;
  _Particle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.shape,
    required this.rotation,
    required this.rotSpeed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final gravity = 300.0;

    for (final p in particles) {
      final dt = t;
      final x = cx + p.vx * dt;
      final y = cy + p.vy * dt + 0.5 * gravity * dt * dt;
      final opacity = (1 - t).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotSpeed * t);

      switch (p.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset.zero, p.size * (1 - t * 0.3), paint);
          break;
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * 1.5 * (1 - t * 0.3),
              height: p.size * 1.5 * (1 - t * 0.3),
            ),
            paint,
          );
          break;
        case 2: // Star
          _drawStar(canvas, p.size * (1 - t * 0.3), paint);
          break;
      }
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - pi / 2;
      final x = cos(angle) * r;
      final y = sin(angle) * r;
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
  bool shouldRepaint(covariant CustomPainter old) => true;
}
