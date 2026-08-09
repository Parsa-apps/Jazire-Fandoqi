import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// 🪟 Glassmorphism Card Widget
/// Beautiful frosted glass effect card
/// ═══════════════════════════════════════════════
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final double opacity;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 28,
    this.opacity = 0.15,
    this.borderColor,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(opacity + 0.1),
              Colors.white.withOpacity(opacity),
            ],
          ),
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glass card with colored gradient background
class GradientGlassCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GradientGlassCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 28,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: (gradient.colors.first).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
