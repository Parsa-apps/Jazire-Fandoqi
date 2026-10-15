import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/audio_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🧩 کیت طراحی «دنیای جزیرهٔ فندقی»
///
/// همهٔ صفحه‌ها، بازی‌ها و پنجره‌ها باید از همین چند جزء مشترک
/// ساخته شوند تا کل برنامه یک هویت بصری واحد داشته باشد:
///
///   • [IslandKidButton] — دکمهٔ بزرگِ کودکانه با فشردگی لمسی
///   • [IslandPanel] — پنل کاغذی کارتونی با حاشیهٔ عسلی
///   • [showIslandDialog] — پنجرهٔ هم‌سبک با دنیای جزیره
///   • [IslandStatChip] — چیپ آماری (ستاره، سکه و ...)
///
/// رنگ‌ها و شعاع‌ها از `island_world_style.dart` می‌آیند؛ اینجا
/// هیچ رنگ تازه‌ای اختراع نمی‌شود.
/// ═══════════════════════════════════════════════════════════════

/// زبان حرکتی مشترک برنامه: فشردن کوتاه، بازگشت فنری، بدون چشمک.
abstract final class IslandMotion {
  static const Duration pressIn = IslandWorldMetrics.pressIn;
  static const Duration pressOut = IslandWorldMetrics.pressOut;
  static const Curve pressCurve = Curves.easeOut;
  static const Curve springCurve = Curves.easeOutBack;
  static const double pressScale = IslandWorldMetrics.pressScale;
}

/// دکمهٔ اصلی کودک: بزرگ، گرد، با گرادیان عسلی و حاشیهٔ روشن.
/// هنگام لمس کمی فشرده می‌شود و فنری برمی‌گردد؛ صدای لمس و هپتیک
/// ملایم دارد و ناحیهٔ لمسش همیشه برای دست کودک کافی است.
class IslandKidButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final VoidCallback? onPressed;

  /// دکمهٔ اصلی (عسلی) یا فرعی (کاغذی با حاشیهٔ رنگی)
  final bool primary;

  /// رنگ تأکیدی حالت فرعی و سایه
  final Color accent;

  const IslandKidButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.emoji,
    this.primary = true,
    this.accent = IslandWorldPalette.honey,
  });

  @override
  State<IslandKidButton> createState() => _IslandKidButtonState();
}

class _IslandKidButtonState extends State<IslandKidButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _press;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: IslandMotion.pressIn,
      reverseDuration: IslandMotion.pressOut,
    );
    _press = CurvedAnimation(
      parent: _pressCtrl,
      curve: IslandMotion.pressCurve,
      reverseCurve: IslandMotion.springCurve,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onPressed != null;

  void _handleTap() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
    AudioService.tap();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primary;
    final fg = primary ? const Color(0xFF5D3A12) : IslandWorldPalette.ink;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => _pressCtrl.forward() : null,
        onTapUp: _enabled ? (_) => _pressCtrl.reverse() : null,
        onTapCancel: _enabled ? () => _pressCtrl.reverse() : null,
        onTap: _enabled ? _handleTap : null,
        child: AnimatedBuilder(
          animation: _press,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 - _press.value * (1 - IslandMotion.pressScale),
              child: child,
            );
          },
          child: Opacity(
            opacity: _enabled ? 1 : 0.45,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: IslandWorldMetrics.primaryActionHeight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                gradient: primary
                    ? IslandWorldGradients.honeyButton
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFFDF7), Color(0xFFFFF3D6)],
                      ),
                borderRadius:
                    BorderRadius.circular(IslandWorldMetrics.buttonRadius),
                border: Border.all(
                  color: primary
                      ? const Color(0xFFFFE9A8)
                      : widget.accent.withOpacity(0.65),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (primary ? IslandWorldPalette.honey : widget.accent)
                        .withOpacity(0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.emoji != null) ...[
                    Text(widget.emoji!,
                        style: const TextStyle(fontSize: 20, height: 1.1)),
                    const SizedBox(width: 8),
                  ],
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: fg, size: 21),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppFonts.kids(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: fg,
                        height: 1.2,
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

/// پنل کاغذی کارتونی: پس‌زمینهٔ کرمِ گرادیانی، حاشیهٔ عسلی و سایهٔ
/// نرم — ظرف استاندارد همهٔ کارت‌ها و پنجره‌های برنامه.
class IslandPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final double radius;

  const IslandPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor = IslandWorldPalette.honey,
    this.radius = IslandWorldMetrics.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFDF7), Color(0xFFFFF6E0)],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: IslandWorldPalette.ink.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// چیپ آماری جزیره (ستاره/سکه/...): مدال رنگی دور آیکون + عدد فارسی.
class IslandStatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String? semanticLabel;

  const IslandStatChip({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDF7), Color(0xFFFFF3D6)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.45), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.85), color],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 5),
            Text(
              value,
              style: AppFonts.kids(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: IslandWorldPalette.ink,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// پنجرهٔ کارتونی هم‌سبک دنیای جزیره: پنل کاغذی، عنوان تپل و
/// دکمه‌های استاندارد کودک. برای پیام‌های دوستانهٔ خطا/موفقیت و
/// تأییدها از همین استفاده شود تا هیچ پنجرهٔ بی‌روحی نماند.
Future<T?> showIslandDialog<T>({
  required BuildContext context,
  required String title,
  String? emoji,
  required Widget body,
  List<Widget> actions = const [],
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0x66204030),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: IslandPanel(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(emoji, style: const TextStyle(fontSize: 40, height: 1.1)),
                const SizedBox(height: 8),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFonts.kids(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: IslandWorldPalette.ink,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              body,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
