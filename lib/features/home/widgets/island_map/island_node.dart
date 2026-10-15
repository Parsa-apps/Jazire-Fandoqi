import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_fonts.dart';
import '../../../../app/island_world_style.dart';
import '../../../../core/audio_service.dart';

/// موقعیت دکمهٔ شیشه‌ایِ خالی که داخل خودِ تصویر هر سکو کشیده شده است.
/// چون مولد تصویر نمی‌تواند فارسی بنویسد، تابلوها عمداً خالی تولید شدند.
///
/// این دکمه‌ها در خودِ تصویر بسیار کم‌ارتفاع‌اند (حدود ۱۴ پیکسل روی گوشی)،
/// پس متنِ محبوس در آن‌ها هیچ‌وقت به‌اندازهٔ کافی بزرگ نمی‌شود. به همین
/// دلیل `cx`/`cy` را فقط به‌عنوان **نقطهٔ لنگر** به کار می‌بریم و یک پلاکِ
/// اندازه‌شده با خودِ متن دقیقاً روی همان نقطه می‌نشیند و دکمهٔ زیرین را
/// می‌پوشاند. مقادیر کسری از عرض/ارتفاع تصویرند.
class PillRect {
  final double cx;
  final double cy;
  final double w;
  final double h;

  const PillRect(this.cx, this.cy, this.w, this.h);

  /// جای دکمهٔ هر دارایی — با اندازه‌گیری روی خودِ PNG به دست آمده
  static const Map<String, PillRect> byAsset = {
    'assets/theme_map/island_cartoon.png': PillRect(0.395, 0.622, 0.345, 0.070),
    'assets/theme_map/island_story.png': PillRect(0.512, 0.660, 0.360, 0.075),
    // جزیرهٔ قصه‌ها دکمهٔ توکار ندارد؛ لنگر روی چمنِ جلوی فندقی است
    'assets/theme_map/island_tales.png': PillRect(0.497, 0.735, 0.360, 0.075),
    'assets/theme_map/island_game.png': PillRect(0.355, 0.558, 0.335, 0.075),
    'assets/theme_map/island_lullaby.png': PillRect(0.560, 0.520, 0.460, 0.075),
    'assets/theme_map/island_profile.png': PillRect(0.685, 0.630, 0.320, 0.075),
    'assets/theme_map/island_about.png': PillRect(0.455, 0.612, 0.380, 0.085),
  };

  /// نسبت ارتفاع به عرضِ هر تصویر، برای محاسبهٔ ارتفاع بدون خواندن فایل
  static const Map<String, double> aspectByAsset = {
    'assets/theme_map/island_cartoon.png': 511 / 440,
    'assets/theme_map/island_story.png': 509 / 440,
    'assets/theme_map/island_tales.png': 585 / 440,
    'assets/theme_map/island_game.png': 432 / 440,
    'assets/theme_map/island_lullaby.png': 466 / 440,
    'assets/theme_map/island_profile.png': 547 / 440,
    'assets/theme_map/island_about.png': 577 / 440,
    // ── نسخه ۷: سکوی شهر بازی‌های تازه ──
    'assets/theme_map/island_carnival.png': 467 / 440,
    'assets/theme_map/hero_fandoq.png': 456 / 420,
    'assets/theme_map/sign_board.png': 376 / 560,
    'assets/theme_map/bridge.png': 281 / 720,
  };
}

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ یک سکوی شناور روی نقشه
///
/// هر سکو یک PNG جداگانه با پس‌زمینهٔ شفاف است، پس می‌تواند مستقل
/// انیمیت شود:
///   • شناور بودن دائمی با فاز اختصاصی (همه با هم بالا و پایین نمی‌روند)
///   • تاب خوردن بسیار ملایم
///   • فشرده شدن هنگام لمس و برگشت فنری
/// ═══════════════════════════════════════════════════════════════
class IslandNode extends StatefulWidget {
  final String asset;
  final String label;

  /// عرض سکو بر حسب پیکسل منطقی
  final double width;

  /// فاز شناوری (۰ تا ۱)
  final double floatPhase;

  /// کنترلر مشترک شناوری برای کل صفحه
  final Animation<double> floatAnimation;

  final Color labelColor;
  final VoidCallback onTap;

  /// نشان کوچک گوشهٔ سکو (مثلاً «جدید»)
  final String? badge;

  final bool locked;

  /// تأخیرِ ورود پلکانی وقتی نقشه اولین بار ساخته می‌شود تا سکوها
  /// یکی‌یکی و با ریتم روی آب بنشینند، نه همه با هم و ناگهانی.
  final Duration entranceDelay;

  /// چراغ راهنمای فندقی: این سکو «پیشنهاد امروز» است و با یک حلقهٔ
  /// طلاییِ تپنده و ستارهٔ کوچک مشخص می‌شود تا کودک بدون خواندن
  /// متن هم بداند از کجا شروع کند.
  final bool highlight;

  const IslandNode({
    super.key,
    required this.asset,
    required this.label,
    required this.width,
    required this.floatPhase,
    required this.floatAnimation,
    required this.onTap,
    this.labelColor = const Color(0xFF2E4756),
    this.badge,
    this.locked = false,
    this.entranceDelay = Duration.zero,
    this.highlight = false,
  });

  @override
  State<IslandNode> createState() => _IslandNodeState();
}

class _IslandNodeState extends State<IslandNode>
    with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _press;
  late final AnimationController _enterCtrl;
  late final Animation<double> _enter;
  late final AnimationController _burstCtrl;
  late final Animation<double> _burst;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _press = CurvedAnimation(
      parent: _pressCtrl,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOutBack,
    );

    // ورود پلکانیِ سکو روی نقشه
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _enter = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    if (widget.entranceDelay > Duration.zero) {
      Future.delayed(widget.entranceDelay, () {
        if (mounted) _enterCtrl.forward();
      });
    } else {
      _enterCtrl.forward();
    }

    // انفجار کوتاه ستاره‌ها هنگام لمس
    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _burst = CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // احترام به تنظیم «کاهش حرکت» سیستم: ورود بدون انیمیشن کامل شود
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion && _enterCtrl.value < 1) {
      _enterCtrl.value = 1;
    }
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _enterCtrl.dispose();
    _burstCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.locked) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    AudioService.select();
    _burstCtrl.forward(from: 0);
    widget.onTap();
  }

  double get _height =>
      widget.width * (PillRect.aspectByAsset[widget.asset] ?? 1.15);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.floatAnimation, _press, _enter]),
        builder: (context, child) {
          final phase = (widget.floatAnimation.value + widget.floatPhase) % 1.0;
          final bob = sin(phase * 2 * pi);
          final enterT = _enter.value;
          // ورود فنری: سکو از کمی پایین‌تر و کوچک‌تر می‌آید و در انتها
          // یک جهش لطیف دارد؛ حس «نشستن روی آب» می‌دهد.
          final popScale = 0.80 + 0.20 * Curves.easeOutBack.transform(enterT);
          return Opacity(
            opacity: enterT.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, bob * 6 + (1 - enterT) * 22),
              child: Transform.rotate(
                angle: bob * 0.012,
                child: Transform.scale(
                  scale: (1.0 - _press.value * 0.07) * popScale,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final w = widget.width;
    final h = _height;
    final pill = PillRect.byAsset[widget.asset];

    return Semantics(
      button: true,
      label: widget.label,
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // سایهٔ نرم و پهن زیر جزیره تا روی سطح آب «نشسته» به نظر
            // بیاید و از پس‌زمینه جدا شود (عمق بصری).
            Positioned(
              left: w * 0.16,
              right: w * 0.16,
              bottom: -h * 0.02,
              height: h * 0.08,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0x2E00455A), Color(0x0000455A)],
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: widget.locked
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0.2126, 0.7152, 0.0722, 0, 0, //
                        0, 0, 0, 1, 0, //
                      ]),
                      child: _image(w),
                    )
                  : _image(w),
            ),

            // ── پلاک برچسب، لنگرانداخته روی دکمهٔ داخل تصویر ──
            // پلاک از کادر سکو بیرون می‌زند (clipBehavior: none) تا متن
            // بتواند بزرگ باشد بدون اینکه تصویر را بپوشاند.
            if (pill != null)
              Positioned(
                left: 0,
                top: pill.cy * h - _plateHeight / 2,
                width: w,
                height: _plateHeight,
                child: _anchoredPlate(pill.cx),
              )
            else
              Positioned(
                left: 0,
                width: w,
                height: _plateHeight,
                bottom: h * 0.05,
                child: _anchoredPlate(0.5),
              ),

            if (widget.locked)
              Positioned(
                left: 0,
                right: 0,
                top: h * 0.16,
                child: Center(child: _lockBadge()),
              ),

            if (widget.badge != null && !widget.locked)
              Positioned(
                top: h * 0.02,
                right: w * 0.04,
                child: _countBadge(widget.badge!),
              ),

            // ⭐ چراغ راهنمای «پیشنهاد امروز»: حلقهٔ طلایی تپنده + ستاره
            if (widget.highlight)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: widget.floatAnimation,
                    builder: (context, _) {
                      final pulse = (sin((widget.floatAnimation.value +
                                      widget.floatPhase) *
                                  4 *
                                  pi) +
                              1) /
                          2;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: -7,
                            right: -7,
                            top: -7,
                            bottom: -7,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(w * 0.20),
                                border: Border.all(
                                  color: const Color(0xFFFFC93C)
                                      .withOpacity(0.30 + pulse * 0.45),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -h * 0.045 - pulse * 5,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFC93C),
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x33000000),
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.star_rounded,
                                  color: const Color(0xFFFFB300),
                                  size: (w * 0.10).clamp(15.0, 26.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

            // ✨ انفجار کوتاه ستاره‌ها از نقطهٔ لنگر پلاک، هنگام لمس
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _burst,
                  builder: (context, _) => CustomPaint(
                    painter: _TapSparklePainter(
                      progress: _burst.value,
                      center: Offset(
                        w * (pill?.cx ?? 0.5),
                        h * (pill?.cy ?? 0.45),
                      ),
                      radius: w * 0.30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(double w) => Image.asset(
        widget.asset,
        width: w,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );

  /// اندازهٔ متن برچسب — نسبت به عرض سکو بزرگ می‌شود تا روی هر صفحه‌ای
  /// درشت و خوانا بماند. حد پایین برای گوشی‌های کوچک، حد بالا برای تبلت.
  double get _fontSize => (widget.width * 0.150).clamp(17.0, 34.0);

  /// ارتفاع تقریبی پلاک (متن + پدینگ + حاشیه)
  double get _plateHeight => _fontSize * 1.5 + 6;

  /// پلاک با اندازهٔ طبیعیِ خودش روی لنگرِ افقی می‌نشیند. اگر از عرضِ سکو
  /// پهن‌تر شد، به‌جای فشرده‌شدنِ متن آزادانه بیرون می‌زند و
  /// `Alignment` خودش آن را نرم داخل کادر نگه می‌دارد.
  Widget _anchoredPlate(double cx) {
    return OverflowBox(
      minWidth: 0,
      maxWidth: double.infinity,
      minHeight: 0,
      maxHeight: double.infinity,
      alignment: Alignment((cx * 2 - 1).clamp(-1.0, 1.0), 0),
      child: _labelPlate(),
    );
  }

  /// پلاک برچسب: کپسول روشن با حاشیهٔ عسلی، دقیقاً به اندازهٔ خودِ متن.
  Widget _labelPlate() {
    final fs = _fontSize;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fs * 0.52, vertical: fs * 0.17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(fs),
        border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        widget.label,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: AppFonts.kids(
          fontSize: fs,
          fontWeight: FontWeight.w800,
          color: widget.labelColor,
          height: 1.15,
        ),
      ),
    );
  }

  Widget _lockBadge() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lock_rounded, color: Colors.white, size: 22),
    );
  }

  Widget _countBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppFonts.vazirmatn(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 🌰 قهرمان نقشه — شخصیت فندقی اصلی، بالای صفحه و بزرگ‌تر از همه،
/// با هالهٔ طلایی و تکان دائمی تا فوراً به چشم بیاید.
///
/// فندقی فقط بالا و پایین نمی‌رود؛ «زنده» است:
///   • تنفس آرام و پیوسته (بزرگ و کوچک شدن بسیار ملایم)
///   • در انتهای هر چرخهٔ شناوری، یک پرش کوچکِ شاد با فشردگی فنری
///   • هنگام لمس: پرشِ جشن و تاب خوردن، هم‌زمان با پیام مربی
///   • ستاره‌های طلاییِ چشمک‌زن دور هاله
///
/// همهٔ حرکت‌ها از همان کنترلر شناوریِ مشترک نقشه خوانده می‌شوند و
/// فقط واکنش لمس یک کنترلر کوتاهِ اختصاصی دارد. با تنظیم «کاهش
/// حرکت» سیستم، حرکت‌های اضافه خاموش می‌شوند.
class HeroFandoq extends StatefulWidget {
  /// هالهٔ طلایی چند برابرِ خودِ فندقی است؛ ویجت به همین اندازه جا می‌گیرد
  static const double haloFactor = 1.4;

  final double width;
  final Animation<double> floatAnimation;
  final VoidCallback onTap;

  const HeroFandoq({
    super.key,
    required this.width,
    required this.floatAnimation,
    required this.onTap,
  });

  @override
  State<HeroFandoq> createState() => _HeroFandoqState();
}

class _HeroFandoqState extends State<HeroFandoq>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cheerCtrl;
  late final Animation<double> _cheer;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _cheerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    _cheer = CurvedAnimation(parent: _cheerCtrl, curve: Curves.easeOut);
    // لباس جشن از قبل بارگذاری می‌شود تا اولین لمس بدون چشمک عوض شود.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(
        const AssetImage(IslandWorldAssets.fandoghiCelebrate),
        context,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  @override
  void dispose() {
    _cheerCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    AudioService.select();
    if (!_reduceMotion) _cheerCtrl.forward(from: 0);
    widget.onTap();
  }

  /// پلک‌ها روی هندسهٔ واقعی تصویر دست‌تکان (۶۲۲×۶۳۶) سوار می‌شوند:
  /// مرکز چشم‌ها در ۴۲٪ و ۶۸٪ عرض و ۵۲٪ ارتفاع تصویر است. پلک در
  /// ۶٪ اول هر چرخهٔ شناوری یک بار پایین و بالا می‌رود (مثلث نرم).
  Widget _blinkLids(double width) {
    final v = widget.floatAnimation.value;
    final blink = v < 0.03
        ? v / 0.03
        : v < 0.06
            ? (0.06 - v) / 0.03
            : 0.0;
    if (blink <= 0) return const SizedBox.shrink();
    final imgH = width * 636 / 622;
    final box = width * HeroFandoq.haloFactor;
    final imgLeft = (box - width) / 2;
    final imgTop = (box - imgH) / 2;
    final eyeW = width * 0.155;
    final eyeH = imgH * 0.175;
    Widget lid(double centerFx) {
      return Positioned(
        left: imgLeft + centerFx * width - eyeW / 2,
        top: imgTop + 0.522 * imgH - eyeH / 2,
        width: eyeW,
        height: eyeH * blink,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFCE9250), Color(0xFFB57A3E)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(eyeW / 2),
              bottomRight: Radius.circular(eyeW / 2),
            ),
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Stack(
        children: [
          lid(0.424),
          lid(0.677),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width;
    return Semantics(
      button: true,
      label: 'فندقی؛ برای شنیدن پیام لمس کن',
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.floatAnimation, _cheer]),
          builder: (context, child) {
            final v = widget.floatAnimation.value;
            final bob = sin(v * 2 * pi);
            // تنفس: دو چرخهٔ ملایم در هر شناوریِ کامل
            final breath = _reduceMotion ? 1.0 : 1 + 0.018 * sin(v * 4 * pi);
            // پرش کوچکِ شاد در انتهای هر چرخهٔ شناوری
            var hop = 0.0;
            if (!_reduceMotion && v > 0.78 && v < 0.94) {
              hop = sin((v - 0.78) / 0.16 * pi);
            }
            // واکنش لمس: پرش جشن + تابِ رو به اتمام
            final cheerT = _cheer.value;
            final cheerHop = sin(cheerT * pi) * -13.0;
            final cheerTilt = sin(cheerT * 2 * pi) * 0.05 * (1 - cheerT);
            final squashY = 1 - hop * 0.05 - sin(cheerT * pi) * 0.04;
            return Transform.translate(
              offset: Offset(0, bob * 9 - hop * 8 + cheerHop),
              child: Transform.rotate(
                angle: bob * 0.03 + cheerTilt,
                child: Transform.scale(
                  scaleX: breath * (1 + hop * 0.03),
                  scaleY: breath * squashY,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            );
          },
          child: SizedBox(
            width: width * HeroFandoq.haloFactor,
            height: width * HeroFandoq.haloFactor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: width * HeroFandoq.haloFactor,
                  height: width * HeroFandoq.haloFactor,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFE082).withOpacity(0.7),
                        const Color(0xFFFFE082).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                // هنگام لمس، فندقی برای لحظه‌ای لباس جشن واقعی‌اش را
                // می‌پوشد (دارایی شفاف موجود)، بعد به حالت دست‌تکان برمی‌گردد.
                AnimatedBuilder(
                  animation: _cheer,
                  builder: (context, _) {
                    final celebrating = _cheer.value > 0 && _cheer.value < 1;
                    return Image.asset(
                      celebrating
                          ? IslandWorldAssets.fandoghiCelebrate
                          : IslandWorldAssets.fandoghiWave,
                      width: width,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      excludeFromSemantics: true,
                      cacheWidth:
                          (width * MediaQuery.devicePixelRatioOf(context))
                              .round()
                              .clamp(1, 666)
                              .toInt(),
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/theme_map/hero_fandoq.png',
                        width: width,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        excludeFromSemantics: true,
                      ),
                    );
                  },
                ),
                // پلک‌زدن: دو پلک هم‌رنگ موی بالای چشم که ابتدای هر چرخهٔ
                // شناوری (۵ ثانیه) یک بار کوتاه پایین می‌آیند. مختصات چشم‌ها
                // از خودِ دارایی واقعی خوانده شده است.
                if (!_reduceMotion)
                  AnimatedBuilder(
                    animation: widget.floatAnimation,
                    builder: (context, _) => _blinkLids(width),
                  ),
                // ستاره‌های چشمک‌زن دور هاله
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _HeroSparklePainter(widget.floatAnimation),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ستاره‌های طلایی و سفید دور هالهٔ فندقی که با فاز متفاوت چشمک
/// می‌زنند؛ روی همان کنترلر شناوری سوارند و هزینهٔ جدا ندارند.
class _HeroSparklePainter extends CustomPainter {
  final Animation<double> animation;

  _HeroSparklePainter(this.animation) : super(repaint: animation);

  static const List<List<double>> _spots = [
    // [x نسبی, y نسبی, اندازهٔ پایه]
    [0.15, 0.30, 4.5],
    [0.85, 0.26, 5.0],
    [0.09, 0.56, 3.6],
    [0.91, 0.54, 4.0],
    [0.25, 0.11, 3.8],
    [0.74, 0.10, 4.4],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (var i = 0; i < _spots.length; i++) {
      final spot = _spots[i];
      final twinkle = (sin(t * 4 * pi + i * 1.9) + 1) / 2;
      final center = Offset(spot[0] * size.width, spot[1] * size.height);
      final radius = spot[2] * (0.6 + twinkle * 0.7);
      final color = i.isEven ? const Color(0xFFFFC93C) : Colors.white;
      canvas.drawPath(
        _sparklePath(center, radius),
        Paint()..color = color.withOpacity(0.25 + twinkle * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_HeroSparklePainter old) => old.animation != animation;
}

/// 🫧 حباب یادگیری زیرِ آب — برادر کوچک‌ترِ [IslandNode].
///
/// همان زبان تصویری را دارد: تصویر سه‌بعدیِ شناور + پلاک کپسولیِ کرم با
/// حاشیهٔ عسلی. فرقش این است که تصویر گرد است و پلاک همیشه زیرِ حباب
/// می‌نشیند، نه رویش، تا داخل حباب دیده شود.
class BubbleNode extends StatefulWidget {
  const BubbleNode({
    super.key,
    required this.asset,
    required this.label,
    required this.width,
    required this.floatAnimation,
    required this.onTap,
    this.floatPhase = 0,
  });

  final String asset;
  final String label;
  final double width;
  final Animation<double> floatAnimation;
  final VoidCallback onTap;
  final double floatPhase;

  @override
  State<BubbleNode> createState() => _BubbleNodeState();
}

class _BubbleNodeState extends State<BubbleNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _press;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _press = CurvedAnimation(
      parent: _pressCtrl,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    AudioService.tap();
    widget.onTap();
  }

  /// متن کمی ریزتر از سکوهاست چون حباب‌ها چهارتایی کنار هم می‌نشینند
  double get _fontSize => (widget.width * 0.215).clamp(12.0, 21.0);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        onTap: _handleTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([widget.floatAnimation, _press]),
              builder: (context, child) {
                final phase =
                    (widget.floatAnimation.value + widget.floatPhase) % 1.0;
                final bob = sin(phase * 2 * pi);
                return Transform.translate(
                  // حباب‌ها بالا و پایین می‌روند، انگار توی آب معلق‌اند
                  offset: Offset(bob * 2, bob * 5),
                  child: Transform.scale(
                    scale: 1.0 - _press.value * 0.08,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                widget.asset,
                width: widget.width,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),
            SizedBox(height: widget.width * 0.05),
            _labelPlate(),
          ],
        ),
      ),
    );
  }

  /// دقیقاً همان پلاکِ سکوها، فقط کوچک‌تر — تا کل نقشه یک‌دست بماند.
  Widget _labelPlate() {
    final fs = _fontSize;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fs * 0.52, vertical: fs * 0.17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(fs),
        border: Border.all(color: const Color(0xFFFFB300), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        widget.label,
        maxLines: 1,
        style: AppFonts.kids(
          fontSize: fs,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2E4756),
          height: 1.15,
        ),
      ),
    );
  }
}

/// ✨ انفجار ستارهٔ لمس: ده ستارهٔ چهارپر که از نقطهٔ لنگرِ پلاک به
/// بیرون پخش و هم‌زمان محو می‌شوند، همراه یک حلقهٔ نورانیِ ظریف.
/// کوتاه و بدون چشمکِ تند است تا برای چشم کودک آزاردهنده نباشد.
class _TapSparklePainter extends CustomPainter {
  final double progress;
  final Offset center;
  final double radius;

  const _TapSparklePainter({
    required this.progress,
    required this.center,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final fade = 1 - progress;

    // حلقهٔ نورِ در حال گسترش
    canvas.drawCircle(
      center,
      radius * 0.75 * progress + 6,
      Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.45 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var i = 0; i < 10; i++) {
      final angle = (i / 10) * 2 * pi + 0.35;
      final dist = radius * progress;
      final pos = Offset(
        center.dx + cos(angle) * dist,
        center.dy + sin(angle) * dist - progress * 12,
      );
      final r = 1.5 + fade * 4.2;
      final color = i.isEven ? const Color(0xFFFFC93C) : Colors.white;
      canvas.drawPath(
        _sparklePath(pos, r),
        Paint()..color = color.withOpacity(0.9 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_TapSparklePainter old) =>
      old.progress != progress || old.center != center;
}

/// ستارهٔ چهارپرِ کلاسیکِ بازی‌های کودک (الماسِ خمیده).
Path _sparklePath(Offset center, double radius) {
  return Path()
    ..moveTo(center.dx, center.dy - radius)
    ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
    ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
    ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
    ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
}
