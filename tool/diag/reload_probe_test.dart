// TEMPORARY diagnostic harness — deleted before the final build.
//
// The cartoons gate test hangs on `GameData.reload()`. Each probe below is
// wrapped in a bounded pump loop, so a Future that only needs fake time to
// elapse is detected instead of blocking the whole file forever.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/security/secure_store.dart';
import 'package:jazireh_fandoghi/data/datasources/hive_player_store.dart';

void note(String tag, String message) {
  final escaped = message
      .replaceAll('%', '%25')
      .replaceAll('\r', '%0D')
      .replaceAll('\n', '%0A');
  print('::error title=DIAG $tag::$escaped');
}

/// Runs [probe] and pumps bounded frames (so fake timers can fire) until it
/// completes or [seconds] of fake time have elapsed.
Future<bool> completes(
  WidgetTester tester,
  Future<void> Function() probe, {
  int seconds = 5,
}) async {
  var done = false;
  var error = '';
  // Deliberately not awaited: the pump loop below drives it.
  probe().then<void>(
    (_) => done = true,
    onError: (Object e) {
      done = true;
      error = e.toString();
    },
  );
  for (var i = 0; i < seconds && !done; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
  if (error.isNotEmpty) note('PROBE', 'probe error: $error');
  return done;
}

void main() {
  setUp(GameData.resetForTesting);

  testWidgets('DIAG-P0: GameData.resetForTesting leaves memory storage on',
      (tester) async {
    note('P0', 'isLoaded=${GameData.isLoaded}');
    final snapshot = await HivePlayerStore.readSnapshot().timeout(
      const Duration(seconds: 5),
    );
    note('P0', 'readSnapshot=$snapshot');
  });

  testWidgets('DIAG-P1: SharedPreferences.getInstance', (tester) async {
    SharedPreferences.setMockInitialValues(
      {'cartoon_parent_disclosure_shown': true},
    );
    final ok = await completes(tester, () async {
      final prefs = await SharedPreferences.getInstance();
      note('P1', 'getInstance ok; flag=${prefs.getBool('cartoon_parent_disclosure_shown')}');
    });
    note('P1', 'completed=$ok');
  });

  testWidgets('DIAG-P2: HivePlayerStore.readSnapshot (memory)', (tester) async {
    final ok = await completes(tester, () async {
      final snapshot = await HivePlayerStore.readSnapshot();
      note('P2', 'readSnapshot=$snapshot');
    });
    note('P2', 'completed=$ok');
  });

  testWidgets('DIAG-P3: SecureStore.read', (tester) async {
    final ok = await completes(tester, () async {
      final value = await SecureStore.read('parent_pin_hash');
      note('P3', 'secure read=$value');
    });
    note('P3', 'completed=$ok');
  });

  testWidgets('DIAG-P4: GameData.reload with pumping', (tester) async {
    SharedPreferences.setMockInitialValues(
      {'cartoon_parent_disclosure_shown': true},
    );
    final ok = await completes(
      tester,
      () => GameData.reload(),
      seconds: 10,
    );
    note(
      'P4',
      'reload completed=$ok flag=${GameData.getBool('cartoon_parent_disclosure_shown')}',
    );
  });

  testWidgets('DIAG-P5: GameData.save with pumping', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ok = await completes(tester, () => GameData.save(), seconds: 10);
    note('P5', 'save completed=$ok');
  });
}
