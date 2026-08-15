import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/content_access_policy.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../core/learning_content/children_stories_data.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/premium_lock_overlay.dart';
import '../shop/full_version_paywall.dart';
import 'story_reader_screen.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📚 STORIES HUB SCREEN — قصه‌خانه و داستان‌های کودکانه (نسخه پیشرفته)
/// بخش جدید شامل ۱۰ داستان کامل، مصور، فیلتر علاقه‌مندی‌ها و پاداش مطالعه
/// ═══════════════════════════════════════════════════════════════
class StoriesHubScreen extends StatefulWidget {
  const StoriesHubScreen({super.key});

  @override
  State<StoriesHubScreen> createState() => _StoriesHubScreenState();
}

class _StoriesHubScreenState extends State<StoriesHubScreen> {
  StoryCategoryType _selectedCategory = StoryCategoryType.all;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  int _featuredIndex = 0;
  bool _onlyFavorites = false;
  bool _hasFullVersion = false;

  @override
  void initState() {
    super.initState();
    // فندقی فقط در بخش بازی/یادگیری حضور دارد.
    FandoghiCoach.disablePersistentPresence();
    _refreshEntitlement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.say(
          'یه داستان قشنگ انتخاب کن تا با هم بخونیم 📚✨',
          mood: FandoghiMood.excited,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ChildrenStory> get _filteredStories {
    var list = ChildrenStoriesData.getByCategory(_selectedCategory);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((s) {
        return s.title.toLowerCase().contains(q) ||
            s.subtitle.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q) ||
            s.moralMessage.toLowerCase().contains(q);
      }).toList();
    }
    if (_onlyFavorites) {
      list = list.where((s) => GameData.isStoryFavorite(s.id)).toList();
    }
    return list;
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
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            settings: RouteSettings(name: '/story/${story.id}'),
            builder: (_) => StoryReaderScreen(story: story),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    final featuredStories = ChildrenStoriesData.getFeaturedStories();
    final completedCount = ChildrenStoriesData.allStories
        .where((s) => GameData.hasCompletedStory(s.id))
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF131127),
      body: SafeArea(
        child: Column(
          children: [
            // ۱. نوار بالای صفحه
            _buildTopBar(completedCount),

            // ۲. ناحیه اسکرول شونده اصلی
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // بنر خوش‌آمدگویی و پاداش
                  SliverToBoxAdapter(
                      child: _buildWelcomeBanner(completedCount)),

                  // گردونه داستان‌های ویژه (در صورت عدم جستجو یا فیلتر)
                  if (_searchQuery.isEmpty && !_onlyFavorites)
                    SliverToBoxAdapter(
                      child: _buildFeaturedCarousel(featuredStories),
                    ),

                  // نوار جستجو و فیلتر علاقه‌مندی‌ها
                  SliverToBoxAdapter(child: _buildSearchBar()),

                  // چیپ‌های دسته‌بندی موضوعی
                  SliverToBoxAdapter(child: _buildCategoryChips()),

                  // شبکه کارت‌های داستان
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    sliver: _buildStoryGrid(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildSwitchToGamesFab(),
    );
  }

  Widget _buildTopBar(int completedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Row(
              children: [
                const Text('📚', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'قصه‌خانه فندقی',
                  style: AppFonts.vazirmatn(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // شمارنده داستان‌های خوانده‌شده
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.greenAccent, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$completedCount / ${ChildrenStoriesData.allStories.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // شمارنده سکه
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${GameData.coins}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(int completedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5C6BC0), Color(0xFF7E57C2)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('📖', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '۱۰ داستان کودکانه و مصور',
                    style: AppFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'با کلمات طلایی، مسابقه درک مطلب و قصه شب 🌙 هر داستان ۵ ستاره و ۲۵ سکه جایزه دارد!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(List<ChildrenStory> featured) {
    if (featured.isEmpty) return const SizedBox.shrink();
    final story = featured[_featuredIndex % featured.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: GestureDetector(
        onTap: () => _openStory(story),
        child: Container(
          height: 185,
          decoration: BoxDecoration(
            gradient: story.gradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: story.themeColor.withOpacity(0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '🔥 داستان ویژه • ${story.categoryLabel}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            story.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.vazirmatn(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            story.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.menu_book_rounded,
                                        color: Colors.black87, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'بخوانیم',
                                      style: AppFonts.vazirmatn(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${story.pages.length} صفحه • ${story.readingTime}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Container(
                          height: 135,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.55), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: story.coverAsset != null
                                ? Image.asset(
                                    story.coverAsset!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildEmojiCover(story),
                                  )
                                : _buildEmojiCover(story),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .moveY(
                                begin: 0,
                                end: -5,
                                duration: 1800.ms,
                                curve: Curves.easeInOut),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(featured.length, (i) {
                    final isSel = i == (_featuredIndex % featured.length);
                    return GestureDetector(
                      onTap: () => setState(() => _featuredIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSel ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSel ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (_isLocked(story)) const PremiumLockOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiCover(ChildrenStory story) {
    return Container(
      color: story.themeColor.withOpacity(0.3),
      alignment: Alignment.center,
      child: Text(
        story.coverEmoji,
        style: const TextStyle(fontSize: 54),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'جستجو در عنوان یا پند داستان‌ها...',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Colors.white54, size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: Colors.white54, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // دکمه فیلتر علاقه‌مندی‌ها
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              AudioService.tap();
              setState(() => _onlyFavorites = !_onlyFavorites);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _onlyFavorites
                    ? Colors.redAccent.withOpacity(0.25)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      _onlyFavorites ? Colors.redAccent : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _onlyFavorites
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _onlyFavorites ? Colors.redAccent : Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'علاقه‌ها',
                    style: TextStyle(
                      color: _onlyFavorites
                          ? Colors.redAccent
                          : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ChildrenStoriesData.categories.length,
        itemBuilder: (context, index) {
          final cat = ChildrenStoriesData.categories[index];
          final isSelected = _selectedCategory == cat.type;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              AudioService.tap();
              setState(() => _selectedCategory = cat.type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? cat.color : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? Colors.white38 : Colors.white12,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: cat.color.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    cat.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryGrid() {
    final list = _filteredStories;

    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 12),
              Text(
                'داستانی با این موضوع پیدا نشد!',
                style: AppFonts.vazirmatn(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final story = list[index];
          final isCompleted = GameData.hasCompletedStory(story.id);
          final isFav = GameData.isStoryFavorite(story.id);

          return GestureDetector(
            onTap: () => _openStory(story),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B38),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isCompleted
                      ? Colors.greenAccent.withOpacity(0.5)
                      : story.themeColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: story.themeColor.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (story.coverAsset != null)
                            Image.asset(
                              story.coverAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildEmojiCover(story),
                            )
                          else
                            _buildEmojiCover(story),

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1E1B38),
                                    const Color(0xFF1E1B38).withOpacity(0.0),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),

                          // دکمه لایک داستان در گوشه بالا سمت چپ
                          Positioned(
                            top: 8,
                            left: 8,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                final wasFav = isFav;
                                GameData.toggleStoryFavorite(story.id);
                                if (!wasFav) AudioService.coin();
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isFav ? Colors.redAccent : Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),

                          if (isCompleted)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'خوانده‌شده',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          Positioned(
                            bottom: 6,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${story.pages.length} صفحه مصور',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (_isLocked(story))
                            const PremiumLockOverlay(),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${story.coverEmoji} ${story.title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.vazirmatn(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              story.categoryLabel,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '⏱️ ${story.readingTime}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: story.themeColor.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'بخوانیم 📖',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
        },
        childCount: list.length,
      ),
    );
  }

  Widget _buildSwitchToGamesFab() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed('/gateway'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              'بازگشت به جزیره 🏝️',
              style: AppFonts.vazirmatn(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -4, duration: 1500.ms);
  }
}
