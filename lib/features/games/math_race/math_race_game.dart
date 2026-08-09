import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/premium_button.dart';

/// ────────────────────────────────────────────────────────────
/// 🏎️ فاز ۳۶: مسابقه ماشین فندقی (ریاضی)
///
/// برای هر جواب درست، ماشین به سمت پرچم جلو می‌رود؛ جواب غلط
/// کمی عقب می‌کشد. مناسب ۵-۸ سال — جمع و تفریق تا ۲۰.
/// ────────────────────────────────────────────────────────────
class MathRaceGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const MathRaceGame({super.key, this.stageId, this.stageNumber});

  @override
  State<MathRaceGame> createState() => _MathRaceGameState();
}

class _MathRaceGameState extends State<MathRaceGame> {
  static const int _questionCount = 10;

  final List<(int, int, String)> _questions = <(int, int, String)>[];
  int _index = 0;
  int _correct = 0;
  int _progress = 0; // 0..100
  bool _locked = false;
  bool _finished = false;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _buildQuestions();
    _roundOptions = _buildOptions();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.instruction(
        'مسابقه ماشین فندقی! هر جواب درست، ماشین را به پرچم نزدیک‌تر می‌کند 🏁',
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _buildQuestions() {
    final rng = Random();
    _questions.clear();
    for (var i = 0; i < _questionCount; i++) {
      final useAdd = rng.nextBool();
      if (useAdd) {
        final a = 1 + rng.nextInt(10);
        final b = 1 + rng.nextInt(10);
        _questions.add((a, b, '+'));
      } else {
        final a = 3 + rng.nextInt(15);
        final b = 1 + rng.nextInt(a);
        _questions.add((a, b, '-'));
      }
    }
  }

  int _answerOf((int, int, String) q) =>
      q.$3 == '+' ? q.$1 + q.$2 : q.$1 - q.$2;

  void _answer(int optionIndex) {
    if (_locked || _finished) return;
    if (!canStartPlay(context)) return;
    final q = _questions[_index];
    final correct = optionIndex == _answerOf(q);
    FandoghiCoach.cancelSmartHint();
    setState(() {
      _locked = true;
      _selected = optionIndex;
      if (correct) {
        _correct++;
        _progress = min(100, _progress + 10);
      } else {
        _progress = max(0, _progress - 5);
      }
    });
    GameData.recordAnswer(correct: correct, skill: 'math');
    if (correct) {
      // فاز ۵۲: پیشرفت مأموریت روزانه ریاضی
      GameData.progressMission('math');
      HapticFeedback.lightImpact();
      FandoghiCoach.correct('آفرین! ماشین جلو رفت 🚗💨');
      unawaited(AudioService.playCorrect());
    } else {
      FandoghiCoach.incorrect('${_answerOf(q)}');
      unawaited(AudioService.playWrong());
    }

    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_index + 1 >= _questionCount || _progress >= 100) {
        _finish();
      } else {
        setState(() {
          _index++;
          _roundOptions = _buildOptions();
          _selected = null;
          _locked = false;
        });
      }
    });
  }

  void _finish() {
    setState(() => _finished = true);
    GameData.addCoins(_correct * 2);
    GameData.addStars(_correct ~/ 2);
    GameData.updateHighScore(_correct * 10, 'math_race');
    if (widget.stageId != null) {
      GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
    }
    FandoghiCoach.reward(
      _correct >= 7
          ? 'چه راننده‌ی سریعی! $_correct جواب درست دادی 🏆'
          : 'مسابقه تمام شد! با تمرین، تندتر می‌شوی 💪',
    );
  }

  void _restart() {
    setState(() {
      _buildQuestions();
      _index = 0;
      _roundOptions = _buildOptions();
      _correct = 0;
      _progress = 0;
      _locked = false;
      _finished = false;
      _selected = null;
    });
    FandoghiCoach.instruction('دور جدید! ماشین آماده است 🏁');
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

  /// گزینه‌های دور جاری — یک‌بار ساخته می‌شوند تا نمایش و پاسخ همیشه
  /// روی یک لیست باشند.
  /// ⚠️ بدون initializer: ساخت در initState بعد از _buildQuestions
  late List<int> _roundOptions;

  List<int> _buildOptions() {
    final q = _questions[_index];
    final answer = _answerOf(q);
    // گزینه‌ها: جواب درست + ۲ گزینه نزدیک (همه غیرمنفی — دور ۸:
    // قبلاً برای جواب ۰ گزینه «۱-» نمایش داده می‌شد)
    final options = <int>{answer, answer + 1};
    options.add(answer > 0 ? answer - 1 : answer + 2);
    return options.toList()..shuffle();
  }

  Widget _buildGame() {
    final q = _questions[_index];
    final answer = _answerOf(q);
    final options = _roundOptions;
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
                  'مسابقه ماشین 🏎️',
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
        const SizedBox(height: 10),
        // پیست مسابقه (دور ۷: عرض کامل + بدون کلیپ — قبلاً Stack عرض صفر می‌گرفت)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 18,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  left: (MediaQuery.of(context).size.width - 48) * _progress / 100,
                  top: 0,
                  child: const Text('🏎️', style: TextStyle(fontSize: 32)),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: const Text('🏁', style: TextStyle(fontSize: 32)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 34),
        Text(
          '${q.$1} ${q.$3} ${q.$2} = ؟',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 30),
        for (final option in options) ...[
          SizedBox(
            width: 160,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _locked ? null : () => _answer(option),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 64),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _locked && _selected == option
                        ? (option == answer
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFFE74C3C))
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '$option',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        const Spacer(),
        Text(
          'سوال ${_index + 1} از $_questionCount',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_correct >= 7 ? '🏆' : '🚗', style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text(
            'مسابقه تمام شد!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$_correct جواب درست از $_questionCount',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 26),
          PremiumButton(
            text: 'مسابقه دوباره 🔄',
            icon: Icons.replay_rounded,
            onPressed: _restart,
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
