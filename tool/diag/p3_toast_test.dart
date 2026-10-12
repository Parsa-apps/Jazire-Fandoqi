// TEMPORARY diagnostic harness — deleted before the final build.
//
// P3: is the coach toast itself (AnimatedSwitcher + فندقی سخنگو) the thing that
// hangs a long elapse?
//  P3a: پیام از همان ابتدا روی صفحه است و بعد ۱۱ ثانیه جلو می‌رویم.
//  P3b: پیام با Timer(10s) می‌آید (همان الگوی _hintTimer اسکافولد).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/shared/widgets/fandoghi_coach.dart';

void note(String tag, String message) {
  final escaped = message
      .replaceAll('%', '%25')
      .replaceAll('\r', '%0D')
      .replaceAll('\n', '%0A');
  print('::error title=DIAG $tag::$escaped');
}

Widget host(Widget child) => MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      home: FandoghiCoachOverlay(
        child: Scaffold(body: Center(child: child)),
      ),
    );

class SayAfter extends StatefulWidget {
  final Duration delay;
  final String text;
  const SayAfter({super.key, required this.delay, required this.text});

  @override
  State<SayAfter> createState() => _SayAfterState();
}

class _SayAfterState extends State<SayAfter> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () => FandoghiCoach.say(widget.text));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 40, height: 40);
}

void main() {
  setUp(GameData.resetForTesting);
  tearDown(FandoghiCoach.clear);

  testWidgets('DIAG-P3a: toast visible, then one 11s elapse', (tester) async {
    await tester.pumpWidget(host(const SizedBox.shrink()));
    FandoghiCoach.say('دوتا یکی دیگه اضافه کن');
    await tester.pump(const Duration(milliseconds: 100));
    note('P3a', 'toast rendered; text widgets=${find.textContaining('دوتا').evaluate().length}');
    await tester.pump(const Duration(seconds: 11));
    note('P3a', 'after 11s — OK');
  });

  testWidgets('DIAG-P3b: toast arrives at t=10s, one 11s elapse',
      (tester) async {
    await tester.pumpWidget(
      host(const SayAfter(delay: Duration(seconds: 10), text: 'دوتا یکی دیگه اضافه کن')),
    );
    note('P3b', 'mounted SayAfter(10s)');
    await tester.pump(const Duration(seconds: 11));
    note('P3b',
        'after 11s — OK; coach=${FandoghiCoach.current.value?.text ?? '(none)'}');
  });
}
