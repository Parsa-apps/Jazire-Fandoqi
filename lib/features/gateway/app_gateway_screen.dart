import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amoozesh_fandoghi/app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import 'package:amoozesh_fandoghi/core/fandoghi_coach.dart';
import 'package:amoozesh_fandoghi/core/game_data.dart';
import 'package:amoozesh_fandoghi/features/cartoons/widgets/cartoon_rating_dialog.dart';
import 'package:amoozesh_fandoghi/shared/widgets/fandoghi_v2.dart';
import 'package:amoozesh_fandoghi/shared/widgets/star_field.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🚀 APP GATEWAY SCREEN — دروازه ورود و انتخاب دوگانه بخش‌های اپ
/// (۱. مشاهده کارتون‌های جذاب کودکان  |  ۲. ورود به دنیای بازی و آموزش)
/// ═══════════════════════════════════════════════════════════════
class AppGatewayScreen extends StatefulWidget {
  const AppGatewayScreen({super.key});

  @override
  State<AppGatewayScreen> createState() => _AppGatewayScreenState();
}

class _AppGatewayScreenState extends State<AppGatewayScreen> {
  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.say(
          'سلام ${GameData.childName.isNotEmpty ? GameData.childName : 'قهرمان کوچولو'}! خوش اومدی! دوست داری کارتون ببینی یا بازی کنی؟ 🌰🎉',
          mood: FandoghiMood.excited,
          duration: const Duration(seconds: 5),
        );
      }
    });
  }

  void _openCartoons() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushNamed('/cartoons').then((_) => setState(() {}));
  }

  void _openGames() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushNamed('/home').then((_) => setState(() {}));
  }

  Future<void> _parentGate(BuildContext context) async {
    final n1 = Random().nextInt(10) + 1;
    final n2 = Random().nextInt(10) + 1;
    final controller = TextEditingController();
    var errorText = '';

    final approved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🔒 ورود والدین'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'این بخش برای بزرگ‌ترهاست. لطفاً پاسخ دهید:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$n1 + $n2 = ?',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'جواب',
                  errorText: errorText.isEmpty ? null : errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                if (int.tryParse(controller.text) == n1 + n2) {
                  Navigator.pop(dialogContext, true);
                } else {
                  setDialogState(() => errorText = 'جواب نادرست است.');
                }
              },
              child: const Text('تایید'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (approved == true && context.mounted) {
      await Navigator.pushNamed(context, '/parent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.nightSky,
        ),
        child: Stack(
          children: [
            // Ambient Star Field
            const StarFieldBackground(starCount: 60),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Top Profile & Parent Bar
                  _buildTopBar(),

                  // Heading & Prompt
                  _buildHeading(),

                  // Two Major Gate Cards (Cartoons & Games)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          // 1. CARTOONS SECTION CARD
                          _buildCartoonsCard(),

                          const SizedBox(height: 20),

                          // 2. GAMES & LEARNING SECTION CARD
                          _buildGamesCard(),

                          const SizedBox(height: 24),

                          // Bottom Quick Action Badges
                          _buildBottomBadges(),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          // Child Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: Center(
              child: Text(
                GameData.avatar,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سلام ${GameData.childName.isNotEmpty ? GameData.childName : 'دوست کوچولو'}! 👋',
                  style: AppFonts.vazirmatn(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'لول ${GameData.level} • ${GameData.getLevelName()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),

          // Coins & Stars Badges
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statBadge(Icons.star_rounded, '${GameData.stars}', Colors.amber),
              const SizedBox(width: 8),
              _statBadge(Icons.monetization_on_rounded, '${GameData.coins}', Colors.orangeAccent),
              const SizedBox(width: 8),
              // Parent Panel Icon
              GestureDetector(
                onTap: () => _parentGate(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.lock_outline_rounded, color: Colors.white70, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Text(
            'ماجراجویی امروزت رو انتخاب کن! 🌟',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'کارتون‌های دیدنی یا بازی‌های هیجان‌انگیز؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  // ─── ۱. کارتون‌کده و سینما فندقی ───────────────────
  Widget _buildCartoonsCard() {
    return GestureDetector(
      onTap: _openCartoons,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF5E3A),
              Color(0xFFFF2A6D),
              Color(0xFF9B51E0),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF2A6D).withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Decorative background patterns
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row (Badge + Cinema Icon)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Text('🔥', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 6),
                            Text(
                              'جدید • صدها انیمیشن شاد',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text('🍿🎬', style: TextStyle(fontSize: 28)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Main Content & Mascot Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'کارتون‌کده و سینما',
                              style: AppFonts.vazirmatn(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'شکرستان • پهلوانان • سگ‌های نگهبان • باب اسفنجی • دیرین دیرین و کارتون‌های موزیکال',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Animated Cartoon Popcorn Character
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🦁', style: TextStyle(fontSize: 44)),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.1, 1.1), duration: 1600.ms),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Action Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFFF2A6D), size: 26),
                        const SizedBox(width: 8),
                        Text(
                          'تماشای کارتون‌های جذاب ▶',
                          style: AppFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFF2A6D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.15);
  }

  // ─── ۲. دنیای بازی و یادگیری فندقی ───────────────────
  Widget _buildGamesCard() {
    return GestureDetector(
      onTap: _openGames,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4834D4),
              Color(0xFF6C5CE7),
              Color(0xFF00CEC9),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row (Badge + Games Icon)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Text('🏆', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 6),
                            Text(
                              '۵۰ مرحله • بازی‌های فکری',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text('🎮✨', style: TextStyle(fontSize: 28)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Main Content & Mascot Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'دنیای بازی و آموزش',
                              style: AppFonts.vazirmatn(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'الفبا • نقاشی • مسابقه ریاضی • حافظه • جزیره جادویی و آزمون‌های هوش',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Animated Fandoghi Mascot
                      const FandoghiV2(
                        size: 74,
                        animate: true,
                        mood: FandoghiMood.excited,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: 0, end: -6, duration: 1500.ms, curve: Curves.easeInOut),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Action Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rocket_launch_rounded, color: Color(0xFF6C5CE7), size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'ورود به بازی‌ها و یادگیری 🚀',
                          style: AppFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF6C5CE7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 500.ms).slideY(begin: 0.15);
  }

  Widget _buildBottomBadges() {
    return Row(
      children: [
        // 5-Star Rating Incentive
        Expanded(
          child: GestureDetector(
            onTap: () => CartoonRatingDialog.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('⭐', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'ثبت ۵ ستاره (+۵۰ سکه)',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
