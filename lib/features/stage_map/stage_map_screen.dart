import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_colors.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/fandoghi_v2.dart';
import 'painters/path_painter.dart';
import 'painters/map_background_painter.dart';
import 'widgets/stage_node.dart';

/// ═══════════════════════════════════════════════
/// 🗺️ STAGE MAP — Winding Path Level Select
/// Beautiful scrolling map with curved path
/// ═══════════════════════════════════════════════
class StageMapScreen extends StatefulWidget {
  const StageMapScreen({super.key});
  @override
  State<StageMapScreen> createState() => _StageMapState();
}

class _StageMapState extends State<StageMapScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollCtrl;
  late AnimationController _animCtrl;
  late AnimationController _entryCtrl;

  // Stage definitions
  final List<_StageData> _stages = [
    _StageData(1, 'شروع ماجرا', '🌱', 'الفبا', 0.15, 0.06),
    _StageData(2, 'حروف الفبا', '🔤', 'الفبا', 0.75, 0.12),
    _StageData(3, 'اعداد جادویی', '🔢', 'اعداد', 0.25, 0.19),
    _StageData(4, 'رنگین‌کمان', '🌈', 'رنگ‌ها', 0.70, 0.26),
    _StageData(5, 'جنگل حیوانات', '🦁', 'حیوانات', 0.30, 0.33),
    _StageData(6, 'شهر فکری', '🧠', 'حافظه', 0.65, 0.40),
    _StageData(7, 'حباب‌ترکان', '🫧', 'حباب‌ترکان', 0.25, 0.47),
    _StageData(8, 'مسابقه بزرگ', '🏆', 'مسابقه', 0.70, 0.54),
    _StageData(9, 'ستاره‌گیری', '⭐', 'ستاره‌گیری', 0.30, 0.61),
    _StageData(10, 'دنیای احساسات', '😊', 'احساسات', 0.65, 0.68),
    _StageData(11, 'کارگاه خلاقیت', '🎨', 'نقاشی', 0.25, 0.75),
    _StageData(12, 'قصر قهرمان', '👑', 'مسابقه', 0.55, 0.84),
  ];

  // Computed path points (screen coordinates)
  late List<Offset> _pathPoints;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // Compute path points after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _computePathPoints();
      _scrollToCurrentStage();
    });
  }

  void _computePathPoints() {
    final w = MediaQuery.of(context).size.width;
    final totalH = _stages.length * 160.0 + 200;

    _pathPoints = _stages.map((s) {
      return Offset(s.relX * w, s.relY * totalH);
    }).toList();
  }

  void _scrollToCurrentStage() {
    final currentIdx = GameData.currentStage - 1;
    if (currentIdx > 0 && _scrollCtrl.hasClients) {
      final targetY = (currentIdx * 160.0 - 200).clamp(0.0, _scrollCtrl.position.maxScrollExtent);
      _scrollCtrl.animateTo(
        targetY,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _animCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final totalH = _stages.length * 160.0 + 300;

    return AnimatedBuilder(
      animation: Listenable.merge([_animCtrl, _entryCtrl]),
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              // ─── BACKGROUND ───
              CustomPaint(
                painter: MapBackgroundPainter(
                  scrollY: _scrollCtrl.hasClients ? _scrollCtrl.offset : 0,
                  animValue: _animCtrl.value,
                ),
                size: Size.infinite,
              ),

              // ─── SCROLLABLE MAP ───
              NotificationListener<ScrollNotification>(
                onNotification: (_) {
                  setState(() {}); // rebuild for parallax
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: totalH,
                    width: w,
                    child: Stack(
                      children: [
                        // ─── PATH ───
                        if (_pathPoints.isNotEmpty)
                          CustomPaint(
                            painter: PathPainter(
                              points: _pathPoints,
                              progress: _getPathProgress(),
                              animValue: _animCtrl.value,
                            ),
                            size: Size(w, totalH),
                          ),

                        // ─── STAGE NODES ───
                        ..._buildStageNodes(w, totalH),

                        // ─── DECORATIVE ELEMENTS ───
                        ..._buildDecorations(w, totalH),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── UI OVERLAY ───
              _buildUI(),
            ],
          ),
        );
      },
    );
  }

  double _getPathProgress() {
    // Progress based on completed stages
    final completed = GameData.completedStageCount;
    if (completed == 0) return 0;
    return completed / _stages.length;
  }

  List<Widget> _buildStageNodes(double w, double totalH) {
    return _stages.asMap().entries.map((entry) {
      final i = entry.key;
      final stage = entry.value;
      final nodeW = 72.0;
      final nodeH = 90.0;

      StageState state;
      if (i + 1 < GameData.currentStage) {
        state = StageState.completed;
      } else if (i + 1 == GameData.currentStage) {
        state = StageState.current;
      } else {
        state = StageState.locked;
      }

      return Positioned(
        left: stage.relX * w - nodeW / 2,
        top: stage.relY * totalH - nodeH / 2,
        child: StageNode(
          stageNumber: stage.number,
          title: stage.title,
          emoji: stage.emoji,
          state: state,
          route: '/game/${stage.gameName}',
          onTap: () => _onStageTap(stage),
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 200 + i * 100),
              duration: 500.ms,
            )
            .scale(
              begin: const Offset(0.5, 0.5),
              delay: Duration(milliseconds: 200 + i * 100),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
      );
    }).toList();
  }

  List<Widget> _buildDecorations(double w, double totalH) {
    final rng = Random(42);
    final decorations = <Widget>[];

    // Trees
    for (int i = 0; i < 8; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * totalH;
      final size = 20.0 + rng.nextDouble() * 15;

      // Skip if too close to path
      if (_isNearPath(x, y, 60)) continue;

      decorations.add(Positioned(
        left: x - size,
        top: y - size * 1.5,
        child: _buildTree(size),
      ));
    }

    // Flags at completed stages
    for (int i = 0; i < GameData.completedStageCount && i < _stages.length; i++) {
      final stage = _stages[i];
      decorations.add(Positioned(
        left: stage.relX * w + 25,
        top: stage.relY * totalH - 40,
        child: _buildFlag(),
      ));
    }

    return decorations;
  }

  bool _isNearPath(double x, double y, double threshold) {
    if (_pathPoints.isEmpty) return false;
    for (final p in _pathPoints) {
      if ((Offset(x, y) - p).distance < threshold) return true;
    }
    return false;
  }

  Widget _buildTree(double size) {
    return SizedBox(
      width: size * 2,
      height: size * 2.5,
      child: CustomPaint(
        painter: _TreePainter(size),
      ),
    );
  }

  Widget _buildFlag() {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, __) {
        final wave = sin(_animCtrl.value * 2 * pi * 2) * 0.15;
        return Transform.rotate(
          angle: wave,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flag
              Container(
                width: 20,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('⭐', style: TextStyle(fontSize: 8)),
                ),
              ),
              // Pole
              Container(
                width: 2,
                height: 25,
                color: const Color(0xFF795548),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── UI OVERLAY ─────────────────────────
  Widget _buildUI() {
    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _glassBtn(Icons.arrow_back_rounded, () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                }),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Text('🗺️', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'نقشه مراحل',
                        style: GoogleFonts.vazirmatn(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _buildProgressBadge(),
              ],
            ),
          ),

          const Spacer(),

          // Fandoghi guide at bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildFandoghiGuide(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBadge() {
    final completed = GameData.completedStageCount;
    final total = _stages.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 6),
          Text(
            '$completed/$total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFandoghiGuide() {
    final idx = (GameData.currentStage - 1).clamp(0, _stages.length - 1);
    final currentStage = _stages[idx];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const FandoghiV2(
            size: 45,
            animate: true,
            mood: FandoghiMood.happy,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'مرحله بعد: ${currentStage.title}',
                  style: GoogleFonts.vazirmatn(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${currentStage.emoji} ${currentStage.gameName} رو بازی کن!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'برو! 🚀',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3);
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

  void _onStageTap(_StageData stage) {
    if (stage.number > GameData.currentStage) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(stage.emoji, style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            Text(
              stage.title,
              style: GoogleFonts.vazirmatn(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'بازی: ${stage.gameName}',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (stage.number < GameData.currentStage)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                    SizedBox(width: 8),
                    Text(
                      'تکمیل شده! ✅',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/game/${stage.gameName}');
              },
              child: Text(
                stage.number < GameData.currentStage ? 'بازی مجدد 🔄' : 'شروع! 🚀',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Stage data model ───────────────────────
class _StageData {
  final int number;
  final String title;
  final String emoji;
  final String gameName;
  final double relX; // relative X position (0..1)
  final double relY; // relative Y position (0..1)

  _StageData(this.number, this.title, this.emoji, this.gameName, this.relX, this.relY);
}

// ─── Tree Painter ───────────────────────────
class _TreePainter extends CustomPainter {
  final double size;
  _TreePainter(this.size);

  @override
  void paint(Canvas canvas, Size _) {
    final s = size;
    final cx = s;
    final cy = s * 2;

    // Trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - s * 0.08, cy - s * 0.6, s * 0.16, s * 0.7),
        Radius.circular(s * 0.04),
      ),
      Paint()..color = const Color(0xFF6D4C41),
    );

    // Foliage
    final foliagePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF66BB6A),
          const Color(0xFF388E3C),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy - s * 0.8), radius: s * 0.5));

    canvas.drawCircle(Offset(cx, cy - s * 0.8), s * 0.45, foliagePaint);
    canvas.drawCircle(Offset(cx - s * 0.25, cy - s * 0.6), s * 0.3, foliagePaint);
    canvas.drawCircle(Offset(cx + s * 0.25, cy - s * 0.65), s * 0.28, foliagePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
