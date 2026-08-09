import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import '../../core/fandoghi_coach.dart';
import 'draggable_fandoghi.dart';
import 'fandoghi_bunny.dart';
import 'fandoghi_welcome.dart';

/// Global speech-bubble layer mounted by MaterialApp.builder.
/// It ignores pointer events so it can never block a game button or gesture.
///
/// This is now also the home of the always-on, freely-draggable bunny
/// mascot. The bunny lives in the global [FandoghiPosition] notifier so
/// it stays exactly where the child left it on every page.
class FandoghiCoachOverlay extends StatelessWidget {
  final Widget child;

  const FandoghiCoachOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ValueListenableBuilder<bool>(
        valueListenable: FandoghiCoach.persistent,
        builder: (context, showPersistent, _) {
          return ValueListenableBuilder<FandoghiCoachMessage?>(
            valueListenable: FandoghiCoach.current,
            builder: (context, message, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  child,
                  // The mascot is shown only after a screen requests a persistent
                  // coach, or while it is actively delivering a message.
                  if (showPersistent || message != null)
                    const Positioned.fill(child: _DraggableMascot()),
                  if (message != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _CoachBubbleFollower(
                          message: message,
                          mascotSize: 84,
                        ),
                      ),
                    )
                  else if (showPersistent)
                    const SizedBox.shrink(),
                  // Cinematic welcome intro. Renders above everything and
                  // listens to its own isPlaying flag so it can play once
                  // per session without blocking the rest of the UI.
                  const FandoghiWelcomeOverlay(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// The always-on, freely-draggable mascot. Tap = instruction prompt,
/// drag = move anywhere on the screen. اندازهٔ کوچک‌تر + ناحیهٔ لمسی
/// فشرده باعث می‌شود هیچ‌وقت جلوی لمس گزینه‌ها و دکمه‌ها را نگیرد.
class _DraggableMascot extends StatelessWidget {
  const _DraggableMascot();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: FandoghiCoach.minimized,
      builder: (context, minimized, _) => DraggableFandoghi(
        size: minimized ? 48 : 84,
        minimized: minimized,
        onRestore: FandoghiCoach.restore,
        onMinimize: FandoghiCoach.minimize,
        onClose: FandoghiCoach.disablePersistentPresence,
        onTap: () => FandoghiCoach.instruction(
          'هر وقت کمک خواستی روی من بزن! من راهنمای تو هستم 🧒',
        ),
      ),
    );
  }
}

/// Positions the coach bubble next to the same fractional center used by the
/// draggable mascot. The old implementation pinned this bubble to a fixed
/// bottom offset, so moving the mascot made the character and its words look
/// unrelated.
class _CoachBubbleFollower extends StatelessWidget {
  final FandoghiCoachMessage message;
  final double mascotSize;

  const _CoachBubbleFollower({
    required this.message,
    required this.mascotSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return ValueListenableBuilder<Offset>(
          valueListenable: FandoghiPosition.instance,
          builder: (context, position, _) {
            final center = Offset(
              position.dx * size.width,
              position.dy * size.height,
            );
            return CustomSingleChildLayout(
              delegate: _CoachBubbleLayoutDelegate(
                mascotCenter: center,
                mascotSize: mascotSize,
              ),
              child: _CoachBubble(message: message),
            );
          },
        );
      },
    );
  }
}

class _CoachBubbleLayoutDelegate extends SingleChildLayoutDelegate {
  final Offset mascotCenter;
  final double mascotSize;
  static const double _edgePadding = 12;
  static const double _gap = 14;
  static const double _maxBubbleWidth = 400;

  const _CoachBubbleLayoutDelegate({
    required this.mascotCenter,
    required this.mascotSize,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth.isFinite
        ? math.max(0.0, math.min(_maxBubbleWidth, constraints.maxWidth - 24))
            .toDouble()
        : _maxBubbleWidth;
    final maxHeight = constraints.maxHeight.isFinite
        ? math.max(0.0, constraints.maxHeight - 24).toDouble()
        : double.infinity;
    return BoxConstraints(
      minWidth: maxWidth,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final availableWidth = math.max(0.0, size.width - childSize.width);
    final left = (mascotCenter.dx - childSize.width / 2)
        .clamp(_edgePadding, math.max(_edgePadding, availableWidth - _edgePadding))
        .toDouble();

    final above = mascotCenter.dy - mascotSize / 2 - _gap - childSize.height;
    final below = mascotCenter.dy + mascotSize / 2 + _gap;
    final bottomLimit = size.height - _edgePadding - childSize.height;
    final top = above >= _edgePadding
        ? above
        : below <= bottomLimit
            ? below
            : (mascotCenter.dy - childSize.height / 2)
                .clamp(_edgePadding, math.max(_edgePadding, bottomLimit))
                .toDouble();

    return Offset(left, top);
  }

  @override
  bool shouldRelayout(covariant _CoachBubbleLayoutDelegate oldDelegate) =>
      oldDelegate.mascotCenter != mascotCenter ||
      oldDelegate.mascotSize != mascotSize;
}

class _CoachBubble extends StatelessWidget {
  final FandoghiCoachMessage message;

  const _CoachBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final toneColor = switch (message.tone) {
      FandoghiCoachTone.success => AppColors.success,
      FandoghiCoachTone.encouragement => AppColors.primary,
      FandoghiCoachTone.warning => AppColors.warning,
      FandoghiCoachTone.neutral => AppColors.primary,
    };

    return Semantics(
      liveRegion: true,
      label: 'پیام فندقی: ${message.text}',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: Container(
          key: ValueKey<int>(message.id),
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 12, 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: toneColor.withOpacity(0.55), width: 2),
            boxShadow: [
              BoxShadow(
                color: toneColor.withOpacity(0.3),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // بیان چهرهٔ واقعی متناسب با حس پیام (شادی، فکر، تعجب، جشن)
              FandoghiBunny(size: 56, mood: message.mood),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'فندقی می‌گوید 🧒',
                      style: AppFonts.balooBhaijaan2(
                        color: toneColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.text,
                      textAlign: TextAlign.start,
                      style: AppFonts.balooBhaijaan2(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
