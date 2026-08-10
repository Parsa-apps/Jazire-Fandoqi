import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/design_tokens.dart';
import '../../app/app_fonts.dart';
import '../../app/app_colors.dart';

/// ═══════════════════════════════════════════════════════════════
/// ✍️ HANDWRITING SCORE OVERLAY — پیشنهاد پریمیوم ۲۱
/// نمایش امتیاز ۰-۱۰۰ + ۳ ستاره + بازخورد توصیفی ML-like آفلاین
/// ═══════════════════════════════════════════════════════════════
class HandwritingScoreOverlay extends StatelessWidget {
  final double score; // 0..1
  final String letter;
  final bool passed;
  final VoidCallback? onNext;
  final VoidCallback? onRetry;

  const HandwritingScoreOverlay({
    super.key,
    required this.score,
    required this.letter,
    required this.passed,
    this.onNext,
    this.onRetry,
  });

  int get stars {
    if (score >= 0.85) return 3;
    if (score >= 0.65) return 2;
    if (score >= 0.5) return 1;
    return 0;
  }

  String get feedback {
    if (stars == 3) return 'عالیه! دندانه «$letter» و کشیدگیش بی‌نقص بود! 🌟';
    if (stars == 2) return 'خیلی خوب! فقط کمی بیشتر روی خط راهنما بمون 💪';
    if (stars == 1) return 'خوبه! یه بار دیگه با آرامش بیشتر بنویس ✍️';
    return 'هنوز کمی بیرون خط رفتی؛ از نقطه‌های کم‌رنگ آروم‌تر رد شو 🙂';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: passed ? const Color(0xFF00B894).withOpacity(0.3) : Colors.orange.withOpacity(0.3), width: 2),
        boxShadow: AppShadows.strong,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          // امتیاز عددی
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (passed ? const Color(0xFF00B894) : Colors.orange).withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text('${(score * 100).round()}٪ — ${passed ? "قبول" : "تلاش دوباره"}',
                style: AppFonts.vazirmatn(fontSize: 16, fontWeight: FontWeight.w900, color: passed ? const Color(0xFF00B894) : Colors.orange)),
          ),
          const SizedBox(height: 12),
          Text(feedback, textAlign: TextAlign.center, style: AppFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w700, height: 1.6, color: isDark ? Colors.white70 : const Color(0xFF2D3436))),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!passed) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('دوباره', style: AppFonts.vazirmatn(fontWeight: FontWeight.w800)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNext,
                  icon: Icon(passed ? Icons.arrow_forward_rounded : Icons.lightbulb_rounded, size: 18),
                  label: Text(passed ? 'حرف بعدی →' : 'نکته', style: AppFonts.vazirmatn(fontWeight: FontWeight.w900)),
                  style: FilledButton.styleFrom(
                    backgroundColor: passed ? AppColors.primary : const Color(0xFF00B894),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
                  ),
                ),
              ),
            ],
          ),
          if (passed) ...[
            const SizedBox(height: 10),
            Text('+8 سکه  •  +1 ستاره  •  حرف «$letter» ثبت شد ⭐', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          ],
        ],
      ),
    ).animate().scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut).fadeIn(duration: 400.ms);
  }
}
