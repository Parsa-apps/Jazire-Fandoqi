import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/growth/growth.dart';
import '../../shared/widgets/child_touch_target.dart';
import 'life_skills_game.dart';

class LifeSkillsHubScreen extends StatefulWidget {
  const LifeSkillsHubScreen({super.key});

  @override
  State<LifeSkillsHubScreen> createState() => _LifeSkillsHubScreenState();
}

class _LifeSkillsHubScreenState extends State<LifeSkillsHubScreen> {
  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    ActivityTracker.recordOpen(route: '/life-skills', title: 'مهارت زندگی', skill: 'concepts');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.instruction(
          'این‌جا زندگی واقعی را تمرین می‌کنیم: خیابان، بهداشت، پول و ایران خودمان 🧭',
        );
      }
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _open(LifeSkillTopic topic) {
    HapticFeedback.selectionClick();
    AudioService.select();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (_) => LifeSkillsGame(topic: topic),
    ))
        .then((_) {
      if (mounted) setState(() {});
    });
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
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    ChildTouchTarget(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                    ),
                    Expanded(
                      child: Text(
                        'مهارت زندگی 🧭',
                        textAlign: TextAlign.center,
                        style: AppFonts.vazirmatn(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '۱۰ دنیای روزمره برای کودک ایرانی — آفلاین و بدون تبلیغ',
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: LifeSkillsData.topics.length,
                  itemBuilder: (context, index) {
                    final topic = LifeSkillsData.topics[index];
                    final done = GrowthStore.completedLifeTopics.contains(topic.id);
                    final pts = GrowthStore.lifeSkillPoints[topic.id] ?? 0;
                    return Semantics(
                      button: true,
                      label: topic.title,
                      child: GestureDetector(
                        onTap: () => _open(topic),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                            border: Border.all(
                              color: done ? const Color(0xFF00B894) : AppColors.primary.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(topic.emoji, style: const TextStyle(fontSize: 36)),
                              const SizedBox(height: 8),
                              Text(
                                topic.title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                topic.subtitle,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.vazirmatn(fontSize: 10, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                done ? 'تمام شد ✓  ${PersianDigits.toFa(pts)}' : 'شروع کنیم',
                                style: AppFonts.vazirmatn(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: done ? const Color(0xFF00B894) : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate(delay: (index * 50).ms).fadeIn().scale(begin: const Offset(0.92, 0.92));
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
