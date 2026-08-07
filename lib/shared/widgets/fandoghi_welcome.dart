import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_colors.dart';
import '../../core/fandoghi_welcome.dart';
import 'fandoghi_bunny.dart';

/// ═══════════════════════════════════════════════
/// 🐰 Fandoghi Welcome — Cinematic intro animation.
///
/// Plays once per app session:
///   1. Soft scrim fades in.
///   2. Bunny bounces in from the bottom and lands big in the centre.
///   3. Welcome speech bubble pops up next to the bunny.
///   4. After ~2.5s the bunny floats back to its corner and the
///      scrim fades out, leaving the rest of the app untouched.
///
/// Triggered by [FandoghiWelcome.start]. Tap anywhere to skip.
class FandoghiWelcomeOverlay extends StatefulWidget {
  const FandoghiWelcomeOverlay({super.key});

  /// Play the welcome animation. Safe to call multiple times — it
  /// only runs once per session unless [FandoghiWelcome.reset] is
  /// called.
  static void start(BuildContext context) {
    if (FandoghiWelcome.shownThisSession) return;
    FandoghiWelcome.markShown();
    FandoghiWelcome.isPlaying.value = true;
  }

  @override
  State<FandoghiWelcomeOverlay> createState() => _FandoghiWelcomeOverlayState();
}

class _FandoghiWelcomeOverlayState extends State<FandoghiWelcomeOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final AnimationController _exitCtrl;
  late final AnimationController _bubbleCtrl;
  late final Animation<double> _bounceAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _bubbleScaleAnim;
  late final Animation<double> _bubbleOpacityAnim;

  @override
  void initState() {
    super.initState();

    // Total timeline: enter (~1.4s) → hold (~2.4s) → exit (~1.0s)
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _bounceAnim = CurvedAnimation(
      parent: _enterCtrl,
      curve: Curves.elasticOut,
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_enterCtrl);

    _bubbleScaleAnim = CurvedAnimation(
      parent: _bubbleCtrl,
      curve: Curves.elasticOut,
    );
    _bubbleOpacityAnim = CurvedAnimation(
      parent: _bubbleCtrl,
      curve: Curves.easeIn,
    );

    // Sequence: enter → wait briefly → bubble pops in → wait → exit.
    _runSequence();
  }

  Future<void> _runSequence() async {
    try {
      await _enterCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 350));
      await _bubbleCtrl.forward();
      // Hold the bunny + bubble on screen long enough to be read aloud
      // (2.4s ≈ 85 Persian characters at our current speech rate).
      await Future.delayed(const Duration(milliseconds: 2400));
      await _bubbleCtrl.reverse();
      await _exitCtrl.forward();
    } finally {
      if (mounted) {
        FandoghiWelcome.isPlaying.value = false;
      }
    }
  }

  void _skip() {
    _enterCtrl.stop();
    _exitCtrl.stop();
    _bubbleCtrl.stop();
    _exitCtrl.value = 0;
    _exitCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _exitCtrl.dispose();
    _bubbleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: FandoghiWelcome.isPlaying,
      builder: (context, isPlaying, _) {
        if (!isPlaying) return const SizedBox.shrink();
        return _buildOverlay(context);
      },
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft scrim that fades in/out. Doesn't fully block the app
          // visually, just dims it so the bunny is the hero.
          AnimatedBuilder(
            animation: _enterCtrl,
            builder: (_, __) {
              return AnimatedBuilder(
                animation: _exitCtrl,
                builder: (_, __) {
                  final enter = _enterCtrl.value;
                  final exit = 1.0 - _exitCtrl.value;
                  final opacity = (enter * exit).clamp(0.0, 1.0);
                  return GestureDetector(
                    onTap: _skip,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.black.withOpacity(0.35 * opacity),
                    ),
                  );
                },
              );
            },
          ),

          // Confetti / sparkles in the background
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _enterCtrl,
                builder: (_, __) {
                  return Opacity(
                    opacity: _enterCtrl.value.clamp(0.0, 1.0),
                    child: const _SparkleField(),
                  );
                },
              ),
            ),
          ),

          // The bunny. Sits at the centre while entering/exiting,
          // then animates to its saved corner position.
          AnimatedBuilder(
            animation: Listenable.merge([_enterCtrl, _exitCtrl]),
            builder: (context, _) {
              final enterT = _enterCtrl.value;
              final exitT = _exitCtrl.value;
              return _BunnyStage(
                enterT: enterT,
                exitT: exitT,
                scale: _scaleAnim.value,
                bounce: _bounceAnim.value,
                child: const _WelcomeBunny(),
              );
            },
          ),

          // Welcome speech bubble. Sits next to the bunny in the centre.
          Center(
            child: AnimatedBuilder(
              animation: _bubbleCtrl,
              builder: (_, __) {
                final t = _bubbleCtrl.value;
                return _WelcomeBubble(
                  opacity: _bubbleOpacityAnim.value,
                  scale: 0.4 + 0.6 * _bubbleScaleAnim.value,
                  offset: (1 - t) * 20.0,
                );
              },
            ),
          ),

          // Tap-to-skip hint, very small at the bottom.
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _enterCtrl,
                builder: (_, __) {
                  return Opacity(
                    opacity: (_enterCtrl.value * (1 - _exitCtrl.value))
                        .clamp(0.0, 1.0) *
                        0.6,
                    child: Text(
                      'برای رد کردن، صفحه را بزن',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.balooBhaijaan2(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bunny on stage. Sits at the centre while entering/exiting.
class _BunnyStage extends StatelessWidget {
  final double enterT;
  final double exitT;
  final double scale;
  final double bounce;
  final Widget child;

  const _BunnyStage({
    required this.enterT,
    required this.exitT,
    required this.scale,
    required this.bounce,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Enter: from y=+1.2 (below screen) → 0 (centre), with bounce.
    // Exit: from centre → bottom-right corner.
    final media = MediaQuery.of(context).size;
    final centerY = media.height * 0.42;
    final cornerX = media.width * 0.86 - 60; // align with default corner
    final cornerY = media.height * 0.78 - 60;

    // Position while entering (lerp from bottom to centre).
    final enterY = centerY + (1 - enterT) * (media.height * 0.6);
    // Position while exiting (lerp from centre to corner).
    final exitY = centerY + exitT * (cornerY - centerY);
    final exitX = exitT * (cornerX - media.width / 2);
    final exitScale = 1.1 - exitT * 0.1; // gently shrink as it leaves

    // Active values depending on phase.
    final y = exitT > 0 ? exitY : enterY;
    final x = exitT > 0 ? exitX : 0.0;
    final s = exitT > 0 ? exitScale : scale;
    final b = exitT > 0 ? 1.0 : bounce;

    return Positioned(
      left: media.width / 2 - 70 + x,
      top: y - 70,
      child: IgnorePointer(
        child: Transform.scale(
          scale: s * b,
          child: SizedBox(
            width: 140,
            height: 140,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _WelcomeBunny extends StatelessWidget {
  const _WelcomeBunny();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 4,
          ),
          BoxShadow(
            color: const Color(0xFFFFB8C8).withOpacity(0.7),
            blurRadius: 40,
            spreadRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: const FandoghiBunny(size: 132),
    );
  }
}

class _WelcomeBubble extends StatelessWidget {
  final double opacity;
  final double scale;
  final double offset;
  const _WelcomeBubble({
    required this.opacity,
    required this.scale,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, offset),
        child: Transform.scale(
          scale: scale,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            margin: const EdgeInsets.only(top: 180, left: 24, right: 24),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'سلام! 👋',
                  style: GoogleFonts.balooBhaijaan2(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'من فندقی هستم، دوست و مربی تو! 🐰\nهر وقت کمک خواستی من اینجام.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.balooBhaijaan2(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.45,
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

/// Decorative sparkles that fall/float while the welcome plays.
class _SparkleField extends StatefulWidget {
  const _SparkleField();

  @override
  State<_SparkleField> createState() => _SparkleFieldState();
}

class _SparkleFieldState extends State<_SparkleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Sparkle> _sparkles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _sparkles = List.generate(18, (i) {
      return _Sparkle(
        dx: (i * 53) % 100 / 100.0,
        dy: (i * 91) % 100 / 100.0,
        size: 8 + (i % 5) * 4.0,
        delay: (i % 6) / 6.0,
        emoji: const ['✨', '⭐', '💫', '🌟'][i % 4],
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Stack(
          children: _sparkles.map((s) {
            final t = (_ctrl.value + s.delay) % 1.0;
            final yPos = t; // fall from top to bottom
            return Positioned(
              left: MediaQuery.of(context).size.width * s.dx - s.size / 2,
              top: MediaQuery.of(context).size.height * yPos - s.size / 2,
              child: Opacity(
                opacity: 0.5 + 0.5 * (1 - (t - 0.5).abs() * 2),
                child: Text(
                  s.emoji,
                  style: TextStyle(fontSize: s.size),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Sparkle {
  final double dx;
  final double dy;
  final double size;
  final double delay;
  final String emoji;
  const _Sparkle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.delay,
    required this.emoji,
  });
}
