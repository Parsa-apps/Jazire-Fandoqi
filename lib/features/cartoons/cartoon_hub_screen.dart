import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import 'package:jazireh_fandoghi/app/app_theme.dart';
import 'package:jazireh_fandoghi/core/audio_service.dart';
import 'package:jazireh_fandoghi/core/cartoons/aparat_service.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/monetization.dart';
import 'package:jazireh_fandoghi/features/cartoons/cartoon_player_screen.dart';
import 'package:jazireh_fandoghi/features/cartoons/widgets/cartoon_cover.dart';
import 'package:jazireh_fandoghi/features/home/widgets/island_map/island_map_background.dart';
import 'package:jazireh_fandoghi/features/shop/full_version_paywall.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎬 CARTOON HUB SCREEN — کارتون‌کدهٔ جزیره‌ای
///
/// دقیقاً هم‌زبان با «قصه‌خانه»: هر کارتون روی سکوی جزیره‌ایِ مستقل
/// خودش می‌نشیند، پس‌زمینه همان آسمان/اقیانوس نقشهٔ اصلی است و خبری
/// از گرید تیره، فیلترِ دسته‌بندی و بنرهای شلوغ نیست. کودک خردسال
/// فقط یک تصمیم دارد: لمس سکوی کارتونی که دوست دارد.
/// ═══════════════════════════════════════════════════════════════
class CartoonHubScreen extends StatefulWidget {
  const CartoonHubScreen({super.key});

  @override
  State<CartoonHubScreen> createState() => _CartoonHubScreenState();
}

class _CartoonHubScreenState extends State<CartoonHubScreen>
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

    // خود فندقی در هدر حضور دارد؛ حباب سراسری خاموش می‌ماند تا صفحه
    // برای کودک خردسال خلوت و متمرکز بماند (مثل قصه‌خانه).
    FandoghiCoach.disablePersistentPresence();

    // پیش‌بارگیری پوستر کارتون‌ها به همان ترتیبی که روی سکوها می‌آیند
    AparatService.prefetchCartoonCovers(
      CartoonData.allCartoons.map(
        (c) => c.episodes.isNotEmpty ? c.episodes.first.aparatHash : null,
      ),
      onProgress: () {
        if (mounted) setState(() {});
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeShowParentDisclosure();
    });
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

  Future<void> _maybeShowParentDisclosure() async {
    final shown = GameData.getBool('cartoon_parent_disclosure_shown') ?? false;
    if (shown) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFFDF7),
        title: Row(
          children: [
            const Text('👨‍👩‍👧', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'اطلاعیه به والدین عزیز',
                style: AppFonts.kids(
                  color: const Color(0xFF3B2B52),
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _disclosureRow(Icons.wifi_rounded, const Color(0xFF2196F3),
                'بخش «کارتون‌کده» تنها بخش آنلاین اپ است و برای پخش به اینترنت نیاز دارد.'),
            const SizedBox(height: 10),
            _disclosureRow(Icons.verified_rounded, const Color(0xFF43A047),
                'ویدیوها فقط از سرویس ویدیوی ایرانی آپارات (aparat.com) و صرفاً از طریق هش‌های از پیش تأییدشده و فهرست سفید پخش می‌شوند.'),
            const SizedBox(height: 10),
            _disclosureRow(Icons.shield_rounded, const Color(0xFFEF6C00),
                'هیچ‌گونه جستجوی آزاد، تبلیغ، لینک خروجی به سایت‌های ثالث، یا ارسال اطلاعات کودک به سرور وجود ندارد.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              GameData.setBool('cartoon_parent_disclosure_shown', true);
              Navigator.of(ctx).pop();
            },
            child: Text(
              'مطّلع شدم ✅',
              style: AppFonts.kids(
                color: const Color(0xFF7E57C2),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclosureRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4B3565),
              fontSize: 12,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  bool _isLocked(Cartoon cartoon) =>
      !_hasFullVersion && !ContentAccessPolicy.isCartoonFree(cartoon.id);

  Future<bool> _refreshEntitlement() async {
    final hasFullVersion = await Monetization.hasFullVersion();
    if (mounted && hasFullVersion != _hasFullVersion) {
      setState(() => _hasFullVersion = hasFullVersion);
    }
    return hasFullVersion;
  }

  Future<void> _openCartoon(Cartoon cartoon) async {
    HapticFeedback.lightImpact();
    AudioService.select();

    if (!ContentAccessPolicy.isCartoonFree(cartoon.id) &&
        !await Monetization.hasFullVersion()) {
      if (!mounted) return;
      await showFullVersionPaywall(context, featureName: cartoon.title);
      if (!mounted || !await _refreshEntitlement()) return;
    }
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: '/cartoon/${cartoon.id}'),
        builder: (_) => CartoonPlayerScreen(
          cartoon: cartoon,
          initialEpisodeIndex: 0,
        ),
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
    final cartoons = CartoonData.allCartoons;
    final watchedCount = cartoons
        .where((cartoon) => GameData.watchedCartoons.contains(cartoon.id))
        .length;
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
                  key: const ValueKey('cartoon_island_scroll'),
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.only(
                    top: topInset,
                    bottom: MediaQuery.paddingOf(context).bottom + 34,
                  ),
                  child: _CartoonIslandMap(
                    width: constraints.maxWidth,
                    cartoons: cartoons,
                    floatAnimation: _floatController,
                    isLocked: _isLocked,
                    onCartoonTap: _openCartoon,
                    onToggleFavorite: (cartoon) {
                      HapticFeedback.selectionClick();
                      GameData.toggleCartoonFavorite(cartoon.id);
                      setState(() {});
                    },
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
                child: _CartoonTopBar(
                  watchedCount: watchedCount,
                  totalCount: cartoons.length,
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

class _CartoonTopBar extends StatelessWidget {
  const _CartoonTopBar({
    required this.watchedCount,
    required this.totalCount,
    required this.onBack,
  });

  final int watchedCount;
  final int totalCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'کارتون‌کده فندقی، $watchedCount کارتون از $totalCount کارتون تماشا شده',
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
              key: const ValueKey('cartoons_back'),
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
                'کارتون‌کده فندقی',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.kids(
                  color: const Color(0xFF3B2B52),
                  fontSize: 21,
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
                    Icons.movie_rounded,
                    color: Color(0xFF558B2F),
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$watchedCount/$totalCount',
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

class _CartoonIslandMap extends StatelessWidget {
  const _CartoonIslandMap({
    required this.width,
    required this.cartoons,
    required this.floatAnimation,
    required this.isLocked,
    required this.onCartoonTap,
    required this.onToggleFavorite,
  });

  static const double _stepHeight = 238;
  static const double _introHeight = 92;

  final double width;
  final List<Cartoon> cartoons;
  final Animation<double> floatAnimation;
  final bool Function(Cartoon cartoon) isLocked;
  final ValueChanged<Cartoon> onCartoonTap;
  final ValueChanged<Cartoon> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final mapHeight = _introHeight + cartoons.length * _stepHeight + 32;
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
                painter: _CartoonTrailPainter(
                  cartoonCount: cartoons.length,
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
            child: _GuideBubble(cartoonCount: cartoons.length),
          ),
          for (var index = 0; index < cartoons.length; index++)
            Positioned(
              key: ValueKey('cartoon_platform_$index'),
              top: _introHeight + index * _stepHeight,
              left: index.isEven ? 8 : null,
              right: index.isOdd ? 8 : null,
              child: _CartoonPlatform(
                index: index,
                cartoon: cartoons[index],
                width: platformWidth,
                floatAnimation: floatAnimation,
                locked: isLocked(cartoons[index]),
                watched:
                    GameData.watchedCartoons.contains(cartoons[index].id),
                isFavorite: GameData.isCartoonFavorite(cartoons[index].id),
                onTap: () => onCartoonTap(cartoons[index]),
                onToggleFavorite: () => onToggleFavorite(cartoons[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _GuideBubble extends StatelessWidget {
  const _GuideBubble({required this.cartoonCount});

  final int cartoonCount;

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
          'یکی از $cartoonCount سکوی کارتون را لمس کن! 🍿',
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

class _CartoonPlatform extends StatefulWidget {
  const _CartoonPlatform({
    required this.index,
    required this.cartoon,
    required this.width,
    required this.floatAnimation,
    required this.locked,
    required this.watched,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final int index;
  final Cartoon cartoon;
  final double width;
  final Animation<double> floatAnimation;
  final bool locked;
  final bool watched;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  State<_CartoonPlatform> createState() => _CartoonPlatformState();
}

class _CartoonPlatformState extends State<_CartoonPlatform>
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
      label:
          '${widget.cartoon.title}${widget.locked ? '، قفل' : ''}${widget.watched ? '، تماشا شده' : ''}',
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
            final phase = (widget.floatAnimation.value + phaseOffset) % 1.0;
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
                        color: widget.watched
                            ? const Color(0xFF6FCF67)
                            : const Color(0xFFFFC857),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.cartoon.themeColor.withOpacity(0.35),
                          blurRadius: 13,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(child: _cover(coverSize)),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: widget.width * 0.09,
                  child: _numberBadge(),
                ),
                Positioned(
                  top: 4,
                  left: widget.width * 0.09,
                  child: _favoriteButton(),
                ),
                if (widget.watched)
                  Positioned(
                    top: coverSize * 0.72,
                    left: widget.width * 0.25,
                    child: _statusBadge(
                      icon: Icons.check_rounded,
                      color: const Color(0xFF43A047),
                      label: 'دیدم',
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

  Widget _cover(double size) {
    return CartoonCoverImage(
      videoHash: widget.cartoon.episodes.isNotEmpty
          ? widget.cartoon.episodes.first.aparatHash
          : null,
      coverAsset: widget.cartoon.coverAsset,
      fallbackEmoji: widget.cartoon.coverEmoji,
      fallbackGradient: widget.cartoon.gradient,
      emojiSize: size * 0.46,
      cacheWidth: 320,
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

  Widget _favoriteButton() {
    return Semantics(
      button: true,
      label: widget.isFavorite
          ? '${widget.cartoon.title}، حذف از علاقه‌مندی‌ها'
          : '${widget.cartoon.title}، افزودن به علاقه‌مندی‌ها',
      child: GestureDetector(
        onTap: widget.onToggleFavorite,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF7),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            widget.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            size: 19,
            color: widget.isFavorite
                ? const Color(0xFFE53935)
                : const Color(0xFFBCAAA4),
          ),
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
        widget.cartoon.title,
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

class _CartoonTrailPainter extends CustomPainter {
  const _CartoonTrailPainter({
    required this.cartoonCount,
    required this.stepHeight,
    required this.introHeight,
  });

  final int cartoonCount;
  final double stepHeight;
  final double introHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (cartoonCount < 2) return;

    final path = Path();
    for (var index = 0; index < cartoonCount; index++) {
      final x = index.isEven ? size.width * 0.35 : size.width * 0.65;
      final y = introHeight + index * stepHeight + stepHeight * 0.50;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        final previousX = index.isEven ? size.width * 0.65 : size.width * 0.35;
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
  bool shouldRepaint(covariant _CartoonTrailPainter oldDelegate) =>
      oldDelegate.cartoonCount != cartoonCount ||
      oldDelegate.stepHeight != stepHeight ||
      oldDelegate.introHeight != introHeight;
}
