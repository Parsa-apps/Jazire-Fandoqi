import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import 'parsa_apps_logo.dart';

/// ═══════════════════════════════════════════════════════════
/// 👑 PARSA GOLD AURA CARD — کارت اختصاصی پارسا اپس و فرشاد پارسا
/// هاله‌ی طلایی متحرک، پالسی و با شیمر نرم طبق MasterPrompt بند ۱۵
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
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
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
      builder: (context, _) {
        final glowOpacity = _pulseAnimation.value;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              // هاله‌ی طلایی پالسی محو و پررنگ‌شونده
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.35 * glowOpacity),
                blurRadius: 24 * glowOpacity + 8,
                spreadRadius: 4 * glowOpacity,
              ),
              BoxShadow(
                color: const Color(0xFFFF8C00).withOpacity(0.2 * glowOpacity),
                blurRadius: 36 * glowOpacity + 12,
                spreadRadius: 8 * glowOpacity,
              ),
            ],
          ),
          child: CustomPaint(
            foregroundPainter: _GoldenBorderPainter(
              progress: _controller.value,
              glowOpacity: glowOpacity,
            ),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E173E),
                    Color(0xFF3023AE),
                    Color(0xFF130F26),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.4 + 0.5 * glowOpacity),
                  width: 2,
                ),
              ),
              child: widget.child ??
                  Row(
                    children: [
                      const ParsaAppsLogo(
                        size: 68,
                        borderRadius: 18,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Color(0xFFFFE57F),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // نام فرشاد پارسا با هاله‌ی طلایی
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    const Color(0xFFFFFFFF),
                                    const Color(0xFFFFD700),
                                    const Color(0xFFFF8C00),
                                    const Color(0xFFFFFFFF),
                                  ],
                                  stops: [
                                    0.0,
                                    0.3 + 0.4 * glowOpacity,
                                    0.7 + 0.2 * glowOpacity,
                                    1.0,
                                  ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                widget.developerName,
                                style: AppFonts.vazirmatn(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        );
      },
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
        colors: [
          Colors.transparent,
          const Color(0xFFFFD700).withOpacity(0.8 * glowOpacity),
          const Color(0xFFFF8C00),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 1.0],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldenBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.glowOpacity != glowOpacity;
  }
}
