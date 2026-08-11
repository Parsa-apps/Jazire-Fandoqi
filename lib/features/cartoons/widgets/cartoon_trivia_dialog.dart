import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/shared/widgets/fandoghi_v2.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🧠 CARTOON TRIVIA DIALOG — معما و هوش فندقی بعد از کارتون
/// ═══════════════════════════════════════════════════════════════
class CartoonTriviaDialog extends StatefulWidget {
  final Cartoon cartoon;
  final CartoonEpisode episode;

  const CartoonTriviaDialog({
    super.key,
    required this.cartoon,
    required this.episode,
  });

  static Future<void> show(
    BuildContext context, {
    required Cartoon cartoon,
    required CartoonEpisode episode,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CartoonTriviaDialog(
        cartoon: cartoon,
        episode: episode,
      ),
    );
  }

  @override
  State<CartoonTriviaDialog> createState() => _CartoonTriviaDialogState();
}

class _CartoonTriviaDialogState extends State<CartoonTriviaDialog> {
  int? _selectedIndex;
  bool _answered = false;
  bool _isCorrect = false;

  String get _question {
    if (widget.episode.triviaQuestion.isNotEmpty) {
      return widget.episode.triviaQuestion;
    }
    return 'در کارتون «${widget.cartoon.title}»، قهرمان اصلی چه کاری انجام داد؟';
  }

  List<String> get _options {
    if (widget.episode.triviaOptions.isNotEmpty) {
      return widget.episode.triviaOptions;
    }
    return [
      'به دوستانش کمک کرد و راستگو بود 🌟',
      'قهر کرد و تنها نشست 😢',
      'به حرف بزرگ‌ترها گوش نکرد ❌',
    ];
  }

  int get _correctIndex => widget.episode.triviaCorrectIndex;

  void _onSelect(int index) {
    if (_answered) return;
    HapticFeedback.mediumImpact();

    final correct = index == _correctIndex;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      _isCorrect = correct;
    });

    if (correct) {
      GameData.addCoins(10);
      GameData.addStars(1);
      // Unlock cartoon sticker
      final stickerKey = 'sticker_${widget.cartoon.id}';
      if (!GameData.hasItem(stickerKey)) {
        GameData.buyItem(stickerKey, 0);
      }
      FandoghiCoach.celebrate('آفرین باهوش من! ۱۰ سکه و استیکر «${widget.cartoon.title}» گرفتی! 🎉');
    } else {
      FandoghiCoach.say('اشکالی نداره عزیزم! دوباره با دقت به کارتون نگاه کن 🌱', mood: FandoghiMood.thinking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: widget.cartoon.themeColor.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: widget.cartoon.themeColor.withOpacity(0.25),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Mascot
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FandoghiV2(
                  size: 75,
                  animate: true,
                  mood: _answered
                      ? (_isCorrect ? FandoghiMood.celebrating : FandoghiMood.thinking)
                      : FandoghiMood.excited,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: widget.cartoon.themeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '💡 معمای فندقی • ${widget.cartoon.title}',
                style: TextStyle(
                  color: widget.cartoon.themeColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Question Text
            Text(
              _question,
              textAlign: TextAlign.center,
              style: AppFonts.vazirmatn(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            // Options
            ...List.generate(_options.length, (i) {
              final isSelected = _selectedIndex == i;
              final isTarget = i == _correctIndex;

              Color bg = Colors.black.withOpacity(0.04);
              Color border = Colors.black12;

              if (_answered) {
                if (isTarget) {
                  bg = AppColors.success.withOpacity(0.2);
                  border = AppColors.success;
                } else if (isSelected) {
                  bg = Colors.red.withOpacity(0.15);
                  border = Colors.red;
                }
              } else if (isSelected) {
                bg = widget.cartoon.themeColor.withOpacity(0.15);
                border = widget.cartoon.themeColor;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _answered ? null : () => _onSelect(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: border.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: border,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _options[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (_answered && isTarget)
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // Close / Done button
            if (_answered)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCorrect ? AppColors.success : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isCorrect ? 'هورااا! دریافت جایزه 🎁' : 'ادامه',
                      style: AppFonts.vazirmatn(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale()
            else
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'انصراف',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
