import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// 📊 STAT RING — Circular Progress
/// ═══════════════════════════════════════════════
class StatRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double animProgress;

  StatRingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 10,
    this.animProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - strokeWidth / 2;
    final center = Offset(cx, cy);

    // Background ring
    canvas.drawCircle(center, r, Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round);

    // Progress arc
    final sweepAngle = 2 * pi * progress * animProgress;
    final rect = Rect.fromCircle(center: center, radius: r);

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + sweepAngle,
        colors: [color.withOpacity(0.6), color],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round);

    // Tip glow
    if (animProgress > 0.5) {
      final tipAngle = -pi / 2 + sweepAngle;
      canvas.drawCircle(
        Offset(cx + cos(tipAngle) * r, cy + sin(tipAngle) * r),
        strokeWidth * 0.8,
        Paint()..color = color.withOpacity(0.3 * animProgress));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

/// ═══════════════════════════════════════════════
/// 📅 ACTIVITY HEATMAP — GitHub-style Calendar
/// ═══════════════════════════════════════════════
class ActivityHeatmapPainter extends CustomPainter {
  final List<int> activity;
  final double animProgress;

  ActivityHeatmapPainter({required this.activity, this.animProgress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = (size.width - 6 * 4) / 7;
    final gap = 4.0;

    for (int i = 0; i < activity.length; i++) {
      final day = i % 7;
      final week = i ~/ 7;
      final x = day * (cellW + gap);
      final y = week * (cellW + gap);
      final delay = (i / activity.length) * 0.5;
      final localAnim = ((animProgress - delay) / (1 - delay)).clamp(0.0, 1.0);
      final intensity = activity[i];

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, cellW, cellW), const Radius.circular(4));

      canvas.drawRRect(rect, Paint()..color = Colors.white.withOpacity(0.05 * localAnim));

      if (intensity > 0) {
        final colors = [
          const Color(0xFF2D5F2D), const Color(0xFF3E8E3E),
          const Color(0xFF5ABF5A), const Color(0xFF7AE67A),
        ];
        canvas.drawRRect(rect, Paint()
          ..color = colors[(intensity - 1).clamp(0, 3)].withOpacity(0.8 * localAnim));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

/// ═══════════════════════════════════════════════
/// 📈 SKILL BAR — Horizontal Progress Bars
/// ═══════════════════════════════════════════════
class SkillBarPainter extends CustomPainter {
  final List<BarData> bars;
  final double animProgress;

  SkillBarPainter({required this.bars, this.animProgress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final barH = 24.0;
    final gap = 12.0;
    final labelW = 70.0;
    final barW = size.width - labelW - 40;

    for (int i = 0; i < bars.length; i++) {
      final y = i * (barH + gap);
      final bar = bars[i];
      final animVal = bar.value * animProgress;

      // Label
      final tp = TextPainter(
        text: TextSpan(text: bar.label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.rtl,
      );
      tp.layout();
      tp.paint(canvas, Offset(size.width - labelW - tp.width, y + 4));

      // Background
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(labelW, y, barW, barH), const Radius.circular(12)),
        Paint()..color = Colors.white.withOpacity(0.06));

      // Progress
      if (animVal > 0) {
        final progressW = barW * animVal;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(labelW, y, progressW, barH), const Radius.circular(12)),
          Paint()..shader = LinearGradient(
            colors: [bar.color.withOpacity(0.7), bar.color],
          ).createShader(Rect.fromLTWH(labelW, y, progressW, barH)));

        final vp = TextPainter(
          text: TextSpan(text: '${(bar.value * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
          textDirection: TextDirection.ltr,
        );
        vp.layout();
        vp.paint(canvas, Offset(labelW + progressW - vp.width - 8, y + 5));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class BarData {
  final String label;
  final double value;
  final Color color;
  BarData({required this.label, required this.value, required this.color});
}
