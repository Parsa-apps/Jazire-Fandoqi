import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// ▰ نوار پیشرفت سه‌بعدیِ سبز (طرحِ اصلی جزیره فندقی)
///
/// ریلِ کپسولیِ تیره با کادرِ سفیدِ براق و پرشدگیِ سبزِ زمردی-فسفریِ
/// سه‌بعدی به همراهِ بازتابِ نورِ بالایی.
/// ─────────────────────────────────────────────────────────────
class SplashProgressBar extends StatelessWidget {
  const SplashProgressBar({
    super.key,
    required this.progress,
    required this.indeterminate,
    required this.ready,
    required this.shimmer,
  });

  final double progress;
  final bool indeterminate;
  final bool ready;
  final Animation<double> shimmer;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return RepaintBoundary(
      child: SizedBox(
        height: 22,
        child: CustomPaint(
          size: Size.infinite,
          painter: _SplashBarPainter(
            progress: progress.clamp(0.0, 1.0).toDouble(),
            indeterminate: indeterminate,
            ready: ready,
            rtl: rtl,
            shimmer: shimmer,
          ),
        ),
      ),
    );
  }
}

class _SplashBarPainter extends CustomPainter {
  _SplashBarPainter({
    required this.progress,
    required this.indeterminate,
    required this.ready,
    required this.rtl,
    required this.shimmer,
  }) : super(repaint: shimmer);

  final double progress;
  final bool indeterminate;
  final bool ready;
  final bool rtl;
  final Animation<double> shimmer;

  static const double _trackHeight = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    if (w <= 0 || size.height <= 0) return;
    final top = (size.height - _trackHeight) / 2;
    final track = Rect.fromLTWH(0, top, w, _trackHeight);
    final radius = const Radius.circular(_trackHeight / 2);
    final trackRRect = RRect.fromRectAndRadius(track, radius);

    // سایهٔ زیرِ کپسول
    canvas.drawRRect(
      trackRRect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withOpacity(0.42),
    );

    // ریلِ تیرهٔ نیمه‌شفاف
    canvas.drawRRect(
      trackRRect,
      Paint()..color = const Color(0xAA08261E),
    );

    final phase = (shimmer.value * 2) % 1.0;
    final inner = track.deflate(2.0);
    final fill = _fillRect(inner, phase);

    if (fill != null) {
      _paintFill(canvas, inner, fill, phase);
    } else {
      _paintIndeterminate(canvas, inner, phase);
    }

    // کادرِ سفیدِ براقِ دورِ ریل (مطابق طرحِ مرجع)
    canvas.drawRRect(
      trackRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = Colors.white.withOpacity(0.92),
    );
  }

  Rect? _fillRect(Rect inner, double phase) {
    if (indeterminate) return null;
    final width = (inner.width * progress).clamp(0.0, inner.width).toDouble();
    if (width <= 0) return null;
    return rtl
        ? Rect.fromLTWH(inner.right - width, inner.top, width, inner.height)
        : Rect.fromLTWH(inner.left, inner.top, width, inner.height);
  }

  void _paintFill(Canvas canvas, Rect inner, Rect fill, double phase) {
    final rrect = RRect.fromRectAndRadius(
      fill,
      Radius.circular(inner.height / 2),
    );

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(inner, Radius.circular(inner.height / 2)),
    );

    // گرادیانِ سه‌بعدیِ سبزِ درخشان
    final gradient = ui.Gradient.linear(
      Offset(fill.left, fill.top),
      Offset(fill.left, fill.bottom),
      const <Color>[
        Color(0xFFB4FF4A),
        Color(0xFF3AE360),
        Color(0xFF14A847),
      ],
      const <double>[0.0, 0.52, 1.0],
    );
    canvas.drawRRect(rrect, Paint()..shader = gradient);

    // نوارِ هایلایتِ شیشه‌ایِ بالا
    final highlightRect = Rect.fromLTWH(
      fill.left + 3,
      fill.top + 1.5,
      (fill.width - 6).clamp(0.0, fill.width),
      fill.height * 0.36,
    );
    if (highlightRect.width > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          highlightRect,
          Radius.circular(highlightRect.height / 2),
        ),
        Paint()..color = Colors.white.withOpacity(0.42),
      );
    }

    // عبورِ موجِ نور روی نوارِ سبز
    final bandWidth = fill.width.clamp(24.0, 64.0).toDouble();
    final travel = fill.width + bandWidth * 2;
    final x = rtl
        ? fill.right - (travel * phase)
        : fill.left - bandWidth + travel * phase;
    final band = Rect.fromLTWH(x, fill.top, bandWidth, fill.height);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            Colors.transparent,
            Colors.white.withOpacity(0.38),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.5, 1.0],
        ).createShader(band),
    );

    canvas.restore();
  }

  void _paintIndeterminate(Canvas canvas, Rect inner, double phase) {
    final bandWidth = inner.width * 0.38;
    final travel = inner.width + bandWidth;
    final x = rtl
        ? inner.right - travel * phase
        : inner.left - bandWidth + travel * phase;
    final rect = Rect.fromLTWH(x, inner.top, bandWidth, inner.height);
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(inner, Radius.circular(inner.height / 2)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(inner.height / 2)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFB4FF4A),
            Color(0xFF3AE360),
            Color(0xFF14A847),
          ],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SplashBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.indeterminate != indeterminate ||
        oldDelegate.ready != ready ||
        oldDelegate.rtl != rtl;
  }
}
