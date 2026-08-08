import 'package:flutter/material.dart';

/// =======================================================
/// 🌟 PREMIUM PAGE TRANSITION — انیمیشن نرم بین صفحات
/// =======================================================
class PremiumPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  PremiumPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 420),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            );

            final slide = Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(fade);

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(
                  scale: scale,
                  child: child,
                ),
              ),
            );
          },
        );
}