import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/learning_content/children_stories_data.dart';
import '../../../shared/widgets/fandoghi_v2.dart';
import '../../../shared/widgets/particle_celebration.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎯 STORY QUIZ MODAL — چالش درک مطلب داستان
/// دو پرسش چهارگزینه‌ای همراه با تشویق، توضیح و جایزه ستاره و سکه
/// ═══════════════════════════════════════════════════════════════
class StoryQuizModal extends StatefulWidget {
  final ChildrenStory story;

  const StoryQuizModal({super.key, required this.story});

  static Future<void> show(BuildContext context, ChildrenStory story) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StoryQuizModal(story: story),
    );
  }

  @override
  State<StoryQuizModal> createState() => _StoryQuizModalState();
}

class _StoryQuizModalState extends State<StoryQuizModal> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _finished = false;
  int _score = 0;

  StoryQuizQuestion get _currentQuestion =>
      widget.story.quizQuestions[_currentIndex];

  void _selectOption(int idx) {
    if (_answered) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = idx;
      _answered = true;
      if (idx == _currentQuestion.correctIndex) {
        _score++;
        AudioService.correct();
        AudioService.speak('آفرین! پاسخت کاملاً درست بود');
      } else {
        AudioService.wrong();
        AudioService.speak('اشکالی نداره! پاسخ درست رو یاد گرفتیم');
      }
    });
  }

  void _nextQuestion() {
    HapticFeedback.mediumImpact();
    AudioService.tap();
    if (_currentIndex < widget.story.quizQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      // اتمام مسابقه
      setState(() => _finished = true);
      AudioService.win();
      GameData.addStars(5);
      GameData.addCoins(25);
      FandoghiCoach.reward(
        'آفرین قهرمان باهوش! مسابقه داستان «${widget.story.title}» رو عالی تموم کردی 🏆 ۵ ستاره + ۲۵ سکه هدیه گرفتی!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF28234E), Color(0xFF1B1836)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.amberAccent.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (_finished) _buildFinishedView() else _buildQuestionView(),
            if (_finished)
              const Positioned.fill(
                child: IgnorePointer(
                  child: ParticleCelebration(count: 50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    final q = _currentQuestion;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // هدر سوال
        Row(
          children: [
            FandoghiV2(size: 52, mood: FandoghiMood.excited),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        'چالش درک مطلب داستان',
                        style: AppFonts.vazirmatn(
                          color: Colors.amberAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سوال ${_currentIndex + 1} از ${widget.story.quizQuestions.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white54),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // متن پرسش
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            q.question,
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.6,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // گزینه‌ها
        for (int i = 0; i < q.options.length; i++) ...[
          _buildOptionCard(i, q.options[i], q.correctIndex),
          const SizedBox(height: 12),
        ],

        // توضیح پاسخ بعد از انتخاب
        if (_answered) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _selectedIndex == q.correctIndex
                  ? Colors.green.withOpacity(0.2)
                  : Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedIndex == q.correctIndex
                    ? Colors.greenAccent
                    : Colors.amberAccent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedIndex == q.correctIndex
                      ? Icons.check_circle_rounded
                      : Icons.lightbulb_rounded,
                  color: _selectedIndex == q.correctIndex
                      ? Colors.greenAccent
                      : Colors.amberAccent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    q.explanation,
                    style: AppFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 250.ms),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 4,
            ),
            child: Text(
              _currentIndex < widget.story.quizQuestions.length - 1
                  ? 'سوال بعدی ➡'
                  : 'مشاهده نتیجه و جایزه 🏆',
              style: AppFonts.vazirmatn(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionCard(int index, String optionText, int correctIndex) {
    bool isSelected = _selectedIndex == index;
    bool isCorrect = index == correctIndex;

    Color bg = Colors.white.withOpacity(0.1);
    Color borderColor = Colors.white24;

    if (_answered) {
      if (isCorrect) {
        bg = Colors.green.withOpacity(0.35);
        borderColor = Colors.greenAccent;
      } else if (isSelected) {
        bg = Colors.redAccent.withOpacity(0.35);
        borderColor = Colors.redAccent;
      }
    } else if (isSelected) {
      bg = Colors.amber.withOpacity(0.3);
      borderColor = Colors.amberAccent;
    }

    return GestureDetector(
      onTap: () => _selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _answered && isCorrect
                    ? Colors.green
                    : _answered && isSelected
                        ? Colors.redAccent
                        : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: _answered && isCorrect
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : _answered && isSelected
                      ? const Icon(Icons.close, color: Colors.white, size: 16)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                optionText,
                style: AppFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🏆✨', style: TextStyle(fontSize: 64))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
              duration: 800.ms,
            ),
        const SizedBox(height: 16),
        Text(
          'آفرین قهرمان داستان‌ها!',
          style: AppFonts.vazirmatn(
            color: Colors.amberAccent,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تو به هر $_score سوال داستان درست پاسخ دادی و پندهای شیرین رو به خوبی یاد گرفتی.',
          textAlign: TextAlign.center,
          style: AppFonts.vazirmatn(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.amberAccent.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                  const SizedBox(width: 6),
                  Text(
                    '+۵ ستاره',
                    style: AppFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  const Icon(Icons.monetization_on_rounded,
                      color: Colors.amberAccent, size: 24),
                  const SizedBox(width: 6),
                  Text(
                    '+۲۵ سکه',
                    style: AppFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 6,
            ),
            child: Text(
              'بازگشت به قصه‌خانه 📚',
              style: AppFonts.vazirmatn(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
