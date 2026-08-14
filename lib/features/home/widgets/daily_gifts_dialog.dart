import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../../../shared/widgets/premium/particle_celebration.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎁 دیالوگ هدایا و صندوق‌های جادویی روزانه
/// ═══════════════════════════════════════════════════════════════
void showDailyGiftsDialog(BuildContext context, {VoidCallback? onRewardClaimed}) {
  HapticFeedback.heavyImpact();
  AudioService.star();
  FandoghiCoach.celebrate('وقت دریافت هدایای طلایی رسیده قهرمان! 🎁✨');

  showDialog(
    context: context,
    builder: (ctx) => _DailyGiftsDialogWidget(onRewardClaimed: onRewardClaimed),
  );
}

class _DailyGiftsDialogWidget extends StatefulWidget {
  final VoidCallback? onRewardClaimed;
  const _DailyGiftsDialogWidget({this.onRewardClaimed});

  @override
  State<_DailyGiftsDialogWidget> createState() => _DailyGiftsDialogWidgetState();
}

class _DailyGiftsDialogWidgetState extends State<_DailyGiftsDialogWidget> {
  bool _claimedToday = false;
  bool _showConfetti = false;
  int _rewardCoins = 0;
  int _rewardStars = 0;

  void _claimGift() {
    HapticFeedback.heavyImpact();
    AudioService.win();

    setState(() {
      _claimedToday = true;
      _rewardCoins = 50 + Random().nextInt(50);
      _rewardStars = 10 + Random().nextInt(10);
      _showConfetti = true;
    });

    GameData.addCoins(_rewardCoins);
    GameData.addStars(_rewardStars);
    widget.onRewardClaimed?.call();

    FandoghiCoach.celebrate('هوراا! $_rewardCoins سکه و $_rewardStars ستاره به کوله‌پشتیت اضافه شد! 🌟🪙');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConfettiOverlay(
        isActive: _showConfetti,
        onComplete: () => setState(() => _showConfetti = false),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD35400).withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // تصویر صندوقچه هدیه با انیمیشن
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFB300), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/mascot/gift_box_3d_clean.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1500.ms)
                  .rotate(begin: -0.04, end: 0.04, duration: 1500.ms),

              const SizedBox(height: 16),

              Text(
                '🎁 صندوقچه هدایای امروز',
                style: AppFonts.vazirmatn(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF5A3A1B),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _claimedToday
                    ? 'تبریک! جایزه امروزت رو گرفتی 🎉'
                    : 'هر روز با باز کردن برنامه، جایزه‌های شگفت‌انگیز بگیر!',
                textAlign: TextAlign.center,
                style: AppFonts.vazirmatn(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8A6A45),
                ),
              ),

              const SizedBox(height: 20),

              if (_claimedToday) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 6),
                          Text(
                            '+${PersianDigits.toFa(_rewardCoins)} سکه',
                            style: AppFonts.vazirmatn(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      Container(width: 2, height: 28, color: Colors.grey.shade300),
                      Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 6),
                          Text(
                            '+${PersianDigits.toFa(_rewardCoins)} ستاره',
                            style: AppFonts.vazirmatn(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFF57F17),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                    'خیلی ممنون! 🚀',
                    style: AppFonts.vazirmatn(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ] else ...[
                // دکمه باز کردن صندوق
                GestureDetector(
                  onTap: _claimGift,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5722).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'باز کردن صندوقچه جادویی ✨',
                        style: AppFonts.vazirmatn(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'بعداً باز می‌کنم',
                    style: AppFonts.vazirmatn(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
