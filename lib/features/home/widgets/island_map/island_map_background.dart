import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_theme.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌤️ لایهٔ پس‌زمینهٔ نقشهٔ جزیره — آسمان، ابر، خورشید و اقیانوس
///
/// این لایه با نقاشی برداری (CustomPainter) کشیده می‌شود نه با تصویر،
/// چون باید هر ارتفاعی را بدون کشیدگی پر کند و با چرخهٔ روز عوض شود.
/// ═══════════════════════════════════════════════════════════════
class IslandMapBackground extends StatelessWidget {
  /// موقعیت اسکرول برای حرکت پارالاکس ابرها
  final double scrollOffset;

  /// پیشرفت سفر از بالای نقشه (۰) تا پایین آن (۱).
  /// خطِ افق با همین مقدار پایین می‌آید تا کودک حس کند واقعاً
  /// از آسمان به سمت عمق دریا فرود می‌آید.
  final double progress;

  final DayCycle cycle;

  const IslandMapBackground({
    super.key,
    required this.scrollOffset,
    required this.cycle,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SkyOceanPainter(
          scrollOffset: scrollOffset,
          cycle: cycle,
          progress: progress,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SkyOceanPainter extends CustomPainter {
  final double scrollOffset;
  final DayCycle cycle;
  final double progress;

  _SkyOceanPainter({
    required this.scrollOffset,
    required this.cycle,
    required this.progress,
  });

  /// خط افق: بالای نقشه پایینِ کادر است و هرچه پایین‌تر می‌رویم بالا می‌آید
  double get _horizon => (1.15 - progress * 1.30).clamp(-0.15, 1.15);

  Color get _skyTop => switch (cycle) {
        DayCycle.morning => AppColors.mapSkyMorning,
        DayCycle.noon => AppColors.mapSkyNoon,
        DayCycle.night => AppColors.mapSkyNight,
      };

  /// آسمانِ نزدیک افق کمی روشن‌تر و گرم‌تر است
  Color get _skyLow => switch (cycle) {
        DayCycle.morning => const Color(0xFFFFF0D2),
        DayCycle.noon => const Color(0xFFDFF4FF),
        DayCycle.night => const Color(0xFF64729B),
      };

  Color get _seaTop => switch (cycle) {
        DayCycle.night => const Color(0xFF1E4C6E),
        _ => AppColors.mapSeaTop,
      };

  Color get _seaDeep => switch (cycle) {
        DayCycle.night => const Color(0xFF06263D),
        _ => AppColors.mapSeaDeep,
      };

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ── ۱. گرادیان آسمان → سطح دریا → عمق ──
    final hz = _horizon;
    final stops = <double>[
      0.0,
      (hz - 0.12).clamp(0.001, 0.985),
      hz.clamp(0.002, 0.99),
      1.0,
    ];
    // اطمینان از صعودی بودن stops (شرط LinearGradient)
    for (var i = 1; i < stops.length; i++) {
      if (stops[i] <= stops[i - 1]) stops[i] = stops[i - 1] + 0.001;
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_skyTop, _skyLow, _seaTop, _seaDeep],
          stops: stops,
        ).createShader(rect),
    );

    // هرچه پایین‌تر می‌رویم آسمان کم‌رنگ‌تر می‌شود تا زیرِ آب برویم
    final skyFade = (hz * 1.6).clamp(0.0, 1.0);
    if (skyFade > 0.02) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height * hz + 4));
      _paintSun(canvas, size, skyFade);
      _paintClouds(canvas, size, skyFade);
      canvas.restore();
    }
    _paintWaves(canvas, size);
  }

  /// خورشید (یا ماه در شب) گوشهٔ بالا با هالهٔ نرم
  void _paintSun(Canvas canvas, Size size, double fade) {
    final isNight = cycle == DayCycle.night;
    final center = Offset(size.width * 0.82, size.height * 0.035);
    final r = size.width * 0.11;
    final body = (isNight ? const Color(0xFFFFF3C4) : const Color(0xFFFFD54F))
        .withOpacity(fade);

    canvas.drawCircle(
      center,
      r * 2.1,
      Paint()
        ..shader = RadialGradient(
          colors: [body.withOpacity(0.45 * fade), body.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: center, radius: r * 2.1)),
    );

    if (!isNight) {
      canvas.drawCircle(center, r, Paint()..color = body);
      return;
    }

    // ماه هلالی: قرص ماه را داخل یک لایهٔ جدا می‌کشیم تا برشِ هلال
    // فقط ماه را سوراخ کند، نه آسمانِ زیرش.
    final layer = Rect.fromCircle(center: center, radius: r * 1.2);
    canvas.saveLayer(layer, Paint());
    canvas.drawCircle(center, r, Paint()..color = body);
    canvas.drawCircle(
      center.translate(-r * 0.45, -r * 0.25),
      r * 0.92,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
  }

  /// ابرهای پفکی با پارالاکس آرام نسبت به اسکرول
  void _paintClouds(Canvas canvas, Size size, double fade) {
    final paint = Paint()
      ..color = Colors.white
          .withOpacity((cycle == DayCycle.night ? 0.30 : 0.82) * fade);

    // موقعیت‌های نسبی ثابت تا ابرها هر فریم نپرند
    const spots = <List<double>>[
      // [x نسبی, y نسبی, مقیاس, ضریب پارالاکس]
      [0.16, 0.045, 1.00, 0.10],
      [0.62, 0.095, 0.72, 0.16],
      [0.30, 0.150, 0.85, 0.22],
      [0.80, 0.205, 0.65, 0.13],
      [0.10, 0.255, 0.78, 0.19],
    ];

    // بازهٔ چرخش عمودی: ابرها به‌جای تمام‌شدن، از پایین دوباره بالا می‌آیند
    final span = size.height + 320;
    for (final s in spots) {
      var dy = (s[1] * size.height) - scrollOffset * s[3];
      dy = ((dy + 160) % span + span) % span - 160;
      _cloud(canvas, Offset(s[0] * size.width, dy), 46 * s[2], paint);
    }
  }

  void _cloud(Canvas canvas, Offset c, double r, Paint p) {
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c.translate(r * 0.85, r * 0.16), r * 0.74, p);
    canvas.drawCircle(c.translate(-r * 0.82, r * 0.20), r * 0.66, p);
    canvas.drawCircle(c.translate(r * 0.18, -r * 0.52), r * 0.62, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - r * 1.3, c.dy, r * 2.6, r * 0.85),
        Radius.circular(r * 0.5),
      ),
      p,
    );
  }

  /// موج‌های افقی ملایم روی سطح اقیانوس
  void _paintWaves(Canvas canvas, Size size) {
    final top = size.height * _horizon;
    if (top > size.height) return;
    final paint = Paint()
      ..color = Colors.white.withOpacity(cycle == DayCycle.night ? 0.08 : 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    var y = top < 0 ? 0.0 : top;
    var i = 0;
    while (y < size.height) {
      final path = Path();
      final amp = 5.0 + (i % 3) * 2.0;
      final wave = size.width / 3.2;
      final phase = (i.isEven ? 0.0 : wave / 2) - scrollOffset * 0.05;
      path.moveTo(-wave, y);
      for (var x = -wave; x < size.width + wave; x += wave) {
        path.relativeQuadraticBezierTo(wave / 4, -amp, wave / 2, 0);
        path.relativeQuadraticBezierTo(wave / 4, amp, wave / 2, 0);
      }
      canvas.save();
      canvas.translate(phase % wave, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
      y += 78;
      i++;
    }
  }

  @override
  bool shouldRepaint(_SkyOceanPainter old) =>
      // فقط وقتی اسکرول محسوس جابه‌جا شد دوباره بکش
      (old.scrollOffset - scrollOffset).abs() > 1.5 ||
      (old.progress - progress).abs() > 0.002 ||
      old.cycle != cycle;
}

/// حباب‌های ریزِ شناور که حس زیرِ آب بودن بخش پایانی نقشه را می‌سازند.
class FloatingBubbles extends StatelessWidget {
  final Animation<double> animation;
  final int count;

  const FloatingBubbles({super.key, required this.animation, this.count = 14});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) => CustomPaint(
            painter: _BubblePainter(animation.value, count),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final double t;
  final int count;

  _BubblePainter(this.t, this.count);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.28);
    final stroke = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (var i = 0; i < count; i++) {
      // مقادیر شبه‌تصادفیِ قطعی (بدون Random) تا هر فریم یکسان بمانند
      final seed = (i * 2654435761) % 1000 / 1000.0;
      final r = 4.0 + seed * 9.0;
      final x = ((i * 0.137 + seed * 0.5) % 1.0) * size.width;
      final speed = 0.35 + seed * 0.5;
      final y = size.height - ((t * speed + seed) % 1.0) * size.height;
      final sway = sin((t * 2 * pi) + i) * 8;
      canvas.drawCircle(Offset(x + sway, y), r, paint);
      canvas.drawCircle(Offset(x + sway, y), r, stroke);
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.t != t;
}
