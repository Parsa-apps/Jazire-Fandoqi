// TEMPORARY diagnostic harness — deleted before the final build.
//
// P1: does advancing fake time by 11 seconds hang *by itself*?
//  P1a: خالی — control (no animation, no timers).
//  P1b: یک AnimationController تکرارشونده (مثل نبض Hint) بدون هیچ تایمری.
// اگر P1b معلق شود، مشکل «کنترلر تکرارشونده + elapse بلند» است و ربطی به
// منطق بازی ندارد.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void note(String tag, String message) {
  final escaped = message
      .replaceAll('%', '%25')
      .replaceAll('\r', '%0D')
      .replaceAll('\n', '%0A');
  print('::error title=DIAG $tag::$escaped');
}

class RepeatBox extends StatefulWidget {
  const RepeatBox({super.key});

  @override
  State<RepeatBox> createState() => _RepeatBoxState();
}

class _RepeatBoxState extends State<RepeatBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Transform.scale(
        scale: 1 + _ctrl.value * 0.07,
        child: const SizedBox(width: 48, height: 48),
      ),
    );
  }
}

Widget host(Widget child) => MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('DIAG-P1a: empty tree — one 11s elapse', (tester) async {
    await tester.pumpWidget(host(const SizedBox.shrink()));
    note('P1a', 'mounted empty tree');
    await tester.pump(const Duration(seconds: 11));
    note('P1a', 'after 11s — OK');
  });

  testWidgets('DIAG-P1b: repeating controller — 11s elapse twice',
      (tester) async {
    await tester.pumpWidget(host(const RepeatBox()));
    await tester.pump(const Duration(milliseconds: 100));
    note('P1b', 'mounted repeating controller');
    await tester.pump(const Duration(seconds: 11));
    note('P1b', 'after 11s #1');
    await tester.pump(const Duration(seconds: 11));
    note('P1b', 'after 11s #2 — OK');
  });
}
