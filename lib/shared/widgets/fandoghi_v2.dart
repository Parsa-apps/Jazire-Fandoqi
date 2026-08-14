import 'package:flutter/material.dart';

import '../../core/fandoghi_models.dart';
import 'fandoghi_hazelnut_character.dart';

export '../../core/fandoghi_models.dart';

/// ═══════════════════════════════════════════════
/// 🌰 Fandoghi V2 — ویجت کاراکتر فندق مربی و همراه کودک
/// ═══════════════════════════════════════════════
class FandoghiV2 extends StatelessWidget {
  final double size;
  final bool shouldAnimate;
  final String? message;
  final VoidCallback? onTap;
  final FandoghiMood mood;

  const FandoghiV2({
    super.key,
    this.size = 80,
    bool animate = true,
    this.message,
    this.onTap,
    this.mood = FandoghiMood.happy,
  }) : shouldAnimate = animate;

  @override
  Widget build(BuildContext context) {
    Widget body = GestureDetector(
      onTap: onTap,
      child: FandoghiHazelnutCharacter(
        size: size,
        mood: mood,
        animate: shouldAnimate,
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
      label: 'فندقی، مربی و دوست صمیمی کودک',
      button: onTap != null,
      child: body,
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE67E22).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2C3E50),
          height: 1.4,
        ),
      ),
    );
  }
}
