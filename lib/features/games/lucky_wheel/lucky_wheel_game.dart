import 'dart:async';
import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_colors.dart';
import '../../../app/design_tokens.dart';
import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/particle_celebration.dart';

/// ────────────────────────────────────────────────────────────
/// 🎡 فاز ۵۶: چرخ شانس کودکانه
///
/// ضد قمار: همیشه جایزه دارد، یک‌بار در روز، و جایزه‌ها تزئینی
/// هستند نه توانایی‌محور. چرخ با انیمیشن فیزیکی می‌چرخد.
/// ────────────────────────────────────────────────────────────
class LuckyWheelGame extends StatefulWidget {
  const LuckyWheelGame({super.key});

  @override
  State<LuckyWheelGame> createState() => _LuckyWheelGameState();
}

class _LuckyWheelGameState extends State<LuckyWheelGame>
    with SingleTickerProviderStateMixin {
  static const List<(String, String, int, int)> _rewards = <(String, String, int, int)>[
    ('🌟', 'ستاره درخشان', 3, 0),
    ('🪙', 'سکه طلایی', 0, 10),
    ('🎈', 'بادکنک شادی', 1, 5),
    ('🍭', 'آب‌نبات جادویی', 2, 8),
    ('✨', 'جرقه', 0, 15),
    ('🏵️', 'نشان افتخار', 5, 0),
    ('🧸', 'خرس عروسکی', 1, 12),
    ('💎', 'الماس کوچک', 4, 20),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishSpin();
      }
    });

  late final Animation<double> _rotation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutQuart,
  );

  bool _spinning = false;
  (String, String, int, int)? _result;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameData.luckyWheelSpunToday) {
        FandoghiCoach.instruction(
          'امروز چرخ را چرخاندی! فردا دوباره بیا تا جایزه‌ی جدید بگیری 🎡',
        );
      } else {
        FandoghiCoach.instruction(
          'به چرخ شانس خوش آمدی! بچرخان و یک جایزه‌ی قشنگ بگیر — همه برنده می‌شوند! 🎉',
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    FandoghiCoach.clear();
    super.dispose();
  }

  void _spin() {
    if (_spinning || GameData.luckyWheelSpunToday) return;
    setState(() => _spinning = true);
    HapticFeedback.mediumImpact();
    AudioService.swoosh();
    _controller.forward(from: 0);
  }

  void _finishSpin() {
    final rng = Random();
    // همیشه جایزه — فقط انتخاب تصادفی با وزن یکسان (ضد قمار: بدون ضرر)
    _result = _rewards[rng.nextInt(_rewards.length)];
    setState(() => _spinning = false);
    HapticFeedback.lightImpact();
    GameData.spinLucky();
    GameData.addStars(_result!.$3);
    GameData.addCoins(_result!.$4);
    if (_result!.$3 > 0) {
      AudioService.star();
    } else if (_result!.$4 > 0) {
      AudioService.coin();
    }
    AudioService.unlock();
    FandoghiCoach.reward(
      'جایزه‌ی تو: ${_result!.$1} ${_result!.$2}! به دست آوردی 🎊',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        ChildTouchTarget(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white30)),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text('چرخ شانس 🎡 — همیشه برنده!', textAlign: TextAlign.center, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.soft),
                          child: Row(children: [const Text('🎁', style: TextStyle(fontSize: 14)), const SizedBox(width: 4), Text(GameData.luckyWheelSpunToday ? 'فردا' : '۱/روز', style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF6C5CE7)))]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const FandoghiPremium(size: 52, mood: FandoghiMood.excited, showParticles: false),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: Colors.white24)),
                    child: Text(' ضد قمار — هر چرخش یه جایزه تزئینی قشنگ 🎀 ', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _rotation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotation.value * 2 * pi * 3,
                            child: child,
                          );
                        },
                        child: _buildWheel(),
                      ),
                    ),
                  ),
                  if (_result != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          border: Border.all(color: const Color(0xFFFFD700), width: 2),
                          boxShadow: AppShadows.colored(const Color(0xFFFFD700), opacity: 0.3),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.15), shape: BoxShape.circle),
                              child: Text(_result!.$1, style: const TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_result!.$2}! 🎉', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFF2D3436))),
                                  Text('+${_result!.$3} ⭐  +${_result!.$4} 🪙  — به کیف پولت اضافه شد', style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const Icon(Icons.celebration_rounded, color: Color(0xFFFFD700), size: 20),
                          ],
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.elasticOut).shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.5)),
                    ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: PremiumButton(
                            text: GameData.luckyWheelSpunToday ? 'فردا دوباره بیا 🌙' : (_spinning ? 'در حال چرخش...' : 'بچرخان! 🎡'),
                            icon: Icons.casino_rounded,
                            onPressed: (GameData.luckyWheelSpunToday || _spinning) ? () {} : _spin,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('هر روز فقط یک بار — همیشه جایزه، بدون باخت 💛', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // جشن ذرات وقتی نتیجه آمد
            if (_result != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: ParticleCelebration(trigger: _result != null, particleCount: 40),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final maxDimension = math.min(constraints.maxWidth, constraints.maxHeight);
        final base = maxDimension > 0
            ? maxDimension * 0.85
            : math.min(screenWidth * 0.65, screenHeight * 0.38);
        final size = base.clamp(200.0, 320.0);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
            ),
            border: Border.all(color: Colors.amber, width: 6),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: CustomPaint(
            size: Size.square(size),
            painter: _WheelPainter(_rewards),
          ),
        );
      },
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<(String, String, int, int)> rewards;

  _WheelPainter(this.rewards);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final slice = 2 * pi / rewards.length;
    for (var i = 0; i < rewards.length; i++) {
      final start = i * slice - pi / 2;
      final paint = Paint()
        ..color = i.isEven ? const Color(0xFFFFD700) : const Color(0xFFFFA502);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        slice,
        true,
        paint,
      );
      final mid = start + slice / 2;
      final textPos = center +
          Offset(cos(mid), sin(mid)) * (radius * 0.62);
      final tp = TextPainter(
        text: TextSpan(
          text: rewards[i].$1,
          style: const TextStyle(fontSize: 26),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, textPos - Offset(tp.width / 2, tp.height / 2));
    }
    // نشانگر بالا
    final marker = Paint()..color = Colors.white;
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - 14, 4)
        ..lineTo(center.dx + 14, 4)
        ..lineTo(center.dx, 26)
        ..close(),
      marker,
    );
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) => true;
}
