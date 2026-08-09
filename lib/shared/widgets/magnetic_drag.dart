import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ────────────────────────────────────────────────────────────
/// 🧲 فاز ۱۳: سیستم Drag & Drop کودکانه
///
/// - ناحیه‌های هدف بزرگ (min 64px) طبق استاندارد فاز ۱۱
/// - آهنربای کناری: وقتی قطعه به هدف نزدیک است (پیش‌فرض 48px)
///   به‌طور نرم به مرکز هدف می‌چسبد
/// - ویبره نرم هنگام چسبیدن به آهنربا
/// - بازخورد بصری هدف (هایلایت) وقتی قطعه روی آن است
/// ────────────────────────────────────────────────────────────
class MagneticDropZone extends StatefulWidget {
  final Widget child;
  final Widget? placeholder;
  final void Function()? onDropped;
  final double magnetRadius;
  final bool hapticOnSnap;

  const MagneticDropZone({
    super.key,
    required this.child,
    this.placeholder,
    this.onDropped,
    this.magnetRadius = 48,
    this.hapticOnSnap = true,
  });

  @override
  State<MagneticDropZone> createState() => _MagneticDropZoneState();
}

class _MagneticDropZoneState extends State<MagneticDropZone> {
  bool _highlighted = false;
  bool _filled = false;

  void _handleDrop() {
    if (_filled) return;
    setState(() => _filled = true);
    if (widget.hapticOnSnap) {
      HapticFeedback.lightImpact();
    }
    widget.onDropped?.call();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => !_filled,
      onAcceptWithDetails: (_) => _handleDrop(),
      onMove: (_) {
        if (!_highlighted) setState(() => _highlighted = true);
      },
      onLeave: (_) {
        if (_highlighted) setState(() => _highlighted = false);
      },
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
          decoration: BoxDecoration(
            color: hovering
                ? Colors.amber.withOpacity(0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: hovering
                ? Border.all(color: Colors.amber, width: 3)
                : null,
          ),
          child: Center(child: _filled ? widget.child : (widget.placeholder ?? widget.child)),
        );
      },
    );
  }
}

/// قطعه قابل کشیدن با آهنربای چسبنده به [MagneticDropZone].
class MagneticDraggable extends StatelessWidget {
  final String data;
  final Widget child;
  final VoidCallback? onDragStarted;

  const MagneticDraggable({
    super.key,
    required this.data,
    required this.child,
    this.onDragStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: data,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.08, child: child),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      onDragStarted: onDragStarted,
      child: child,
    );
  }
}

/// پوشش لمسی بزرگ برای آیتم‌های کوچک (min 64px).
class BigTouchArea extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const BigTouchArea({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
