import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/audio_service.dart';
import '../../core/content_access_policy.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/growth/growth.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/child_touch_target.dart';
import '../shop/content_lock.dart';
import 'life_skills_game.dart';

class LifeSkillsHubScreen extends StatefulWidget {
  const LifeSkillsHubScreen({super.key});

  @override
  State<LifeSkillsHubScreen> createState() => _LifeSkillsHubScreenState();
}

class _LifeSkillsHubScreenState extends State<LifeSkillsHubScreen> {
  /// نیمهٔ دومِ دنیاها فقط با نسخهٔ کامل باز می‌شود. تا وقتی وضعیت خرید
  /// مشخص نشده، همهٔ دنیاهای پولی قفل‌اند (fail-closed) — حالتِ پیش‌فرضِ
  /// «باز» یعنی نشتِ محتوای پولی پیش از پاسخِ فروشگاه.
  bool _hasFullVersion = false;

  void _syncFullVersionAccess() {
    if (!mounted) return;
    final has = Monetization.accessStatus.value.isVerified;
    if (has != _hasFullVersion) setState(() => _hasFullVersion = has);
  }

  @override
  void initState() {
    super.initState();
    Monetization.accessStatus.addListener(_syncFullVersionAccess);
    FandoghiCoach.enablePersistentPresence();
    ActivityTracker.recordOpen(route: '/life-skills', title: 'مهارت زندگی', skill: 'concepts');
    _refreshEntitlement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.instruction(
          'این‌جا زندگی واقعی را تمرین می‌کنیم: خیابان، بهداشت، پول و ایران خودمان 🧭',
        );
      }
    });
  }

  Future<bool> _refreshEntitlement() async {
    final hasFullVersion = await Monetization.hasFullVersion();
    if (mounted && hasFullVersion != _hasFullVersion) {
      setState(() => _hasFullVersion = hasFullVersion);
    }
    return hasFullVersion;
  }

  /// قفلِ مؤثرِ یک دنیا: دقیقاً همان چیزی که هنگام لمس اتفاق می‌افتد.
  bool _isLocked(LifeSkillTopic topic) =>
      !_hasFullVersion && !ContentAccessPolicy.isLifeSkillFree(topic.id);

  @override
  void dispose() {
    Monetization.accessStatus.removeListener(_syncFullVersionAccess);
    FandoghiCoach.clear();
    super.dispose();
  }

  Future<void> _open(LifeSkillTopic topic) async {
    HapticFeedback.selectionClick();
    AudioService.select();

    // ⚠️ این صفحه خودش درِ ورودِ همهٔ دنیاهاست؛ مسیر deep-link
    // `/life-skills/<id>` در main.dart گیت شده، ولی این هاب قبلاً مستقیم
    // `LifeSkillsGame` را push می‌کرد و گیت را دور می‌زد — یعنی هر ۱۰ دنیا
    // بدون هیچ پرداختی باز بود. حالا همان سیاستِ مرکزی اینجا هم اعمال می‌شود.
    final allowed = await ensureContentAccess(
      context,
      featureName: topic.title,
      isFree: ContentAccessPolicy.isLifeSkillFree(topic.id),
    );
    if (!allowed) return;
    if (!mounted) return;
    await _refreshEntitlement();
    if (!mounted) return;

    await Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (_) => LifeSkillsGame(topic: topic),
    ));
    if (mounted) setState(() {});
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
                  '۱۰ دنیای روزمره برای کودک ایرانی — ${PersianDigits.toFa(ContentAccessPolicy.freeLifeSkillCount)} دنیا رایگان و بقیه با نسخهٔ کامل — آفلاین و بدون تبلیغ',
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
                    final locked = _isLocked(topic);
                    return Semantics(
                      button: true,
                      label: locked ? '${topic.title} — قفل' : topic.title,
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
                          child: LockedCardOverlay(
                            locked: locked,
                            badgeSize: 26,
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
                                  locked
                                      ? 'با نسخهٔ کامل 🔒'
                                      : (done ? 'تمام شد ✓  ${PersianDigits.toFa(pts)}' : 'شروع کنیم'),
                                  style: AppFonts.vazirmatn(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: locked
                                        ? const Color(0xFF8D6E63)
                                        : (done ? const Color(0xFF00B894) : AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
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
