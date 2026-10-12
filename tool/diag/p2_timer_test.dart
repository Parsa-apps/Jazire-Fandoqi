// TEMPORARY diagnostic harness — deleted before the final build.
//
// P2: does a Timer that fires *inside* a long fake-time elapse hang?
//  P2a: Timer(10s) → setState (شبیه _hintTimer خودِ اسکافولد).
//  P2b: Timer(10s) → FandoghiCoach.say (شبیه راهنمای فندقی).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';

void note(String tag, String message) {
  final escaped = message
      .replaceAll('%', '%25')
      .replaceAll('\r', '%0D')
      .replaceAll('\n', '%0A');
  print('::error title=DIAG $tag::$escaped');
}

class TimerBox extends StatefulWidget {
  final VoidCallback onFire;
  const TimerBox({super.key, required this.onFire});

  @override
  State<TimerBox> createState() => _TimerBoxState();
}

class _TimerBoxState extends State<TimerBox> {
  Timer? _timer;
  int _fired = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 10), () {
      _fired++;
      widget.onFire();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text('fired=$_fired');
}

Widget host(Widget child) => MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  setUp(GameData.resetForTesting);
  tearDown(FandoghiCoach.clear);

  testWidgets('DIAG-P2a: Timer(10s) → setState, then 11s elapse',
      (tester) async {
    await tester.pumpWidget(host(TimerBox(onFire: () {})));
    note('P2a', 'mounted timer box');
    await tester.pump(const Duration(seconds: 11));
    note('P2a', 'after 11s — OK');
  });

  testWidgets('DIAG-P2b: Timer(10s) → FandoghiCoach.say, then 11s elapse',
      (tester) async {
    await tester.pumpWidget(
      host(TimerBox(onFire: () => FandoghiCoach.say('دوتا یکی دیگه اضافه کن'))),
    );
    note('P2b', 'mounted timer box (coach)');
    await tester.pump(const Duration(seconds: 11));
    note('P2b',
        'after 11s — OK; coach=${FandoghiCoach.current.value?.text ?? '(none)'}');
    await tester.pump(const Duration(seconds: 11));
    note('P2b', 'after second 11s — OK');
  });
}
