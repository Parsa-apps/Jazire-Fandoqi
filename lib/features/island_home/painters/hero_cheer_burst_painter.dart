import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ✨ درخششِ کوتاهِ دورِ فندقی هنگامِ جشن.
///
/// فقط ۱۲ ذره، فقط به اندازهٔ یک چرخهٔ ۱٫۱۵ ثانیه‌ای، و با محوشدنِ
/// کامل در انتها: نه چشمک می‌زند، نه تکرار می‌شود، نه روی گوشیِ
/// ضعیف هزینه دارد (۱۲ دایره در هر فریم).
class HeroCheerBurstPainter extends CustomPainter {
  const HeroCheerBurstPainter({
    required this.progress,
    required this.color,
    this.particleCount = 12,
  });

  /// ۰ تا ۱ — پیشرفتِ انیمیشنِ جشن
  final double progress;

  final Color color;

  final int particleCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    if (size.width <= 0 || size.height <= 0) return;

    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height);
    final fade = (1 - progress) * (progress < 0.12 ? progress / 0.12 : 1.0);

    for (var i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi - math.pi / 2;
      final travel = radius * (0.30 + 0.22 * progress);
      final wobble = math.sin(progress * math.pi * 2 + i) * radius * 0.03;
      final x = center.dx + math.cos(angle) * (travel + wobble);
      final y = center.dy + math.sin(angle) * (travel + wobble);
      final r = radius * 0.028 * (1 - progress * 0.45);

      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = color.withOpacity(0.85 * fade),
      );
      // هستهٔ روشن
      canvas.drawCircle(
        Offset(x, y),
        r * 0.45,
        Paint()..color = Colors.white.withOpacity(0.9 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant HeroCheerBurstPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.particleCount != particleCount;
  }
}
