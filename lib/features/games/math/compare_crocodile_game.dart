import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// تمساح ریاضی اول دبستان: دهان باز به سمت عدد بزرگ‌تر.
class CompareCrocodileGame extends StatefulWidget {
  const CompareCrocodileGame({super.key});

  @override
  State<CompareCrocodileGame> createState() => _CompareCrocodileGameState();
}

class _CompareCrocodileGameState extends State<CompareCrocodileGame> {
  static const int _rounds = 8;
  final Random _rng = Random();
  late int _left;
  late int _right;
  int _index = 0;
  int _correct = 0;
  bool _locked = false;
  bool _finished = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _nextPair();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'تمساح همیشه عدد بزرگ‌تر را می‌خورد! علامت درست را بزن.',
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _nextPair() {
    _left = 1 + _rng.nextInt(20);
    _right = 1 + _rng.nextInt(20);
    if (_index.isEven && _left == _right) {
      _right = (_right % 20) + 1;
    }
  }

  String get _answer {
    if (_left > _right) return '>';
    if (_left < _right) return '<';
    return '=';
  }

  void _pick(String symbol) {
    if (_locked || _finished) return;
    if (!canStartPlay(context)) return;
    final ok = symbol == _answer;
    setState(() {
      _locked = true;
      if (ok) _correct++;
    });
    GameData.recordAnswer(correct: ok, skill: 'math');
    if (ok) {
      GameData.progressMission('math');
      AudioService.playCorrect();
      FandoghiCoach.correct('آفرین! تمساح درست دهان باز کرد 🐊');
    } else {
      AudioService.playWrong();
      FandoghiCoach.instruction(
        'جواب درست ${_label(_answer)} بود. تمساح عدد بزرگ را می‌خورد.',
      );
    }

    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_index + 1 >= _rounds) {
        setState(() {
          _finished = true;
          _won = _correct >= 5;
        });
        GameData.addCoins(_correct * 2);
        GameData.addStars(_correct ~/ 2);
        if (_won) {
          unawaited(AudioService.win());
          FandoghiCoach.reward('تمساح را خوب شناختی 🏆');
        } else {
          FandoghiCoach.say('یک دور دیگر تمرین می‌کنیم 💪', mood: FandoghiMood.shy);
        }
      } else {
        setState(() {
          _index++;
          _locked = false;
          _nextPair();
        });
      }
    });
  }

  String _label(String s) {
    switch (s) {
      case '>':
        return 'بزرگ‌تر';
      case '<':
        return 'کوچک‌تر';
      default:
        return 'مساوی';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: _finished ? _result() : _game(),
      ),
    );
  }

  Widget _game() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          child: Row(
            children: [
              ChildTouchTarget(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded, size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تمساح بزرگ‌تر و کوچک‌تر 🐊',
                  style: AppFonts.vazirmatn(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'سؤال ${PersianDigits.toFa(_index + 1)} از ${PersianDigits.toFa(_rounds)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _numberBubble(_left),
              const Text('🐊', style: TextStyle(fontSize: 56)),
              _numberBubble(_right),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _choice('>', 'عدد سمت چپ بزرگ‌تر است  >'),
              _choice('<', 'عدد سمت راست بزرگ‌تر است  <'),
              _choice('=', 'مساوی  =  هر دو عدد یکی‌اند'),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _numberBubble(int n) {
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2E7D32), width: 3),
      ),
      child: Text(
        PersianDigits.toFa(n),
        style: AppFonts.vazirmatn(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1B5E20),
        ),
      ),
    );
  }

  Widget _choice(String symbol, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: FilledButton(
          onPressed: _locked ? null : () => _pick(symbol),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1B5E20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFF81C784), width: 2),
            ),
          ),
          child: Text(
            label,
            style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _result() {
    return Stack(
      children: [
        if (_won)
          const Positioned.fill(
            child: IgnorePointer(
              child: ParticleCelebration(trigger: true, particleCount: 40),
            ),
          ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FandoghiPremium(
                  size: 96,
                  mood: _won ? FandoghiMood.celebrating : FandoghiMood.shy,
                  showParticles: _won,
                ),
                const SizedBox(height: 12),
                Text(
                  '${PersianDigits.toFa(_correct)} از ${PersianDigits.toFa(_rounds)} درست',
                  style: AppFonts.vazirmatn(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                const NextTodayButton(justFinished: 'math'),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _index = 0;
                      _correct = 0;
                      _locked = false;
                      _finished = false;
                      _won = false;
                      _nextPair();
                    });
                  },
                  child: const Text('دور دوباره'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('برگشت'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
