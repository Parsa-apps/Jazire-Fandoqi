import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_colors.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/fandoghi_v2.dart';
import '../../shared/widgets/premium_button.dart';

/// A short, local-only setup for the child profile.
///
/// We ask for a nickname rather than a real name and make it optional. No
/// account, phone number, email, location or network permission is required.
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

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    GameData.completeOnboarding(
      nickname: _nicknameController.text,
      age: _age,
    );
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'شروع یک ماجرای تازه',
                      style: GoogleFonts.vazirmatn(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_page + 1}/2',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) => setState(() => _page = value),
                  children: [
                    _welcomePage(),
                    _profilePage(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: PremiumButton(
                  text: _page == 0 ? 'بزن بریم! 🚀' : 'ورود به دنیای من 🌟',
                  icon: _page == 0 ? Icons.rocket_launch_rounded : Icons.stars_rounded,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const FandoghiV2(
            size: 130,
            animate: true,
            mood: FandoghiMood.excited,
            message: 'من فندقی‌ام؛ با هم کلی چیز جالب یاد می‌گیریم! 🌰',
          ),
          const SizedBox(height: 24),
          Text(
            'سلام قهرمان کوچولو! 👋',
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          const SizedBox(height: 12),
          const Text(
            'اینجا با بازی، کشف می‌کنی و هر روز یک مهارت تازه یاد می‌گیری.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.7,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
          const SizedBox(height: 24),
          _privacyNote(),
        ],
      ),
    );
  }

  Widget _profilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const FandoghiV2(
            size: 92,
            animate: true,
            mood: FandoghiMood.happy,
          ),
          const SizedBox(height: 18),
          Text(
            'قهرمانت را بساز',
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nicknameController,
            maxLength: 24,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              LengthLimitingTextInputFormatter(24),
              FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
            ],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'لقب یا اسم مستعار (اختیاری)',
              hintText: 'مثلاً: ستاره کوچولو',
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
              counterStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.face_rounded, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              enabledBorder: _border(Colors.white24),
              focusedBorder: _border(AppColors.primaryLight),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'چند سالته؟',
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(10, (index) {
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
                side: BorderSide(color: Colors.white.withOpacity(0.12)),
              );
            }),
          ),
          const SizedBox(height: 18),
          _privacyNote(),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _privacyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: Colors.white70, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'اطلاعات این صفحه فقط روی همین دستگاه ذخیره می‌شود و برای بازی ضروری نیست.',
              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
