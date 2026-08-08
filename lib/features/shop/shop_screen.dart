import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/premium_animations.dart';
import '../home/widgets/premium_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import '../../core/game_data.dart';
import 'painters/coin_rain_painter.dart';

/// ═══════════════════════════════════════════════
/// 🏪 SHOP SCREEN — Professional Store
/// Categories, items, purchase animations
/// ═══════════════════════════════════════════════
class ShopScreen extends StatefulWidget {
  final bool embedded;

  const ShopScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<ShopScreen> createState() => _ShopState();
}

class _ShopState extends State<ShopScreen>
    with TickerProviderStateMixin {
  int _selectedCategory = 0;
  late AnimationController _purchaseCtrl;
  late AnimationController _coinBounceCtrl;
  late AnimationController _glowCtrl;
  bool _showCoinRain = false;
  String _lastPurchasedItem = '';
  int _lastPurchasePrice = 0;

  // Shop categories
  final _categories = [
    _Category('🎨', 'استیکرها', const Color(0xFF6C5CE7)),
    _Category('😎', 'آواتارها', const Color(0xFF00CEC9)),
    _Category('🌟', 'آیتم‌ها', const Color(0xFFFFD700)),
    _Category('🎁', 'ویژه', const Color(0xFFE17055)),
  ];

  // Shop items by category
  final Map<int, List<ShopItem>> _items = {
    0: [ // Stickers
      ShopItem('sticker_star', '⭐', 'ستاره طلایی', 50, 'استیکر ستاره درخشان'),
      ShopItem('sticker_heart', '❤️', 'قلب قرمز', 40, 'قلب عاشقانه'),
      ShopItem('sticker_rainbow', '🌈', 'رنگین‌کمان', 80, 'رنگین‌کمان زیبا'),
      ShopItem('sticker_crown', '👑', 'تاج طلایی', 120, 'تاج پادشاهی'),
      ShopItem('sticker_rocket', '🚀', 'موشک فضایی', 100, 'موشک آماده پرتاب'),
      ShopItem('sticker_unicorn', '🦄', 'تک‌شاخ', 150, 'تک‌شاخ جادویی'),
    ],
    1: [ // Avatars
      ShopItem('avatar_superhero', '🦸', 'قهرمان', 200, 'آواتار قهرمانی'),
      ShopItem('avatar_wizard', '🧙', 'جادوگر', 180, 'آواتار جادوگر'),
      ShopItem('avatar_astronaut', '🧑‍🚀', 'فضانورد', 250, 'آواتار فضانورد'),
      ShopItem('avatar_artist', '🧑‍🎨', 'هنرمند', 160, 'آواتار هنرمند'),
      ShopItem('avatar_scientist', '🧑‍🔬', 'دانشمند', 220, 'آواتار دانشمند'),
    ],
    2: [ // Powers
      ShopItem('power_double', '⚡', 'نشان برق', 300, 'یک آیتم درخشان برای کلکسیون'),
      ShopItem('power_shield', '🛡️', 'نشان محافظ', 200, 'نشان شجاعت برای پروفایل'),
      ShopItem('power_hint', '💡', 'لامپ فکری', 100, 'آیتم بامزه برای کلکسیون'),
      ShopItem('power_slow', '🐌', 'حلزون بامزه', 150, 'یک دوست کوچک و آرام'),
    ],
    3: [ // Special
      ShopItem('special_theme_night', '🌙', 'تم شب', 400, 'پس‌زمینه آسمان شب'),
      ShopItem('special_theme_ocean', '🌊', 'تم اقیانوس', 400, 'پس‌زمینه اقیانوس'),
      ShopItem('special_fandoghi_hat', '🎩', 'کلاه فندقی', 350, 'کلاه شیک برای فندقی'),
      ShopItem('special_confetti', '🎊', 'جعبه جشن', 500, 'یک آیتم شاد برای کلکسیون'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _purchaseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _coinBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    GameData.changes.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GameData.changes.removeListener(_onDataChanged);
    _purchaseCtrl.dispose();
    _coinBounceCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _purchaseItem(ShopItem item) {
    if (GameData.coins < item.price) {
      _showSnackBar('سکه‌ت کافی نیست! 😅', Colors.red);
      return;
    }
    if (GameData.hasItem(item.id)) {
      _showSnackBar('قبلاً خریدی! ✓', Colors.orange);
      return;
    }

    // Deduct and persist atomically. The return value protects against a
    // double tap or a stale modal opened before another purchase.
    if (!GameData.buyItem(item.id, item.price)) {
      _showSnackBar('این آیتم دیگر قابل خرید نیست.', Colors.orange);
      return;
    }
    HapticFeedback.heavyImpact();

    setState(() {
      _lastPurchasedItem = item.emoji;
      _lastPurchasePrice = item.price;
      _showCoinRain = true;
    });

    // Play purchase animation
    _purchaseCtrl.forward(from: 0);
    _coinBounceCtrl.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _showCoinRain = false);
    });

    _showSnackBar('${item.name} خریداری شد! 🎉', const Color(0xFF00B894));
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppFonts.vazirmatn(fontWeight: FontWeight.w700)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: Stack(
          children: [
            // Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                _buildHeader(),

                // Coin balance
                SliverToBoxAdapter(child: _buildCoinBalance()),

                // Categories
                SliverToBoxAdapter(child: _buildCategories()),

                // Items grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: _buildItemsGrid(),
                ),
              ],
            ),

            // Coin rain overlay
            if (_showCoinRain)
              AnimatedBuilder(
                animation: _purchaseCtrl,
                builder: (_, __) {
                  return CustomPaint(
                    painter: CoinRainPainter(
                      progress: _purchaseCtrl.value,
                      center: Offset(
                        MediaQuery.of(context).size.width / 2,
                        MediaQuery.of(context).size.height / 2,
                      ),
                    ),
                    size: Size.infinite,
                  );
                },
              ),

            // Purchase success overlay
            if (_showCoinRain) _buildPurchaseOverlay(),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ─────────────────────────────────
  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A2E), Colors.transparent],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (!widget.embedded)
                    _glassBtn(Icons.arrow_back_rounded, () => Navigator.pop(context))
                  else
                    const SizedBox(width: 44),
                  const Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🏪 فروشگاه',
                        style: AppFonts.vazirmatn(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        '${_items.values.expand((e) => e).length} آیتم',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildCoinDisplay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── COIN BALANCE ───────────────────────────
  Widget _buildCoinBalance() {
    return AnimatedBuilder(
      animation: _coinBounceCtrl,
      builder: (_, __) {
        final bounce = 1.0 + sin(_coinBounceCtrl.value * pi) * 0.1;
        return Transform.scale(
          scale: bounce,
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('💰', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سکه‌های شما',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${GameData.coins}',
                        style: AppFonts.exo2(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'بازی کن و سکه بگیر! 🎮',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3);
  }

  // ─── CATEGORIES ─────────────────────────────
  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedCategory = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? cat.color.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? cat.color.withOpacity(0.5)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white60,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  // ─── ITEMS GRID ─────────────────────────────
  Widget _buildItemsGrid() {
    final items = _items[_selectedCategory] ?? [];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => _buildItemCard(items[i], i),
        childCount: items.length,
      ),
    );
  }

  // ─── ITEM CARD ──────────────────────────────
  Widget _buildItemCard(ShopItem item, int index) {
    final owned = GameData.hasItem(item.id);
    final canAfford = GameData.coins >= item.price;
    final catColor = _categories[_selectedCategory].color;

    return PremiumAnimations.premiumCard(
      onTap: () => _showItemDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: owned
              ? const Color(0xFF00B894).withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: owned
                ? const Color(0xFF00B894).withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: catColor.withOpacity(0.05),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoji
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          item.emoji,
                          style: TextStyle(
                            fontSize: owned ? 36 : 32,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Name
                    Text(
                      item.name,
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      item.desc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Price / Owned
                    if (owned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B894).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF00B894), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'مال توئه!',
                              style: TextStyle(
                                color: Color(0xFF00B894),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: canAfford
                              ? const Color(0xFFFFD700).withOpacity(0.2)
                              : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '💰',
                              style: TextStyle(fontSize: canAfford ? 14 : 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.price}',
                              style: TextStyle(
                                color: canAfford
                                    ? const Color(0xFFFFD700)
                                    : Colors.red.shade300,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Owned badge
              if (owned)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate(
          delay: Duration(milliseconds: 100 * index),
        )
        .fadeIn()
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }
    final owned = GameData.hasItem(item.id);
    final canAfford = GameData.coins >= item.price;
    final catColor = _categories[_selectedCategory].color;

    return GestureDetector(
      onTap: () => _showItemDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: owned
              ? const Color(0xFF00B894).withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: owned
                ? const Color(0xFF00B894).withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: catColor.withOpacity(0.05),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoji
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          item.emoji,
                          style: TextStyle(
                            fontSize: owned ? 36 : 32,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Name
                    Text(
                      item.name,
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      item.desc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Price / Owned
                    if (owned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B894).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF00B894), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'مال توئه!',
                              style: TextStyle(
                                color: Color(0xFF00B894),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: canAfford
                              ? const Color(0xFFFFD700).withOpacity(0.2)
                              : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '💰',
                              style: TextStyle(fontSize: canAfford ? 14 : 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.price}',
                              style: TextStyle(
                                color: canAfford
                                    ? const Color(0xFFFFD700)
                                    : Colors.red.shade300,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Owned badge
              if (owned)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate(
          delay: Duration(milliseconds: 100 * index),
        )
        .fadeIn()
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }

  // ─── ITEM DETAIL MODAL ──────────────────────
  void _showItemDetail(ShopItem item) {
    final owned = GameData.hasItem(item.id);
    final canAfford = GameData.coins >= item.price;

    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Item preview
            AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _categories[_selectedCategory].color
                            .withOpacity(0.2 + sin(_glowCtrl.value * 2 * pi) * 0.15),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Center(
                      child: Text(item.emoji, style: const TextStyle(fontSize: 56)),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Name
            Text(
              item.name,
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 26,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              item.desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Price info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    '${item.price} سکه',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '(داری: ${GameData.coins})',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            if (owned)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF00B894), size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'قبلاً خریداری شده!',
                      style: AppFonts.vazirmatn(
                        color: const Color(0xFF00B894),
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford
                        ? const Color(0xFFFFD700)
                        : Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: canAfford ? 8 : 0,
                    shadowColor: canAfford
                        ? const Color(0xFFFFD700).withOpacity(0.4)
                        : Colors.transparent,
                  ),
                  onPressed: canAfford
                      ? () {
                          Navigator.pop(ctx);
                          _purchaseItem(item);
                        }
                      : null,
                  child: Text(
                    canAfford
                        ? 'خرید! 🎉'
                        : 'سکه کافی نیست 😅',
                    style: AppFonts.vazirmatn(
                      color: canAfford ? Colors.black : Colors.white54,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              if (!canAfford) ...[
                const SizedBox(height: 12),
                Text(
                  '${item.price - GameData.coins} سکه دیگه لازم داری',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Navigate to games to earn coins
                  },
                  icon: const Icon(Icons.games_rounded, color: AppColors.primaryLight),
                  label: Text(
                    'بازی کن و سکه بگیر! 🎮',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── PURCHASE OVERLAY ───────────────────────
  Widget _buildPurchaseOverlay() {
    return AnimatedBuilder(
      animation: _purchaseCtrl,
      builder: (_, __) {
        final opacity = _purchaseCtrl.value < 0.3
            ? _purchaseCtrl.value / 0.3
            : _purchaseCtrl.value > 0.7
                ? (1 - _purchaseCtrl.value) / 0.3
                : 1.0;

        if (opacity <= 0) return const SizedBox.shrink();

        return Center(
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0).toDouble(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Item emoji
                Transform.scale(
                  scale: 0.5 + _purchaseCtrl.value * 0.5,
                  child: Text(
                    _lastPurchasedItem,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),

                const SizedBox(height: 16),

                // Success text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B894),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B894).withOpacity(0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Text(
                    'خرید موفق! 🎉',
                    style: AppFonts.vazirmatn(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Price deducted
                Text(
                  '-$_lastPurchasePrice 💰',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── HELPERS ────────────────────────────────
  Widget _buildCoinDisplay() {
    return AnimatedBuilder(
      animation: _coinBounceCtrl,
      builder: (_, __) {
        final scale = 1.0 + sin(_coinBounceCtrl.value * pi) * 0.15;
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('💰', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '${GameData.coins}',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _glassBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────
class _Category {
  final String emoji;
  final String name;
  final Color color;
  _Category(this.emoji, this.name, this.color);
}

class ShopItem {
  final String id;
  final String emoji;
  final String name;
  final int price;
  final String desc;
  ShopItem(this.id, this.emoji, this.name, this.price, this.desc);
}
