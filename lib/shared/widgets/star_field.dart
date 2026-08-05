import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// ✨ Animated Star Field Background
/// Creates a beautiful twinkling star background
/// ═══════════════════════════════════════════════
class StarFieldBackground extends StatefulWidget {
  final int starCount;
  final List<Color> colors;
  
  const StarFieldBackground({
    super.key,
    this.starCount = 60,
    this.colors = const [
      Color(0xFF6C5CE7),
      Color(0xFFA29BFE),
      Color(0xFF00CEC9),
      Color(0xFFFFDCB6E),
      Color(0xFFFF7675),
      Color(0xFFFFFFFF),
    ],
  });

  @override
  State<StarFieldBackground> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarFieldBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Star> _stars;
  final _rng = Random(42);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _stars = List.generate(widget.starCount, (_) => _Star(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: _rng.nextDouble() * 3 + 1,
      color: widget.colors[_rng.nextInt(widget.colors.length)],
      speed: _rng.nextDouble() * 0.5 + 0.1,
      phase: _rng.nextDouble() * 2 * pi,
    ));
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
      builder: (_, __) => CustomPaint(
        painter: _StarPainter(_stars, _ctrl.value),
        size: Size.infinite,
      ),
    );
  }
}

class _Star {
  final double x, y, size, speed, phase;
  final Color color;
  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.phase,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress;
  _StarPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final opacity = (sin(progress * 2 * pi * star.speed + star.phase) + 1) / 2;
      final paint = Paint()
        ..color = star.color.withOpacity(0.3 + opacity * 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 0.5);
      
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * (0.8 + opacity * 0.4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
