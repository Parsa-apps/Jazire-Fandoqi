import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import 'fandoghi_hazelnut_character.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌰 FANDOGHI COACH OVERLAY — لایه سراسری همراه و مربی هوشمند
/// کاملاً بدون مزاحمت برای لمس گزینه‌ها و خواندن متون (Non-Intrusive)
/// پیام‌ها از بالا به صورت بنر سبک ظاهر شده و لمس را به لایه‌های زیرین عبور می‌دهند
/// ═══════════════════════════════════════════════════════════════
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
          // لایه بنر پیام‌های فندقی (IgnorePointer فعال است تا هیچ دکمه‌ای مسدود نشود)
          const Positioned.fill(
            child: IgnorePointer(
              child: _CoachToastLayer(),
            ),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
      FandoghiCoachTone.success => const Color(0xFF27AE60),
      FandoghiCoachTone.encouragement => const Color(0xFF2980B9),
      FandoghiCoachTone.warning => const Color(0xFFE67E22),
      FandoghiCoachTone.neutral => const Color(0xFF8E44AD),
    };

    return Semantics(
      liveRegion: true,
      label: 'پیام فندقی: ${message.text}',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, -0.22),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: Container(
          key: ValueKey<int>(message.id),
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: toneColor.withOpacity(0.55), width: 2),
            boxShadow: [
              BoxShadow(
                color: toneColor.withOpacity(0.24),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // کاراکتر فندقی سخنگو در کنار پیام
              SizedBox(
                width: 44,
                height: 44,
                child: FandoghiHazelnutCharacter(
                  size: 44,
                  mood: message.mood,
                  isTalking: true,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message.text,
                  textAlign: TextAlign.start,
                  style: AppFonts.vazirmatn(
                    color: const Color(0xFF2C3E50),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate(key: ValueKey<int>(message.id))
            .scale(
              begin: const Offset(0.94, 0.94),
              duration: 280.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}
