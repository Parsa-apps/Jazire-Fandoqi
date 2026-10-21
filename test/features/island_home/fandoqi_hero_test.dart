import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/features/island_home/painters/hero_cheer_burst_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/widgets/fandoqi_hero.dart';

/// 🐿️ فندقی باید زنده باشد: نفس بکشد، پلک بزند، به لمس واکنش نشان
/// بدهد و با جشنِ بیرونی هماهنگ شود — بدون هیچ خطا در چرخهٔ عمر.
void main() {
  testWidgets('breathing and blink cycles run without errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: FandoqiHero(size: 160)),
      ),
    );
    await tester.pump();

    // چند چرخهٔ نفس (۳٫۴ ثانیه) و چند پلک (فاصله‌ها ۳٫۶ تا ۶٫۱ ثانیه)
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 600));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping swaps to the real celebrate artwork and back',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: FandoqiHero(size: 160)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(_heroAsset(tester), FandoqiHero.waveAsset);

    await tester.tap(find.byType(FandoqiHero));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(_heroAsset(tester), FandoqiHero.celebrateAsset);

    // پایانِ جشن: برگشت به حالتِ دست‌تکان‌دادن
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    expect(_heroAsset(tester), FandoqiHero.waveAsset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an external controller can cheer the hero',
      (WidgetTester tester) async {
    final controller = FandoqiHeroController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Center(child: FandoqiHero(size: 160, controller: controller)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(_heroAsset(tester), FandoqiHero.waveAsset);

    controller.cheer();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(_heroAsset(tester), FandoqiHero.celebrateAsset);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    expect(_heroAsset(tester), FandoqiHero.waveAsset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion keeps the hero visible and static',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: FandoqiHero(size: 160, reduceMotion: true)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(_heroAsset(tester), FandoqiHero.waveAsset);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(tester.takeException(), isNull);
  });

  test('the cheer burst painter is a no-op outside its animation window', () {
    const painter = HeroCheerBurstPainter(progress: 0, color: Colors.amber);
    final opposite = HeroCheerBurstPainter(progress: 0.5, color: Colors.amber);
    expect(painter.shouldRepaint(opposite), isTrue);
    expect(
      painter.shouldRepaint(
        const HeroCheerBurstPainter(progress: 0, color: Colors.amber),
      ),
      isFalse,
    );
  });
}

String _heroAsset(WidgetTester tester) {
  final images = tester.widgetList<Image>(find.byType(Image)).toList();
  expect(images, hasLength(1));
  return _assetNameOf(images.single.image);
}

String _assetNameOf(ImageProvider<Object> provider) {
  if (provider is ResizeImage) return _assetNameOf(provider.imageProvider);
  return (provider as AssetImage).assetName;
}
