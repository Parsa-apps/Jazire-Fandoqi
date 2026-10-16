import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/features/shop/content_lock.dart';
import 'package:jazireh_fandoghi/shared/widgets/animated_gold_lock.dart';

Widget _host(
  Widget child, {
  bool disableAnimations = false,
  bool accessibleNavigation = false,
  bool tickersEnabled = true,
}) =>
    MediaQuery(
      data: MediaQueryData(
        disableAnimations: disableAnimations,
        accessibleNavigation: accessibleNavigation,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TickerMode(
          enabled: tickersEnabled,
          child: Center(child: child),
        ),
      ),
    );

CustomPaint _paint(WidgetTester tester) => tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(AnimatedGoldLock),
        matching: find.byType(CustomPaint),
      ),
    );

Future<List<int>> _pixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.descendant(
      of: find.byType(AnimatedGoldLock),
      matching: find.byType(RepaintBoundary),
    ),
  );
  // Image readback needs the real event loop, not the fake animation clock.
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      return bytes!.buffer.asUint8List().toList();
    } finally {
      image.dispose();
    }
  }))!;
}

void main() {
  testWidgets('gold lock actually animates without rebuilding the widget',
      (tester) async {
    var builds = 0;
    await tester.pumpWidget(_host(Builder(builder: (_) {
      builds++;
      return const AnimatedGoldLock(size: 80);
    })));
    final painter = _paint(tester).painter;
    final before = await _pixels(tester);

    await tester.pump(const Duration(milliseconds: 800));
    final after = await _pixels(tester);

    expect(after, isNot(orderedEquals(before)));
    expect(builds, 1);
    expect(_paint(tester).painter, same(painter));
    expect(_paint(tester).willChange, isTrue);
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.binding.transientCallbackCount, 0);
  });

  for (final setting in ['reduced motion', 'accessible navigation']) {
    testWidgets('$setting leaves a visible static gold lock', (tester) async {
      await tester.pumpWidget(_host(
        const AnimatedGoldLock(size: 80),
        disableAnimations: setting == 'reduced motion',
        accessibleNavigation: setting == 'accessible navigation',
      ));
      final before = await _pixels(tester);
      await tester.pump(const Duration(seconds: 4));
      final after = await _pixels(tester);

      expect(after, orderedEquals(before));
      expect(before.any((channel) => channel != 0), isTrue);
      expect(_paint(tester).willChange, isFalse);
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('changing reduced-motion preference stops and restarts the loop',
      (tester) async {
    await tester.pumpWidget(_host(const AnimatedGoldLock()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_paint(tester).willChange, isTrue);

    await tester.pumpWidget(_host(
      const AnimatedGoldLock(),
      disableAnimations: true,
    ));
    expect(_paint(tester).willChange, isFalse);
    expect(tester.binding.transientCallbackCount, 0);

    await tester.pumpWidget(_host(const AnimatedGoldLock()));
    expect(_paint(tester).willChange, isTrue);
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('TickerMode pauses hidden locks and resumes visible ones',
      (tester) async {
    await tester.pumpWidget(_host(
      const AnimatedGoldLock(),
      tickersEnabled: false,
    ));
    expect(_paint(tester).willChange, isFalse);
    expect(tester.binding.transientCallbackCount, 0);

    await tester.pumpWidget(_host(const AnimatedGoldLock()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(_paint(tester).willChange, isTrue);
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    await tester.pumpWidget(_host(
      const AnimatedGoldLock(),
      tickersEnabled: false,
    ));
    expect(_paint(tester).willChange, isFalse);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('explicit static rendering can be changed at runtime',
      (tester) async {
    await tester.pumpWidget(_host(const AnimatedGoldLock(animated: false)));
    expect(_paint(tester).willChange, isFalse);
    expect(tester.binding.transientCallbackCount, 0);

    await tester.pumpWidget(_host(const AnimatedGoldLock()));
    expect(_paint(tester).willChange, isTrue);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpWidget(_host(const AnimatedGoldLock(animated: false)));
    expect(_paint(tester).willChange, isFalse);
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small badges and the large denied-page lock stay bounded in RTL',
      (tester) async {
    for (final size in [16.0, 24.0, 36.0, 44.0, 128.0]) {
      await tester.pumpWidget(_host(AnimatedGoldLock(size: size)));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.getSize(find.byType(AnimatedGoldLock)), Size.square(size));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('lock has an honest localized accessible image label',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(_host(const AnimatedGoldLock(animated: false)));
      expect(
        tester.getSemantics(find.byType(AnimatedGoldLock)),
        matchesSemantics(
          label: 'قفل؛ با نسخهٔ کامل باز می‌شود',
          isImage: true,
        ),
      );
    } finally {
      // Flutter 3.24 verifies handles before package:test tearDown callbacks.
      semantics.dispose();
    }
  });

  testWidgets('tapping the gold overlay still reaches the paid card handler',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(GestureDetector(
      onTap: () => taps++,
      child: const LockedCardOverlay(
        locked: true,
        child: SizedBox(
          width: 120,
          height: 90,
          child: ColoredBox(color: Colors.blue),
        ),
      ),
    )));
    await tester.tapAt(tester.getCenter(find.byType(AnimatedGoldLock)));
    expect(taps, 1);
    expect(find.byType(AnimatedGoldLock), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unlocking removes the gold overlay and disposes its ticker',
      (tester) async {
    const child = SizedBox(width: 120, height: 90, child: Text('محتوا'));
    await tester.pumpWidget(_host(
      const LockedCardOverlay(locked: true, child: child),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AnimatedGoldLock), findsOneWidget);
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    await tester.pumpWidget(_host(
      const LockedCardOverlay(locked: false, child: child),
    ));
    await tester.pump(const Duration(seconds: 4));
    expect(find.byType(AnimatedGoldLock), findsNothing);
    expect(find.text('محتوا'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });
}
