import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/fandoghi_models.dart';
import 'fandoghi_bunny.dart';

export '../../core/fandoghi_models.dart';

/// ═══════════════════════════════════════════════
/// 🐰 Fandoghi V2 — Backwards-compatible wrapper.
///
/// The original V2 widget was a CustomPaint hazelnut. We replaced it
/// with the cute [FandoghiBunny] image everywhere it was used, but
/// kept the public API ([FandoghiV2]) so every existing call site
/// (FandoghiV2(size: 80, animate: true, mood: …)) keeps compiling.
/// ═══════════════════════════════════════════════
class FandoghiV2 extends StatelessWidget {
  final double size;
  final bool animate;
  final String? message;
  final VoidCallback? onTap;

  /// Kept for API compatibility. The bunny has a single friendly
  /// smile and ignores mood switches.
  // ignore: unused_element_parameter
  final FandoghiMood mood;

  const FandoghiV2({
    super.key,
    this.size = 80,
    this.animate = true,
    this.message,
    this.onTap,
    this.mood = FandoghiMood.happy,
  });

  @override
  Widget build(BuildContext context) {
    Widget body = GestureDetector(
      onTap: onTap,
      child: _BunnyWithFloat(
        size: size,
        animate: animate,
        child: FandoghiBunny(size: size),
      ),
    );

    if (message != null && message!.isNotEmpty) {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          body,
          const SizedBox(height: 8),
          _buildSpeechBubble(),
        ],
      );
    }

    return Semantics(
      label: 'فندقی، مربی و راهنمای کودک',
      button: onTap != null,
      child: body,
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
    );
  }
}

/// Gentle float animation so the bunny still feels alive even
/// though it's an image now.
class _BunnyWithFloat extends StatefulWidget {
  final double size;
  final bool animate;
  final Widget child;
  const _BunnyWithFloat({
    required this.size,
    required this.animate,
    required this.child,
  });

  @override
  State<_BunnyWithFloat> createState() => _BunnyWithFloatState();
}

class _BunnyWithFloatState extends State<_BunnyWithFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2200 + _rng.nextInt(600)),
    );
    if (widget.animate) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _BunnyWithFloat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.animate && oldWidget.animate) {
      _ctrl.stop();
      _ctrl.value = 0;
    }
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
      builder: (_, child) {
        final dy = widget.animate ? sin(_ctrl.value * pi) * 4 : 0.0;
        return Transform.translate(offset: Offset(0, -dy), child: child);
      },
      child: widget.child,
    );
  }
}
