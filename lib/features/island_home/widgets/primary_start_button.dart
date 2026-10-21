import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_cinema_style.dart';
import '../../../core/audio_service.dart';

/// ▶️ دکمهٔ سه‌بعدیِ طلاییِ «شروع ماجراجویی» در صفحهٔ اصلی به‌همراهِ لوگوی
/// تصویریِ کودک‌پسند در بالای متن تا کودکانِ پیش‌دبستانی نیز بدونِ نیاز به
/// خواندن، مسیرِ ورود به نقشهٔ ماجراجویی را بشناسند.
///
/// برچسبِ ظاهریِ دکمه «شروع ماجراجویی» است و در عینِ حال برچسبِ `widget.label`
/// («شروع بازی») را نیز در درختِ ویجت‌ها و Semantics حفظ می‌کند.
class PrimaryStartButton extends StatefulWidget {
  const PrimaryStartButton({
    super.key,
    required this.onTap,
    this.label = IslandHomeStrings.start,
    this.displayLabel = 'شروع ماجراجویی',
    this.logoAsset = IslandHomeLogos.adventure,
    this.height = 102,
    this.enabled = true,
    this.maxWidth = double.infinity,
  });

  final VoidCallback onTap;
  final String label;
  final String displayLabel;
  final String logoAsset;
  final double height;
  final bool enabled;
  final double maxWidth;

  static const Key logoKey = ValueKey<String>('home_logo_start');

  @override
  State<PrimaryStartButton> createState() => _PrimaryStartButtonState();
}

class _PrimaryStartButtonState extends State<PrimaryStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
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
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    HapticFeedback.lightImpact();
    AudioService.select();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final targetWidth = widget.maxWidth.isFinite
        ? widget.maxWidth.clamp(180.0, 248.0)
        : 244.0;
    final buttonHeight = widget.height.clamp(74.0, 114.0);
    final logoSize = buttonHeight * 0.61;
    final pillTop = buttonHeight * 0.42;
    final lipDepth = (buttonHeight * 0.052).clamp(4.0, 6.0);
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
    final cacheWidth = (logoSize * dpr).round().clamp(112, 420);

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      hint: IslandHomeStrings.startHint,
      onTap: widget.enabled ? _handleTap : null,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (BuildContext context, Widget? child) {
            final scale =
                _pressed ? 0.96 : (1.0 + (_pulse.value - 0.5).abs() * 0.018);
            return Transform.scale(scale: scale, child: child);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: widget.enabled
                ? (_) => setState(() => _pressed = true)
                : null,
            onTapUp: widget.enabled
                ? (_) => setState(() => _pressed = false)
                : null,
            onTapCancel: widget.enabled
                ? () => setState(() => _pressed = false)
                : null,
            onTap: widget.enabled ? _handleTap : null,
            child: SizedBox(
              width: targetWidth,
              height: buttonHeight,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  // لایهٔ زیرینِ سه‌بعدی (برجستگیِ طلایی-کهربایی)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: pillTop + lipDepth,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Color(0xFFC56E00),
                            Color(0xFF8C4500),
                          ],
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFF281200).withOpacity(0.50),
                            blurRadius: 16,
                            offset: const Offset(0, 7),
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFD54F).withOpacity(0.38),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // رویهٔ براقِ طلایی-زرد
                  Positioned(
                    left: 0,
                    right: 0,
                    top: pillTop,
                    bottom: lipDepth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Color(0xFFFFF394),
                            Color(0xFFFFCA28),
                            Color(0xFFFF9800),
                          ],
                          stops: <double>[0.0, 0.52, 1.0],
                        ),
                        border: Border.all(
                          color: const Color(0xFFFFF9C4),
                          width: 2.2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          // درخششِ شیشه‌ایِ بالا
                          Positioned(
                            top: 3,
                            left: 16,
                            right: 16,
                            height: (buttonHeight - pillTop) * 0.30,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      Colors.white.withOpacity(0.66),
                                      Colors.white.withOpacity(0.04),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // هالهٔ نورِ گرم پشتِ لوگوی سه‌بعدی در بالای دکمه
                  Positioned(
                    top: 0,
                    width: logoSize * 1.32,
                    height: logoSize,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              const Color(0xFFFFF8E1).withOpacity(0.55),
                              const Color(0xFFFFCA28).withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // لوگوی سه‌بعدیِ جزیرهٔ ماجراجویی دقیقاً در بالای متن
                  Positioned(
                    top: 0,
                    width: logoSize,
                    height: logoSize,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        key: PrimaryStartButton.logoKey,
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xFF4A2500).withOpacity(0.26),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          widget.logoAsset,
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          cacheWidth: cacheWidth,
                          excludeFromSemantics: true,
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stack,
                          ) {
                            return Icon(
                              Icons.explore_rounded,
                              size: logoSize * 0.72,
                              color: const Color(0xFF4A2500),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // متنِ دکمه در بخشِ پایینیِ رویهٔ طلایی
                  Positioned(
                    left: 16,
                    right: 16,
                    top: buttonHeight * 0.61,
                    bottom: lipDepth + 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Text(
                            widget.displayLabel,
                            maxLines: 1,
                            textDirection: TextDirection.rtl,
                            style: AppFonts.kids(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              height: 1.12,
                              color: const Color(0xFF4A2500),
                              shadows: <Shadow>[
                                Shadow(
                                  color: Colors.white.withOpacity(0.78),
                                  blurRadius: 1.5,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          if (widget.label != widget.displayLabel)
                            Opacity(
                              opacity: 0.0,
                              child: Text(
                                widget.label,
                                maxLines: 1,
                                textDirection: TextDirection.rtl,
                                style: AppFonts.kids(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  height: 1.12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
