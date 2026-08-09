import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amoozesh_fandoghi/app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import 'package:amoozesh_fandoghi/core/ai_system.dart';
import 'package:amoozesh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:amoozesh_fandoghi/core/fandoghi_coach.dart';
import 'package:amoozesh_fandoghi/core/game_data.dart';
import 'package:amoozesh_fandoghi/features/cartoons/cartoon_player_screen.dart';
import 'package:amoozesh_fandoghi/features/cartoons/widgets/cartoon_rating_dialog.dart';
import 'package:amoozesh_fandoghi/features/profile/sticker_album_screen.dart';
import 'package:amoozesh_fandoghi/shared/widgets/fandoghi_v2.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎬 CARTOON HUB SCREEN — کارتون‌کده و سینما کودک فوق پیشرفته
/// ═══════════════════════════════════════════════════════════════
class CartoonHubScreen extends StatefulWidget {
  const CartoonHubScreen({super.key});

  @override
  State<CartoonHubScreen> createState() => _CartoonHubScreenState();
}

class _CartoonHubScreenState extends State<CartoonHubScreen> {
  CartoonCategoryType _selectedCategory = CartoonCategoryType.all;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  int _featuredIndex = 0;
  bool _onlyFavorites = false;
  late String _suggestedCartoonId;

  @override
  void initState() {
    super.initState();
    _suggestedCartoonId = AI.suggestCartoon();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.say(
          'به کارتون‌کده فندقی خوش اومدی! روی هر کارتون که دوست داری بزن تا تماشا کنیم 🍿🎬',
          mood: FandoghiMood.excited,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Cartoon> get _filteredCartoons {
    var list = CartoonData.getByCategory(_selectedCategory);
    if (_searchQuery.isNotEmpty) {
      list = CartoonData.search(_searchQuery);
    }
    if (_onlyFavorites) {
      list = list.where((c) => GameData.isCartoonFavorite(c.id)).toList();
    }
    return list;
  }

  void _openCartoon(Cartoon cartoon, {int episodeIndex = 0}) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartoonPlayerScreen(
          cartoon: cartoon,
          initialEpisodeIndex: episodeIndex,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _goToGames() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _openStickerAlbum() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StickerAlbumScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featuredCartoons = CartoonData.getFeatured();
    final suggestedCartoon = CartoonData.getCartoonById(_suggestedCartoonId);
    final watchedMins = (GameData.cartoonWatchSeconds / 60).round();
    final currentRank = CartoonRank.currentRank(watchedMins);

    return Scaffold(
      backgroundColor: const Color(0xFF131127),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(currentRank),

            // Main Scrollable Area
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 5-Star Rating Incentive Banner
                  SliverToBoxAdapter(child: _buildRatingBanner()),

                  // VIP Rank Progress Pill
                  SliverToBoxAdapter(child: _buildRankProgressCard(currentRank, watchedMins)),

                  // Featured Carousel (if no active search)
                  if (_searchQuery.isEmpty && !_onlyFavorites)
                    SliverToBoxAdapter(
                      child: _buildFeaturedCarousel(featuredCartoons),
                    ),

                  // AI Recommendation Banner (if exists and no search)
                  if (_searchQuery.isEmpty && !_onlyFavorites && suggestedCartoon != null)
                    SliverToBoxAdapter(
                      child: _buildAiSuggestionCard(suggestedCartoon),
                    ),

                  // Search & Quick Filter Bar
                  SliverToBoxAdapter(child: _buildSearchBar()),

                  // Category Chips
                  SliverToBoxAdapter(child: _buildCategoryChips()),

                  // Cartoon Grid / List
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    sliver: _buildCartoonGrid(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating switch to Games button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildSwitchToGamesFab(),
    );
  }

  Widget _buildTopBar(CartoonRank rank) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back to gateway
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/gateway');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Mascot
          Expanded(
            child: Row(
              children: [
                const Text('🍿', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'کارتون‌کده فندقی',
                  style: AppFonts.vazirmatn(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Sticker Album Button
          GestureDetector(
            onTap: _openStickerAlbum,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.pinkAccent.withOpacity(0.4)),
              ),
              child: const Icon(Icons.auto_awesome_motion_rounded, color: Colors.pinkAccent, size: 20),
            ),
          ),

          // Coins Pill
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
                const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 18),
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

  Widget _buildRankProgressCard(CartoonRank rank, int mins) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: rank.color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Text(rank.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'رتبه شما: ${rank.title}',
              style: TextStyle(color: rank.color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const Spacer(),
            Text(
              '$mins دقیقه تماشا ⏱️',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: GestureDetector(
        onTap: () => CartoonRatingDialog.show(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9F43), Color(0xFFFF5252)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 32))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 800.ms),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'کارتون‌ها رو دوست داری؟',
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'با ثبت ۵ ستاره، ۵۰ سکه هدیه بگیر! 🎁',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'ثبت رای ⭐',
                  style: AppFonts.vazirmatn(
                    color: Colors.deepOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiSuggestionCard(Cartoon cartoon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      child: GestureDetector(
        onTap: () => _openCartoon(cartoon),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cartoon.themeColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: cartoon.gradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(cartoon.coverEmoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'پیشنهاد هوشمند فندقی برای شما',
                          style: TextStyle(
                            color: cartoon.themeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cartoon.title,
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cartoon.themeColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('تماشا ▶', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(List<Cartoon> featured) {
    if (featured.isEmpty) return const SizedBox.shrink();
    final cartoon = featured[_featuredIndex % featured.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: GestureDetector(
        onTap: () => _openCartoon(cartoon),
        child: Container(
          height: 175,
          decoration: BoxDecoration(
            gradient: cartoon.gradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: cartoon.themeColor.withOpacity(0.4),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '🔥 ویژه امروز • ${cartoon.badgeText}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cartoon.title,
                            style: AppFonts.vazirmatn(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cartoon.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.play_arrow_rounded, color: Colors.black87, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      'تماشا کن',
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
                                '${cartoon.episodes.length} قسمت',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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
                        child: Text(
                          cartoon.coverEmoji,
                          style: const TextStyle(fontSize: 74),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .moveY(begin: 0, end: -8, duration: 1800.ms, curve: Curves.easeInOut),
                      ),
                    ),
                  ],
                ),
              ),

              // Slide Dots
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Search Field
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
                  hintText: 'جستجوی کارتون، شخصیت و موضوع...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
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

          // Favorite Filter Toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _onlyFavorites = !_onlyFavorites);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _onlyFavorites ? Colors.redAccent.withOpacity(0.25) : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _onlyFavorites ? Colors.redAccent : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _onlyFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _onlyFavorites ? Colors.redAccent : Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'علاقه‌ها',
                    style: TextStyle(
                      color: _onlyFavorites ? Colors.redAccent : Colors.white70,
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
        itemCount: CartoonData.categories.length,
        itemBuilder: (context, index) {
          final cat = CartoonData.categories[index];
          final isSelected = _selectedCategory == cat.type;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedCategory = cat.type;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
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

  Widget _buildCartoonGrid() {
    final list = _filteredCartoons;

    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 12),
              Text(
                'کارتونی با این مشخصات پیدا نشد!',
                style: AppFonts.vazirmatn(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'می‌تونی دسته‌بندی دیگه‌ای رو انتخاب کنی 🌈',
                style: TextStyle(color: Colors.white38, fontSize: 13),
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
        childAspectRatio: 0.76,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final cartoon = list[index];
            final isFav = GameData.isCartoonFavorite(cartoon.id);

            return GestureDetector(
              onTap: () => _openCartoon(cartoon),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B38),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: cartoon.themeColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cartoon.themeColor.withOpacity(0.15),
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
                      // Header Cover Box
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: cartoon.gradient,
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  cartoon.coverEmoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                              // Favorite Button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    GameData.toggleCartoonFavorite(cartoon.id);
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: isFav ? Colors.redAccent : Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              // Episode Count Badge
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${cartoon.episodes.length} قسمت',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Info Details
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cartoon.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.vazirmatn(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                cartoon.categoryLabel,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${cartoon.rating}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: cartoon.themeColor.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'تماشا ▶',
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
      ),
    );
  }

  Widget _buildSwitchToGamesFab() {
    return GestureDetector(
      onTap: _goToGames,
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
            const Icon(Icons.videogame_asset_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              'ورود به دنیای بازی و آموزش 🎮',
              style: AppFonts.vazirmatn(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -4, duration: 1500.ms);
  }
}
