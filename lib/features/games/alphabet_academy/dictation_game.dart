import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/persian_digits.dart';
import '../../../core/literacy/literacy_path.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/next_today_button.dart';
import '../../../shared/widgets/particle_celebration.dart';

/// املای شنیداری اول دبستان: فندقی کلمه را می‌خواند، کودک کلمهٔ درست را می‌زند.
class AlphabetDictationGame extends StatefulWidget {
  final List<String> words;
  final String title;

  const AlphabetDictationGame({
    super.key,
    this.words = const [],
    this.title = 'املای شنیداری',
  });

  @override
  State<AlphabetDictationGame> createState() => _AlphabetDictationGameState();
}

class _AlphabetDictationGameState extends State<AlphabetDictationGame> {
  static const List<String> _fallback = [
    'آب',
    'بابا',
    'مادر',
    'سیب',
    'نان',
    'دست',
    'باران',
    'ایران',
  ];

  late List<String> _pool;
  String _target = '';
  late List<String> _options;
  int _index = 0;
  int _correct = 0;
  bool _locked = false;
  bool _finished = false;
  static const int _rounds = 5;

  @override
  void initState() {
    super.initState();
    _pool = widget.words
        .map(AudioService.cleanSpokenText)
        .where((w) => w.length >= 2)
        .toSet()
        .toList();
    if (_pool.length < 3) {
      _pool = LiteracyUnit.dictationWords();
    }
    if (_pool.length < 3) {
      _pool = List<String>.from(_fallback);
    }
    _deal();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.instruction('گوش کن؛ بعد کلمه‌ای را که شنیدی لمس کن 👂');
      unawaited(_speak());
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _deal() {
    final rng = Random();
    final previous = _target;
    final candidates = _pool.length < 2
        ? _pool
        : _pool.where((w) => w != previous).toList();
    _target = candidates[rng.nextInt(candidates.length)];
    final others = _pool.where((w) => w != _target).toList()..shuffle(rng);
    _options = <String>[_target, ...others.take(2)]..shuffle(rng);
  }

  Future<void> _speak() async {
    HapticFeedback.lightImpact();
    final spoken = await AudioService.speakWord(_target);
    if (!spoken) {
      await AudioService.spellOut(_target);
    }
  }

  void _pick(String word) {
    if (_locked || _finished) return;
    if (!canStartPlay(context)) return;
    final ok = word == _target;
    setState(() {
      _locked = true;
      if (ok) _correct++;
    });
    GameData.recordAnswer(correct: ok, skill: 'alphabet');
    if (ok) {
      GameData.progressMission('alphabet');
      AudioService.playCorrect();
      FandoghiCoach.correct('آفرین! «$_target» را درست شنیدی');
    } else {
      AudioService.playWrong();
      FandoghiCoach.instruction('کلمه «$_target» بود. یک‌بار دیگر گوش کن.');
    }
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_index + 1 >= _rounds) {
        setState(() => _finished = true);
        GameData.addCoins(_correct * 3);
        GameData.addStars(_correct);
        if (_correct >= 3) {
          GameData.markTodayStation('literacy');
          unawaited(AudioService.win());
        }
        FandoghiCoach.reward(
          _correct >= 3
              ? 'املای خوبی بود 🏆'
              : 'بازم گوش می‌دهیم تا بهتر شود 💪',
        );
      } else {
        setState(() {
          _index++;
          _locked = false;
          _deal();
        });
        unawaited(_speak());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        child: _finished ? _result() : _game(),
      ),
    );
  }

  Widget _game() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              ChildTouchTarget(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: AppFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4E342E),
                  ),
                ),
              ),
              Text(
                '${PersianDigits.toFa(_index + 1)}/${PersianDigits.toFa(_rounds)}',
                style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const FandoghiPremium(
          size: 88,
          mood: FandoghiMood.thinking,
          showParticles: false,
        ),
        const SizedBox(height: 12),
        Text(
          'کدام کلمه را شنیدی؟',
          style: AppFonts.vazirmatn(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _speak,
          icon: const Icon(Icons.volume_up_rounded),
          label: const Text('دوباره بشنو'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),
        for (final word in _options)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: SizedBox(
              width: double.infinity,
              height: 62,
              child: FilledButton(
                onPressed: _locked ? null : () => _pick(word),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2C3E50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFD7CCC8), width: 2),
                  ),
                ),
                child: Text(
                  word,
                  style: AppFonts.vazirmatn(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _result() {
    final passed = _correct >= 3;
    return Stack(
      children: [
        if (passed)
          const Positioned.fill(
            child: IgnorePointer(
              child: ParticleCelebration(trigger: true, particleCount: 36),
            ),
          ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FandoghiPremium(
                size: 90,
                mood: passed ? FandoghiMood.celebrating : FandoghiMood.shy,
                showParticles: passed,
              ),
              const SizedBox(height: 10),
              Text(
                '${PersianDigits.toFa(_correct)} از ${PersianDigits.toFa(_rounds)} درست',
                style: AppFonts.vazirmatn(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: NextTodayButton(justFinished: 'literacy'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _index = 0;
                    _correct = 0;
                    _locked = false;
                    _finished = false;
                    _deal();
                  });
                  unawaited(_speak());
                },
                child: const Text('املای دوباره'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('برگشت'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
