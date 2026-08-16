import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../../../core/growth/parent_insights.dart';
import '../../../shared/widgets/skill_radar_chart.dart';
import '../widgets/parent_widgets.dart';

/// تب پیشرفت: رادار مهارت، نقاط قوت/ضعف، روند هفتگی و واژه‌نامه.
class ParentProgressTab extends StatelessWidget {
  final VoidCallback? onOpenVocabulary;
  final VoidCallback? onOpenCertificates;

  const ParentProgressTab({
    super.key,
    this.onOpenVocabulary,
    this.onOpenCertificates,
  });

  static const Map<String, String> _emoji = {
    'الفبا': '🔤',
    'اعداد': '🔢',
    'رنگ‌ها': '🎨',
    'شکل‌ها': '🔷',
    'حیوانات': '🦁',
    'حافظه': '🧠',
    'ریاضی': '🧮',
    'هنر': '✏️',
  };

  @override
  Widget build(BuildContext context) {
    final skills = ParentInsights.radarSkills();
    final hasData = skills.values.any((v) => v > 0);
    final strongest = ParentInsights.strongestSkills();
    final focus = ParentInsights.focusSkills();
    final trend = ParentInsights.trend();
    final maxTrend = trend.fold<int>(1, (m, d) => d.total > m ? d.total : m);
    final accuracy = (GameData.averageSuccessRate).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // آمار کلی
        Row(
          children: [
            Expanded(
              child: ParentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 8),
                    Text(
                      '${PersianDigits.toFa(accuracy)}٪',
                      style: AppFonts.vazirmatn(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    Text('نرخ موفقیت کل',
                        style: AppFonts.vazirmatn(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ParentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✅', style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 8),
                    Text(
                      PersianDigits.toFa(GameData.totalCorrect),
                      style: AppFonts.vazirmatn(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF00B894),
                      ),
                    ),
                    Text('پاسخ درست',
                        style: AppFonts.vazirmatn(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ParentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🏅', style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 8),
                    Text(
                      PersianDigits.toFa(GameData.level),
                      style: AppFonts.vazirmatn(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE17055),
                      ),
                    ),
                    Text('سطح',
                        style: AppFonts.vazirmatn(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '📊',
                title: 'نقشه‌ی مهارت‌ها',
                subtitle: 'هر گوشه‌ی نمودار یک مهارت؛ هرچه پررنگ‌تر یعنی تسلط بیشتر',
              ),
              const SizedBox(height: 8),
              if (!hasData)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'هنوز تمرین کافی ثبت نشده. بعد از چند بازی آموزشی، این نمودار پر می‌شود 🌱',
                    style: TextStyle(height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Center(child: SkillRadarChart(skills: skills, size: 240)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // نقاط قوت و تمرین
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ParentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💪', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text('نقاط قوت',
                            style: AppFonts.vazirmatn(
                                fontWeight: FontWeight.w900, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (strongest.isEmpty || strongest.first.value == 0)
                      Text('هنوز ثبت نشده',
                          style: AppFonts.vazirmatn(
                              fontSize: 12, color: Colors.grey))
                    else
                      ...strongest.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LabeledProgress(
                            value: s.value / 100,
                            color: const Color(0xFF00B894),
                            label: '${_emoji[s.key] ?? ''} ${s.key}',
                            trailing: '${PersianDigits.toFa(s.value)}٪',
                            height: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ParentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text('نیازمند تمرین',
                            style: AppFonts.vazirmatn(
                                fontWeight: FontWeight.w900, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (focus.isEmpty)
                      Text('همه‌چیز تازه شروع شده',
                          style: AppFonts.vazirmatn(
                              fontSize: 12, color: Colors.grey))
                    else
                      ...focus.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LabeledProgress(
                            value: s.value / 100,
                            color: const Color(0xFFE17055),
                            label: '${_emoji[s.key] ?? ''} ${s.key}',
                            trailing: '${PersianDigits.toFa(s.value)}٪',
                            height: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // روند ۷ روزه
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '📈',
                title: 'روند ۷ روز اخیر',
                subtitle: 'میله‌ی پررنگ = یادگیری، کم‌رنگ = کل زمان',
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 130,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final d in trend)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor:
                                        (d.total / maxTrend).clamp(0.06, 1),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB2EBF2),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: FractionallySizedBox(
                                          heightFactor: d.total == 0
                                              ? 0
                                              : (d.learning / d.total)
                                                  .clamp(0, 1),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF00897B),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(PersianDigits.toFa(d.label),
                                  style: AppFonts.vazirmatn(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ParentInsights.balanceLabel,
                style: AppFonts.vazirmatn(
                  fontSize: 12.5,
                  color: ToneBanner.colorOf(ParentInsights.balanceTone),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // میانبرها
        Row(
          children: [
            Expanded(
              child: ParentCard(
                onTap: onOpenCertificates,
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('گواهی‌های افتخار',
                              style: AppFonts.vazirmatn(
                                  fontWeight: FontWeight.w900, fontSize: 14)),
                          Text('مدرک پیشرفت کودک',
                              style: AppFonts.vazirmatn(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ParentCard(
                onTap: onOpenVocabulary,
                child: Row(
                  children: [
                    const Text('📒', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('دفتر لغات',
                              style: AppFonts.vazirmatn(
                                  fontWeight: FontWeight.w900, fontSize: 14)),
                          Text(
                            '${PersianDigits.toFa(GrowthStore.vocabWords.length)} واژه',
                            style: AppFonts.vazirmatn(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
