import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/design_tokens.dart';
import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/game_data.dart';
import '../../core/jalali_calendar.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🔥 PREMIUM STREAK CALENDAR — پیشنهاد پریمیوم شماره ۳۳
/// تقویم ۷ روزه شمسی + شعله Streak + قلب یخی + جایزه
/// ═══════════════════════════════════════════════════════════════
class PremiumStreakCalendar extends StatelessWidget {
  final VoidCallback? onHeartIceTap;
  final VoidCallback? onCalendarTap;

  const PremiumStreakCalendar({super.key, this.onHeartIceTap, this.onCalendarTap});

  @override
  Widget build(BuildContext context) {
    final jalaliToday = JalaliDate.today();
    final streak = GameData.streak;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // شبیه‌سازی ۷ روز اخیر بر اساس streak (ساده ولی واقعی‌نما)
    final days = _buildLast7Days(streak);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: isDark ? Colors.white12 : Colors.white, width: 1.5),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          // هدر
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFFD23F)]),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Text('🔥', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('$streak روز پشت سر هم', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1F3A5F))),
                        const SizedBox(width: 6),
                        if (streak >= 7)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(AppRadii.pill)),
                            child: Text('هفته طلایی!', style: AppFonts.vazirmatn(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black87)),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.6)),
                      ],
                    ),
                    Text('${jalaliToday.day} ${jalaliToday.monthName} ${jalaliToday.year} — ${streak == 0 ? "امروز شروع کن!" : "آفرین! ادامه بده"}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (onCalendarTap != null) onCalendarTap!();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('تقویم', style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ۷ روز
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = days[index];
              final isToday = index == 6;
              final isDone = day.done;
              final jalali = day.jalali;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: index == 6 ? 0 : 6),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF00B894).withOpacity(0.12)
                        : isToday
                            ? AppColors.primary.withOpacity(0.08)
                            : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F3F8)),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: isDone ? const Color(0xFF00B894) : isToday ? AppColors.primary.withOpacity(0.4) : Colors.transparent, width: isDone || isToday ? 1.5 : 1),
                  ),
                  child: Column(
                    children: [
                      Text(_weekdayName(index), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isToday ? AppColors.primary : (isDark ? Colors.white54 : Colors.black45))),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? const Color(0xFF00B894) : isToday ? AppColors.primary : Colors.transparent,
                          border: Border.all(color: isDone ? const Color(0xFF00B894) : Colors.black12),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                              : Text('${jalali.day}', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: isToday ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF1F3A5F)))),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(isDone ? '✅' : isToday ? '⭐' : '—', style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ).animate(delay: (index * 70).ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
              );
            }),
          ),
          const SizedBox(height: 14),
          // نوار پیشرفت تا جایزه ۷ روزه + قلب یخی
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('جایزه هفته طلایی تا ۷ روز', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black54)),
                        const Spacer(),
                        Text('${(streak % 7)}/7', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: LinearProgressIndicator(
                        value: (streak % 7) / 7,
                        minHeight: 8,
                        backgroundColor: (isDark ? Colors.white12 : const Color(0xFFE8E8E8)),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(streak >= 7 ? '🎉 جایزه‌ات آماده‌ست! فردا هم بیا' : 'فقط ${7 - (streak % 7)} روز دیگه تا صندوق طلایی!', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (onHeartIceTap != null) onHeartIceTap!();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: streak == 0 ? [const Color(0xFF74B9FF), const Color(0xFF0984E3)] : [const Color(0xFF00CEC9), const Color(0xFF00B894)]),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    boxShadow: AppShadows.colored(streak == 0 ? const Color(0xFF74B9FF) : const Color(0xFF00B894), opacity: 0.3),
                  ),
                  child: Column(
                    children: [
                      Text(streak == 0 ? '🧊' : '❄️', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(streak == 0 ? 'قلب یخی' : 'محافظ', style: AppFonts.vazirmatn(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text(streak == 0 ? '۵۰ سکه' : 'فعال', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -3, duration: 1500.ms, curve: Curves.easeInOut),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0, curve: AppMotion.entrance);
  }

  List<_Day> _buildLast7Days(int streak) {
    final now = DateTime.now();
    final days = <_Day>[];
    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final jalali = JalaliDate.fromGregorian(date);
      // ساده: اگر streak >= (7 - i) یعنی آن روز بازی کرده
      final positionFromEnd = 6 - i; // 0 = 6 روز پیش، 6 = امروز
      final done = streak > 0 && positionFromEnd >= (7 - streak).clamp(0, 7);
      // همیشه امروز اگر streak>0 انجام شده فرض کن
      final isTodayDone = i == 0 && streak > 0;
      days.add(_Day(jalali, done || isTodayDone));
    }
    // اگر streak 0، هیچ روزی done نیست
    if (streak == 0) return days.map((d) => _Day(d.jalali, false)).toList();
    return days;
  }

  String _weekdayName(int indexFromStart) {
    // شنبه = 0 ... جمعه = 6 — ساده بر اساس امروز
    const names = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
    final todayWeekday = DateTime.now().weekday % 7; // شنبه 6؟ ساده
    // نمایش ساده: ۷ حرف متوالی
    return names[(indexFromStart) % 7];
  }
}

class _Day {
  final JalaliDate jalali;
  final bool done;
  const _Day(this.jalali, this.done);
}
