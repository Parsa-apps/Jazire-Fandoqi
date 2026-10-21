import 'package:flutter/material.dart';

import '../../../app/island_cinema_style.dart';
import '../../../core/growth/growth_store.dart';
import '../painters/island_atmosphere_painter.dart';
import '../painters/island_land_painter.dart';
import '../painters/island_sea_painter.dart';
import '../painters/island_sky_painter.dart';

/// 🎬 صحنهٔ زنده و سه‌بعدیِ جزیره فندقی.
///
/// تصویرِ سه‌بعدیِ اصلیِ جزیره و فندقی (`assets/theme_v2/home_scene.webp`)
/// را به‌همراهِ لایه‌های پشتیبان و ذراتِ درخشانِ محیطی نمایش می‌دهد.
class IslandScene extends StatefulWidget {
  const IslandScene({
    super.key,
    this.child,
    this.sparkleCount = IslandCinemaMetrics.sparkleBudget,
  });

  final Widget? child;
  final int sparkleCount;

  static const String homeSceneAsset = 'assets/theme_v2/home_scene.webp';

  @override
  State<IslandScene> createState() => _IslandSceneState();
}

class _IslandSceneState extends State<IslandScene>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ambient;

  bool _reduceMotion = false;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ambient = AnimationController(
      vsync: this,
      duration: IslandCinemaMotion.ambientLoop,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final systemReduce =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final next = systemReduce || GrowthStore.reduceMotion;
    if (next == _reduceMotion) return;
    _reduceMotion = next;
    _syncAmbient();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final paused = state != AppLifecycleState.resumed;
    if (paused == _paused) return;
    _paused = paused;
    _syncAmbient();
  }

  void _syncAmbient() {
    if (!mounted) return;
    if (_reduceMotion || _paused) {
      _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ambient.dispose();
    super.dispose();
  }

  int get _effectiveSparkles {
    final budget = widget.sparkleCount;
    if (_reduceMotion) return (budget / 2).floor();
    return budget;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ambient,
      builder: (BuildContext context, Widget? child) {
        final phase = _ambient.value;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // لایه‌های پشتیبانِ برداری
            const RepaintBoundary(
              child: CustomPaint(
                painter: IslandSkyPainter(),
                size: Size.infinite,
              ),
            ),
            RepaintBoundary(
              child: CustomPaint(
                painter: IslandSeaPainter(
                  phase: phase,
                  reduceMotion: _reduceMotion,
                ),
                size: Size.infinite,
              ),
            ),
            RepaintBoundary(
              child: CustomPaint(
                painter: IslandLandPainter(
                  phase: phase,
                  reduceMotion: _reduceMotion,
                ),
                size: Size.infinite,
              ),
            ),
            // تصویرِ سه‌بعدیِ اصلیِ جزیره و سنجابِ ماجراجو (مطابقِ طرحِ مرجع)
            Positioned.fill(
              child: RepaintBoundary(
                child: Image.asset(
                  IslandScene.homeSceneAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                  excludeFromSemantics: true,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stack,
                  ) {
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
            // لایهٔ اتمسفر و ذراتِ نورِ طلایی
            RepaintBoundary(
              child: CustomPaint(
                painter: IslandAtmospherePainter(
                  phase: phase,
                  reduceMotion: _reduceMotion,
                  sparkleCount: _effectiveSparkles,
                ),
                size: Size.infinite,
              ),
            ),
            if (child != null) child,
          ],
        );
      },
      child: widget.child,
    );
  }
}
