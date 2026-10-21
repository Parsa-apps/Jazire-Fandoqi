import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../core/growth/persian_digits.dart';

/// 🎯 کارتِ هدفِ روزانه در صفحهٔ اصلیِ جزیرهٔ فندقی.
///
/// پیشرفتِ واقعیِ ایستگاه‌های روزانه (`TodayPath`) را بدونِ هیچ عددِ ساختگی
/// با ارقامِ فارسی و نوارِ پیشرفتِ طلایی نمایش می‌دهد.
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.taskTitle,
    required this.doneCount,
    required this.totalCount,
    required this.allDone,
    required this.onTap,
    this.isRestLimit = false,
    this.compact = false,
    this.height = 50,
  });

  final String taskTitle;
  final int doneCount;
  final int totalCount;
  final bool allDone;
  final bool isRestLimit;
  final bool compact;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalCount <= 0 ? 1 : totalCount;
    final clampedDone = doneCount.clamp(0, safeTotal);
    final progress = (clampedDone / safeTotal).clamp(0.0, 1.0);
    final doneFa = PersianDigits.toFa(clampedDone);
    final totalFa = PersianDigits.toFa(safeTotal);
    final counterLabel = '$doneFa از $totalFa';

    final statusSubtitle = isRestLimit
        ? 'زمانِ استراحتِ امروز'
        : allDone
            ? 'آفرین! همه کامل شد'
            : taskTitle;

    final badgeEmoji = isRestLimit
        ? '🌙'
        : allDone
            ? '🏆'
            : '🎯';

    return Semantics(
      button: true,
      label: 'هدف امروز: $statusSubtitle',
      value: counterLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            key: const ValueKey<String>('living_island_daily_goal_card'),
            height: height,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 12,
              vertical: compact ? 5 : 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xDE134E5E),
                  Color(0xEE082B35),
                ],
              ),
              border: Border.all(
                color: allDone
                    ? const Color(0xDDFFD54F)
                    : const Color(0xAA80DEEA),
                width: 1.5,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.26),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: compact ? 30 : 34,
                  height: compact ? 30 : 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: allDone
                          ? const <Color>[Color(0xFFFFF176), Color(0xFFFFA000)]
                          : const <Color>[Color(0xFF26A69A), Color(0xFF00695C)],
                    ),
                    border: Border.all(
                      color: const Color(0xCCFFF9C4),
                      width: 1.3,
                    ),
                  ),
                  child: Text(
                    badgeEmoji,
                    style: TextStyle(fontSize: compact ? 15 : 17),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'هدف امروز:',
                            maxLines: 1,
                            style: AppFonts.kids(
                              fontSize: compact ? 11.5 : 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFFF59D),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              statusSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.kids(
                                fontSize: compact ? 11.5 : 12.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          height: compact ? 6 : 7,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              const ColoredBox(color: Color(0x55FFFFFF)),
                              FractionallySizedBox(
                                alignment: AlignmentDirectional.centerStart,
                                widthFactor: progress,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Color(0xFFFFEE58),
                                        Color(0xFFFFB300),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 7 : 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFD54F),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xAAFFD54F),
                      width: 1.1,
                    ),
                  ),
                  child: Text(
                    counterLabel,
                    maxLines: 1,
                    style: AppFonts.kids(
                      fontSize: compact ? 11.5 : 12.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFF9C4),
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
