import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/app_colors.dart';
import '../../../core/ai_system.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../shared/widgets/fandoghi_v2.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/star_field.dart';

/// ═══════════════════════════════════════════════
/// 📊 DASHBOARD TAB — Main Content
/// Parallax hero, daily missions, game categories
/// ═══════════════════════════════════════════════
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override
  State<DashboardTab> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardTab> {
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    GameData.changes.addListener(_onDataChanged);
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FandoghiCoach.welcome();
    });
  }

  void _onScroll() {
    if (mounted) setState(() => _scrollOffset = _scrollCtrl.offset);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GameData.changes.removeListener(_onDataChanged);
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Hero App Bar with parallax
        _buildHeroAppBar(),
        
        // Quick stats
        SliverToBoxAdapter(child: _buildQuickStats()),
        
        // Daily missions
        SliverToBoxAdapter(child: _buildDailyMissions()),
        
        // Quick games
        SliverToBoxAdapter(child: _buildQuickGames()),
        
        // Game categories
        SliverToBoxAdapter(child: _buildCategories()),
        
        // Fandoghi tip
        SliverToBoxAdapter(child: _buildFandoghiTip()),
        
        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  // ─── HERO APP BAR ─────────────────────────────
  Widget _buildHeroAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background with parallax
            Transform.translate(
              offset: Offset(0, -_scrollOffset * 0.3),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF4834D4),
                      Color(0xFF6C5CE7),
                      Color(0xFFA29BFE),
                    ],
                  ),
                ),
              ),
            ),
            
            // Floating decorative circles
            ..._buildDecorativeCircles(),
            
            // Stars overlay
            const StarFieldBackground(starCount: 25),
            
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              GameData.avatar,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سلام ${GameData.childName.isNotEmpty ? GameData.childName : 'دوست کوچولو'}! 👋',
                                style: GoogleFonts.vazirmatn(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'لول ${GameData.level} • ${GameData.getLevelName()}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Settings button
                        _glassIconButton(
                          Icons.settings_rounded,
                          () => _parentGate(context),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Stats row
                    Row(
                      children: [
                        _heroStat(Icons.star_rounded, '${GameData.stars}', 'ستاره',
                            Colors.amber),
                        const SizedBox(width: 12),
                        _heroStat(Icons.monetization_on_rounded, '${GameData.coins}', 'سکه',
                            Colors.orange),
                        const SizedBox(width: 12),
                        _heroStat(Icons.local_fire_department_rounded, '${GameData.streak}', 'روز پیاپی',
                            Colors.redAccent),
                        const Spacer(),
                        // Fandoghi mini
                        const FandoghiV2(
                          size: 45,
                          animate: true,
                          mood: FandoghiMood.wink,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Level progress bar
                    _buildLevelProgress(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecorativeCircles() {
    return [
      Positioned(
        top: -30 + _scrollOffset * 0.1,
        right: -40,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      Positioned(
        top: 60 - _scrollOffset * 0.05,
        left: -60,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.04),
          ),
        ),
      ),
      Positioned(
        bottom: 20 + _scrollOffset * 0.08,
        right: 60,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
    ];
  }

  Widget _heroStat(IconData icon, String value, String label, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 18,
      opacity: 0.15,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress() {
    final progress = (GameData.coins % 100) / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'پیشرفت لول ${GameData.level + 1}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              '${GameData.coins % 100}/100',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  // ─── QUICK STATS ──────────────────────────────
  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              icon: Icons.check_circle_rounded,
              value: '${GameData.totalCorrect}',
              label: 'جواب درست',
              color: AppColors.success,
              gradient: AppGradients.forest,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              icon: Icons.trending_up_rounded,
              value: '${(GameData.successRate * 100).toStringAsFixed(0)}%',
              label: 'نرخ موفقیت',
              color: AppColors.info,
              gradient: AppGradients.ocean,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              icon: Icons.emoji_events_rounded,
              value: '${GameData.achievements.length}',
              label: 'مدال',
              color: AppColors.warning,
              gradient: AppGradients.candy,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3);
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.exo2(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  // ─── DAILY MISSIONS ───────────────────────────
  Widget _buildDailyMissions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GradientGlassCard(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.03),
          ],
        ),
        borderRadius: 28,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ماموریت‌های امروز',
                  style: GoogleFonts.vazirmatn(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${GameData.dailyMissions}/4',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _missionTile('۵ سوال حل کن', 'questions', 5, Icons.quiz_rounded),
            _missionTile('الفبا تمرین کن', 'alphabet', 1, Icons.abc_rounded),
            _missionTile('یک نقاشی بکش', 'drawing', 1, Icons.brush_rounded),
            _missionTile('رنگ‌ها رو یاد بگیر', 'colors', 1, Icons.palette_rounded),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3);
  }

  Widget _missionTile(String title, String id, int target, IconData icon) {
    final value = GameData.missionValue(id);
    final done = GameData.isMissionDone(id);
    final progress = (value / target).clamp(0.0, 1.0).toDouble();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              done ? Icons.check_circle_rounded : icon,
              color: done ? AppColors.success : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // Progress bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: done ? AppColors.success : AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!done)
            Text(
              '$value/$target',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  // ─── QUICK GAMES ──────────────────────────────
  Widget _buildQuickGames() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بازی‌های سریع',
            style: GoogleFonts.vazirmatn(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _quickGameBtn('ستاره‌گیری', '⭐', const Color(0xFFFF5252)),
                _quickGameBtn('حباب‌ترکان', '🫧', const Color(0xFF00CEC9)),
                _quickGameBtn('حافظه', '🧠', const Color(0xFFE17055)),
                _quickGameBtn('الفبا', '🔤', const Color(0xFF6C5CE7)),
                _quickGameBtn('اعداد', '🔢', const Color(0xFFFF8E53)),
                _quickGameBtn('رنگ‌ها', '🎨', const Color(0xFFFA709A)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3);
  }

  Widget _quickGameBtn(String name, String emoji, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, '/game/$name');
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ).animate().scale(
            delay: Duration(
              milliseconds: 100 *
                  [
                    'ستاره‌گیری',
                    'حباب‌ترکان',
                    'حافظه',
                    'الفبا',
                    'اعداد',
                    'رنگ‌ها',
                  ].indexOf(name).clamp(0, 5).toInt(),
            ),
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
    );
  }

  // ─── CATEGORIES ───────────────────────────────
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'دسته‌بندی بازی‌ها',
            style: GoogleFonts.vazirmatn(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _categoryCard(
            title: 'یادگیری پایه',
            subtitle: 'الفبا • اعداد • رنگ‌ها • اشکال',
            icon: Icons.school_rounded,
            gradient: AppGradients.purple,
            games: ['الفبا', 'اعداد', 'رنگ‌ها', 'اشکال'],
          ),
          const SizedBox(height: 12),
          _categoryCard(
            title: 'بازی‌های فکری',
            subtitle: 'حافظه • الگو • مسابقه • ترتیب',
            icon: Icons.psychology_rounded,
            gradient: AppGradients.ocean,
            games: ['حافظه', 'الگو', 'مسابقه', 'ترتیب'],
          ),
          const SizedBox(height: 12),
          _categoryCard(
            title: 'دنیای اطراف',
            subtitle: 'حیوانات • بدن • شغل‌ها • فضا',
            icon: Icons.public_rounded,
            gradient: AppGradients.forest,
            games: ['حیوانات', 'بدن', 'شغل‌ها', 'فضا'],
          ),
          const SizedBox(height: 12),
          _categoryCard(
            title: 'خلاقیت',
            subtitle: 'نقاشی • داستان • موسیقی',
            icon: Icons.palette_rounded,
            gradient: AppGradients.candy,
            games: ['نقاشی', 'داستان', 'سازها'],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3);
  }

  Widget _categoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required List<String> games,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            HapticFeedback.lightImpact();
            if (games.isNotEmpty) {
              Navigator.pushNamed(context, '/game/${games.first}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.vazirmatn(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: games
                      .map(
                        (g) => GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(context, '/game/$g');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              g,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── FANDOGHI TIP ─────────────────────────────
  Widget _buildFandoghiTip() {
    final coachText = GameData.totalCorrect == 0
        ? 'من از اول تا آخر کنارت هستم؛ هر وقت آماده‌ای، یکی از بازی‌ها را انتخاب کن!'
        : AI.mascotMsg();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GradientGlassCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
        ),
        borderRadius: 30,
        padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FandoghiV2(
              size: 104,
              animate: true,
              mood: GameData.successRate > 0.8
                  ? FandoghiMood.excited
                  : FandoghiMood.happy,
              onTap: () => FandoghiCoach.say(
                'من فندقی‌ام؛ راهنما، مربی و داور بازی‌های تو! روی هر بازی بزن تا با هم شروع کنیم 🌰',
                mood: FandoghiMood.excited,
                duration: const Duration(seconds: 4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'فندقی، مربی تو 🌰',
                    style: GoogleFonts.vazirmatn(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: AppColors.fandoghiDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    coachText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.55,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'برای راهنمایی روی من بزن!',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3);
  }

  // ─── PARENT GATE ──────────────────────────────
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
                'این سؤال برای ورود بزرگ‌ترهاست.',
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
                  setDialogState(() => errorText = 'جواب درست نیست. دوباره امتحان کنید.');
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
}
