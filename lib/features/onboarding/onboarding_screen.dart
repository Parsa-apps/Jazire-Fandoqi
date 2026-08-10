import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import '../../app/design_tokens.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/fandoghi_premium.dart';
import '../../shared/widgets/premium_button.dart';

/// =======================================================
/// 🌟 PREMIUM ONBOARDING V2 — پیشنهاد پریمیوم شماره ۱۸
/// ۴ مرحله بازی‌گونه + آواتار واقعی + تست پنهان + جایزه
/// طراحی با Design Tokens + انیمیشن Spring + فندقی V4
/// =======================================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _nicknameController = TextEditingController();
  late final AnimationController _progressCtrl;

  int _page = 0;
  int _age = 5;
  String _selectedAvatar = '🦊';
  String _selectedAvatarImage = '';

  // فاز ۱۸: تست سطح اولیه پنهان — ۳ سوال
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

  // آواتارهای تصویرسازی‌شده واقعی + ایموجی
  static const List<_AvatarOption> _avatarOptions = [
    _AvatarOption(emoji: '🦊', image: 'assets/avatars/avatar_0.png', name: 'روباه باهوش'),
    _AvatarOption(emoji: '🐼', image: 'assets/avatars/avatar_1.png', name: 'پاندای مهربون'),
    _AvatarOption(emoji: '🐰', image: 'assets/avatars/avatar_2.png', name: 'خرگوش تندرو'),
    _AvatarOption(emoji: '🐨', image: 'assets/avatars/avatar_3.png', name: 'کوآلای ناز'),
    _AvatarOption(emoji: '🦁', image: 'assets/avatars/avatar_4.png', name: 'شیر شجاع'),
    _AvatarOption(emoji: '🐸', image: 'assets/avatars/avatar_5.png', name: 'قورباغه شاد'),
    _AvatarOption(emoji: '🐧', image: '', name: 'پنگوئن برفی'),
    _AvatarOption(emoji: '🦉', image: '', name: 'جغد دانا'),
  ];

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: AppMotion.slow);
    _progressCtrl.value = 0.25;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_page < 3) {
      _pageController.nextPage(
        duration: AppMotion.normal,
        curve: AppMotion.entrance,
      );
      return;
    }
    if (!_quizDone) {
      FandoghiCoach.instruction('اول این سه تا سوال کوچولو رو جواب بده؛ بعد با هم وارد دنیای بازی‌ها می‌شیم 🎮');
      return;
    }
    GameData.completeOnboarding(
      nickname: _nicknameController.text,
      age: _age,
      avatarIcon: _selectedAvatar,
    );
    // جایزه خوش‌آمدگویی ۵۰ سکه
    GameData.addCoins(50);
    FandoghiCoach.celebrate('خوش اومدی ${_nicknameController.text.isEmpty ? "قهرمان" : _nicknameController.text}! ۵۰ سکه هدیه گرفتی! 🎉');
    Navigator.pushReplacementNamed(context, '/gateway');
  }

  void _goBack() {
    if (_page > 0) {
      HapticFeedback.selectionClick();
      _pageController.previousPage(
        duration: AppMotion.normal,
        curve: AppMotion.entrance,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    _progressCtrl.animateTo((page + 1) / 4, duration: AppMotion.normal, curve: AppMotion.entrance);
  }

  @override
  Widget build(BuildContext context) {
    final seasonal = SeasonalTokens.current;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: seasonal == SeasonalTheme.normal ? [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)] : [SeasonalTokens.gradient.first.withOpacity(0.9), SeasonalTokens.gradient.last.withOpacity(0.85), const Color(0xFF0F0C29)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildPremiumHeader(),
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  children: [
                    _welcomePage(),
                    _avatarPage(),
                    _profilePage(),
                    _finalPage(),
                  ],
                ),
              ),
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  // ── هدر پریمیوم با دکمه برگشت و نشان مرحله ────────────────
  Widget _buildPremiumHeader() {
    final titles = ['خوش اومدی!', 'آواتارت', 'قهرمانت', 'بذار ببینم!'];
    final subtitles = ['ماجراجویی با فندقی', 'یکی رو انتخاب کن', 'اسم و سنت', '۳ سوال کوچولو'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          if (_page > 0)
            GestureDetector(
              onTap: _goBack,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white24)),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
              ),
            )
          else
            const SizedBox(width: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titles[_page], style: AppFonts.vazirmatn(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                Text(subtitles[_page], style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // نشان فصلی
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: Colors.white24)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(SeasonalTokens.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text('${_page + 1} / 4', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: AnimatedBuilder(
          animation: _progressCtrl,
          builder: (context, _) {
            return LinearProgressIndicator(
              value: _progressCtrl.value,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(SeasonalTokens.gradient.first),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    final isLastPage = _page == 3;
    final canProceed = !isLastPage || _quizDone;
    final buttonText = isLastPage ? (_quizDone ? 'ورود به دنیای من 🌟 + ۵۰ سکه' : 'اول سوال‌ها رو جواب بده') : 'ادامه';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          if (isLastPage && _quizDone)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text('۵۰ سکه هدیه منتظرته!', style: AppFonts.vazirmatn(color: const Color(0xFFFFD700), fontWeight: FontWeight.w800, fontSize: 13)),
                ],
              ),
            ).animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),
          SizedBox(
            width: double.infinity,
            child: Opacity(
              opacity: canProceed ? 1 : 0.55,
              child: PremiumButton(
                text: buttonText,
                icon: isLastPage ? Icons.stars_rounded : Icons.arrow_forward_rounded,
                onPressed: canProceed ? _next : () {},
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('قدم ${_page + 1} از ۴ — ${SeasonalTokens.greeting}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  // ==================== PAGE 1: WELCOME ====================
  Widget _welcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // فندقی V4 پریمیوم با ذرات
          const FandoghiPremium(
            size: 148,
            mood: FandoghiMood.excited,
            showParticles: true,
            message: 'من فندقی‌ام؛ بیا با هم کلی چیز قشنگ یاد بگیریم! 🌰',
          ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 28),
          Text('سلام قهرمان کوچولو! 👋', textAlign: TextAlign.center, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900))
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: AppMotion.entrance),
          const SizedBox(height: 12),
          Text('اینجا با بازی و ماجراجویی، هر روز یه مهارت جدید یاد می‌گیری.\n${SeasonalTokens.greeting}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.7))
              .animate()
              .fadeIn(delay: 600.ms),
          const SizedBox(height: 20),
          // کارت‌های پیش‌نمایش ۳ دسته
          Row(
            children: [
              _previewChip('🔤', 'الفبا', AppColors.primary),
              const SizedBox(width: 10),
              _previewChip('🎨', 'رنگ‌ها', const Color(0xFFFF6B6B)),
              const SizedBox(width: 10),
              _previewChip('🧩', 'بازی‌ها', const Color(0xFF00B894)),
            ],
          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0, duration: 500.ms),
          const SizedBox(height: 24),
          _privacyNote(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _previewChip(String emoji, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: color.withOpacity(0.35))),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(label, style: AppFonts.vazirmatn(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ==================== PAGE 2: AVATAR ====================
  Widget _avatarPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text('آواتارت رو انتخاب کن', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          Text('هر کدوم یه قدرت خاص داره ✨', style: const TextStyle(color: Colors.white60, fontSize: 14)).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
              itemCount: _avatarOptions.length,
              itemBuilder: (context, index) {
                final option = _avatarOptions[index];
                final isSelected = _selectedAvatar == option.emoji;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedAvatar = option.emoji;
                      _selectedAvatarImage = option.image;
                    });
                  },
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.18) : Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: isSelected ? SeasonalTokens.gradient.first : Colors.white24, width: isSelected ? 3 : 1),
                      boxShadow: isSelected ? AppShadows.colored(SeasonalTokens.gradient.first, opacity: 0.3) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // تصویر واقعی یا ایموجی
                        if (option.image.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            child: Image.asset(option.image, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Text(option.emoji, style: const TextStyle(fontSize: 38))),
                          )
                        else
                          Text(option.emoji, style: const TextStyle(fontSize: 38)),
                        const SizedBox(height: 6),
                        Text(option.name, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 10, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600)),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: SeasonalTokens.gradient.first)).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                        ],
                      ],
                    ),
                  ).animate(delay: (index * 60).ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // نمایش انتخاب
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: Colors.white24)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedAvatarImage.isNotEmpty)
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(_selectedAvatarImage, width: 28, height: 28, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Text(_selectedAvatar, style: const TextStyle(fontSize: 20))))
                else
                  Text(_selectedAvatar, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('انتخابت: ${_avatarOptions.firstWhere((e) => e.emoji == _selectedAvatar).name}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded, color: Color(0xFF00B894), size: 18),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ==================== PAGE 3: PROFILE ====================
  Widget _profilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          FandoghiPremium(size: 96, mood: FandoghiMood.happy, showParticles: false).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('قهرمانت رو بساز', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          Text('یه لقب بامزه انتخاب کن', style: const TextStyle(color: Colors.white60, fontSize: 14)),
          const SizedBox(height: 24),
          // فیلد اسم با دیزاین توکن
          TextField(
            controller: _nicknameController,
            maxLength: 20,
            style: AppFonts.vazirmatn(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              labelText: 'لقب یا اسم مستعار (اختیاری)',
              hintText: 'مثلاً: ستاره کوچولو ⭐',
              labelStyle: const TextStyle(color: Colors.white60),
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: SeasonalTokens.gradient.first.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadii.sm)),
                child: const Icon(Icons.face_rounded, color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              counterStyle: const TextStyle(color: Colors.white38),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.lg), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.lg), borderSide: BorderSide(color: SeasonalTokens.gradient.first, width: 2)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_nicknameController.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF00B894).withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: const Color(0xFF00B894).withOpacity(0.3))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👋', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text('سلام ${_nicknameController.text} عزیزم!', style: AppFonts.vazirmatn(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerRight, child: Text('چند سالته؟', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(8, (index) {
              final age = index + 3;
              final selected = age == _age;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _age = age);
                },
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? SeasonalTokens.gradient.first : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(color: selected ? Colors.white : Colors.white24, width: selected ? 2 : 1),
                    boxShadow: selected ? AppShadows.colored(SeasonalTokens.gradient.first) : null,
                  ),
                  child: Text('$age سال', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: selected ? 15 : 14)),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // کارت راهنما سنی
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: Colors.white12)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: SeasonalTokens.gradient.first.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadii.sm)),
                  child: Icon(_ageIcon(_age), color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_ageHint(_age), style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5))),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  IconData _ageIcon(int age) {
    if (age <= 4) return Icons.child_care_rounded;
    if (age <= 6) return Icons.school_rounded;
    return Icons.emoji_events_rounded;
  }

  String _ageHint(int age) {
    if (age <= 4) return 'برای ۳-۴ سال: بازی‌های ساده و رنگارنگ با فندقی مهربون';
    if (age <= 6) return 'برای ۵-۶ سال: ماجراجویی مرحله‌ای با چالش‌های باحال';
    return 'برای ۷-۸ سال: چالش‌های فکری و مسابقه‌ای حرفه‌ای';
  }

  // ==================== PAGE 4: QUIZ ====================
  Widget _finalPage() {
    if (_quizDone) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FandoghiPremium(size: 130, mood: FandoghiMood.celebrating, showParticles: true).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text('عالیه! آماده‌ای؟ 🎉', textAlign: TextAlign.center, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            const Text('حالا می‌تونی با فندقی به دنیای بازی‌ها و یادگیری بری!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6)).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFFFFD700).withOpacity(0.2), const Color(0xFFFF8E53).withOpacity(0.2)]), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 8),
                  Text('امتیازت: $_quizScore از ${_quizQuestions.length} 🌟', style: AppFonts.vazirmatn(color: const Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
            ).animate().scale(delay: 700.ms, duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 10),
            Text(_quizFeedback(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)).animate().fadeIn(delay: 900.ms),
            const SizedBox(height: 20),
            _privacyNote(),
          ],
        ),
      );
    }

    final question = _quizQuestions[_quizIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          FandoghiPremium(size: 88, mood: FandoghiMood.thinking, showParticles: false),
          const SizedBox(height: 12),
          Text('بذار ببینم چی بلدی! 😄', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Text('سوال ${_quizIndex + 1} از ${_quizQuestions.length} • ${_progressEmoji(_quizIndex)}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 20),
          // کارت سوال با دیزاین توکن
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(AppRadii.xl), border: Border.all(color: Colors.white.withOpacity(0.15))),
            child: Column(
              children: [
                Text(question.emoji, style: const TextStyle(fontSize: 52)).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 12),
                Text(question.prompt, textAlign: TextAlign.center, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, height: 1.5)),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 20),
          for (var i = 0; i < question.options.length; i++) ...[
            _quizOption(i, question).animate(delay: (i * 80).ms).fadeIn(duration: 400.ms).slideX(begin: 0.15, end: 0),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          Text('💡 این فقط بازیه، اشتباه هم عالیه!', style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _progressEmoji(int index) => ['🔤', '🍎', '🎨'][index];
  String _quizFeedback() {
    if (_quizScore == 3) return 'وای! تو یه نابغه کوچولویی! فندقی خیلی ذوق کرده 🤩';
    if (_quizScore == 2) return 'آفرین! خیلی چیزا بلدی، با فندقی بیشتر هم یاد می‌گیری 💪';
    return 'عالیه که اومدی! فندقی قدم به قدم همه‌چی رو بهت یاد می‌ده 🌱';
  }

  Widget _quizOption(int index, _QuizQuestion question) {
    final selected = _quizLocked && _quizSelected == index;
    final bool isCorrect = index == question.correctIndex;
    Color bg;
    Color border;
    IconData? icon;
    if (selected) {
      bg = _quizWasCorrect ? const Color(0xFF00B894) : const Color(0xFFFF7675);
      border = Colors.white;
      icon = _quizWasCorrect ? Icons.check_circle_rounded : Icons.close_rounded;
    } else {
      bg = Colors.white.withOpacity(0.10);
      border = Colors.white24;
      icon = null;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: _quizLocked ? null : () => _answerQuiz(question, index),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: border, width: selected ? 2.5 : 1), boxShadow: selected ? AppShadows.medium : null),
          child: Row(
            children: [
              Expanded(child: Text(question.options[index], textAlign: TextAlign.center, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
              if (icon != null) ...[
                const SizedBox(width: 12),
                Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white), child: Icon(icon, size: 18, color: bg)),
              ],
            ],
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
    GameData.recordAnswer(correct: correct, skill: question.skill);
    GameData.addSkill(question.skill);
    if (correct) {
      FandoghiCoach.correct('آفرین! تو بلدی! 🌟');
      HapticFeedback.lightImpact();
    } else {
      FandoghiCoach.incorrect(question.options[question.correctIndex]);
      HapticFeedback.heavyImpact();
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
        HapticFeedback.mediumImpact();
      }
    });
  }

  Widget _privacyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF00B894).withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadii.sm)), child: const Icon(Icons.lock_rounded, color: Color(0xFF00B894), size: 18)),
          const SizedBox(width: 12),
          const Expanded(child: Text('همه اطلاعات فقط روی دستگاه خودت ذخیره می‌شه و کاملاً خصوصی است. 🔒', style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5))),
        ],
      ),
    );
  }
}

class _AvatarOption {
  final String emoji;
  final String image;
  final String name;
  const _AvatarOption({required this.emoji, required this.image, required this.name});
}

class _QuizQuestion {
  final String prompt;
  final String emoji;
  final List<String> options;
  final int correctIndex;
  final String skill;
  const _QuizQuestion({required this.prompt, required this.emoji, required this.options, required this.correctIndex, required this.skill});
}
