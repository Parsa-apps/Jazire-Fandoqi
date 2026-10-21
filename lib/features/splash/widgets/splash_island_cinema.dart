import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/island_cinema_style.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌅 لایهٔ سینماییِ اسپلش — دنیای سه‌بعدیِ جزیره فندقی
///
/// تصویرِ سه‌بعدیِ جزیره و سنجابِ فندقی روی صخرهٔ خزه‌دار را به‌همراه
/// ذراتِ نورِ طلایی و سایه‌روشنِ پایینِ قاب (برای خواناییِ نوارِ پیشرفت)
/// نمایش می‌دهد.
/// ═══════════════════════════════════════════════════════════════
class SplashIslandCinema extends StatelessWidget {
  const SplashIslandCinema({
    super.key,
    required this.master,
    required this.ambient,
    required this.reduceMotion,
  });

  final Animation<double> master;
  final Animation<double> ambient;
  final bool reduceMotion;

  static const String splashSceneAsset = 'assets/theme_v2/splash_scene.webp';

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[master, ambient]),
        builder: (BuildContext context, Widget? _) {
          final wake = Curves.easeOutCubic.transform(
            master.value.clamp(0.0, 1.0),
          );
          final phase = reduceMotion ? 0.25 : ambient.value;
          final scale = reduceMotion ? 1.0 : (1.03 - 0.03 * wake);

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // لایهٔ پشتیبانِ برداری در صورتِ عدمِ بارگذاریِ تصویر در محیطِ تست
              CustomPaint(
                painter: SplashIslandPainter(wake: wake, ambient: phase),
                size: Size.infinite,
              ),
              // تصویرِ سه‌بعدیِ اصلیِ اسپلش (جزیره + آبشار + سنجابِ فندقی روی صخره)
              Transform.scale(
                scale: scale,
                child: Image.asset(
                  splashSceneAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                  excludeFromSemantics: true,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stack,
                  ) {
                    return const SizedBox.expand();
                  },
                ),
              ),
              // ذراتِ درخشانِ جادویی روی منظرهٔ جزیره
              CustomPaint(
                painter: SplashLeafPainter(reveal: wake, ambient: phase),
                size: Size.infinite,
              ),
              // سایه‌روشنِ نرمِ پایینِ صفحه برای خواناییِ کاملِ نوارِ پیشرفتِ سبز
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 190,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.transparent,
                        const Color(0xFF041A18).withOpacity(0.55),
                        const Color(0xFF031314).withOpacity(0.82),
                      ],
                      stops: const <double>[0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 🏝️ نقاشِ پشتیبانِ سپیده‌دمِ جزیره
class SplashIslandPainter extends CustomPainter {
  const SplashIslandPainter({required this.wake, required this.ambient});

  final double wake;
  final double ambient;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height;
    final horizon = h * 0.60;

    final skyRect = Rect.fromLTWH(0, 0, w, horizon + 1);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(
              const Color(0xFF0D47A1),
              IslandCinemaPalette.skyHigh,
              wake,
            )!,
            Color.lerp(
              const Color(0xFF1976D2),
              IslandCinemaPalette.skyMid,
              wake,
            )!,
            Color.lerp(
              const Color(0xFF4FC3F7),
              IslandCinemaPalette.skyLow,
              wake,
            )!,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ).createShader(skyRect),
    );

    final seaRect = Rect.fromLTWH(0, horizon, w, h - horizon);
    canvas.drawRect(
      seaRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            IslandCinemaPalette.seaMid,
            IslandCinemaPalette.seaDeep,
          ],
        ).createShader(seaRect),
    );
  }

  @override
  bool shouldRepaint(covariant SplashIslandPainter oldDelegate) {
    return oldDelegate.wake != wake || oldDelegate.ambient != ambient;
  }
}

/// ✨ ذراتِ طلاییِ نرم در فضایِ اسپلش
class SplashLeafPainter extends CustomPainter {
  const SplashLeafPainter({required this.reveal, required this.ambient});

  final double reveal;
  final double ambient;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 10; i++) {
      final seed = i * 1.37;
      final x = size.width * (0.12 + 0.76 * ((math.sin(seed * 2.1) + 1) * 0.5));
      final baseY =
          size.height * (0.18 + 0.52 * ((math.cos(seed * 1.7) + 1) * 0.5));
      final driftY = math.sin(ambient * 2 * math.pi + seed) * 8.0;
      final pulse =
          0.35 + 0.65 * (0.5 + 0.5 * math.sin(ambient * 2 * math.pi + i));
      final radius = (1.8 + (i % 3) * 1.1) * reveal;

      paint.color = const Color(0xFFFFF59D).withOpacity(0.22 * pulse * reveal);
      canvas.drawCircle(Offset(x, baseY + driftY), radius * 2.4, paint);
      paint.color = Colors.white.withOpacity(0.65 * pulse * reveal);
      canvas.drawCircle(Offset(x, baseY + driftY), radius * 0.9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SplashLeafPainter oldDelegate) {
    return oldDelegate.reveal != reveal || oldDelegate.ambient != ambient;
  }
}
