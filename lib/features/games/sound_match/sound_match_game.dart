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
import '../../../core/learning_content/learning_topics.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
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
  /// (اموجی، نام فارسی) — نام فارسی حتماً لازم است: `AudioService.speak`
  /// اموجی‌ها را حذف می‌کند، پس اگر متنِ خوانده‌شده خودِ اموجی باشد بازی
  /// کاملاً بی‌صدا می‌شود و کودک چیزی برای شنیدن ندارد.
  static const List<(String, String)> _sounds = <(String, String)>[
    ('🐶', 'سگ'),
    ('🐱', 'گربه'),
    ('🐮', 'گاو'),
    ('🐔', 'مرغ'),
    ('🦆', 'اردک'),
    ('🐸', 'قورباغه'),
    ('🐴', 'اسب'),
    ('🐑', 'گوسفند'),
    ('🚗', 'ماشین'),
    ('🚌', 'اتوبوس'),
    ('✈️', 'هواپیما'),
    ('🚂', 'قطار'),
    ('⏰', 'ساعت'),
    ('📞', 'تلفن'),
    ('🚀', 'موشک'),
    ('⛵', 'قایق'),
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
      for (final entry in _sounds)
        LearningCard(
          id: entry.$1,
          name: entry.$2,
          emoji: entry.$1,
          sound: entry.$2,
        ),
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
      FandoghiCoach.incorrect('من گفتم «${_target.name}» 👂');
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
              Expanded(child: Text('بشنو و پیدا کن 🎧 — دور ${_round + 1}/۶', textAlign: TextAlign.center, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.soft),
                child: Text('$_correct/6 • $_score ⭐', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF6C5CE7))),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF00B894).withOpacity(0.9), borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Text('شنیداری', style: AppFonts.vazirmatn(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const FandoghiPremium(size: 56, mood: FandoghiMood.happy, showParticles: false),
        const SizedBox(height: 12),
        // دکمه پخش صدا پریمیوم با موج
        GestureDetector(
          onTap: _playSound,
          child: Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15))),
                const Icon(Icons.volume_up_rounded, color: Colors.white, size: 56),
                Positioned(
                  bottom: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (i) => Container(width: 3, height: 10 + (i % 2) * 6, margin: const EdgeInsets.symmetric(horizontal: 1.5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(2)))),
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.97, 0.97), end: const Offset(1.03, 1.03), duration: 900.ms, curve: Curves.easeInOut),
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
            Text('شنونده حرفه‌ای! 🎧✨', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, size: 32, color: i < stars ? const Color(0xFFFFD700) : Colors.white24).animate(delay: (i * 100).ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut))),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: Colors.white24)),
              child: Column(children: [Text('$_correct درست از ۶ — شنیداری قوی شد!', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)), Text('امتیاز: $_score', style: TextStyle(color: Colors.white70, fontSize: 13))]),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: PremiumButton(text: 'دور جدید 🔄', icon: Icons.replay_rounded, onPressed: () { HapticFeedback.mediumImpact(); setState(() { _round = 0; _score = 0; _correct = 0; _locked = false; _finished = false; _selected = null; _newRound(); }); })),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.home_rounded, size: 18, color: Colors.white), label: Text('برگشت به خانه', style: AppFonts.vazirmatn(color: Colors.white)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Colors.white54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))))),
          ],
        ),
      ),
    );
  }
}
