import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import '../../app/app_colors.dart';
import '../../core/audio_service.dart';
import '../../core/game_data.dart';
import '../../core/logger_service.dart';
import 'painters/sky_painter.dart';
import 'painters/water_painter.dart';
import 'painters/island_painter.dart';
import 'widgets/floating_platform.dart';
import 'island_professional_features.dart';

/// ═══════════════════════════════════════════════
/// 🏝️ LEARNING ISLAND — Custom Painted World
/// A magical floating island with game platforms
/// ═══════════════════════════════════════════════
class LearningIsland extends StatefulWidget {
  final bool embedded;

  const LearningIsland({
    super.key,
    this.embedded = false,
  });

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
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveScale = (screenWidth / 360).clamp(0.85, 1.3);
    final textScale = GameData.textScale.clamp(0.85, 1.4);

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

              // ─── PROFESSIONAL PROGRESS BAR (Feature 29) ───
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.2),
                        blurRadius: 16,
                        spreadRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (GameData.currentIsland + 1) / ((GameData.maxStageCount ~/ 3) + 1),
                          backgroundColor: Colors.white.withOpacity(0.15),
                          // یک رنگ از گرادیان اصلی — valueColor فقط Color می‌پذیرد، نه Shader
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBA68C8)),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${((GameData.currentIsland + 1) / ((GameData.maxStageCount ~/ 3) + 1) * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── PROFESSIONAL FOOTER (Feature 36) ───
              if (!widget.embedded)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'کُدَک ایران — جزیره یادگیری',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Color(0xFFFFA726), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'حرفه‌ای',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ─── PROFESSIONAL GLASS HEADER (Feature 1-10) ───
              if (!widget.embedded)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 4,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Back button with glow
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                AudioService.tap();
                                LoggerService.event(event: 'island_back_tap');
                                Navigator.pop(context);
                              },
                              onLongPress: () {
                                HapticFeedback.mediumImpact();
                                AudioService.select();
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF6C5CE7).withOpacity(0.6),
                                      const Color(0xFFBA68C8).withOpacity(0.4),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6C5CE7).withOpacity(0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ).animate().fadeIn(duration: 400.ms).scale(duration: 400.ms, curve: Curves.elasticOut),
                            ),
                            const Spacer(),
                            // Professional title with shimmer
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'جزیره یادگیری 🏝️',
                                    textAlign: TextAlign.center,
                                    style: AppFonts.vazirmatn(
                                      color: Colors.white,
                                      fontSize: (18 * textScale).clamp(14, 28),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFF6C5CE7).withOpacity(0.5),
                                          blurRadius: 12,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  ).animate().shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.4)).fadeIn(duration: 600.ms),
                                  const SizedBox(height: 2),
                                  // Professional breadcrumbs (Feature 35)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C5CE7).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3), width: 1),
                                    ),
                                    child: Text(
                                      'جزیره ${GameData.currentIsland + 1} از ${(GameData.maxStageCount ~/ 3) + 1}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: (11 * textScale).clamp(9, 16),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Professional island number badge (Feature 30)
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFFA726).withOpacity(0.7),
                                    const Color(0xFFF06292).withOpacity(0.6),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFA726).withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${GameData.currentIsland + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: (16 * textScale).clamp(12, 22),
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 300.ms, duration: 500.ms).scale(delay: 300.ms, duration: 500.ms, curve: Curves.elasticOut),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── FLOATING PLATFORMS ───────────────────
  Widget _glassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

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
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              AudioService.tap();
              LoggerService.event(event: 'island_platform_tap', properties: {'platform': p.name, 'route': p.route});
              Navigator.pushNamed(context, p.route);
            },
            onLongPress: () {
              HapticFeedback.heavyImpact();
              AudioService.select();
              LoggerService.event(event: 'island_platform_long_press', properties: {'platform': p.name});
            },
            onDoubleTap: () {
              AudioService.select();
              LoggerService.event(event: 'island_platform_double_tap', properties: {'platform': p.name});
            },
            child: FloatingPlatform(
              emoji: p.emoji,
              name: p.name,
              color: p.color,
              floatDelay: p.delay.toDouble(),
              onTap: () => Navigator.pushNamed(context, p.route),
            ),
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
