import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/growth/persian_digits.dart';

/// 🎉 صفحه/دیالوگِ جشنِ پاداشِ سه‌بعدی (مطابقِ طرحِ مرجع `05_reward_phone.png`).
Future<void> showTodayCompleteSheet(
  BuildContext context, {
  int bonusStars = 20,
}) async {
  HapticFeedback.heavyImpact();
  AudioService.win();

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext ctx) => _RewardCelebrationCard(
      bonusStars: bonusStars,
    ),
  );
}

class _RewardCelebrationCard extends StatelessWidget {
  const _RewardCelebrationCard({required this.bonusStars});

  final int bonusStars;

  static const String rewardAsset = 'assets/theme_v2/squirrel_reward.webp';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF1A6978),
                  Color(0xFF0D3D48),
                  Color(0xFF07232B),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFFFD54F),
                width: 3,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFFFFD54F).withOpacity(0.28),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // ربانِ طلاییِ بالای کارت: «آفرین!»
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xFFFFF59D),
                        Color(0xFFFFCA28),
                        Color(0xFFFF8F00),
                      ],
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Text(
                        'آفرین!',
                        style: AppFonts.kids(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4A2500),
                        ),
                      ),
                      Opacity(
                        opacity: 0.0,
                        child: Text(
                          'آفرین قهرمان!',
                          style: AppFonts.kids(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // تصویرِ سه‌بعدیِ سنجابِ فندقی با ستارهٔ طلایی و کاغذرنگی
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: 210,
                    height: 210,
                    child: Image.asset(
                      rewardAsset,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('🐿️⭐', style: TextStyle(fontSize: 72)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'تو خیلی باهوشی!',
                  textAlign: TextAlign.center,
                  style: AppFonts.kids(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'همهٔ کارهای امروزت را انجام دادی!',
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB2EBF2),
                  ),
                ),
                const SizedBox(height: 12),
                // نشانِ ستارهٔ جایزه: `⭐ +۲۰`
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFD54F),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFFFD54F),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('⭐', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        '+${PersianDigits.toFa(bonusStars)}',
                        style: AppFonts.kids(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFF59D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // دکمهٔ سه‌بعدیِ سبزِ «ادامه»
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      AudioService.select();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Color(0xFFA5D6A7),
                            Color(0xFF4CAF50),
                            Color(0xFF2E7D32),
                          ],
                        ),
                        border: Border.all(color: Colors.white, width: 2.2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFF1B5E20).withOpacity(0.55),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Text(
                            'ادامه',
                            style: AppFonts.kids(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Opacity(
                            opacity: 0.0,
                            child: Text(
                              'عالیه! 🌈',
                              style: AppFonts.kids(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
