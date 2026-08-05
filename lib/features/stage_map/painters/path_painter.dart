import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════
/// 🛤️ PATH PAINTER — Winding Road
/// Beautiful curvy path connecting stages
/// ═══════════════════════════════════════════════
class PathPainter extends CustomPainter {
  final List<Offset> points;
  final double progress; // 0..1 how far the player has gone
  final double animValue; // for sparkles

  PathPainter({
    required this.points,
    required this.progress,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Build the smooth path
    final path = _buildSmoothPath();

    // ─── SHADOW ───
    _drawPathShadow(canvas, path);

    // ─── ROAD BASE (dark brown) ───
    _drawRoad(canvas, path, 28, const Color(0xFF5D4037));

    // ─── ROAD SURFACE (light brown) ───
    _drawRoad(canvas, path, 22, const Color(0xFF8D6E63));

    // ─── ROAD CENTER (dashed line) ───
    _drawCenterLine(canvas, path);

    // ─── COMPLETED GLOW ───
    _drawCompletedGlow(canvas, path);

    // ─── PATH SPARKLES ───
    _drawPathSparkles(canvas, path);

    // ─── DECORATIONS along path ───
    _drawPathDecorations(canvas);
  }

  Path _buildSmoothPath() {
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      // Catmull-Rom to Bezier conversion
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    return path;
  }

  void _drawPathShadow(Canvas canvas, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..strokeWidth = 34
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _drawRoad(Canvas canvas, Path path, double width, Color color) {
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawCenterLine(Canvas canvas, Path path) {
    // Dashed center line
    final metrics = path.computeMetrics().first;
    final totalLen = metrics.length;
    final dashLen = 12.0;
    final gapLen = 8.0;
    double dist = 0;

    while (dist < totalLen) {
      final extractPath = metrics.extractPath(dist, dist + dashLen);
      canvas.drawPath(
        extractPath,
        Paint()
          ..color = Colors.white.withOpacity(0.25)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      dist += dashLen + gapLen;
    }
  }

  void _drawCompletedGlow(Canvas canvas, Path path) {
    if (progress <= 0) return;

    final metrics = path.computeMetrics().first;
    final completedPath = metrics.extractPath(0, metrics.length * progress);

    // Glow layer
    canvas.drawPath(
      completedPath,
      Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.15)
        ..strokeWidth = 36
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Bright line
    canvas.drawPath(
      completedPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFD700),
            const Color(0xFFFFA000),
          ],
        ).createShader(
          Rect.fromPoints(points.first, points.last),
        )
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawPathSparkles(Canvas canvas, Path path) {
    if (progress <= 0) return;

    final metrics = path.computeMetrics().first;
    final rng = Random(42);

    for (int i = 0; i < 15; i++) {
      final dist = rng.nextDouble() * metrics.length * progress;
      final tangent = metrics.getTangentForOffset(dist);
      if (tangent == null) continue;

      final pos = tangent.position;
      final phase = animValue * 2 * pi + i * 1.5;
      final opacity = (sin(phase) + 1) / 2 * 0.5;

      if (opacity > 0.1) {
        _drawStar4(
          canvas,
          Offset(
            pos.dx + sin(phase) * 8,
            pos.dy + cos(phase) * 8,
          ),
          3 + sin(phase) * 1.5,
          opacity,
        );
      }
    }
  }

  void _drawStar4(Canvas canvas, Offset center, double size, double opacity) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(opacity)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - size * 0.6, center.dy - size * 0.6),
      Offset(center.dx + size * 0.6, center.dy + size * 0.6),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + size * 0.6, center.dy - size * 0.6),
      Offset(center.dx - size * 0.6, center.dy + size * 0.6),
      paint,
    );
  }

  void _drawPathDecorations(Canvas canvas) {
    final rng = Random(123);

    // Bushes along path
    for (int i = 0; i < 12; i++) {
      final idx = rng.nextInt(points.length);
      final p = points[idx];
      final side = rng.nextBool() ? 1.0 : -1.0;
      final dist = 40 + rng.nextDouble() * 30;
      final bx = p.dx + side * dist;
      final by = p.dy + (rng.nextDouble() - 0.5) * 20;
      final br = 8 + rng.nextDouble() * 10;

      canvas.drawCircle(
        Offset(bx, by),
        br,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF66BB6A),
              const Color(0xFF388E3C),
            ],
          ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: br)),
      );
    }

    // Small flowers
    for (int i = 0; i < 20; i++) {
      final idx = rng.nextInt(points.length);
      final p = points[idx];
      final side = rng.nextBool() ? 1.0 : -1.0;
      final dist = 30 + rng.nextDouble() * 50;
      final fx = p.dx + side * dist;
      final fy = p.dy + (rng.nextDouble() - 0.5) * 30;
      final colors = [
        const Color(0xFFFF5252),
        const Color(0xFFFFD740),
        const Color(0xFFE040FB),
        const Color(0xFF40C4FF),
        const Color(0xFFFF6E40),
      ];
      final fc = colors[rng.nextInt(colors.length)];

      canvas.drawCircle(
        Offset(fx, fy),
        3 + rng.nextDouble() * 2,
        Paint()..color = fc.withOpacity(0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
