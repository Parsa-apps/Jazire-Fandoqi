import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/island_cinema_style.dart';
import '../../../core/audio_service.dart';
import '../painters/hero_cheer_burst_painter.dart';

/// کنترلرِ سبک برای جشن‌گرفتنِ فندقی از بیرونِ ویجت
class FandoqiHeroController {
  final ValueNotifier<int> _cheerTick = ValueNotifier<int>(0);

  ValueNotifier<int> get cheerTick => _cheerTick;

  void cheer() => _cheerTick.value++;

  void dispose() => _cheerTick.dispose();
}

/// 🐿️ فندقی — قهرمانِ سه‌بعدیِ صفحهٔ اصلی
class FandoqiHero extends StatefulWidget {
  const FandoqiHero({
    super.key,
    required this.size,
    this.controller,
    this.onTap,
    this.reduceMotion = false,
    this.semanticLabel = 'فندقی',
    this.imageOpacity = 1.0,
  });

  final double size;
  final FandoqiHeroController? controller;
  final VoidCallback? onTap;
  final bool reduceMotion;
  final String semanticLabel;

  /// در صفحهٔ اصلی که تصویرِ سه‌بعدیِ فندقی در `home_scene.webp` حضور دارد،
  /// با `imageOpacity: 0.0` از هم‌پوشانیِ دو تصویر جلوگیری می‌شود و در عینِ حال
  /// لمس، صدا و ذراتِ جشنِ طلایی روی کاراکتر فعال می‌مانند.
  final double imageOpacity;

  static const String waveAsset = 'assets/theme_v2/squirrel_hero.webp';
  static const String celebrateAsset = waveAsset;

  @override
  State<FandoqiHero> createState() => _FandoqiHeroState();
}

class _FandoqiHeroState extends State<FandoqiHero>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _breath;
  late final AnimationController _cheer;
  late final ValueNotifier<int> _stateTick;

  bool _blinking = false;
  bool _cheering = false;
  int _blinkIndex = 0;

  Timer? _blinkTimer;
  Timer? _cheerTimer;

  static const List<int> _blinkDelays = <int>[4200, 5400, 3600, 6100, 4800];
  static const Duration _blinkDuration = IslandCinemaMotion.heroBlink;

  @override
  void initState() {
    super.initState();
    _stateTick = ValueNotifier<int>(0);

    _entrance = AnimationController(
      vsync: this,
      duration: IslandCinemaMotion.heroEntrance,
    );
    _breath = AnimationController(
      vsync: this,
      duration: IslandCinemaMotion.heroBreath,
    );
    _cheer = AnimationController(
      vsync: this,
      duration: IslandCinemaMotion.heroCheer,
    );

    widget.controller?.cheerTick.addListener(_onExternalCheer);

    if (widget.reduceMotion) {
      _entrance.value = 1;
      _breath.value = 0.25;
    } else {
      _entrance.forward();
      _breath.repeat();
      _scheduleBlink();
    }
  }

  @override
  void didUpdateWidget(covariant FandoqiHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.cheerTick.removeListener(_onExternalCheer);
      widget.controller?.cheerTick.addListener(_onExternalCheer);
    }
    if (oldWidget.reduceMotion != widget.reduceMotion) {
      if (widget.reduceMotion) {
        _entrance.value = 1;
        _breath.stop();
        _breath.value = 0.25;
        _cheer.stop();
        _cheer.value = 0;
        _blinkTimer?.cancel();
        _blinkTimer = null;
        _cheerTimer?.cancel();
        _cheerTimer = null;
        _blinking = false;
        _cheering = false;
      } else {
        _breath.repeat();
        _scheduleBlink();
      }
      _bumpTick();
    }
  }

  void _bumpTick() => _stateTick.value++;

  void _onExternalCheer() {
    if (!mounted) return;
    _playCheer(silent: false);
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
    if (!mounted || widget.reduceMotion) return;
    final delay = _blinkDelays[_blinkIndex % _blinkDelays.length];
    _blinkIndex++;
    _blinkTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted || widget.reduceMotion) return;
      _blinking = true;
      _bumpTick();
      _blinkTimer = Timer(_blinkDuration, () {
        if (!mounted) return;
        _blinking = false;
        _bumpTick();
        _scheduleBlink();
      });
    });
  }

  void _playCheer({required bool silent}) {
    if (widget.reduceMotion) {
      HapticFeedback.selectionClick();
      if (!silent) AudioService.select();
      return;
    }
    _cheering = true;
    _cheer.forward(from: 0);
    _bumpTick();
    _cheerTimer?.cancel();
    _cheerTimer = Timer(IslandCinemaMotion.heroCheer, () {
      if (!mounted) return;
      _cheering = false;
      _bumpTick();
    });
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    AudioService.select();
    _playCheer(silent: true);
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _cheerTimer?.cancel();
    _blinkTimer = null;
    _cheerTimer = null;
    widget.controller?.cheerTick.removeListener(_onExternalCheer);
    _entrance.dispose();
    _breath.dispose();
    _cheer.dispose();
    _stateTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      onTap: _handleTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[
                _entrance,
                _breath,
                _cheer,
                _stateTick,
              ]),
              builder: (BuildContext context, Widget? _) {
                return _buildTransformed(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransformed(BuildContext context) {
    final enter = Curves.easeOutCubic.transform(_entrance.value);
    final entryDx = (1 - enter) * -widget.size * 0.55;
    final entryDy = (1 - enter) * -widget.size * 0.28;
    final entryRotation = (1 - enter) * -0.28;

    final breathWave = math.sin(_breath.value * 2 * math.pi);
    final breathScale = 1 + breathWave * 0.018;
    final breathDy = breathWave * widget.size * 0.008;

    final blinkSquash = _blinking ? 0.965 : 1.0;

    final cheerValue = _cheer.value;
    final bounce = cheerValue <= 0.0
        ? 0.0
        : math.sin(cheerValue * math.pi) * (1 - cheerValue * 0.35);
    final cheerScale = 1 + bounce * 0.10;
    final cheerDy = -bounce * widget.size * 0.055;
    final cheerRotation = bounce * math.sin(cheerValue * math.pi * 3) * 0.045;

    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
    final cacheWidth = (widget.size * dpr).round().clamp(96, 640);

    return Opacity(
      opacity: enter.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(entryDx, entryDy + breathDy + cheerDy),
        child: Transform.rotate(
          angle: entryRotation + cheerRotation,
          child: Transform.scale(
            scale: breathScale * cheerScale,
            alignment: Alignment.bottomCenter,
            child: Transform.scale(
              scaleY: blinkSquash,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (widget.imageOpacity > 0.0)
                    Positioned(
                      bottom: widget.size * 0.02,
                      child: Container(
                        width: widget.size * 0.52,
                        height: widget.size * 0.075,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            widget.size * 0.04,
                          ),
                          gradient: RadialGradient(
                            colors: <Color>[
                              IslandCinemaPalette.forestDeep.withOpacity(
                                0.34 * widget.imageOpacity,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  Opacity(
                    opacity: widget.imageOpacity.clamp(0.0, 1.0),
                    child: Image.asset(
                      _cheering
                          ? FandoqiHero.celebrateAsset
                          : FandoqiHero.waveAsset,
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      cacheWidth: cacheWidth,
                      excludeFromSemantics: true,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stack,
                      ) {
                        return Center(
                          child: Text(
                            '🌰',
                            style: TextStyle(fontSize: widget.size * 0.58),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_cheering)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: HeroCheerBurstPainter(
                            progress: _cheer.value,
                            color: IslandCinemaPalette.gold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
