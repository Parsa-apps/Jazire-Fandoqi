import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/island_cinema_style.dart';
import '../../../core/audio_service.dart';

/// 🧱 رویهٔ سه‌بعدیِ فشردنی — پایهٔ دکمهٔ اصلی و کارت‌های مسیر.
///
/// عمق با سه لایه ساخته می‌شود (بدون هیچ وابستگیٔ جدید):
///   ۱. لایهٔ برجستگی: یک سایهٔ بی‌محو با آفستِ رو به پایین که دقیقاً
///      شکلِ رویه را با رنگِ تیره تکرار می‌کند (ضخامتِ دکمه)؛
///   ۲. سایهٔ نرمِ زیرِ آن برای بلندشدن از زمینه؛
///   ۳. رویهٔ شیب‌دار با خطِ براقِ بالا و کادرِ روشن.
///
/// هنگامِ فشرده‌شدن، لایهٔ برجستگی به صفر می‌رسد و رویه ۳٪ کوچک
/// می‌شود — همان بازخوردی که کودک از یک دکمهٔ واقعی انتظار دارد
/// (به‌همراه لرزشِ ملایم و صدایِ کوتاه).
///
/// نکتهٔ چیدمان: برخلافِ `Stack` + `Positioned`، اینجا همه‌چیز با
/// `AnimatedContainer` و سایه ساخته شده تا ویجت به اندازهٔ محتوایش
/// جمع شود (وگرنه دکمهٔ اصلی تمامِ عرضِ صفحه را می‌گرفت).
class Island3DSurface extends StatefulWidget {
  const Island3DSurface({
    super.key,
    required this.child,
    required this.baseColor,
    required this.deepColor,
    this.onTap,
    this.height,
    this.width,
    this.radius = IslandCinemaMetrics.radius,
    this.extrusion = IslandCinemaMetrics.extrusion,
    this.semanticLabel,
    this.semanticHint,
    this.enabled = true,
    this.margin,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
  });

  final Widget child;
  final Color baseColor;
  final Color deepColor;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final double radius;
  final double extrusion;
  final String? semanticLabel;
  final String? semanticHint;
  final bool enabled;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;

  @override
  State<Island3DSurface> createState() => _Island3DSurfaceState();
}

class _Island3DSurfaceState extends State<Island3DSurface> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  void _fire() {
    if (!widget.enabled) return;
    _setPressed(false);
    HapticFeedback.mediumImpact();
    AudioService.tap();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final faceHeight = widget.height ?? 60.0;

    final face = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            _lighten(widget.baseColor, 0.26),
            widget.baseColor,
            _darken(widget.baseColor, 0.10),
          ],
          stops: const <double>[0.0, 0.48, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.55),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // خطِ براقِ بالای رویه
          Positioned(
            top: 6,
            left: widget.radius * 0.7,
            right: widget.radius * 0.7,
            child: IgnorePointer(
              child: Container(
                height: faceHeight * 0.16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.white.withOpacity(0.55),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      onTap: widget.enabled ? _fire : null,
      child: ExcludeSemantics(
        child: Container(
          margin: widget.margin,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: widget.enabled ? _fire : null,
            child: AnimatedContainer(
              duration: _pressed
                  ? IslandCinemaMotion.pressIn
                  : IslandCinemaMotion.pressOut,
              curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                boxShadow: <BoxShadow>[
                  // ضخامتِ واقعیِ دکمه
                  BoxShadow(
                    color: widget.deepColor,
                    offset: Offset(0, _pressed ? 0 : widget.extrusion),
                    blurRadius: 0,
                  ),
                  // سایهٔ نرم برای جدا شدن از زمینه
                  BoxShadow(
                    color: widget.deepColor.withOpacity(0.42),
                    blurRadius: 18,
                    offset: Offset(0, _pressed ? 2 : 8),
                  ),
                  BoxShadow(
                    color: IslandCinemaPalette.shade.withOpacity(0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: IslandCinemaMetrics.minTouch,
                  minWidth: IslandCinemaMetrics.minTouch,
                ),
                child: AnimatedScale(
                  scale: _pressed ? 0.97 : 1.0,
                  duration: _pressed
                      ? IslandCinemaMotion.pressIn
                      : IslandCinemaMotion.pressOut,
                  curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
                  child: Opacity(
                    opacity: widget.enabled ? 1.0 : 0.6,
                    child: face,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _lighten(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      (color.red + (255 - color.red) * amount).round().clamp(0, 255),
      (color.green + (255 - color.green) * amount).round().clamp(0, 255),
      (color.blue + (255 - color.blue) * amount).round().clamp(0, 255),
    );
  }

  Color _darken(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - amount)).round().clamp(0, 255),
      (color.green * (1 - amount)).round().clamp(0, 255),
      (color.blue * (1 - amount)).round().clamp(0, 255),
    );
  }
}
