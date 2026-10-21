import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/island_atmosphere_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/island_crest_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/island_land_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/island_living_overlay_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/island_scene_geometry.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/island_sea_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/island_sky_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/path_icon_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/widgets/island_scene.dart';

/// 🎬 صحنهٔ جزیره باید در هر اندازه و هر تنظیمِ حرکت، بی‌خطا رسم شود.
///
/// نکته: این تست‌ها عمداً از `pumpAndSettle` استفاده نمی‌کنند چون
/// انیمیشنِ محیط بی‌پایان است؛ فقط چند فریم جلو می‌روند تا تیکرها
/// یک دور کامل بزنند.
void main() {
  setUp(() => GrowthStore.resetForTesting());

  tearDown(() => GrowthStore.reduceMotion = false);

  Future<void> pumpScene(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    bool reduceMotion = false,
  }) async {
    GrowthStore.reduceMotion = reduceMotion;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size, devicePixelRatio: 1),
          child: const SizedBox.expand(child: IslandScene()),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  IslandLivingOverlayPainter overlay(WidgetTester tester) {
    return tester.widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((widget) => widget.painter)
        .whereType<IslandLivingOverlayPainter>()
        .single;
  }

  testWidgets('ambient clock starts by default and stops in background',
      (WidgetTester tester) async {
    await pumpScene(tester);
    final clock = overlay(tester).animation;
    final before = clock.value;
    await tester.pump(const Duration(seconds: 1));
    expect(clock.value, isNot(before));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final paused = clock.value;
    await tester.pump(const Duration(seconds: 1));
    expect(clock.value, paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(clock.value, isNot(paused));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion freezes the living overlay',
      (WidgetTester tester) async {
    await pumpScene(tester, reduceMotion: true);
    final painter = overlay(tester);
    expect(painter.reduceMotion, isTrue);
    final before = painter.animation.value;
    await tester.pump(const Duration(seconds: 2));
    expect(painter.animation.value, before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('system reduced motion also freezes the ambient clock',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: IslandScene(),
      ),
    ));
    await tester.pump(const Duration(seconds: 1));
    expect(overlay(tester).reduceMotion, isTrue);
    expect(overlay(tester).animation.value, 0);
  });

  testWidgets('paints on a normal phone without errors',
      (WidgetTester tester) async {
    await pumpScene(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paints on a narrow phone without errors',
      (WidgetTester tester) async {
    await pumpScene(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);
  });

  testWidgets('paints on a tablet without errors',
      (WidgetTester tester) async {
    await pumpScene(tester, size: const Size(1024, 1366));
    expect(tester.takeException(), isNull);
  });

  testWidgets('paints with motion reduced without errors',
      (WidgetTester tester) async {
    await pumpScene(tester, reduceMotion: true);
    expect(tester.takeException(), isNull);
  });

  testWidgets('all scene painters render every icon and crest',
      (WidgetTester tester) async {
    // نکته: عنصرِ `for` در یک لیترالِ const مجاز نیست (const_eval_for_element)،
    // بنابراین فقط بخشِ ثابت const می‌ماند و گالریِ آیکون‌ها خارج از آن ساخته
    // می‌شود — هر دو حالتِ صحنه همچنان رسم می‌شوند.
    // روی سطحِ ۸۰۰×۶۰۰ تست، ستونِ همهٔ نقاش‌ها بلندتر از صفحه است؛
    // بدون اسکرول یک سرریزِ عمودی (و نه نقصِ طراحی) گزارش می‌شد.
    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(painter: IslandSkyPainter()),
              ),
              const SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(painter: IslandSeaPainter(phase: 0.35)),
              ),
              const SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(painter: IslandLandPainter(phase: 0.6)),
              ),
              const SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: IslandAtmospherePainter(phase: 0.2),
                ),
              ),
              const SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(painter: IslandCrestPainter()),
              ),
              for (final IslandPathIcon icon in IslandPathIcon.values)
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CustomPaint(
                    painter: PathIconPainter(
                      icon: icon,
                      baseColor: Colors.purple,
                      deepColor: Colors.indigo,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  // ─── هندسهٔ صحنه ───
  //
  // این بررسی‌ها داخل testWidgets اجرا می‌شوند تا اتصالِ موتورِ رسم
  // حتماً برقرار باشد (مسیرِ Path روی برخی نسخه‌های تست بدون binding
  // مقداردهی نمی‌شود).
  testWidgets('island geometry keeps every layer in a sane vertical order',
      (WidgetTester tester) async {
    final geo = IslandSceneGeometry(const Size(390, 844));

    // قله بالاتر از خطِ افق است (مقدارِ y کوچک‌تر) و ساحل پایین‌تر از هر دو.
    expect(geo.islandPeak, lessThan(geo.horizon));
    expect(geo.horizon, lessThan(geo.islandShore));
    // فندقی روی چمن می‌ایستد، نه روی آب.
    expect(geo.mascotAnchor.dy, lessThan(geo.islandShore));
    expect(geo.mascotAnchor.dy, greaterThan(geo.islandPeak));
    // آبشار از بالای صخره تا پایینِ ساحل می‌ریزد.
    expect(geo.fallTop, lessThan(geo.fallBottom));
    // برجستگیِ صخره از نوارِ ماسه قطورتر است.
    expect(geo.cliffThickness, greaterThan(geo.sandThickness));
  });

  testWidgets('island geometry scales proportionally with the viewport',
      (WidgetTester tester) async {
    const Size small = Size(320, 568);
    const Size large = Size(1024, 1366);
    final a = IslandSceneGeometry(small);
    final b = IslandSceneGeometry(large);

    expect(a.horizon / small.height, closeTo(b.horizon / large.height, 0.001));
    expect(
      a.islandPeak / small.height,
      closeTo(b.islandPeak / large.height, 0.001),
    );
    // فندقی همیشه وسطِ سکو می‌ایستد.
    expect(a.mascotAnchor.dx / small.width, closeTo(0.5, 0.001));
    expect(b.mascotAnchor.dx / large.width, closeTo(0.5, 0.001));
  });

  testWidgets('silhouette and garden path stay inside the frame',
      (WidgetTester tester) async {
    final geo = IslandSceneGeometry(const Size(390, 844));
    final silhouette = geo.islandSilhouette();
    final bounds = silhouette.getBounds();

    expect(bounds.width, greaterThan(0));
    expect(bounds.height, greaterThan(0));
    // سیلوئت عمداً از دو طرف از کادر بیرون می‌زند تا لبهٔ بریده دیده نشود.
    expect(bounds.left, lessThanOrEqualTo(0));
    expect(bounds.right, greaterThanOrEqualTo(390));

    final pathBounds = geo.gardenPath().getBounds();
    expect(pathBounds.top, greaterThanOrEqualTo(bounds.top));
    expect(pathBounds.bottom, lessThanOrEqualTo(bounds.bottom + geo.h * 0.02));
  });
}
