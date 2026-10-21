import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/island_atmosphere_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/island_crest_painter.dart';
import 'package:jazireh_fandoghi/features/island_home/painters/island_land_painter.dart';
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
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: <Widget>[
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(painter: IslandSkyPainter()),
            ),
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: IslandSeaPainter(phase: 0.35),
              ),
            ),
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: IslandLandPainter(phase: 0.6),
              ),
            ),
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: IslandAtmospherePainter(phase: 0.2),
              ),
            ),
            SizedBox(
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
