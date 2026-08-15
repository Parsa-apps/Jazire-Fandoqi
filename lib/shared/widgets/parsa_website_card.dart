import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';
import 'parsa_apps_logo.dart';

/// قاب معرفی وب‌سایت پارسا اپس در صفحهٔ درباره و پشتیبانی.
///
/// انیمیشن‌ها فقط تزئینی‌اند و در صورت فعال‌بودن تنظیم «کاهش حرکت» سیستم،
/// متوقف می‌شوند. تمام کارت یک لینک قابل‌دسترسی است و دکمهٔ واضح نیز دارد.
class ParsaWebsiteCard extends StatefulWidget {
  const ParsaWebsiteCard({
    super.key,
    required this.onTap,
    this.title = 'سایت پارسا اپس',
  });

  final VoidCallback onTap;
  final String title;

  @override
  State<ParsaWebsiteCard> createState() => _ParsaWebsiteCardState();
}

class _ParsaWebsiteCardState extends State<ParsaWebsiteCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );

  bool _hovered = false;
  bool _animationsDisabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_animationsDisabled == disabled &&
        (_controller.isAnimating || disabled)) {
      return;
    }
    _animationsDisabled = disabled;
    if (disabled) {
      _controller.stop();
      _controller.value = 0.16;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      button: true,
      label: '${widget.title}، ورود مستقیم به وب‌سایت',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;
            final wave = math.sin(progress * math.pi * 2);
            return AnimatedScale(
              scale: _hovered ? 1.018 : 1 + wave * 0.003,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF48CAE4)
                          .withOpacity(0.18 + (wave + 1) * 0.05),
                      blurRadius: _hovered ? 34 : 24,
                      spreadRadius: _hovered ? 3 : 1,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFF9B5DE5).withOpacity(0.16),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _WebsiteBorderPainter(progress: progress),
                  child: child,
                ),
              ),
            );
          },
          child: _CardBody(
            title: widget.title,
            onTap: widget.onTap,
            hovered: _hovered,
            animation: _controller,
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.title,
    required this.onTap,
    required this.hovered,
    required this.animation,
  });

  final String title;
  final VoidCallback onTap;
  final bool hovered;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF211552),
              Color(0xFF182A67),
              Color(0xFF073B5C),
            ],
          ),
        ),
        child: InkWell(
          key: const ValueKey('parsa_website_link'),
          onTap: onTap,
          splashColor: const Color(0xFF64DFDF).withOpacity(0.22),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) => CustomPaint(
                      painter: _WebsiteSparklesPainter(
                        progress: animation.value,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -54,
                left: -38,
                child: _GlowOrb(
                  color: const Color(0xFF00F5D4).withOpacity(0.13),
                  size: 142,
                ),
              ),
              Positioned(
                bottom: -60,
                right: -30,
                child: _GlowOrb(
                  color: const Color(0xFFF15BB5).withOpacity(0.12),
                  size: 150,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) => Transform.rotate(
                            angle: math.sin(animation.value * math.pi * 2) *
                                0.045,
                            child: child,
                          ),
                          child: const ParsaAppsLogo(
                            size: 62,
                            borderRadius: 16,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'دنیای محصولات و تازه‌های ما',
                                style: TextStyle(
                                  color: Color(0xFFB8F8F2),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) => ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) => LinearGradient(
                                    begin: Alignment(
                                      -2.5 + animation.value * 5,
                                      0,
                                    ),
                                    end: Alignment(
                                      -1.1 + animation.value * 5,
                                      0,
                                    ),
                                    colors: const [
                                      Color(0xFFFFFFFF),
                                      Color(0xFFFFE66D),
                                      Color(0xFFFFFFFF),
                                    ],
                                  ).createShader(bounds),
                                  child: child,
                                ),
                                child: Text(
                                  title,
                                  style: AppFonts.vazirmatn(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00F5D4), Color(0xFF48CAE4)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: hovered
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00F5D4)
                                      .withOpacity(0.38),
                                  blurRadius: 18,
                                ),
                              ]
                            : const [],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ورود مستقیم به سایت',
                            style: TextStyle(
                              color: Color(0xFF102A56),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_outward_rounded,
                            color: Color(0xFF102A56),
                            size: 20,
                          ),
                        ],
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
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 44, spreadRadius: 8)],
      ),
    );
  }
}

class _WebsiteBorderPainter extends CustomPainter {
  const _WebsiteBorderPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final border = RRect.fromRectAndRadius(
      rect.deflate(1.2),
      const Radius.circular(29),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..shader = SweepGradient(
        transform: GradientRotation(progress * math.pi * 2),
        colors: const [
          Color(0xFF00F5D4),
          Color(0xFF48CAE4),
          Color(0xFFFEE440),
          Color(0xFFF15BB5),
          Color(0xFF00F5D4),
        ],
      ).createShader(rect);
    canvas.drawRRect(border, paint);
  }

  @override
  bool shouldRepaint(covariant _WebsiteBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _WebsiteSparklesPainter extends CustomPainter {
  const _WebsiteSparklesPainter({required this.progress});

  final double progress;

  static const _points = <Offset>[
    Offset(0.08, 0.22),
    Offset(0.22, 0.78),
    Offset(0.72, 0.16),
    Offset(0.88, 0.42),
    Offset(0.63, 0.82),
    Offset(0.39, 0.12),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _points.length; i++) {
      final phase = (progress + i / _points.length) % 1.0;
      final opacity = (0.16 + math.sin(phase * math.pi) * 0.5).clamp(0, 1);
      final center = Offset(
        _points[i].dx * size.width,
        _points[i].dy * size.height,
      );
      canvas.drawCircle(
        center,
        1.2 + math.sin(phase * math.pi) * 1.2,
        Paint()..color = Colors.white.withOpacity(opacity.toDouble()),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WebsiteSparklesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
