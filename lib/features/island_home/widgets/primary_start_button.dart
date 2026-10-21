import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_cinema_style.dart';
import 'island_3d_surface.dart';

/// ▶️ بزرگ‌ترین و واضح‌ترین کنترلِ صفحهٔ اصلی.
///
/// الزام‌هایی که این دکمه برآورده می‌کند:
///   * بزرگ‌ترین هدفِ لمسیِ صفحه (بلندای ۷۸، بزرگ‌تر از استاندارد)؛
///   * زرد/طلایی با متنِ قهوه‌ایِ تیره → نسبتِ کنتراست ≈ ۷:۱؛
///   * آیکونِ پخشِ کاملاً واضح در یک نشانِ سفیدِ مدور؛
///   * بازخوردِ لمسی (لرزش + صدا) و انیمیشنِ فشردن واقعی؛
///   * یک نفس‌کشیدنِ بسیار ملایم (۲٫۵٪) برای هدایتِ نگاهِ کودک —
///     نه پرش، نه چشمک، نه تکرارِ آزاردهنده.
class PrimaryStartButton extends StatefulWidget {
  const PrimaryStartButton({
    super.key,
    required this.onTap,
    this.label = IslandHomeStrings.start,
    this.height = IslandCinemaMetrics.startButtonHeight,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final String label;
  final double height;
  final bool enabled;

  @override
  State<PrimaryStartButton> createState() => _PrimaryStartButtonState();
}

class _PrimaryStartButtonState extends State<PrimaryStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      _pulse.stop();
      _pulse.value = 0.25;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = IslandCinemaPalette.woodDeep;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (BuildContext context, Widget? child) {
        final wave = 0.5 - 0.5 * _pulse.value.abs() * 2;
        final scale = 1.0 + (1 - wave) * 0.012;
        return Transform.scale(scale: scale, child: child);
      },
      child: Island3DSurface(
        height: widget.height,
        radius: 30,
        extrusion: 9,
        baseColor: IslandCinemaPalette.gold,
        deepColor: IslandCinemaPalette.bronze,
        enabled: widget.enabled,
        semanticLabel: widget.label,
        semanticHint: IslandHomeStrings.startHint,
        onTap: widget.onTap,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: IslandCinemaGradients.goldFace,
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: IslandCinemaPalette.bronze.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 34,
                color: textColor,
              ),
            ),
            const SizedBox(width: 12),
            // بدون Flexible: در یک Row با mainAxisSize.min، Flexible تمامِ
            // فضایِ باقی‌مانده را می‌خورد و دکمه عرضِ کلِ صفحه می‌شد.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.label,
                maxLines: 1,
                textDirection: TextDirection.rtl,
                style: AppFonts.kids(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.white.withOpacity(0.55),
                      blurRadius: 1.5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
