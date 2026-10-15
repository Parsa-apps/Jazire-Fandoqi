import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/app/island_world_style.dart';
import 'package:jazireh_fandoghi/features/home/widgets/island_map/island_node.dart';

/// فندقیِ قهرمان باید زنده باشد: هنگام لمس برای لحظه‌ای لباس جشن
/// واقعی‌اش را بپوشد و چرخهٔ پلک‌زدن بدون خطا اجرا شود.
void main() {
  testWidgets('hero swaps to the real celebrate artwork while cheering',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_HeroHarness(onTap: () => taps++));
    await tester.pump(const Duration(milliseconds: 300));

    expect(_heroAsset(tester), IslandWorldAssets.fandoghiWave);

    await tester.tap(find.byType(HeroFandoq));
    // فریم واسط: رویداد لمس پردازش و کنترلر جشن تازه شروع می‌شود؛
    // بدون آن، فریم بعدی هنوز elapsed صفر را نشان می‌دهد.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(taps, 1);
    expect(_heroAsset(tester), IslandWorldAssets.fandoghiCelebrate);

    // پایان جشن: برگشت به حالت دست‌تکان
    await tester.pump(const Duration(milliseconds: 700));
    expect(_heroAsset(tester), IslandWorldAssets.fandoghiWave);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('hero blink cycle runs without errors', (tester) async {
    await tester.pumpWidget(_HeroHarness(onTap: () {}));
    // عبور از چند چرخهٔ شناوری/پلک (هر چرخه ۵ ثانیه)
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 450));
    }
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
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

class _HeroHarness extends StatefulWidget {
  final VoidCallback onTap;

  const _HeroHarness({required this.onTap});

  @override
  State<_HeroHarness> createState() => _HeroHarnessState();
}

class _HeroHarnessState extends State<_HeroHarness>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // محیط تست ممکن است «کاهش حرکت» را فعال گزارش کند؛ اینجا صریحاً
        // حرکت را روشن می‌کنیم چون رفتارِ مورد آزمون همین است. (در خودِ
        // برنامه، خاموشیِ سیستم محترم شمرده می‌شود.)
        body: MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: Center(
            child: HeroFandoq(
              width: 140,
              floatAnimation: _floatCtrl,
              onTap: widget.onTap,
            ),
          ),
        ),
      ),
    );
  }
}
