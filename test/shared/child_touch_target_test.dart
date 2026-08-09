import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amoozesh_fandoghi/shared/widgets/child_touch_target.dart';

void main() {
  testWidgets('ChildTouchTarget has a minimum 64px tap area', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChildTouchTarget(
              onTap: () => taps++,
              child: const Icon(Icons.star, size: 24),
            ),
          ),
        ),
      ),
    );

    final target = tester.getSize(find.byType(ChildTouchTarget));
    expect(target.width, greaterThanOrEqualTo(64));
    expect(target.height, greaterThanOrEqualTo(64));

    await tester.tap(find.byType(ChildTouchTarget));
    expect(taps, 1);
  });

  testWidgets('ChildPressable scales down while pressed and fires on release',
      (tester) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChildPressable(
              onPressed: () => presses++,
              child: const Text('فندقی'),
            ),
          ),
        ),
      ),
    );

    await tester.press(find.text('فندقی'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.release(find.text('فندقی'));
    await tester.pump();
    expect(presses, 1);
  });
}
