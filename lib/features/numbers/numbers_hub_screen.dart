import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import '../../app/design_tokens.dart';
import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/content_access_policy.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/fandoghi_premium.dart';
import '../shop/full_version_paywall.dart';

/// 🔢 NUMBERS HUB PREMIUM — پیشنهاد ۲۴
/// اعداد ۱-۲۰ + جمع/تفریق داستانی با فندقی — با شمارش واقعی سیب/گردو
class NumbersHubScreen extends StatefulWidget {
  const NumbersHubScreen({super.key});
  @override
  State<NumbersHubScreen> createState() => _NumbersHubState();
}

class _NumbersHubState extends State<NumbersHubScreen> {
  int _selectedNumber = 1;
  bool _hasFullVersion = false;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    _refreshEntitlement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FandoghiCoach.say('به دنیای اعداد خوش اومدی! 🔢 با سیب و گردو می‌شمریم — بزن روی هر عدد!', mood: FandoghiMood.excited, duration: const Duration(seconds: 4));
    });
  }

  bool _isLocked(int number) =>
      !_hasFullVersion && !ContentAccessPolicy.isNumberFree(number);

  Future<bool> _refreshEntitlement() async {
    final hasFullVersion = await Monetization.hasFullVersion();
    if (mounted && hasFullVersion != _hasFullVersion) {
      setState(() => _hasFullVersion = hasFullVersion);
    }
    return hasFullVersion;
  }

  Future<void> _selectNumber(int number) async {
    HapticFeedback.selectionClick();
    if (!ContentAccessPolicy.isNumberFree(number) &&
        !await Monetization.hasFullVersion()) {
      if (!mounted) return;
      await showFullVersionPaywall(context, featureName: 'عدد $number');
      if (!mounted || !await _refreshEntitlement()) return;
    }
    if (!mounted) return;
    setState(() => _selectedNumber = number);
    GameData.recordAnswer(correct: true, skill: 'counting');
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
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEF6C00), Color(0xFFFFA000), Color(0xFFFFCA28)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white30)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20))),
                    const SizedBox(width: 10),
                    Expanded(child: Text('دنیای اعداد 🔢 ۱-۲۰', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill)), child: Text('${GameData.skills['counting'] ?? 0}/20', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFFE65100)))),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              FandoghiPremium(size: 56, mood: FandoghiMood.happy, showParticles: false, message: 'عدد $_selectedNumber — ${_emojiOf(_selectedNumber)}'),
              const SizedBox(height: 8),
              // نمایش عدد بزرگ
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.xl), boxShadow: AppShadows.medium, border: Border.all(color: const Color(0xFFE65100).withOpacity(0.2), width: 2)),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(gradient: AppGradients.sunset, shape: BoxShape.circle, boxShadow: AppShadows.colored(const Color(0xFFFF6B00))),
                      child: Center(child: Text('$_selectedNumber', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('عدد $_selectedNumber', style: AppFonts.vazirmatn(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF4E342E))),
                          const SizedBox(height: 4),
                          Text(_selectedNumber <= 10 ? '${'🍎 ' * _selectedNumber}' : 'بشمار: $_selectedNumber تا', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              AudioService.speakNumber(_selectedNumber);
                              FandoghiCoach.say('$_selectedNumber — ${_emojiOf(_selectedNumber)}', mood: FandoghiMood.excited, duration: const Duration(seconds: 2));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFFE65100).withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: const Color(0xFFE65100).withOpacity(0.2))),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFFE65100)), const SizedBox(width: 4), Text('بشنو', style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFE65100)))]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1),
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    final n = index + 1;
                    final locked = _isLocked(n);
                    final selected = _selectedNumber == n && !locked;
                    return GestureDetector(
                      onTap: () => _selectNumber(n),
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFE65100)
                              : locked
                                  ? const Color(0xFF4E342E).withOpacity(0.78)
                                  : Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          border: Border.all(
                            color: selected
                                ? Colors.white
                                : locked
                                    ? Colors.white38
                                    : Colors.white.withOpacity(0.5),
                            width: selected ? 2.5 : 1,
                          ),
                          boxShadow: selected
                              ? AppShadows.colored(
                                  const Color(0xFFE65100),
                                  opacity: 0.3,
                                )
                              : AppShadows.soft,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$n',
                              style: AppFonts.vazirmatn(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: selected
                                    ? Colors.white
                                    : locked
                                        ? Colors.white70
                                        : const Color(0xFF4E342E),
                              ),
                            ),
                            if (locked)
                              const Positioned(
                                top: 3,
                                right: 4,
                                child: Icon(
                                  Icons.lock_rounded,
                                  color: Colors.amberAccent,
                                  size: 11,
                                ),
                              ),
                          ],
                        ),
                      )
                          .animate(delay: (index * 20).ms)
                          .fadeIn(duration: 300.ms)
                          .scale(begin: const Offset(0.85, 0.85)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
