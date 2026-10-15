import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/app_fonts.dart';
import '../../../../app/island_world_style.dart';
import '../../../../core/audio_service.dart';
import '../../../profile/profile_editor.dart';
import '../../../stage_map/stage_map_screen.dart';
import '../daily_gifts_dialog.dart';
import '../fandoqi_hub_sheet.dart';
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

  void _openHub(HubData hub) {
    HapticFeedback.lightImpact();
    AudioService.select();
    showFandoqiHubSheet(context, hub);
  }

  void _openProfile() {
    HapticFeedback.lightImpact();
    AudioService.select();
    showProfileEditor(context);
  }

  void _openStageMap() {
    HapticFeedback.mediumImpact();
    AudioService.select();
    if (widget.onOpenStageMap != null) {
      widget.onOpenStageMap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StageMapScreen()),
      );
    }
  }

  void _openGifts() {
    showDailyGiftsDialog(context, onRewardClaimed: () {
      if (mounted) setState(() {});
    });
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

                  // ── ۶ هاب یادگیری جزیره فندقی + پروفایل ──
                  _buildRegionTitle(w, mapHeight * 0.06, 'جزیرهٔ یادگیری', IslandWorldPalette.ocean),
                  _buildLandmark(
                    w * 0.28, mapHeight * 0.12, '📖', 'فارسی',
                    () => _openHub(FandoqiHubs.farsi), IslandWorldPalette.honey,
                  ),
                  _buildLandmark(
                    w * 0.72, mapHeight * 0.20, '🔤', 'حروف',
                    () => _openHub(FandoqiHubs.lettersAndSounds), IslandWorldPalette.sky,
                  ),

                  _buildRegionTitle(w, mapHeight * 0.30, 'کارگاه دانش', IslandWorldPalette.lavender),
                  _buildLandmark(
                    w * 0.30, mapHeight * 0.36, '🧮', 'ریاضی',
                    () => _openHub(FandoqiHubs.math), IslandWorldPalette.lavender,
                  ),
                  _buildLandmark(
                    w * 0.70, mapHeight * 0.44, '🔬', 'علوم',
                    () => _openHub(FandoqiHubs.science), IslandWorldPalette.ocean,
                  ),

                  _buildRegionTitle(w, mapHeight * 0.54, 'ساحل سرگرمی', IslandWorldPalette.rose),
                  _buildLandmark(
                    w * 0.30, mapHeight * 0.60, '🎮', 'بازی‌ها',
                    () => _openHub(FandoqiHubs.games), IslandWorldPalette.coral,
                  ),
                  _buildLandmark(
                    w * 0.70, mapHeight * 0.68, '🎨', 'هنر',
                    () => _openHub(FandoqiHubs.art), IslandWorldPalette.rose,
                  ),
                  _buildLandmark(
                    w * 0.28, mapHeight * 0.76, '🎪', 'بازی‌های تازه',
                    () => _go('/games-carnival'), IslandWorldPalette.honey,
                  ),
                  _buildLandmark(
                    w * 0.72, mapHeight * 0.84, '🗺️', 'مراحل',
                    _openStageMap, IslandWorldPalette.foliage,
                  ),
                  _buildLandmark(
                    w * 0.5, mapHeight * 0.90, '🌟', 'پروفایل من',
                    _openProfile, IslandWorldPalette.success,
                  ),

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

          // دکمه‌های شناور کنارهٔ صفحه: هدیهٔ روزانه و کتابخانه
          Positioned(
            right: 10,
            bottom: 22,
            child: SafeArea(top: false, child: _buildSideButtons()),
          ),
        ],
      ),
    );
  }

  /// دکمه‌های شناور کنارهٔ صفحه: هدیهٔ روزانه و کتابخانه
  Widget _buildSideButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sideButton(
          icon: Icons.card_giftcard_rounded,
          color: const Color(0xFFE91E63),
          tooltip: 'هدیهٔ روزانه',
          onTap: _openGifts,
        ),
        const SizedBox(height: 10),
        _sideButton(
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF00897B),
          tooltip: 'کتابخانه',
          onTap: () => _go('/learning-library'),
        ),
      ],
    );
  }

  Widget _sideButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          AudioService.tap();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.35), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
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

  Widget _buildLandmark(double x, double y, String emoji, String title, VoidCallback onTap, Color color) {
    return Positioned(
      top: y,
      left: x - 50,
      child: _LandmarkWidget(
        emoji: emoji,
        title: title,
        color: color,
        onTap: onTap,
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
