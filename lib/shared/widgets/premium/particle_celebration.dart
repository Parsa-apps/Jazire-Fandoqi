import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// 🎊 PARTICLE CELEBRATION — سیستم جشن حرفه‌ای با ذرات
/// Premium Visual Effect برای جشن برد بازی
/// ═══════════════════════════════════════════════════════════

class ParticleCelebration extends StatefulWidget {
  final VoidCallback? onComplete;
  final int particleCount;
  final Duration duration;
  final List<Color> colors;
  final double intensity;

  const ParticleCelebration({
    super.key,
    this.onComplete,
    this.particleCount = 50,
    this.duration = const Duration(milliseconds: 2500),
    this.colors = const [
      Color(0xFFFF6B6B),
      Color(0xFFFF8E53),
      Color(0xFFFFD93D),
      Color(0xFF6BCB77),
      Color(0xFF4D96FF),
      Color(0xFFC084FC),
    ],
    this.intensity = 1.0,
  });

  @override
  State<ParticleCelebration> createState() => _ParticleCelebrationState();
}

class _ParticleCelebrationState extends State<ParticleCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _particles = List.generate(
      (widget.particleCount * widget.intensity).round(),
      (_) => _generateParticle(),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  _Particle _generateParticle() {
    return _Particle(
      startX: _random.nextDouble(),
      startY: _random.nextDouble() * 0.3 + 0.7,
      endX: _random.nextDouble() * 1.5 - 0.25,
      endY: _random.nextDouble() * -0.8 - 0.2,
      size: _random.nextDouble() * 12 + 4,
      color: widget.colors[_random.nextInt(widget.colors.length)],
      rotation: _random.nextDouble() * pi * 4,
      shape: _ParticleShape.values[_random.nextInt(_ParticleShape.values.length)],
      wobble: _random.nextDouble() * 0.3,
      delay: _random.nextDouble() * 0.3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

enum _ParticleShape { circle, square, star, heart, confetti }

class _Particle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final Color color;
  final double rotation;
  final _ParticleShape shape;
  final double wobble;
  final double delay;

  _Particle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.color,
    required this.rotation,
    required this.shape,
    required this.wobble,
    required this.delay,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final adjustedProgress = ((progress - particle.delay) / (1 - particle.delay))
          .clamp(0.0, 1.0);
      
      if (adjustedProgress <= 0) continue;

      final x = size.width * (particle.startX + (particle.endX - particle.startX) * adjustedProgress);
      final y = size.height * (particle.startY + (particle.endY - particle.startY) * adjustedProgress);
      
      final wobbleOffset = sin(adjustedProgress * pi * 6) * particle.wobble * size.width;
      final finalX = x + wobbleOffset;
      
      final opacity = (1 - adjustedProgress).clamp(0.0, 1.0);
      final scale = 1.0 - (adjustedProgress * 0.5);
      final rotation = particle.rotation * adjustedProgress;

      canvas.save();
      canvas.translate(finalX, y);
      canvas.rotate(rotation);
      canvas.scale(scale);

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      switch (particle.shape) {
        case _ParticleShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case _ParticleShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case _ParticleShape.star:
          _drawStar(canvas, particle.size / 2, paint);
          break;
        case _ParticleShape.heart:
          _drawHeart(canvas, particle.size, paint);
          break;
        case _ParticleShape.confetti:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 0.4,
              height: particle.size,
            ),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    const points = 5;
    final innerRadius = radius * 0.4;

    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
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

  void _drawHeart(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final s = size / 2;
    path.moveTo(0, s * 0.3);
    path.cubicTo(-s * 0.5, -s * 0.3, -s, s * 0.1, 0, s);
    path.cubicTo(s, s * 0.1, s * 0.5, -s * 0.3, 0, s * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🎆 CONFETTI OVERLAY — پوشش جشن برای کل صفحه
/// ═══════════════════════════════════════════════════════════

class ConfettiOverlay extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback? onComplete;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.isActive,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: ParticleCelebration(
                onComplete: onComplete,
                particleCount: 80,
                duration: const Duration(milliseconds: 3000),
              ),
            ),
          ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// ⭐ STAR BURST — انفجار ستاره‌ای برای امتیاز بالا
/// ═══════════════════════════════════════════════════════════

class StarBurst extends StatefulWidget {
  final Offset position;
  final int starCount;
  final VoidCallback? onComplete;

  const StarBurst({
    super.key,
    required this.position,
    this.starCount = 5,
    this.onComplete,
  });

  @override
  State<StarBurst> createState() => _StarBurstState();
}

class _StarBurstState extends State<StarBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_StarParticle> _stars;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _stars = List.generate(widget.starCount, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = _random.nextDouble() * 100 + 60;
      return _StarParticle(
        angle: angle,
        distance: distance,
        size: _random.nextDouble() * 20 + 15,
        delay: _random.nextDouble() * 0.2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      );
    });

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarBurstPainter(
            stars: _stars,
            progress: _controller.value,
            center: widget.position,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _StarParticle {
  final double angle;
  final double distance;
  final double size;
  final double delay;
  final double rotationSpeed;

  _StarParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.rotationSpeed,
  });
}

class _StarBurstPainter extends CustomPainter {
  final List<_StarParticle> stars;
  final double progress;
  final Offset center;

  _StarBurstPainter({
    required this.stars,
    required this.progress,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final adjustedProgress = ((progress - star.delay) / (1 - star.delay))
          .clamp(0.0, 1.0);
      
      if (adjustedProgress <= 0) continue;

      final distance = star.distance * adjustedProgress;
      final x = center.dx + cos(star.angle) * distance;
      final y = center.dy + sin(star.angle) * distance;
      
      final opacity = (1 - adjustedProgress).clamp(0.0, 1.0);
      final scale = 1.0 - (adjustedProgress * 0.7);
      final rotation = star.rotationSpeed * adjustedProgress;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.scale(scale);

      final paint = Paint()
        ..color = Colors.amber.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Draw star
      final path = Path();
      const points = 5;
      final radius = star.size / 2;
      final innerRadius = radius * 0.4;

      for (var i = 0; i < points * 2; i++) {
        final r = i.isEven ? radius : innerRadius;
        final angle = (i * pi / points) - pi / 2;
        final px = cos(angle) * r;
        final py = sin(angle) * r;
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      
      // Glow effect
      canvas.drawShadow(path, Colors.amber, 8, true);
      canvas.drawPath(path, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _StarBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
