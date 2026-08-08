import 'package:flutter/material.dart';
import '../../../core/premium_animations.dart';

/// =======================================================
/// ✨ PREMIUM GLASS CARD — طراحی لوکس و کودک‌پسند
/// =======================================================
class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final double elevation;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius = 28,
    this.color,
    this.elevation = 12,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: elevation,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );

    if (onTap != null) {
      return PremiumAnimations.premiumCard(
        onTap: onTap!,
        elevation: elevation,
        child: card,
      );
    }
    return card;
  }
}