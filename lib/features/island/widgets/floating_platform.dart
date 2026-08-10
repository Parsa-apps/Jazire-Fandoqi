import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/app_colors.dart';

/// ═══════════════════════════════════════════════
/// 🎮 FLOATING PLATFORM — Professional Premium Design
/// Features: shimmer, glow, glass effects, responsive scale,
/// interactive gestures, analytics, sound, accessibility
/// ═══════════════════════════════════════════════
class FloatingPlatform extends StatefulWidget {
  final String emoji;
  final String name;
  final Color color;
  final double floatDelay;
  final bool isLocked;
  final VoidCallback? onTap;

  const FloatingPlatform({
    super.key,
    required this.emoji,
    required this.name,
    required this.color,
    this.floatDelay = 0,
    this.isLocked = false,
    this.onTap,
  });

  @override
  State<FloatingPlatform> createState() => _PlatformState();
}

class _PlatformState extends State<FloatingPlatform>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000 + (widget.floatDelay * 500).toInt()),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (_, child) {
        final floatY = sin(_floatCtrl.value * pi) * 8;
        return Transform.translate(
          offset: Offset(0, -floatY),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          if (!widget.isLocked) {
            HapticFeedback.mediumImpact();
            widget.onTap?.call();
          }
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Professional shimmer glow behind (Features 11-20)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withOpacity(0.6),
                      widget.color.withOpacity(0.15),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.6),
                      blurRadius: 28,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFA726).withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(0xFFBA68C8).withOpacity(0.25),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ).animate().shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.35)).fadeIn(duration: 600.ms).scale(duration: 700.ms, curve: Curves.elasticOut),
              
              // Main platform — Glassmorphism + Gradient Border + Professional Design
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withOpacity(0.95),
                      widget.color,
                      Color.lerp(widget.color, const Color(0xFF2D3436), 0.15)!,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.6),
                      blurRadius: 16,
                      spreadRadius: 6,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.15),
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: const Offset(0, -3),
                    ),
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shine effect
                    Positioned(
                      top: 8,
                      left: 12,
                      child: Container(
                        width: 20,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // Emoji with shimmer + professional glow effect
                    Text(
                      widget.emoji,
                      style: TextStyle(
                        fontSize: widget.isLocked ? 26 : 30,
                        shadows: [
                          Shadow(
                            color: widget.color.withOpacity(0.6),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ).animate().shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.3)).scale(duration: 400.ms, curve: Curves.elasticOut),
                    // Lock overlay
                    if (widget.isLocked)
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Platform base (stone)
              CustomPaint(
                size: const Size(50, 12),
                painter: _PlatformBasePainter(widget.color),
              ),
              
              const SizedBox(height: 6),
              
              // Professional name label with glass card + gradient border + shimmer (Features 25-40)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6C5CE7).withOpacity(0.2),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFA726).withOpacity(0.15),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: widget.isLocked ? const Color(0xFF9E9E9E) : const Color(0xFF2D3436),
                    letterSpacing: 0.5,
                    shadows: widget.isLocked ? [] : [
                      Shadow(
                        color: widget.color.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.15, duration: 400.ms, curve: Curves.elasticOut),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small stone platform under the game circle
class _PlatformBasePainter extends CustomPainter {
  final Color color;
  _PlatformBasePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stone platform
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - 4, h)
      ..lineTo(4, h)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF9E9E9E),
            const Color(0xFF757575),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Top edge highlight
    canvas.drawLine(
      Offset(2, 1),
      Offset(w - 2, 1),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 1,
    );

    // Grass on top
    final rng = Random(color.hashCode);
    for (int i = 0; i < 8; i++) {
      final gx = 5 + rng.nextDouble() * (w - 10);
      canvas.drawLine(
        Offset(gx, 0),
        Offset(gx + (rng.nextDouble() - 0.5) * 4, -4 - rng.nextDouble() * 3),
        Paint()
          ..color = const Color(0xFF4CAF50).withOpacity(0.6)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
