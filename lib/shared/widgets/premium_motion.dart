import 'package:flutter/material.dart';

/// ────────────────────────────────────────────────────────────
/// ✨ فاز ۱۵: Premium Motion — انیمیشن‌های اسپرینگ استاندارد
///
/// همه ورود/خروج‌ها باید از این ویجت‌ها استفاده کنند تا حرکت در
/// کل اپ یکدست و بدون jank باشد. هر انیمیشن داخل RepaintBoundary
/// قرار می‌گیرد تا ناحیه بازکشی حداقل باشد (گوشی ضعیف).
/// ────────────────────────────────────────────────────────────
class SpringEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double beginOffsetY;
  final double beginScale;

  const SpringEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.beginOffsetY = 0.2,
    this.beginScale = 0.92,
  });

  @override
  State<SpringEntrance> createState() => _SpringEntranceState();
}

class _SpringEntranceState extends State<SpringEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay > Duration.zero) {
      _controller.stop();
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) {
          final t = _curve.value;
          return Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, widget.beginOffsetY * 40 * (1 - t)),
              child: Transform.scale(
                scale: widget.beginScale + (1 - widget.beginScale) * t,
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// ورود پلکانی لیست (staggered) با فاصله ثابت بین آیتم‌ها.
class StaggeredEntrance extends StatelessWidget {
  final List<Widget> children;
  final Duration baseDelay;
  final Duration step;

  const StaggeredEntrance({
    super.key,
    required this.children,
    this.baseDelay = const Duration(milliseconds: 120),
    this.step = const Duration(milliseconds: 90),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++)
          SpringEntrance(
            delay: baseDelay + step * i,
            child: children[i],
          ),
      ],
    );
  }
}

/// محافظ jank: هر ویجت سنگین (نقشه، جزیره، لیست تصاویر) را در این
/// می‌پیچیم تا فقط همان ناحیه هنگام انیمیشن بازکشی شود.
class JankGuard extends StatelessWidget {
  final Widget child;

  const JankGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => RepaintBoundary(child: child);
}
