import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../core/growth/growth.dart';
import '../../core/play_limit.dart';
import '../../shared/widgets/child_touch_target.dart';
import '../../shared/widgets/particle_celebration.dart';
import '../../shared/widgets/premium_button.dart';

class LifeSkillsGame extends StatefulWidget {
  final LifeSkillTopic topic;

  const LifeSkillsGame({super.key, required this.topic});

  @override
  State<LifeSkillsGame> createState() => _LifeSkillsGameState();
}

class _LifeSkillsGameState extends State<LifeSkillsGame> {
  late List<LifeSkillQuestion> _round;
  late List<String> _options;
  int _index = 0;
  int _correct = 0;
  int _wrongStreak = 0;
  bool _locked = false;
  bool _finished = false;
  int? _selected;
  bool _wasCorrect = false;

  @override
  void initState() {
    super.initState();
    _prepareRound();
    ActivityTracker.recordOpen(
      route: '/life-skills/${widget.topic.id}',
      title: widget.topic.title,
      skill: widget.topic.skill,
    );
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameData.isDailyLimitReached) {
        FandoghiCoach.judge('زمان بازی امروز تمام شده ⏰');
        return;
      }
      FandoghiCoach.instruction('به دنیای ${widget.topic.title} خوش آمدی!');
      _speakCurrentQuestion();
    });
  }

  void _prepareRound() {
    final pool = List<LifeSkillQuestion>.of(widget.topic.questions)..shuffle(Random());
    _round = pool.take(5).toList();
    _options = _buildOptions();
  }

  LifeSkillQuestion get _current => _round[_index];

  void _speakCurrentQuestion() {
    if (widget.topic.questions.isEmpty) return;
    unawaited(AudioService.speak(_current.prompt));
  }

  List<String> _buildOptions() {
    final count = AdaptiveCoach.optionCountForAge();
    final correct = _current.options[_current.correctIndex];
    final others = List<String>.from(_current.options)..remove(correct);
    others.shuffle(Random());
    final picked = <String>[correct, ...others.take(max(1, count - 1))];
    picked.shuffle(Random());
    return picked;
  }

  void _answer(int i) {
    if (_locked || _finished) return;
    if (!canStartPlay(context)) return;
    FandoghiCoach.cancelSmartHint();
    AudioService.tap();
    final picked = _options[i];
    final correct = picked == _current.options[_current.correctIndex];
    setState(() {
      _locked = true;
      _selected = i;
      _wasCorrect = correct;
      if (correct) {
        _correct++;
        _wrongStreak = 0;
      } else {
        _wrongStreak++;
      }
    });
    GameData.recordAnswer(correct: correct, skill: widget.topic.skill);
    ActivityTracker.noteAnswer(correct: correct);
    WeeklyEngine.progress('correct');
    WeeklyEngine.progress('life');
    if (correct) {
      HapticFeedback.lightImpact();
      unawaited(AudioService.playCorrect());
      FandoghiCoach.correct(_current.fact);
      if (_current.vocab.isNotEmpty) VocabularyJournal.add(_current.vocab);
    } else {
      unawaited(AudioService.playWrong());
      final hint = AdaptiveCoach.hintAfterMistakes(
        _wrongStreak,
        _current.options[_current.correctIndex],
      );
      FandoghiCoach.incorrect(hint);
    }

    final skip = !correct && AdaptiveCoach.shouldSkip(_wrongStreak);
    Future<void>.delayed(Duration(milliseconds: skip ? 900 : 1400), () {
      if (!mounted) return;
      if (_index + 1 >= _round.length) {
        _finish();
      } else {
        setState(() {
          _index++;
          _options = _buildOptions();
          _selected = null;
          _locked = false;
          if (skip) _wrongStreak = 0;
        });
        _speakCurrentQuestion();
      }
    });
  }

  void _finish() {
    if (_finished) return;
    setState(() => _finished = true);
    final score = _correct * 8;
    GameData.addCoins(score);
    GameData.addStars(_correct);
    GrowthStore.lifeSkillPoints[widget.topic.id] =
        (GrowthStore.lifeSkillPoints[widget.topic.id] ?? 0) + _correct;
    if (_correct >= 3 && !GrowthStore.completedLifeTopics.contains(widget.topic.id)) {
      GrowthStore.completedLifeTopics = [...GrowthStore.completedLifeTopics, widget.topic.id];
    }
    GrowthStore.save();
    WeeklyEngine.progress('life');
    FandoghiCoach.reward('دنیای ${widget.topic.title} تمام شد! 🏆');
    unawaited(AudioService.playWin());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(child: _finished ? _result() : _game()),
      ),
    );
  }

  Widget _game() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              ChildTouchTarget(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
              ),
              Expanded(
                child: Text(
                  widget.topic.title,
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'خواندن صوتی سؤال',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _speakCurrentQuestion();
                },
                icon: const Icon(Icons.volume_up_rounded, color: Colors.amberAccent, size: 26),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: LinearProgressIndicator(
            value: (_index + 1) / _round.length,
            backgroundColor: Colors.white24,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Text(_current.emoji, style: const TextStyle(fontSize: 64)),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _current.prompt,
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, height: 1.4),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'خواندن صوتی',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  AudioService.speak(_current.prompt);
                },
                icon: const Icon(Icons.volume_up_rounded, size: 20, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
            itemCount: _options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final selected = _locked && _selected == i;
              final bg = selected
                  ? (_wasCorrect ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C))
                  : Colors.white.withOpacity(0.14);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: _locked ? null : () => _answer(i),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 64),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(selected ? 1 : 0.25)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _options[i],
                            textAlign: TextAlign.center,
                            style: AppFonts.vazirmatn(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          tooltip: 'تلفظ گزینه',
                          icon: const Icon(Icons.volume_up_rounded, size: 16, color: Colors.white70),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            AudioService.speak(_options[i]);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _result() {
    final ok = _correct >= 3;
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ok ? '🌟' : '🌱', style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 12),
                Text(
                  ok ? 'آفرین به قهرمان مهارت‌ها!' : 'خوب تلاش کردی!',
                  style: AppFonts.vazirmatn(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_correct از ${_round.length} پاسخ درست',
                  style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    text: 'ادامه و دریافت جایزه',
                    icon: Icons.check_circle_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (ok)
          const Positioned.fill(
            child: IgnorePointer(child: ParticleCelebration(trigger: true)),
          ),
      ],
    );
  }
}
