import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_colors.dart';
import '../../../app/design_tokens.dart';
import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
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
  late String _correctNext;
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
        if (_correct >= 4) {
          unawaited(AudioService.win());
        } else {
          unawaited(AudioService.lose());
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
  /// ⚠️ بدون initializer: ساخت در initState بعد از _newPattern
  late List<String> _roundOptions;

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
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              ChildTouchTarget(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white30)),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('الگویاب 🧠 — دور ${_round + 1}/۶', textAlign: TextAlign.center, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.soft),
                child: Text('$_correct/6', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF6C5CE7))),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.9), borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Text('$_score ⭐', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
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
    final stars = _correct == 6 ? 3 : _correct >= 4 ? 2 : _correct >= 2 ? 1 : 0;
    final isWin = _correct >= 4;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FandoghiPremium(size: 96, mood: isWin ? FandoghiMood.celebrating : FandoghiMood.shy, showParticles: isWin).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text('کارآگاه الگو! 🕵️', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, size: 32, color: i < stars ? const Color(0xFFFFD700) : Colors.white24).animate(delay: (i * 100).ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut))),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: Colors.white24)),
              child: Column(
                children: [
                  Text('$_correct درست از ۶ الگو', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('امتیاز: $_score', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: PremiumButton(text: 'دور جدید 🔄', icon: Icons.replay_rounded, onPressed: () { HapticFeedback.mediumImpact(); setState(() { _round = 0; _score = 0; _correct = 0; _locked = false; _finished = false; _selected = null; _newPattern(); _roundOptions = _buildOptions(); }); })),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.home_rounded, size: 18, color: Colors.white), label: Text('برگشت به خانه', style: AppFonts.vazirmatn(color: Colors.white)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Colors.white54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))))),
          ],
        ),
      ),
    );
  }
}
