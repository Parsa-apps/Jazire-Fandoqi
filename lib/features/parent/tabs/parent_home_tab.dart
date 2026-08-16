import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../../../core/growth/parent_insights.dart';
import '../../../core/parental_health_radar.dart';
import '../../growth/widgets/screen_time_chart.dart';
import '../widgets/parent_widgets.dart';

/// تب خانه: کارنامه‌ی یک‌نگاه + هشدارهای معلم + دسترسی سریع.
class ParentHomeTab extends StatefulWidget {
  final VoidCallback? onOpenTimeControls;
  final VoidCallback? onOpenContent;
  final VoidCallback? onOpenProgress;
  final VoidCallback? onShareReport;

  const ParentHomeTab({
    super.key,
    this.onOpenTimeControls,
    this.onOpenContent,
    this.onOpenProgress,
    this.onShareReport,
  });

  @override
  State<ParentHomeTab> createState() => _ParentHomeTabState();
}

class _ParentHomeTabState extends State<ParentHomeTab> {
  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final healthScore = ParentalHealthRadar.getHealthScore();
    final healthColor = healthScore >= 80
        ? const Color(0xFF00B894)
        : healthScore >= 60
            ? const Color(0xFFFDCB6E)
            : const Color(0xFFE17055);
    final alerts = ParentInsights.alerts();
    final tips = ParentInsights.teacherTips();
    final challenge = WeeklyEngine.currentChallenge();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _buildHero(),
        const SizedBox(height: 16),

        // دسترسی سریع
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('دسترسی سریع',
                  style: AppFonts.vazirmatn(
                      fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ParentActionButton(
                    label: 'زمان و خواب',
                    icon: Icons.timer_outlined,
                    color: const Color(0xFF0984E3),
                    onTap: widget.onOpenTimeControls,
                  ),
                  ParentActionButton(
                    label: 'فیلتر محتوا',
                    icon: Icons.shield_outlined,
                    color: const Color(0xFF6C5CE7),
                    onTap: widget.onOpenContent,
                  ),
                  ParentActionButton(
                    label: 'گزارش هفتگی',
                    icon: Icons.insights_rounded,
                    color: const Color(0xFF00B894),
                    onTap: widget.onShareReport,
                  ),
                  ParentActionButton(
                    label: 'پیشرفت',
                    icon: Icons.rocket_launch_rounded,
                    color: const Color(0xFFE17055),
                    onTap: widget.onOpenProgress,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // هشدارهای هوشمند
        ...alerts.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ToneBanner(
                emoji: a.emoji,
                title: a.title,
                body: a.body,
                tone: a.tone,
              ),
            )),

        const SizedBox(height: 8),
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                emoji: '🩺',
                title: 'رادار سلامت دیجیتال',
                subtitle: ParentalHealthRadar.getHealthRecommendation(),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: healthColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${PersianDigits.toFa(healthScore)}٪',
                    style: AppFonts.vazirmatn(
                      color: healthColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const ScreenTimeChart(),
        const SizedBox(height: 16),

        // توصیه معلم
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '👩\u200d🏫',
                title: 'توصیه‌ی معلمِ فندقی',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE3A3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ParentInsights.teacherHeadline(),
                        style: AppFonts.vazirmatn(
                          fontSize: 13.5,
                          height: 1.7,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...tips.take(3).map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ToneBanner(
                        emoji: t.emoji,
                        title: t.title,
                        body: t.body,
                        tone: t.tone,
                      ),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // چالش هفته
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                emoji: challenge.emoji,
                title: 'چالش هفته: ${challenge.title}',
                subtitle: challenge.description,
              ),
              const SizedBox(height: 12),
              LabeledProgress(
                value: WeeklyEngine.challengeRatio,
                color: AppColors.primary,
                label:
                    '${PersianDigits.toFa(GrowthStore.weeklyChallengeProgress)} از ${PersianDigits.toFa(challenge.target)} ${challenge.unit}',
                trailing:
                    '${PersianDigits.toFa((WeeklyEngine.challengeRatio * 100).round())}٪',
              ),
              if (WeeklyEngine.canClaimLearningChest) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      final ok = WeeklyEngine.claimLearningChest();
                      _refresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'صندوق یادگیری باز شد! +۱۵ سکه 🎁'
                              : 'هنوز ۱۵ دقیقه یادگیری کامل نشده.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.card_giftcard_rounded),
                    label: const Text('باز کردن صندوق یادگیری (+۱۵ سکه)'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    final name = GameData.childName.trim().isEmpty
        ? 'قهرمان'
        : GameData.childName.trim();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(GameData.avatar,
                    style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سلام والد عزیز 👋',
                      style: AppFonts.vazirmatn(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'کارنامه‌ی $name',
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: Colors.orangeAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${PersianDigits.toFa(ParentInsights.streakDays)} روز',
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _heroStat(
                  '${PersianDigits.toFa(ParentInsights.todayLearningMinutes)}',
                  'دقیقه یادگیری',
                  Icons.menu_book_rounded,
                ),
              ),
              Expanded(
                child: _heroStat(
                  '${PersianDigits.toFa(ParentInsights.todayEntertainmentMinutes)}',
                  'دقیقه سرگرمی',
                  Icons.sports_esports_rounded,
                ),
              ),
              Expanded(
                child: _heroStat(
                  '${PersianDigits.toFa(ParentInsights.accuracyPercent.round())}٪',
                  'دقت پاسخ',
                  Icons.verified_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppFonts.vazirmatn(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
