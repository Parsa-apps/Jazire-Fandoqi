import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import '../../../core/ai_system.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../presentation/providers/game_state_provider.dart';
import '../../../shared/widgets/fandoghi_v2.dart';
import '../../../shared/widgets/glass_card.dart';
import 'premium_card.dart';
import '../../../shared/widgets/star_field.dart';
import '../../../core/monetization.dart';
import '../../shop/full_version_paywall.dart';
import '../../profile/profile_editor.dart';

/// ═══════════════════════════════════════════════
/// 📊 DASHBOARD TAB — Main Content
/// Parallax hero, daily missions, game categories
/// ═══════════════════════════════════════════════
class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});
  @override
  ConsumerState<DashboardTab> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<DashboardTab> {
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FandoghiCoach.welcome();
    });
  }

  void _onScroll() {
    if (mounted) setState(() => _scrollOffset = _scrollCtrl.offset);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // فاز ۳: واکنش به وضعیت از طریق Riverpod
    ref.watch(gameStateProvider);
    // فاز ۱۴: داشبورد هوشمند بر اساس سن
    // ۳-۴: ساده (بدون مأموریت روزانه، دسته‌بندی ساده)
    // ۵-۶: استاندارد (همه بخش‌ها)
    // ۷-۸: چالش‌محور (مأموریت‌ها جلوتر + نکته تشویقی)
    final simple = _ageMode == _AgeMode.simple;
    final challenge = _ageMode == _AgeMode.challenge;
    final slivers = <Widget>[
      // Hero App Bar with parallax
      _buildHeroAppBar(),

      // Quick stats
      SliverToBoxAdapter(child: _buildQuickStats()),

      // 🎬 بنر کارتون‌ها و سینما کودک
      SliverToBoxAdapter(child: _buildCartoonBanner()),
    ];

    // مأموریت‌ها فقط یک‌بار نمایش داده می‌شوند:
    //  - چالش (۷-۸ سال): بالای لیست (جلوتر)
    //  - استاندارد (۵-۶ سال): بعد از دسته‌بندی‌ها
    if (challenge) {
      slivers.add(SliverToBoxAdapter(child: _buildDailyMissions()));
    }

    // Quick games
    slivers.add(SliverToBoxAdapter(child: _buildQuickGames()));

    // Game categories — در حالت ساده فقط دسته‌بندی‌های اصلی
    slivers.add(SliverToBoxAdapter(child: _buildCategories(simple: simple)));

    if (simple) {
      // حالت ساده (۳-۴ سال): بدون مأموریت و بدون نکته
    } else if (challenge) {
      slivers.add(SliverToBoxAdapter(child: _buildFandoghiTip()));
    } else {
      slivers.add(SliverToBoxAdapter(child: _buildDailyMissions()));
      slivers.add(SliverToBoxAdapter(child: _buildFandoghiTip()));
    }

    // فاز ۵۰/۶۲: یادآوری استراحت برای همه سن‌ها (حتی حالت ساده)
    if (AI.needsBreak() && !GameData.isDailyLimitReached) {
      slivers.add(SliverToBoxAdapter(child: _buildBreakReminder()));
    }

    // Bottom padding
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 120)));

    return CustomScrollView(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      slivers: slivers,
    );
  }

  /// فاز ۱۴: حالت سنی داشبورد.
  _AgeMode get _ageMode {
    final age = GameData.childAge;
    if (age <= 4) return _AgeMode.simple;
    if (age <= 6) return _AgeMode.standard;
    return _AgeMode.challenge;
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
                                style: AppFonts.vazirmatn(
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
                        _glassIconButton(Icons.edit_rounded, () => showProfileEditor(context)),
                        const SizedBox(width: 8),
                        // Cinema Hub Button
                        _glassIconButton(
                          Icons.movie_rounded,
                          () => Navigator.pushNamed(context, '/cartoons'),
                        ),
                        const SizedBox(width: 8),
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
            child: PremiumCard(
              padding: const EdgeInsets.all(18),
              onTap: () {
                HapticFeedback.lightImpact();
                FandoghiCoach.say('آفرین! تا الان ${GameData.totalCorrect} جواب درست دادی! ادامه بده قهرمان 🌰🌟', mood: FandoghiMood.excited);
              },
              child: _statContent(
                icon: Icons.check_circle_rounded,
                value: '${GameData.totalCorrect}',
                label: 'جواب درست',
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PremiumCard(
              padding: const EdgeInsets.all(18),
              onTap: () {
                HapticFeedback.lightImpact();
                FandoghiCoach.say('نرخ موفقیت تو ${(GameData.successRate * 100).toStringAsFixed(0)}% است! فوق‌العاده‌ای! 🔥', mood: FandoghiMood.happy);
              },
              child: _statContent(
                icon: Icons.trending_up_rounded,
                value: '${(GameData.successRate * 100).toStringAsFixed(0)}%',
                label: 'نرخ موفقیت',
                color: AppColors.info,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PremiumCard(
              padding: const EdgeInsets.all(18),
              onTap: () {
                HapticFeedback.lightImpact();
                FandoghiCoach.say('تا الان ${GameData.achievements.length} مدال افتخار گرفتی! 🏅', mood: FandoghiMood.excited);
              },
              child: _statContent(
                icon: Icons.emoji_events_rounded,
                value: '${GameData.achievements.length}',
                label: 'مدال',
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3);
  }

  Widget _statContent({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 10),
        Text(
          value,
          style: AppFonts.exo2(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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
            style: AppFonts.exo2(
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

  // ─── CARTOON BANNER ──────────────────────────
  Widget _buildCartoonBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, '/cartoons');
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF5E3A),
                Color(0xFFFF2A6D),
                Color(0xFF8E44AD),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF2A6D).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('🍿🎬', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'سینما کارتون‌های شاد',
                          style: AppFonts.vazirmatn(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('جدید', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'شکرستان • پهلوانان • سگ‌های نگهبان و...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Color(0xFFFF2A6D), size: 18),
                    const SizedBox(width: 2),
                    Text(
                      'تماشا',
                      style: AppFonts.vazirmatn(
                        color: const Color(0xFFFF2A6D),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2);
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
                  style: AppFonts.vazirmatn(
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

  static const _freeGames = {'الفبا', 'اعداد', 'رنگ‌ها', 'ستاره‌گیری', 'حباب‌ترکان'};

  Future<void> _openGame(String game) async {
    // A generous starter set lets families assess the app before the parent-only paywall.
    if (!_freeGames.contains(game) && !await Monetization.hasFullVersion()) {
      if (mounted) await showFullVersionPaywall(context, featureName: game);
      return;
    }
    if (mounted) Navigator.pushNamed(context, '/game/$game');
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
            style: AppFonts.vazirmatn(
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
        _openGame(name);
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
  Widget _buildCategories({bool simple = false}) {
    final children = <Widget>[
      Text(
        simple ? 'بازی‌های من' : 'دسته‌بندی بازی‌ها',
        style: AppFonts.vazirmatn(
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
      if (!simple) ...[
        _categoryCard(
          title: 'بازی‌های فکری',
          subtitle: 'حافظه • الگو • مسابقه • ترتیب',
          icon: Icons.psychology_rounded,
          gradient: AppGradients.ocean,
          games: ['حافظه', 'الگو', 'مسابقه', 'ترتیب'],
        ),
        const SizedBox(height: 12),
      ],
      if (simple) ...[
        _categoryCard(
          title: 'بازی‌های من',
          subtitle: 'نقاشی • ستاره‌گیری • حباب',
          icon: Icons.favorite_rounded,
          gradient: AppGradients.candy,
          games: ['نقاشی', 'ستاره‌گیری', 'حباب‌ترکان'],
        ),
        const SizedBox(height: 12),
      ],
      _categoryCard(
        title: 'دنیای اطراف',
        subtitle: 'حیوانات • بدن • شغل‌ها • فضا',
        icon: Icons.public_rounded,
        gradient: AppGradients.forest,
        games: ['حیوانات', 'بدن', 'شغل‌ها', 'فضا'],
      ),
      if (!simple) ...[
        const SizedBox(height: 12),
        _categoryCard(
          title: 'خلاقیت',
          subtitle: 'نقاشی • داستان • موسیقی',
          icon: Icons.palette_rounded,
          gradient: AppGradients.candy,
          games: ['نقاشی', 'داستان', 'سازها'],
        ),
      ],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
              _openGame(games.first);
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
                            style: AppFonts.vazirmatn(
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
                            _openGame(g);
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
  /// فاز ۵۰/۶۲: کارت استراحت چشم (قانون 20-20-20) — برای همه سن‌ها.
  Widget _buildBreakReminder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GradientGlassCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        ),
        borderRadius: 30,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('😴', style: TextStyle(fontSize: 46)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وقت یک استراحت کوچک است!',
                    style: AppFonts.vazirmatn(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'قانون ۲۰-۲۰-۲۰: بیا ۲۰ ثانیه به جای دور نگاه کنیم؛ چشم‌ها خسته نشوند 🌈',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFandoghiTip() {
    // فاز ۴۶: پیشنهاد ۳ بازی هوشمند بر اساس مهارت ضعیف
    final suggestions = AI.suggestGames();
    final coachText = GameData.totalCorrect == 0
        ? 'من از اول تا آخر کنارت هستم؛ هر وقت آماده‌ای، یکی از بازی‌ها را انتخاب کن!'
        : 'فندقی پیشنهاد می‌کند امروز این بازی‌ها را امتحان کنی: '
            '${suggestions.map((g) => '«$g»').join('، ')} 🎯';

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
                    style: AppFonts.vazirmatn(
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

/// فاز ۱۴: حالت‌های داشبورد هوشمند بر اساس سن کودک.
enum _AgeMode { simple, standard, challenge }
