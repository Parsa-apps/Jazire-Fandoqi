import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'fandoghi_bunny.dart';

bool _everDragged = false;

/// ═══════════════════════════════════════════════
/// 🐰 Draggable Fandoghi — a freely draggable
/// floating mascot that the user can move anywhere
/// on the screen with one finger. The position is
/// persisted in a global [ValueNotifier] so the
/// bunny stays where the child left it across
/// every page of the app.
/// ═══════════════════════════════════════════════

/// Fractional position (0..1) of the mascot's *center* relative to the
/// available screen. Using fractions means the bunny keeps the same visual
/// spot on phones and tablets of all sizes, and on rotation.
class FandoghiPosition extends ValueNotifier<Offset> {
  FandoghiPosition._(Offset initial) : super(initial);

  static final FandoghiPosition instance = FandoghiPosition._(
    const Offset(0.86, 0.78), // default: bottom-right
  );

  /// Update position from a raw pixel offset, converting to fractions of
  /// [size]. Bounds are clamped to keep the bunny on-screen.
  void updateFromPixels(Offset pixel, Size size) {
    final cx = (pixel.dx / size.width).clamp(0.05, 0.95).toDouble();
    final cy = (pixel.dy / size.height).clamp(0.08, 0.95).toDouble();
    value = Offset(cx, cy);
  }
}

/// The visual + interactive draggable bunny that should be mounted once at
/// the top of the widget tree (above all screens). Wrap your root screen
/// body in [DraggableFandoghiScope] or use [DraggableFandoghi] inside a
/// [Stack] for full control.
class DraggableFandoghi extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  final bool persistAcrossPages;

  const DraggableFandoghi({
    super.key,
    this.size = 96,
    this.onTap,
    this.persistAcrossPages = true,
  });

  @override
  State<DraggableFandoghi> createState() => _DraggableFandoghiState();
}

class _DraggableFandoghiState extends State<DraggableFandoghi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wobbleCtrl;
  double _scale = 1.0;
  bool _hasDragged = false;

  @override
  void initState() {
    super.initState();
    _hasDragged = _everDragged;
    _wobbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _wobbleCtrl.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails _) {
    _everDragged = true;
    setState(() {
      _hasDragged = true;
      _scale = 1.12;
    });
  }

  /// We use the global pointer position from the gesture itself
  /// ([DragUpdateDetails.globalPosition]) to compute the new center, which
  /// is the simplest and most robust way — no RenderBox math, no race
  /// conditions, no jitter.
  void _onPanUpdate(DragUpdateDetails details, Size parentSize) {
    // The center of the bunny follows the finger one-to-one.
    FandoghiPosition.instance.updateFromPixels(
      details.globalPosition,
      parentSize,
    );
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() => _scale = 1.0);
    _wobbleCtrl.forward(from: 0);
  }

  void _onTap() {
    _wobbleCtrl.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentSize = Size(constraints.maxWidth, constraints.maxHeight);
        return ValueListenableBuilder<Offset>(
          valueListenable: FandoghiPosition.instance,
          builder: (context, pos, _) {
            // Convert fraction to pixel center position.
            final cx = pos.dx * parentSize.width;
            final cy = pos.dy * parentSize.height;
            // Use top-left so the bunny's center is at (cx, cy).
            final left = cx - widget.size / 2;
            final top = cy - widget.size / 2;
            return AnimatedBuilder(
              animation: _wobbleCtrl,
              builder: (context, child) {
                final wobble = 1.0 +
                    (1.0 - _wobbleCtrl.value) * 0.08 *
                        (1 - (_wobbleCtrl.value - 0.5).abs() * 2);
                return Positioned(
                  left: left,
                  top: top,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onTap,
                    onPanStart: _onPanStart,
                    onPanUpdate: (d) => _onPanUpdate(d, parentSize),
                    onPanEnd: _onPanEnd,
                    child: AnimatedScale(
                      scale: _scale * wobble,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      child: _BunnyContainer(
                        size: widget.size,
                        showHint: !_hasDragged,
                        child: FandoghiBunny(size: widget.size),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Adds a soft drop shadow + circular white halo so the bunny is easy to
/// spot on any background, and a tiny "drag me" hint arrow that fades out
/// after the user has dragged the bunny once.
class _BunnyContainer extends StatelessWidget {
  final double size;
  final bool showHint;
  final Widget child;

  const _BunnyContainer({
    required this.size,
    required this.showHint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Soft halo so the bunny pops on any background.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.88),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 22,
                    offset: const Offset(0, 7),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFB8C8).withOpacity(0.6),
                    blurRadius: 28,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          // The bunny itself.
          Positioned.fill(child: child),
          // Tiny drag hint that fades out after the first drag.
          if (showHint)
            const Positioned(
              top: -6,
              right: -6,
              child: _DragHint(),
            ),
        ],
      ),
    );
  }
}

/// A small animated arrow that nudges the user to drag.
class _DragHint extends StatefulWidget {
  const _DragHint();

  @override
  State<_DragHint> createState() => _DragHintState();
}

class _DragHintState extends State<_DragHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final dx = (_ctrl.value - 0.5) * 8; // sway horizontally
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('بکش',
                    style: GoogleFonts.balooBhaijaan2(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFE91E63),
                    )),
                const SizedBox(width: 2),
                const Text('👆', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A convenient wrapper: stacks a [DraggableFandoghi] over [child] inside
/// a [Stack] with the same dimensions as the parent. Drop this around the
/// body of any screen to get a draggable mascot on that screen only.
class DraggableFandoghiScope extends StatelessWidget {
  final Widget child;
  final double size;
  final VoidCallback? onTap;

  const DraggableFandoghiScope({
    super.key,
    required this.child,
    this.size = 96,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned.fill(
          child: DraggableFandoghi(size: size, onTap: onTap),
        ),
      ],
    );
  }
}
