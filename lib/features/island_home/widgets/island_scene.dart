import 'package:flutter/material.dart';

import '../../../app/island_cinema_style.dart';
import '../../../core/growth/growth_store.dart';
import '../painters/island_atmosphere_painter.dart';

/// 🎬 صحنهٔ زنده و سه‌بعدیِ جزیره فندقی.
///
/// تصویرِ سه‌بعدیِ اصلیِ جزیره و فندقی (`assets/theme_v2/home_scene.webp`)
/// کاملاً کدر است (VP8 بدونِ کانالِ آلفا با ابعادِ ۱۰۷۲×۱۹۲۰ و `BoxFit.cover`)،
/// بنابراین نقاش‌های برداریِ زیرین (آسمان، دریا، خشکی) حذف شده‌اند تا در هر فریم
/// بازرسمِ پنهان رخ ندهد و فقط ذراتِ درخشانِ محیطی (`IslandAtmospherePainter`) رسم شوند.
class IslandScene extends StatefulWidget {
  const IslandScene({
    super.key,
    this.child,
    this.sparkleCount = IslandCinemaMetrics.sparkleBudget,
  });

  final Widget? child;
  final int sparkleCount;

  static const String homeSceneAsset = 'assets/theme_v2/home_scene.webp';

  /// ابعادِ پیکسلیِ واقعیِ تصویرِ `assets/theme_v2/home_scene.webp`.
  static const Size homeSceneImageSize = Size(1072, 1920);

  /// مستطیلِ نرمال‌شدهٔ سنجابِ پخته‌شده درونِ `home_scene.webp` (۱۰۷۲×۱۹۲۰):
  /// از نوکِ دم در چپ (`0.210`) تا پنجهٔ راست (`0.692`) و از نوکِ گوش‌ها (`0.530`)
  /// تا کفِ پاها روی مسیرِ خاکی (`0.812`).
  static const Rect bakedSquirrelNormalizedRect = Rect.fromLTRB(
    0.210,
    0.530,
    0.692,
    0.812,
  );

  /// مختصاتِ افقیِ نرمال‌شدهٔ مرکزِ سرِ سنجاب در `home_scene.webp` (بینِ دو گوش).
  static const double bakedSquirrelHeadNormalizedX = 0.492;

  /// نگاشتِ یک مستطیلِ نرمال‌شده در فضایِ `home_scene.webp` به مختصاتِ واقعیِ صحنه
  /// دقیقاً مطابقِ `BoxFit.cover` و `Alignment.center`.
  static Rect projectNormalizedRect(
    Size sceneSize,
    Rect normalizedRect, {
    Alignment alignment = Alignment.center,
  }) {
    if (sceneSize.isEmpty) return Rect.zero;
    final fitted = applyBoxFit(BoxFit.cover, homeSceneImageSize, sceneSize);
    final dest = alignment.inscribe(
      fitted.destination,
      Offset.zero & sceneSize,
    );
    return Rect.fromLTRB(
      dest.left + dest.width * normalizedRect.left,
      dest.top + dest.height * normalizedRect.top,
      dest.left + dest.width * normalizedRect.right,
      dest.top + dest.height * normalizedRect.bottom,
    );
  }

  /// مستطیلِ پیکسلیِ سنجابِ پخته‌شده روی صحنه در ابعادِ فعلیِ نما.
  static Rect bakedSquirrelRect(Size sceneSize) =>
      projectNormalizedRect(sceneSize, bakedSquirrelNormalizedRect);

  /// مختصاتِ افقیِ مرکزِ سرِ سنجاب روی صحنه در ابعادِ فعلیِ نما.
  static double bakedSquirrelHeadX(Size sceneSize) {
    if (sceneSize.isEmpty) return 0;
    final fitted = applyBoxFit(BoxFit.cover, homeSceneImageSize, sceneSize);
    final dest = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & sceneSize,
    );
    return dest.left + dest.width * bakedSquirrelHeadNormalizedX;
  }

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
    GrowthStore.changes.addListener(_onGrowthChanged);
    _ambient = AnimationController(
      vsync: this,
      duration: IslandCinemaMotion.ambientLoop,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateReduceMotion();
  }

  void _onGrowthChanged() {
    if (!mounted) return;
    final changed = _updateReduceMotion();
    if (changed) setState(() {});
  }

  bool _updateReduceMotion() {
    final systemReduce =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final next = systemReduce || GrowthStore.reduceMotion;
    final changed = next != _reduceMotion;
    _reduceMotion = next;
    _syncAmbient();
    return changed;
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
    GrowthStore.changes.removeListener(_onGrowthChanged);
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
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // رنگِ پایهٔ سبک برای لحظهٔ بارگذاری یا خطای احتمالیِ تصویر
        const ColoredBox(color: IslandCinemaPalette.seaDeep),
        // تصویرِ سه‌بعدیِ کدرِ جزیره و فندقی (بیرون از AnimatedBuilder تا هر فریم بازسازی نشود)
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
        // تنها لایهٔ متحرکِ محیط: ذراتِ نورِ طلایی در RepaintBoundary ایزوله
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _ambient,
                builder: (BuildContext context, Widget? _) {
                  return CustomPaint(
                    painter: IslandAtmospherePainter(
                      phase: _ambient.value,
                      reduceMotion: _reduceMotion,
                      sparkleCount: _effectiveSparkles,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}
