import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../shared/widgets/child_touch_target.dart';
import '../../shared/widgets/fandoghi_premium.dart';

/// Entry point for the premium content hubs delivered in PR80.
///
/// These screens used to exist as orphaned Dart files: no route or visible
/// gateway action opened them. Keeping the links in one small library makes
/// every content promise discoverable without adding network dependencies.
class LearningLibraryScreen extends StatefulWidget {
  final bool embedded;
  const LearningLibraryScreen({super.key, this.embedded = false});

  @override
  State<LearningLibraryScreen> createState() => _LearningLibraryScreenState();
}

class _LearningLibraryScreenState extends State<LearningLibraryScreen> {
  static const _entries = <_LibraryEntry>[
    _LibraryEntry(
      title: 'دانشنامه حیوانات ایران',
      subtitle: '۳۰ حیوان، زیستگاه و نکته‌های جالب',
      emoji: '🦁',
      route: '/animals',
      color: IslandWorldPalette.foliage,
    ),
    _LibraryEntry(
      title: 'دنیای اعداد',
      subtitle: 'شمارش با سیب و گردو از ۱ تا ۲۰',
      emoji: '🔢',
      route: '/numbers',
      color: IslandWorldPalette.deepOcean,
    ),
    _LibraryEntry(
      title: 'شغل‌های قهرمانانه',
      subtitle: 'با ۲۰ شغل و آدم‌های مفید آشنا شو',
      emoji: '👷',
      route: '/jobs',
      color: IslandWorldPalette.wood,
    ),
    _LibraryEntry(
      title: 'مفاهیم اولیه',
      subtitle: 'فصل‌ها، هوا، شب و روز و اندازه‌ها',
      emoji: '🌈',
      route: '/concepts',
      color: IslandWorldPalette.coral,
    ),
    _LibraryEntry(
      title: 'دنیای احساسات',
      subtitle: 'شناخت احساس و تمرین نفس آرام',
      emoji: '💛',
      route: '/sel',
      color: IslandWorldPalette.rose,
    ),
    _LibraryEntry(
      title: 'مهارت زندگی',
      subtitle: 'ترافیک، بهداشت، پول تومان و ایران',
      emoji: '🧭',
      route: '/life-skills',
      color: IslandWorldPalette.ocean,
    ),
  ];

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.instruction(
          'هر دنیا یک چیز تازه برای یاد گرفتن دارد؛ یکی را انتخاب کن 🌟',
        );
      }
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _open(String route) {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, route).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    const gridCardAspectRatio = 0.88;
    final cardWidth = (MediaQuery.of(context).size.width - 44) / 2;
    final aspectRatioExtent = cardWidth / gridCardAspectRatio;
    final cardMainAxisExtent =
        aspectRatioExtent < 190 ? 190.0 : aspectRatioExtent;

    return Scaffold(
      backgroundColor: IslandWorldPalette.paper,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  gradient: IslandWorldGradients.sky,
                  borderRadius:
                      BorderRadius.circular(IslandWorldMetrics.cardRadius),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.84),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: IslandWorldPalette.deepOcean.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (widget.embedded)
                          const SizedBox(width: 64)
                        else
                          ChildTouchTarget(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: IslandWorldPalette.deepOcean,
                              size: 28,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            widget.embedded
                                ? 'کوله‌پشتی یادگیری 🎒'
                                : 'کتابخانه یادگیری 📚',
                            textAlign: TextAlign.center,
                            style: AppFonts.kids(
                              color: IslandWorldPalette.ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 64),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FandoghiPremium(
                      size: 64,
                      mood: FandoghiMood.excited,
                      showParticles: false,
                      animated: !animationsDisabled,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'یادگیری پریمیوم، آفلاین و کودکانه',
                      textAlign: TextAlign.center,
                      style: AppFonts.vazirmatn(
                        color: IslandWorldPalette.deepOcean,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: cardMainAxisExtent,
                ),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  final card = _LibraryCard(
                    entry: entry,
                    onTap: () => _open(entry.route),
                  );
                  if (animationsDisabled) return card;

                  return card
                      .animate(delay: (index * 70).ms)
                      .fadeIn(duration: IslandWorldMetrics.routeTransition)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        duration: IslandWorldMetrics.routeTransition,
                        curve: Curves.easeOutBack,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryEntry {
  final String title;
  final String subtitle;
  final String emoji;
  final String route;
  final Color color;

  const _LibraryEntry({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.route,
    required this.color,
  });
}

class _LibraryCard extends StatelessWidget {
  final _LibraryEntry entry;
  final VoidCallback onTap;

  const _LibraryCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: entry.title,
      onTap: onTap,
      // متن‌های داخل کارت نباید به برچسب دکمه اضافه شوند؛ برچسب دقیقاً
      // عنوان کارت می‌ماند (مثل خانه‌های نوار ناوبری).
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: IslandWorldPalette.paper,
              borderRadius: BorderRadius.circular(IslandWorldMetrics.cardRadius),
              border: Border.all(
                color: entry.color.withOpacity(0.36),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: entry.color.withOpacity(0.13),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: entry.color.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(entry.emoji, style: const TextStyle(fontSize: 34)),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.kids(
                    color: IslandWorldPalette.ink,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    color: IslandWorldPalette.mutedInk,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.arrow_back_rounded,
                  color: entry.color,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
