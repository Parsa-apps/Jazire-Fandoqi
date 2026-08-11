import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../../core/game_launch.dart';
import '../../domain/entities/game_stage.dart';
import '../../shared/widgets/fandoghi_v2.dart';
import 'painters/path_painter.dart';
import 'painters/map_background_painter.dart';
import 'widgets/premium_stage_node.dart';

/// ═══════════════════════════════════════════════
/// 🗺️ STAGE MAP — Winding Path Level Select
/// Beautiful scrolling map with curved path
/// ═══════════════════════════════════════════════
class StageMapScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const StageMapScreen({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<StageMapScreen> createState() => _StageMapState();
}

class _StageMapState extends ConsumerState<StageMapScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollCtrl;
  late AnimationController _animCtrl;

  // فاز ۵۸: نقشه ۵۰ مرحله‌ای با مسیر مارپیچ واقعی (تولید برنامه‌ای)
  late final List<_StageData> _stages = _generateStages();

  static const int stageCount = 50;

  static List<_StageData> _generateStages() {
    const themes = <(String, String, String)>[
      ('شروع ماجرا', '🌱', 'الفبا'),
      ('حروف الفبا', '🔤', 'الفبا'),
      ('اعداد جادویی', '🔢', 'اعداد'),
      ('رنگین‌کمان', '🌈', 'رنگ‌ها'),
      ('جنگل حیوانات', '🦁', 'حیوانات'),
      ('شهر فکری', '🧠', 'حافظه'),
      ('حباب‌ترکان', '🫧', 'حباب‌ترکان'),
      ('مسابقه بزرگ', '🏆', 'مسابقه'),
      ('ستاره‌گیری', '⭐', 'ستاره‌گیری'),
      ('دنیای احساسات', '😊', 'احساسات'),
      ('کارگاه خلاقیت', '🎨', 'نقاشی'),
      ('قصر قهرمان', '👑', 'مسابقه'),
      ('آزمایشگاه رنگ', '🧪', 'آزمایشگاه رنگ'),
      ('جزیره پازل', '🧩', 'پازل'),
      ('آسمان اعداد', '🔢', 'اعداد'),
      ('جنگل الگوها', '🌀', 'الگو'),
      ('صدای جنگل', '🎧', 'صدا'),
      ('بدن من', '🧍', 'بدن'),
      ('جزیره‌ی من', '🏝️', 'جزیره‌سازی'),
      ('ماشین ریاضی', '🏎️', 'مسابقه'),
      ('قصه‌های فندقی', '📖', 'داستان'),
      ('شهر مشاغل', '👷', 'شغل‌ها'),
      ('باغ میوه', '🍎', 'میوه‌ها'),
      ('قلعه حافظه', '🏰', 'حافظه'),
      ('ستاره‌های طلایی', '🌟', 'ستاره‌گیری'),
    ];
    final stages = <_StageData>[];
    for (var i = 0; i < stageCount; i++) {
      final theme = themes[i % themes.length];
      // مسیر مارپیچ: X با موج سینوسی بین دو لبه می‌چرخد
      final relX = i.isEven ? 0.22 : 0.74;
      final relY = i / (stageCount - 1) * 0.92 + 0.04;
      stages.add(_StageData(
        i + 1,
        i == 0 ? 'شروع ماجرا' : '${theme.$1} ${i + 1}',
        theme.$2,
        theme.$3,
        relX,
        relY,
      ));
    }
    return stages;
  }

  // Computed path points (screen coordinates)
  List<Offset> _pathPoints = [];
  double _computedWidth = 0;

  double get _mapHeight => _stages.length * 160.0 + 300;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()..addListener(_onScroll);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Compute path points after layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _computePathPoints();
      _scrollToCurrentStage();
    });
  }

  void _onScroll() {
    if (mounted) setState(() {});
  }

  void _computePathPoints() {
    final w = MediaQuery.of(context).size.width;
    _computedWidth = w;
    _pathPoints = _stages.map((s) {
      return Offset(s.relX * w, s.relY * _mapHeight);
    }).toList();
    if (mounted) setState(() {});
  }

  void _scrollToCurrentStage() {
    final currentIdx = GameData.currentStage - 1;
    if (currentIdx > 0 && _scrollCtrl.hasClients) {
      final targetY = (currentIdx * 160.0 - 200).clamp(0.0, _scrollCtrl.position.maxScrollExtent).toDouble();
      _scrollCtrl.animateTo(
        targetY,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // فاز ۳: واکنش به وضعیت از طریق Riverpod
    ref.watch(gameStateProvider);
    final w = MediaQuery.of(context).size.width;
    final totalH = _mapHeight;
    if (_computedWidth != w) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _computedWidth != w) _computePathPoints();
      });
    }

    return AnimatedBuilder(
      animation: _animCtrl,
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
              SingleChildScrollView(
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
    return (completed / _stages.length).clamp(0.0, 1.0).toDouble();
  }

  List<Widget> _buildStageNodes(double w, double totalH) {
    return _stages.asMap().entries.map((entry) {
      final i = entry.key;
      final stage = entry.value;
      final nodeW = 72.0;
      final nodeH = 90.0;

      final stageId = 'stage_${stage.number}';
      StageState state;
      if (GameData.isStageCompleted(stageId)) {
        state = StageState.completed;
      } else if (i + 1 == GameData.currentStage) {
        state = StageState.current;
      } else {
        state = StageState.locked;
      }

                        return Positioned(
        left: stage.relX * w - nodeW / 2,
        top: stage.relY * totalH - nodeH / 2,
        child: PremiumStageNode(
          stageNumber: stage.number,
          title: stage.title,
          emoji: stage.emoji,
          state: state,
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
                if (!widget.embedded)
                  _glassBtn(Icons.arrow_back_rounded, () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  })
                else
                  const SizedBox(width: 44),
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
                        style: AppFonts.vazirmatn(
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
    final allCompleted = GameData.currentStage > _stages.length;
    final idx = (GameData.currentStage - 1).clamp(0, _stages.length - 1).toInt();
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
                  allCompleted
                      ? 'همه مراحل را بردی! 🏆'
                      : 'مرحله بعد: ${currentStage.title}',
                  style: AppFonts.vazirmatn(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  allCompleted
                      ? 'تو قهرمان نقشه‌ای!'
                      : '${currentStage.emoji} ${currentStage.gameName} رو بازی کن!',
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
    if (stage.number > GameData.currentStage) {
      FandoghiCoach.judge('این مرحله هنوز قفل است؛ اول مرحله‌های قبلی را با هم کامل کنیم 🔒');
      return;
    }
    FandoghiCoach.instruction('این مرحله را انتخاب کردی! آماده‌ای با فندقی شروع کنیم؟ 🗺️');

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
            Image.asset(
              'assets/premium/star_catch_icon.png',
              width: 70,
              height: 70,
            ),
            const SizedBox(height: 12),
            Text(
              stage.title,
              style: AppFonts.vazirmatn(
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
                Navigator.pushNamed(
                  context,
                  '/game/${stage.gameName}',
                  arguments: GameLaunch(
                    gameName: stage.gameName,
                    stageId: stage.stage.id,
                    stageNumber: stage.stage.number,
                  ),
                );
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

  /// نمای Domain از مرحله — موجودیت [GameStage] منبع حقیقت پیشرفت نقشه است.
  GameStage get stage => GameStage(
        id: 'stage_$number',
        number: number,
        isCompleted: GameData.isStageCompleted('stage_$number'),
        starsEarned: GameData.isStageCompleted('stage_$number') ? 3 : 0,
      );
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
