import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/fandoghi_models.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌰 FANDOGHI HAZELNUT CHARACTER — کاراکتر فندق بامزه و کودکانه
/// فندق تپل، مهربان و باانرژی با کلاه برگی، چشمان درخشان و لپ‌های گل‌انداخته
/// ═══════════════════════════════════════════════════════════════
class FandoghiHazelnutCharacter extends StatefulWidget {
  final double size;
  final FandoghiMood mood;
  final bool isTalking;
  final bool animate;

  const FandoghiHazelnutCharacter({
    super.key,
    this.size = 80,
    this.mood = FandoghiMood.happy,
    this.isTalking = false,
    this.animate = true,
  });

  @override
  State<FandoghiHazelnutCharacter> createState() =>
      _FandoghiHazelnutCharacterState();
}

class _FandoghiHazelnutCharacterState extends State<FandoghiHazelnutCharacter>
    with TickerProviderStateMixin {
  late final AnimationController _idleCtrl;
  late final AnimationController _blinkCtrl;
  late final AnimationController _talkCtrl;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.animate) _idleCtrl.repeat(reverse: true);

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _startBlinkLoop();

    _talkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    if (widget.isTalking) _talkCtrl.repeat(reverse: true);
  }

  void _startBlinkLoop() async {
    while (mounted) {
      final waitSeconds = 2 + Random().nextInt(4);
      await Future.delayed(Duration(seconds: waitSeconds));
      if (!mounted) break;
      await _blinkCtrl.forward();
      await _blinkCtrl.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant FandoghiHazelnutCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTalking && !oldWidget.isTalking) {
      _talkCtrl.repeat(reverse: true);
    } else if (!widget.isTalking && oldWidget.isTalking) {
      _talkCtrl.stop();
      _talkCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _blinkCtrl.dispose();
    _talkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleCtrl, _blinkCtrl, _talkCtrl]),
      builder: (context, _) {
        final idleLift = widget.animate ? sin(_idleCtrl.value * pi) * 3.0 : 0.0;
        final idleScale =
            widget.animate ? 1.0 + sin(_idleCtrl.value * pi) * 0.02 : 1.0;

        return Transform.translate(
          offset: Offset(0, -idleLift),
          child: Transform.scale(
            scale: idleScale,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _HazelnutPainter(
                  mood: widget.mood,
                  blinkValue: _blinkCtrl.value,
                  talkValue: _talkCtrl.value,
                  idleProgress: _idleCtrl.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HazelnutPainter extends CustomPainter {
  final FandoghiMood mood;
  final double blinkValue;
  final double talkValue;
  final double idleProgress;

  _HazelnutPainter({
    required this.mood,
    required this.blinkValue,
    required this.talkValue,
    required this.idleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.54);

    // ── سایه نرم زیر کاراکتر ──
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, h * 0.94),
        width: w * 0.65,
        height: h * 0.14,
      ),
      shadowPaint,
    );

    // ── پاهای فندق (کفش‌های گرد بامزه) ──
    final feetPaint = Paint()..color = const Color(0xFFD35400);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.36, h * 0.88),
        width: w * 0.18,
        height: h * 0.12,
      ),
      feetPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.64, h * 0.88),
        width: w * 0.18,
        height: h * 0.12,
      ),
      feetPaint,
    );

    // ── بدن فندق (فرم تخم‌مرغی گرد با نوک گرد پایین) ──
    final nutBodyPath = Path();
    nutBodyPath.moveTo(w * 0.5, h * 0.18);
    nutBodyPath.cubicTo(
      w * 0.92, h * 0.22,
      w * 0.94, h * 0.74,
      w * 0.5, h * 0.88,
    );
    nutBodyPath.cubicTo(
      w * 0.06, h * 0.74,
      w * 0.08, h * 0.22,
      w * 0.5, h * 0.18,
    );
    nutBodyPath.close();

    // گرادیان پوست فندق (بلوطی طلایی با هایلایت براق)
    final nutShader = RadialGradient(
      center: const Alignment(-0.25, -0.3),
      radius: 0.85,
      colors: const [
        Color(0xFFFFB347), // کهربایی روشن
        Color(0xFFE67E22), // نارنجی گرم فندقی
        Color(0xFFBA4A00), // قهوه‌ای شکلاتی
        Color(0xFF7E3817), // تیره انتهای فندق
      ],
      stops: const [0.0, 0.45, 0.82, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final nutPaint = Paint()
      ..shader = nutShader
      ..style = PaintingStyle.fill;
    canvas.drawPath(nutBodyPath, nutPaint);

    // خطوط بافت ملایم روی بدنه فندق
    final texturePaint = Paint()
      ..color = const Color(0xFF6E2C00).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(w * 0.32, h * 0.35), Offset(w * 0.38, h * 0.75), texturePaint);
    canvas.drawLine(Offset(w * 0.68, h * 0.35), Offset(w * 0.62, h * 0.75), texturePaint);

    // ── کلاه پوستی سبز بالای فندق (کاسبرگ دندانه‌دار فندق) ──
    final capPath = Path();
    capPath.moveTo(w * 0.12, h * 0.28);
    // دندانه‌های سبز کلاه فندق
    capPath.quadraticBezierTo(w * 0.22, h * 0.34, w * 0.28, h * 0.22);
    capPath.quadraticBezierTo(w * 0.38, h * 0.36, w * 0.50, h * 0.24);
    capPath.quadraticBezierTo(w * 0.62, h * 0.36, w * 0.72, h * 0.22);
    capPath.quadraticBezierTo(w * 0.78, h * 0.34, w * 0.88, h * 0.28);
    // گنبد بالای کلاه
    capPath.cubicTo(w * 0.94, h * 0.08, w * 0.06, h * 0.08, w * 0.12, h * 0.28);
    capPath.close();

    final capShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF82E0AA), // سبز روشن
        Color(0xFF27AE60), // سبز زمردی
        Color(0xFF1E8449), // سبز تیره
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h * 0.35));

    final capPaint = Paint()..shader = capShader;
    canvas.drawPath(capPath, capPaint);

    // هایلایت لبه کلاه
    final capBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(capPath, capBorderPaint);

    // ── ساقه و جوانه سبز بالای کلاه ──
    final stemPath = Path();
    final stemWave = sin(idleProgress * pi * 2) * 2.5;
    stemPath.moveTo(w * 0.5, h * 0.12);
    stemPath.quadraticBezierTo(
      w * 0.5 + stemWave,
      h * 0.02,
      w * 0.56 + stemWave,
      h * 0.01,
    );
    final stemPaint = Paint()
      ..color = const Color(0xFF196F3D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(stemPath, stemPaint);

    // برگ کوچک بالای ساقه
    final leafPaint = Paint()..color = const Color(0xFF58D68D);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.58 + stemWave, h * 0.02),
        width: w * 0.12,
        height: h * 0.06,
      ),
      leafPaint,
    );

    // ── لپ‌های گل‌انداخته صورتی (Cheek Blush) ──
    final blushPaint = Paint()
      ..color = const Color(0xFFFF5252).withOpacity(0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.26, h * 0.58),
        width: w * 0.16,
        height: h * 0.09,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.74, h * 0.58),
        width: w * 0.16,
        height: h * 0.09,
      ),
      blushPaint,
    );

    // ── چشم‌های درخشان و کارتونی ──
    _drawEyes(canvas, w, h);

    // ── دهان خندان و گوینده ──
    _drawMouth(canvas, w, h);

    // ── دست‌های بامزه و خوش‌آمدگو ──
    _drawHands(canvas, w, h);
  }

  void _drawEyes(Canvas canvas, double w, double h) {
    final eyeY = h * 0.48;
    final leftEyeX = w * 0.35;
    final rightEyeX = w * 0.65;
    final eyeRadiusX = w * 0.105;
    final eyeRadiusY = (1.0 - blinkValue) * (h * 0.135);

    if (mood == FandoghiMood.wink) {
      // چشم چپ باز، چشم راست چشمک
      _drawSingleEye(canvas, Offset(leftEyeX, eyeY), eyeRadiusX, eyeRadiusY);
      final winkPaint = Paint()
        ..color = const Color(0xFF3E2723)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round;
      final winkPath = Path();
      winkPath.moveTo(rightEyeX - w * 0.08, eyeY);
      winkPath.quadraticBezierTo(rightEyeX, eyeY + h * 0.04, rightEyeX + w * 0.08, eyeY);
      canvas.drawPath(winkPath, winkPaint);
      return;
    }

    if (mood == FandoghiMood.celebrating || mood == FandoghiMood.excited) {
      // چشم‌های هلالی شاد
      final happyEyePaint = Paint()
        ..color = const Color(0xFF3E2723)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;

      final leftH = Path()
        ..moveTo(leftEyeX - w * 0.08, eyeY + h * 0.02)
        ..quadraticBezierTo(leftEyeX, eyeY - h * 0.04, leftEyeX + w * 0.08, eyeY + h * 0.02);
      final rightH = Path()
        ..moveTo(rightEyeX - w * 0.08, eyeY + h * 0.02)
        ..quadraticBezierTo(rightEyeX, eyeY - h * 0.04, rightEyeX + w * 0.08, eyeY + h * 0.02);

      canvas.drawPath(leftH, happyEyePaint);
      canvas.drawPath(rightH, happyEyePaint);
      return;
    }

    // چشم‌های معمولی درخشان
    _drawSingleEye(canvas, Offset(leftEyeX, eyeY), eyeRadiusX, eyeRadiusY);
    _drawSingleEye(canvas, Offset(rightEyeX, eyeY), eyeRadiusX, eyeRadiusY);
  }

  void _drawSingleEye(Canvas canvas, Offset center, double rx, double ry) {
    if (ry < 1.0) {
      // چشم بسته (پلک‌زدن)
      final linePaint = Paint()
        ..color = const Color(0xFF3E2723)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(center.dx - rx, center.dy),
        Offset(center.dx + rx, center.dy),
        linePaint,
      );
      return;
    }

    // سفیدی چشم
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      whitePaint,
    );

    // عنبیه قهوه‌ای درخشان
    final irisPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawCircle(Offset(center.dx, center.dy + ry * 0.1), rx * 0.72, irisPaint);

    // برق چشم ستاره‌ای (هایلایت‌های براق چشم)
    final sparkPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(center.dx - rx * 0.28, center.dy - ry * 0.25),
      rx * 0.32,
      sparkPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + rx * 0.25, center.dy + ry * 0.22),
      rx * 0.16,
      sparkPaint,
    );
  }

  void _drawMouth(Canvas canvas, double w, double h) {
    final mouthY = h * 0.65;
    final mouthX = w * 0.5;

    if (talkValue > 0.1) {
      // دهان در حال حرف زدن (باز و بسته شدن متحرک)
      final openH = (talkValue * 0.07 + 0.03) * h;
      final mouthPath = Path();
      mouthPath.moveTo(mouthX - w * 0.12, mouthY);
      mouthPath.quadraticBezierTo(mouthX, mouthY + openH * 2.2, mouthX + w * 0.12, mouthY);
      mouthPath.close();

      final mouthPaint = Paint()..color = const Color(0xFFC0392B);
      canvas.drawPath(mouthPath, mouthPaint);

      // زبان صورتی داخل دهان
      final tonguePaint = Paint()..color = const Color(0xFFFF8A80);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(mouthX, mouthY + openH * 1.3), width: w * 0.12, height: openH),
        tonguePaint,
      );
      return;
    }

    // دهان لبخند مهربان
    final smilePaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(mouthX - w * 0.10, mouthY - h * 0.01);
    smilePath.quadraticBezierTo(mouthX, mouthY + h * 0.05, mouthX + w * 0.10, mouthY - h * 0.01);
    canvas.drawPath(smilePath, smilePaint);
  }

  void _drawHands(Canvas canvas, double w, double h) {
    final handPaint = Paint()..color = const Color(0xFFE67E22);
    final waveHandY = h * 0.58 + sin(idleProgress * pi * 2) * 3;

    // دست چپ (سلام دادن)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.10, waveHandY),
        width: w * 0.14,
        height: h * 0.12,
      ),
      handPaint,
    );

    // دست راست
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.90, h * 0.62),
        width: w * 0.14,
        height: h * 0.12,
      ),
      handPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HazelnutPainter oldDelegate) =>
      oldDelegate.blinkValue != blinkValue ||
      oldDelegate.talkValue != talkValue ||
      oldDelegate.idleProgress != idleProgress ||
      oldDelegate.mood != mood;
}
