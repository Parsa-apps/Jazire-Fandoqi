import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import '../../app/design_tokens.dart';
import '../../app/app_fonts.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../core/learning_content/learning_topics.dart';
import '../../shared/widgets/fandoghi_premium.dart';

/// 🌈 CONCEPTS HUB PREMIUM — پیشنهاد ۲۸
/// مفاهیم اولیه: بزرگ/کوچک، شب/روز، فصل‌ها، هوا، زمان
class ConceptsHubScreen extends StatefulWidget {
  const ConceptsHubScreen({super.key});
  @override
  State<ConceptsHubScreen> createState() => _ConceptsHubState();
}

class _ConceptsHubState extends State<ConceptsHubScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FandoghiCoach.say('به دنیای مفاهیم خوش اومدی! 🌈 بزرگ و کوچک، شب و روز، فصل‌ها — همه رو با هم یاد می‌گیریم!', mood: FandoghiMood.excited, duration: const Duration(seconds: 4));
    });
  }

  @override
  Widget build(BuildContext context) {
    final topic = learningTopics.firstWhere((t) => t.id == 'concepts');
    // دسته‌بندی مفاهیم
    final groups = {
      'اندازه': topic.cards.where((c) => ['بزرگ', 'کوچک'].contains(c.name)).toList(),
      'شبانه‌روز': topic.cards.where((c) => ['روز', 'شب', 'صبح', 'ظهر', 'عصر', 'ساعت'].contains(c.name)).toList(),
      'فصل‌ها': topic.cards.where((c) => ['بهار', 'تابستان', 'پاییز', 'زمستان'].contains(c.name)).toList(),
      'هوا': topic.cards.where((c) => ['آفتابی', 'بارانی', 'ابری', 'برفی'].contains(c.name)).toList(),
    };
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFA000), Color(0xFFFFCA28)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white30)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20))),
                    const SizedBox(width: 10),
                    Expanded(child: Text('مفاهیم اولیه 🌈 — ۱۶ مفهوم', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))),
                    const FandoghiPremium(size: 40, mood: FandoghiMood.happy, showParticles: false),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  physics: const BouncingScrollPhysics(),
                  children: groups.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                          child: Row(
                            children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.soft), child: Text(entry.key, style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFFE65100)))),
                              const SizedBox(width: 8),
                              Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.4))),
                              const SizedBox(width: 8),
                              Text('${entry.value.length} مفهوم', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6),
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            final card = entry.value[index];
                            final isSelected = _selectedId == card.id;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedId = card.id);
                                FandoghiCoach.say('${card.name} ${card.emoji} — ${card.fact ?? ''}', mood: FandoghiMood.happy, duration: const Duration(seconds: 3));
                                GameData.recordAnswer(correct: true, skill: 'concepts');
                                setState(() {});
                              },
                              child: AnimatedContainer(
                                duration: AppMotion.fast,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(AppRadii.xl),
                                  border: Border.all(color: isSelected ? const Color(0xFFE65100) : Colors.white.withOpacity(0.5), width: isSelected ? 2.5 : 1),
                                  boxShadow: isSelected ? AppShadows.colored(const Color(0xFFE65100), opacity: 0.25) : AppShadows.soft,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(card.emoji, style: const TextStyle(fontSize: 36)),
                                    const SizedBox(height: 4),
                                    Text(card.name, style: AppFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF4E342E))),
                                    if (card.fact != null) Text(card.fact!, style: TextStyle(fontSize: 10, color: Colors.black54), textAlign: TextAlign.center),
                                  ],
                                ),
                              ).animate(delay: (index * 40).ms).fadeIn(duration: 300.ms),
                            );
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
