import 'package:flutter/material.dart';

import '../../core/growth/growth.dart';

/// پوسته سراسری: کاهش حرکت، حالت کوررنگی، بنر ساعت خواب.
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
    Widget tree = child;
    final mq = MediaQuery.of(context);
    tree = MediaQuery(
      data: mq.copyWith(
        disableAnimations: mq.disableAnimations || GrowthStore.reduceMotion,
      ),
      child: tree,
    );
    if (GrowthStore.colorBlindMode) {
      tree = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_colorBlindMatrix),
        child: tree,
      );
    }
    return tree;
  }
}
