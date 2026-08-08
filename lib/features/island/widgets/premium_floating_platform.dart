import 'package:flutter/material.dart';
import '../../../core/premium_animations.dart';

/// =======================================================
/// 🏝️ PREMIUM FLOATING PLATFORM — جزیره شناور لوکس
/// =======================================================
class PremiumFloatingPlatform extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;

  const PremiumFloatingPlatform({
    super.key,
    required this.child,
    this.amplitude = 12,
    this.duration = const Duration(milliseconds: 2800),
  });

  @override
  State<PremiumFloatingPlatform> createState() => _PremiumFloatingPlatformState();
}

class _PremiumFloatingPlatformState extends State<PremiumFloatingPlatform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -widget.amplitude,
      end: widget.amplitude,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: PremiumAnimations.fadeScale(
            visible: true,
            duration: PremiumAnimations.slow,
            child: child!,
          ),
        );
      },
      child: widget.child,
    );
  }
}