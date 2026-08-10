import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/design_tokens.dart';
import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/game_data.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎯 PREMIUM DAILY MISSIONS — پیشنهاد ۵۲
/// ۳ مأموریت روزانه با rollover نیمه‌شب، نوار پیشرفت و جایزه
/// ═══════════════════════════════════════════════════════════════
class PremiumDailyMissions extends StatelessWidget {
  final VoidCallback? onClaimChest;

  const PremiumDailyMissions({super.key, this.onClaimChest});

  static const List<_MissionMeta> _metas = [
    _MissionMeta(id: 'questions', title: '۵ سوال جواب بده', emoji: '❓', color: Color(0xFF6C5CE7), reward: '۸ سکه'),
    _MissionMeta(id: 'math', title: '۳ مسابقه ریاضی', emoji: '🧮', color: Color(0xFFFF6B6B), reward: '۱۰ سکه'),
    _MissionMeta(id: 'memory', title: '۱ بازی حافظه', emoji: '🧠', color: Color(0xFF00B894), reward: '۶ سکه'),
    _MissionMeta(id: 'alphabet', title: '۱ حرف بنویس', emoji: '✍️', color: Color(0xFFFF8E53), reward: '۸ سکه'),
    _MissionMeta(id: 'colors', title: 'آزمایش رنگ', emoji: '🎨', color: Color(0xFF00CEC9), reward: '۶ سکه'),
    _MissionMeta(id: 'drawing', title: '۱ نقاشی بکش', emoji: '🖌️', color: Color(0xFFBA68C8), reward: '۵ سکه'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // انتخاب ۳ مأموریت روزانه (چرخشی بر اساس روز سال)
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final todays = [
      _metas[dayOfYear % _metas.length],
      _metas[(dayOfYear + 2) % _metas.length],
      _metas[(dayOfYear + 4) % _metas.length],
    ];

    final allDone = todays.every((m) => GameData.isMissionDone(m.id));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: allDone ? const Color(0xFFFFD700).withOpacity(0.5) : Colors.white.withOpacity(0.8), width: allDone ? 2 : 1.5),
        boxShadow: allDone ? AppShadows.colored(const Color(0xFFFFD700), opacity: 0.25) : AppShadows.medium,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(gradient: AppGradients.sunset, borderRadius: BorderRadius.circular(AppRadii.md)),
                child: const Text('🎯', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مأموریت‌های امروز', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1F3A5F))),
                    Text(allDone ? 'همه انجام شد! صندوق باز شد 🎉' : 'هر روز ۳ مأموریت جدید — نیمه‌شب عوض می‌شود', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: allDone ? const Color(0xFFFFD700) : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: allDone ? const Color(0xFFFFD700) : AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(allDone ? Icons.celebration_rounded : Icons.flag_rounded, size: 14, color: allDone ? Colors.black87 : AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${todays.where((m) => GameData.isMissionDone(m.id)).length}/3', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: allDone ? Colors.black87 : AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...todays.asMap().entries.map((entry) {
            final idx = entry.key;
            final meta = entry.value;
            final progress = GameData.missionValue(meta.id);
            final target = GameData.missionTargets[meta.id] ?? 1;
            final done = progress >= target;
            return Padding(
              padding: EdgeInsets.only(bottom: idx == 2 ? 0 : 10),
              child: AnimatedContainer(
                duration: AppMotion.normal,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: done ? meta.color.withOpacity(0.10) : (isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF8F9FE)),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: done ? meta.color.withOpacity(0.35) : Colors.black.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: done ? meta.color : Colors.white, shape: BoxShape.circle, border: Border.all(color: done ? meta.color : Colors.black12), boxShadow: done ? [BoxShadow(color: meta.color.withOpacity(0.3), blurRadius: 8)] : null),
                      child: Center(child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 22) : Text(meta.emoji, style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meta.title, style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF2D3436))),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            child: LinearProgressIndicator(value: (progress / target).clamp(0.0, 1.0), minHeight: 6, backgroundColor: isDark ? Colors.white12 : Colors.black.withOpacity(0.08), valueColor: AlwaysStoppedAnimation<Color>(done ? meta.color : AppColors.primary)),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text('$progress از $target', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: done ? const Color(0xFF00B894).withOpacity(0.15) : Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: done ? const Color(0xFF00B894).withOpacity(0.3) : Colors.black12)),
                                child: Text(done ? 'انجام شد ✓' : meta.reward, style: AppFonts.vazirmatn(fontSize: 10, fontWeight: FontWeight.w800, color: done ? const Color(0xFF00B894) : const Color(0xFF636E72))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: (idx * 80).ms).fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
            );
          }).toList(),
          if (allDone) ...[
            const SizedBox(height: 12),
            Semantics(
              button: onClaimChest != null && GameData.canClaimDailyMissionChest,
              label: GameData.canClaimDailyMissionChest
                  ? 'دریافت صندوق روزانه، بیست سکه'
                  : 'صندوق روزانه دریافت شده',
              child: GestureDetector(
                onTap: GameData.canClaimDailyMissionChest ? onClaimChest : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: GameData.canClaimDailyMissionChest
                        ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8E53)])
                        : null,
                    color: GameData.canClaimDailyMissionChest
                        ? null
                        : Colors.grey.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    boxShadow: GameData.canClaimDailyMissionChest
                        ? AppShadows.colored(const Color(0xFFFFD700))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        GameData.canClaimDailyMissionChest ? '🎁' : '✅',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        GameData.canClaimDailyMissionChest
                            ? 'دریافت صندوق روزانه: +۲۰ سکه'
                            : 'صندوق روزانه دریافت شد',
                        style: AppFonts.vazirmatn(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: GameData.canClaimDailyMissionChest
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.12, end: 0);
  }
}

class _MissionMeta {
  final String id;
  final String title;
  final String emoji;
  final Color color;
  final String reward;
  const _MissionMeta({required this.id, required this.title, required this.emoji, required this.color, required this.reward});
}
