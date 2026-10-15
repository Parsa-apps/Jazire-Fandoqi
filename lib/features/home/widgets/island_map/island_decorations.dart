import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/island_world_style.dart';
import '../../../../core/audio_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌴 لایهٔ تزئیناتِ زندهٔ نقشهٔ جزیره
///
/// سکوها «نقاط دیدنی»‌اند، ولی بینِ آن‌ها دنیا نباید خالی بماند.
/// این لایه — که زیرِ سکوها و پل‌ها و روی تصویرِ پس‌زمینه می‌نشیند —
/// جزیره را به یک دنیای کامل تبدیل می‌کند:
///
///   • رنگین‌کمانِ بزرگ پشتِ قهرمان فندقی
///   • بالنِ شناور در آسمان با رانش آرام افقی
///   • درخت نخل و درخت شکوفهٔ جادویی در حاشیهٔ مسیر (با سایهٔ نرم
///     زیرشان تا روی آب «ایستاده» به نظر بیایند، نه چسبیده به صفحه)
///   • ذرات نورِ جادویی که در کل مسیر می‌درخشند
///
/// همهٔ حرکت‌ها از همان کنترلرِ شناوریِ مشترک نقشه تغذیه می‌شوند؛
/// یعنی هیچ تایمر و کنترلر اضافه‌ای ساخته نمی‌شود و وقتی نقشه از
/// صفحه کنار می‌رود (TickerMode) همه‌چیز خودکار می‌ایستد.
/// ═══════════════════════════════════════════════════════════════
class IslandDecorations extends StatelessWidget {
  final double width;
  final double mapHeight;
  final Animation<double> floatAnimation;

  const IslandDecorations({
    super.key,
    required this.width,
    required this.mapHeight,
    required this.floatAnimation,
  });

  double _w(double fraction, double min, double max) =>
      (width * fraction).clamp(min, max);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🌈 رنگین‌کمان پشتِ قهرمان — قابِ طبیعیِ بالای جزیره
        Positioned(
          top: mapHeight * 0.050,
          left: width * 0.05,
          width: _w(0.90, 260, 720),
          child: _FloatingDecor(
            asset: IslandWorldAssets.decorRainbow,
            animation: floatAnimation,
            phase: 0.12,
            bobAmplitude: 4,
            opacity: 0.94,
          ),
        ),

        // 🎈 بالنِ آسمان — بالا و چپ، دور از سکوی کارتون‌ها
        Positioned(
          top: mapHeight * 0.104,
          left: width * 0.030,
          width: _w(0.17, 52, 118),
          child: _BalloonDecor(animation: floatAnimation),
        ),

        // 🌴 نخلِ سمت راست، هم‌سطحِ سکوی کارتون‌ها
        Positioned(
          top: mapHeight * 0.208,
          right: width * 0.012,
          width: _w(0.35, 120, 285),
          child: _FloatingDecor(
            asset: IslandWorldAssets.decorPalmTree,
            animation: floatAnimation,
            phase: 0.55,
            bobAmplitude: 5,
            withShadow: true,
          ),
        ),

        // 🌸 درخت شکوفهٔ سمت چپ، درست بالای سکوی فارسی
        Positioned(
          top: mapHeight * 0.294,
          left: width * 0.008,
          width: _w(0.31, 112, 262),
          child: _FloatingDecor(
            asset: IslandWorldAssets.decorBlossomTree,
            animation: floatAnimation,
            phase: 0.30,
            bobAmplitude: 5,
            withShadow: true,
          ),
        ),

        // 🌴 نخلِ کوچکِ آینه‌ای در نیمهٔ پایینی، روبه‌روی چادر جشن
        Positioned(
          top: mapHeight * 0.652,
          right: width * 0.020,
          width: _w(0.26, 92, 215),
          child: _FloatingDecor(
            asset: IslandWorldAssets.decorPalmTree,
            animation: floatAnimation,
            phase: 0.78,
            bobAmplitude: 4,
            withShadow: true,
            mirrored: true,
          ),
        ),

        // ✨ غبارِ نورِ جادویی در سراسر مسیر
        Positioned.fill(
          child: IslandSparkleField(animation: floatAnimation),
        ),
      ],
    );
  }
}

/// یک تزئین شناور: بالا و پایین رفتنِ سینوسیِ ملایم + تابِ بسیار کم،
/// با سایهٔ بیضیِ نرم زیرِ پایه تا عنصر روی آب «نشسته» به نظر بیاید.
///
/// تزئینات «زنده»‌اند: با لمس، یک جهش فنریِ کوتاه و چند ستارهٔ نور
/// نشان می‌دهند (با صدای لمس ملایم). کاملاً اختیاری‌اند و چون بیرون
/// از مسیر بازی‌ها قرار دارند، هیچ‌وقت مزاحم ورود به بازی نمی‌شوند.
class _FloatingDecor extends StatelessWidget {
  final String asset;
  final Animation<double> animation;
  final double phase;
  final double bobAmplitude;
  final double opacity;
  final bool withShadow;
  final bool mirrored;

  const _FloatingDecor({
    required this.asset,
    required this.animation,
    required this.phase,
    required this.bobAmplitude,
    this.opacity = 1,
    this.withShadow = false,
    this.mirrored = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = (animation.value + phase) % 1.0;
        final bob = sin(t * 2 * pi);
        return Transform.translate(
          offset: Offset(0, bob * bobAmplitude),
          child: Transform.rotate(angle: bob * 0.008, child: child),
        );
      },
      child: Opacity(
        opacity: opacity,
        child: Transform(
          transform: Matrix4.diagonal3Values(mirrored ? -1.0 : 1.0, 1, 1),
          alignment: Alignment.center,
          child: _InteractiveDecor(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (withShadow)
                  const Positioned(
                    left: 18,
                    right: 18,
                    bottom: -4,
                    height: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Color(0x2B00455A), Color(0x0000455A)],
                        ),
                      ),
                    ),
                  ),
                Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  excludeFromSemantics: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// لایهٔ واکنش لمسی تزئینات: فشردگی و جهش فنری + پاشش کوتاه ستاره.
/// یک کنترلر کوتاهِ اختصاصی دارد و فقط هنگام لمس اجرا می‌شود.
class _InteractiveDecor extends StatefulWidget {
  final Widget child;

  const _InteractiveDecor({required this.child});

  @override
  State<_InteractiveDecor> createState() => _InteractiveDecorState();
}

class _InteractiveDecorState extends State<_InteractiveDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reactCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _reactCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.90)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.90, end: 1.07)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.07, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(_reactCtrl);
  }

  @override
  void dispose() {
    _reactCtrl.dispose();
    super.dispose();
  }

  void _react() {
    HapticFeedback.lightImpact();
    AudioService.tap();
    _reactCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _react,
      child: AnimatedBuilder(
        animation: _reactCtrl,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            alignment: Alignment.bottomCenter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                child ?? const SizedBox.shrink(),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DecorBurstPainter(_reactCtrl.value),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// پاشش ستارهٔ واکنش تزئین: چند ستارهٔ کوچک که از مرکز عنصر پخش و
/// محو می‌شوند؛ کوتاه و لطیف، بدون چشمک تند.
class _DecorBurstPainter extends CustomPainter {
  final double progress;

  const _DecorBurstPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1 || size.isEmpty) return;
    final center = Offset(size.width / 2, size.height * 0.38);
    final fade = 1 - progress;
    final maxDist = size.width * 0.42;
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + 0.5;
      final dist = maxDist * progress;
      final pos = Offset(
        center.dx + cos(angle) * dist,
        center.dy + sin(angle) * dist * 0.8 - progress * 10,
      );
      final r = 1.4 + fade * 3.6;
      final color = i.isEven ? const Color(0xFFFFC93C) : Colors.white;
      canvas.drawPath(
        _sparklePath(pos, r),
        Paint()..color = color.withOpacity(0.85 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_DecorBurstPainter old) => old.progress != progress;
}

/// بالن با رانش افقیِ آرام — برخلاف بقیهٔ تزئینات بیشتر «سفر» می‌کند
/// تا «شناور» باشد.
class _BalloonDecor extends StatelessWidget {
  final Animation<double> animation;

  const _BalloonDecor({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final v = animation.value * 2 * pi;
        return Transform.translate(
          offset: Offset(sin(v) * 13, cos(v * 0.5 + 1) * 5),
          child: child,
        );
      },
      child: _InteractiveDecor(
        child: Image.asset(
          IslandWorldAssets.decorBalloon,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

/// ✨ میدانِ ذرات نور: چند ستارهٔ چهارپرِ کوچکِ طلایی و سفید که با
/// فازهای متفاوت چشمک می‌زنند و کمی بالا و پایین می‌شوند. تعدادشان
/// کم و اندازه‌شان کوچک است تا چشم کودک خسته نشود.
class IslandSparkleField extends StatelessWidget {
  final Animation<double> animation;
  final int count;

  const IslandSparkleField({
    super.key,
    required this.animation,
    this.count = 12,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SparkleFieldPainter(animation, count),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SparkleFieldPainter extends CustomPainter {
  final Animation<double> animation;
  final int count;

  _SparkleFieldPainter(this.animation, this.count)
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (var i = 0; i < count; i++) {
      // جای ثابت و قطعی هر ذره (بدون Random) تا بین فریم‌ها نپرد
      final seedX = ((i * 2654435761) % 1000) / 1000.0;
      final seedY = ((i * 40503 + 137) % 1000) / 1000.0;
      final x = (0.06 + seedX * 0.88) * size.width;
      final y = (0.03 + seedY * 0.94) * size.height +
          sin(t * 2 * pi + i * 1.7) * 7;
      final twinkle = (sin(t * 2 * pi * (1 + seedX) + i * 2.3) + 1) / 2;
      final radius = 2.4 + seedY * 2.8 + twinkle * 1.6;
      final color = i.isEven
          ? const Color(0xFFFFD54F)
          : const Color(0xFFFFFFFF);
      final paint = Paint()
        ..color = color.withOpacity(0.10 + twinkle * 0.38);
      canvas.drawPath(_sparklePath(Offset(x, y), radius), paint);
    }
  }

  @override
  bool shouldRepaint(_SparkleFieldPainter old) =>
      old.count != count || old.animation != animation;
}

/// ستارهٔ چهارپرِ کلاسیکِ بازی‌های کودک (الماسِ خمیده).
Path _sparklePath(Offset center, double radius) {
  return Path()
    ..moveTo(center.dx, center.dy - radius)
    ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
    ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
    ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
    ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
}

/// ═══════════════════════════════════════════════════════════════
/// 🐠 تزئیناتِ ناحیهٔ زیرِ آب: ماهی‌هایی که رد می‌شوند، جلبک‌هایی
/// که با جریان آب تاب می‌خورند، مرجان و ستارهٔ دریایی.
///
/// روی همان کنترلر حباب‌های موجود سوار است (۱۲ ثانیه) و هیچ
/// کنترلر تازه‌ای نمی‌سازد.
/// ═══════════════════════════════════════════════════════════════
class UnderwaterDecor extends StatelessWidget {
  final Animation<double> animation;

  const UnderwaterDecor({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _UnderwaterPainter(animation),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _UnderwaterPainter extends CustomPainter {
  final Animation<double> animation;

  _UnderwaterPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    _paintSeaweed(canvas, w, h, t);
    _paintCoral(canvas, Offset(w * 0.15, h), 1, t);
    _paintCoral(canvas, Offset(w * 0.84, h), 0.8, t + 0.4);
    _paintStarfish(canvas, Offset(w * 0.34, h - 10), t);

    // سه ماهی با سرعت و جهت متفاوت؛ بیرون از کادر شروع و تمام می‌شوند
    final fishLen = (w * 0.11).clamp(26.0, 54.0);
    final travel1 = ((t * 0.85 + 0.05) % 1.2) - 0.1;
    _paintFish(
      canvas,
      Offset(travel1 * w, h * 0.30 + sin(t * 2 * pi) * 4),
      fishLen,
      const Color(0xFFFFFFFF).withOpacity(0.30),
      flip: false,
    );
    final travel2 = ((t * 0.6 + 0.45) % 1.2) - 0.1;
    _paintFish(
      canvas,
      Offset(w - travel2 * w, h * 0.58 + cos(t * 2 * pi + 2) * 4),
      fishLen * 0.8,
      const Color(0xFFFFB74D).withOpacity(0.55),
      flip: true,
    );
    final travel3 = ((t * 0.45 + 0.75) % 1.2) - 0.1;
    _paintFish(
      canvas,
      Offset(travel3 * w, h * 0.78 + sin(t * 2 * pi + 4) * 3),
      fishLen * 0.62,
      const Color(0xFFFFFFFF).withOpacity(0.20),
      flip: false,
    );
  }

  void _paintFish(
    Canvas canvas,
    Offset center,
    double len,
    Color color, {
    required bool flip,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (flip) canvas.scale(-1, 1);
    final body = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: len, height: len * 0.42),
      body,
    );
    final tail = Path()
      ..moveTo(-len * 0.40, 0)
      ..lineTo(-len * 0.72, -len * 0.27)
      ..lineTo(-len * 0.72, len * 0.27)
      ..close();
    canvas.drawPath(tail, body);
    canvas.drawCircle(
      Offset(len * 0.27, -len * 0.05),
      len * 0.05,
      Paint()..color = const Color(0xFF0B3B54).withOpacity(0.65),
    );
    canvas.restore();
  }

  void _paintSeaweed(Canvas canvas, double w, double h, double t) {
    final paint = Paint()
      ..color = const Color(0xFF2E9E6B).withOpacity(0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (final xFrac in [0.05, 0.47, 0.95]) {
      for (var blade = -1; blade <= 1; blade++) {
        final baseX = w * xFrac + blade * 9;
        final sway = sin(t * 2 * pi + xFrac * 9 + blade) * 7;
        final height = h * (0.34 + 0.08 * (blade + 1));
        final path = Path()
          ..moveTo(baseX, h + 4)
          ..quadraticBezierTo(
            baseX + sway * 0.4,
            h - height * 0.55,
            baseX + sway,
            h - height,
          );
        canvas.drawPath(path, paint);
      }
    }
  }

  void _paintCoral(Canvas canvas, Offset base, double scale, double t) {
    final paint = Paint()
      ..color = const Color(0xFFF48FB1).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * scale
      ..strokeCap = StrokeCap.round;
    final tipPaint = Paint()..color = const Color(0xFFFFCCDC).withOpacity(0.8);
    final sway = sin(t * 2 * pi + base.dx) * 2;
    final branches = <List<double>>[
      // [زاویه نسبت به عمود، طول] — سه شاخهٔ اصلی
      [0.0, 34.0],
      [-0.55, 24.0],
      [0.5, 22.0],
    ];
    for (final branch in branches) {
      final angle = branch[0];
      final len = branch[1] * scale;
      final tip = Offset(
        base.dx + sin(angle) * len + sway,
        base.dy - cos(angle) * len,
      );
      canvas.drawLine(base, tip, paint);
      canvas.drawCircle(tip, 3.2 * scale, tipPaint);
    }
  }

  void _paintStarfish(Canvas canvas, Offset center, double t) {
    final rotation = sin(t * 2 * pi) * 0.18;
    final path = Path();
    for (var k = 0; k < 10; k++) {
      final angle = -pi / 2 + rotation + k * pi / 5;
      final radius = k.isEven ? 10.0 : 4.4;
      final point = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      if (k == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFFFFA726).withOpacity(0.62),
    );
  }

  @override
  bool shouldRepaint(_UnderwaterPainter old) => old.animation != animation;
}
