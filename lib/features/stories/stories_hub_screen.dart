import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/app_theme.dart';
import '../../core/audio_service.dart';
import '../../core/content_access_policy.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../core/learning_content/children_stories_data.dart';
import '../../core/literacy/decodable_stories.dart';
import '../../core/monetization.dart';
import '../home/widgets/island_map/island_map_background.dart';
import '../shop/full_version_paywall.dart';
import 'story_reader_screen.dart';

/// قصه‌خانهٔ جزیره‌ای؛ یک انتخاب ساده، بزرگ و یکدست برای کودکان خردسال.
///
/// هر داستان روی سکوی مستقل خودش قرار دارد. جستجو، فیلتر، بنر، گردونه و
/// کارت‌های تو‌در‌تو عمداً حذف شده‌اند تا کودک فقط یک تصمیم روشن داشته باشد:
/// لمس سکوی قصه‌ای که دوست دارد.
class StoriesHubScreen extends StatefulWidget {
  const StoriesHubScreen({super.key});

  @override
  State<StoriesHubScreen> createState() => _StoriesHubScreenState();
}

class _StoriesHubScreenState extends State<StoriesHubScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _floatController;

  double _scrollOffset = 0;
  bool _hasFullVersion = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _scrollController.addListener(_onScroll);
    _refreshEntitlement();

    // خود فندقی در هدر حضور دارد؛ حباب سراسری عمداً خاموش می‌ماند تا
    // صفحه برای کودک خردسال خلوت و متمرکز باشد.
    FandoghiCoach.disablePersistentPresence();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final next = _scrollController.hasClients ? _scrollController.offset : 0.0;
    if ((next - _scrollOffset).abs() > 1.5) {
      setState(() => _scrollOffset = next);
    }
  }

  double get _scrollProgress {
    if (!_scrollController.hasClients) return 0;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return 0;
    return (_scrollController.offset / max).clamp(0.0, 1.0);
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

    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: '/story/${story.id}'),
        builder: (_) => StoryReaderScreen(story: story),
      ),
    );
    if (mounted) setState(() {});
  }

  void _goBack() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stories = ChildrenStoriesData.allStories;
    final completedCount =
        stories.where((story) => GameData.hasCompletedStory(story.id)).length;
    final cycle = AppTheme.currentCycle;

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: IslandMapBackground(
              scrollOffset: _scrollOffset,
              cycle: cycle,
              progress: _scrollProgress * 0.62,
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final topInset = MediaQuery.paddingOf(context).top + 82;
                return SingleChildScrollView(
                  key: const ValueKey('story_island_scroll'),
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.only(
                    top: topInset,
                    bottom: MediaQuery.paddingOf(context).bottom + 34,
                  ),
                  child: _StoryIslandMap(
                    width: constraints.maxWidth,
                    stories: stories,
                    floatAnimation: _floatController,
                    isLocked: _isLocked,
                    onStoryTap: _openStory,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: _StoryTopBar(
                  completedCount: completedCount,
                  totalCount: stories.length,
                  onBack: _goBack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryTopBar extends StatelessWidget {
  const _StoryTopBar({
    required this.completedCount,
    required this.totalCount,
    required this.onBack,
  });

  final int completedCount;
  final int totalCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'قصه‌خانه فندقی، $completedCount قصه از $totalCount قصه خوانده شده',
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF8EA).withOpacity(0.94),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFFFC857), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B3B1E).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              key: const ValueKey('stories_back'),
              onPressed: onBack,
              tooltip: 'بازگشت',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF7E57C2),
                foregroundColor: Colors.white,
                minimumSize: const Size(48, 48),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 25),
            ),
            const SizedBox(width: 9),
            ClipOval(
              child: Image.asset(
                'assets/mascot/fandoghi_baby.webp',
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'قصه‌خانه',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.kids(
                  color: const Color(0xFF3B2B52),
                  fontSize: 23,
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 66),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7DF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF8BC34A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: Color(0xFF558B2F),
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$completedCount/$totalCount',
                    style: AppFonts.kids(
                      color: const Color(0xFF3E6D21),
                      fontSize: 15,
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
}

class _StoryIslandMap extends StatelessWidget {
  const _StoryIslandMap({
    required this.width,
    required this.stories,
    required this.floatAnimation,
    required this.isLocked,
    required this.onStoryTap,
  });

  static const double _stepHeight = 238;
  static const double _introHeight = 168;

  final double width;
  final List<ChildrenStory> stories;
  final Animation<double> floatAnimation;
  final bool Function(ChildrenStory story) isLocked;
  final ValueChanged<ChildrenStory> onStoryTap;

  @override
  Widget build(BuildContext context) {
    final mapHeight = _introHeight + stories.length * _stepHeight + 32;
    final platformWidth = (width * 0.60).clamp(196.0, 270.0);

    return SizedBox(
      width: width,
      height: mapHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _StoryTrailPainter(
                  storyCount: stories.length,
                  stepHeight: _stepHeight,
                  introHeight: _introHeight,
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            left: 20,
            right: 20,
            child: _GuideBubble(storyCount: stories.length),
          ),
          for (var index = 0; index < stories.length; index++)
            Positioned(
              key: ValueKey('story_platform_$index'),
              top: _introHeight + index * _stepHeight,
              left: index.isEven ? 8 : null,
              right: index.isOdd ? 8 : null,
              child: _StoryPlatform(
                index: index,
                story: stories[index],
                width: platformWidth,
                floatAnimation: floatAnimation,
                locked: isLocked(stories[index]),
                completed: GameData.hasCompletedStory(stories[index].id),
                onTap: () => onStoryTap(stories[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _DecodableTodayCard extends StatelessWidget {
  const _DecodableTodayCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final story = DecodableStories.forToday();
    final unlocked = DecodableStories.isUnlocked(story);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('decodable_today_card'),
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFB300), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(story.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unlocked ? 'امروز خودت بخوان' : 'بشنو؛ بعد از نوشتن بخوان',
                      style: AppFonts.kids(
                        color: const Color(0xFF6D4C41),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      story.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.kids(
                        color: const Color(0xFF3E3150),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.menu_book_rounded, color: Color(0xFFE65100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideBubble extends StatelessWidget {
  const _GuideBubble({required this.storyCount});

  final int storyCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFC857), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'یکی از $storyCount سکوی قصه را لمس کن! ✨',
          textAlign: TextAlign.center,
          style: AppFonts.kids(
            color: const Color(0xFF4B3565),
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}

class _StoryPlatform extends StatefulWidget {
  const _StoryPlatform({
    required this.index,
    required this.story,
    required this.width,
    required this.floatAnimation,
    required this.locked,
    required this.completed,
    required this.onTap,
  });

  final int index;
  final ChildrenStory story;
  final double width;
  final Animation<double> floatAnimation;
  final bool locked;
  final bool completed;
  final VoidCallback onTap;

  @override
  State<_StoryPlatform> createState() => _StoryPlatformState();
}

class _StoryPlatformState extends State<_StoryPlatform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.width * 0.84;
    final coverSize = widget.width * 0.39;
    final phaseOffset = widget.index * 0.13;

    return Semantics(
      button: true,
      label: '${widget.story.title}${widget.locked ? '، قفل' : ''}${widget.completed ? '، خوانده شده' : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pressController.forward(),
        onTapCancel: () => _pressController.reverse(),
        onTapUp: (_) => _pressController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            widget.floatAnimation,
            _pressController,
          ]),
          builder: (context, child) {
            final phase =
                (widget.floatAnimation.value + phaseOffset) % 1.0;
            final bob = math.sin(phase * math.pi * 2);
            return Transform.translate(
              offset: Offset(0, bob * 6),
              child: Transform.rotate(
                angle: bob * 0.01 * (widget.index.isEven ? 1 : -1),
                child: Transform.scale(
                  scale: 1 - _pressController.value * 0.07,
                  child: child,
                ),
              ),
            );
          },
          child: SizedBox(
            width: widget.width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/theme_map/island_blank.png',
                    width: widget.width,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
                Positioned(
                  top: 4,
                  child: Container(
                    width: coverSize,
                    height: coverSize,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: widget.completed
                            ? const Color(0xFF6FCF67)
                            : const Color(0xFFFFC857),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.story.themeColor.withOpacity(0.35),
                          blurRadius: 13,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(child: _cover()),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: widget.width * 0.09,
                  child: _numberBadge(),
                ),
                if (widget.completed)
                  Positioned(
                    top: coverSize * 0.72,
                    left: widget.width * 0.25,
                    child: _statusBadge(
                      icon: Icons.check_rounded,
                      color: const Color(0xFF43A047),
                      label: 'خواندم',
                    ),
                  ),
                if (widget.locked)
                  Positioned(
                    top: coverSize * 0.73,
                    right: widget.width * 0.23,
                    child: _statusBadge(
                      icon: Icons.lock_rounded,
                      color: const Color(0xFF7E57C2),
                      label: 'قفل',
                    ),
                  ),
                Positioned(
                  left: -18,
                  right: -18,
                  bottom: height * 0.03,
                  child: Center(child: _titlePlate()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cover() {
    final asset = widget.story.coverAsset;
    if (asset == null) return _emojiCover();
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => _emojiCover(),
    );
  }

  Widget _emojiCover() {
    return ColoredBox(
      color: widget.story.themeColor.withOpacity(0.24),
      child: Center(
        child: Text(
          widget.story.coverEmoji,
          style: TextStyle(fontSize: widget.width * 0.20),
        ),
      ),
    );
  }

  Widget _numberBadge() {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        '${widget.index + 1}',
        style: AppFonts.kids(
          color: const Color(0xFF5D4037),
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _statusBadge({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppFonts.kids(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _titlePlate() {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.width + 32),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        widget.story.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppFonts.kids(
          color: const Color(0xFF3E3150),
          fontSize: 16,
          height: 1.15,
        ),
      ),
    );
  }
}

class _StoryTrailPainter extends CustomPainter {
  const _StoryTrailPainter({
    required this.storyCount,
    required this.stepHeight,
    required this.introHeight,
  });

  final int storyCount;
  final double stepHeight;
  final double introHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (storyCount < 2) return;

    final path = Path();
    for (var index = 0; index < storyCount; index++) {
      final x = index.isEven ? size.width * 0.35 : size.width * 0.65;
      final y = introHeight + index * stepHeight + stepHeight * 0.50;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        final previousX = index.isEven
            ? size.width * 0.65
            : size.width * 0.35;
        final previousY = y - stepHeight;
        path.cubicTo(
          previousX,
          previousY + stepHeight * 0.46,
          x,
          y - stepHeight * 0.46,
          x,
          y,
        );
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFD166).withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _StoryTrailPainter oldDelegate) =>
      oldDelegate.storyCount != storyCount ||
      oldDelegate.stepHeight != stepHeight ||
      oldDelegate.introHeight != introHeight;
}
