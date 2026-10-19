import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/parsa_brand.dart';

/// ─────────────────────────────────────────────────────────────
/// ▰ نوار پیشرفت اسپلش
///
/// ریلِ تیرهٔ شفاف، خطِ آبی نئونی با درخشش کنترل‌شده، عبور نور روی
/// خط، گوشه‌های کاملِ گرد و نوکِ طلایی وقتی کار تمام شده است.
/// درصدِ نمایش‌داده‌شده همان پیشرفتِ واقعیِ [progress] است؛ تا وقتی
/// هیچ مرحله‌ای تمام نشده، به‌جای عددِ الکی حالت نامعین نشان می‌دهد.
/// ─────────────────────────────────────────────────────────────
class SplashProgressBar extends StatelessWidget {
  const SplashProgressBar({
    super.key,
    required this.progress,
    required this.indeterminate,
    required this.ready,
    required this.shimmer,
  });

  /// پیشرفت واقعی، ۰ تا ۱.
  final double progress;
  final bool indeterminate;
  final bool ready;

  /// انیمیشن آرامِ عبور نور روی خط؛ بوم با آن دوباره رنگ می‌شود.
  final Animation<double> shimmer;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return RepaintBoundary(
      child: SizedBox(
        height: 14,
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

  static const double _trackHeight = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    if (w <= 0) return;
    final top = (size.height - _trackHeight) / 2;
    final track = Rect.fromLTWH(0, top, w, _trackHeight);
    final trackRRect = RRect.fromRectAndRadius(
      track,
      const Radius.circular(_trackHeight / 2),
    );

    // ── ریل تیره و شفاف ──
    canvas.drawRRect(
      trackRRect,
      Paint()..color = Colors.white.withOpacity(0.065),
    );
    canvas.drawRRect(
      trackRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withOpacity(0.055),
    );
    // خط تیرهٔ نازک زیر ریل، برای حس فرورفتگی.
    canvas.drawLine(
      Offset(4, track.bottom - 0.4),
      Offset(w - 4, track.bottom - 0.4),
      Paint()..color = Colors.black.withOpacity(0.5),
    );

    final phase = (shimmer.value * 2) % 1.0;
    final fill = _fillRect(w, top);

    if (fill != null) {
      _paintFill(canvas, fill, phase);
    } else {
      _paintIndeterminate(canvas, w, top, phase);
    }
  }

  Rect? _fillRect(double w, double top) {
    if (indeterminate) return null;
    final width = (w * progress).clamp(0.0, w).toDouble();
    if (width <= 0) return null;
    return rtl
        ? Rect.fromLTWH(w - width, top, width, _trackHeight)
        : Rect.fromLTWH(0, top, width, _trackHeight);
  }

  void _paintFill(Canvas canvas, Rect fill, double phase) {
    final rrect = RRect.fromRectAndRadius(
      fill,
      const Radius.circular(_trackHeight / 2),
    );

    // درخشش نئونی کنترل‌شده دور خط (بدون blur سنگین؛ چند لایهٔ محو).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        fill.inflate(1.6),
        const Radius.circular(_trackHeight),
      ),
      Paint()..color = ParsaBrand.neonBlue.withOpacity(0.10),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        fill.inflate(0.8),
        const Radius.circular(_trackHeight),
      ),
      Paint()..color = ParsaBrand.iceBlue.withOpacity(0.18),
    );

    final gradient = ui.Gradient.linear(
      rtl ? Offset(fill.right, 0) : Offset(fill.left, 0),
      rtl ? Offset(fill.left, 0) : Offset(fill.right, 0),
      <Color>[
        ParsaBrand.electricBlue,
        ParsaBrand.neonBlue,
        ParsaBrand.iceBlue,
      ],
      const <double>[0.0, 0.55, 1.0],
    );
    canvas.drawRRect(rrect, Paint()..shader = gradient);

    // عبور نورِ محو روی خط، فقط داخل خط.
    canvas.save();
    canvas.clipRRect(rrect);
    final bandWidth = fill.width.clamp(28.0, 72.0).toDouble();
    final travel = fill.width + bandWidth * 2;
    final x = rtl
        ? fill.right - (travel * phase)
        : fill.left - bandWidth + travel * phase;
    final band = Rect.fromLTWH(x, fill.top - 1, bandWidth, fill.height + 2);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Colors.transparent,
            Colors.white.withOpacity(0.5),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.5, 1.0],
        ).createShader(band),
    );
    canvas.restore();

    // نوکِ روشن — نشانهٔ لحظهٔ فعلی.
    final headX = rtl ? fill.left : fill.right;
    final head = Offset(headX, fill.center.dy);
    canvas.drawCircle(
      head,
      9,
      Paint()
        ..shader = ui.Gradient.radial(
          head,
          9,
          <Color>[
            ParsaBrand.iceBlue.withOpacity(0.45),
            ParsaBrand.neonBlue.withOpacity(0.12),
            Colors.transparent,
          ],
          const <double>[0.0, 0.45, 1.0],
        ),
    );
    canvas.drawCircle(
      head,
      1.6,
      Paint()..color = ParsaBrand.silver.withOpacity(0.95),
    );

    // پایانِ کار: نوک طلایی، هم‌رنگ تاجِ لوگو.
    if (ready) {
      final cap = RRect.fromRectAndRadius(
        Rect.fromCenter(center: head, width: 2.4, height: 9),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        cap.inflate(1.2),
        Paint()..color = ParsaBrand.gold.withOpacity(0.20),
      );
      canvas.drawRRect(cap, Paint()..color = ParsaBrand.brightGold);
    }
  }

  void _paintIndeterminate(Canvas canvas, double w, double top, double phase) {
    final bandWidth = w * 0.34;
    final travel = w + bandWidth;
    final x = rtl ? w - travel * phase : -bandWidth + travel * phase;
    final rect = Rect.fromLTWH(x, top, bandWidth, _trackHeight);
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, top, w, _trackHeight),
        const Radius.circular(_trackHeight / 2),
      ),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            Colors.transparent,
            ParsaBrand.neonBlue.withOpacity(0.35),
            ParsaBrand.iceBlue.withOpacity(0.85),
            ParsaBrand.neonBlue.withOpacity(0.35),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.3, 0.5, 0.7, 1.0],
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
