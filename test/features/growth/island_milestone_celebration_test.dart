import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/growth/island_milestone_celebration.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎉 تست جشن گواهی افتخار نقاط عطف سطح جزیره — نسخهٔ ۷.۱
/// ═══════════════════════════════════════════════════════════════
void main() {
  setUp(() {
    GameData.resetForTesting();
  });

  test('نقاط عطف جشن گواهی دقیقاً سطوح ۳/۵/۷/۹ هستند', () {
    for (final level in [3, 5, 7, 9]) {
      expect(IslandMilestoneCelebration.isMilestone(level), isTrue);
    }
    for (final level in [1, 2, 4, 6, 8, 10, 11]) {
      expect(IslandMilestoneCelebration.isMilestone(level), isFalse);
    }
  });

  testWidgets('جشن گواهی: نمایش گواهی با نام کودک و لقب و بستن آن', (tester) async {
    GameData.childName = 'نگار';
    GameData.xp = 1050; // مرز سطح ۷ — «قهرمان جزیره»

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () =>
                    IslandMilestoneCelebration.show(context, level: 7),
                child: const Text('CELEBRATE'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('CELEBRATE'));
    await tester.pumpAndSettle();

    expect(find.text('گواهی افتخار جدید!'), findsOneWidget);
    expect(find.text('نگار'), findsOneWidget);
    expect(find.text('به سطح ۷ — قهرمان جزیره رسید'), findsOneWidget);
    expect(find.text('گواهی «قهرمان جزیره»'), findsOneWidget);

    await tester.tap(find.text('ادامهٔ بازی ⭐'));
    await tester.pumpAndSettle();
    expect(find.text('گواهی افتخار جدید!'), findsNothing);
  });

  testWidgets('سطح غیرِ‌نقطه‌عطف: جشنی نمایش داده نمی‌شود', (tester) async {
    GameData.xp = 300; // سطح ۴ — نقطهٔ عطف نیست

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () =>
                    IslandMilestoneCelebration.show(context, level: 4),
                child: const Text('CELEBRATE'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('CELEBRATE'));
    await tester.pumpAndSettle();

    expect(find.text('گواهی افتخار جدید!'), findsNothing);
  });

  testWidgets('کپی متن گواهی: دکمهٔ کپی تأییدِ درون‌دیالوگی می‌گیرد', (tester) async {
    GameData.childName = 'علی';
    GameData.xp = 1800; // مرز سطح ۹ — «افسانه جزیره»

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () =>
                    IslandMilestoneCelebration.show(context, level: 9),
                child: const Text('CELEBRATE'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('CELEBRATE'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('کپی متن گواهی'));
    await tester.pump();

    expect(find.text('کپی شد ✓'), findsOneWidget);
    expect(find.text('گواهی «افسانه جزیره»'), findsOneWidget);
  });
}
