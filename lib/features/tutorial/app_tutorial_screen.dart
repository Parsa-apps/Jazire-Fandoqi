import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../core/game_data.dart';

/// A full-screen, video-like walkthrough shown once at first app entry.
/// Subsequent launches skip directly to the main page.
class AppTutorialScreen extends StatefulWidget {
  const AppTutorialScreen({super.key});

  @override
  State<AppTutorialScreen> createState() => _AppTutorialScreenState();
}

class _AppTutorialScreenState extends State<AppTutorialScreen>
    with TickerProviderStateMixin {
  static const Duration _slideDuration = Duration(seconds: 7);
  static const Duration minimumSlideDuration = Duration(seconds: 5);
  static const Duration maximumSlideDuration = Duration(seconds: 30);

  static const List<_TutorialSlide> _slides = [
    _TutorialSlide(
      eyebrow: 'سلام قهرمان کوچولو! 👋',
      title: 'به جزیره فندقی خوش آمدی',
      description:
          'من فندقی‌ام؛ دوست و راهنمای تو. روی جزیره‌ها و حباب‌های رنگی بزن تا وارد بازی، قصه، کارتون، لالایی و آموزش شوی. هر کارت یک ماجرای تازه است!',
      tip: 'هرجا من را دیدی، یک راهنمای کوتاه و مهربان برایت دارم.',
      asset: 'assets/mascot/fandoghi_welcome_hero.png',
      icon: Icons.favorite_rounded,
      colors: [Color(0xFF6C3BCE), Color(0xFF1E88E5), Color(0xFF00B8D4)],
      features: ['بازی و یادگیری', 'قصه و کارتون', 'جایزه و ستاره'],
    ),
    _TutorialSlide(
      eyebrow: 'آماده‌ای؟ ✨',
      title: 'ماجراجویی را شروع کن!',
      description:
          'حالا می‌توانی وارد جزیره شوی. بازی کن، یاد بگیر و جزیرهٔ خودت را بساز. فندقی همیشه کنار توست!',
      tip: 'هر وقت کمک خواستی، به فندقی و نشانه‌های رنگی صفحه نگاه کن.',
      asset: 'assets/mascot/fandoghi_baby_party.webp',
      icon: Icons.rocket_launch_rounded,
      colors: [Color(0xFF4A148C), Color(0xFF7B1FA2), Color(0xFFE91E63)],
      features: ['یادگیری', 'بازی', 'ماجراجویی'],
      isFinal: true,
    ),
  ];

  final PageController _pageController = PageController();
  late final AnimationController _ambientController;
  late final AnimationController _progressController;
  Timer? _slideTimer;
  int _index = 0;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    assert(_slideDuration >= minimumSlideDuration);
    assert(_slideDuration <= maximumSlideDuration);
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _progressController = AnimationController(
      vsync: this,
      duration: _slideDuration,
    );
    _startSlideClock();
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _pageController.dispose();
    _ambientController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startSlideClock() {
    _slideTimer?.cancel();
    _progressController
      ..stop()
      ..value = 0;
    if (_slides[_index].isFinal) return;
    _progressController.forward();
    _slideTimer = Timer(_slideDuration, () {
      if (mounted) _goTo(_index + 1);
    });
  }

  void _goTo(int target) {
    if (target < 0 || target >= _slides.length || target == _index) return;
    HapticFeedback.selectionClick();
    final previousIndex = _index;
    setState(() => _index = target);

    // A skip can cross several lazily-built pages. Jump directly so the final
    // choice and its matching artwork always appear together; neighbouring
    // slides retain the premium animated transition.
    if ((target - previousIndex).abs() > 1) {
      _pageController.jumpToPage(target);
    } else {
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubicEmphasized,
      );
    }
    _startSlideClock();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    HapticFeedback.mediumImpact();
    final shouldOfferProfile = !GameData.onboardingSeen;
    // آموزش فقط یک‌بار نمایش داده می‌شود؛ ورودهای بعدی مستقیم
    // به صفحهٔ اصلی می‌روند.
    await GameData.completeInitialGuide(
      doNotShowTutorialAgain: true,
    );
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      shouldOfferProfile ? '/gateway-first-entry' : '/gateway',
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    final animationsDisabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: slide.colors,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _ambientController,
                    builder: (_, __) => CustomPaint(
                      painter: _DreamyBackgroundPainter(
                        progress: animationsDisabled ? 0.2 : _ambientController.value,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _slides.length,
                        itemBuilder: (_, index) => _SlideBody(
                          slide: _slides[index],
                          active: index == _index,
                          animationsDisabled: animationsDisabled,
                        ),
                      ),
                    ),
                    if (slide.isFinal) _buildFinalChoice() else _buildControls(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  '${_index + 1} از ${_slides.length}',
                  style: AppFonts.kids(color: Colors.white, fontSize: 16),
                ),
              ),
              const Spacer(),
              if (!_slides[_index].isFinal)
                Semantics(
                  button: true,
                  label: 'رد کردن آموزش و رفتن به مرحله پایان',
                  child: TextButton.icon(
                    key: const ValueKey('tutorial_skip'),
                    onPressed: () => _goTo(_slides.length - 1),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      textStyle: AppFonts.kids(fontSize: 17),
                    ),
                    icon: const Icon(Icons.fast_forward_rounded, size: 23),
                    label: const Text('رد کردن'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 7,
              child: Row(
                children: List.generate(_slides.length, (i) {
                  if (i < _index) {
                    return const Expanded(child: ColoredBox(color: Colors.white));
                  }
                  if (i > _index || _slides[_index].isFinal) {
                    return Expanded(child: ColoredBox(color: Colors.white.withOpacity(0.25)));
                  }
                  return Expanded(
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (_, __) => LinearProgressIndicator(
                        value: _progressController.value,
                        minHeight: 7,
                        color: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.25),
                      ),
                    ),
                  );
                }).expand((widget) => [widget, const SizedBox(width: 4)]).toList()
                  ..removeLast(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      child: Row(
        children: [
          if (_index > 0) ...[
            Expanded(
              child: _TutorialButton(
                key: const ValueKey('tutorial_previous'),
                label: 'قبلی',
                icon: Icons.arrow_forward_rounded,
                filled: false,
                onPressed: () => _goTo(_index - 1),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: _TutorialButton(
              key: const ValueKey('tutorial_next'),
              label: 'بعدی',
              icon: Icons.arrow_back_rounded,
              onPressed: () => _goTo(_index + 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalChoice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: _TutorialButton(
              key: const ValueKey('tutorial_finish'),
              label: _finishing ? 'یک لحظه...' : 'پایان؛ ورود به جزیره',
              icon: Icons.rocket_launch_rounded,
              onPressed: _finishing ? null : _finish,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideBody extends StatelessWidget {
  const _SlideBody({
    required this.slide,
    required this.active,
    required this.animationsDisabled,
  });

  final _TutorialSlide slide;
  final bool active;
  final bool animationsDisabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 610;
        final visualSize = compact ? 138.0 : math.min(220.0, constraints.maxHeight * 0.31);
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(22, compact ? 4 : 12, 22, 8),
          child: Column(
            children: [
              AnimatedScale(
                scale: active ? 1 : 0.82,
                duration: animationsDisabled ? Duration.zero : const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: visualSize + 34,
                      height: visualSize + 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.13),
                        border: Border.all(color: Colors.white30, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.18),
                            blurRadius: 35,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    Hero(
                      tag: 'tutorial_${slide.title}',
                      child: Image.asset(
                        slide.asset,
                        width: visualSize,
                        height: visualSize,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => Icon(
                          slide.icon,
                          color: Colors.white,
                          size: visualSize * 0.55,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -12,
                      bottom: 6,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 14)],
                        ),
                        child: Icon(slide.icon, color: slide.colors.first, size: 31),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 5 : 14),
              Text(
                slide.eyebrow,
                textAlign: TextAlign.center,
                style: AppFonts.kids(
                  color: const Color(0xFFFFF0A8),
                  fontSize: compact ? 17 : 20,
                  shadows: const [Shadow(color: Colors.black26, blurRadius: 5)],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: AppFonts.kids(
                  color: Colors.white,
                  fontSize: compact ? 24 : 30,
                  height: 1.2,
                  shadows: const [Shadow(color: Colors.black38, blurRadius: 9, offset: Offset(0, 3))],
                ),
              ),
              SizedBox(height: compact ? 5 : 10),
              Text(
                slide.description,
                textAlign: TextAlign.center,
                style: AppFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w700,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 7,
                runSpacing: 7,
                children: slide.features
                    .map(
                      (feature) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.17),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Text(
                          feature,
                          style: AppFonts.kids(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1).withOpacity(0.94),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🌰', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'نکتهٔ فندقی: ${slide.tip}',
                        style: AppFonts.vazirmatn(
                          color: const Color(0xFF51310D),
                          fontSize: compact ? 11 : 12,
                          fontWeight: FontWeight.w800,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TutorialButton extends StatelessWidget {
  const _TutorialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(88, 58)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 18, vertical: 13)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
      textStyle: WidgetStatePropertyAll(AppFonts.kids(fontSize: 21)),
      foregroundColor: WidgetStatePropertyAll(filled ? const Color(0xFF42135E) : Colors.white),
      backgroundColor: WidgetStatePropertyAll(filled ? Colors.white : Colors.white.withOpacity(0.14)),
      side: WidgetStatePropertyAll(BorderSide(color: Colors.white.withOpacity(filled ? 0.0 : 0.55), width: 1.5)),
      elevation: WidgetStatePropertyAll(filled ? 7 : 0),
    );
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 25),
      label: Text(label),
    );
  }
}

class _TutorialSlide {
  const _TutorialSlide({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.tip,
    required this.asset,
    required this.icon,
    required this.colors,
    required this.features,
    this.isFinal = false,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String tip;
  final String asset;
  final IconData icon;
  final List<Color> colors;
  final List<String> features;
  final bool isFinal;
}

class _DreamyBackgroundPainter extends CustomPainter {
  const _DreamyBackgroundPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 14; i++) {
      final phase = progress * math.pi * 2 + i * 0.73;
      final x = (i * 83.0 + math.sin(phase) * 34) % (size.width + 50) - 25;
      final y = (i * 127.0 - progress * size.height * (0.3 + (i % 3) * 0.1)) %
          (size.height + 80);
      final radius = 3.0 + (i % 4) * 3.2;
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.08 + (i % 3) * 0.035)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, size.height - y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DreamyBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
