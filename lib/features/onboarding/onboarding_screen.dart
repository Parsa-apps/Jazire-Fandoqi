import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
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

    // ✅ فیکس عمیق فاز ۱۱: ذخیره آواتار انتخابی
    GameData.completeOnboarding(
      nickname: _nicknameController.text,
      age: _age,
      avatarIcon: _selectedAvatar,
    );
    Navigator.pushReplacementNamed(context, '/home');
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

  // ==================== PAGE 4: FINAL ====================
  Widget _finalPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FandoghiV2(size: 120, animate: true, mood: FandoghiMood.excited),
          const SizedBox(height: 30),

          Text(
            'عالیه! آماده‌ای؟',
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
          const SizedBox(height: 40),
          _privacyNote(),
        ],
      ),
    );
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