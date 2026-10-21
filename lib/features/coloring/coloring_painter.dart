import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/coloring/coloring_pages.dart';

/// قلم‌موی کتابِ رنگ‌آمیزی.
///
/// نواحیِ هر صفحه با رنگِ انتخابیِ کودک پر می‌شوند و خطِ دورشان همیشه
/// باقی می‌ماند تا نقاشی شکلِ خودش را حفظ کند. جزئیات (چشم، لبخند، خطِ
/// پنجره و...) روی لایهٔ رنگ کشیده می‌شوند.
class ColoringPainter extends CustomPainter {
  ColoringPainter({
    required this.page,
    required this.colors,
    this.showOutlines = true,
  });

  final ColoringPage page;
  final Map<String, Color> colors;
  final bool showOutlines;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scale = (size.shortestSide / 360).clamp(0.75, 2.4).toDouble();
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF3A3A4A);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = page.paperColor,
    );

    for (final region in page.regions) {
      final path = region.buildPath(size);
      fillPaint.color = colors[region.id] ?? region.defaultColor;
      canvas.drawPath(path, fillPaint);
      if (showOutlines) canvas.drawPath(path, outlinePaint);
    }

    for (final detail in page.details) {
      final path = detail.buildPath(size);
      final paint = Paint()
        ..style = detail.fill ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = detail.strokeWidth * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = detail.color;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ColoringPainter oldDelegate) =>
      oldDelegate.page.id != page.id ||
      oldDelegate.showOutlines != showOutlines ||
      !mapEquals(oldDelegate.colors, colors);
}

/// پیش‌نمایشِ کوچکِ یک صفحه برای شبکهٔ انتخاب صفحه.
class ColoringPreview extends StatelessWidget {
  const ColoringPreview({
    super.key,
    required this.page,
    this.colors = const <String, Color>{},
  });

  final ColoringPage page;
  final Map<String, Color> colors;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: ColoringPainter(page: page, colors: colors),
        ),
      ),
    );
  }
}
