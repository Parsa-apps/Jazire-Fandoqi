import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import '../../core/fandoghi_coach.dart';

/// لایهٔ سراسری بازخورد. شخصیت مربی دیگر روی صفحه شناور نیست
/// تا جلوی دکمه‌های کودک را نگیرد. متن راهنما با فونت درشت و
/// انیمیشن نرم از بالای صفحه ظاهر می‌شود.
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          const Positioned.fill(
            child: IgnorePointer(child: _CoachToastLayer()),
          ),
        ],
      ),
    );
  }
}

class _CoachToastLayer extends StatelessWidget {
  const _CoachToastLayer();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FandoghiCoachMessage?>(
      valueListenable: FandoghiCoach.current,
      builder: (context, message, _) {
        if (message == null) return const SizedBox.shrink();
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _CoachToast(message: message),
            ),
          ),
        );
      },
    );
  }
}

class _CoachToast extends StatelessWidget {
  final FandoghiCoachMessage message;

  const _CoachToast({required this.message});

  @override
  Widget build(BuildContext context) {
    final toneColor = switch (message.tone) {
      FandoghiCoachTone.success => const Color(0xFF00B894),
      FandoghiCoachTone.encouragement => const Color(0xFF0984E3),
      FandoghiCoachTone.warning => const Color(0xFFE17055),
      FandoghiCoachTone.neutral => const Color(0xFF00A8C6),
    };
    final emoji = switch (message.tone) {
      FandoghiCoachTone.success => '🌟',
      FandoghiCoachTone.encouragement => '💪',
      FandoghiCoachTone.warning => '🌙',
      FandoghiCoachTone.neutral => '✨',
    };

    return Semantics(
      liveRegion: true,
      label: message.text,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, -0.18),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: Container(
          key: ValueKey<int>(message.id),
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: toneColor.withOpacity(0.55), width: 2),
            boxShadow: [
              BoxShadow(
                color: toneColor.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message.text,
                  textAlign: TextAlign.start,
                  style: AppFonts.vazirmatn(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate(key: ValueKey<int>(message.id))
            .scale(
              begin: const Offset(0.92, 0.92),
              duration: 320.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}
