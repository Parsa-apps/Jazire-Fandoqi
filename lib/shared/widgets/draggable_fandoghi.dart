import 'package:flutter/material.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import 'package:flutter/rendering.dart';

import 'fandoghi_bunny.dart';

bool _everDragged = false;

/// ═══════════════════════════════════════════════
/// 🧒 Draggable Fandoghi — a freely draggable
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

  /// Update position from a pixel-space center, converting to fractions of
  /// [size]. Bounds account for the mascot frame so dragging cannot leave a
  /// visibly cut-off bunny at the edges of the screen.
  void updateFromPixels(
    Offset pixel,
    Size size, {
    double mascotSize = 0,
  }) {
    if (size.width <= 0 || size.height <= 0) return;

    final halfWidth = (mascotSize / 2).clamp(0.0, size.width / 2).toDouble();
    final halfHeight = (mascotSize / 2).clamp(0.0, size.height / 2).toDouble();
    final minX = (halfWidth / size.width).clamp(0.02, 0.5).toDouble();
    final maxX = 1.0 - minX;
    final minY = (halfHeight / size.height).clamp(0.02, 0.5).toDouble();
    final maxY = 1.0 - minY;

    final cx = (pixel.dx / size.width).clamp(minX, maxX).toDouble();
    final cy = (pixel.dy / size.height).clamp(minY, maxY).toDouble();
    value = Offset(cx, cy);
  }

  /// Converts the stored fractional center into the coordinate space used by
  /// the overlay. Keeping this in one place prevents the mascot and its
  /// speech bubble from drifting apart when the screen is resized.
  Offset toPixels(Size size) => Offset(
        value.dx * size.width,
        value.dy * size.height,
      );
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
  late final AnimationController _snapCtrl;
  Animation<Offset>? _snapAnim;
  double _scale = 1.0;
  bool _hasDragged = false;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _hasDragged = _everDragged;
    _wobbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // انیمیشن چسبیدن به لبهٔ صفحه بعد از رها کردن، تا مسکات روی
    // محتوا و دکمه‌های وسط صفحه معلق نماند.
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _wobbleCtrl.dispose();
    _snapCtrl.dispose();
    super.dispose();
  }

  Offset _toParentPosition(Offset globalPosition, BuildContext coordinateContext) {
    final renderObject = coordinateContext.findRenderObject();
    if (renderObject is RenderBox) {
      return renderObject.globalToLocal(globalPosition);
    }
    return globalPosition;
  }

  void _onPanStart(
    DragStartDetails details,
    Size parentSize,
    BuildContext coordinateContext,
  ) {
    // اگر انیمیشن چسبیدن به لبه در حال اجراست، متوقفش کن تا با انگشت
    // کاربر تقابل نکند.
    _snapCtrl.stop();
    _snapAnim?.removeListener(_applySnap);
    _snapAnim = null;

    final pointer = _toParentPosition(details.globalPosition, coordinateContext);
    final center = FandoghiPosition.instance.toPixels(parentSize);
    // Preserve the point where the child grabbed the mascot. Without this
    // offset the mascot jumps so its center lands under the finger on the
    // first update, which feels especially wrong for a child-sized target.
    _dragOffset = pointer - center;

    _everDragged = true;
    setState(() {
      _hasDragged = true;
      _scale = 1.12;
    });
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    Size parentSize,
    BuildContext coordinateContext,
  ) {
    final pointer = _toParentPosition(details.globalPosition, coordinateContext);
    FandoghiPosition.instance.updateFromPixels(
      pointer - _dragOffset,
      parentSize,
      mascotSize: widget.size,
    );
  }

  void _applySnap() {
    final anim = _snapAnim;
    if (anim != null) {
      FandoghiPosition.instance.value = anim.value;
    }
  }

  /// بعد از رها شدن، مسکات به نزدیک‌ترین لبهٔ افقی می‌چسبد تا روی
  /// گزینه‌ها و محتوای وسط صفحه خیمه نزند.
  void _snapToEdge(Size parentSize) {
    if (parentSize.width <= 0 || parentSize.height <= 0) return;
    final pos = FandoghiPosition.instance;
    final current = pos.value;

    final halfW = ((widget.size / 2) / parentSize.width)
        .clamp(0.02, 0.5)
        .toDouble();
    final minX = (halfW + 0.008).clamp(0.02, 0.5).toDouble();
    final maxX = 1.0 - minX;
    final targetX = current.dx < 0.5 ? minX : maxX;

    if ((current.dx - targetX).abs() < 0.002) return;

    _snapAnim?.removeListener(_applySnap);
    _snapAnim = CurvedAnimation(
      parent: _snapCtrl,
      curve: Curves.easeOutCubic,
    ).drive(Tween<Offset>(begin: current, end: Offset(targetX, current.dy)))
      ..addListener(_applySnap);
    _snapCtrl.forward(from: 0);
  }

  void _finishPan(Size parentSize) {
    _dragOffset = Offset.zero;
    if (mounted) setState(() => _scale = 1.0);
    _wobbleCtrl.forward(from: 0);
    _snapToEdge(parentSize);
  }

  void _onPanEnd(DragEndDetails _, Size parentSize) => _finishPan(parentSize);

  void _onPanCancel(Size parentSize) => _finishPan(parentSize);

  void _onTap() {
    _wobbleCtrl.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (coordinateContext, constraints) {
        final parentSize = Size(constraints.maxWidth, constraints.maxHeight);
        // The bunny is placed with a [Positioned] widget, which is only valid
        // as a direct descendant of a [Stack]. Previously [Positioned] was
        // returned straight from this [LayoutBuilder] with no [Stack] ancestor,
        // so Flutter threw a "ParentDataWidget Positioned" assertion on every
        // screen the mascot was mounted on. This [Stack] is that missing parent
        // and gives the fractional position a real coordinate space to resolve
        // against (the global overlay feeds us full-size constraints).
        return Stack(
          fit: StackFit.expand,
          children: [
            ValueListenableBuilder<Offset>(
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
                      child: SizedBox(
                        width: widget.size,
                        height: widget.size,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 🖼️ لایهٔ دیداری: تصویر مسکات لمس را رد می‌کند،
                            // پس حاشیه‌های شفاف عکس هیچ وقت جلوی لمس
                            // دکمه‌ها و گزینه‌های زیرش را نمی‌گیرد.
                            Positioned.fill(
                              child: IgnorePointer(
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
                            ),
                            // 👆 لایهٔ لمسی: فقط ناحیهٔ بدن شخصیت (مرکز
                            // تصویر) لمسی است — نه کل قاب مربع.
                            Center(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _onTap,
                                onPanStart: (d) => _onPanStart(
                                    d, parentSize, coordinateContext),
                                onPanUpdate: (d) => _onPanUpdate(
                                    d, parentSize, coordinateContext),
                                onPanEnd: (d) => _onPanEnd(d, parentSize),
                                onPanCancel: () => _onPanCancel(parentSize),
                                child: SizedBox(
                                  width: widget.size * 0.62,
                                  height: widget.size * 0.78,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Adds a soft drop shadow and a subtle glow so the bunny is easy to spot
/// on any background, without creating a visible white cut-out circle around
/// the artwork. A tiny "drag me" hint fades out after the first drag.
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
                color: Colors.transparent,
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
                    style: AppFonts.balooBhaijaan2(
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
