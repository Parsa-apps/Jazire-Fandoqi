import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../app/design_tokens.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/persian_digits.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/particle_celebration.dart';
import '../../../shared/widgets/premium_button.dart';

/// ────────────────────────────────────────────────────────────
/// 🥢 بازی تعاملی چوب‌خط اول دبستان (Tally Marks)
///
/// آموزش بسته‌بندی ۵ تایی چوب‌خط مطابق سرفصل ریاضی پایه اول:
/// ۴ خط عمودی + خط پنجم مورب با انیمیشن و بازخورد چندحسی.
/// ────────────────────────────────────────────────────────────
class TallyMarksGame extends StatefulWidget {
  const TallyMarksGame({super.key});

  @override
  State<TallyMarksGame> createState() => _TallyMarksGameState();
}

class _TallyMarksGameState extends State<TallyMarksGame> {
  int _targetNumber = 5;
  int _currentSticks = 0;
  int _round = 1;
  int _score = 0;
  bool _won = false;
  final List<int> _levels = [3, 5, 7, 10, 12, 15, 8, 14];

  @override
  void initState() {
    super.initState();
    _targetNumber = _levels[0];
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'با ضربه زدن، چوب‌خط‌ها را بکش تا به عدد ${PersianDigits.toFa(_targetNumber)} برسیم! هر ۵ تا یه بسته میشه 🥢',
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 4),
      );
      unawaited(AudioService.speak('عدد $_targetNumber چوب خط بکش'));
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _addStick() {
    if (_won || _currentSticks >= _targetNumber) return;
    if (!canStartPlay(context)) return;

    HapticFeedback.lightImpact();
    setState(() {
      _currentSticks++;
    });

    if (_currentSticks % 5 == 0) {
      AudioService.success();
      FandoghiCoach.say('آفرین! یک بسته ۵ تایی بسته شد 🌟', mood: FandoghiMood.happy);
    } else {
      AudioService.tap();
    }

    if (_currentSticks == _targetNumber) {
      _finishRound();
    }
  }

  void _undoStick() {
    if (_currentSticks <= 0 || _won) return;
    HapticFeedback.selectionClick();
    AudioService.back();
    setState(() {
      _currentSticks--;
    });
  }

  void _resetSticks() {
    if (_currentSticks <= 0 || _won) return;
    HapticFeedback.mediumImpact();
    AudioService.swoosh();
    setState(() {
      _currentSticks = 0;
    });
  }

  void _finishRound() {
    setState(() => _won = true);
    _score += 10;
    GameData.recordAnswer(correct: true, skill: 'counting');
    GameData.addCoins(10);
    GameData.addStars(1);
    AudioService.win();
    FandoghiCoach.celebrate('عالی بود! عدد ${PersianDigits.toFa(_targetNumber)} چوب‌خط با دقت کشیده شد 🎉');

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (_round < _levels.length) {
        setState(() {
          _round++;
          _targetNumber = _levels[_round - 1];
          _currentSticks = 0;
          _won = false;
        });
        FandoghiCoach.say(
          'مرحله ${PersianDigits.toFa(_round)}: حالا عدد ${PersianDigits.toFa(_targetNumber)} چوب‌خط بکش 🥢',
          mood: FandoghiMood.happy,
        );
        unawaited(AudioService.speak('مرحله $_round: عدد $_targetNumber'));
      } else {
        FandoghiCoach.reward('تبریک! تمام مراحل چوب‌خط را با امتیاز عالی تمام کردی 🏆');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bundles = _currentSticks ~/ 5;
    final remaining = _currentSticks % 5;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF3498DB), Color(0xFF2980B9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildTargetCard(),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTallyBoard(bundles, remaining),
                            const SizedBox(height: 20),
                            _buildActionControls(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_won)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleCelebration(trigger: true, particleCount: 50),
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
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Row(
        children: [
          ChildTouchTarget(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: Colors.white30),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'بازی چوب‌خط اول دبستان 🥢',
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.black87),
                const SizedBox(width: 4),
                Text(
                  PersianDigits.toFa(_score),
                  style: AppFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          const FandoghiPremium(size: 48, mood: FandoghiMood.excited, showParticles: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هدف: عدد ${PersianDigits.toFa(_targetNumber)}',
                  style: AppFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  'تا حالا کشیدی: ${PersianDigits.toFa(_currentSticks)} چوب‌خط',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _currentSticks == _targetNumber ? Colors.green : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'خواندن صوتی',
            onPressed: () {
              HapticFeedback.lightImpact();
              AudioService.speak('هدف: عدد $_targetNumber. تا حالا $_currentSticks تا کشیدی');
            },
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2980B9)),
          ),
        ],
      ),
    );
  }

  Widget _buildTallyBoard(int bundles, int remaining) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: AppShadows.soft,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 24,
        runSpacing: 20,
        children: [
          for (var i = 0; i < bundles; i++)
            _TallyBundleWidget(count: 5).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
          if (remaining > 0)
            _TallyBundleWidget(count: remaining).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
          if (_currentSticks == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'روی دکمه «چوب‌خط بکش 🥢» بزن تا شروع کنیم!',
                textAlign: TextAlign.center,
                style: AppFonts.vazirmatn(
                  fontSize: 14,
                  color: Colors.black45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionControls() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: PremiumButton(
            text: _currentSticks >= _targetNumber ? 'آفرین! تکمیل شد ✨' : 'چوب‌خط بکش 🥢 (+۱)',
            icon: Icons.draw_rounded,
            onPressed: _currentSticks >= _targetNumber ? () {} : _addStick,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _currentSticks > 0 ? _undoStick : null,
              icon: const Icon(Icons.undo_rounded, size: 18),
              label: const Text('یکی بردار'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(width: 14),
            OutlinedButton.icon(
              onPressed: _currentSticks > 0 ? _resetSticks : null,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('شروع دوباره'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TallyBundleWidget extends StatelessWidget {
  final int count;

  const _TallyBundleWidget({required this.count});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(70, 75),
      painter: _TallyPainter(count),
    );
  }
}

class _TallyPainter extends CustomPainter {
  final int count;

  _TallyPainter(this.count);

  @override
  void paint(Canvas canvas, Size size) {
    final stickPaint = Paint()
      ..color = const Color(0xFFD35400)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final slashPaint = Paint()
      ..color = const Color(0xFFC0392B)
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    final verticalCount = math.min(count, 4);
    final spacing = size.width / 5;

    // Draw vertical sticks
    for (var i = 0; i < verticalCount; i++) {
      final x = spacing * (i + 1);
      canvas.drawLine(
        Offset(x, 10),
        Offset(x, size.height - 10),
        stickPaint,
      );
    }

    // If 5th stick, draw diagonal strike
    if (count >= 5) {
      canvas.drawLine(
        Offset(4, size.height - 16),
        Offset(size.width - 4, 16),
        slashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TallyPainter oldDelegate) => oldDelegate.count != count;
}
