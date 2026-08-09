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
/// 🧠 فاز ۳۷: الگویاب (Pattern & Logic)
///
/// یک الگوی تکراری از ایموجی‌ها نشان داده می‌شود (ABAB، AABB، ABC)
/// و کودک باید «بعدی» را از بین ۳ گزینه انتخاب کند.
/// ────────────────────────────────────────────────────────────
class PatternGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const PatternGame({super.key, this.stageId, this.stageNumber});

  @override
  State<PatternGame> createState() => _PatternGameState();
}

class _PatternGameState extends State<PatternGame> {
  static const List<String> _pool = <String>[
    '🔴', '🔵', '🟢', '🟡', '🟣', '🟠', '⭐', '❤️',
  ];

  late List<String> _pattern;
  late int _correctNext;
  int _round = 0;
  int _score = 0;
  int _correct = 0;
  bool _locked = false;
  bool _finished = false;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _newPattern();
    _roundOptions = _buildOptions();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.instruction(
        'الگو را ببین و حدس بزن بعدی کدام است! مثلاً آبی، قرمز، آبی، قرمز، بعدی؟ 🧠',
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _newPattern() {
    final rng = Random();
    // الگوهای ABAB / AABB / ABCABC
    final kind = rng.nextInt(3);
    final a = _pool[rng.nextInt(_pool.length)];
    var b = _pool[rng.nextInt(_pool.length)];
    var c = _pool[rng.nextInt(_pool.length)];
    while (b == a) {
      b = _pool[rng.nextInt(_pool.length)];
    }
    if (kind == 2) {
      while (c == a || c == b) {
        c = _pool[rng.nextInt(_pool.length)];
      }
    }
    _pattern = <String>[];
    switch (kind) {
      case 0:
        _pattern = <String>[a, b, a, b, a];
      case 1:
        _pattern = <String>[a, a, b, b, a];
      case 2:
        _pattern = <String>[a, b, c, a, b];
    }
    _correctNext = switch (kind) {
      0 => b,
      1 => b,
      _ => c,
    };
  }

  void _answer(int index, List<String> options) {
    if (_locked || _finished) return;
    if (!canStartPlay(context)) return;
    final correct = options[index] == _correctNext;
    setState(() {
      _locked = true;
      _selected = index;
      if (correct) {
        _correct++;
        _score += 10;
      }
    });
    GameData.recordAnswer(correct: correct, skill: 'pattern');
    if (correct) {
      HapticFeedback.lightImpact();
      FandoghiCoach.correct('آفرین! الگو را پیدا کردی 🧠✨');
      unawaited(AudioService.playCorrect());
    } else {
      FandoghiCoach.incorrect(_correctNext);
      unawaited(AudioService.playWrong());
    }
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_round + 1 >= 6) {
        setState(() => _finished = true);
        GameData.addCoins(_score);
        GameData.addStars(_correct);
        if (widget.stageId != null) {
          GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
        }
        FandoghiCoach.reward('تو یک کارآگاه الگو هستی! 🕵️');
      } else {
        setState(() {
          _round++;
          _selected = null;
          _locked = false;
        });
        _newPattern();
        _roundOptions = _buildOptions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.purple),
        child: SafeArea(
          child: _finished ? _buildResult() : _buildGame(),
        ),
      ),
    );
  }

  /// گزینه‌های دور جاری — یک‌بار ساخته می‌شوند تا نمایش، پاسخ و
  /// هایلایت درست/غلط همیشه روی یک لیست باشند.
  late List<String> _roundOptions = _buildOptions();

  List<String> _buildOptions() {
    final others = _pool
        .where((x) => x != _correctNext)
        .toList()
      ..shuffle();
    return <String>[_correctNext, others[0], others[1]]..shuffle();
  }

  Widget _buildGame() {
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
                  'الگویاب 🧠',
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
        Text(
          'بعدی کدام است؟',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 26),
        // الگو
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final e in _pattern)
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(e, style: const TextStyle(fontSize: 30)),
              ),
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: const Text('؟', style: TextStyle(fontSize: 26, color: Colors.amber)),
            ),
          ],
        ),
        const SizedBox(height: 40),
        for (final option in options) ...[
          SizedBox(
            width: 170,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _locked ? null : () => _answer(options.indexOf(option), options),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 64),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _locked && _selected == options.indexOf(option)
                        ? (option == _correctNext
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFFE74C3C))
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30, width: 1.5),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        const Spacer(),
        Text(
          'دور ${_round + 1} از ۶',
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
          const Text('🧠✨', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text(
            'کارآگاه الگو!',
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
              _newPattern();
              _roundOptions = _buildOptions();
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
