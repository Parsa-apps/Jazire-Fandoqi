import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/app/island_world_style.dart';
import 'package:jazireh_fandoghi/features/home/widgets/island_map/island_node.dart';

void main() {
  testWidgets('map hero uses the new waving character artwork', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _HeroTestScreen()));

    final image = tester.widget<Image>(find.byType(Image));
    expect(
      _assetImageFrom(image.image).assetName,
      IslandWorldAssets.fandoghiWave,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

AssetImage _assetImageFrom(ImageProvider<Object> provider) {
  if (provider is ResizeImage) {
    return _assetImageFrom(provider.imageProvider);
  }
  return provider as AssetImage;
}

class _HeroTestScreen extends StatefulWidget {
  const _HeroTestScreen();

  @override
  State<_HeroTestScreen> createState() => _HeroTestScreenState();
}

class _HeroTestScreenState extends State<_HeroTestScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _floatAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: HeroFandoq(
          width: 120,
          floatAnimation: _floatAnimation,
          onTap: () {},
        ),
      ),
    );
  }
}
