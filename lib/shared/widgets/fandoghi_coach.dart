import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_colors.dart';
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
                  // The draggable bunny mascot (always present, even when
                  // a bubble is shown, so the user can keep dragging it).
                  const Positioned.fill(child: _DraggableMascot()),
                  if (message != null)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 140,
                      child: IgnorePointer(
                        child: SafeArea(
                          top: false,
                          child: _CoachBubble(message: message),
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

/// The always-on, freely-draggable bunny. Tap = instruction prompt,
/// drag = move anywhere on the screen.
class _DraggableMascot extends StatelessWidget {
  const _DraggableMascot();

  @override
  Widget build(BuildContext context) {
    return DraggableFandoghi(
      size: 120,
      onTap: () => FandoghiCoach.instruction(
        'هر وقت کمک خواستی روی من بزن! من راهنمای تو هستم 🐰',
      ),
    );
  }
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
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 14, 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: toneColor.withOpacity(0.55), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: toneColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FandoghiBunny(size: 96),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'فندقی می‌گوید 🐰',
                      style: GoogleFonts.balooBhaijaan2(
                        color: toneColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message.text,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.balooBhaijaan2(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
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
