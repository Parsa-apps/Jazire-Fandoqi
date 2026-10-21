import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/parsa_brand.dart';
import '../splash_timeline.dart';

/// ─────────────────────────────────────────────────────────────
/// 🌰 لوگوی جزیرهٔ فندقی در قاب آغازین سینمایی
///
/// سه لایه، همه با یک زمان‌بند:
///   ۱. هالهٔ آبی/طلایی که *قبل از* لوگو شکل می‌گیرد.
///   ۲. ذرات نور که از بیرون به سمت لوگو می‌آیند و بعد محو می‌شوند.
///   ۳. لوگوی فندقی با Fade + Scale و نورپردازی تدریجی.
///
/// پس‌زمینهٔ سفیدِ فایل مرجع شفاف شده تا صحنهٔ جزیره از پشت لوگو دیده شود.
/// ─────────────────────────────────────────────────────────────
class SplashBrand extends StatelessWidget {
  const SplashBrand({
    super.key,
    required this.size,
    required this.master,
    required this.ambient,
    required this.repaint,
    required this.reduceMotion,
    required this.cacheWidth,
  });

  final double size;
  final Animation<double> master;
  final Animation<double> ambient;
  final Listenable repaint;
  final bool reduceMotion;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          // ۱) هالهٔ نورِ پشت لوگو (بزرگ‌تر از خود لوگو).
          Positioned(
            left: -size * 0.32,
            top: -size * 0.32,
            width: size * 1.64,
            height: size * 1.64,
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: _HaloPainter(
                  master: master,
                  ambient: ambient,
                  repaint: repaint,
                  reduceMotion: reduceMotion,
                ),
              ),
            ),
          ),

          // ۲) ذرات نورِ محدود — پشت لوگو و روی هاله.
          if (!reduceMotion)
            Positioned(
              left: -size * 0.55,
              top: -size * 0.55,
              width: size * 2.1,
              height: size * 2.1,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _ParticlePainter(
                    master: master,
                    ambient: ambient,
                    repaint: repaint,
                  ),
                ),
              ),
            ),

          // ۳) لوگوی رسمی.
          Positioned.fill(
            child: _SplashLogo(
              key: const ValueKey<String>('fandoghi_splash_logo'),
              master: master,
              reduceMotion: reduceMotion,
              cacheWidth: cacheWidth,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo({
    super.key,
    required this.master,
    required this.reduceMotion,
    required this.cacheWidth,
  });

  final Animation<double> master;
  final bool reduceMotion;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: master,
      builder: (BuildContext context, Widget? _) {
        final t = master.value;
        final settled = t >= 0.999;

        final appear = reduceMotion
            ? 1.0
            : splashCurve(t, 0.05, 0.44, Curves.easeOutCubic);
        final settle = reduceMotion
            ? 1.0
            : splashCurve(t, 0.05, 0.52, Curves.easeOutCubic);
        final light = reduceMotion
            ? 1.0
            : splashPhase(t, 0.10, 0.60);
        final blueSweep = reduceMotion ? 0.0 : splashPhase(t, 0.44, 0.66);
        final goldSweep = reduceMotion ? 0.0 : splashPhase(t, 0.53, 0.79);

        Widget logo = _sweptLogo(
          blueSweep: blueSweep,
          goldSweep: goldSweep,
        );

        if (!settled) {
          // نورپردازی تدریجی: لوگو از تاریکی روشن می‌شود.
          final brightness = 0.30 + 0.70 * Curves.easeOut.transform(light);
          logo = ColorFiltered(
            colorFilter: ColorFilter.matrix(<double>[
              brightness, 0, 0, 0, 0,
              0, brightness, 0, 0, 0,
              0, 0, brightness, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: logo,
          );
          logo = Opacity(
            opacity: appear.clamp(0.0, 1.0).toDouble(),
            child: Transform.scale(scale: 0.88 + 0.12 * settle, child: logo),
          );
        }

        return logo;
      },
    );
  }

  Widget _sweptLogo({required double blueSweep, required double goldSweep}) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Opacity(
          opacity: 0.0,
          child: _logoPrecacheImage(),
        ),
        _brandImage(),

        // عبور نور آبی از روی لوگو، مثل نور روی فلز.
        if (blueSweep > 0.001 && blueSweep < 0.999)
          ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (Rect bounds) {
              final x = -2.3 + 4.6 * blueSweep;
              return LinearGradient(
                begin: Alignment(x, -0.55),
                end: Alignment(x + 1.15, 0.55),
                colors: <Color>[
                  Colors.transparent,
                  ParsaBrand.iceBlue.withOpacity(0.55),
                  Colors.white.withOpacity(0.42),
                  Colors.transparent,
                ],
                stops: const <double>[0.0, 0.40, 0.50, 0.64],
              ).createShader(bounds);
            },
            child: _brandImage(),
          ),

        // درخشش فلزی طلایی روی نشان و حاشیه‌ها — بعد از نور آبی.
        if (goldSweep > 0.001 && goldSweep < 0.999)
          ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (Rect bounds) {
              final x = -2.1 + 4.2 * goldSweep;
              return LinearGradient(
                begin: Alignment(x, -0.75),
                end: Alignment(x + 0.85, 0.2),
                colors: <Color>[
                  Colors.transparent,
                  ParsaBrand.gold.withOpacity(0.34),
                  ParsaBrand.brightGold.withOpacity(0.30),
                  Colors.transparent,
                ],
                stops: const <double>[0.0, 0.44, 0.52, 0.66],
              ).createShader(bounds);
            },
            child: _brandImage(),
          ),
      ],
    );
  }

  Widget _logoPrecacheImage() {
    return Image.asset(
      'assets/branding/fandoghi_app_logo_alpha.webp',
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return const _BrandFallback();
      },
    );
  }

  Widget _brandImage() {
    return Image.asset(
      'assets/branding/fandoghi_app_logo_alpha.webp',
      fit: BoxFit.contain,
      alignment: const Alignment(0, -0.65),
      filterQuality: FilterQuality.high,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return const _BrandFallback();
      },
    );
  }
}

/// اگر (فقط در حالت خرابی دارایی) لوگو خوانده نشود، صفحه خالی نمی‌ماند.
class _BrandFallback extends StatelessWidget {
  const _BrandFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '🐿️',
            style: TextStyle(
              fontSize: 64,
              shadows: <Shadow>[
                Shadow(
                  color: ParsaBrand.gold.withOpacity(0.55),
                  blurRadius: 24,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'جزیره فندقی',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// هاله
// ─────────────────────────────────────────────────────────────
class _HaloPainter extends CustomPainter {
  _HaloPainter({
    required this.master,
    required this.ambient,
    required Listenable repaint,
    required this.reduceMotion,
  }) : super(repaint: repaint);

  final Animation<double> master;
  final Animation<double> ambient;
  final bool reduceMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final t = master.value;
    final halo = reduceMotion
        ? 1.0
        : splashCurve(t, 0.02, 0.40, Curves.easeOutCubic);
    if (halo <= 0.001) return;

    final pulse = reduceMotion ? 0.4 : splashWave(ambient.value);
    final center = Offset(size.width * 0.5, size.height * 0.47);
    final s = size.shortestSide;

    // هالهٔ آبی پشت لوگو.
    canvas.drawCircle(
      center,
      s * 0.46,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          s * 0.46,
          <Color>[
            ParsaBrand.electricBlue.withOpacity(0.30 * halo),
            ParsaBrand.neonBlue.withOpacity(0.14 * halo),
            ParsaBrand.deepBlue.withOpacity(0.05 * halo),
            Colors.transparent,
          ],
          const <double>[0.0, 0.34, 0.66, 1.0],
        ),
    );

    // هستهٔ یخیِ روشن‌تر، دقیقاً پشت لوگو — حس نورپردازی سه‌بعدی.
    canvas.drawCircle(
      center,
      s * 0.26,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          s * 0.26,
          <Color>[
            ParsaBrand.iceBlue.withOpacity(0.20 * halo),
            ParsaBrand.iceBlue.withOpacity(0.06 * halo),
            Colors.transparent,
          ],
          const <double>[0.0, 0.5, 1.0],
        ),
    );

    // طلاییِ پایین قاب، هم‌خانوادهٔ تاج.
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.73);
    canvas.scale(1.0, 0.34);
    canvas.drawCircle(
      Offset.zero,
      s * 0.34,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          s * 0.34,
          <Color>[
            ParsaBrand.gold.withOpacity(0.11 * halo + 0.02 * pulse),
            ParsaBrand.deepGold.withOpacity(0.05 * halo),
            Colors.transparent,
          ],
          const <double>[0.0, 0.45, 1.0],
        ),
    );
    canvas.restore();

    // حلقه‌های نازکِ فلزی با شیمر چرخان — بسیار ظریف.
    final rotation = reduceMotion ? 0.0 : ambient.value * 2 * math.pi;
    final ringRect = Rect.fromCircle(center: center, radius: s * 0.43);
    canvas.drawCircle(
      center,
      s * 0.43,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..shader = SweepGradient(
          colors: <Color>[
            Colors.transparent,
            ParsaBrand.gold.withOpacity(0.34 * halo),
            Colors.transparent,
            ParsaBrand.neonBlue.withOpacity(0.32 * halo),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.16, 0.42, 0.68, 1.0],
          transform: GradientRotation(rotation),
        ).createShader(ringRect),
    );
    canvas.drawCircle(
      center,
      s * 0.385,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..shader = SweepGradient(
          colors: <Color>[
            Colors.transparent,
            ParsaBrand.iceBlue.withOpacity(0.22 * halo),
            Colors.transparent,
            ParsaBrand.brightGold.withOpacity(0.22 * halo),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.22, 0.5, 0.78, 1.0],
          transform: GradientRotation(-rotation * 0.7),
        ).createShader(ringRect),
    );
  }

  @override
  bool shouldRepaint(covariant _HaloPainter oldDelegate) {
    return oldDelegate.reduceMotion != reduceMotion;
  }
}

// ─────────────────────────────────────────────────────────────
// ذرات نور
// ─────────────────────────────────────────────────────────────
class _ParticleSeed {
  const _ParticleSeed(this.angle, this.radius, this.size, this.gold, this.alpha);

  final double angle;
  final double radius;
  final double size;
  final bool gold;
  final double alpha;
}

final List<_ParticleSeed> _particleSeeds = _buildSeeds();

List<_ParticleSeed> _buildSeeds() {
  final random = math.Random(20251019);
  return List<_ParticleSeed>.generate(18, (int i) {
    return _ParticleSeed(
      random.nextDouble() * math.pi * 2,
      0.42 + random.nextDouble() * 0.58,
      0.7 + random.nextDouble() * 1.6,
      i % 4 == 0,
      0.45 + random.nextDouble() * 0.5,
    );
  });
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.master,
    required this.ambient,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final Animation<double> master;
  final Animation<double> ambient;

  @override
  void paint(Canvas canvas, Size size) {
    final t = master.value;
    if (t <= 0.001 || t >= 0.999) return;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final s = size.shortestSide;
    final converge = splashCurve(t, 0.01, 0.48, Curves.easeOutCubic);
    final fadeAll = 1.0 - splashPhase(t, 0.80, 1.0);
    if (fadeAll <= 0.001) return;

    // مرحلهٔ ۱: حرکت کنترل‌شده به سمت مرکز.
    for (var i = 0; i < _particleSeeds.length; i++) {
      final seed = _particleSeeds[i];
      if (converge <= 0) continue;
      final angle = seed.angle + converge * 0.5;
      final distance = seed.radius * (1 - converge) * s * 0.5;
      final opacity = (converge < 0.14
              ? converge / 0.14
              : 1 - (converge - 0.14) / 0.86) *
          seed.alpha *
          fadeAll;
      if (opacity <= 0.008) continue;
      _drawParticle(
        canvas,
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        seed.size,
        seed.gold ? ParsaBrand.gold : ParsaBrand.iceBlue,
        opacity,
      );
    }

    // مرحلهٔ ۲: چند ذرهٔ کم‌تعداد دور لوگو می‌گردند و سپس محو می‌شوند.
    final orbit = splashPhase(t, 0.42, 0.94);
    if (orbit > 0 && orbit < 1) {
      final orbitOpacity = math.sin(orbit * math.pi) * 0.5;
      final spin = ambient.value * 2 * math.pi;
      for (var i = 0; i < 5; i++) {
        final angle = spin * 0.5 + i * (math.pi * 2 / 5) + t * 1.4;
        final radius = s * (0.20 + 0.012 * math.sin(spin + i));
        _drawParticle(
          canvas,
          center + Offset(math.cos(angle), math.sin(angle)) * radius,
          1.0 + (i % 2) * 0.5,
          i.isEven ? ParsaBrand.iceBlue : ParsaBrand.gold,
          orbitOpacity,
        );
      }
    }
  }

  void _drawParticle(
    Canvas canvas,
    Offset position,
    double radius,
    Color color,
    double opacity,
  ) {
    final paint = Paint()..blendMode = BlendMode.plus;
    paint.color = color.withOpacity(0.06 * opacity);
    canvas.drawCircle(position, radius * 3.0, paint);
    paint.color = color.withOpacity(0.16 * opacity);
    canvas.drawCircle(position, radius * 1.8, paint);
    paint
      ..blendMode = BlendMode.srcOver
      ..color = color.withOpacity(0.85 * opacity);
    canvas.drawCircle(position, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => false;
}
