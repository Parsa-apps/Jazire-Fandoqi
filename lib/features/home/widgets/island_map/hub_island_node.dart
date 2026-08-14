import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_fonts.dart';
import '../../../../core/audio_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ سکوی عمومیِ داخلِ هاب‌ها
///
/// روی نقشهٔ اصلی هر بخش یک تصویر اختصاصی دارد، ولی داخلِ هاب‌ها
/// ده‌ها فعالیت داریم و ساختن تصویر جدا برای هرکدام نه شدنی است نه
/// لازم. پس یک «سکوی خالی» (`island_blank.png`) داریم و هر فعالیت
/// وسایل خودش را روی چمنِ آن می‌گذارد:
///
///   • تصویر یا ایموجیِ فعالیت روی چمن می‌ایستد (با سایهٔ بیضیِ نرم)
///   • پلاکِ کِرِمی با نام فعالیت، مثل سکوهای نقشهٔ اصلی
///   • همان انیمیشن‌ها: شناوری با فاز اختصاصی، تاب ملایم، فشردگی لمس
///
/// این‌طوری کل برنامه یک زبانِ تصویریِ واحد پیدا می‌کند.
/// ═══════════════════════════════════════════════════════════════
class HubIslandNode extends StatefulWidget {
  /// تصویر سکو — به‌صورت پیش‌فرض سکوی سبزِ خالی
  static const String blankAsset = 'assets/theme_map/island_blank.png';

  /// نسبت ارتفاع به عرضِ سکوی خالی
  static const double blankAspect = 374 / 440;

  /// جای ایستادنِ وسایل روی چمن (کسری از ارتفاع تصویر)
  static const double _propBaseline = 0.44;

  /// لنگر عمودیِ پلاکِ نام (کسری از ارتفاع تصویر)
  static const double _plateAnchor = 0.545;

  final String label;

  /// تصویر فعالیت؛ اگر نبود از ایموجی استفاده می‌شود
  final String? image;
  final String emoji;

  final double width;
  final double floatPhase;
  final Animation<double> floatAnimation;

  final VoidCallback onTap;

  /// رنگ حاشیهٔ پلاک — معمولاً رنگ اصلی همان هاب
  final Color accent;

  /// قفل بودن (محتوای نسخهٔ کامل)
  final bool locked;

  const HubIslandNode({
    super.key,
    required this.label,
    required this.emoji,
    required this.width,
    required this.floatPhase,
    required this.floatAnimation,
    required this.onTap,
    this.image,
    this.accent = const Color(0xFFFFB300),
    this.locked = false,
  });

  @override
  State<HubIslandNode> createState() => _HubIslandNodeState();
}

class _HubIslandNodeState extends State<HubIslandNode>
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
    HapticFeedback.mediumImpact();
    AudioService.select();
    widget.onTap();
  }

  double get _height => widget.width * HubIslandNode.blankAspect;

  double get _fontSize => (widget.width * 0.130).clamp(13.0, 24.0);

  double get _plateHeight => _fontSize * 1.5 + 5;

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
            offset: Offset(0, bob * 5),
            child: Transform.rotate(
              angle: bob * 0.010,
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
    final propSize = w * 0.42;

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
              child: Image.asset(
                HubIslandNode.blankAsset,
                width: w,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),

            // سایهٔ بیضیِ زیر وسایل تا روی چمن «ایستاده» به نظر بیایند
            Positioned(
              left: w / 2 - propSize * 0.36,
              top: h * HubIslandNode._propBaseline - propSize * 0.07,
              width: propSize * 0.72,
              height: propSize * 0.18,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x2A1B5E20),
                ),
              ),
            ),

            // وسایلِ خودِ فعالیت، ایستاده روی چمن
            Positioned(
              left: w / 2 - propSize / 2,
              top: h * HubIslandNode._propBaseline - propSize,
              width: propSize,
              height: propSize,
              child: _prop(propSize),
            ),

            if (widget.locked)
              Positioned(
                left: 0,
                right: 0,
                top: h * HubIslandNode._propBaseline - propSize * 1.16,
                child: Center(child: _lockBadge()),
              ),

            // پلاک نام، هم‌سبک با سکوهای نقشهٔ اصلی
            Positioned(
              left: 0,
              top: h * HubIslandNode._plateAnchor - _plateHeight / 2,
              width: w,
              height: _plateHeight,
              child: _plate(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prop(double size) {
    if (widget.image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          widget.image!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => _emojiProp(size),
        ),
      );
    }
    return _emojiProp(size);
  }

  Widget _emojiProp(double size) => Center(
        child: Text(
          widget.emoji,
          style: TextStyle(fontSize: size * 0.78),
        ),
      );

  /// پلاک با اندازهٔ طبیعیِ خودش وسطِ سکو می‌نشیند و اگر پهن‌تر از سکو
  /// شد، به‌جای فشرده‌شدنِ متن آزادانه بیرون می‌زند.
  Widget _plate() {
    final fs = _fontSize;
    return OverflowBox(
      alignment: Alignment.center,
      minWidth: 0,
      maxWidth: double.infinity,
      minHeight: 0,
      maxHeight: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(fs),
          border: Border.all(color: widget.accent, width: 2.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: fs * 0.52,
            vertical: fs * 0.17,
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: AppFonts.kids(
              fontSize: fs,
              color: const Color(0xFF2E4756),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lockBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, color: Colors.white, size: 12),
            const SizedBox(width: 3),
            Text(
              'ویژه',
              style: AppFonts.kids(fontSize: 11, color: Colors.white),
            ),
          ],
        ),
      );
}
