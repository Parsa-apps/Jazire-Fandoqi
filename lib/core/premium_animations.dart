import 'package:flutter/material.dart';

/// =======================================================
/// ✨ PREMIUM ANIMATION SYSTEM — کودک ایران
/// انیمیشن‌های نرم، حرفه‌ای و کودک‌پسند
/// =======================================================

class PremiumAnimations {
  // ===== Duration Standards =====
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 520);
  static const Duration verySlow = Duration(milliseconds: 800);

  // ===== Curves =====
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve bouncy = Curves.elasticOut;
  static const Curve gentle = Curves.easeInOutCubic;
  static const Curve playful = Curves.easeOutBack;

  // ===== Fade + Scale (Hero-like) =====
  static Widget fadeScale({
    required Widget child,
    required bool visible,
    Duration duration = normal,
    Curve curve = smooth,
    double beginScale = 0.85,
  }) {
    return AnimatedScale(
      scale: visible ? 1.0 : beginScale,
      duration: duration,
      curve: curve,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: duration,
        curve: curve,
        child: child,
      ),
    );
  }

  // ===== Slide from Bottom =====
  static Widget slideUp({
    required Widget child,
    required bool visible,
    Duration duration = normal,
    double offset = 40,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: visible ? offset : 0, end: visible ? 0 : offset),
      duration: duration,
      curve: smooth,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, value),
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: duration,
            child: child,
          ),
        );
      },
    );
  }

  // ===== Premium Card Hover / Press =====
  static Widget premiumCard({
    required Widget child,
    required VoidCallback onTap,
    double elevation = 8,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: onTap,
          child: AnimatedContainer(
            duration: fast,
            curve: smooth,
            transform: Matrix4.identity()..scale(isPressed ? 0.96 : 1.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isPressed ? 0.08 : 0.15),
                  blurRadius: isPressed ? 6 : elevation,
                  offset: Offset(0, isPressed ? 2 : 6),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }

  // ===== Micro Interaction Button =====
  static Widget premiumButton({
    required Widget child,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool pressed = false;
        return GestureDetector(
          onTapDown: (_) => setState(() => pressed = true),
          onTapUp: (_) => setState(() => pressed = false),
          onTapCancel: () => setState(() => pressed = false),
          onTap: onPressed,
          child: AnimatedScale(
            scale: pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: child,
          ),
        );
      },
    );
  }

  // ===== Staggered List Animation =====
  static Widget staggeredItem({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 60),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: normal + (delay * index),
      curve: smooth,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}