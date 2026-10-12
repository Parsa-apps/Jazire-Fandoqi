// TEMPORARY diagnostic harness — deleted before the final build.
//
// Answers two questions about the cartoons gate:
//  1. Does `GameData.reload()` complete inside a widget test?
//  2. Does `pumpAndSettle()` (used by the real test's `openGate`) ever settle
//     after `reload()` has populated SharedPreferences?
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/cartoons/online_cartoon_gate.dart';

/// Publishes a line as a check annotation so the finding survives even when the
/// Actions log backend is unreachable.
void note(String tag, String message) {
  final escaped = message
      .replaceAll('%', '%25')
      .replaceAll('\r', '%0D')
      .replaceAll('\n', '%0A');
  print('::error title=DIAG $tag::$escaped');
}

Widget host() => MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (homeContext) => Center(
            child: FilledButton(
              onPressed: () => Navigator.of(homeContext).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OnlineCartoonGate(child: Text('HUB')),
                ),
              ),
              child: const Text('OPEN_GATE'),
            ),
          ),
        ),
      ),
    );

void main() {
  setUp(() {
    GameData.resetForTesting();
    OnlineCartoonGate.resetForTesting();
  });

  testWidgets('DIAG-A1: reload completes and the old-user flag is read',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      {'cartoon_parent_disclosure_shown': true},
    );
    note('A1', 'prefs mock set; awaiting reload');
    await GameData.reload().timeout(const Duration(seconds: 20));
    final flag = GameData.getBool('cartoon_parent_disclosure_shown');
    note('A1', 'reload finished; flag=$flag');
    expect(flag, isTrue);
  });

  testWidgets('DIAG-A2: gate with bounded pumps (no pumpAndSettle)',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      {'cartoon_parent_disclosure_shown': true},
    );
    await GameData.reload().timeout(const Duration(seconds: 20));
    await tester.pumpWidget(host());
    await tester.tap(find.text('OPEN_GATE'));
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    final full = find
        .text('اطلاعیه به والدین عزیز — پیش از ورود')
        .evaluate()
        .length;
    final short = find.text('کارتون‌کده بخش آنلاین بازی است').evaluate().length;
    note('A2', 'bounded pumps done: fullNotice=$full shortNotice=$short');
  });

  testWidgets('DIAG-A3: does pumpAndSettle ever return?', (tester) async {
    SharedPreferences.setMockInitialValues(
      {'cartoon_parent_disclosure_shown': true},
    );
    await GameData.reload().timeout(const Duration(seconds: 20));
    await tester.pumpWidget(host());
    await tester.tap(find.text('OPEN_GATE'));
    note('A3', 'before pumpAndSettle');
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    final short = find.text('کارتون‌کده بخش آنلاین بازی است').evaluate().length;
    note('A3', 'pumpAndSettle returned; shortNotice=$short');
  });

  testWidgets('DIAG-A4: same flow without reload (control)', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('OPEN_GATE'));
    note('A4', 'before pumpAndSettle (no reload)');
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    final full = find
        .text('اطلاعیه به والدین عزیز — پیش از ورود')
        .evaluate()
        .length;
    note('A4', 'pumpAndSettle returned; fullNotice=$full');
  });
}
