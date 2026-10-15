import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/features/home/widgets/island_map/hub_island_node.dart';

/// نمایش صادقانهٔ قفل در هاب‌ها: سکوی قفل‌شده باید صریحاً بگوید
/// «نسخه کامل» (هم دیداری، هم برای صفحه‌خوان) و سکوی باز هیچ نشانی
/// نداشته باشد.
void main() {
  testWidgets('locked hub node shows the honest full-version badge',
      (tester) async {
    await tester.pumpWidget(_harness(locked: true));
    await tester.pump();

    expect(find.text('نسخه کامل'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('با نسخه کامل')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unlocked hub node shows no lock badge', (tester) async {
    await tester.pumpWidget(_harness(locked: false));
    await tester.pump();

    expect(find.text('نسخه کامل'), findsNothing);
    expect(find.byIcon(Icons.lock_rounded), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Widget _harness({required bool locked}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: HubIslandNode(
          label: 'واژگان',
          emoji: '📚',
          width: 170,
          floatPhase: 0,
          floatAnimation: const AlwaysStoppedAnimation<double>(0.2),
          locked: locked,
          onTap: () {},
        ),
      ),
    ),
  );
}
