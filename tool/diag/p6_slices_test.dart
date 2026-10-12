// TEMPORARY diagnostic harness — deleted before the final build.
//
// P6: mount increasingly complex copies of the mini-game screen, one slice per
// test, simplest first. Every slice is marked in diag-logs/p6-progress.log, so
// the slice that hangs is the last one recorded. The last test mounts the real
// MiniGameScaffold as a control.
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_models.dart';
import 'package:jazireh_fandoghi/features/games/mini_games/mini_game_scaffold.dart';
import 'package:jazireh_fandoghi/shared/widgets/child_touch_target.dart';
import 'package:jazireh_fandoghi/shared/widgets/premium_button.dart';

final List<String> _trace = <String>[];

void step(String message) {
  _trace.add(message);
  print('[P6] $message');
  try {
    final file = File('diag-logs/p6-progress.log');
    if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
    file.writeAsStringSync('${_trace.join('\n')}\n');
  } catch (_) {}
}

Widget host(Widget child) => MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );

const _titles = ['۱ + ۱ چند می‌شود؟', '۲ + ۲ چند می‌شود؟'];

/// S1 — static layout only: no animations, no touch targets.
Widget sliceStatic({bool animatedContainer = false, bool touch = false}) {
  Widget card(String label) {
    final Widget box = animatedContainer
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 104,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30, width: 1.6),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 34,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        : Container(
            width: 104,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30, width: 1.6),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 34,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
    if (!touch) return box;
    return ChildTouchTarget(onTap: () {}, minSize: 64, child: box);
  }

  return Scaffold(
    body: DecoratedBox(
      decoration: BoxDecoration(gradient: AppGradients.primary),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'بازی آزمایشی 🧪',
                      textAlign: TextAlign.center,
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _titles[0],
                textAlign: TextAlign.center,
                style: AppFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(minHeight: 96, maxHeight: 170),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: Colors.white24),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('🧪', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [card('۲'), card('۳')],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'دور ۱ از ۳',
              style: AppFonts.vazirmatn(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}

/// S4/S5 — pulses every card with a repeating controller (the scaffold does).
class PulsingScreen extends StatefulWidget {
  final bool withSceneAnimation;
  final bool withButton;
  const PulsingScreen({
    super.key,
    this.withSceneAnimation = false,
    this.withButton = false,
  });

  @override
  State<PulsingScreen> createState() => _PulsingScreenState();
}

class _PulsingScreenState extends State<PulsingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = sliceStatic(animatedContainer: true, touch: true);
    Widget tree = base;
    if (widget.withSceneAnimation) {
      tree = Stack(
        children: [
          tree,
          const Positioned(
            left: 8,
            top: 8,
            child: SizedBox(width: 30, height: 30, child: Text('✨')),
          ),
        ],
      );
    }
    if (widget.withButton) {
      tree = Column(
        children: [
          Expanded(child: tree),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: PremiumButton(text: 'گذاشتم! ۲ تا 🧺', onPressed: () {}),
          ),
        ],
      );
    }
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) =>
          Transform.scale(scale: 1 + _pulse.value * 0.07, child: child),
      child: tree,
    );
  }
}

Future<void> mount(WidgetTester tester, String tag, Widget screen) async {
  step('$tag: pumpWidget begin');
  await tester.pumpWidget(host(screen));
  step('$tag: pumpWidget done');
  await tester.pump(const Duration(milliseconds: 100));
  step('$tag: first pump done');
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GameData.resetForTesting();
  });

  tearDown(FandoghiCoach.clear);

  testWidgets('P6-S1 static layout', (tester) async {
    await mount(tester, 'S1', sliceStatic());
  });

  testWidgets('P6-S2 animated containers + touch targets', (tester) async {
    await mount(tester, 'S2', sliceStatic(animatedContainer: true, touch: true));
  });

  testWidgets('P6-S3 repeating controller + scale wrapper', (tester) async {
    await mount(tester, 'S3', const PulsingScreen());
  });

  testWidgets('P6-S4 + scene animation + premium button', (tester) async {
    await mount(
      tester,
      'S4',
      const PulsingScreen(withSceneAnimation: true, withButton: true),
    );
  });

  testWidgets('P6-S5 real MiniGameScaffold (control)', (tester) async {
    await mount(
      tester,
      'S5',
      MiniGameScaffold(
        spec: const MiniGameSpec(
          title: 'بازی آزمایشی 🧪',
          gameId: 'بازی آزمایشی',
          skill: 'logic',
          missionId: 'logic',
          gradient: AppGradients.primary,
          introCoach: 'سلام! شروع کنیم',
          rewardCoach: 'تمام شد!',
          rounds: 1,
        ),
        roundFactory: () => <MiniGameRound>[
          MiniGameRound(
            prompt: _titles[0],
            scene: '🧪',
            options: [
              MiniGameOption('۲', correct: true),
              MiniGameOption('۳'),
            ],
            hint: 'دوتا یکی دیگه اضافه کن',
          ),
        ],
      ),
    );
  });
}
