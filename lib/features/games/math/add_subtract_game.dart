import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../core/math/grade1_math.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/next_today_button.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/particle_celebration.dart';

/// جمع و تفریق اول دبستان با مهره — فقط تا ۲۰، بدون ضرب.
class AddSubtractGame extends StatefulWidget {
  const AddSubtractGame({super.key});

  @override
  State<AddSubtractGame> createState() => _AddSubtractGameState();
}

class _AddSubtractItem {
  final int a;
  final int b;
  final bool add;
  const _AddSubtractItem(this.a, this.b, this.add);

  int get answer => add ? a + b : a - b;
  String get op => add ? '+' : '−';
}

class _AddSubtractGameState extends State<AddSubtractGame> {
  static const int _rounds = 8;
  final List<_AddSubtractItem> _items = <_AddSubtractItem>[];
  int _index = 0;
  int _correct = 0;
  int _streakOk = 0;
  int _streakBad = 0;
  int _level = 1;
  bool _locked = false;
  bool _finished = false;
  late List<int> _options;

  _AddSubtractItem get _item => _items[_index];

  void _dealRound() {
    final rng = Random();
    _items.clear();
    for (var i = 0; i < _rounds; i++) {
      final problem = Grade1Math.nextAddOrSubtract(random: rng, level: _level);
      _items.add(_AddSubtractItem(problem.$1, problem.$2, problem.$3 == '+'));
    }
  }

  /// سطح وسط دور عوض شد؛ سؤال‌های باقی‌مانده باید با سطح تازه ساخته شوند.
  void _rewriteRemaining() {
    final rng = Random();
    for (var i = _index + 1; i < _items.length; i++) {
      final problem = Grade1Math.nextAddOrSubtract(random: rng, level: _level);
      _items[i] = _AddSubtractItem(problem.$1, problem.$2, problem.$3 == '+');
    }
  }

  @override
  void initState() {
    super.initState();
    _dealRound();
    _options = _choices();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'مهره‌ها را بشمار و جواب جمع یا تفریق را بزن. فقط تا بیست.',
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

  List<int> _choices() {
    final answer = _item.answer;
    final pool = <int>{answer};
    if (Grade1Math.isInRange(answer + 1)) pool.add(answer + 1);
    if (Grade1Math.isInRange(answer - 1)) pool.add(answer - 1);
    if (pool.length < 3 && Grade1Math.isInRange(answer + 2)) pool.add(answer + 2);
    return pool.toList()..shuffle();
  }

  void _pick(int value) {
    if (_locked || _finished) return;
    if (!canStartPlay(context)) return;
    final ok = value == _item.answer;
    setState(() {
      _locked = true;
      if (ok) {
        _correct++;
        _streakOk++;
        _streakBad = 0;
        if (_streakOk >= 3) {
          final next = (_level + 1).clamp(1, 3);
          if (next != _level) {
            _level = next;
            _rewriteRemaining();
          }
        }
      } else {
        _streakBad++;
        _streakOk = 0;
        if (_streakBad >= 2) {
          final next = (_level - 1).clamp(1, 3);
          if (next != _level) {
            _level = next;
            _rewriteRemaining();
          }
        }
      }
    });
    GameData.recordAnswer(correct: ok, skill: 'math');
    if (ok) {
      GameData.progressMission('math');
      AudioService.playCorrect();
      FandoghiCoach.correct('آفرین! جواب ${Grade1Math.number(_item.answer)} بود.');
    } else {
      AudioService.playWrong();
      FandoghiCoach.instruction(
        'جواب ${Grade1Math.number(_item.answer)} است. مهره‌ها را دوباره بشمار.',
      );
    }
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_index + 1 >= _items.length) {
        setState(() => _finished = true);
        GameData.markTodayStation('math');
        GameData.addCoins(_correct * 2);
        GameData.addStars(_correct ~/ 2);
        if (_correct >= 5) unawaited(AudioService.win());
      } else {
        setState(() {
          _index++;
          _locked = false;
          _options = _choices();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(child: _finished ? _result() : _game()),
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
                  'جمع و تفریق تا ۲۰ ➕',
                  style: AppFonts.vazirmatn(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'سؤال ${Grade1Math.number(_index + 1)} از ${Grade1Math.number(_items.length)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          Grade1Math.equation(_item.a, _item.op, _item.b),
          style: AppFonts.vazirmatn(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFBF360C),
          ),
        ),
        const SizedBox(height: 12),
        _beads(_item.a, const Color(0xFFE53935)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            _item.add ? 'و' : 'برمی‌داریم',
            style: AppFonts.vazirmatn(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        _beads(_item.b, _item.add ? const Color(0xFF1E88E5) : const Color(0xFF8D6E63)),
        const Spacer(),
        for (final option in _options)
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _locked ? null : () => _pick(option),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE65100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFFFB74D), width: 2),
                  ),
                ),
                child: Text(
                  Grade1Math.number(option),
                  style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 22),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _beads(int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: List.generate(
          count,
          (_) => Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _result() {
    final passed = _correct >= 5;
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
                '${Grade1Math.number(_correct)} از ${Grade1Math.number(_items.length)} درست',
                style: AppFonts.vazirmatn(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              const NextTodayButton(justFinished: 'math'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _index = 0;
                    _correct = 0;
                    _streakOk = 0;
                    _streakBad = 0;
                    _level = 1;
                    _locked = false;
                    _finished = false;
                    _dealRound();
                    _options = _choices();
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
      ],
    );
  }
}
