import 'dart:async';

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
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/particle_celebration.dart';
import '../../../shared/widgets/premium_button.dart';

/// ────────────────────────────────────────────────────────────
/// 🐸 بازی محور اعداد جهنده با فندقی (پایه اول ابتدایی)
///
/// آموزش مفهوم جمع و تفریق روی محور اعداد ۰ تا ۲۰:
/// جهش‌های روبه‌جلو برای جمع (+) و جهش روبه‌عقب برای تفریق (-).
/// ────────────────────────────────────────────────────────────
class NumberLineGame extends StatefulWidget {
  const NumberLineGame({super.key});

  @override
  State<NumberLineGame> createState() => _NumberLineGameState();
}

class _Equation {
  final int start;
  final int step;
  final bool isAddition;
  int get answer => isAddition ? start + step : start - step;
  String get text => isAddition ? '$start + $step = ؟' : '$start - $step = ؟';

  const _Equation(this.start, this.step, this.isAddition);
}

class _NumberLineGameState extends State<NumberLineGame> {
  static const List<_Equation> _equations = [
    _Equation(3, 4, true),   // 3 + 4 = 7
    _Equation(8, 3, false),  // 8 - 3 = 5
    _Equation(5, 5, true),   // 5 + 5 = 10
    _Equation(9, 4, false),  // 9 - 4 = 5
    _Equation(6, 6, true),   // 6 + 6 = 12
    _Equation(12, 5, false), // 12 - 5 = 7
    _Equation(7, 8, true),   // 7 + 8 = 15
  ];

  int _round = 0;
  late int _fandoghiPos;
  int _score = 0;
  bool _won = false;

  _Equation get _eq => _equations[_round];

  @override
  void initState() {
    super.initState();
    _fandoghiPos = _eq.start;
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _announceRound();
    });
  }

  void _announceRound() {
    FandoghiCoach.say(
      'فندقی روی عدد ${_eq.start} است. با دکمه‌های پرش، مسئله «${_eq.text}» را حل کن! 🐸',
      mood: FandoghiMood.excited,
      duration: const Duration(seconds: 4),
    );
    unawaited(AudioService.speak('مسئله ${_eq.text}'));
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _jumpForward() {
    if (_won || _fandoghiPos >= 20) return;
    if (!canStartPlay(context)) return;
    HapticFeedback.lightImpact();
    AudioService.swoosh();
    setState(() => _fandoghiPos++);
    AudioService.speakNumber(_fandoghiPos);
    _checkAnswer();
  }

  void _jumpBackward() {
    if (_won || _fandoghiPos <= 0) return;
    if (!canStartPlay(context)) return;
    HapticFeedback.lightImpact();
    AudioService.back();
    setState(() => _fandoghiPos--);
    AudioService.speakNumber(_fandoghiPos);
    _checkAnswer();
  }

  void _checkAnswer() {
    if (_fandoghiPos == _eq.answer) {
      setState(() => _won = true);
      _score += 15;
      GameData.recordAnswer(correct: true, skill: 'counting');
      GameData.addCoins(12);
      GameData.addStars(1);
      AudioService.win();
      FandoghiCoach.celebrate('آفرین! فندقی دقیقاً روی عدد ${_eq.answer} فرود آمد 🎉');

      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        if (_round + 1 < _equations.length) {
          setState(() {
            _round++;
            _fandoghiPos = _eq.start;
            _won = false;
          });
          _announceRound();
        } else {
          FandoghiCoach.reward('آفرین! قهرمان حل مسائل روی محور اعداد شدی 🏆');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF16A085), Color(0xFF1ABC9C), Color(0xFF2C3E50)],
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
                  const SizedBox(height: 6),
                  _buildEquationCard(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildNumberLineBoard(),
                            const SizedBox(height: 24),
                            _buildJumpControls(),
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
              'محور اعداد جهنده 🐸',
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
                  '$_score',
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

  Widget _buildEquationCard() {
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
          const FandoghiPremium(size: 46, mood: FandoghiMood.excited, showParticles: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _eq.text,
                  style: AppFonts.vazirmatn(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF16A085),
                  ),
                ),
                Text(
                  'موقعیت فندقی: عدد $_fandoghiPos',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _fandoghiPos == _eq.answer ? Colors.green : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'خواندن صوتی',
            onPressed: () {
              HapticFeedback.lightImpact();
              AudioService.speak('مسئله: ${_eq.text}. فندقی روی عدد $_fandoghiPos است');
            },
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF16A085)),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberLineBoard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.medium,
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Column(
        children: [
          // خط محور با گره‌ها و نشانگر فندقی
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // نمایش راست به چپ مطابق ریاضی فارسی
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: List.generate(21, (index) {
                  final isCurrent = index == _fandoghiPos;
                  final isStart = index == _eq.start;

                  return Container(
                    width: 44,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        // آیکون فندقی در خانه جاری
                        SizedBox(
                          height: 38,
                          child: isCurrent
                              ? const Text('🐸', style: TextStyle(fontSize: 26))
                                  .animate()
                                  .bounce(duration: 400.ms)
                              : (isStart ? const Text('🚩', style: TextStyle(fontSize: 18)) : const SizedBox.shrink()),
                        ),
                        const SizedBox(height: 4),
                        // نشانگر خطی
                        Container(
                          width: isCurrent ? 14 : 6,
                          height: isCurrent ? 14 : 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? Colors.orange
                                : (isStart ? Colors.teal : Colors.grey.shade400),
                          ),
                        ),
                        Container(width: 2, height: 16, color: Colors.grey.shade400),
                        const SizedBox(height: 6),
                        // عدد
                        Text(
                          '$index',
                          style: AppFonts.vazirmatn(
                            fontSize: isCurrent ? 16 : 12,
                            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                            color: isCurrent ? Colors.orange.shade800 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          const Divider(height: 20, thickness: 3, color: Color(0xFF1ABC9C)),
          Text(
            _eq.isAddition
                ? 'برای جمع (+)، با دکمه جهش به جلو برو ➡️'
                : 'برای تفریق (-)، با دکمه جهش به عقب برگرد ⬅️',
            style: AppFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJumpControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _fandoghiPos > 0 ? _jumpBackward : null,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('جهش به عقب (-۱)'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _fandoghiPos < 20 ? _jumpForward : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('جهش به جلو (+۱)'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
