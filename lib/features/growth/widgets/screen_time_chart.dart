import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../app/design_tokens.dart';
import '../../../core/growth/growth.dart';

class ScreenTimeChart extends StatelessWidget {
  const ScreenTimeChart({super.key});

  @override
  Widget build(BuildContext context) {
    final days = WeeklyEngine.last7Days();
    final maxMin = days.fold<int>(1, (m, d) => d.$2 > m ? d.$2 : m);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('زمان ۷ روز اخیر', style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('میله پررنگ = یادگیری  •  کم‌رنگ = کل زمان', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in days)
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
                                heightFactor: (day.$2 / maxMin).clamp(0.06, 1),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB2EBF2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: day.$2 == 0 ? 0 : (day.$3 / day.$2).clamp(0, 1),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00897B),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(day.$1, style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
