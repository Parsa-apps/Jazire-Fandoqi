import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/learning_content/learning_topics.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/premium_button.dart';

/// ────────────────────────────────────────────────────────────
/// 🎧 فاز ۳۸: بشنو و پیدا کن (حافظه شنیداری)
///
/// فندقی صدای یک چیز را می‌گوید (TTS)؛ کودک باید آن را بین
/// ۴ کارت پیدا کند. تقویت حافظه شنیداری + واژگان.
/// ────────────────────────────────────────────────────────────
class SoundMatchGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const SoundMatchGame({super.key, this.stageId, this.stageNumber});

  @override
  State<SoundMatchGame> createState() => _SoundMatchGameState();
}

class _SoundMatchGameState extends State<SoundMatchGame> {
  static const List<String> _sounds = <String>[
    '🐶', '🐱', '🐮', '🐔', '🦆', '🐸', '🐴', '🐑',
    '🚗', '🚌', '✈️', '🚂', '⏰', '📞', '🚀', '⛵',
  ];

  late LearningCard _target;
  late List<LearningCard> _options;
  int _round = 0;
  int _correct = 0;
  int _score = 0;
  bool _locked = false;
  bool _finished = false;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _newRound();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.instruction(
        'با دقت گوش بده؛ بعد کارت درست را پیدا کن! می‌توانی دکمه صدا را دوباره بزنی 🔊',
      );
      Future<void>.delayed(const Duration(milliseconds: 700), _playSound);
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _newRound() {
    final rng = Random();
    final pool = <LearningCard>[
      for (final s in _sounds)
        LearningCard(id: s, name: s, emoji: s, sound: s),
    ];
    _target = pool[rng.nextInt(pool.length)];
    final others = pool.where((c) => c.id != _target.id).toList()
      ..shuffle();
    _options = <LearningCard>[_target, others[0], others[1], others[2]]
      ..shuffle();
  }

  void _playSound() {
    AudioService.tap();
    unawaited(AudioService.speak(_target.sound));
  }

  void _answer(int index) {
    if (_locked || _finished) return;
    if (!canStartPlay(context)) return;
    final correct = _options[index].id == _target.id;
    setState(() {
      _locked = true;
      _selected = index;
      if (correct) {
        _correct++;
        _score += 10;
      }
    });
    GameData.recordAnswer(correct: correct, skill: 'vocab');
    if (correct) {
      HapticFeedback.lightImpact();
      FandoghiCoach.correct('آفرین! گوش‌هایت عالی کار می‌کنند 👂✨');
      unawaited(AudioService.playCorrect());
    } else {
      FandoghiCoach.incorrect(_target.sound);
      unawaited(AudioService.playWrong());
    }
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_round + 1 >= 6) {
        setState(() => _finished = true);
        GameData.addCoins(_score);
        GameData.addStars(_correct);
        if (widget.stageId != null) {
          GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
        }
        if (_correct >= 4) {
          unawaited(AudioService.win());
        } else {
          unawaited(AudioService.lose());
        }
        FandoghiCoach.reward('حافظه شنیداری‌ات قوی شد! 🎧🏆');
      } else {
        setState(() {
          _round++;
          _selected = null;
          _locked = false;
        });
        _newRound();
        Future<void>.delayed(const Duration(milliseconds: 400), _playSound);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(
          child: _finished ? _buildResult() : _buildGame(),
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              ChildTouchTarget(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'بشنو و پیدا کن 🎧',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // دکمه پخش صدا
        ChildTouchTarget(
          onTap: _playSound,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white38, width: 2),
            ),
            child: const Icon(Icons.volume_up_rounded,
                color: Colors.white, size: 64),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'چه صدایی شنیدی؟',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 26),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              for (var i = 0; i < _options.length; i++)
                _optionCard(i),
            ],
          ),
        ),
        Text(
          'دور ${_round + 1} از ۶',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _optionCard(int index) {
    final card = _options[index];
    final selected = _locked && _selected == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _locked ? null : () => _answer(index),
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? (card.id == _target.id
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFFE74C3C))
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(selected ? 1 : 0.25),
              width: selected ? 2.5 : 1.2,
            ),
          ),
          child: Center(
            child: Text(
              card.emoji,
              style: const TextStyle(fontSize: 46),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎧✨', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text(
            'شنونده حرفه‌ای!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$_correct درست از ۶',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 26),
          PremiumButton(
            text: 'دور جدید 🔄',
            icon: Icons.replay_rounded,
            onPressed: () => setState(() {
              _round = 0;
              _score = 0;
              _correct = 0;
              _locked = false;
              _finished = false;
              _selected = null;
              _newRound();
            }),
          ),
          const SizedBox(height: 12),
          PremiumButton(
            text: 'برگشت 🏠',
            icon: Icons.home_rounded,
            color: const Color(0xFF5C6BC0),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
