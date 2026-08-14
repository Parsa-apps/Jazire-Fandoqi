import 'package:flutter/material.dart';

import '../../core/fandoghi_models.dart';
import 'fandoghi_hazelnut_character.dart';

/// ═══════════════════════════════════════════════
/// 🌰 Fandoghi Mascot — کاراکتر فندق کودکانه و بامزه
/// ═══════════════════════════════════════════════
class FandoghiBunny extends StatelessWidget {
  final double size;
  final BoxFit fit;
  final Alignment alignment;
  final FandoghiMood mood;

  const FandoghiBunny({
    super.key,
    this.size = 96,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.mood = FandoghiMood.happy,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FandoghiHazelnutCharacter(
        size: size,
        mood: mood,
      ),
    );
  }
}
