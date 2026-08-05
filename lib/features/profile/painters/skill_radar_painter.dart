import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// 🕸️ SKILL RADAR — Hexagonal Spider Chart
/// ═══════════════════════════════════════════════
class SkillRadarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;
  final double animProgress;

  SkillRadarPainter({
    required this.values,
    required this.labels,
    required this.colors,
    this.animProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = min(cx, cy) - 35;
    final sides = values.length;
    if (sides < 3) return;
    final center = Offset(cx, cy);

    // Grid rings
    for (int ring = 1; ring <= 4; ring++) {
      final r = maxR * ring / 4;
      final path = Path();
      for (int i = 0; i <= sides; i++) {
        final angle = (i % sides) * 2 * pi / sides - pi / 2;
        final x = cx + cos(angle) * r;
        final y = cy + sin(angle) * r;
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, Paint()
        ..color = Colors.white.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }

    // Axis lines
    for (int i = 0; i < sides; i++) {
      final angle = i * 2 * pi / sides - pi / 2;
      canvas.drawLine(center,
        Offset(cx + cos(angle) * maxR, cy + sin(angle) * maxR),
        Paint()..color = Colors.white.withOpacity(0.08)..strokeWidth = 1);
    }

    // Data polygon
    final animVals = values.map((v) => v * animProgress).toList();
    final fillPath = Path();
    for (int i = 0; i <= sides; i++) {
      final idx = i % sides;
      final angle = idx * 2 * pi / sides - pi / 2;
      final r = maxR * animVals[idx];
      final x = cx + cos(angle) * r;
      final y = cy + sin(angle) * r;
      i == 0 ? fillPath.moveTo(x, y) : fillPath.lineTo(x, y);
    }
    fillPath.close();

    canvas.drawPath(fillPath, Paint()
      ..shader = RadialGradient(
        colors: [colors.first.withOpacity(0.3), colors.last.withOpacity(0.1)],
      ).createShader(Rect.fromCircle(center: center, radius: maxR)));

    canvas.drawPath(fillPath, Paint()
      ..color = colors.first.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);

    // Data dots
    for (int i = 0; i < sides; i++) {
      final angle = i * 2 * pi / sides - pi / 2;
      final r = maxR * animVals[i];
      final x = cx + cos(angle) * r;
      final y = cy + sin(angle) * r;
      final dotColor = colors[i % colors.length];

      canvas.drawCircle(Offset(x, y), 8, Paint()..color = dotColor.withOpacity(0.3));
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = dotColor);
      canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = Colors.white);
    }

    // Labels
    for (int i = 0; i < sides; i++) {
      final angle = i * 2 * pi / sides - pi / 2;
      final labelR = maxR + 25;
      final x = cx + cos(angle) * labelR;
      final y = cy + sin(angle) * labelR;
      final tp = TextPainter(
        text: TextSpan(text: labels[i],
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.rtl,
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
