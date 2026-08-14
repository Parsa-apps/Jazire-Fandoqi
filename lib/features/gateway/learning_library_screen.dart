import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/content_access.dart';
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
      color: Color(0xFF00B894),
    ),
    _LibraryEntry(
      title: 'دنیای اعداد',
      subtitle: 'شمارش با سیب و گردو از ۱ تا ۲۰',
      emoji: '🔢',
      route: '/numbers',
      color: Color(0xFFEF6C00),
    ),
    _LibraryEntry(
      title: 'شغل‌های قهرمانانه',
      subtitle: 'با ۲۰ شغل و آدم‌های مفید آشنا شو',
      emoji: '👷',
      route: '/jobs',
      color: Color(0xFF1976D2),
    ),
    _LibraryEntry(
      title: 'مفاهیم اولیه',
      subtitle: 'فصل‌ها، هوا، شب و روز و اندازه‌ها',
      emoji: '🌈',
      route: '/concepts',
      color: Color(0xFFFF8E53),
    ),
    _LibraryEntry(
      title: 'دنیای احساسات',
      subtitle: 'شناخت احساس و تمرین نفس آرام',
      emoji: '💛',
      route: '/sel',
      color: Color(0xFFFF6B6B),
    ),
    _LibraryEntry(
      title: 'مهارت زندگی',
      subtitle: 'ترافیک، بهداشت، پول تومان و ایران',
      emoji: '🧭',
      route: '/life-skills',
      color: Color(0xFF00897B),
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
                      if (!widget.embedded) ...[
                        ChildTouchTarget(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          widget.embedded ? 'کوله‌پشتی یادگیری 🎒' : 'کتابخانه یادگیری 📚',
                          textAlign: TextAlign.center,
                          style: AppFonts.vazirmatn(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (!widget.embedded) const SizedBox(width: 32),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              const FandoghiPremium(
                size: 64,
                mood: FandoghiMood.excited,
                showParticles: false,
              ),
              const SizedBox(height: 8),
              Text(
                'یادگیری پریمیوم، آفلاین و کودکانه',
                style: AppFonts.vazirmatn(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return _LibraryCard(
                      entry: entry,
                      locked: !ContentAccess.isRouteUnlocked(entry.route),
                      onTap: () => _open(entry.route),
                    ).animate(delay: (index * 70).ms).fadeIn(duration: 350.ms).scale(
                          begin: const Offset(0.9, 0.9),
                          curve: Curves.easeOutBack,
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

  /// در نسخهٔ رایگان این دنیا قفل است (گیت واقعی روی خودِ مسیر است؛
  /// این فقط نشانهٔ بصری برای والد و کودک است).
  final bool locked;

  const _LibraryCard({
    required this.entry,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: entry.title,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: entry.color.withOpacity(0.45), width: 2),
            boxShadow: AppShadows.colored(entry.color, opacity: 0.22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: entry.color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(entry.emoji, style: const TextStyle(fontSize: 36)),
              ),
              const SizedBox(height: 10),
              Text(
                entry.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.vazirmatn(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                entry.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.vazirmatn(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              if (locked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(color: const Color(0xFFFFC107)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded,
                          size: 12, color: Color(0xFF8D6E00)),
                      const SizedBox(width: 4),
                      Text(
                        'نسخه کامل',
                        style: AppFonts.vazirmatn(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF8D6E00),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(Icons.arrow_back_rounded, color: entry.color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
