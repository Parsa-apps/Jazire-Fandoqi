import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/audio_service.dart';
import '../../core/content_access_policy.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../core/learning_content/children_stories_data.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/child_touch_target.dart';
import '../../shared/widgets/fandoghi_v2.dart';
import '../../shared/widgets/premium_lock_overlay.dart';
import '../shop/full_version_paywall.dart';
import 'story_reader_screen.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📚 STORIES HUB SCREEN — جزیره سکوهای قصه‌خانه فندقی
/// طراحی خلوت، یکدست با تم جزیره اصلی با سکوهای شناور اختصاصی برای هر قصه
/// ═══════════════════════════════════════════════════════════════
class StoriesHubScreen extends StatefulWidget {
  const StoriesHubScreen({super.key});

  @override
  State<StoriesHubScreen> createState() => _StoriesHubScreenState();
}

class _StoriesHubScreenState extends State<StoriesHubScreen> {
  StoryCategoryType _selectedCategory = StoryCategoryType.all;
  bool _hasFullVersion = false;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.disablePersistentPresence();
    _refreshEntitlement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.say(
          'به جزیره قصه‌خانه فندقی خوش اومدی! 📚 روی سکوی هر قصه بزن تا با هم بخونیم!',
          mood: FandoghiMood.excited,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  List<ChildrenStory> get _filteredStories {
    return ChildrenStoriesData.getByCategory(_selectedCategory);
  }

  bool _isLocked(ChildrenStory story) =>
      !_hasFullVersion && !ContentAccessPolicy.isStoryFree(story.id);

  Future<bool> _refreshEntitlement() async {
    final hasFullVersion = await Monetization.hasFullVersion();
    if (mounted && hasFullVersion != _hasFullVersion) {
      setState(() => _hasFullVersion = hasFullVersion);
    }
    return hasFullVersion;
  }

  Future<void> _openStory(ChildrenStory story) async {
    HapticFeedback.lightImpact();
    AudioService.select();
    if (!ContentAccessPolicy.isStoryFree(story.id) &&
        !await Monetization.hasFullVersion()) {
      if (!mounted) return;
      await showFullVersionPaywall(context, featureName: story.title);
      if (!mounted || !await _refreshEntitlement()) return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: '/story/${story.id}'),
        builder: (_) => StoryReaderScreen(story: story),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredStories;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              _buildCategoriesPill(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                  child: Column(
                    children: [
                      _buildHeroIslandBanner(),
                      const SizedBox(height: 18),
                      // سکوهای شناور قصه ها
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 22,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.76,
                        ),
                        itemBuilder: (context, index) {
                          final story = list[index];
                          final locked = _isLocked(story);
                          final isFav = GameData.isStoryFavorite(story.id);

                          return _StoryPlatformItem(
                            story: story,
                            isLocked: locked,
                            isFav: isFav,
                            onTap: () => _openStory(story),
                            onToggleFav: () {
                              HapticFeedback.selectionClick();
                              GameData.toggleStoryFavorite(story.id);
                              setState(() {});
                            },
                          ).animate(delay: (index * 40).ms).fadeIn(duration: 350.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          ChildTouchTarget(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: Colors.white30),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'قصه‌خانه فندقی 📚',
              style: AppFonts.balooBhaijaan2(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              children: [
                const Text('📖', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  'داستان',
                  style: AppFonts.balooBhaijaan2(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPill() {
    final categories = [
      (StoryCategoryType.all, 'همه داستان‌ها', '📚'),
      (StoryCategoryType.friendship, 'دوستی و مهربانی', '🤝'),
      (StoryCategoryType.nature, 'طبیعت و حیوانات', '🌿'),
      (StoryCategoryType.adventure, 'ماجراجویی', '🚀'),
      (StoryCategoryType.morals, 'پندآموز و اخلاقی', '💡'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat.$1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = cat.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white24,
                    width: isSelected ? 1.8 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Text(cat.$3, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      cat.$2,
                      style: AppFonts.balooBhaijaan2(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
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

  Widget _buildHeroIslandBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          const FandoghiV2(size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جزیره داستان‌های صوتی و مصور 📖',
                  style: AppFonts.balooBhaijaan2(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'روی هر سکو بزن تا قصه زیبایش را بشنوی و ورق بزنی.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ STORY PLATFORM ITEM — سکوی شناور اختصاصی برای هر قصه
/// ═══════════════════════════════════════════════════════════════
class _StoryPlatformItem extends StatelessWidget {
  final ChildrenStory story;
  final bool isLocked;
  final bool isFav;
  final VoidCallback onTap;
  final VoidCallback onToggleFav;

  const _StoryPlatformItem({
    required this.story,
    required this.isLocked,
    required this.isFav,
    required this.onTap,
    required this.onToggleFav,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // قاب اصلی قصه با هاله نور و گوشه‌های گرد
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // هاله نور زیر سکو
                Positioned(
                  bottom: -6,
                  left: 12,
                  right: 12,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: story.themeColor.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: story.themeColor.withOpacity(0.6),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // بدنه کارت / پوستر قصه
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B38),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: story.themeColor.withOpacity(0.8),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (story.coverAsset != null)
                        Image.asset(
                          story.coverAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallbackCover(),
                        )
                      else
                        _fallbackCover(),
                      // گرادیان ملایم پایین قاب
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.65),
                            ],
                          ),
                        ),
                      ),
                      // نشانگر تعداد صفحات
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Text(
                            '${story.pages.length} صفحه',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // دکمه علاقه‌مندی
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onToggleFav,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFav ? Colors.redAccent : Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      // نشان قفل در صورت عدم خرید نسخه کامل
                      if (isLocked) const PremiumLockOverlay(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // پایه سکوی سنگی زیر قصه (Stone Platform Base)
          CustomPaint(
            size: const Size(90, 10),
            painter: _PlatformBasePainter(story.themeColor),
          ),
          const SizedBox(height: 4),
          // بنر نام قصه
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.soft,
            ),
            child: Text(
              story.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppFonts.balooBhaijaan2(
                color: const Color(0xFF2D3436),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      decoration: BoxDecoration(gradient: story.gradient),
      child: Center(
        child: Text(story.coverEmoji, style: const TextStyle(fontSize: 48)),
      ),
    );
  }
}

/// نقاش سکوی سنگی زیر هر قصه (طرح جزیره اصلی)
class _PlatformBasePainter extends CustomPainter {
  final Color color;

  _PlatformBasePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // سکوی سنگی لوزی‌شکل
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - 8, h)
      ..lineTo(8, h)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7F8C8D),
            Color(0xFF34495E),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // خط براق لبه بالا
    canvas.drawLine(
      Offset(4, 1),
      Offset(w - 4, 1),
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
