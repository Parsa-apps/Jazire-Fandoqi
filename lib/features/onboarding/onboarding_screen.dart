import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/fandoghi_v2.dart';
import '../../shared/widgets/premium_button.dart';

/// =======================================================
/// 🌟 PREMIUM ONBOARDING — تجربه ورود لوکس و کودک‌پسند
/// =======================================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nicknameController = TextEditingController();
  int _page = 0;
  int _age = 5;
  String _selectedAvatar = '🦊';

  // فاز ۱۸: تست سطح اولیه پنهان
  int _quizIndex = 0;
  int _quizScore = 0;
  bool _quizDone = false;
  bool _quizLocked = false;
  int _quizSelected = -1;
  bool _quizWasCorrect = false;

  static const List<_QuizQuestion> _quizQuestions = <_QuizQuestion>[
    _QuizQuestion(
      prompt: 'کدوم یکی از این‌ها حرف «ب» است؟',
      emoji: '🔤',
      options: <String>['آ', 'ب', 'ت'],
      correctIndex: 1,
      skill: 'alphabet',
    ),
    _QuizQuestion(
      prompt: 'چند تا سیب می‌بینی؟',
      emoji: '🍎🍎🍎',
      options: <String>['۲', '۳', '۵'],
      correctIndex: 1,
      skill: 'counting',
    ),
    _QuizQuestion(
      prompt: 'کدوم یکی رنگ قرمز است؟',
      emoji: '🎨',
      options: <String>['🔴', '🟢', '🔵'],
      correctIndex: 0,
      skill: 'colors',
    ),
  ];

  final List<String> _avatars = ['🦊', '🐼', '🐰', '🐨', '🦁', '🐸', '🐧', '🦉'];

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    // فاز ۱۸: اگر کوییز سطح اولیه هنوز کامل نشده، اول بازی تمام شود
    if (!_quizDone) {
      FandoghiCoach.instruction(
        'اول این سه تا سوال کوچولو رو جواب بده؛ بعد با هم وارد دنیای بازی‌ها می‌شیم 🎮',
      );
      return;
    }

    // ✅ فیکس عمیق فاز ۱۱: ذخیره آواتار انتخابی
    GameData.completeOnboarding(
      nickname: _nicknameController.text,
      age: _age,
      avatarIcon: _selectedAvatar,
    );
    Navigator.pushReplacementNamed(context, '/gateway');
  }

  void _goBack() {
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    if (_page > 0)
                      IconButton(
                        onPressed: _goBack,
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                      ),
                    Expanded(
                      child: Text(
                        'شروع یک ماجرای تازه',
                        style: AppFonts.vazirmatn(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Text(
                      '${_page + 1}/4',
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) => setState(() => _page = value),
                  children: [
                    _welcomePage(),
                    _avatarPage(),
                    _profilePage(),
                    _finalPage(),
                  ],
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: PremiumButton(
                  text: _page == 3 ? 'ورود به دنیای من 🌟' : 'ادامه',
                  icon: _page == 3 ? Icons.stars_rounded : Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PAGE 1: WELCOME ====================
  Widget _welcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FandoghiV2(
            size: 140,
            animate: true,
            mood: FandoghiMood.excited,
            message: 'من فندقی‌ام؛ بیا با هم کلی چیز قشنگ یاد بگیریم! 🌰',
          ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 32),

          Text(
            'سلام قهرمان کوچولو! 👋',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          Text(
            'اینجا با بازی و ماجراجویی، هر روز یه مهارت جدید یاد می‌گیری.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 17, height: 1.6),
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 40),
          _privacyNote(),
        ],
      ),
    );
  }

  // ==================== PAGE 2: AVATAR ====================
  Widget _avatarPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'آواتارت رو انتخاب کن',
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'هر کدوم که دوست داری!',
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
          const SizedBox(height: 40),

          // Avatar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: _avatars.length,
            itemBuilder: (context, index) {
              final avatar = _avatars[index];
              final isSelected = avatar == _selectedAvatar;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedAvatar = avatar);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white24,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 42)),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 50),
          Text(
            'آواتارت: $_selectedAvatar',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ==================== PAGE 3: PROFILE ====================
  Widget _profilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const FandoghiV2(size: 100, animate: true, mood: FandoghiMood.happy),
          const SizedBox(height: 24),

          Text(
            'قهرمانت رو بساز',
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 32),

          TextField(
            controller: _nicknameController,
            maxLength: 20,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              labelText: 'لقب یا اسم مستعار (اختیاری)',
              hintText: 'مثلاً: ستاره کوچولو',
              prefixIcon: const Icon(Icons.face_rounded, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'چند سالته؟',
            style: AppFonts.vazirmatn(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(8, (index) {
              final age = index + 3;
              final selected = age == _age;
              return ChoiceChip(
                label: Text('$age سال'),
                selected: selected,
                onSelected: (_) => setState(() => _age = age),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: Colors.white.withOpacity(0.08),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==================== PAGE 4: بازی سطح اولیه پنهان (فاز ۱۸) ====================
  Widget _finalPage() {
    if (_quizDone) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FandoghiV2(
              size: 120,
              animate: true,
              mood: FandoghiMood.celebrating,
            ),
            const SizedBox(height: 30),
            Text(
              'عالیه! آماده‌ای؟ 🎉',
              textAlign: TextAlign.center,
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'حالا می‌تونی با فندقی به دنیای بازی‌ها و یادگیری بری!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.6),
            ),
            const SizedBox(height: 14),
            // فاز ۱۸: نمایش نتیجه تست سطح اولیه (برای والدین)
            Text(
              'پاسخ‌های درست: $_quizScore از ${_quizQuestions.length} 🌟',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 28),
            _privacyNote(),
          ],
        ),
      );
    }

    // «بذار ببینم چی بلدی» — تست سطح اولیه پنهان (بدون برچسب تست)
    final question = _quizQuestions[_quizIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          FandoghiV2(size: 90, animate: true, mood: FandoghiMood.thinking),
          const SizedBox(height: 18),
          Text(
            'بذار ببینم چی بلدی! 😄',
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'سوال ${_quizIndex + 1} از ${_quizQuestions.length}',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 26),
          Text(
            question.emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 14),
          Text(
            question.prompt,
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < question.options.length; i++) ...[
            _quizOption(i, question),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _quizOption(int index, _QuizQuestion question) {
    final selected = _quizLocked && _quizSelected == index;
    final isCorrectOption = index == question.correctIndex;
    final Color bg;
    if (selected) {
      bg = _quizWasCorrect ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
    } else {
      bg = Colors.white.withOpacity(0.12);
    }
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _quizLocked ? null : () => _answerQuiz(question, index),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? Colors.white
                    : Colors.white.withOpacity(0.25),
                width: selected ? 2.5 : 1,
              ),
            ),
            child: Text(
              question.options[index],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _answerQuiz(_QuizQuestion question, int index) {
    final correct = index == question.correctIndex;
    setState(() {
      _quizLocked = true;
      _quizSelected = index;
      _quizWasCorrect = correct;
    });

    if (correct) _quizScore++;
    // ثبت مهارت (حتی با پاسخ نادرست — شرکت کردن ارزش دارد)
    GameData.recordAnswer(correct: correct, skill: question.skill);
    GameData.addSkill(question.skill);

    if (correct) {
      FandoghiCoach.correct('آفرین! تو بلدی! 🌟');
      HapticFeedback.lightImpact();
    } else {
      FandoghiCoach.incorrect(question.options[question.correctIndex]);
    }

    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_quizIndex + 1 < _quizQuestions.length) {
        setState(() {
          _quizIndex++;
          _quizLocked = false;
          _quizSelected = -1;
        });
      } else {
        setState(() {
          _quizDone = true;
          _quizLocked = false;
        });
        FandoghiCoach.reward('همه جواب‌ها رو دادی؛ حالا بریم بازی کنیم! 🎮');
      }
    });
  }

  Widget _privacyNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: Colors.white54, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'همه اطلاعات فقط روی دستگاه خودت ذخیره می‌شه و کاملاً خصوصی است.',
              style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
/// فاز ۱۸: سوال بازی سطح اولیه (بدون برچسب تست برای کودک).
class _QuizQuestion {
  final String prompt;
  final String emoji;
  final List<String> options;
  final int correctIndex;
  final String skill;

  const _QuizQuestion({
    required this.prompt,
    required this.emoji,
    required this.options,
    required this.correctIndex,
    required this.skill,
  });
}
