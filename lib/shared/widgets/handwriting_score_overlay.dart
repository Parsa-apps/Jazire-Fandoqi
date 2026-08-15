import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/design_tokens.dart';
import '../../app/app_fonts.dart';
import '../../app/app_colors.dart';

/// ═══════════════════════════════════════════════════════════════
/// ✍️ HANDWRITING SCORE OVERLAY — ارزیابی دقیق و مهربان معلم کلاس اول
/// قفل بودن نشانه بعدی تا زمان تأیید رسمی معلم با مهر صدآفرین
/// ═══════════════════════════════════════════════════════════════
class HandwritingScoreOverlay extends StatelessWidget {
  final double score; // 0..1
  final String letter;
  final bool passed;
  final VoidCallback? onNext;
  final VoidCallback? onRetry;
  final VoidCallback? onShowGuide;

  const HandwritingScoreOverlay({
    super.key,
    required this.score,
    required this.letter,
    required this.passed,
    this.onNext,
    this.onRetry,
    this.onShowGuide,
  });

  int get stars {
    if (score >= 0.85) return 3;
    if (score >= 0.65) return 2;
    if (score >= 0.50) return 1;
    return 0;
  }

  String get teacherFeedback {
    if (stars == 3) {
      return 'آفرین صدآفرین! خط تو روی خط کرسی بی‌نقص و بسیار تمیز است 🌟 مهر قبولی را گرفتی!';
    }
    if (stars == 2) {
      return 'خیلی خوب نوشتی! معلم خوش‌خطی شما را تأیید کرد 🌸 می‌توانی به نشانه بعدی بروی!';
    }
    if (stars == 1) {
      return 'نزدیک شدی اما هنوز کامل نیست! خط از نشانه بیرون رفته؛ باید یک بار دیگر با دقت تمرین کنی ✍️';
    }
    return 'هنوز کامل نشد! برای یادگیری بهتر، از نقطه سبز شروع کن و دقیقاً روی خط‌های کم‌رنگ بکش 🙂';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: passed ? const Color(0xFF00B894) : const Color(0xFFE74C3C),
          width: 2.5,
        ),
        boxShadow: AppShadows.strong,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مهر کارتونی معلم
          if (passed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00B894).withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: const Color(0xFF00B894), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏵️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(
                    'مهر تأیید معلم اول دبستان',
                    style: AppFonts.balooBhaijaan2(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00B894),
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: Colors.orange, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✍️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    'نیاز به تمرین بیشتر',
                    style: AppFonts.balooBhaijaan2(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          // ستاره‌ها
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final filled = i < stars;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 42,
                  color: filled ? const Color(0xFFFFD700) : Colors.grey.shade300,
                )
                    .animate(delay: (i * 150).ms)
                    .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(delay: 600.ms, duration: 800.ms, color: Colors.white.withOpacity(0.6)),
              );
            }),
          ),
          const SizedBox(height: 12),
          // امتیاز عددی و وضعیت
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: (passed ? const Color(0xFF00B894) : const Color(0xFFE74C3C)).withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              '${(score * 100).round()}٪ — ${passed ? "قبول و تأیید شد ✅" : "تأیید نشد ❌"}',
              style: AppFonts.vazirmatn(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: passed ? const Color(0xFF00B894) : const Color(0xFFE74C3C),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            teacherFeedback,
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.6,
              color: isDark ? Colors.white70 : const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 18),
          // دکمه‌ها
          if (passed)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: Text(
                  'نشانه بعدی →',
                  style: AppFonts.balooBhaijaan2(fontWeight: FontWeight.w900, fontSize: 17),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
                ),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(
                      'تلاش دوباره با کمک معلم ✍️',
                      style: AppFonts.balooBhaijaan2(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
                    ),
                  ),
                ),
                if (onShowGuide != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onShowGuide,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(
                        'قلم جادویی (نشانم بده چطور بنویسم) 🪄',
                        style: AppFonts.balooBhaijaan2(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2980B9),
                        side: const BorderSide(color: Color(0xFF2980B9), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          if (passed) ...[
            const SizedBox(height: 10),
            Text(
              '+8 سکه  •  +1 ستاره  •  نشانه «$letter» در کارنامه ثبت شد ⭐',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ).animate().scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut).fadeIn(duration: 400.ms);
  }
}
