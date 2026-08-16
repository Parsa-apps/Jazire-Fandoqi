import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
import '../../../shared/widgets/next_today_button.dart';
import '../../../shared/widgets/particle_celebration.dart';
import '../../../shared/widgets/premium_button.dart';

/// قاب ده‌تایی — ابزار اصلی شمارش کتاب ریاضی اول دبستان.
class TenFrameGame extends StatefulWidget {
  const TenFrameGame({super.key});

  @override
  State<TenFrameGame> createState() => _TenFrameGameState();
}

class _TenFrameGameState extends State<TenFrameGame> {
  static const List<int> _levels = [3, 5, 7, 8, 10, 4, 9, 6];
  int _filled = 0;
  int _round = 0;
  int _score = 0;
  bool _won = false;
  bool _finished = false;

  int get _target => _levels[_round];

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'قاب ده‌تایی ۱۰ خانه دارد. مهره‌ها را بگذار تا عدد ${PersianDigits.toFa(_target)} ساخته شود.',
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 4),
      );
      unawaited(AudioService.speak('عدد $_target را در قاب ده تایی بساز'));
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _add() {
    if (_won || _filled >= 10) return;
    if (!canStartPlay(context)) return;
    HapticFeedback.lightImpact();
    AudioService.tap();
    setState(() => _filled++);
    unawaited(AudioService.speakNumber(_filled));
    _check();
  }

  void _remove() {
    if (_won || _filled <= 0) return;
    HapticFeedback.selectionClick();
    AudioService.back();
    setState(() => _filled--);
    _check();
  }

  void _check() {
    if (_filled != _target) return;
    setState(() => _won = true);
    _score += 12;
    GameData.recordAnswer(correct: true, skill: 'counting');
    GameData.addCoins(10);
    GameData.addStars(1);
    AudioService.win();
    FandoghiCoach.celebrate(
      'آفرین! ${PersianDigits.toFa(_filled)} مهره در قاب ده‌تایی 🎉',
    );

    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (_round + 1 < _levels.length) {
        setState(() {
          _round++;
          _filled = 0;
          _won = false;
        });
        FandoghiCoach.say(
          'حالا عدد ${PersianDigits.toFa(_target)} را بساز.',
          mood: FandoghiMood.happy,
        );
        unawaited(AudioService.speak('عدد $_target'));
      } else {
        GameData.markTodayStation('math');
        FandoghiCoach.reward('قاب ده‌تایی را کامل یاد گرفتی 🏆');
        setState(() => _finished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _header(),
                const SizedBox(height: 8),
                _targetCard(),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _frame(),
                          const SizedBox(height: 20),
                          Text(
                            '${PersianDigits.toFa(_filled)} از ۱۰ خانه پر است',
                            style: AppFonts.vazirmatn(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4E342E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_finished)
                            const NextTodayButton(justFinished: 'math')
                          else
                            _controls(),
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
                  child: ParticleCelebration(trigger: true, particleCount: 40),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Row(
        children: [
          ChildTouchTarget(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFE65100)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'قاب ده‌تایی 🟥',
              style: AppFonts.vazirmatn(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF4E342E),
              ),
            ),
          ),
          Text(
            PersianDigits.toFa(_score),
            style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _targetCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFB74D), width: 2),
      ),
      child: Row(
        children: [
          const FandoghiPremium(size: 48, mood: FandoghiMood.happy, showParticles: false),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'هدف: عدد ${PersianDigits.toFa(_target)}',
              style: AppFonts.vazirmatn(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _frame() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5D4037), width: 3),
      ),
      child: Column(
        children: [
          Row(children: List.generate(5, (i) => _cell(i))),
          Row(children: List.generate(5, (i) => _cell(i + 5))),
        ],
      ),
    );
  }

  Widget _cell(int index) {
    final filled = index < _filled;
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: filled ? const Color(0xFFE53935) : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF5D4037), width: 2),
          ),
        ).animate(key: ValueKey('cell-$index-$filled')).scale(
              duration: 180.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }

  Widget _controls() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _filled > 0 && !_won ? _remove : null,
            icon: const Icon(Icons.remove_rounded),
            label: const Text('یکی کم'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PremiumButton(
            text: _won
                ? 'آفرین'
                : _filled > _target
                    ? 'یکی کم کن'
                    : 'مهره بگذار',
            icon: Icons.add_rounded,
            onPressed: _filled >= 10 || _won ? () {} : _add,
          ),
        ),
      ],
    );
  }
}
