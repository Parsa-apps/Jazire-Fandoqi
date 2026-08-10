import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/fandoghi_models.dart';
import 'fandoghi_bunny.dart';
import '../../app/design_tokens.dart';
import '../../app/app_colors.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌟 FANDOGHI PREMIUM V4 — پیشنهاد پریمیوم شماره ۱۲
/// هر حالت احساسی انیمیشن اختصاصی + ذرات + هاله
/// جایگزین قطره‌ای برای FandoghiV2 — API یکسان ولی لوکس
/// ═══════════════════════════════════════════════════════════════
class FandoghiPremium extends StatefulWidget {
  final double size;
  final FandoghiMood mood;
  final bool animated;
  final String? message;
  final VoidCallback? onTap;
  final bool showShadow;
  final bool showParticles;

  const FandoghiPremium({
    super.key,
    this.size = 96,
    this.mood = FandoghiMood.happy,
    this.animated = true,
    this.message,
    this.onTap,
    this.showShadow = true,
    this.showParticles = true,
  });

  @override
  State<FandoghiPremium> createState() => _FandoghiPremiumState();
}

class _FandoghiPremiumState extends State<FandoghiPremium> with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: Duration(milliseconds: 2000 + _rng.nextInt(800)));
    if (widget.animated) _floatCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant FandoghiPremium oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated && !oldWidget.animated) {
      _floatCtrl.repeat(reverse: true);
    } else if (!widget.animated && oldWidget.animated) {
      _floatCtrl.stop();
    }
    if (widget.mood != oldWidget.mood && widget.animated) {
      // ضربه کوچک هنگام تغییر حالت
      _floatCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodConfig = _moodConfig(widget.mood);

    Widget bunny = GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // هاله پشت فندقی
          if (widget.showShadow)
            _GlowHalo(size: widget.size, color: moodConfig.glowColor, animate: widget.animated),

          // ذرات اطراف برای حالت‌های جشن
          if (widget.showParticles && moodConfig.showParticles)
            _MoodParticles(size: widget.size, mood: widget.mood),

          // خود فندقی با انیمیشن اختصاصی هر mood
          _AnimatedBunny(
            size: widget.size,
            mood: widget.mood,
            floatCtrl: _floatCtrl,
            animate: widget.animated,
          ),

          // ایموجی شناور برای حالت‌هایی که تصویر ندارند (fallback)
          if (widget.mood.portraitAsset == null)
            Positioned(
              right: -widget.size * 0.1,
              top: -widget.size * 0.1,
              child: Text(moodConfig.emoji, style: TextStyle(fontSize: widget.size * 0.38))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.05, 1.05), duration: 900.ms, curve: Curves.easeInOut),
            ),

          // Zzz برای خواب
          if (widget.mood == FandoghiMood.sleeping && widget.animated)
            Positioned(
              right: -widget.size * 0.15,
              top: widget.size * 0.05,
              child: Column(
                children: [
                  Text('Z', style: TextStyle(fontSize: widget.size * 0.22, color: Colors.white, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black26, blurRadius: 4)]))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(begin: 0.3, end: 1, duration: 1000.ms)
                      .moveY(begin: 0, end: -6, duration: 1000.ms),
                  Text('z', style: TextStyle(fontSize: widget.size * 0.16, color: Colors.white70))
                      .animate(delay: 300.ms, onPlay: (c) => c.repeat(reverse: true))
                      .fade(begin: 0.2, end: 0.8, duration: 1200.ms),
                ],
              ),
            ),
        ],
      ),
    );

    // انیمیشن ورودی بر اساس mood
    bunny = _wrapWithMoodEntrance(bunny, widget.mood, widget.animated);

    if (widget.message != null && widget.message!.isNotEmpty) {
      bunny = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          bunny,
          const SizedBox(height: 10),
          _PremiumSpeechBubble(text: widget.message!, mood: widget.mood),
        ],
      );
    }

    return Semantics(
      label: 'فندقی ${moodConfig.label}',
      button: widget.onTap != null,
      child: bunny,
    );
  }

  Widget _wrapWithMoodEntrance(Widget child, FandoghiMood mood, bool animate) {
    if (!animate) return child;
    return switch (mood) {
      FandoghiMood.excited || FandoghiMood.celebrating => child
          .animate()
          .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut)
          .then()
          .shimmer(duration: 900.ms, color: Colors.white.withOpacity(0.4)),
      FandoghiMood.surprised => child
          .animate()
          .scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.easeOutBack)
          .then()
          .shake(hz: 4, curve: Curves.easeInOut, duration: 500.ms),
      FandoghiMood.thinking => child.animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
      FandoghiMood.sad => child.animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
      _ => child.animate().scale(begin: const Offset(0.85, 0.85), duration: 500.ms, curve: Curves.easeOutBack),
    };
  }

  _MoodConfig _moodConfig(FandoghiMood mood) => switch (mood) {
        FandoghiMood.happy => _MoodConfig('خوشحال', '😊', AppColors.primary, false),
        FandoghiMood.excited => _MoodConfig('ذوق‌زده', '🤩', const Color(0xFFFFD700), true),
        FandoghiMood.celebrating => _MoodConfig('جشن', '🎉', const Color(0xFFFF6B6B), true),
        FandoghiMood.thinking => _MoodConfig('متفکر', '🤔', const Color(0xFF74B9FF), false),
        FandoghiMood.sleeping => _MoodConfig('خوابالو', '😴', const Color(0xFF636E72), false),
        FandoghiMood.wink => _MoodConfig('چشمک', '😉', AppColors.accent, false),
        FandoghiMood.proud => _MoodConfig('مغرور', '😎', const Color(0xFF00B894), true),
        FandoghiMood.shy => _MoodConfig('خجالتی', '☺️', const Color(0xFFFFB8B8), false),
        FandoghiMood.surprised => _MoodConfig('متعجب', '😮', const Color(0xFFFDCB6E), true),
        FandoghiMood.sad => _MoodConfig('ناراحت مهربان', '🥺', const Color(0xFF74B9FF), false),
      };
}

class _MoodConfig {
  final String label;
  final String emoji;
  final Color glowColor;
  final bool showParticles;
  const _MoodConfig(this.label, this.emoji, this.glowColor, this.showParticles);
}

// ── هاله نور پشت فندقی ───────────────────────────────────────
class _GlowHalo extends StatelessWidget {
  final double size;
  final Color color;
  final bool animate;
  const _GlowHalo({required this.size, required this.color, required this.animate});

  @override
  Widget build(BuildContext context) {
    final halo = Container(
      width: size * 1.35,
      height: size * 1.35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.18), color.withOpacity(0.06), Colors.transparent],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
    if (!animate) return halo;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.05),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeInOut,
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: halo,
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1800.ms, curve: Curves.easeInOut);
  }
}

// ── ذرات جشن ──────────────────────────────────────────────────
class _MoodParticles extends StatelessWidget {
  final double size;
  final FandoghiMood mood;
  const _MoodParticles({required this.size, required this.mood});

  @override
  Widget build(BuildContext context) {
    final count = mood == FandoghiMood.celebrating ? 6 : 3;
    final colors = [const Color(0xFFFFD700), const Color(0xFFFF6B6B), AppColors.primary, AppColors.accent, const Color(0xFF00B894)];
    return SizedBox(
      width: size * 1.6,
      height: size * 1.6,
      child: Stack(
        children: List.generate(count, (i) {
          final angle = (i * 2 * pi / count);
          final radius = size * 0.55;
          final dx = cos(angle) * radius;
          final dy = sin(angle) * radius;
          return Positioned(
            left: size * 0.8 + dx - 6,
            top: size * 0.8 + dy - 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors[i % colors.length], boxShadow: [BoxShadow(color: colors[i % colors.length].withOpacity(0.5), blurRadius: 6)]),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.2, 1.2), duration: (800 + i * 200).ms, curve: Curves.easeInOut)
                .fade(begin: 0.5, end: 1, duration: (800 + i * 200).ms),
          );
        }),
      ),
    );
  }
}

// ── فندقی متحرک با شناوری و tilt ──────────────────────────────
class _AnimatedBunny extends StatelessWidget {
  final double size;
  final FandoghiMood mood;
  final AnimationController floatCtrl;
  final bool animate;
  const _AnimatedBunny({required this.size, required this.mood, required this.floatCtrl, required this.animate});

  @override
  Widget build(BuildContext context) {
    Widget bunny = FandoghiBunny(size: size, mood: mood);

    if (!animate) return bunny;

    // شناوری عمودی
    bunny = AnimatedBuilder(
      animation: floatCtrl,
      builder: (_, child) {
        final dy = sin(floatCtrl.value * pi) * 5;
        final tilt = mood == FandoghiMood.thinking ? sin(floatCtrl.value * pi) * 0.04 : 0.0;
        return Transform.translate(
          offset: Offset(0, -dy),
          child: Transform.rotate(angle: tilt, child: child),
        );
      },
      child: bunny,
    );

    // افکت اختصاصی هر mood
    if (mood == FandoghiMood.excited) {
      bunny = bunny.animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 700.ms, curve: Curves.easeInOut);
    } else if (mood == FandoghiMood.sleeping) {
      bunny = bunny.animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 0.98), end: const Offset(1, 1.02), duration: 1800.ms, curve: Curves.easeInOut);
    }

    return bunny;
  }
}

// ── حباب گفتار پریمیوم ────────────────────────────────────────
class _PremiumSpeechBubble extends StatelessWidget {
  final String text;
  final FandoghiMood mood;
  const _PremiumSpeechBubble({required this.text, required this.mood});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3436) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: _bubbleBorder(mood).withOpacity(0.2), width: 1.5),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.5, color: isDark ? Colors.white : const Color(0xFF2D3436)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0, duration: 400.ms, curve: AppMotion.entrance);
  }

  Color _bubbleBorder(FandoghiMood mood) => switch (mood) {
        FandoghiMood.excited || FandoghiMood.celebrating => const Color(0xFFFFD700),
        FandoghiMood.thinking => const Color(0xFF74B9FF),
        FandoghiMood.sad => const Color(0xFF636E72),
        _ => AppColors.primary,
      };
}
