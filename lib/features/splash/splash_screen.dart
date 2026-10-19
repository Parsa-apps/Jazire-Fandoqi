import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/parsa_brand.dart';
import '../../core/game_data.dart';
import '../../core/growth/growth_store.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/startup/startup_coordinator.dart';
import 'widgets/splash_backdrop.dart';
import 'widgets/splash_brand.dart';
import 'widgets/splash_progress_bar.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎬 SPLASH SCREEN — ورود سینمایی Parsa Apps
///
/// پنج مرحلهٔ هم‌زمان با آماده‌سازی *واقعی* برنامه:
///   ۱. نور آبی مرکزی از تاریکی گسترش می‌یابد و ذرات به مرکز می‌آیند.
///   ۲. هالهٔ آبی/طلایی شکل می‌گیرد و لوگوی رسمی با Fade+Scale روشن می‌شود.
///   ۳. نور آبی روی نماد P عبور می‌کند و جزئیات طلایی شیمر می‌گیرند.
///   ۴. نوار پیشرفت باریک، متصل به [StartupCoordinator]، ظاهر می‌شود.
///   ۵. بعد از آمادهٔ واقعیِ برنامه، صفحه با Fade نرم به برنامه می‌رود.
///
/// زمان کل ≈ ۳ ثانیه است، اما نوار تا پایانِ کارِ واقعی صبر می‌کند؛
/// اگر آماده‌سازی زودتر تمام شود، بیش از حدِ لازم معطل نمی‌کند و اگر
/// دیرتر طول بکشد، نوار صادقانه همان وضعیت را نشان می‌دهد.
/// ═══════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.coordinator, this.onEnterApp});

  /// برای تست؛ در برنامهٔ واقعی از پوستهٔ برنامه تزریق می‌شود.
  final StartupCoordinator? coordinator;

  /// پیش از جانشینی مسیر صدا زده می‌شود تا پوستهٔ برنامه بتواند پردهٔ
  /// سیاه را نرم کنار بزند و صفحهٔ اصلی «آرام نمایان» شود.
  final VoidCallback? onEnterApp;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _entranceDuration = Duration(milliseconds: 2200);
  static const Duration _reducedEntrance = Duration(milliseconds: 700);
  static const Duration _exitDuration = Duration(milliseconds: 340);
  static const Duration _minVisible = Duration(milliseconds: 2650);
  static const Duration _minVisibleReduced = Duration(milliseconds: 900);
  static const Duration _holdAfterComplete = Duration(milliseconds: 420);

  late final AnimationController _master;
  late final AnimationController _ambient;
  late final AnimationController _exit;
  late final Listenable _stage;
  late final StartupCoordinator _coordinator;
  late final bool _ownsCoordinator;

  Timer? _minTimer;
  Timer? _holdTimer;
  bool _minElapsed = false;
  bool _holdDone = false;
  bool _started = false;
  bool _leaving = false;
  bool _reduceMotion = false;
  bool _completionNoted = false;

  @override
  void initState() {
    super.initState();
    _coordinator = widget.coordinator ?? StartupCoordinator();
    _ownsCoordinator = widget.coordinator == null;
    _coordinator.addListener(_handleStartup);

    _master = AnimationController(vsync: this, duration: _entranceDuration);
    _ambient = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _exit = AnimationController(vsync: this, duration: _exitDuration);
    _stage = Listenable.merge(<Listenable>[_master, _ambient]);
    _exit.addStatusListener(_handleExitStatus);

    // کارِ واقعی از همان لحظهٔ ساخته‌شدن شروع می‌شود؛ زمان‌بندی بصری در
    // didChangeDependencies تنظیم می‌شود، چون به MediaQuery نیاز دارد.
    unawaited(_coordinator.ensureStarted());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final media = MediaQuery.maybeOf(context);
    _reduceMotion =
        (media?.disableAnimations ?? false) || GrowthStore.reduceMotion;

    if (_reduceMotion) {
      _master.duration = _reducedEntrance;
      _exit.duration = const Duration(milliseconds: 200);
    }
    _master.forward();
    if (!_reduceMotion) _ambient.repeat();

    _minTimer = Timer(
      _reduceMotion ? _minVisibleReduced : _minVisible,
      () {
        _minElapsed = true;
        _maybeLeave();
      },
    );
    _noteCompletion();
  }

  void _handleStartup() {
    if (!mounted) return;
    _noteCompletion();
    setState(() {});
    _maybeLeave();
  }

  void _noteCompletion() {
    if (!_coordinator.isComplete || _completionNoted) return;
    _completionNoted = true;
    _holdTimer = Timer(_holdAfterComplete, () {
      _holdDone = true;
      _maybeLeave();
    });
  }

  void _maybeLeave() {
    if (!mounted || _leaving) return;
    if (!_minElapsed || !_holdDone || !_coordinator.isComplete) return;
    _leaving = true;
    // بدون لرزش یا صدای اضافه: گذار فقط بصری است تا برای کودکِ در حال
    // استراحت هم آزاردهنده نباشد.
    _exit.forward();
  }

  void _handleExitStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _goToApp();
  }

  void _goToApp() {
    if (!mounted) return;
    final blocked = _coordinator.blocked;
    final destination = blocked
        ? '/security-blocked'
        : (GameData.onboardingSeen ? '/gateway' : '/tutorial');

    // «تازه‌های نسخه» فقط بعد از نصب آپدیت و یک‌بار نمایش داده می‌شود؛
    // مقصد بعدی‌اش همان دروازه/آموزش است.
    final showWhatsNew = !blocked && GrowthStore.shouldShowWhatsNew;
    final route = showWhatsNew ? '/whats-new' : destination;
    final arguments = showWhatsNew ? destination : null;

    widget.onEnterApp?.call();
    Navigator.of(context).pushReplacementNamed(
      route,
      arguments: arguments,
    );
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _holdTimer?.cancel();
    _exit.removeStatusListener(_handleExitStatus);
    _coordinator.removeListener(_handleStartup);
    if (_ownsCoordinator) _coordinator.dispose();
    _master.dispose();
    _ambient.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final dpr = media.devicePixelRatio;

    return Scaffold(
      backgroundColor: ParsaBrand.ink,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: ParsaBrand.ink,
          systemNavigationBarDividerColor: ParsaBrand.ink,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: FadeTransition(
          opacity: ReverseAnimation(_exit),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: SplashBackdrop(
                  master: _master,
                  ambient: _ambient,
                  repaint: _stage,
                  reduceMotion: _reduceMotion,
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return _buildStage(constraints, dpr);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStage(BoxConstraints constraints, double dpr) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final horizontal = math.max(20.0, width * 0.055);

    // اندازهٔ لوگو با عرض و ارتفاعِ واقعی قاب تطبیق می‌یابد تا در گوشی
    // باریک یا صفحهٔ کوتاه نه بریده شود و نه نوار پیشرفت را هل بدهد.
    final availableWidth = math.max(120.0, width - horizontal * 2);
    final logoSize = math
        .min(availableWidth * 0.78, math.max(96.0, height - 150.0))
        .clamp(96.0, 400.0)
        .toDouble();
    final barWidth = math.min(logoSize * 0.95, 320.0);
    final cacheWidth = (logoSize * dpr).round().clamp(256, 1024).toInt();

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 6, horizontal, 16),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SplashBrand(
                  size: logoSize,
                  master: _master,
                  ambient: _ambient,
                  repaint: _stage,
                  reduceMotion: _reduceMotion,
                  cacheWidth: cacheWidth,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: barWidth),
            child: ListenableBuilder(
              listenable: _coordinator,
              builder: (BuildContext context, Widget? _) => _buildProgress(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final complete = _coordinator.isComplete;
    final progress = _coordinator.progress;
    final degraded = _coordinator.degraded || _coordinator.hadTimeout;
    final indeterminate = !complete && progress < 0.02;
    final percent = (progress * 100).round().clamp(0, 100).toInt();

    final String caption;
    if (!complete) {
      caption = 'در حال آماده‌سازی...';
    } else if (degraded) {
      caption = 'با حالت ایمن آماده شد';
    } else {
      caption = 'آماده شد ✨';
    }

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'در حال آماده‌سازی برنامه',
      value: indeterminate
          ? null
          : '${PersianDigits.toFa(percent)} درصد',
      child: ExcludeSemantics(
        child: Column(
          key: const ValueKey<String>('parsa_splash_progress'),
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: progress),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double value, Widget? _) {
                return SplashProgressBar(
                  progress: value,
                  indeterminate: indeterminate,
                  ready: complete,
                  shimmer: _ambient,
                );
              },
            ),
            const SizedBox(height: 9),
            Row(
              children: <Widget>[
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: Text(
                      caption,
                      key: ValueKey<String>(caption),
                      textAlign: TextAlign.start,
                      style: AppFonts.vazirmatn(
                        fontSize: 12.5,
                        color: Colors.white.withOpacity(0.74),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (indeterminate)
                  _PulsingDot(ambient: _ambient)
                else
                  Text(
                    '${PersianDigits.toFa(percent)}٪',
                    textDirection: TextDirection.rtl,
                    style: AppFonts.vazirmatn(
                      fontSize: 11.5,
                      color: ParsaBrand.gold.withOpacity(0.82),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            const _PoweredBy(),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({required this.ambient});

  final Animation<double> ambient;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      builder: (BuildContext context, Widget? _) {
        final wave = 0.5 - 0.5 * math.cos(ambient.value * 2 * math.pi);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(3, (int index) {
            final value =
                (wave + index * 0.22) % 1.0;
            final opacity = 0.25 + 0.55 * value;
            return Container(
              width: 4,
              height: 4,
              margin: EdgeInsets.only(left: index == 2 ? 0 : 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ParsaBrand.iceBlue.withOpacity(opacity),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: ParsaBrand.neonBlue.withOpacity(0.35 * opacity),
                    blurRadius: 6,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _PoweredBy extends StatelessWidget {
  const _PoweredBy();

  @override
  Widget build(BuildContext context) {
    // روی گوشیِ باریک یا با فونت/مقیاس متنی متفاوت، متن برند باید کوچک
    // شود نه اینکه سرریز کند؛ دو خط طلایی هم فضای باقی‌مانده را پر می‌کنند.
    return const Row(
      children: <Widget>[
        Expanded(child: _Hairline()),
        Flexible(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                ParsaBrand.poweredBy,
                maxLines: 1,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 1.9,
                  fontWeight: FontWeight.w500,
                  color: Color(0x73FFFFFF),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: _Hairline()),
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Colors.transparent,
            ParsaBrand.gold.withOpacity(0.22),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
