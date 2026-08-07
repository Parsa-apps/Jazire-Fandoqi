import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_colors.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/fandoghi_v2.dart';
import '../../shared/widgets/star_field.dart';
import 'painters/skill_radar_painter.dart';
import 'painters/stat_ring_painter.dart';

/// ═══════════════════════════════════════════════
/// 👤 PROFILE SCREEN — Professional Profile
/// Avatar, stats, skill radar, achievements, history
/// ═══════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  final bool embedded;

  const ProfileScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _radarCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _barCtrl;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Staggered animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _radarCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _ringCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _barCtrl.forward();
    });
    GameData.changes.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GameData.changes.removeListener(_onDataChanged);
    _radarCtrl.dispose();
    _ringCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: Stack(
          children: [
            // Star background
            const StarFieldBackground(starCount: 40),

            // Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── HERO HEADER ───
                _buildHeroHeader(),

                // ─── QUICK STATS RINGS ───
                SliverToBoxAdapter(child: _buildStatRings()),

                // ─── SKILL RADAR ───
                SliverToBoxAdapter(child: _buildSkillRadar()),

                // ─── SKILL BARS ───
                SliverToBoxAdapter(child: _buildSkillBars()),

                // ─── ACHIEVEMENTS ───
                SliverToBoxAdapter(child: _buildAchievements()),

                // ─── ACTIVITY HEATMAP ───
                SliverToBoxAdapter(child: _buildActivityHeatmap()),

                // ─── GAME HISTORY ───
                SliverToBoxAdapter(child: _buildGameHistory()),

                // ─── FANDOGHI TIP ───
                SliverToBoxAdapter(child: _buildFandoghiTip()),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),

            // Back button is only needed when this screen is pushed as a
            // standalone route. HomeScreen owns navigation when embedded.
            if (!widget.embedded)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _glassBtn(Icons.arrow_back_rounded, () => Navigator.pop(context)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── HERO HEADER ─────────────────────────────
  Widget _buildHeroHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6C5CE7),
                    Color(0xFF4834D4),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: -60,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),

            // Profile content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Avatar with glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          GameData.avatar,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

                  const SizedBox(height: 16),

                  // Name
                  Text(
                    GameData.childName.isNotEmpty ? GameData.childName : 'قهرمان کوچولو',
                    style: GoogleFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                  const SizedBox(height: 4),

                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      'لول ${GameData.level} • ${GameData.getLevelName()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                  const SizedBox(height: 16),

                  // Quick stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _miniStat('⭐', '${GameData.stars}', 'ستاره'),
                      _miniStat('💰', '${GameData.coins}', 'سکه'),
                      _miniStat('🔥', '${GameData.streak}', 'روز پیاپی'),
                      _miniStat('🏅', '${GameData.achievements.length}', 'مدال'),
                    ],
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String emoji, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── STAT RINGS ──────────────────────────────
  Widget _buildStatRings() {
    final successRate = GameData.successRate;
    final levelProgress = (GameData.coins % 100) / 100;
    final missionProgress = GameData.dailyMissions / 4;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: AnimatedBuilder(
        animation: _ringCtrl,
        builder: (_, __) {
          return Row(
            children: [
              Expanded(child: _statRingCard(
                'نرخ موفقیت',
                successRate,
                '${(successRate * 100).toStringAsFixed(0)}%',
                const Color(0xFF00B894),
                _ringCtrl.value,
              )),
              const SizedBox(width: 12),
              Expanded(child: _statRingCard(
                'پیشرفت لول',
                levelProgress,
                '${GameData.coins % 100}/100',
                const Color(0xFF6C5CE7),
                _ringCtrl.value,
              )),
              const SizedBox(width: 12),
              Expanded(child: _statRingCard(
                'ماموریت‌ها',
                missionProgress,
                '${GameData.dailyMissions}/4',
                const Color(0xFFFFD700),
                _ringCtrl.value,
              )),
            ],
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _statRingCard(String label, double progress, String text, Color color, double anim) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(70, 70),
                  painter: StatRingPainter(
                    progress: progress,
                    color: color,
                    strokeWidth: 8,
                    animProgress: anim,
                  ),
                ),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── SKILL RADAR ─────────────────────────────
  Widget _buildSkillRadar() {
    final skillData = _getSkillData();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.radar_rounded, color: AppColors.primaryLight, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'نمودار مهارت‌ها',
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _radarCtrl,
              builder: (_, __) {
                return SizedBox(
                  height: 250,
                  child: CustomPaint(
                    size: const Size(double.infinity, 250),
                    painter: SkillRadarPainter(
                      values: skillData.map((s) => s.$2).toList(),
                      labels: skillData.map((s) => s.$1).toList(),
                      colors: skillData.map((s) => s.$3).toList(),
                      animProgress: _radarCtrl.value,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  List<(String, double, Color)> _getSkillData() {
    final skills = GameData.skills;
    final maxVal = skills.values.fold(1, (a, b) => a > b ? a : b).toDouble();

    return [
      ('ریاضی', (skills['math'] ?? 0) / maxVal, const Color(0xFFFF6B6B)),
      ('الفبا', (skills['alphabet'] ?? 0) / maxVal, const Color(0xFF6C5CE7)),
      ('حافظه', (skills['memory'] ?? 0) / maxVal, const Color(0xFF00CEC9)),
      ('رنگ‌ها', (skills['colors'] ?? 0) / maxVal, const Color(0xFFFFD700)),
      ('حیوانات', (skills['animals'] ?? 0) / maxVal, const Color(0xFF00B894)),
      ('شمارش', (skills['counting'] ?? 0) / maxVal, const Color(0xFFE17055)),
    ];
  }

  // ─── SKILL BARS ──────────────────────────────
  Widget _buildSkillBars() {
    final skills = GameData.skills;
    final maxVal = skills.values.fold(1, (a, b) => a > b ? a : b).toDouble();

    final barData = [
      BarData(label: 'ریاضی', value: (skills['math'] ?? 0) / maxVal, color: const Color(0xFFFF6B6B)),
      BarData(label: 'الفبا', value: (skills['alphabet'] ?? 0) / maxVal, color: const Color(0xFF6C5CE7)),
      BarData(label: 'حافظه', value: (skills['memory'] ?? 0) / maxVal, color: const Color(0xFF00CEC9)),
      BarData(label: 'رنگ‌ها', value: (skills['colors'] ?? 0) / maxVal, color: const Color(0xFFFFD700)),
      BarData(label: 'شکل‌ها', value: (skills['shapes'] ?? 0) / maxVal, color: const Color(0xFFA29BFE)),
      BarData(label: 'حیوانات', value: (skills['animals'] ?? 0) / maxVal, color: const Color(0xFF00B894)),
      BarData(label: 'لغات', value: (skills['vocab'] ?? 0) / maxVal, color: const Color(0xFFE17055)),
      BarData(label: 'بدن', value: (skills['body'] ?? 0) / maxVal, color: const Color(0xFFFD79A8)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00CEC9).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF00CEC9), size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'جزئیات مهارت‌ها',
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _barCtrl,
              builder: (_, __) {
                return CustomPaint(
                  size: Size(double.infinity, barData.length * 36.0 + 10),
                  painter: SkillBarPainter(
                    bars: barData,
                    animProgress: _barCtrl.value,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }

  // ─── ACHIEVEMENTS ────────────────────────────
  Widget _buildAchievements() {
    final allAch = [
      {'id': 'math_50', 'emoji': '🧮', 'title': 'ریاضیدان', 'desc': '۵۰ امتیاز ریاضی'},
      {'id': 'memory_king', 'emoji': '🧠', 'title': 'شاه حافظه', 'desc': 'بازی حافظه کامل'},
      {'id': 'streak_3', 'emoji': '🔥', 'title': '۳ روز پیاپی', 'desc': '۳ روز متوالی'},
      {'id': 'streak_7', 'emoji': '🏆', 'title': '۷ روز پیاپی', 'desc': '۷ روز متوالی'},
      {'id': 'coin_500', 'emoji': '💰', 'title': 'ثروتمند', 'desc': '۵۰۰ سکه'},
      {'id': 'level_5', 'emoji': '🌟', 'title': 'استاد', 'desc': 'لول ۵'},
      {'id': 'correct_100', 'emoji': '🎯', 'title': 'ماهر', 'desc': '۱۰۰ جواب درست'},
      {'id': 'collector', 'emoji': '🎁', 'title': 'کلکسیونر', 'desc': '۵ استیکر'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'مدال‌ها',
                style: GoogleFonts.vazirmatn(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${GameData.achievements.length}/${allAch.length}',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: allAch.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final ach = allAch[i];
                final unlocked = GameData.achievements.contains(ach['id']);
                return _achievementCard(
                  ach['emoji']!,
                  ach['title']!,
                  ach['desc']!,
                  unlocked,
                  i,
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _achievementCard(String emoji, String title, String desc, bool unlocked, int index) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFFFD700).withOpacity(0.1)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked
              ? const Color(0xFFFFD700).withOpacity(0.3)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: 30,
                  color: unlocked ? null : Colors.white.withOpacity(0.15),
                ),
              ),
              if (!unlocked)
                Icon(
                  Icons.lock_rounded,
                  color: Colors.white.withOpacity(0.2),
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.white.withOpacity(0.3),
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    )
        .animate(
          delay: Duration(milliseconds: 100 * index),
        )
        .fadeIn()
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }

  // ─── ACTIVITY HEATMAP ────────────────────────
  Widget _buildActivityHeatmap() {
    // Generate fake activity data based on streak
    final rng = Random(42);
    final activity = List.generate(28, (i) {
      if (i < GameData.streak && i < 28) return rng.nextInt(3) + 1;
      return rng.nextInt(2);
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B894).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF00B894), size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'فعالیت ۴ هفته اخیر',
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Day labels
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']
                    .map((d) => Text(
                          d,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                          ),
                        ))
                    .toList(),
              ),
            ),

            // Heatmap grid
            AnimatedBuilder(
              animation: _ringCtrl,
              builder: (_, __) {
                return CustomPaint(
                  size: Size(double.infinity, 4 * 30.0),
                  painter: ActivityHeatmapPainter(
                    activity: activity,
                    animProgress: _ringCtrl.value,
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'کم',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                ),
                const SizedBox(width: 6),
                ...List.generate(5, (i) {
                  final colors = [
                    Colors.white.withOpacity(0.05),
                    const Color(0xFF2D5F2D),
                    const Color(0xFF3E8E3E),
                    const Color(0xFF5ABF5A),
                    const Color(0xFF7AE67A),
                  ];
                  return Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: colors[i],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
                const SizedBox(width: 6),
                Text(
                  'زیاد',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2);
  }

  // ─── GAME HISTORY ────────────────────────────
  Widget _buildGameHistory() {
    final history = [
      ('⭐', 'ستاره‌گیری', '${GameData.totalCorrect} جواب درست', '🔥 ${GameData.streak} روز پیاپی'),
      ('🧮', 'رکورد ریاضی', '${GameData.mathRaceHighScore} امتیاز', 'بهترین رکورد'),
      ('🏆', 'رکورد مسابقه', '${GameData.quizHighScore} امتیاز', 'مسابقه عمومی'),
      ('📊', 'بیشترین امتیاز', '${GameData.highScore} امتیاز', 'رکورد کلی'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE17055).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.history_rounded, color: Color(0xFFE17055), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'رکوردها',
                style: GoogleFonts.vazirmatn(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...history.asMap().entries.map((entry) {
            final i = entry.key;
            final (emoji, title, value, subtitle) = entry.value;
            return _historyRow(emoji, title, value, subtitle, i);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }

  Widget _historyRow(String emoji, String title, String value, String subtitle, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ─── FANDOGHI TIP ────────────────────────────
  Widget _buildFandoghiTip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const FandoghiV2(
              size: 55,
              animate: true,
              mood: FandoghiMood.happy,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نکته فندقی 🌰',
                    style: GoogleFonts.vazirmatn(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getProfileTip(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2);
  }

  String _getProfileTip() {
    final weakSkill = GameData.skills.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
    final skillNames = {
      'math': 'ریاضی', 'alphabet': 'الفبا', 'memory': 'حافظه',
      'colors': 'رنگ‌ها', 'animals': 'حیوانات', 'vocab': 'لغات',
    };
    final name = skillNames[weakSkill] ?? weakSkill;
    return 'بیشتر روی $name تمرین کن تا بهتر بشی! هر روز بازی کن و مدال جمع کن! 🌟';
  }

  Widget _glassBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
