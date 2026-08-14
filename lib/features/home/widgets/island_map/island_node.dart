import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_fonts.dart';
import '../../../../core/audio_service.dart';

/// موقعیت دکمهٔ شیشه‌ایِ خالی که داخل خودِ تصویر هر سکو کشیده شده است.
/// چون مولد تصویر نمی‌تواند فارسی بنویسد، تابلوها عمداً خالی تولید شدند و
/// متن با ویجت دقیقاً روی همان دکمه می‌نشیند. مقادیر کسری از عرض/ارتفاع
/// تصویرند تا در هر اندازهٔ صفحه درست بمانند.
class PillRect {
  final double cx;
  final double cy;
  final double w;
  final double h;

  const PillRect(this.cx, this.cy, this.w, this.h);

  /// جای دکمهٔ هر دارایی — با اندازه‌گیری روی خودِ PNG به دست آمده
  static const Map<String, PillRect> byAsset = {
    'assets/theme_map/island_cartoon.png': PillRect(0.395, 0.622, 0.345, 0.070),
    'assets/theme_map/island_story.png': PillRect(0.512, 0.660, 0.360, 0.075),
    'assets/theme_map/island_game.png': PillRect(0.355, 0.558, 0.335, 0.075),
    'assets/theme_map/island_lullaby.png': PillRect(0.560, 0.520, 0.460, 0.075),
    'assets/theme_map/island_profile.png': PillRect(0.685, 0.630, 0.320, 0.075),
    'assets/theme_map/island_about.png': PillRect(0.455, 0.612, 0.380, 0.085),
  };

  /// نسبت ارتفاع به عرضِ هر تصویر، برای محاسبهٔ ارتفاع بدون خواندن فایل
  static const Map<String, double> aspectByAsset = {
    'assets/theme_map/island_cartoon.png': 511 / 440,
    'assets/theme_map/island_story.png': 509 / 440,
    'assets/theme_map/island_game.png': 432 / 440,
    'assets/theme_map/island_lullaby.png': 466 / 440,
    'assets/theme_map/island_profile.png': 547 / 440,
    'assets/theme_map/island_about.png': 577 / 440,
    'assets/theme_map/hero_fandoq.png': 456 / 420,
    'assets/theme_map/sign_board.png': 376 / 560,
    'assets/theme_map/bridge.png': 281 / 720,
  };
}

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ یک سکوی شناور روی نقشه
///
/// هر سکو یک PNG جداگانه با پس‌زمینهٔ شفاف است، پس می‌تواند مستقل
/// انیمیت شود:
///   • شناور بودن دائمی با فاز اختصاصی (همه با هم بالا و پایین نمی‌روند)
///   • تاب خوردن بسیار ملایم
///   • فشرده شدن هنگام لمس و برگشت فنری
/// ═══════════════════════════════════════════════════════════════
class IslandNode extends StatefulWidget {
  final String asset;
  final String label;

  /// عرض سکو بر حسب پیکسل منطقی
  final double width;

  /// فاز شناوری (۰ تا ۱)
  final double floatPhase;

  /// کنترلر مشترک شناوری برای کل صفحه
  final Animation<double> floatAnimation;

  final Color labelColor;
  final VoidCallback onTap;

  /// نشان کوچک گوشهٔ سکو (مثلاً «جدید»)
  final String? badge;

  final bool locked;

  const IslandNode({
    super.key,
    required this.asset,
    required this.label,
    required this.width,
    required this.floatPhase,
    required this.floatAnimation,
    required this.onTap,
    this.labelColor = const Color(0xFF2E4756),
    this.badge,
    this.locked = false,
  });

  @override
  State<IslandNode> createState() => _IslandNodeState();
}

class _IslandNodeState extends State<IslandNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _press;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _press = CurvedAnimation(
      parent: _pressCtrl,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.locked) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    AudioService.select();
    widget.onTap();
  }

  double get _height =>
      widget.width * (PillRect.aspectByAsset[widget.asset] ?? 1.15);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.floatAnimation, _press]),
        builder: (context, child) {
          final phase = (widget.floatAnimation.value + widget.floatPhase) % 1.0;
          final bob = sin(phase * 2 * pi);
          return Transform.translate(
            offset: Offset(0, bob * 6),
            child: Transform.rotate(
              angle: bob * 0.012,
              child: Transform.scale(
                scale: 1.0 - _press.value * 0.07,
                child: child,
              ),
            ),
          );
        },
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final w = widget.width;
    final h = _height;
    final pill = PillRect.byAsset[widget.asset];

    return Semantics(
      button: true,
      label: widget.label,
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: widget.locked
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0, 0, 0, 1, 0, //
                      ]),
                      child: _image(w),
                    )
                  : _image(w),
            ),

            // ── برچسب فارسی، دقیقاً روی دکمهٔ شیشه‌ایِ داخل تصویر ──
            if (pill != null)
              Positioned(
                left: (pill.cx - pill.w / 2) * w,
                top: (pill.cy - pill.h / 2) * h,
                width: pill.w * w,
                height: pill.h * h,
                child: _pillLabel(pill.h * h),
              )
            else
              Positioned(
                left: 0,
                right: 0,
                bottom: h * 0.06,
                child: Center(child: _fallbackLabel()),
              ),

            if (widget.locked)
              Positioned(
                left: 0,
                right: 0,
                top: h * 0.16,
                child: Center(child: _lockBadge()),
              ),

            if (widget.badge != null && !widget.locked)
              Positioned(
                top: h * 0.02,
                right: w * 0.04,
                child: _countBadge(widget.badge!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _image(double w) => Image.asset(
        widget.asset,
        width: w,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );

  /// متن داخل دکمهٔ شیشه‌ای — اندازهٔ فونت با ارتفاع دکمه بالا و پایین می‌رود
  Widget _pillLabel(double pillH) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          widget.label,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: AppFonts.vazirmatn(
            fontSize: (pillH * 0.62).clamp(9.0, 16.0),
            fontWeight: FontWeight.w900,
            color: widget.labelColor,
            shadows: const [
              Shadow(
                color: Color(0x66FFFFFF),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD180), width: 2),
      ),
      child: Text(
        widget.label,
        style: AppFonts.vazirmatn(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: widget.labelColor,
        ),
      ),
    );
  }

  Widget _lockBadge() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lock_rounded, color: Colors.white, size: 22),
    );
  }

  Widget _countBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppFonts.vazirmatn(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 🌰 قهرمان نقشه — شخصیت فندقی اصلی، بالای صفحه و بزرگ‌تر از همه،
/// با هالهٔ طلایی و تکان دائمی تا فوراً به چشم بیاید.
class HeroFandoq extends StatelessWidget {
  /// هالهٔ طلایی چند برابرِ خودِ فندقی است؛ ویجت به همین اندازه جا می‌گیرد
  static const double haloFactor = 1.4;

  final double width;
  final Animation<double> floatAnimation;
  final VoidCallback onTap;

  const HeroFandoq({
    super.key,
    required this.width,
    required this.floatAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'فندقی',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          AudioService.select();
          onTap();
        },
        child: AnimatedBuilder(
          animation: floatAnimation,
          builder: (context, child) {
            final bob = sin(floatAnimation.value * 2 * pi);
            return Transform.translate(
              offset: Offset(0, bob * 9),
              child: Transform.rotate(angle: bob * 0.03, child: child),
            );
          },
          child: SizedBox(
            width: width * haloFactor,
            height: width * haloFactor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: width * haloFactor,
                  height: width * haloFactor,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFE082).withOpacity(0.7),
                        const Color(0xFFFFE082).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/theme_map/hero_fandoq.png',
                  width: width,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
