import 'package:flutter/material.dart';

/// ────────────────────────────────────────────────────────────
/// 👆 فاز ۱۱/۱۳: استاندارد هدف لمسی کودکانه
///
/// همه اهداف لمسی اپ باید حداقل ۶۴×۶۴px باشند (توانایی حرکتی
/// کودکان ۳-۸ سال). این ویجت هر child کوچکی را در یک ناحیه
/// لمسی امن می‌پیچد و در حالت فشرده، مقیاس ظریفی می‌دهد.
/// ────────────────────────────────────────────────────────────
class ChildTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minSize;

  /// اگر `true` باشد، هاله آبی «بزرگ‌نمایی لمس» (tap target) نمایش داده می‌شود.
  final bool showHighlight;

  const ChildTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minSize = 64,
    this.showHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(
            minWidth: minSize,
            minHeight: minSize,
          ),
          alignment: Alignment.center,
          decoration: showHighlight
              ? BoxDecoration(
                  color: Colors.blue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(minSize / 3),
                )
              : null,
          child: child,
        ),
      ),
    );
  }
}

/// بازخورد فشاری نرم برای دکمه‌های کودکانه (scale on press).
class ChildPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double pressedScale;

  const ChildPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.pressedScale = 0.94,
  });

  @override
  State<ChildPressable> createState() => _ChildPressableState();
}

class _ChildPressableState extends State<ChildPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onPressed == null ? null : () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
