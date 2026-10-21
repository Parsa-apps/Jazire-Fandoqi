import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_cinema_style.dart';
import '../../../core/audio_service.dart';

/// ▶️ دکمهٔ سه‌بعدیِ طلاییِ «شروع ماجراجویی» در صفحهٔ اصلی (مطابقِ طرحِ مرجع).
///
/// برچسبِ ظاهریِ دکمه «شروع ماجراجویی» است و در عینِ حال برچسبِ `widget.label`
/// («شروع بازی») را نیز در درختِ ویجت‌ها و Semantics حفظ می‌کند.
class PrimaryStartButton extends StatefulWidget {
  const PrimaryStartButton({
    super.key,
    required this.onTap,
    this.label = IslandHomeStrings.start,
    this.displayLabel = 'شروع ماجراجویی',
    this.height = 60,
    this.enabled = true,
    this.maxWidth = double.infinity,
  });

  final VoidCallback onTap;
  final String label;
  final String displayLabel;
  final double height;
  final bool enabled;
  final double maxWidth;

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
        ? widget.maxWidth.clamp(180.0, 290.0)
        : 270.0;
    final buttonHeight = widget.height.clamp(50.0, 68.0);

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
                children: <Widget>[
                  // لایهٔ زیرینِ سه‌بعدی (برجستگیِ طلایی-کهربایی)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 5,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
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
                    top: 0,
                    bottom: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
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
                            left: 18,
                            right: 18,
                            height: buttonHeight * 0.34,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      Colors.white.withOpacity(0.68),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18),
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
                                      fontSize: 23,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF4A2500),
                                      shadows: <Shadow>[
                                        Shadow(
                                          color: Colors.white.withOpacity(0.75),
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
                                          fontSize: 23,
                                          fontWeight: FontWeight.w900,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
