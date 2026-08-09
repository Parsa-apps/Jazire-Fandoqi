import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amoozesh_fandoghi/app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import 'package:amoozesh_fandoghi/core/fandoghi_coach.dart';
import 'package:amoozesh_fandoghi/core/game_data.dart';
import 'package:amoozesh_fandoghi/shared/widgets/fandoghi_v2.dart';

/// ═══════════════════════════════════════════════════════════════
/// ⭐ CARTOON RATING DIALOG — دریافت امتیاز ۵ ستاره و هدیه ۵۰ سکه
/// ═══════════════════════════════════════════════════════════════
class CartoonRatingDialog extends StatefulWidget {
  const CartoonRatingDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const CartoonRatingDialog(),
    );
  }

  @override
  State<CartoonRatingDialog> createState() => _CartoonRatingDialogState();
}

class _CartoonRatingDialogState extends State<CartoonRatingDialog> {
  int _selectedStars = 5;
  bool _submitted = false;

  final List<String> _starLabels = [
    'نیاز به بهتر شدن 🌿',
    'بد نیست 😊',
    'خوب بود 👍',
    'خیلی دوست داشتم! 💖',
    'فوق‌العاده و بی‌نظیر! 🌟🎉',
  ];

  void _onRate() {
    HapticFeedback.heavyImpact();
    setState(() => _submitted = true);

    final claimed = GameData.claimRatingReward();
    if (claimed) {
      FandoghiCoach.celebrate('هورااا! ۵۰ سکه هدیه گرفتی! ممنون از محبتت 🌰💖');
    } else {
      FandoghiCoach.say('ممنون از نظر قشنگت دوست مهربانم! 🌟', mood: FandoghiMood.excited);
    }

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.amber.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: _submitted ? _buildSubmittedContent() : _buildRatingForm(),
      ),
    );
  }

  Widget _buildRatingForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Mascot
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FandoghiV2(
              size: 80,
              animate: true,
              mood: FandoghiMood.excited,
            ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
          ],
        ),
        const SizedBox(height: 12),

        // Title
        Text(
          'کارتون‌ها و بازی‌ها رو دوست داشتی؟',
          textAlign: TextAlign.center,
          style: AppFonts.vazirmatn(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle & Reward badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'با ثبت ۵ ستاره، ۵۰ سکه هدیه بگیر!',
                style: AppFonts.vazirmatn(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
        ).animate().shimmer(duration: 1500.ms, delay: 300.ms),

        const SizedBox(height: 20),

        // Interactive 5 Stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNum = index + 1;
            final isFilled = starNum <= _selectedStars;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedStars = starNum);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 46,
                  color: isFilled ? const Color(0xFFFFB300) : Colors.black26,
                ),
              )
                  .animate(target: isFilled ? 1 : 0)
                  .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.1, 1.1), duration: 200.ms),
            );
          }),
        ),
        const SizedBox(height: 10),

        // Feedback text for selected rating
        Text(
          _starLabels[_selectedStars - 1],
          style: AppFonts.vazirmatn(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 24),

        // Actions
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'بعداً',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _onRate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_rounded, size: 20, color: Colors.pinkAccent),
                    const SizedBox(width: 8),
                    Text(
                      'ثبت ۵ ستاره 🌟',
                      style: AppFonts.vazirmatn(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmittedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const Text('🎉', style: TextStyle(fontSize: 60))
            .animate()
            .scale(duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: 14),
        Text(
          'خیلی ممنون از امتیازت! 💖',
          textAlign: TextAlign.center,
          style: AppFonts.vazirmatn(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppGradients.sunset,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.monetization_on_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 6),
                  Text(
                    '+۵۰ سکه هدیه به حساب شما اضافه شد!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms).scale(),
        const SizedBox(height: 16),
      ],
    );
  }
}
