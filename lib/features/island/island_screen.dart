import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_colors.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/fandoghi_v2.dart';
import 'painters/sky_painter.dart';
import 'painters/water_painter.dart';
import 'painters/island_painter.dart';
import 'widgets/floating_platform.dart';

/// ═══════════════════════════════════════════════
/// 🏝️ LEARNING ISLAND — Custom Painted World
/// A magical floating island with game platforms
/// ═══════════════════════════════════════════════
class LearningIsland extends StatefulWidget {
  const LearningIsland({super.key});
  @override
  State<LearningIsland> createState() => _IslandState();
}

class _IslandState extends State<LearningIsland>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _worldCtrl;  // Main world animation
  late AnimationController _floatCtrl;  // Island floating

  @override
  void initState() {
    super.initState();
    _worldCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _worldCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_worldCtrl, _floatCtrl]),
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              // ─── LAYER 1: SKY ───
              CustomPaint(
                painter: SkyPainter(
                  progress: _worldCtrl.value,
                ),
                size: Size.infinite,
              ),

              // ─── LAYER 3: WATER ───
              CustomPaint(
                painter: WaterPainter(
                  progress: _worldCtrl.value,
                  waterLevel: 0.58,
                ),
                size: Size.infinite,
              ),

              // ─── LAYER 4: MAIN ISLAND ───
              CustomPaint(
                painter: IslandPainter(
                  progress: _worldCtrl.value,
                  floatY: sin(_floatCtrl.value * pi) * 6,
                ),
                size: Size.infinite,
              ),

              // ─── LAYER 5: FLOATING PLATFORMS ───
              _buildPlatforms(context),

              // ─── LAYER 7: UI OVERLAY ───
              _buildUI(context),
            ],
          ),
        );
      },
    );
  }

  // ─── FLOATING PLATFORMS ───────────────────
  Widget _buildPlatforms(BuildContext context) {
    final floatY = sin(_floatCtrl.value * pi) * 6;
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final platforms = [
      _PlatformData('🔤', 'الفبا', '/game/الفبا', const Color(0xFFE040FB), 0, 0.28, 0.22),
      _PlatformData('🔢', 'اعداد', '/game/اعداد', const Color(0xFF40C4FF), 1, 0.72, 0.20),
      _PlatformData('🎨', 'رنگ‌ها', '/game/رنگ‌ها', const Color(0xFFFFD740), 2, 0.18, 0.42),
      _PlatformData('🧠', 'حافظه', '/memory_match', const Color(0xFF69F0AE), 3, 0.82, 0.40),
      _PlatformData('🫧', 'حباب‌ترکان', '/bubble_pop', const Color(0xFFFF8A65), 4, 0.35, 0.50),
      _PlatformData('⭐', 'ستاره‌گیری', '/star_catch', const Color(0xFFFF5252), 5, 0.65, 0.48),
    ];

    return Stack(
      children: platforms.map((p) {
        final px = w * p.relX;
        final py = h * p.relY + floatY * (1 + p.delay * 0.1);
        
        return Positioned(
          left: px - 40,
          top: py - 50,
          child: FloatingPlatform(
            emoji: p.emoji,
            name: p.name,
            route: p.route,
            color: p.color,
            floatDelay: p.delay,
            onTap: () => Navigator.pushNamed(context, p.route),
          ),
        ).animate().fadeIn(
          delay: Duration(milliseconds: 300 + p.delay.toInt() * 200),
          duration: 600.ms,
        ).scale(
          begin: const Offset(0.5, 0.5),
          delay: Duration(milliseconds: 300 + p.delay.toInt() * 200),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
      }).toList(),
    );
  }

  // ─── UI OVERLAY ───────────────────────────
  Widget _buildUI(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Back button
                _glassBtn(Icons.arrow_back_rounded, () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                }),
                
                const Spacer(),
                
                // Title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Text(
                    '🏝️ جزیره یادگیری',
                    style: GoogleFonts.vazirmatn(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Stars
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${GameData.stars}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Fandoghi floating on water
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FandoghiV2(
                  size: 50,
                  animate: true,
                  mood: FandoghiMood.happy,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _getFandoghiMessage(),
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFandoghiMessage() {
    if (GameData.totalCorrect == 0) {
      return 'یکی از بازی‌ها رو انتخاب کن! 🎮';
    }
    if (GameData.successRate > 0.8) {
      return 'آفرین! عالی پیش میری! 🌟';
    }
    if (GameData.streak > 3) {
      return '${GameData.streak} روز پیاپی! ادامه بده! 🔥';
    }
    return 'هر بازی یه ماجراجوییه! ✨';
  }

  Widget _glassBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── Platform data model ────────────────────
class _PlatformData {
  final String emoji;
  final String name;
  final String route;
  final Color color;
  final int delay;
  final double relX;
  final double relY;

  _PlatformData(
    this.emoji, this.name, this.route, this.color,
    this.delay, this.relX, this.relY,
  );
}
