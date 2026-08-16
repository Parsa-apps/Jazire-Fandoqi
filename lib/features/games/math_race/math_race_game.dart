import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/child_touch_target.dart';

import '../../../app/app_colors.dart';
import '../../../app/design_tokens.dart';
import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../core/math/grade1_math.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/next_today_button.dart';
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
      final problem = Grade1Math.nextAddOrSubtract(rng);
      _questions.add(problem);
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
    // قبولی مرحله فقط با حداقل ۷ پاسخ درست — معلم کلاس اول بی‌دلیل مهر نمی‌زند.
    if (widget.stageId != null && _correct >= 7) {
      GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
    }
    if (_correct >= 7) {
      unawaited(AudioService.win());
    } else {
      unawaited(AudioService.lose());
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
        // 🏁 پیست پریمیوم — شطرنجی + سایه + ذرات سرعت (بهبود پریمیوم)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ریل
                Positioned(
                  left: 0,
                  right: 0,
                  top: 22,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.15)]),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: List.generate(20, (i) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 1), height: 4, decoration: BoxDecoration(color: i % 2 == 0 ? Colors.white.withOpacity(0.5) : Colors.transparent, borderRadius: BorderRadius.circular(2))))),
                    ),
                  ),
                ),
                // پرچم شطرنجی
                Positioned(
                  right: -4,
                  top: 0,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          children: List.generate(4, (i) => Container(width: 6, height: 6, color: i % 2 == 0 ? Colors.black : Colors.white)),
                        ),
                      ),
                      const Text('🏁', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
                // ماشین با ذرات
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  left: (MediaQuery.of(context).size.width - 72) * _progress / 100,
                  top: 0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (_progress > 0 && _progress < 100)
                        Positioned(
                          left: -10,
                          top: 12,
                          child: Row(
                            children: List.generate(3, (i) => Container(width: 4, height: 4, margin: const EdgeInsets.only(right: 2), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.6 - i * 0.15)))
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: (400 + i * 100).ms)
                                .fade(begin: 0.3, end: 0.8, duration: (400 + i * 100).ms)),
                          ),
                        ),
                      Text('🏎️', style: TextStyle(fontSize: 30, shadows: [Shadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 8)]))
                          .animate(target: _progress > 0 ? 1 : 0)
                          .shake(hz: 6, curve: Curves.easeInOut, duration: 300.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 34),
        Text(
          Grade1Math.equation(q.$1, q.$3 == '+' ? '+' : '−', q.$2),
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
                    Grade1Math.number(option),
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
          'سوال ${Grade1Math.number(_index + 1)} از ${Grade1Math.number(_questionCount)}',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResult() {
    final isWin = _correct >= 7;
    final stars = _correct == _questionCount ? 3 : _correct >= 8 ? 2 : isWin ? 1 : 0;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FandoghiPremium(
              size: 100,
              mood: isWin ? FandoghiMood.celebrating : FandoghiMood.shy,
              showParticles: isWin,
              message: isWin ? 'چه راننده سریعی! 🏆' : 'تلاش خوبی بود! 💪',
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text('مسابقه تمام شد! 🏁', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, size: 36, color: i < stars ? const Color(0xFFFFD700) : Colors.white24)
                    .animate(delay: (i * 120).ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut),
              )),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: Colors.white24)),
              child: Column(
                children: [
                  Text('$_correct درست از $_questionCount سوال', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadii.pill)), child: Row(children: [const Text('🪙', style: TextStyle(fontSize: 14)), const SizedBox(width: 4), Text('+${_correct * 2}', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFFFFD700)))])),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadii.pill)), child: Row(children: [const Icon(Icons.star_rounded, size: 14, color: Colors.white), const SizedBox(width: 4), Text('+${_correct ~/ 2}', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white))])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const NextTodayButton(justFinished: 'math'),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: PremiumButton(text: 'مسابقه دوباره 🔄', icon: Icons.replay_rounded, onPressed: () { HapticFeedback.mediumImpact(); _restart(); }),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home_rounded, size: 18, color: Colors.white),
                label: Text('برگشت به خانه', style: AppFonts.vazirmatn(color: Colors.white, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Colors.white54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))),
              ),
            ),
            const SizedBox(height: 8),
            Text('🏎️ هر جواب درست = ۱۰٪ پیشرفت + ذرات سرعت!', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
