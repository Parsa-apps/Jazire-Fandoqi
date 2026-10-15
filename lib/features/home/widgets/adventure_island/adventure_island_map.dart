import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/app_fonts.dart';
import '../../../../app/island_world_style.dart';
import '../../../../core/audio_service.dart';
import '../../../../core/game_data.dart';
import 'adventure_island_painter.dart';
import 'adventure_island_hero.dart';

class AdventureIslandMap extends StatefulWidget {
  final VoidCallback? onOpenStageMap;
  const AdventureIslandMap({super.key, this.onOpenStageMap});

  @override
  State<AdventureIslandMap> createState() => _AdventureIslandMapState();
}

class _AdventureIslandMapState extends State<AdventureIslandMap> with TickerProviderStateMixin {
  late ScrollController _scrollCtrl;
  late AnimationController _worldAnim;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()..addListener(() {
      setState(() => _scrollOffset = _scrollCtrl.offset);
    });
    _worldAnim = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _worldAnim.dispose();
    super.dispose();
  }

  void _go(String route) {
    HapticFeedback.lightImpact();
    AudioService.select();
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // Map is roughly 4 screens tall
    final mapHeight = MediaQuery.of(context).size.height * 4.0;
    final topInset = MediaQuery.of(context).padding.top + 80;

    return Container(
      color: IslandWorldPalette.skyMist,
      child: Stack(
        children: [
          // Scrolling content
          SingleChildScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: mapHeight + topInset + 200,
              width: w,
              child: Stack(
                children: [
                  // The continuous island ground and paths
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _worldAnim,
                      builder: (context, _) => CustomPaint(
                        painter: AdventureIslandPainter(
                          progress: _worldAnim.value,
                          scrollOffset: _scrollOffset,
                        ),
                      ),
                    ),
                  ),

                  // Interactive landmarks
                  _buildRegionTitle(w, mapHeight * 0.1, 'ساحل سرگرمی', IslandWorldPalette.ocean),
                  _buildLandmark(w * 0.25, mapHeight * 0.15, '🎪', 'بازی‌های تازه', '/games-carnival', IslandWorldPalette.rose, mapHeight),
                  _buildLandmark(w * 0.7, mapHeight * 0.22, '🫧', 'حباب‌ترکان', '/bubble_pop', IslandWorldPalette.sky, mapHeight),
                  _buildLandmark(w * 0.3, mapHeight * 0.28, '⭐', 'ستاره‌گیری', '/star_catch', IslandWorldPalette.honey, mapHeight),
                  
                  _buildRegionTitle(w, mapHeight * 0.35, 'کارگاه خلاقیت', IslandWorldPalette.lavender),
                  _buildLandmark(w * 0.65, mapHeight * 0.40, '🎨', 'دفتر نقاشی', '/game/نقاشی', IslandWorldPalette.coral, mapHeight),
                  _buildLandmark(w * 0.25, mapHeight * 0.46, '🧪', 'آزمایشگاه رنگ', '/game/رنگ‌ها', IslandWorldPalette.sky, mapHeight),
                  _buildLandmark(w * 0.75, mapHeight * 0.52, '🧩', 'پازل', '/game/پازل', IslandWorldPalette.honey, mapHeight),
                  
                  _buildRegionTitle(w, mapHeight * 0.60, 'جنگل ریاضی', IslandWorldPalette.foliageDeep),
                  _buildLandmark(w * 0.3, mapHeight * 0.65, '🏎️', 'مسابقه ریاضی', '/game/مسابقه ریاضی', IslandWorldPalette.rose, mapHeight),
                  _buildLandmark(w * 0.7, mapHeight * 0.71, '🕒', 'ساعت', '/game/ساعت', IslandWorldPalette.sky, mapHeight),
                  _buildLandmark(w * 0.25, mapHeight * 0.77, '🐊', 'تمساح مقایسه', '/game/تمساح', IslandWorldPalette.foliage, mapHeight),

                  _buildRegionTitle(w, mapHeight * 0.85, 'روستای الفبا', IslandWorldPalette.success),
                  _buildLandmark(w * 0.75, mapHeight * 0.90, '🔤', 'حروف فارسی', '/game/الفبا', IslandWorldPalette.honey, mapHeight),
                  _buildLandmark(w * 0.25, mapHeight * 0.96, '📖', 'قصه‌ها', '/stories', IslandWorldPalette.ocean, mapHeight),

                  // The main character as the guide
                  Positioned(
                    top: mapHeight * 0.96 - 150,
                    left: w * 0.5 - 70,
                    child: AdventureIslandHero(progress: _worldAnim.value),
                  ),
                ],
              ),
            ),
          ),
          
          // Sky/Clouds overlay at top (parallax)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _worldAnim,
                builder: (context, _) => CustomPaint(
                  painter: CloudsOverlayPainter(progress: _worldAnim.value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionTitle(double w, double y, String title, Color color) {
    return Positioned(
      top: y,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            title,
            style: AppFonts.kids(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandmark(double x, double y, String emoji, String title, String route, Color color, double mapH) {
    return Positioned(
      top: y,
      left: x - 50,
      child: _LandmarkWidget(
        emoji: emoji,
        title: title,
        color: color,
        onTap: () => _go(route),
      ),
    );
  }
}

class _LandmarkWidget extends StatefulWidget {
  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _LandmarkWidget({
    required this.emoji,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  State<_LandmarkWidget> createState() => _LandmarkWidgetState();
}

class _LandmarkWidgetState extends State<_LandmarkWidget> with SingleTickerProviderStateMixin {
  late AnimationController _jumpCtrl;
  
  @override
  void initState() {
    super.initState();
    _jumpCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }
  
  @override
  void dispose() {
    _jumpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _jumpCtrl.forward(from: 0).then((_) => widget.onTap());
      },
      child: AnimatedBuilder(
        animation: _jumpCtrl,
        builder: (context, child) {
          final jumpY = sin(_jumpCtrl.value * pi) * -15;
          final scale = 1.0 + sin(_jumpCtrl.value * pi) * 0.1;
          return Transform.translate(
            offset: Offset(0, jumpY),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: widget.color, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.title,
                style: AppFonts.kids(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
