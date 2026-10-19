import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';

import '../../app/parsa_brand.dart';
import 'parsa_apps_logo.dart';

/// ═══════════════════════════════════════════════════════════
/// 👑 PARSA GOLD AURA CARD — کارت اختصاصی پارسا اپس و فرشاد پارسا
///
/// هالهٔ طلایی متحرک، قاب فلزی و لوگوی رسمی برند. رنگ‌ها از خود لوگو
/// گرفته شده‌اند: مشکی عمیق، آبی نئونی و طلایی. کارت در بخش «درباره و
/// پشتیبانی» به والد نشان می‌دهد سازندهٔ برنامه چه کسی است.
/// ═══════════════════════════════════════════════════════════
class ParsaGoldAuraCard extends StatefulWidget {
  final Widget? child;
  final String title;
  final String developerName;
  final String subtitle;

  const ParsaGoldAuraCard({
    super.key,
    this.child,
    this.title = 'PARSA APPS • سازنده و توسعه‌دهنده',
    this.developerName = 'فرشاد پارسا',
    this.subtitle = 'گروه برنامه‌نویسی پارسا اپس',
  });

  @override
  State<ParsaGoldAuraCard> createState() => _ParsaGoldAuraCardState();
}

class _ParsaGoldAuraCardState extends State<ParsaGoldAuraCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disabled == _reduceMotion &&
        (_controller.isAnimating || disabled)) {
      return;
    }
    _reduceMotion = disabled;
    if (disabled) {
      _controller.stop();
      _controller.value = 0.55;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        final glowOpacity = _pulseAnimation.value;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: <BoxShadow>[
              // هالهٔ طلایی پالسی محو و پررنگ‌شونده.
              BoxShadow(
                color: ParsaBrand.gold.withOpacity(0.26 * glowOpacity),
                blurRadius: 24 * glowOpacity + 8,
                spreadRadius: 3 * glowOpacity,
              ),
              BoxShadow(
                color: ParsaBrand.neonBlue.withOpacity(0.14 * glowOpacity),
                blurRadius: 30 * glowOpacity + 10,
                spreadRadius: 4 * glowOpacity,
              ),
            ],
          ),
          child: CustomPaint(
            foregroundPainter: _GoldenBorderPainter(
              progress: _controller.value,
              glowOpacity: glowOpacity,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: ParsaBrand.cardGradient,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: ParsaBrand.gold.withOpacity(0.34 + 0.42 * glowOpacity),
                  width: 1.6,
                ),
              ),
              child: widget.child ?? _buildBrandRow(glowOpacity),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandRow(double glowOpacity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // لوگوی رسمی با هالهٔ طلایی/آبی، بدون قاب اضافه.
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: ParsaBrand.gold.withOpacity(0.22 * glowOpacity + 0.10),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const ParsaAppsLogo(
            size: 74,
            borderRadius: 18,
            showShadow: false,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 16,
                    height: 1.2,
                    color: ParsaBrand.gold.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: ParsaBrand.brightGold.withOpacity(0.92),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // نام فرشاد پارسا با درخشش فلزی طلایی.
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: <Color>[
                      Colors.white,
                      ParsaBrand.brightGold,
                      ParsaBrand.gold,
                      ParsaBrand.deepGold,
                      Colors.white,
                    ],
                    stops: <double>[
                      0.0,
                      0.28 + 0.10 * glowOpacity,
                      0.5,
                      0.72,
                      1.0,
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  widget.developerName,
                  textDirection: TextDirection.rtl,
                  style: AppFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.subtitle,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.66),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoldenBorderPainter extends CustomPainter {
  final double progress;
  final double glowOpacity;

  _GoldenBorderPainter({required this.progress, required this.glowOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(28));

    final paint = Paint()
      ..shader = SweepGradient(
        colors: <Color>[
          Colors.transparent,
          ParsaBrand.gold.withOpacity(0.85 * glowOpacity),
          ParsaBrand.brightGold,
          ParsaBrand.deepGold.withOpacity(0.9),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.26, 0.46, 0.62, 1.0],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldenBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowOpacity != glowOpacity;
  }
}
