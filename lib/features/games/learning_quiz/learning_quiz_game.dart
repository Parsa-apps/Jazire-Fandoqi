import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import '../../../core/ai_system.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/learning_content/learning_topics.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/fandoghi_v2.dart';
import '../../../shared/widgets/illustration_tile.dart';

/// A small, reusable quiz engine for all learning-map topics.
///
/// It deliberately uses local content and deterministic state. That keeps the
/// game playable offline and makes every map destination honest: alphabet,
/// numbers, colours and the world topics no longer fall through to an unrelated
/// game.
class LearningQuizGame extends StatefulWidget {
  final String topic;
  final String? stageId;
  final int? stageNumber;

  const LearningQuizGame({
    super.key,
    required this.topic,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<LearningQuizGame> createState() => _LearningQuizGameState();
}

class _LearningQuizGameState extends State<LearningQuizGame> {
  late final List<_QuizQuestion> _questions;
  int _questionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _consecutiveWrong = 0; // فاز ۴۵
  int? _selectedOption;
  bool _answerLocked = false;
  bool _finished = false;
  int _roundToken = 0;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    _questions = _questionsFor(widget.topic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (GameData.isDailyLimitReached) {
          FandoghiCoach.judge('زمان بازی امروز تمام شده؛ فردا دوباره با هم ادامه می‌دهیم ⏰');
        } else {
          FandoghiCoach.instruction(
            'من داور این مسابقه‌ام! گزینه‌ای را انتخاب کن؛ بعد با هم جواب را بررسی می‌کنیم 🌰',
          );
          // فاز ۱۹: راهنمای هوشمند برای سوال اول
          Future<void>.delayed(const Duration(milliseconds: 600), () {
            if (mounted) _armNextHint();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _roundToken++;
    FandoghiCoach.clear();
    super.dispose();
  }

  void _answer(int optionIndex) {
    if (_answerLocked || _finished) return;
    if (!canStartPlay(context)) return;
    final question = _questions[_questionIndex];
    final correct = optionIndex == question.correctIndex;
    final token = _roundToken;

    // فاز ۱۹: فعالیت کودک، راهنمای بی‌حرکتی را لغو می‌کند
    FandoghiCoach.cancelSmartHint();

    HapticFeedback.lightImpact();
    setState(() {
      _answerLocked = true;
      _selectedOption = optionIndex;
      if (correct) {
        _correctAnswers++;
        _score += 20;
      }
    });

    GameData.recordAnswer(correct: correct, skill: question.skill);
    if (question.missionId != null) {
      GameData.progressMission(question.missionId!);
    }
    if (correct) {
      _consecutiveWrong = 0;
      FandoghiCoach.correct('آفرین! «${question.options[optionIndex]}» جواب درست بود 🌟');
      HapticFeedback.mediumImpact();
      // فاز ۶: تشویق صوتی هم‌زمان با حباب فندقی
      unawaited(AudioService.playCorrect());
    } else {
      _consecutiveWrong++;
      // فاز ۴۵: اگر پشت سر هم غلط زد، همدلی + پیشنهاد بازی آسون‌تر
      final empathyMessage = AI.encouragementAfterMistakes(_consecutiveWrong);
      FandoghiCoach.say(
        empathyMessage.isEmpty
            ? 'جواب درست «${question.options[question.correctIndex]}» بود'
            : '$empathyMessage جواب درست «${question.options[question.correctIndex]}» بود',
        mood: FandoghiMood.shy,
        tone: FandoghiCoachTone.encouragement,
        duration: const Duration(seconds: 4),
      );
      unawaited(AudioService.playWrong());
    }

    Future<void>.delayed(const Duration(milliseconds: 850), () {
      if (!mounted || token != _roundToken || _finished) return;
      if (_questionIndex + 1 >= _questions.length) {
        _finish();
      } else {
        setState(() {
          _questionIndex++;
          _selectedOption = null;
          _answerLocked = false;
        });
        _armNextHint();
      }
    });
  }

  /// فاز ۱۹: اگر کودک ۳ ثانیه جواب ندهد، فندقی ملایم راهنمایی می‌کند.
  void _armNextHint() {
    final question = _questions[_questionIndex];
    FandoghiCoach.armSmartHint(
      onHint: () {
        if (!mounted || _finished || _answerLocked) return;
        FandoghiCoach.instruction(
          'می‌تونی جواب رو با لمس انتخاب کنی؛ هر کدوم که فکر می‌کنی درسته بزن 🌟',
        );
      },
    );
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    final completed = _correctAnswers >= (_questions.length * 0.6).ceil();
    final finalScore = _score + (_correctAnswers * 5);
    _score = finalScore;

    GameData.addCoins(finalScore ~/ 2);
    GameData.addStars(_correctAnswers);
    GameData.updateHighScore(finalScore, 'quiz');
    if (completed && widget.stageId != null) {
      GameData.completeStage(
        widget.stageId!,
        stageNumber: widget.stageNumber,
      );
    }
    FandoghiCoach.reward(
      completed
          ? 'مسابقه را عالی انجام دادی! من بهت افتخار می‌کنم؛ مرحله هم باز شد 🏆'
          : 'تلاش خوبی بود! با یک تمرین دیگر می‌توانی مرحله را باز کنی 💪',
    );
    setState(() {});
  }

  void _restart() {
    if (!canStartPlay(context)) return;
    FandoghiCoach.instruction('دوباره شروع کنیم! این بار فندقی هم حواسش به جواب‌ها هست 🌰');
    _roundToken++;
    setState(() {
      _questionIndex = 0;
      _score = 0;
      _correctAnswers = 0;
      _consecutiveWrong = 0;
      _selectedOption = null;
      _answerLocked = false;
      _finished = false;
    });
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _armNextHint();
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = _finished
        ? _buildResult()
        : GameData.isDailyLimitReached
            ? _buildLimitReached()
            : _buildGame();
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(child: content),
      ),
    );
  }

  Widget _buildLimitReached() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⏰', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              'زمان بازی امروز تمام شده',
              textAlign: TextAlign.center,
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'فردا دوباره ادامه می‌دهیم! 🌟',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('برگشت'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    final question = _questions[_questionIndex];
    return Column(
      children: [
        _topBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'سوال ${_questionIndex + 1} از ${_questions.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'امتیاز $_score',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: (_questionIndex + 1) / _questions.length,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _questionCard(question),
                const SizedBox(height: 24),
                ...question.options.asMap().entries.map(
                  (entry) => _optionButton(question, entry.key, entry.value),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _roundButton(
            Icons.arrow_back_rounded,
            () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            '${_topicTitle(widget.topic)} ${_topicEmoji(widget.topic)}',
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: 'بازگشت',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  Widget _questionCard(_QuizQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        children: [
          if (question.imageAsset != null && question.imageIndex != null)
            SizedBox(
              width: 150,
              height: 150,
              child: IllustrationTile(
                asset: question.imageAsset!,
                index: question.imageIndex!,
                semanticLabel: question.visualLabel,
                borderRadius: BorderRadius.circular(22),
              ),
            )
          else
            Text(question.emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 18),
          Text(
            question.prompt,
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionButton(_QuizQuestion question, int index, String option) {
    final selected = _selectedOption == index;
    final isCorrect = question.correctIndex == index;
    final showResult = _answerLocked;
    final color = showResult && isCorrect
        ? AppColors.success
        : showResult && selected
            ? AppColors.danger
            : Colors.white.withOpacity(0.08);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: option,
        enabled: !_answerLocked,
        child: InkWell(
          onTap: _answerLocked ? null : () => _answer(index),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: showResult && (isCorrect || selected)
                    ? color
                    : Colors.white.withOpacity(0.12),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  child: Text(
                    String.fromCharCode(0x06F0 + index),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (showResult && isCorrect)
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                if (showResult && selected && !isCorrect)
                  const Icon(Icons.cancel_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final passed = _correctAnswers >= (_questions.length * 0.6).ceil();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FandoghiV2(
              size: 100,
              animate: true,
              mood: FandoghiMood.excited,
            ),
            const SizedBox(height: 18),
            Text(
              passed ? 'عالی بود! 🏆' : 'تلاش خیلی خوبی بود! 💪',
              textAlign: TextAlign.center,
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_correctAnswers از ${_questions.length} پاسخ درست\nامتیاز نهایی: $_score',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 28),
            if (widget.stageId != null && passed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'مرحله باز شد! ⭐',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _restart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('دوباره بازی کن 🔄'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: const Text('برگشت'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// فاز ۳۰: تولید هوشمند سوال از روی ضعیف‌ترین مهارت کودک
  /// (با استفاده از محتوای آکادمی — نه بانک ثابت)
  List<_QuizQuestion> _generateSmartQuestions() {
    final weakSkillKey = AI.weakSkillKey();
    final topic = learningTopics.firstWhere(
      (t) => t.skill == weakSkillKey,
      orElse: () => learningTopics.first,
    );
    final questions = <_QuizQuestion>[];
    final cards = topic.pickRandom(5);
    for (final card in cards) {
      // «کدام گزینه X است؟» با ایموجی
      final others = topic.cards
          .where((c) => c.id != card.id)
          .take(3)
          .map((c) => c.name)
          .toList();
      final options = <String>[...others, card.name]..shuffle();
      questions.add(_QuizQuestion(
        'کدام یکی «${card.name}» است؟',
        card.emoji,
        options,
        options.indexOf(card.name),
        topic.skill,
        topic.skill,
      ));
    }
    if (questions.isEmpty) {
      questions.add(const _QuizQuestion(
        'کدام یکی «یک» است؟',
        '1️⃣',
        ['دو', 'یک', 'سه'],
        1,
        'counting',
        null,
      ));
    }
    return questions;
  }

  List<_QuizQuestion> _questionsFor(String rawTopic) {
    final topic = rawTopic.trim().toLowerCase();
    // فاز ۳۰: کوییز هوشمند بر اساس مهارت ضعیف
    if (topic.contains('هوشمند') || topic.contains('smart')) {
      return _generateSmartQuestions();
    }
    if (topic.contains('الفبا') || topic.contains('alphabet')) {
      return const [
        _QuizQuestion('کلمه «بابا» با چه حرفی شروع می‌شود؟', '🔤', ['ب', 'م', 'س', 'ر'], 0, 'alphabet', 'alphabet'),
        _QuizQuestion('بعد از «ب» کدام حرف می‌آید؟', '📚', ['پ', 'ا', 'ت', 'ج'], 0, 'alphabet', 'alphabet'),
        _QuizQuestion('کدام کلمه با «م» شروع می‌شود؟', '🐟', ['سیب', 'ماه', 'باد', 'رود'], 1, 'alphabet', 'alphabet'),
        _QuizQuestion('حرف اول «آب» چیست؟', '💧', ['آ', 'ب', 'د', 'ا'], 0, 'alphabet', 'alphabet'),
        _QuizQuestion('کدام گزینه یک حرف است؟', '✨', ['کتاب', 'ش', 'مداد', 'خانه'], 1, 'alphabet', 'alphabet'),
      ];
    }
    if (topic.contains('عدد') || topic.contains('اعداد') || topic.contains('شمار') || topic.contains('number')) {
      return const [
        _QuizQuestion('🍎🍎🍎 چند سیب می‌بینی؟', '🔢', ['۲', '۳', '۴', '۵'], 1, 'counting', null),
        _QuizQuestion('عدد بعد از ۴ چیست؟', '4️⃣', ['۳', '۵', '۶', '۷'], 1, 'math', null),
        _QuizQuestion('کدام عدد کوچک‌تر است؟', '🐞', ['۸', '۲', '۶', '۹'], 1, 'math', null),
        _QuizQuestion('۲ + ۳ چند می‌شود؟', '➕', ['۴', '۵', '۶', '۷'], 1, 'math', null),
        _QuizQuestion('کدام گزینه پنج تاست؟', '🖐️', ['۳', '۴', '۵', '۶'], 2, 'counting', null),
      ];
    }
    if (topic.contains('رنگ') || topic.contains('color')) {
      return const [
        _QuizQuestion(
          'کدام چیز آبی است؟',
          '🎈',
          ['آبی', 'سبز', 'قرمز', 'زرد'],
          0,
          'colors',
          'colors',
          imageAsset: 'assets/illustrations/colors_cards.webp',
          imageIndex: 1,
          visualLabel: 'بادکنک آبی',
        ),
        _QuizQuestion(
          'کدام چیز سبز است؟',
          '🌿',
          ['سبز', 'زرد', 'صورتی', 'نارنجی'],
          0,
          'colors',
          'colors',
          imageAsset: 'assets/illustrations/colors_cards.webp',
          imageIndex: 2,
          visualLabel: 'برگ سبز',
        ),
        _QuizQuestion(
          'خورشید را کدام رنگ نشان می‌دهد؟',
          '☀️',
          ['سیاه', 'زرد', 'آبی', 'بنفش'],
          1,
          'colors',
          'colors',
          imageAsset: 'assets/illustrations/colors_cards.webp',
          imageIndex: 3,
          visualLabel: 'خورشید زرد',
        ),
        _QuizQuestion(
          'کدام گل بنفش است؟',
          '🌸',
          ['بنفش', 'زرد', 'آبی', 'قرمز'],
          0,
          'colors',
          'colors',
          imageAsset: 'assets/illustrations/colors_cards.webp',
          imageIndex: 4,
          visualLabel: 'گل بنفش',
        ),
        _QuizQuestion(
          'کدام چیز نارنجی است؟',
          '🎃',
          ['آبی', 'نارنجی', 'سبز', 'سفید'],
          1,
          'colors',
          'colors',
          imageAsset: 'assets/illustrations/colors_cards.webp',
          imageIndex: 5,
          visualLabel: 'کدو تنبل نارنجی',
        ),
      ];
    }
    if (topic.contains('حیوان') || topic.contains('animal')) {
      return const [
        _QuizQuestion(
          'کدام حیوان می‌گوید «میو»؟',
          '🐾',
          ['سگ', 'گربه', 'گاو', 'مرغ'],
          1,
          'animals',
          null,
          imageAsset: 'assets/illustrations/animals_cards.webp',
          imageIndex: 5,
          visualLabel: 'گربه کارتونی',
        ),
        _QuizQuestion(
          'کدام حیوان یال دارد؟',
          '🦁',
          ['شیر', 'گربه', 'ماهی', 'زنبور'],
          0,
          'animals',
          null,
          imageAsset: 'assets/illustrations/animals_cards.webp',
          imageIndex: 0,
          visualLabel: 'شیر کارتونی',
        ),
        _QuizQuestion(
          'بزرگ‌ترین حیوان خشکی کدام است؟',
          '🐘',
          ['فیل', 'گربه', 'موش', 'پروانه'],
          0,
          'animals',
          null,
          imageAsset: 'assets/illustrations/animals_cards.webp',
          imageIndex: 1,
          visualLabel: 'فیل کارتونی',
        ),
        _QuizQuestion(
          'کدام حیوان بامبو دوست دارد؟',
          '🐼',
          ['پاندا', 'شیر', 'ماهی', 'زنبور'],
          0,
          'animals',
          null,
          imageAsset: 'assets/illustrations/animals_cards.webp',
          imageIndex: 3,
          visualLabel: 'پاندا کارتونی',
        ),
        _QuizQuestion(
          'کدام حیوان دم پف‌دار دارد؟',
          '🦊',
          ['روباه', 'فیل', 'ماهی', 'مرغ'],
          0,
          'animals',
          null,
          imageAsset: 'assets/illustrations/animals_cards.webp',
          imageIndex: 4,
          visualLabel: 'روباه کارتونی',
        ),
      ];
    }
    if (topic.contains('احساس') || topic.contains('emotion')) {
      return const [
        _QuizQuestion('وقتی هدیه می‌گیریم، معمولاً چه حسی داریم؟', '🎁', ['خوشحالی', 'خواب‌آلودگی', 'تشنگی', 'سرما'], 0, 'emotions', null),
        _QuizQuestion('لبخند بیشتر نشانه کدام احساس است؟', '😊', ['ترس', 'شادی', 'خستگی', 'گرسنگی'], 1, 'emotions', null),
        _QuizQuestion('وقتی ناراحتیم، چه کاری کمک می‌کند؟', '💛', ['صحبت با بزرگ‌تر', 'پنهان شدن', 'داد زدن', 'آسیب زدن'], 0, 'emotions', null),
        _QuizQuestion('همدلی یعنی چه؟', '🤝', ['درک احساس دیگران', 'دویدن سریع', 'رنگ‌آمیزی', 'خوابیدن'], 0, 'emotions', null),
        _QuizQuestion('برای آرام شدن می‌توانیم چه کنیم؟', '🌬️', ['نفس عمیق', 'هل دادن دوست', 'فریاد زدن', 'پرتاب کردن'], 0, 'emotions', null),
      ];
    }
    if (topic.contains('شغل') || topic.contains('job')) {
      return const [
        _QuizQuestion(
          'پزشک به چه کسی کمک می‌کند؟',
          '🩺',
          ['بیمار', 'درخت', 'ماشین', 'کتاب'],
          0,
          'jobs',
          null,
          imageAsset: 'assets/illustrations/jobs_cards.webp',
          imageIndex: 0,
          visualLabel: 'پزشک کارتونی',
        ),
        _QuizQuestion(
          'آتش‌نشان چه کاری انجام می‌دهد؟',
          '🚒',
          ['خاموش کردن آتش', 'پختن نان', 'دوختن لباس', 'ساختن کفش'],
          0,
          'jobs',
          null,
          imageAsset: 'assets/illustrations/jobs_cards.webp',
          imageIndex: 1,
          visualLabel: 'آتش‌نشان کارتونی',
        ),
        _QuizQuestion(
          'معلم کجا درس می‌دهد؟',
          '🏫',
          ['مدرسه', 'فرودگاه', 'باغ‌وحش', 'آشپزخانه'],
          0,
          'jobs',
          null,
          imageAsset: 'assets/illustrations/jobs_cards.webp',
          imageIndex: 2,
          visualLabel: 'معلم کارتونی',
        ),
        _QuizQuestion(
          'کشاورز با چه چیزی کار می‌کند؟',
          '🌾',
          ['زمین و گیاه', 'ستاره‌ها', 'کتابخانه', 'رودخانه'],
          0,
          'jobs',
          null,
          imageAsset: 'assets/illustrations/jobs_cards.webp',
          imageIndex: 3,
          visualLabel: 'کشاورز کارتونی',
        ),
        _QuizQuestion(
          'خلبان چه چیزی را هدایت می‌کند؟',
          '✈️',
          ['هواپیما', 'دوچرخه', 'قایق کاغذی', 'قطار اسباب‌بازی'],
          0,
          'jobs',
          null,
          imageAsset: 'assets/illustrations/jobs_cards.webp',
          imageIndex: 4,
          visualLabel: 'خلبان کارتونی',
        ),
      ];
    }
    if (topic.contains('شکل') || topic.contains('shape')) {
      return const [
        _QuizQuestion(
          'کدام شکل گرد است؟',
          '⭕',
          ['دایره', 'مربع', 'مثلث', 'مستطیل'],
          0,
          'shapes',
          null,
          imageAsset: 'assets/illustrations/shapes_cards.webp',
          imageIndex: 0,
          visualLabel: 'دایره',
        ),
        _QuizQuestion(
          'کدام شکل سه ضلع دارد؟',
          '🔺',
          ['دایره', 'مثلث', 'مربع', 'بیضی'],
          1,
          'shapes',
          null,
          imageAsset: 'assets/illustrations/shapes_cards.webp',
          imageIndex: 1,
          visualLabel: 'مثلث',
        ),
        _QuizQuestion(
          'کدام شکل چهار ضلع برابر دارد؟',
          '🟦',
          ['مربع', 'دایره', 'مثلث', 'خط'],
          0,
          'shapes',
          null,
          imageAsset: 'assets/illustrations/shapes_cards.webp',
          imageIndex: 2,
          visualLabel: 'مربع',
        ),
        _QuizQuestion(
          'پنجره معمولاً شبیه چیست؟',
          '🪟',
          ['مستطیل', 'ستاره', 'دایره', 'مثلث'],
          0,
          'shapes',
          null,
          imageAsset: 'assets/illustrations/shapes_cards.webp',
          imageIndex: 3,
          visualLabel: 'مستطیل',
        ),
        _QuizQuestion(
          'کدام گزینه گوشه ندارد؟',
          '⭕',
          ['دایره', 'مربع', 'مثلث', 'مستطیل'],
          0,
          'shapes',
          null,
          imageAsset: 'assets/illustrations/shapes_cards.webp',
          imageIndex: 0,
          visualLabel: 'دایره',
        ),
      ];
    }
    if (topic.contains('میوه') || topic.contains('fruit')) {
      return const [
        _QuizQuestion(
          'کدام میوه پوست زرد دارد؟',
          '🍌',
          ['موز', 'هندوانه', 'انگور', 'توت'],
          0,
          'fruits',
          null,
          imageAsset: 'assets/illustrations/fruits_cards.webp',
          imageIndex: 1,
          visualLabel: 'موز کارتونی',
        ),
        _QuizQuestion(
          'کدام میوه دانه‌های زیادی بیرونش دارد؟',
          '🍓',
          ['توت‌فرنگی', 'سیب', 'موز', 'پرتقال'],
          0,
          'fruits',
          null,
          imageAsset: 'assets/illustrations/fruits_cards.webp',
          imageIndex: 5,
          visualLabel: 'توت‌فرنگی کارتونی',
        ),
        _QuizQuestion(
          'کدام میوه گرد و نارنجی است؟',
          '🍊',
          ['پرتقال', 'خیار', 'هویج', 'کاهو'],
          0,
          'fruits',
          null,
          imageAsset: 'assets/illustrations/fruits_cards.webp',
          imageIndex: 3,
          visualLabel: 'پرتقال کارتونی',
        ),
        _QuizQuestion(
          'برای آبمیوه سیب از چه چیزی استفاده می‌کنیم؟',
          '🍏',
          ['سیب', 'نان', 'پنیر', 'برنج'],
          0,
          'fruits',
          null,
          imageAsset: 'assets/illustrations/fruits_cards.webp',
          imageIndex: 0,
          visualLabel: 'سیب کارتونی',
        ),
        _QuizQuestion(
          'هندوانه داخلش معمولاً چه رنگی است؟',
          '🍉',
          ['قرمز', 'آبی', 'بنفش', 'سیاه'],
          0,
          'fruits',
          null,
          imageAsset: 'assets/illustrations/fruits_cards.webp',
          imageIndex: 4,
          visualLabel: 'هندوانه کارتونی',
        ),
      ];
    }
    if (topic.contains('بدن') || topic.contains('body')) {
      return const [
        _QuizQuestion(
          'با کدام عضو می‌بینیم؟',
          '👀',
          ['چشم', 'گوش', 'پا', 'دست'],
          0,
          'body',
          null,
          imageAsset: 'assets/illustrations/body_cards.webp',
          imageIndex: 0,
          visualLabel: 'چشم کارتونی',
        ),
        _QuizQuestion(
          'با کدام عضو صداها را می‌شنویم؟',
          '👂',
          ['بینی', 'گوش', 'چشم', 'مو'],
          1,
          'body',
          null,
          imageAsset: 'assets/illustrations/body_cards.webp',
          imageIndex: 1,
          visualLabel: 'گوش کارتونی',
        ),
        _QuizQuestion(
          'برای راه رفتن از چه چیزی استفاده می‌کنیم؟',
          '🚶',
          ['پا', 'گوش', 'دندان', 'مو'],
          0,
          'body',
          null,
          imageAsset: 'assets/illustrations/body_cards.webp',
          imageIndex: 4,
          visualLabel: 'پا کارتونی',
        ),
        _QuizQuestion(
          'کدام عضو برای بوییدن است؟',
          '👃',
          ['بینی', 'دست', 'زانو', 'چشم'],
          0,
          'body',
          null,
          imageAsset: 'assets/illustrations/body_cards.webp',
          imageIndex: 2,
          visualLabel: 'بینی کارتونی',
        ),
        _QuizQuestion(
          'با کدام عضو چیزی را می‌گیریم؟',
          '✋',
          ['دست', 'گوش', 'مو', 'شانه'],
          0,
          'body',
          null,
          imageAsset: 'assets/illustrations/body_cards.webp',
          imageIndex: 3,
          visualLabel: 'دست کارتونی',
        ),
      ];
    }

    // Safe fallback for topics that are not yet specialised.
    return const [
      _QuizQuestion('کدام گزینه برای یادگیری بهتر کمک می‌کند؟', '🌟', ['تمرین هر روز', 'تسلیم شدن', 'بی‌دقتی', 'دعوا'], 0, 'concepts', null),
      _QuizQuestion('بعد از بازی خوب چه کاری انجام می‌دهیم؟', '🧸', ['استراحت کوتاه', 'بیدار ماندن تا دیر وقت', 'نخوردن آب', 'پرت کردن وسایل'], 0, 'concepts', null),
      _QuizQuestion('اگر جواب را ندانیم چه کنیم؟', '💡', ['دوباره فکر و تمرین کنیم', 'عصبانی شویم', 'صفحه را ببندیم', 'حدس‌های زیاد بزنیم'], 0, 'concepts', null),
      _QuizQuestion('یک دوست خوب چه کاری می‌کند؟', '🤗', ['کمک و مهربانی', 'مسخره کردن', 'هل دادن', 'گرفتن اسباب‌بازی'], 0, 'concepts', null),
      _QuizQuestion('یادگیری با بازی یعنی چه؟', '🎮', ['هم سرگرمی هم تمرین', 'فقط خواب', 'فقط دویدن', 'فقط تماشا'], 0, 'concepts', null),
    ];
  }

  String _topicTitle(String topic) {
    if (topic.contains('الفبا')) return 'الفبا';
    if (topic.contains('عدد') || topic.contains('اعداد') || topic.contains('شمار')) return 'اعداد';
    if (topic.contains('رنگ')) return 'رنگ‌ها';
    if (topic.contains('حیوان')) return 'حیوانات';
    if (topic.contains('شکل') || topic.contains('اشکال')) return 'شکل‌ها';
    if (topic.contains('میوه') || topic.contains('میوه‌ها')) return 'میوه‌ها';
    if (topic.contains('بدن')) return 'بدن';
    return topic.isEmpty ? 'یادگیری' : topic;
  }

  String _topicEmoji(String topic) {
    if (topic.contains('الفبا')) return '🔤';
    if (topic.contains('عدد') || topic.contains('اعداد') || topic.contains('شمار')) return '🔢';
    if (topic.contains('رنگ')) return '🎨';
    if (topic.contains('حیوان')) return '🐾';
    if (topic.contains('شکل') || topic.contains('اشکال')) return '🔷';
    if (topic.contains('میوه') || topic.contains('میوه‌ها')) return '🍎';
    if (topic.contains('بدن')) return '🧍';
    if (topic.contains('شغل')) return '🧑‍🚒';
    return '🌟';
  }
}

class _QuizQuestion {
  final String prompt;
  final String emoji;
  final List<String> options;
  final int correctIndex;
  final String skill;
  final String? missionId;
  final String? imageAsset;
  final int? imageIndex;
  final String? visualLabel;

  const _QuizQuestion(
    this.prompt,
    this.emoji,
    this.options,
    this.correctIndex,
    this.skill,
    this.missionId, {
    this.imageAsset,
    this.imageIndex,
    this.visualLabel,
  });
}
