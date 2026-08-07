import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/app_colors.dart';

/// ═══════════════════════════════════════════════
/// 🎮 FLOATING PLATFORM — Game Entry Point
/// Animated floating platform with game info
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
              // Glow effect behind
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              
              // Main platform
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withOpacity(0.9),
                      widget.color,
                      Color.lerp(widget.color, Colors.black, 0.2)!,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
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
                    // Emoji
                    Text(
                      widget.emoji,
                      style: TextStyle(
                        fontSize: widget.isLocked ? 24 : 28,
                      ),
                    ),
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
              
              // Name label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.isLocked
                        ? AppColors.textLight
                        : AppColors.textPrimary,
                  ),
                ),
              ),
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
