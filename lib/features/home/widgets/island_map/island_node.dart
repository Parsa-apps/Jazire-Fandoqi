import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_fonts.dart';
import '../../../../core/audio_service.dart';

/// موقعیت دکمهٔ شیشه‌ایِ خالی که داخل خودِ تصویر هر سکو کشیده شده است.
/// چون مولد تصویر نمی‌تواند فارسی بنویسد، تابلوها عمداً خالی تولید شدند.
///
/// این دکمه‌ها در خودِ تصویر بسیار کم‌ارتفاع‌اند (حدود ۱۴ پیکسل روی گوشی)،
/// پس متنِ محبوس در آن‌ها هیچ‌وقت به‌اندازهٔ کافی بزرگ نمی‌شود. به همین
/// دلیل `cx`/`cy` را فقط به‌عنوان **نقطهٔ لنگر** به کار می‌بریم و یک پلاکِ
/// اندازه‌شده با خودِ متن دقیقاً روی همان نقطه می‌نشیند و دکمهٔ زیرین را
/// می‌پوشاند. مقادیر کسری از عرض/ارتفاع تصویرند.
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
    // جزیرهٔ قصه‌ها دکمهٔ توکار ندارد؛ لنگر روی چمنِ جلوی فندقی است
    'assets/theme_map/island_tales.png': PillRect(0.497, 0.735, 0.360, 0.075),
    'assets/theme_map/island_game.png': PillRect(0.355, 0.558, 0.335, 0.075),
    'assets/theme_map/island_lullaby.png': PillRect(0.560, 0.520, 0.460, 0.075),
    'assets/theme_map/island_profile.png': PillRect(0.685, 0.630, 0.320, 0.075),
    'assets/theme_map/island_about.png': PillRect(0.455, 0.612, 0.380, 0.085),
  };

  /// نسبت ارتفاع به عرضِ هر تصویر، برای محاسبهٔ ارتفاع بدون خواندن فایل
  static const Map<String, double> aspectByAsset = {
    'assets/theme_map/island_cartoon.png': 511 / 440,
    'assets/theme_map/island_story.png': 509 / 440,
    'assets/theme_map/island_tales.png': 585 / 440,
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

            // ── پلاک برچسب، لنگرانداخته روی دکمهٔ داخل تصویر ──
            // پلاک از کادر سکو بیرون می‌زند (clipBehavior: none) تا متن
            // بتواند بزرگ باشد بدون اینکه تصویر را بپوشاند.
            if (pill != null)
              Positioned(
                left: 0,
                top: pill.cy * h - _plateHeight / 2,
                width: w,
                height: _plateHeight,
                child: _anchoredPlate(pill.cx),
              )
            else
              Positioned(
                left: 0,
                width: w,
                height: _plateHeight,
                bottom: h * 0.05,
                child: _anchoredPlate(0.5),
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

  /// اندازهٔ متن برچسب — نسبت به عرض سکو بزرگ می‌شود تا روی هر صفحه‌ای
  /// درشت و خوانا بماند. حد پایین برای گوشی‌های کوچک، حد بالا برای تبلت.
  double get _fontSize => (widget.width * 0.150).clamp(17.0, 34.0);

  /// ارتفاع تقریبی پلاک (متن + پدینگ + حاشیه)
  double get _plateHeight => _fontSize * 1.5 + 6;

  /// پلاک با اندازهٔ طبیعیِ خودش روی لنگرِ افقی می‌نشیند. اگر از عرضِ سکو
  /// پهن‌تر شد، به‌جای فشرده‌شدنِ متن آزادانه بیرون می‌زند و
  /// `Alignment` خودش آن را نرم داخل کادر نگه می‌دارد.
  Widget _anchoredPlate(double cx) {
    return OverflowBox(
      minWidth: 0,
      maxWidth: double.infinity,
      minHeight: 0,
      maxHeight: double.infinity,
      alignment: Alignment((cx * 2 - 1).clamp(-1.0, 1.0), 0),
      child: _labelPlate(),
    );
  }

  /// پلاک برچسب: کپسول روشن با حاشیهٔ عسلی، دقیقاً به اندازهٔ خودِ متن.
  Widget _labelPlate() {
    final fs = _fontSize;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fs * 0.52, vertical: fs * 0.17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(fs),
        border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        widget.label,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: AppFonts.kids(
          fontSize: fs,
          fontWeight: FontWeight.w800,
          color: widget.labelColor,
          height: 1.15,
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

/// 🫧 حباب یادگیری زیرِ آب — برادر کوچک‌ترِ [IslandNode].
///
/// همان زبان تصویری را دارد: تصویر سه‌بعدیِ شناور + پلاک کپسولیِ کرم با
/// حاشیهٔ عسلی. فرقش این است که تصویر گرد است و پلاک همیشه زیرِ حباب
/// می‌نشیند، نه رویش، تا داخل حباب دیده شود.
class BubbleNode extends StatefulWidget {
  const BubbleNode({
    super.key,
    required this.asset,
    required this.label,
    required this.width,
    required this.floatAnimation,
    required this.onTap,
    this.floatPhase = 0,
  });

  final String asset;
  final String label;
  final double width;
  final Animation<double> floatAnimation;
  final VoidCallback onTap;
  final double floatPhase;

  @override
  State<BubbleNode> createState() => _BubbleNodeState();
}

class _BubbleNodeState extends State<BubbleNode>
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
    HapticFeedback.lightImpact();
    AudioService.tap();
    widget.onTap();
  }

  /// متن کمی ریزتر از سکوهاست چون حباب‌ها چهارتایی کنار هم می‌نشینند
  double get _fontSize => (widget.width * 0.215).clamp(12.0, 21.0);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        onTap: _handleTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([widget.floatAnimation, _press]),
              builder: (context, child) {
                final phase =
                    (widget.floatAnimation.value + widget.floatPhase) % 1.0;
                final bob = sin(phase * 2 * pi);
                return Transform.translate(
                  // حباب‌ها بالا و پایین می‌روند، انگار توی آب معلق‌اند
                  offset: Offset(bob * 2, bob * 5),
                  child: Transform.scale(
                    scale: 1.0 - _press.value * 0.08,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                widget.asset,
                width: widget.width,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),
            SizedBox(height: widget.width * 0.05),
            _labelPlate(),
          ],
        ),
      ),
    );
  }

  /// دقیقاً همان پلاکِ سکوها، فقط کوچک‌تر — تا کل نقشه یک‌دست بماند.
  Widget _labelPlate() {
    final fs = _fontSize;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fs * 0.52, vertical: fs * 0.17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(fs),
        border: Border.all(color: const Color(0xFFFFB300), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        widget.label,
        maxLines: 1,
        style: AppFonts.kids(
          fontSize: fs,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2E4756),
          height: 1.15,
        ),
      ),
    );
  }
}
