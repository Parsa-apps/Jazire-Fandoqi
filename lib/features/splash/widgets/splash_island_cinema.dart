import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/island_cinema_style.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌅 لایهٔ سینماییِ اسپلش — بیدارشدنِ جزیره
///
/// ترتیبِ نمایش (هم‌زمان و نه پشتِ‌سرِهم، تا اسپلش کش نیاید):
///   ۱. تاریکیِ آرام و نورِ کنترل‌شده؛
///   ۲. خورشید از پشتِ خط‌الرأس بالا می‌آید و آب جان می‌گیرد؛
///   ۳. فندقی از پشتِ برگِ گوشهٔ راست وارد می‌شود؛
///   ۴. همه‌چیز در انتقالِ بعدی نرم محو می‌شود.
///
/// این لایه هیچ تصمیمی دربارهٔ آماده‌بودنِ برنامه نمی‌گیرد: نوارِ
/// پیشرفت و منطقِ خروج همان [StartupCoordinator] است و دست‌نخورده
/// مانده. فقط «صحنه» اینجا اضافه شده است.
/// ═══════════════════════════════════════════════════════════════
class SplashIslandCinema extends StatelessWidget {
  const SplashIslandCinema({
    super.key,
    required this.master,
    required this.ambient,
    required this.reduceMotion,
  });

  /// پیشرفتِ ورودِ اسپلش (۰ تا ۱)
  final Animation<double> master;

  /// چرخهٔ آرامِ محیط (برای موج و برگ)
  final Animation<double> ambient;

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[master, ambient]),
        builder: (BuildContext context, Widget? _) {
          final wake = Curves.easeOutCubic.transform(
            ((master.value - 0.12) / 0.62).clamp(0.0, 1.0),
          );
          final heroIn = Curves.easeOutBack.transform(
            ((master.value - 0.30) / 0.55).clamp(0.0, 1.0),
          ).clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomPaint(
                painter: SplashIslandPainter(
                  wake: wake,
                  ambient: reduceMotion ? 0.25 : ambient.value,
                ),
                size: Size.infinite,
              ),
              _PeekingFandoqi(
                progress: heroIn,
                ambient: reduceMotion ? 0.25 : ambient.value,
              ),
              CustomPaint(
                painter: SplashLeafPainter(
                  reveal: heroIn,
                  ambient: reduceMotion ? 0.25 : ambient.value,
                ),
                size: Size.infinite,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 🐿️ فندقی که از پشتِ برگِ گوشهٔ راست بیرون می‌آید.
class _PeekingFandoqi extends StatelessWidget {
  const _PeekingFandoqi({required this.progress, required this.ambient});

  final double progress;
  final double ambient;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.maybeOf(context)?.size;
    final heroSize = math
        .min((size?.width ?? 360) * 0.42, (size?.height ?? 720) * 0.24)
        .clamp(96.0, 210.0);
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;

    // از پایین-راست می‌آید و کمی می‌چرخد
    final dx = (1 - progress) * heroSize * 1.05;
    final dy = (1 - progress) * heroSize * 0.30;
    final bob = math.sin(ambient * 2 * math.pi) * heroSize * 0.012;

    return PositionedDirectional(
      end: -heroSize * 0.10,
      bottom: heroSize * 0.10,
      child: IgnorePointer(
        child: Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(dx, dy + bob),
            child: Transform.rotate(
              angle: (1 - progress) * 0.35,
              child: Image.asset(
                'assets/mascot/fandoghi_wave_v2.webp',
                width: heroSize,
                height: heroSize,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                cacheWidth: (heroSize * dpr).round().clamp(96, 512),
                excludeFromSemantics: true,
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stack) {
                  return SizedBox(
                    width: heroSize,
                    height: heroSize,
                    child: Center(
                      child: Text(
                        '🌰',
                        style: TextStyle(fontSize: heroSize * 0.55),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🏝️ سپیده‌دمِ جزیره: آب، خط‌الرأس و خورشیدِ در حالِ طلوع
class SplashIslandPainter extends CustomPainter {
  const SplashIslandPainter({required this.wake, required this.ambient});

  /// ۰ = شبِ آرام، ۱ = روزِ کامل
  final double wake;

  final double ambient;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizon = h * 0.60;

    // ── آسمان: از شب به سپیده ──
    final skyRect = Rect.fromLTWH(0, 0, w, horizon + 1);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(
              const Color(0xFF0A1B33),
              IslandCinemaPalette.skyHigh,
              wake,
            )!,
            Color.lerp(
              const Color(0xFF123A5C),
              IslandCinemaPalette.skyMid,
              wake,
            )!,
            Color.lerp(
              const Color(0xFF2A5A78),
              IslandCinemaPalette.skyLow,
              wake,
            )!,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ).createShader(skyRect),
    );

    // ── خورشیدِ در حالِ طلوع ──
    final sunY = horizon - h * (0.02 + 0.13 * wake);
    final sunX = w * 0.66;
    final sunR = math.min(w, h) * 0.058;
    canvas.drawCircle(
      Offset(sunX, sunY),
      sunR * (3.0 + wake * 1.4),
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            IslandCinemaPalette.sunGlow.withOpacity(0.10 + 0.24 * wake),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(sunX, sunY),
            radius: sunR * (3.0 + wake * 1.4),
          ),
        ),
    );
    canvas.drawCircle(
      Offset(sunX, sunY),
      sunR,
      Paint()
        ..color = Color.lerp(
          IslandCinemaPalette.sunCore.withOpacity(0.55),
          IslandCinemaPalette.sunCore,
          wake,
        )!,
    );

    // ── دریا ──
    final seaRect = Rect.fromLTWH(0, horizon, w, h - horizon);
    canvas.drawRect(
      seaRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(
              const Color(0xFF0B2A44),
              IslandCinemaPalette.seaMid,
              wake,
            )!,
            Color.lerp(
              const Color(0xFF04172A),
              IslandCinemaPalette.seaDeep,
              wake,
            )!,
          ],
        ).createShader(seaRect),
    );

    // موج‌های بیدارشونده
    final wavePaint = Paint()
      ..color = IslandCinemaPalette.foam.withOpacity(0.06 + 0.16 * wake)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, h * 0.0022);
    for (var i = 0; i < 5; i++) {
      final t = i / 4;
      final y = horizon + (h - horizon) * (0.06 + t * 0.5);
      final amp = h * 0.004 * (1 + t);
      final drift = ambient * w * 0.5;
      final path = Path();
      path.moveTo(-w * 0.1, y);
      for (var x = -w * 0.1; x <= w * 1.1; x += w / 14) {
        path.lineTo(x, y + math.sin((x + drift) / (w * 0.42) * 2 * math.pi) * amp);
      }
      canvas.drawPath(path, wavePaint);
    }

    // ── خط‌الرأسِ جزیره (سیلوئت) ──
    final ridge = Path()
      ..moveTo(-w * 0.05, horizon)
      ..quadraticBezierTo(w * 0.10, horizon - h * 0.115, w * 0.26, horizon - h * 0.045)
      ..quadraticBezierTo(w * 0.38, horizon - h * 0.008, w * 0.50, horizon - h * 0.095)
      ..quadraticBezierTo(w * 0.66, horizon - h * 0.180, w * 0.80, horizon - h * 0.055)
      ..quadraticBezierTo(w * 0.92, horizon - h * 0.012, w * 1.05, horizon - h * 0.075)
      ..lineTo(w * 1.05, horizon)
      ..close();
    canvas.drawPath(
      ridge,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(
              const Color(0xFF04121F),
              IslandCinemaPalette.forestDeep,
              wake,
            )!,
            Color.lerp(
              const Color(0xFF020A12),
              const Color(0xFF0B3A2C),
              wake,
            )!,
          ],
        ).createShader(
          Rect.fromLTWH(0, horizon - h * 0.19, w, h * 0.20),
        ),
    );

    // هالهٔ گرمِ پشتِ خط‌الرأس (طلوع)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(sunX, horizon - h * 0.02),
        width: w * 0.55,
        height: h * 0.09,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            IslandCinemaPalette.sunHalo.withOpacity(0.30 * wake),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(sunX, horizon - h * 0.02),
            width: w * 0.55,
            height: h * 0.09,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant SplashIslandPainter oldDelegate) {
    return oldDelegate.wake != wake || oldDelegate.ambient != ambient;
  }
}

/// 🍃 خوشهٔ برگِ گوشهٔ راست که فندقی از پشتش بیرون می‌آید
class SplashLeafPainter extends CustomPainter {
  const SplashLeafPainter({required this.reveal, required this.ambient});

  final double reveal;
  final double ambient;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = math.min(size.width, size.height) * 0.30;
    final sway = math.sin(ambient * 2 * math.pi) * 0.022;
    // با ورودِ فندقی، برگ کمی عقب می‌رود تا راه باز شود
    final shift = reveal * unit * 0.10;

    canvas.save();
    canvas.translate(size.width + unit * 0.10 + shift, size.height + unit * 0.06);
    canvas.rotate(math.pi * 0.78 + sway);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          IslandCinemaPalette.forestDeep.withOpacity(0.92),
          const Color(0xFF04121B).withOpacity(0.96),
        ],
      ).createShader(Rect.fromLTWH(0, -unit * 0.6, unit, unit * 1.2));

    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(unit * 0.55, -unit * 0.42, unit, -unit * 0.10)
        ..quadraticBezierTo(unit * 0.52, unit * 0.42, 0, 0)
        ..close(),
      paint,
    );
    // یک برگِ کوچک‌تر برای پُریِ خوشه
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(unit * 0.40, -unit * 0.62, unit * 0.72, -unit * 0.36)
        ..quadraticBezierTo(unit * 0.38, unit * 0.10, 0, 0)
        ..close(),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SplashLeafPainter oldDelegate) {
    return oldDelegate.reveal != reveal || oldDelegate.ambient != ambient;
  }
}
