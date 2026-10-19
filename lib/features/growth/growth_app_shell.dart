import 'package:flutter/material.dart';

import '../../core/growth/growth.dart';

/// پوسته سراسری: کاهش حرکت، حالت کوررنگی، بنر ساعت خواب.
///
/// بعد از انتقالِ راه‌اندازی به [StartupCoordinator]، تنظیماتِ والد ممکن
/// است *بعد از* اولین فریم برسند؛ پس این پوسته به تغییرات GrowthStore
/// گوش می‌دهد تا «کاهش حرکت» و «حالت کوررنگی» به‌محض خوانده‌شدن اعمال
/// شوند، نه یک اجرا دیرتر.
class GrowthAppShell extends StatelessWidget {
  final Widget child;

  const GrowthAppShell({super.key, required this.child});

  static const List<double> _colorBlindMatrix = <double>[
    0.625, 0.375, 0.0, 0, 0,
    0.70, 0.30, 0.0, 0, 0,
    0.0, 0.30, 0.70, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GrowthStore.changes,
      builder: (BuildContext context, Widget? _) {
        Widget tree = child;
        final mq = MediaQuery.of(context);
        final reduceMotion = GrowthStore.reduceMotion;
        // فقط وقتی مقدار عوض شده MediaQueryData تازه می‌سازیم؛ وگرنه هر
        // به‌روزرسانی GrowthStore کل درختِ وابسته به MediaQuery را
        // بی‌دلیل بازسازی می‌کرد.
        if (reduceMotion && !mq.disableAnimations) {
          tree = MediaQuery(
            data: mq.copyWith(disableAnimations: true),
            child: tree,
          );
        }
        if (GrowthStore.colorBlindMode) {
          tree = ColorFiltered(
            colorFilter: const ColorFilter.matrix(_colorBlindMatrix),
            child: tree,
          );
        }
        return tree;
      },
    );
  }
}
