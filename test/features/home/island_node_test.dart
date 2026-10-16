import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/app/island_world_style.dart';
import 'package:jazireh_fandoghi/features/home/widgets/island_map/island_decorations.dart';
import 'package:jazireh_fandoghi/features/home/widgets/island_map/island_node.dart';
import 'package:jazireh_fandoghi/shared/widgets/animated_gold_lock.dart';

/// تست‌های بازطراحی صفحهٔ جزیره: سکوها باید برچسب خوانا داشته باشند،
/// لمسشان دقیقاً به همان مقصد قبلی برود و سکوی قفل‌شده هرگز مسیری را
/// باز نکند. لایهٔ تزئینات هم باید هر چهار دارایی اختصاصی را رندر کند.
void main() {
  testWidgets('island node shows its label and fires its tap destination',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_NodeHarness(onTap: () => taps++));
    // ورود پلکانی سکو کامل شود
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('کارتون‌ها'), findsOneWidget);

    await tester.tap(find.byType(IslandNode));
    await tester.pump();
    expect(taps, 1);

    // انفجار ستارهٔ لمس تا انتها اجرا و تمام شود
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('locked island node never fires its tap destination',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_NodeHarness(onTap: () => taps++, locked: true));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(AnimatedGoldLock), findsOneWidget);

    await tester.tap(find.byType(IslandNode));
    await tester.pump();
    expect(taps, 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('island node entrance is fully visible after its delay',
      (tester) async {
    await tester.pumpWidget(
      _NodeHarness(
        onTap: () {},
        entranceDelay: const Duration(milliseconds: 300),
      ),
    );
    // فریم اول تایمر تأخیر را رد می‌کند، فریم دوم خود انیمیشن ورود را
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 800));

    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(IslandNode),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('decorations layer renders all four island artworks',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 900,
            child: IslandDecorations(
              width: 400,
              mapHeight: 900,
              floatAnimation: AlwaysStoppedAnimation<double>(0.3),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final assets = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(
      assets,
      containsAll(<String>[
        IslandWorldAssets.decorRainbow,
        IslandWorldAssets.decorBalloon,
        IslandWorldAssets.decorPalmTree,
        IslandWorldAssets.decorBlossomTree,
      ]),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('hero fandoghi reacts to tap and keeps waving artwork',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_HeroHarness(onTap: () => taps++));
    await tester.pump(const Duration(milliseconds: 300));

    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images, hasLength(1));
    expect(
      _assetNameOf(images.single.image),
      IslandWorldAssets.fandoghiWave,
    );

    await tester.tap(find.byType(HeroFandoq));
    await tester.pump();
    expect(taps, 1);

    // پرش جشنِ لمس کامل شود
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

/// نام دارایی از روی ImageProvider — با cacheWidth، پروایدر واقعی
/// ResizeImage است و باید یک لایه باز شود.
String _assetNameOf(ImageProvider<Object> provider) {
  if (provider is ResizeImage) return _assetNameOf(provider.imageProvider);
  return (provider as AssetImage).assetName;
}

class _NodeHarness extends StatefulWidget {
  final VoidCallback onTap;
  final bool locked;
  final Duration entranceDelay;

  const _NodeHarness({
    required this.onTap,
    this.locked = false,
    this.entranceDelay = Duration.zero,
  });

  @override
  State<_NodeHarness> createState() => _NodeHarnessState();
}

class _NodeHarnessState extends State<_NodeHarness>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: IslandNode(
            asset: 'assets/theme_map/island_cartoon.png',
            label: 'کارتون‌ها',
            width: 220,
            floatPhase: 0.1,
            floatAnimation: _float,
            onTap: widget.onTap,
            locked: widget.locked,
            entranceDelay: widget.entranceDelay,
          ),
        ),
      ),
    );
  }
}

class _HeroHarness extends StatefulWidget {
  final VoidCallback onTap;

  const _HeroHarness({required this.onTap});

  @override
  State<_HeroHarness> createState() => _HeroHarnessState();
}

class _HeroHarnessState extends State<_HeroHarness>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: HeroFandoq(
            width: 120,
            floatAnimation: _float,
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}
