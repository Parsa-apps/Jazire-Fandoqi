import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/game_data.dart';
import '../core/ai_system.dart';
import '../core/theme.dart';
import '../widgets/fandoghi.dart';
import '../widgets/star_display.dart';
import '../widgets/common.dart';

/// پروفایل جدید - طراحی حرفه‌ای پروفایل کودک
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildFandoghiMessage()),
          SliverToBoxAdapter(child: _buildProgressSection()),
          SliverToBoxAdapter(child: _buildSkillsChart()),
          SliverToBoxAdapter(child: _buildAchievementsPreview()),
          SliverToBoxAdapter(child: _buildActionButtons()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            child: Column(
              children: [
                // Top row
                Row(
                  children: [
                    const Text(
                      'پروفایل من',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _iconBtn(Icons.settings, () {
                      Navigator.pushNamed(context, '/settings');
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                // Avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.amber, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              GameData.avatar,
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ).animate().scale(
                              duration: 500.ms,
                              curve: Curves.elasticOut,
                            ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          GameData.childName.isEmpty
                              ? 'قهرمان کوچولو'
                              : GameData.childName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            GameData.getLevelName(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const FandoghiMini(size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'لول ${GameData.level}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _statCard(
            Icons.star_rounded,
            '${GameData.stars}',
            'ستاره',
            Colors.amber,
          ),
          const SizedBox(width: 8),
          _statCard(
            Icons.monetization_on_rounded,
            '${GameData.coins}',
            'سکه',
            Colors.orange,
          ),
          const SizedBox(width: 8),
          _statCard(
            Icons.local_fire_department_rounded,
            '${GameData.streak}',
            'پیاپی',
            Colors.red,
          ),
          const SizedBox(width: 8),
          _statCard(
            Icons.check_circle_rounded,
            '${GameData.totalCorrect}',
            'درست',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ).animate().scale(delay: Duration(milliseconds: 100)),
    );
  }

  Widget _buildFandoghiMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.fandoghiCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.fandoghiLight.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            const Fandoghi(size: 50, animate: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'فندقی میگه:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.fandoghiBrown,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AI.mascotMsg(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5D4037),
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

  Widget _buildProgressSection() {
    final progress = (GameData.level % 100) / 100.0;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'پیشرفت',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      color: AppColors.primary,
                      minHeight: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'نرخ موفقیت: ${(GameData.successRate * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsChart() {
    final skills = GameData.skills.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (skills.isEmpty) return const SizedBox.shrink();

    final names = {
      'math': 'ریاضی', 'alphabet': 'الفبا', 'memory': 'حافظه',
      'colors': 'رنگ', 'shapes': 'شکل', 'animals': 'حیوان',
      'counting': 'شمارش', 'pattern': 'الگو', 'fruits': 'میوه',
      'concepts': 'مفاهیم', 'vocab': 'لغات', 'body': 'بدن',
      'vehicles': 'ماشین', 'time': 'زمان', 'weather': 'هوا',
      'emotions': 'احساس', 'jobs': 'شغل'
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'مهارت‌ها',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  barGroups: skills
                      .take(8)
                      .toList()
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(
                            x: e.key.toDouble(),
                            barRods: [
                              BarChartRodData(
                                toY: e.value.value.toDouble(),
                                color: AppColors.primary
                                    .withOpacity(0.7 + (e.key * 0.03)),
                                width: 18,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true, reservedSize: 30),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= skills.take(8).length) {
                            return const Text('');
                          }
                          return Text(
                            names[skills.take(8).toList()[idx].key] ?? '',
                            style: const TextStyle(fontSize: 9),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsPreview() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'مدال‌ها',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${GameData.achievements.length} مدال',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (GameData.achievements.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '🏆\nهنوز مدالی نداری!\nبازی کن و مدال بگیر',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GameData.achievements
                    .take(6)
                    .map((_) => Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('🏅',
                              style: TextStyle(fontSize: 20)),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _actionBtn(
            Icons.face_retouching_natural,
            'تغییر آواتار',
            Colors.purple,
            () => Navigator.pushNamed(context, '/avatar'),
          ),
          const SizedBox(height: 8),
          _actionBtn(
            Icons.bar_chart_rounded,
            'آمار کامل',
            Colors.blue,
            () => Navigator.pushNamed(context, '/stats'),
          ),
          const SizedBox(height: 8),
          _actionBtn(
            Icons.workspace_premium,
            'اشتراک ویژه',
            Colors.amber,
            () => Navigator.pushNamed(context, '/subscription'),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return BounceBtn(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_left, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
