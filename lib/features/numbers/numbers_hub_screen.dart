import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import '../../app/design_tokens.dart';
import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/child_touch_target.dart';
import '../../shared/widgets/fandoghi_premium.dart';

/// 🔢 NUMBERS HUB PREMIUM — دنیای اعداد و دست‌ورزی ریاضی اول دبستان
class NumbersHubScreen extends StatefulWidget {
  const NumbersHubScreen({super.key});
  @override
  State<NumbersHubScreen> createState() => _NumbersHubState();
}

class _NumbersHubState extends State<NumbersHubScreen> {
  int _selectedNumber = 1;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FandoghiCoach.say(
        'به دنیای اعداد و ریاضی اول دبستان خوش اومدی! 🔢 بزن رو هر عدد یا بازی‌های چوب‌خط و جدول ارزش مکانی رو امتحان کن!',
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 4),
      );
    });
  }

  String _emojiOf(int n) {
    const map = {1: '🍎', 2: '🍎🍎', 3: '🍎🍎🍎', 4: '🍏🍏🍏🍏', 5: '🍎🍎🍎🍎🍎', 10: '🎂', 15: '🍉', 20: '🎉'};
    if (map.containsKey(n)) return map[n]!;
    return '🔢';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEF6C00), Color(0xFFFFA000), Color(0xFFFFCA28)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 4),
              FandoghiPremium(
                size: 52,
                mood: FandoghiMood.happy,
                showParticles: false,
                message: 'عدد $_selectedNumber — ${_emojiOf(_selectedNumber)}',
              ),
              const SizedBox(height: 6),
              _buildMathActivitiesRow(),
              const SizedBox(height: 8),
              _buildLargeNumberCard(),
              const SizedBox(height: 10),
              Expanded(
                child: _buildNumbersGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
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
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'دنیای اعداد و ریاضی اول 🔢',
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              '${GameData.skills['counting'] ?? 0}/20',
              style: AppFonts.vazirmatn(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathActivitiesRow() {
    final activities = [
      ('چوب‌خط', '🥢', const Color(0xFF2980B9), '/math/tally'),
      ('ارزش مکانی', '🧮', const Color(0xFF8E44AD), '/math/place-value'),
      ('محور اعداد', '🐸', const Color(0xFF16A085), '/math/number-line'),
      ('تقارن', '🦋', const Color(0xFFD35400), '/math/symmetry'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: activities.map((act) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pushNamed(context, act.$4);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  boxShadow: AppShadows.soft,
                  border: Border.all(color: act.$3.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(act.$2, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      act.$1,
                      style: AppFonts.vazirmatn(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: act.$3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLargeNumberCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.medium,
        border: Border.all(color: const Color(0xFFE65100).withOpacity(0.2), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppGradients.sunset,
              shape: BoxShape.circle,
              boxShadow: AppShadows.colored(const Color(0xFFFF6B00)),
            ),
            child: Center(
              child: Text(
                '$_selectedNumber',
                style: AppFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عدد $_selectedNumber',
                  style: AppFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4E342E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedNumber <= 10 ? '${'🍎 ' * _selectedNumber}' : 'بشمار: $_selectedNumber تا',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    AudioService.speakNumber(_selectedNumber);
                    FandoghiCoach.say(
                      '$_selectedNumber — ${_emojiOf(_selectedNumber)}',
                      mood: FandoghiMood.excited,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: const Color(0xFFE65100).withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFFE65100)),
                        const SizedBox(width: 4),
                        Text(
                          'بشنو',
                          style: AppFonts.vazirmatn(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildNumbersGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        final n = index + 1;
        final selected = _selectedNumber == n;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedNumber = n);
            GameData.recordAnswer(correct: true, skill: 'counting');
          },
          child: AnimatedContainer(
            duration: AppMotion.fast,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE65100) : Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: selected ? Colors.white : Colors.white.withOpacity(0.5),
                width: selected ? 2.5 : 1,
              ),
              boxShadow: selected
                  ? AppShadows.colored(const Color(0xFFE65100), opacity: 0.3)
                  : AppShadows.soft,
            ),
            child: Center(
              child: Text(
                '$n',
                style: AppFonts.vazirmatn(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : const Color(0xFF4E342E),
                ),
              ),
            ),
          ).animate(delay: (index * 15).ms).fadeIn(duration: 250.ms).scale(begin: const Offset(0.85, 0.85)),
        );
      },
    );
  }
}
