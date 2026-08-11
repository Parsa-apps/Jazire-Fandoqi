import 'dart:math' show pi, sin;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ═══════════════════════════════════════════════════════════
/// 🪟 GLASS CARD — کارت شیشه‌ای حرفه‌ای
/// با افکت بلور، حاشیه نورانی و انیمیشن‌های پریمیوم
/// ═══════════════════════════════════════════════════════════

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool enableHaptic;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.blur = 16,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.onTap,
    this.enableHaptic = true,
    this.shadows,
    this.gradient,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
        (isDark 
            ? Colors.white.withOpacity(0.08) 
            : Colors.white.withOpacity(0.7));

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? 
                    (isDark 
                        ? Colors.white.withOpacity(0.15) 
                        : Colors.white.withOpacity(0.8)),
                width: borderWidth,
              ),
              boxShadow: shadows,
              gradient: gradient,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          if (enableHaptic) HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: card.animate().scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: 100.ms,
        ),
      );
    }

    return card;
  }
}

/// ═══════════════════════════════════════════════════════════
/// ✨ GLOWING BUTTON — دکمه درخشان با افکت نور
/// ═══════════════════════════════════════════════════════════

class GlowingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color glowColor;
  final double glowRadius;
  final double borderRadius;
  final EdgeInsets? padding;
  final bool isLoading;
  final bool isEnabled;

  const GlowingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.gradient,
    this.glowColor = const Color(0xFF6C5CE7),
    this.glowRadius = 20,
    this.borderRadius = 20,
    this.padding,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _pulseController.value * 0.3;
        
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.isEnabled && !widget.isLoading
              ? () {
                  HapticFeedback.heavyImpact();
                  widget.onPressed?.call();
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
            padding: widget.padding ?? 
                const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              gradient: widget.gradient ?? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.glowColor,
                  widget.glowColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(0.4 + pulseValue),
                  blurRadius: widget.glowRadius + pulseValue * 10,
                  spreadRadius: pulseValue * 3,
                ),
                BoxShadow(
                  color: widget.glowColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconTheme(
                      data: const IconThemeData(color: Colors.white),
                      child: widget.child,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🎯 PROGRESS RING — حلقه پیشرفت متحرک
/// ═══════════════════════════════════════════════════════════

class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Gradient? progressGradient;
  final Widget? child;
  final bool showPercentage;
  final Duration animationDuration;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 10,
    this.backgroundColor,
    this.progressGradient,
    this.child,
    this.showPercentage = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _ProgressRingPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                  backgroundColor: backgroundColor ?? 
                      (isDark 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.grey.withOpacity(0.2)),
                  progressGradient: progressGradient,
                ),
              ),
              if (child != null) child!,
              if (showPercentage && child == null)
                Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Gradient? progressGradient;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    this.progressGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (progressGradient != null) {
        final rect = Rect.fromCircle(center: center, radius: radius);
        progressPaint.shader = progressGradient!.createShader(rect);
      } else {
        progressPaint.color = const Color(0xFF6C5CE7);
      }

      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🌊 WAVE DECORATION — تزئینات موج‌دار
/// ═══════════════════════════════════════════════════════════

class WaveDecoration extends StatefulWidget {
  final Color color;
  final double height;
  final bool isAnimated;
  final int waveCount;

  const WaveDecoration({
    super.key,
    this.color = const Color(0xFF6C5CE7),
    this.height = 60,
    this.isAnimated = true,
    this.waveCount = 3,
  });

  @override
  State<WaveDecoration> createState() => _WaveDecorationState();
}

class _WaveDecorationState extends State<WaveDecoration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.isAnimated) {
      _controller.repeat();
    }
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
          size: Size(double.infinity, widget.height),
          painter: _WavePainter(
            progress: _controller.value,
            color: widget.color,
            waveCount: widget.waveCount,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int waveCount;

  _WavePainter({
    required this.progress,
    required this.color,
    required this.waveCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < waveCount; i++) {
      final waveProgress = (progress + i * 0.33) % 1.0;
      final opacity = (1 - i / waveCount * 0.7).clamp(0.2, 1.0);
      final yOffset = i * (size.height / waveCount) * 0.4;
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, size.height);

      for (var x = 0.0; x <= size.width; x += 1) {
        final normalizedX = x / size.width;
        final waveHeight = (size.height / waveCount) * 0.3;
        final y = size.height - yOffset - 
            sin((normalizedX + waveProgress) * 2 * pi) * waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🔮 NEON TEXT — متن نئون درخشان
/// ═══════════════════════════════════════════════════════════

class NeonText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double glowRadius;
  final bool isAnimated;

  const NeonText({
    super.key,
    required this.text,
    this.style,
    this.glowColor = const Color(0xFF6C5CE7),
    this.glowRadius = 8,
    this.isAnimated = true,
  });

  @override
  State<NeonText> createState() => _NeonTextState();
}

class _NeonTextState extends State<NeonText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    }
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
        final glowIntensity = widget.isAnimated 
            ? 0.5 + _controller.value * 0.5 
            : 1.0;

        return Text(
          widget.text,
          style: (widget.style ?? Theme.of(context).textTheme.headlineMedium)
              ?.copyWith(
            shadows: [
              Shadow(
                color: widget.glowColor.withOpacity(glowIntensity),
                blurRadius: widget.glowRadius,
              ),
              Shadow(
                color: widget.glowColor.withOpacity(glowIntensity * 0.5),
                blurRadius: widget.glowRadius * 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
