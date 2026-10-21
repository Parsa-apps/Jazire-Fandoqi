import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_cinema_style.dart';
import 'island_3d_surface.dart';

/// فاصله‌ها و اندازهٔ نشانِ پخش. ویجت و State هر دو از آن‌ها استفاده
/// می‌کنند (برای چیدمان و برای محاسبهٔ عرضِ در-دسترسِ برچسب)، پس در سطحِ
/// کتابخانه تعریف شده‌اند تا هرگز از هم جدا نیفتند.
const double _hPad = 22;
const double _iconBox = 46;
const double _iconGap = 12;

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
    this.maxWidth = double.infinity,
  });

  final VoidCallback onTap;
  final String label;
  final double height;
  final bool enabled;

  /// بیشینهٔ عرضی که دکمه می‌تواند بگیرد. روی گوشیِ ۳۲۰dp اگر برچسب از
  /// فضایِ باقی‌مانده بزرگ‌تر بود کوچک می‌شود — نه خودِ دکمه، چون پیچیدنِ
  /// یک هدفِ لمسی در FittedBox لمس را از کار می‌اندازد.
  final double maxWidth;

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

  /// عرضِ در-دسترس برای برچسب پس از کسرِ فاصله‌ها و نشانِ پخش.
  double get _labelMaxWidth {
    if (!widget.maxWidth.isFinite) return double.infinity;
    final available = widget.maxWidth - (_hPad * 2) - _iconBox - _iconGap;
    return available < 48 ? 48 : available;
  }

  @override
  Widget build(BuildContext context) {
    const textColor = IslandCinemaPalette.woodDeep;

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
        padding: const EdgeInsets.symmetric(horizontal: _hPad),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: _iconBox,
              height: _iconBox,
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
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 34,
                color: textColor,
              ),
            ),
            const SizedBox(width: _iconGap),
            // بدون Flexible: در یک Row با mainAxisSize.min، Flexible تمامِ
            // فضایِ باقی‌مانده را می‌خورد و دکمه عرضِ کلِ صفحه می‌شد.
            // به‌جای آن فقط برچسب محدود و مقیاس می‌شود.
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _labelMaxWidth),
              child: FittedBox(
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
            ),
          ],
        ),
      ),
    );
  }
}
