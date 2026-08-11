import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_colors.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/learning_content/learning_topics.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_v2.dart';
import '../../../shared/widgets/particle_celebration.dart';
import '../../../shared/widgets/premium_button.dart';

/// ────────────────────────────────────────────────────────────
/// 🎓 فاز ۲۲-۲۸: موتور بازی آکادمی (مشترک برای همه موضوعات)
///
/// دو حالت بازی هر دور عوض می‌شود:
/// - «بشنو و پیدا کن»: فندقی اسم را می‌گوید، کودک کارت درست را می‌زند
/// - «این چیه؟»: کارت نشان داده می‌شود، کودک اسم درست را انتخاب می‌کند
/// همه کارت‌ها ≥ 64px، بازخورد صوتی + لرزشی، تشویق بدون سرزنش.
/// ────────────────────────────────────────────────────────────
class AcademyGame extends StatefulWidget {
  final String topicId;
  final String? stageId;
  final int? stageNumber;

  const AcademyGame({
    super.key,
    required this.topicId,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<AcademyGame> createState() => _AcademyGameState();
}

class _AcademyGameState extends State<AcademyGame> {
  late final LearningTopic _topic;
  late List<LearningCard> _roundCards;
  int _roundIndex = 0;
  int _score = 0;
  int _correct = 0;
  bool _locked = false;
  bool _finished = false;
  int? _selectedIndex;
  bool _wasCorrect = false;

  @override
  void initState() {
    super.initState();
    _topic = learningTopicById(widget.topicId) ?? learningTopics.first;
    _roundCards = _topic.pickRandom(5);
    _roundOptions = _buildOptions();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameData.isDailyLimitReached) {
        FandoghiCoach.judge('زمان بازی امروز تمام شده؛ فردا ادامه می‌دهیم ⏰');
        return;
      }
      FandoghiCoach.instruction(
        'به آکادمی ${_topic.title} خوش آمدی! اول فندقی می‌گوید و تو پیدا می‌کنی؛ بعد برعکس! 🎮',
      );
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (mounted) _speakCurrent();
      });
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    FandoghiCoach.cancelSmartHint();
    super.dispose();
  }

  bool get _listenMode => _roundIndex.isEven;

  LearningCard get _currentCard => _roundCards[_roundIndex];

  /// گزینه‌های دور جاری — یک‌بار ساخته می‌شوند تا نمایش، پاسخ و
  /// هایلایت درست/غلط همیشه روی یک لیست باشند (رفع شافل مجدد).
  /// ⚠️ بدون initializer: ساخت در initState بعد از آماده‌شدن _roundCards
  late List<LearningCard> _roundOptions;

  List<LearningCard> _buildOptions() {
    // گزینه‌های جواب: کارت درست + ۲ کارت تصادفی دیگر
    final others = _topic.cards
        .where((c) => c.id != _currentCard.id)
        .toList()
      ..shuffle(Random());
    return <LearningCard>[_currentCard, others[0], others[1]]
      ..shuffle(Random());
  }

  void _speakCurrent() {
    unawaited(AudioService.tap());

    // آکادمی اعداد فایل صوتی آفلاین اختصاصی دارد. استفاده از TTS در اینجا
    // باعث می‌شد روی گوشی‌هایی که موتور فارسی ندارند، دکمهٔ بلندگو کاملاً
    // بی‌صدا باشد. شناسه‌های این موضوع به‌شکل n1 تا n20 هستند.
    if (_topic.id == 'numbers') {
      final number = int.tryParse(_currentCard.id.substring(1));
      if (number != null) {
        unawaited(AudioService.speakNumber(number));
        return;
      }
    }

    // موضوع‌های بدون صدای ضبط‌شده همچنان از TTS دستگاه استفاده می‌کنند.
    unawaited(AudioService.speak(_currentCard.sound));
  }

  void _answer(int optionIndex, List<LearningCard> options) {
    if (_locked || _finished) return;
    if (!canStartPlay(context)) return;
    FandoghiCoach.cancelSmartHint();
    AudioService.tap();
    final correct = options[optionIndex].id == _currentCard.id;
    setState(() {
      _locked = true;
      _selectedIndex = optionIndex;
      _wasCorrect = correct;
      if (correct) {
        _correct++;
        _score += 10;
      }
    });

    GameData.recordAnswer(correct: correct, skill: _topic.skill);
    if (_topic.id == 'colors') GameData.progressMission('colors');

    if (correct) {
      HapticFeedback.lightImpact();
      FandoghiCoach.correct('آفرین! ${_currentCard.emoji} ${_currentCard.name}');
      if (_currentCard.fact != null) {
        Future<void>.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          FandoghiCoach.say(
            'می‌دانستی؟ ${_currentCard.fact} 🌟',
            mood: FandoghiMood.proud,
          );
        });
      }
      unawaited(AudioService.playCorrect());
    } else {
      FandoghiCoach.incorrect(options[optionIndex].name);
      unawaited(AudioService.playWrong());
    }

    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_roundIndex + 1 >= _roundCards.length) {
        _finish();
      } else {
        setState(() {
          _roundIndex++;
          _roundOptions = _buildOptions();
          _selectedIndex = null;
          _locked = false;
        });
        Future<void>.delayed(const Duration(milliseconds: 300), _speakCurrent);
      }
    });
  }

  void _finish() {
    if (_finished) return;
    setState(() => _finished = true);
    GameData.addCoins(_score);
    GameData.addStars(_correct);
    GameData.progressMission('questions');
    if (widget.stageId != null) {
      GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
    }
    FandoghiCoach.reward(
      'آکادمی ${_topic.title} را تمام کردی! فندقی به تو افتخار می‌کند 🏆',
    );
    unawaited(AudioService.playWin());
  }

  void _restart() {
    setState(() {
      _roundCards = _topic.pickRandom(5);
      _roundIndex = 0;
      _roundOptions = _buildOptions();
      _score = 0;
      _correct = 0;
      _locked = false;
      _finished = false;
      _selectedIndex = null;
    });
    FandoghiCoach.instruction('دور جدید! آماده‌ای؟ 🚀');
    Future<void>.delayed(const Duration(milliseconds: 700), _speakCurrent);
  }

  @override
  Widget build(BuildContext context) {
    final content = _finished ? _buildResult() : _buildGame();
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(child: content),
      ),
    );
  }

  Widget _buildGame() {
    final options = _roundOptions;
    final card = _currentCard;
    return Column(
      children: [
        // Header
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
              Expanded(
                child: Text(
                  'آکادمی ${_topic.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: LinearProgressIndicator(
            value: (_roundIndex + 1) / _roundCards.length,
            backgroundColor: Colors.white24,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 20),
        // Round title
        Text(
          _listenMode ? '🔊 بشنو و پیدا کن' : '🤔 این چیه؟',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'دور ${_roundIndex + 1} از ${_roundCards.length}',
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 24),
        // Prompt: listen mode shows speaker; name mode shows the card
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_listenMode)
                ChildTouchTarget(
                  onTap: _speakCurrent,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up_rounded,
                        color: Colors.white, size: 64),
                  ),
                )
              else ...[
                Text(card.emoji, style: const TextStyle(fontSize: 90)),
                const SizedBox(height: 14),
                FandoghiV2(size: 76, mood: FandoghiMood.thinking),
              ],
              const SizedBox(height: 20),
              // Options
              for (var i = 0; i < options.length; i++) ...[
                _optionButton(i, options),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _optionButton(int index, List<LearningCard> options) {
    final card = options[index];
    final selected = _locked && _selectedIndex == index;
    final Color bg;
    if (selected) {
      bg = _wasCorrect ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
    } else {
      bg = Colors.white.withOpacity(0.14);
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _locked ? null : () => _answer(index, options),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(selected ? 1 : 0.25),
                width: selected ? 2.5 : 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(card.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Text(
                  _listenMode ? card.emoji + ' ' + card.name : card.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final percent = _roundCards.isEmpty ? 0 : (_correct / _roundCards.length);
    return Stack(
      children: [
        // فاز ۶۰: جشن ذرات برای هر برد
        if (percent >= 0.6)
          const ParticleCelebration(
            trigger: true,
            particleCount: 40,
          ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  percent >= 0.6 ? '🏆' : '💪',
                  style: const TextStyle(fontSize: 80),
                ).animate().scale(begin: const Offset(0.4, 0.4), curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text(
                  percent >= 0.6 ? 'آفرین قهرمان!' : 'تمرین خوبی بود!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$_correct درست از ${_roundCards.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text(
                  '+$_score سکه و $_correct ستاره 🎉',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 30),
                PremiumButton(
                  text: 'بازی دوباره 🔄',
                  icon: Icons.replay_rounded,
                  onPressed: _restart,
                ),
                const SizedBox(height: 12),
                PremiumButton(
                  text: 'برگشت به خانه 🏠',
                  icon: Icons.home_rounded,
                  color: const Color(0xFF5C6BC0),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
