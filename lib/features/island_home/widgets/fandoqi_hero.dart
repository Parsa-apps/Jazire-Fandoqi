import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/island_cinema_style.dart';
import '../../../core/audio_service.dart';
import '../painters/hero_cheer_burst_painter.dart';

/// کنترلرِ سبک برای جشن‌گرفتنِ فندقی از بیرونِ ویجت
/// (مثلاً وقتی کودک از یک فعالیت برمی‌گردد و موفق شده است).
class FandoqiHeroController {
  final ValueNotifier<int> _cheerTick = ValueNotifier<int>(0);

  /// شمارنده‌ای که با هر جشن زیاد می‌شود
  ValueNotifier<int> get cheerTick => _cheerTick;

  /// تشویقِ کوتاهِ فندقی
  void cheer() => _cheerTick.value++;

  void dispose() => _cheerTick.dispose();
}

/// ═══════════════════════════════════════════════════════════════
/// 🐿️ فندقی — مرکزِ احساسیِ صفحهٔ اصلی
///
/// رفتارها (همه کوتاه، نرم و هدفمند):
///   * ورود: از پشتِ برگِ بالای کادر می‌لغزد، می‌چرخد و محو می‌شود؛
///   * تنفس: دم‌وبازدمِ خیلی ملایم (۱٫۸٪) — هرگز حواس‌پرت‌کن نیست؛
///   * پلک: مکثِ ۱۵۰ میلی‌ثانیه‌ایِ چهره با فاصله‌های نامنظم؛
///   * لمس: پرشِ کوتاه + لباسِ جشن + درخشش + لرزشِ ملایم؛
///   * جشنِ بیرونی: با [FandoqiHeroController] از هر صفحه‌ای.
///
/// نکتهٔ صادقانهٔ فنی: دارایی‌های فعلیِ فندقی دو تصویرِ تخت‌اند
/// (`fandoghi_wave_v2` و `fandoghi_celebrate_v2`) و هیچ لایهٔ
/// جداگانه‌ای برای پلک ندارند. «پلک» اینجا به‌شکلِ یک مکثِ کوتاهِ
/// چهره اجرا شده است، نه بازوبستنِ واقعیِ پلک؛ پیاده‌سازیِ پلکِ
/// واقعی نیازمند داراییِ لایه‌بندی‌شده یا ریگِ انیمیشن است.
/// ═══════════════════════════════════════════════════════════════
class FandoqiHero extends StatefulWidget {
  const FandoqiHero({
    super.key,
    required this.size,
    this.controller,
    this.onTap,
    this.reduceMotion = false,
    this.semanticLabel = 'فندقی',
  });

  /// قطرِ ناحیهٔ لمسی و تصویر
  final double size;

  /// برای جشن‌گرفتن از بیرون (اختیاری)
  final FandoqiHeroController? controller;

  /// لمسِ کودک
  final VoidCallback? onTap;

  /// حالتِ کاهشِ حرکت: همهٔ حرکت‌ها ثابت می‌شوند
  final bool reduceMotion;

  final String semanticLabel;

  static const String waveAsset = 'assets/mascot/fandoghi_wave_v2.webp';
  static const String celebrateAsset =
      'assets/mascot/fandoghi_celebrate_v2.webp';

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

  /// فاصله‌های نامنظمِ پلک (میلی‌ثانیه) — تکرارِ ماشینی ندارد
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
    if (!mounted || widget.reduceMotion) return;
    final delay = _blinkDelays[_blinkIndex % _blinkDelays.length];
    _blinkIndex++;
    Future<void>.delayed(Duration(milliseconds: delay), () {
      if (!mounted || widget.reduceMotion) return;
      _blinking = true;
      _bumpTick();
      Future<void>.delayed(_blinkDuration, () {
        if (!mounted) return;
        _blinking = false;
        _bumpTick();
        _scheduleBlink();
      });
    });
  }

  void _playCheer({required bool silent}) {
    if (widget.reduceMotion) {
      // حتی در کاهشِ حرکت، یک بازخوردِ کوتاه و بی‌خطر بده
      HapticFeedback.selectionClick();
      if (!silent) AudioService.select();
      return;
    }
    _cheering = true;
    _cheer.forward(from: 0);
    _bumpTick();
    Future<void>.delayed(IslandCinemaMotion.heroCheer, () {
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
    // ورود از پشتِ برگ (بالا-چپ) همراه با یک چرخشِ کوچک
    final entryDx = (1 - enter) * -widget.size * 0.55;
    final entryDy = (1 - enter) * -widget.size * 0.28;
    final entryRotation = (1 - enter) * -0.28;

    // تنفس
    final breathWave = math.sin(_breath.value * 2 * math.pi);
    final breathScale = 1 + breathWave * 0.018;
    final breathDy = breathWave * widget.size * 0.008;

    // پلک: مکثِ کوتاهِ چهره
    final blinkSquash = _blinking ? 0.965 : 1.0;

    // جشن: پرشِ نرم با فرودِ کنترل‌شده
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
                  // سایهٔ زیرِ پا
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
                            IslandCinemaPalette.forestDeep.withOpacity(0.34),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    // فقط پرچمِ _cheering تصویر را عوض می‌کند، نه مقدارِ
                    // کنترلر: مقدارِ کنترلر بعد از پایان روی ۱ می‌ماند و
                    // اگر مبنا قرار بگیرد فندقی تا ابد لباسِ جشن می‌پوشد.
                    _cheering
                        ? FandoqiHero.celebrateAsset
                        : FandoqiHero.waveAsset,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    cacheWidth: cacheWidth,
                    excludeFromSemantics: true,
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stack) {
                      // هرگز جای خالی نمایش نده: اگر تصویر در دسترس نبود،
                      // نشانِ فندقی با ایموجی رسم می‌شود.
                      return Center(
                        child: Text(
                          '🌰',
                          style: TextStyle(fontSize: widget.size * 0.58),
                        ),
                      );
                    },
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
