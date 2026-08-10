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

/// 👷 JOBS HUB PREMIUM — پیشنهاد ۲۷
/// ۲۰ شغل با کارت پریمیوم + نکته + صدای فندقی
class JobsHubScreen extends StatefulWidget {
  const JobsHubScreen({super.key});
  @override
  State<JobsHubScreen> createState() => _JobsHubState();
}

class _JobsHubState extends State<JobsHubScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FandoghiCoach.say('به دنیای شغل‌ها خوش اومدی! 👷 هر شغلی یه قهرمانه — بزن روش تا بشناسی!', mood: FandoghiMood.excited, duration: const Duration(seconds: 4));
    });
  }

  @override
  Widget build(BuildContext context) {
    final topic = learningTopics.firstWhere((t) => t.id == 'jobs');
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white30)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text('دنیای شغل‌ها 👷 — ۲۰ قهرمان', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill)),
                      child: Text('${GameData.skills['jobs'] ?? 0}/20', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF0D47A1))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const FandoghiPremium(size: 52, mood: FandoghiMood.happy, showParticles: false),
              const SizedBox(height: 6),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.05),
                  itemCount: topic.cards.length,
                  itemBuilder: (context, index) {
                    final card = topic.cards[index];
                    final isSelected = _selectedId == card.id;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedId = card.id);
                        FandoghiCoach.say('${card.name} — ${card.fact ?? 'یک شغل مهم و دوست‌داشتنی'} ${card.emoji}', mood: FandoghiMood.happy, duration: const Duration(seconds: 3));
                        GameData.recordAnswer(correct: true, skill: 'jobs');
                        setState(() {});
                      },
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          border: Border.all(color: isSelected ? const Color(0xFF0D47A1) : Colors.white.withOpacity(0.5), width: isSelected ? 2.5 : 1),
                          boxShadow: isSelected ? AppShadows.colored(const Color(0xFF0D47A1), opacity: 0.25) : AppShadows.soft,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(card.emoji, style: const TextStyle(fontSize: 42)),
                            const SizedBox(height: 6),
                            Text(card.name, textAlign: TextAlign.center, style: AppFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0D47A1)), maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (card.fact != null) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(card.fact!, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF0D47A1).withOpacity(isSelected ? 0.15 : 0.08), borderRadius: BorderRadius.circular(AppRadii.pill)),
                              child: Text(isSelected ? 'شناخته شد ✓' : 'بشنو', style: AppFonts.vazirmatn(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0D47A1))),
                            ),
                          ],
                        ),
                      ).animate(delay: (index * 25).ms).fadeIn(duration: 300.ms).scale(begin: const Offset(0.92, 0.92)),
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
