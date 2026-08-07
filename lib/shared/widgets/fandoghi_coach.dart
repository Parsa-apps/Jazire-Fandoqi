import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../core/fandoghi_coach.dart';
import 'fandoghi_v2.dart';

/// Global speech-bubble layer mounted by MaterialApp.builder.
/// It ignores pointer events so it can never block a game button or gesture.
class FandoghiCoachOverlay extends StatelessWidget {
  final Widget child;

  const FandoghiCoachOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FandoghiCoachMessage?>(
      valueListenable: FandoghiCoach.current,
      builder: (context, message, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (message != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 84,
                child: IgnorePointer(
                  child: SafeArea(
                    top: false,
                    child: _CoachBubble(message: message),
                  ),
                ),
              ),
          ],
        );
      },
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
          padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 14, 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: toneColor.withOpacity(0.45), width: 2),
            boxShadow: [
              BoxShadow(
                color: toneColor.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FandoghiV2(
                size: 88,
                animate: true,
                mood: message.mood,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'فندقی می‌گوید 🌰',
                      style: TextStyle(
                        color: toneColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.text,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.55,
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
