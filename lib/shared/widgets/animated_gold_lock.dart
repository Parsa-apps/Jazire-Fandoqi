import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A small, offline-rendered gold padlock for paid content. Only its own
/// canvas repaints; it never intercepts a card's tap or changes its access.
class AnimatedGoldLock extends StatefulWidget {
  const AnimatedGoldLock({
    super.key,
    this.size = 36,
    this.animated = true,
    this.semanticLabel = 'قفل؛ با نسخهٔ کامل باز می‌شود',
  }) : assert(size > 0);

  final double size;
  final bool animated;
  final String semanticLabel;

  @override
  State<AnimatedGoldLock> createState() => _AnimatedGoldLockState();
}

class _AnimatedGoldLockState extends State<AnimatedGoldLock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  bool _moving = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(AnimatedGoldLock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animated != widget.animated) _updateMotion();
  }

  void _updateMotion() {
    final media = MediaQuery.maybeOf(context);
    final moving = widget.animated &&
        !(media?.disableAnimations ?? false) &&
        !(media?.accessibleNavigation ?? false) &&
        TickerMode.of(context);
    if (_moving == moving) return;
    _moving = moving;
    if (moving) {
      _motion.repeat();
    } else {
      _motion.stop();
      _motion.value = 0;
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: widget.semanticLabel,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.square(widget.size),
            willChange: _moving,
            painter: _GoldLockPainter(motion: _motion, moving: _moving),
          ),
        ),
      ),
    );
  }
}

class _GoldLockPainter extends CustomPainter {
  _GoldLockPainter({required this.motion, required this.moving})
      : super(repaint: motion);

  final Animation<double> motion;
  final bool moving;

  static const _bronze = Color(0xFF9C610B);
  static const _gold = Color(0xFFFFC43D);
  static const _cream = Color(0xFFFFF7D9);
  static const _bodyBounds = Rect.fromLTWH(21, 43, 58, 43);
  static final _body = RRect.fromRectAndRadius(
    _bodyBounds,
    const Radius.circular(11),
  );
  static final _shackle = Path()
    ..moveTo(32, 48)
    ..lineTo(32, 33)
    ..cubicTo(32, 9, 68, 9, 68, 33)
    ..lineTo(68, 48);

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    if (side <= 0) return;
    final phase = moving ? motion.value : 0.0;
    final wave = moving ? math.sin(phase * math.pi * 2) : 0.0;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);
    canvas.translate(50, 50 - wave * 1.8);
    canvas.rotate(wave * 0.065);
    canvas.scale(1 + wave * 0.018);
    canvas.translate(-50, -50);

    // Warm medallion, with enough contrast on both light and night-sky cards.
    canvas.drawCircle(
      const Offset(50, 51),
      44,
      Paint()
        ..color = _gold.withOpacity(0.22 + wave * 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      const Offset(50, 50),
      42,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.45, -0.55),
          colors: [_cream, Color(0xFFFFE5A0), Color(0xFFE9AD35)],
        ).createShader(const Rect.fromLTWH(8, 8, 84, 84)),
    );
    canvas.drawCircle(
      const Offset(50, 50),
      42,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _bronze.withOpacity(0.75),
    );
    canvas.drawCircle(
      const Offset(50, 49),
      39.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withOpacity(0.65),
    );
    canvas.drawOval(
      const Rect.fromLTWH(31, 85, 40, 6),
      Paint()
        ..color = _bronze.withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // The rounded shackle and bevel use metal gradients, not a downloaded asset.
    canvas.drawPath(
      _shackle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 11
        ..color = _bronze,
    );
    canvas.drawPath(
      _shackle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7.5
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFFE397),
            Color(0xFFFFFCE6),
            Color(0xFFF2B732),
            Color(0xFFFFF0B1),
          ],
          stops: [0, 0.32, 0.72, 1],
        ).createShader(const Rect.fromLTWH(27, 16, 46, 36)),
    );
    canvas.drawRRect(
      _body.shift(const Offset(0, 2.5)),
      Paint()..color = _bronze,
    );
    canvas.drawRRect(
      _body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0A3),
            Color(0xFFFFCF42),
            Color(0xFFD99009),
            Color(0xFFFFC843),
          ],
          stops: [0, 0.38, 0.76, 1],
        ).createShader(_bodyBounds),
    );
    canvas.drawRRect(
      _body.deflate(2.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _cream.withOpacity(0.7),
    );

    // One soft travelling highlight per cycle; no rapid flashing.
    if (moving) {
      final x = phase * 150 - 40;
      final shine = Path()
        ..moveTo(x, 40)
        ..lineTo(x + 11, 40)
        ..lineTo(x + 35, 89)
        ..lineTo(x + 24, 89)
        ..close();
      canvas.save();
      canvas.clipRRect(_body);
      canvas.drawPath(shine, Paint()..color = Colors.white.withOpacity(0.48));
      canvas.restore();
    }

    final keyhole = Path()
      ..addOval(const Rect.fromLTWH(45.5, 54, 9, 9))
      ..moveTo(47.5, 60)
      ..lineTo(52.5, 60)
      ..lineTo(55, 72)
      ..lineTo(45, 72)
      ..close();
    canvas.drawPath(keyhole, Paint()..color = const Color(0xFF70400C));
    canvas.drawLine(
      const Offset(47, 56),
      const Offset(49, 55),
      Paint()
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFE49B),
    );
    _sparkle(canvas, const Offset(80, 24), 5, 0.7 + wave * 0.25);
    _sparkle(canvas, const Offset(18, 51), 3.5, 0.65 - wave * 0.2);
    canvas.restore();
  }

  void _sparkle(Canvas canvas, Offset center, double radius, double opacity) {
    final star = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius * 0.28, center.dy - radius * 0.28)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx + radius * 0.28, center.dy + radius * 0.28)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius * 0.28, center.dy + radius * 0.28)
      ..lineTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - radius * 0.28, center.dy - radius * 0.28)
      ..close();
    canvas.drawPath(star, Paint()..color = Colors.white.withOpacity(opacity));
    canvas.drawPath(
      star,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = _bronze.withOpacity(opacity * 0.6),
    );
  }

  @override
  bool shouldRepaint(_GoldLockPainter oldDelegate) =>
      oldDelegate.motion != motion || oldDelegate.moving != moving;
}
