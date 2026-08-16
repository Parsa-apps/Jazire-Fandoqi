import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../../../core/growth/parent_insights.dart';
import '../widgets/parent_widgets.dart';

/// تب زمان و امنیت: سهمیه روزانه، ساعت خواب، سکوت شب، سلامت چشم.
class ParentTimeTab extends StatefulWidget {
  const ParentTimeTab({super.key});

  @override
  State<ParentTimeTab> createState() => _ParentTimeTabState();
}

class _ParentTimeTabState extends State<ParentTimeTab> {
  @override
  Widget build(BuildContext context) {
    final limit = GameData.timeLimitMinutes;
    final used = ParentInsights.todayPlayMinutes;
    final ratio = ParentInsights.dailyBudgetRatio;
    final remaining = ParentInsights.dailyBudgetRemainingMinutes;
    final barColor = ratio > 0.85
        ? const Color(0xFFE17055)
        : ratio > 0.5
            ? const Color(0xFFFDCB6E)
            : const Color(0xFF00B894);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // سهمیه روزانه
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '⏱️',
                title: 'سهمیه‌ی روزانه‌ی صفحه',
                subtitle:
                    'وقتی زمان تمام شود، اپ به‌جز لالایی، بقیه بخش‌ها را می‌بندد. یادگیری و سرگرمی با هم شمرده می‌شوند.',
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PersianDigits.toFa(limit),
                    style: AppFonts.vazirmatn(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('دقیقه در روز',
                        style: AppFonts.vazirmatn(
                            fontSize: 14, color: Colors.grey)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LabeledProgress(
                value: ratio,
                color: barColor,
                height: 14,
                label:
                    '${PersianDigits.toFa(used)} دقیقه استفاده شده از ${PersianDigits.toFa(limit)}',
                trailing:
                    '${PersianDigits.toFa(remaining)} دقیقه باقی‌مانده',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _stepButton(
                      icon: Icons.remove_rounded,
                      label: '۱۵ دقیقه کمتر',
                      color: const Color(0xFFE17055),
                      enabled: limit > 15,
                      onTap: () {
                        final next = (limit - 15).clamp(15, 240);
                        GameData.setTimeLimitMinutes(next);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _stepButton(
                      icon: Icons.add_rounded,
                      label: '۱۵ دقیقه بیشتر',
                      color: const Color(0xFF00B894),
                      enabled: limit < 240,
                      onTap: () {
                        final next = (limit + 15).clamp(15, 240);
                        GameData.setTimeLimitMinutes(next);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _quickChips(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // هدف هفتگی یادگیری
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '🎯',
                title: 'هدف یادگیری هفته',
                subtitle:
                    'این هدف فقط زمان «یادگیری واقعی» را می‌شمارد، نه کارتون. هدف واقع‌بینانه برای خردسالان ۳۰ تا ۶۰ دقیقه در هفته است.',
              ),
              const SizedBox(height: 12),
              Text(
                '${PersianDigits.toFa(GrowthStore.weeklyGoalMinutes)} دقیقه در هفته',
                style: AppFonts.vazirmatn(
                    fontSize: 22, fontWeight: FontWeight.w900),
              ),
              Slider(
                min: 10,
                max: 180,
                divisions: 34,
                value: GrowthStore.weeklyGoalMinutes.toDouble(),
                label:
                    '${PersianDigits.toFa(GrowthStore.weeklyGoalMinutes)} دقیقه',
                onChanged: (v) => setState(
                  () => GrowthStore.setWeeklyGoal(minutes: v.round()),
                ),
              ),
              LabeledProgress(
                value: ParentInsights.weeklyGoalRatio,
                color: const Color(0xFF00B894),
                label:
                    '${PersianDigits.toFa(ParentInsights.weekLearningMinutes)} دقیقه یادگیری این هفته',
                trailing:
                    '${PersianDigits.toFa((ParentInsights.weeklyGoalRatio * 100).round())}٪',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ساعت خواب
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                emoji: '🌙',
                title: 'ساعت خواب',
                subtitle:
                    'از ${PersianDigits.toFa(GrowthStore.bedtimeHour)} شب تا ${PersianDigits.toFa(GrowthStore.wakeHour)} صبح فقط لالایی باز است.',
              ),
              ParentSwitchTile(
                title: 'فعال‌سازی ساعت خواب',
                subtitle: 'در این ساعات بخش‌های محرک بسته می‌شوند',
                value: GrowthStore.bedtimeEnabled,
                icon: Icons.nightlight_round,
                onChanged: (v) =>
                    setState(() => GrowthStore.setBedtime(enabled: v)),
              ),
              if (GrowthStore.bedtimeEnabled) ...[
                const Divider(height: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'ساعت شروع خواب: ${PersianDigits.toFa(GrowthStore.bedtimeHour)}',
                    style: AppFonts.vazirmatn(fontSize: 12),
                  ),
                ),
                Slider(
                  min: 18,
                  max: 23,
                  divisions: 5,
                  value: GrowthStore.bedtimeHour.toDouble(),
                  label: '${GrowthStore.bedtimeHour}',
                  onChanged: (v) => setState(() =>
                      GrowthStore.setBedtime(enabled: true, hour: v.round())),
                ),
                Text(
                  'ساعت بیداری: ${PersianDigits.toFa(GrowthStore.wakeHour)}',
                  style: AppFonts.vazirmatn(fontSize: 12),
                ),
                Slider(
                  min: 5,
                  max: 10,
                  divisions: 5,
                  value: GrowthStore.wakeHour.toDouble(),
                  label: '${GrowthStore.wakeHour}',
                  onChanged: (v) => setState(() =>
                      GrowthStore.setBedtime(enabled: true, wake: v.round())),
                ),
              ],
              const Divider(height: 8),
              ParentSwitchTile(
                title: 'سکوت شب',
                subtitle: 'در ساعت خواب صداها خودکار قطع شوند',
                value: GrowthStore.quietHoursEnabled,
                icon: Icons.volume_off_rounded,
                onChanged: (v) =>
                    setState(() => GrowthStore.setQuietHours(v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // سلامت چشم
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '👀',
                title: 'سلامت چشم و بدن',
                subtitle:
                    'قانون ۲۰-۲۰-۲۰: هر ۲۰ دقیقه، ۲۰ ثانیه به فاصله‌ی دور نگاه کند و تحرک داشته باشد.',
              ),
              const SizedBox(height: 8),
              ToneBanner(
                emoji: '🩺',
                title: 'توصیه‌ی معلم',
                body: GameData.todayPlayMinutes > 60
                    ? 'امروز بیش از یک ساعت صفحه ثبت شده. یک فعالیت بدنی یا بازی در فضای باز پیشنهاد می‌شود 🌳'
                    : 'الگوی استفاده امروز متعادل به نظر می‌رسد. استراحت‌های کوتاه را حفظ کنید ⭐',
                tone: GameData.todayPlayMinutes > 60
                    ? ColorTone.warn
                    : ColorTone.good,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 4),
                Text(label,
                    style: AppFonts.vazirmatn(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickChips() {
    final presets = const [15, 30, 45, 60, 90];
    return Wrap(
      spacing: 8,
      children: [
        for (final p in presets)
          ChoiceChip(
            label: Text('${PersianDigits.toFa(p)} دقیقه'),
            selected: GameData.timeLimitMinutes == p,
            onSelected: (_) {
              GameData.setTimeLimitMinutes(p);
              setState(() {});
            },
          ),
      ],
    );
  }
}
