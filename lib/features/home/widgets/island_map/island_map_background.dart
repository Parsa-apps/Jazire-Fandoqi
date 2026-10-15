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

  /// یک کنترلر مشترک برای حرکت کم‌هزینهٔ ابر، پرنده و برق آب.
  /// اختیاری است تا هاب‌های قدیمی هم بدون تغییر سازنده باقی بمانند.
  final Animation<double>? ambientAnimation;

  final DayCycle cycle;

  const IslandMapBackground({
    super.key,
    required this.scrollOffset,
    required this.cycle,
    this.ambientAnimation,
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
          ambientAnimation: ambientAnimation,
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
  final Animation<double>? ambientAnimation;

  _SkyOceanPainter({
    required this.scrollOffset,
    required this.cycle,
    required this.progress,
    required this.ambientAnimation,
  }) : super(repaint: ambientAnimation);

  /// خط افق: بالای نقشه پایینِ کادر است و هرچه پایین‌تر می‌رویم بالا می‌آید
  double get _horizon => (1.15 - progress * 1.30).clamp(-0.15, 1.15);

  Color get _skyTop => switch (cycle) {
        DayCycle.morning => AppColors.mapSkyMorning,
        DayCycle.noon => AppColors.mapSkyNoon,
        DayCycle.sunset => AppColors.mapSkySunset,
        DayCycle.night => AppColors.mapSkyNight,
      };

  /// آسمانِ نزدیک افق کمی روشن‌تر و گرم‌تر است
  Color get _skyLow => switch (cycle) {
        DayCycle.morning => const Color(0xFFFFF0D2),
        DayCycle.noon => const Color(0xFFDFF4FF),
        DayCycle.sunset => const Color(0xFFFFD9A0),
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
    final ambientPhase = ambientAnimation?.value ?? 0.0;

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
      _paintClouds(canvas, size, skyFade, ambientPhase);
      // در چرخهٔ شب، آسمان عمداً بدون پرنده و پروانه می‌ماند.
      if (ambientAnimation != null && cycle != DayCycle.night) {
        _paintBirds(canvas, size, skyFade, ambientPhase);
        _paintButterflies(canvas, size, skyFade, ambientPhase);
      }
      canvas.restore();
    }
    _paintDistantIslands(canvas, size, skyFade, ambientPhase);
    _paintWaves(canvas, size, ambientPhase);
    if (ambientAnimation != null) {
      _paintWaterGlimmers(canvas, size, ambientPhase);
      _paintLightRays(canvas, size, ambientPhase);
      _paintDeepFish(canvas, size, ambientPhase);
    }
  }

  /// خورشید (یا ماه در شب) گوشهٔ بالا با هالهٔ نرم
  void _paintSun(Canvas canvas, Size size, double fade) {
    final isNight = cycle == DayCycle.night;
    final center = Offset(size.width * 0.82, size.height * 0.035);
    final r = size.width * 0.11;
    // نسخه ۷: در غروب خورشید نارنجی و گرم‌تر می‌شود
    final Color sunColor;
    if (isNight) {
      sunColor = const Color(0xFFFFF3C4);
    } else if (cycle == DayCycle.sunset) {
      sunColor = const Color(0xFFFF9E5E);
    } else {
      sunColor = const Color(0xFFFFD54F);
    }
    final body = sunColor.withOpacity(fade);

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

  /// ابرهای حجیم با شناوری آرام و پارالاکس وابسته به اسکرول
  void _paintClouds(Canvas canvas, Size size, double fade, double phase) {
    final paint = Paint()
      ..color = Colors.white
          .withOpacity((cycle == DayCycle.night ? 0.30 : 0.82) * fade);

    const spots = <List<double>>[
      // [x نسبی, y نسبی, مقیاس, ضریب پارالاکس]
      [0.16, 0.045, 1.00, 0.10],
      [0.62, 0.095, 0.72, 0.16],
      [0.30, 0.150, 0.85, 0.22],
      [0.80, 0.205, 0.65, 0.13],
      [0.10, 0.255, 0.78, 0.19],
    ];

    final span = size.height + 320;
    for (var i = 0; i < spots.length; i++) {
      final spot = spots[i];
      final driftX = sin(phase * 2 * pi + i * 1.4) * size.width * 0.018;
      final driftY = cos(phase * 2 * pi + i * 0.9) * 5;
      var dy = (spot[1] * size.height) - scrollOffset * spot[3] + driftY;
      dy = ((dy + 160) % span + span) % span - 160;
      _cloud(
        canvas,
        Offset(spot[0] * size.width + driftX, dy),
        46 * spot[2],
        paint,
      );
    }
  }

  /// سه پرندهٔ کوچک که آرام از آسمان می‌گذرند؛ بیرون از جزیره پنهان‌اند.
  void _paintBirds(Canvas canvas, Size size, double fade, double phase) {
    if (fade < 0.18) return;
    final birdColor =
        cycle == DayCycle.night ? Colors.white : const Color(0xFF316A7A);
    final paint = Paint()
      ..color = birdColor.withOpacity(
        (cycle == DayCycle.night ? 0.42 : 0.34) * fade,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final travel = (phase * 0.18 + i / 3) % 1.0;
      final x = travel * (size.width + 72) - 36;
      final y = size.height * (i.isEven ? 0.13 : 0.175) +
          sin(phase * 2 * pi + i * 1.8) * 7;
      final scale = i.isEven ? 0.72 : 0.90;
      final bird = Path()
        ..moveTo(x - 8 * scale, y)
        ..quadraticBezierTo(x - 4 * scale, y - 6 * scale, x, y)
        ..quadraticBezierTo(x + 4 * scale, y - 6 * scale, x + 8 * scale, y);
      canvas.drawPath(bird, paint);
    }
  }

  /// دو پروانهٔ دوردست؛ بال‌زدن فقط با تغییر ظرافتِ اندازه انجام می‌شود.
  void _paintButterflies(Canvas canvas, Size size, double fade, double phase) {
    if (fade < 0.26) return;
    for (var i = 0; i < 2; i++) {
      final t = phase * 2 * pi + (i == 0 ? 0.0 : pi);
      final xOffset = i == 0 ? 0.0 : 0.57;
      final x = ((phase * 0.11 + xOffset) % 1.0) * size.width;
      final y = size.height * (i == 0 ? 0.27 : 0.36) + sin(t) * 12;
      final wing = 3.2 + (sin(t * 3).abs() * 2.0);
      final wingColor =
          i == 0 ? const Color(0xFFFFD166) : const Color(0xFFF48FB1);
      final paint = Paint()..color = wingColor.withOpacity(0.62 * fade);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x - wing * 0.65, y),
          width: wing,
          height: wing * 1.5,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + wing * 0.65, y),
          width: wing,
          height: wing * 1.5,
        ),
        paint,
      );
      canvas.drawLine(
        Offset(x, y - 2.2),
        Offset(x, y + 2.2),
        Paint()
          ..color = const Color(0xFF6E5840).withOpacity(0.52 * fade)
          ..strokeWidth = 1.1,
      );
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

  /// دو جزیرهٔ دوردست روی خط افق — حسِ «دنیای بزرگ‌تر» می‌دهند و با
  /// محو شدن آسمان (نزدیک شدن به زیر آب) خودشان هم محو می‌شوند.
  void _paintDistantIslands(
    Canvas canvas,
    Size size,
    double fade,
    double phase,
  ) {
    final horizonY = size.height * _horizon;
    if (fade < 0.08 || horizonY < 8 || horizonY > size.height - 4) return;
    // پارالاکس خیلی آرام: با اسکرول کمتر از سکوها جابه‌جا می‌شوند
    final drift = -scrollOffset * 0.015;
    _distantIsland(
      canvas,
      Offset(size.width * 0.15 + drift, horizonY),
      size.width * 0.13,
      fade,
    );
    _distantIsland(
      canvas,
      Offset(size.width * 0.76 + drift * 1.4, horizonY),
      size.width * 0.09,
      fade,
    );
  }

  void _distantIsland(Canvas canvas, Offset base, double w, double fade) {
    final green = Paint()
      ..color = const Color(0xFF3D9970).withOpacity(0.38 * fade);
    final sea = Paint()
      ..color = const Color(0xFF1F7A8C).withOpacity(0.32 * fade);
    // گنبد سبز جزیره
    final dome = Path()
      ..moveTo(base.dx - w, base.dy)
      ..quadraticBezierTo(base.dx, base.dy - w * 0.66, base.dx + w, base.dy)
      ..close();
    canvas.drawPath(dome, green);
    // بازتاب روی آب
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(base.dx, base.dy + 3),
        width: w * 2.15,
        height: 7,
      ),
      sea,
    );
    // نخل کوچک روی جزیره
    final palmPaint = Paint()
      ..color = const Color(0xFF2E7D5B).withOpacity(0.55 * fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final trunkTop = Offset(base.dx + w * 0.05, base.dy - w * 0.52);
    canvas.drawLine(
      Offset(base.dx, base.dy - w * 0.30),
      trunkTop,
      palmPaint,
    );
    for (final angle in [-2.6, -1.9, -1.2, -0.5]) {
      canvas.drawLine(
        trunkTop,
        trunkTop + Offset(cos(angle) * w * 0.20, sin(angle) * w * 0.20),
        palmPaint,
      );
    }
  }

  /// پرتوهای نورِ خورشید که وقتی کودک به عمق دریا می‌رسد، از سطح آب
  /// به پایین می‌تابند. هرچه عمیق‌تر، پررنگ‌تر (تا سقف ملایم).
  void _paintLightRays(Canvas canvas, Size size, double phase) {
    if (progress < 0.45) return;
    var strength = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
    if (cycle == DayCycle.night) strength *= 0.35;
    if (strength <= 0.01) return;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.055 * strength);
    for (var i = 0; i < 3; i++) {
      final topX = size.width * (0.14 + 0.30 * i) +
          sin(phase * 2 * pi + i * 1.8) * 12;
      final beam = Path()
        ..moveTo(topX, -4)
        ..lineTo(topX + size.width * 0.10, -4)
        ..lineTo(topX + size.width * 0.24, size.height * 0.72)
        ..lineTo(topX + size.width * 0.07, size.height * 0.72)
        ..close();
      canvas.drawPath(beam, paint);
    }
  }

  /// دو ماهیِ سایه‌نما در عمق — فقط وقتی واقعاً پایین نقشه‌ایم دیده
  /// می‌شوند تا حس فرود به دنیای زیر آب کامل شود.
  void _paintDeepFish(Canvas canvas, Size size, double phase) {
    if (progress < 0.55) return;
    final strength = ((progress - 0.55) / 0.45).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = const Color(0xFF0D4A66).withOpacity(0.22 * strength);
    final travel1 = ((phase * 0.5 + 0.10) % 1.2) - 0.1;
    _deepFish(canvas, Offset(travel1 * size.width, size.height * 0.46), 36,
        paint, false);
    final travel2 = ((phase * 0.35 + 0.55) % 1.2) - 0.1;
    _deepFish(canvas, Offset(size.width - travel2 * size.width, size.height * 0.66),
        25, paint, true);
  }

  void _deepFish(
    Canvas canvas,
    Offset center,
    double len,
    Paint paint,
    bool flip,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (flip) canvas.scale(-1, 1);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: len, height: len * 0.4),
      paint,
    );
    final tail = Path()
      ..moveTo(-len * 0.40, 0)
      ..lineTo(-len * 0.72, -len * 0.26)
      ..lineTo(-len * 0.72, len * 0.26)
      ..close();
    canvas.drawPath(tail, paint);
    canvas.restore();
  }

  /// موج‌های افقی ملایم روی اقیانوس با حرکت بسیار آهسته
  void _paintWaves(Canvas canvas, Size size, double ambientPhase) {
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
      final motion =
          (i.isEven ? 0.0 : wave / 2) - scrollOffset * 0.05 + ambientPhase * wave;
      path.moveTo(-wave, y);
      for (var x = -wave; x < size.width + wave; x += wave) {
        path.relativeQuadraticBezierTo(wave / 4, -amp, wave / 2, 0);
        path.relativeQuadraticBezierTo(wave / 4, amp, wave / 2, 0);
      }
      canvas.save();
      canvas.translate((motion % wave + wave) % wave, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
      y += 78;
      i++;
    }
  }

  /// برق‌های کوچک و کم‌تعداد روی سطح آب
  void _paintWaterGlimmers(Canvas canvas, Size size, double phase) {
    final top = (size.height * _horizon).clamp(0.0, size.height).toDouble();
    if (_horizon > 1.0) return;
    const offsets = <double>[0.0, 0.173, 0.346, 0.519, 0.692, 0.865, 0.038];
    const lanes = <double>[0.08, 0.19, 0.30, 0.41];
    for (var i = 0; i < offsets.length; i++) {
      final travel = (phase * 0.42 + offsets[i]) % 1.0;
      final x = travel * size.width;
      final y = top + size.height * lanes[i % lanes.length] +
          sin(phase * 2 * pi + i * 1.3) * 5;
      if (y > size.height) continue;
      final pulse = (sin(phase * 2 * pi + i * 1.7) + 1) / 2;
      final opacity = (cycle == DayCycle.night ? 0.08 : 0.12 + pulse * 0.12);
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x - 7, y), Offset(x + 7, y), paint);
    }
  }

  @override
  bool shouldRepaint(_SkyOceanPainter old) =>
      // کنترلر repaint را مستقیم به CustomPainter می‌فرستد؛ این شرط‌ها
      // برای تغییر اندازه، اسکرول و چرخهٔ روز هستند.
      (old.scrollOffset - scrollOffset).abs() > 1.5 ||
      (old.progress - progress).abs() > 0.002 ||
      old.cycle != cycle ||
      old.ambientAnimation != ambientAnimation;
}

/// حباب‌های ریزِ شناور که حس زیرِ آب بودن بخش پایانی نقشه را می‌سازند.
class FloatingBubbles extends StatelessWidget {
  final Animation<double> animation;
  final int count;

  const FloatingBubbles({super.key, required this.animation, this.count = 10});

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
