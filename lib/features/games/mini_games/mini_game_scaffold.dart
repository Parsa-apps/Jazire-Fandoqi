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
import '../../../core/growth/growth.dart';
import '../../../core/growth/persian_digits.dart';
import '../../../core/xp_system.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/premium/particle_celebration.dart';
import '../../../shared/widgets/premium_button.dart';
import 'mini_game_models.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎪 چارچوب مشترک بازی‌های تازه — نسخه ۷.۰.۰
///
/// ده بازی جدید روی همین موتور می‌خوابند تا:
///  - تجربهٔ یکسان و آشنای کودک (سؤال → بازخورد مثبت → دور بعد)
///  - Hint ظریف پس از ۱۰ ثانیه بی‌حرکتی (بدون خرابکردن بازی)
///  - «تلاش دوباره» به‌جای شکست: دور فقط با پاسخ درست جلو می‌رود
///  - ثبت مرکزی XP/مهارت/مأموریت/مدال از طریق GameData
///  - جشن ارتقای «سطح جزیره» در پایان
/// ═══════════════════════════════════════════════════════════════
class MiniGameScaffold extends StatefulWidget {
  final MiniGameSpec spec;

  /// سازندهٔ دورها؛ با هر «دور جدید» دوباره صدا زده می‌شود.
  final List<MiniGameRound> Function() roundFactory;

  final String? stageId;
  final int? stageNumber;

  const MiniGameScaffold({
    super.key,
    required this.spec,
    required this.roundFactory,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<MiniGameScaffold> createState() => _MiniGameScaffoldState();
}

class _MiniGameScaffoldState extends State<MiniGameScaffold>
    with SingleTickerProviderStateMixin {
  late List<MiniGameRound> _rounds;
  int _roundIndex = 0;
  int _score = 0;
  int _firstTryCorrect = 0;
  int _triesThisRound = 0;
  bool _finished = false;
  bool _transitioning = false;

  /// ایندکس گزینه‌ای که این دور درست جواب داده شده (برای سبزشدن).
  int? _solvedIndex;

  /// گزینه‌های اشتباهِ امتحان‌شده در این دور (تک‌انتخابی).
  final Set<int> _wrongTries = <int>{};

  /// انتخاب‌های فعلی در حالت چندانتخابی.
  final Set<int> _picked = <int>{};

  /// Hint ظریف: پس از این مدت بی‌حرکتی فعال می‌شود.
  Timer? _hintTimer;
  bool _hintActive = false;
  static const Duration _hintDelay = Duration(seconds: 10);

  late final AnimationController _pulseCtrl;

  /// سطح جزیره در شروع بازی — برای تشخیص ارتقا در پایان.
  int _levelAtStart = 1;

  @override
  void initState() {
    super.initState();
    _rounds = widget.roundFactory();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    FandoghiCoach.enablePersistentPresence();
    GameData.recordGamePlayed(widget.spec.gameId);
    ActivityTracker.recordOpen(
      route: '/game/${widget.spec.gameId}',
      title: widget.spec.gameId,
    );
    _levelAtStart = GameData.islandLevel;
    _armHint();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.instruction(widget.spec.introCoach);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _pulseCtrl.dispose();
    FandoghiCoach.clear();
    super.dispose();
  }

  void _armHint() {
    _hintTimer?.cancel();
    if (_hintActive) setState(() => _hintActive = false);
    _hintTimer = Timer(_hintDelay, () {
      if (!mounted || _finished || _transitioning || _solvedIndex != null) {
        return;
      }
      // Hint ظریف: فندقی راهنمایی می‌کند و پاسخ درست نرم می‌تپد.
      FandoghiCoach.say(round.hint);
      setState(() => _hintActive = true);
    });
  }

  MiniGameRound get round => _rounds[_roundIndex];

  // ── جریان تک‌انتخابی ────────────────────────────────────────
  void _onTapOption(int index) {
    if (_finished || _transitioning || _solvedIndex != null) return;
    if (_wrongTries.contains(index)) return;
    _hintTimer?.cancel();
    final option = round.options[index];
    GameData.recordAnswer(correct: option.correct, skill: widget.spec.skill);
    if (option.correct) {
      setState(() {
        _solvedIndex = index;
        _score += _triesThisRound == 0 ? 10 : (_triesThisRound == 1 ? 5 : 2);
        if (_triesThisRound == 0) _firstTryCorrect++;
      });
      unawaited(AudioService.playCorrect());
      HapticFeedback.mediumImpact();
      if (widget.spec.missionId != null) {
        GameData.progressMission(widget.spec.missionId!);
      }
      if (_triesThisRound == 0) {
        FandoghiCoach.correct(_praise());
      }
      _advanceAfterSolved();
    } else {
      setState(() {
        _wrongTries.add(index);
        _triesThisRound++;
      });
      unawaited(AudioService.playWrong());
      HapticFeedback.lightImpact();
      // لحن مثبت — بدون القای شکست و بدون لو دادن جواب:
      // «تقریباً! دوباره امتحان کنیم 😊»
      FandoghiCoach.say(
        _triesThisRound >= 2
            ? 'نزدیک شدی! با دقت نگاه کن؛ می‌توانی! 💪'
            : 'تقریباً! دوباره امتحان کنیم 😊',
        mood: FandoghiMood.thinking,
        tone: FandoghiCoachTone.encouragement,
        duration: const Duration(seconds: 2),
      );
      // پس از سه تلاش، پاسخ درست نرم روشن می‌شود (بدون شکست).
      if (_triesThisRound >= 3) {
        setState(() => _hintActive = true);
      }
      _armHint();
    }
  }

  String _praise() {
    const praises = <String>[
      'آفرین! دقیقاً همین بود! 🌟',
      'عالی بود! چه باهوش! 🎉',
      'درسته! فندقی ذوق کرد! 🐿️',
      'باریکلا قهرمان! 👏',
      'ایول! همین‌طور ادامه بده! ✨',
    ];
    return praises[DateTime.now().millisecondsSinceEpoch % praises.length];
  }

  void _advanceAfterSolved() {
    _transitioning = true;
    Future<void>.delayed(const Duration(milliseconds: 950), () {
      if (!mounted) return;
      setState(() => _transitioning = false);
      if (_roundIndex + 1 >= _rounds.length) {
        _finishGame();
      } else {
        setState(() {
          _roundIndex++;
          _triesThisRound = 0;
          _solvedIndex = null;
          _wrongTries.clear();
          _picked.clear();
        });
        _armHint();
      }
    });
  }

  // ── جریان چندانتخابی (طبقه‌بندی) ─────────────────────────────
  void _togglePick(int index) {
    if (_finished || _transitioning || _solvedIndex != null) return;
    _hintTimer?.cancel();
    setState(() {
      if (_picked.contains(index)) {
        _picked.remove(index);
      } else {
        _picked.add(index);
      }
    });
    unawaited(AudioService.tap());
    _armHint();
  }

  void _checkMultiSelect() {
    if (_finished || _transitioning || _solvedIndex != null || _picked.isEmpty) {
      return;
    }
    _hintTimer?.cancel();
    final correctSet = <int>{
      for (var i = 0; i < round.options.length; i++)
        if (round.options[i].correct) i,
    };
    final isPerfect = _picked.length == correctSet.length &&
        _picked.containsAll(correctSet);
    GameData.recordAnswer(correct: isPerfect, skill: widget.spec.skill);
    if (isPerfect) {
      setState(() {
        _solvedIndex = -1; // همهٔ درست‌ها سبز شوند
        _score += _triesThisRound == 0 ? 10 : (_triesThisRound == 1 ? 5 : 2);
        if (_triesThisRound == 0) _firstTryCorrect++;
      });
      unawaited(AudioService.playCorrect());
      HapticFeedback.mediumImpact();
      if (widget.spec.missionId != null) {
        GameData.progressMission(widget.spec.missionId!);
      }
      FandoghiCoach.correct('همه را درست گذاشتی! 🧺✨');
      _advanceAfterSolved();
    } else {
      setState(() => _triesThisRound++);
      unawaited(AudioService.playWrong());
      HapticFeedback.lightImpact();
      final missed = correctSet.difference(_picked).length;
      final extra = _picked.difference(correctSet).length;
      FandoghiCoach.say(
        'تقریباً! ${PersianDigits.toFa(missed)} تای جا مانده و '
        '${PersianDigits.toFa(extra)} تای اضافه است؛ دوباره امتحان کنیم 😊',
      );
      _armHint();
    }
  }

  // ── پایان بازی ──────────────────────────────────────────────
  void _finishGame() {
    setState(() => _finished = true);
    GameData.addCoins(_score);
    GameData.addStars(_firstTryCorrect);
    GameData.addXp(XpSystem.xpPerGameFinish);
    if (widget.stageId != null) {
      GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
    }
    final isWin = _firstTryCorrect >= (_rounds.length * 0.6).ceil();
    unawaited(isWin ? AudioService.win() : AudioService.lose());
    FandoghiCoach.reward(widget.spec.rewardCoach);
  }

  void _replay() {
    HapticFeedback.mediumImpact();
    setState(() {
      _rounds = widget.roundFactory();
      _roundIndex = 0;
      _score = 0;
      _firstTryCorrect = 0;
      _triesThisRound = 0;
      _solvedIndex = null;
      _finished = false;
      _transitioning = false;
      _wrongTries.clear();
      _picked.clear();
      _levelAtStart = GameData.islandLevel;
    });
    _armHint();
  }

  // ── UI ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: widget.spec.gradient),
        child: SafeArea(
          child: _finished ? _buildResult() : _buildGame(),
        ),
      ),
    );
  }

  Widget _buildGame() {
    final r = round;
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            r.prompt,
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildScene(r),
        const SizedBox(height: 14),
        Expanded(
          child: r.multiSelect
              ? _buildMultiSelectOptions(r)
              : _buildOptions(r),
        ),
        const SizedBox(height: 8),
        Text(
          'دور ${PersianDigits.toFa(_roundIndex + 1)} از ${PersianDigits.toFa(_rounds.length)}',
          style: AppFonts.vazirmatn(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          ChildTouchTarget(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: Colors.white30),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.spec.title,
              textAlign: TextAlign.center,
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              boxShadow: AppShadows.soft,
            ),
            child: Text(
              '✓ ${PersianDigits.toFa(_firstTryCorrect)}/${PersianDigits.toFa(_rounds.length)}',
              style: AppFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF6C5CE7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.9),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              '${PersianDigits.toFa(_score)} ⭐',
              style: AppFonts.vazirmatn(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScene(MiniGameRound r) {
    return KeyedSubtree(
      key: ValueKey('scene-$_roundIndex'),
      child: Container(
        constraints: const BoxConstraints(minHeight: 96, maxHeight: 170),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: Colors.white24),
        ),
        child: r.sceneIsText
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  r.scene,
                  style: AppFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: r.sceneFontSize,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  r.scene,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.sceneFontSize,
                    height: 1.15,
                  ),
                ),
              ),
      ),
    ).animate().fadeIn(duration: 260.ms).slideY(
          begin: 0.08,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildOptions(MiniGameRound r) {
    final isColorGame = r.options.every((o) => o.swatch != null);
    final maxLabelLength = r.options
        .map((o) => o.label.length)
        .reduce((a, b) => a > b ? a : b);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < r.options.length; i++)
              _optionCard(
                r,
                i,
                isColorGame: isColorGame,
                wide: maxLabelLength > 3,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectOptions(MiniGameRound r) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < r.options.length; i++)
                    _optionCard(r, i, isColorGame: false, wide: false),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: _picked.isEmpty
                  ? 'اول انتخاب کن! 👆'
                  : 'گذاشتم! ${PersianDigits.toFa(_picked.length)} تا 🧺',
              icon: Icons.check_circle_rounded,
              onPressed: _picked.isEmpty ? () {} : _checkMultiSelect,
            ),
          ),
        ),
      ],
    );
  }

  Widget _optionCard(
    MiniGameRound r,
    int i, {
    required bool isColorGame,
    required bool wide,
  }) {
    final option = r.options[i];
    final isWrongTry = _wrongTries.contains(i);
    final isSolved = _solvedIndex == i || (_solvedIndex == -1 && option.correct);
    final isPicked = _picked.contains(i);
    final showHintPulse = _hintActive && option.correct && _solvedIndex == null;

    Color bg = Colors.white.withOpacity(0.15);
    Color border = Colors.white30;
    if (isSolved) {
      bg = const Color(0xFF2ECC71);
      border = Colors.white;
    } else if (isWrongTry) {
      bg = const Color(0xFFE74C3C).withOpacity(0.75);
    } else if (isPicked) {
      bg = Colors.white.withOpacity(0.38);
      border = Colors.white;
    }

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: isColorGame ? 84 : (wide ? 220.0 : 104.0),
      height: isColorGame ? 84 : 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(isColorGame ? 999 : 20),
        border: Border.all(color: border, width: 1.6),
        boxShadow: isSolved ? AppShadows.soft : null,
      ),
      child: isColorGame
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: option.swatch,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            )
          : Text(
              option.label,
              textAlign: TextAlign.center,
              style: option.label.length <= 3
                  ? TextStyle(
                      fontSize: option.label.length == 1 ? 34 : 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    )
                  : AppFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
            ),
    );

    Widget interactive = ChildTouchTarget(
      onTap: r.multiSelect
          ? () => _togglePick(i)
          : (isWrongTry || isSolved ? null : () => _onTapOption(i)),
      minSize: 64,
      child: child,
    );

    if (showHintPulse) {
      // Hint ظریف: پاسخ درست نرم می‌تپد — بدون دادن جواب کلامی
      interactive = AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, _) {
          final t = 1 + _pulseCtrl.value * 0.07;
          return Transform.scale(scale: t, child: interactive);
        },
      );
    } else if (isSolved) {
      interactive = interactive
          .animate()
          .scale(end: const Offset(1.06, 1.06), duration: 240.ms)
          .then()
          .scale(end: const Offset(1, 1), duration: 180.ms);
    }

    return interactive;
  }

  Widget _buildResult() {
    final total = _rounds.length;
    final stars = _firstTryCorrect == total
        ? 3
        : _firstTryCorrect >= total * 0.7
            ? 2
            : _firstTryCorrect >= total * 0.4
                ? 1
                : 0;
    final isWin = _firstTryCorrect >= (total * 0.6).ceil();
    final leveledUp = GameData.islandLevel > _levelAtStart;
    return ConfettiOverlay(
      isActive: isWin,
      onComplete: () {},
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FandoghiPremium(
                size: 96,
                mood: isWin ? FandoghiMood.celebrating : FandoghiMood.shy,
                showParticles: isWin,
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),
              Text(
                widget.spec.title,
                style: AppFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                      i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 32,
                      color: i < stars ? const Color(0xFFFFD700) : Colors.white24,
                    )
                        .animate(delay: (i * 100).ms)
                        .scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1, 1),
                          duration: 400.ms,
                          curve: Curves.elasticOut,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    Text(
                      '${PersianDigits.toFa(_firstTryCorrect)} درست از ${PersianDigits.toFa(total)}',
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'امتیاز: ${PersianDigits.toFa(_score)} — تجربه: +${PersianDigits.toFa(XpSystem.xpPerGameFinish)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (leveledUp) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.22),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        'سطح جزیره اتقا پیدا کرد! ${XpSystem.levelLabel(GameData.islandLevel)}',
                        style: AppFonts.vazirmatn(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PremiumButton(
                  text: 'دور جدید 🔄',
                  icon: Icons.replay_rounded,
                  onPressed: _replay,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home_rounded, size: 18, color: Colors.white),
                  label: Text(
                    'برگشت به خانه',
                    style: AppFonts.vazirmatn(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
