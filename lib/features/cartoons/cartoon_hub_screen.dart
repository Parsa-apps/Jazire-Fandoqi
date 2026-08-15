import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import 'package:jazireh_fandoghi/app/design_tokens.dart';
import 'package:jazireh_fandoghi/core/audio_service.dart';
import 'package:jazireh_fandoghi/core/cartoons/aparat_service.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/monetization.dart';
import 'package:jazireh_fandoghi/features/cartoons/cartoon_player_screen.dart';
import 'package:jazireh_fandoghi/features/cartoons/widgets/cartoon_cover.dart';
import 'package:jazireh_fandoghi/features/shop/full_version_paywall.dart';
import 'package:jazireh_fandoghi/shared/widgets/child_touch_target.dart';
import 'package:jazireh_fandoghi/shared/widgets/fandoghi_v2.dart';
import 'package:jazireh_fandoghi/shared/widgets/premium_lock_overlay.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎬 CARTOON HUB SCREEN — جزیره سکوهای کارتون فندقی
/// طراحی خلوت، یکدست با تم جزیره اصلی با سکوهای شناور اختصاصی برای هر کارتون
/// ═══════════════════════════════════════════════════════════════
class CartoonHubScreen extends StatefulWidget {
  const CartoonHubScreen({super.key});

  @override
  State<CartoonHubScreen> createState() => _CartoonHubScreenState();
}

class _CartoonHubScreenState extends State<CartoonHubScreen> {
  CartoonCategoryType _selectedCategory = CartoonCategoryType.all;
  bool _hasFullVersion = false;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.disablePersistentPresence();
    _refreshEntitlement();

    // پیش‌بارگیری پوستر کارتون‌ها
    final ordered = <Cartoon>[
      ...CartoonData.getFeatured(),
      ...CartoonData.allCartoons.where((c) => !c.isFeatured),
    ];
    AparatService.prefetchCartoonCovers(
      ordered.map(
        (c) => c.episodes.isNotEmpty ? c.episodes.first.aparatHash : null,
      ),
      onProgress: () {
        if (mounted) setState(() {});
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _maybeShowParentDisclosure();
        FandoghiCoach.say(
          'به سینمای جزیره فندقی خوش اومدی! 🍿 روی سکوی هر کارتون که دوست داری بزن تا تماشا کنیم!',
          mood: FandoghiMood.excited,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  Future<void> _maybeShowParentDisclosure() async {
    final shown = GameData.getBool('cartoon_parent_disclosure_shown') ?? false;
    if (shown) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1B38),
        title: Row(
          children: [
            const Text('👨‍👩‍👧', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'اطلاعیه به والدین عزیز',
                style: AppFonts.vazirmatn(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _disclosureRow(Icons.wifi_rounded, Colors.lightBlueAccent,
                'بخش «کارتون‌کده» تنها بخش آنلاین اپ است و برای پخش به اینترنت نیاز دارد.'),
            const SizedBox(height: 10),
            _disclosureRow(Icons.verified_rounded, Colors.greenAccent,
                'ویدیوها فقط از سرویس ویدیوی ایرانی آپارات (aparat.com) و صرفاً از طریق هش‌های از پیش تأییدشده و فهرست سفید پخش می‌شوند.'),
            const SizedBox(height: 10),
            _disclosureRow(Icons.shield_rounded, Colors.amberAccent,
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
              style: AppFonts.vazirmatn(
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.w900,
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
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  List<Cartoon> get _filteredCartoons {
    return CartoonData.getByCategory(_selectedCategory);
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
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: '/cartoon/${cartoon.id}'),
        builder: (_) => CartoonPlayerScreen(
          cartoon: cartoon,
          initialEpisodeIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredCartoons;

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
                      // سکوهای شناور کارتون‌ها
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
                          final cartoon = list[index];
                          final locked = _isLocked(cartoon);
                          final isFav = GameData.isCartoonFavorite(cartoon.id);

                          return _CartoonPlatformItem(
                            cartoon: cartoon,
                            isLocked: locked,
                            isFav: isFav,
                            onTap: () => _openCartoon(cartoon),
                            onToggleFav: () {
                              HapticFeedback.selectionClick();
                              GameData.toggleCartoonFavorite(cartoon.id);
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
              'کارتون‌کده فندقی 🎬',
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
                const Text('🍿', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  'سینما',
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
      (CartoonCategoryType.all, 'همه کارتون‌ها', '🌟'),
      (CartoonCategoryType.iranian, 'کارتون‌های ایرانی', '🇮🇷'),
      (CartoonCategoryType.adventure, 'ماجراجویی', '🚀'),
      (CartoonCategoryType.comedy, 'خنده‌دار و شاد', '😄'),
      (CartoonCategoryType.preschool, 'خردسال و آموزش', '🐣'),
      (CartoonCategoryType.musical, 'موزیکال', '🎵'),
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
          colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
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
                  'جزیره کارتون‌های محبوب 🍿',
                  style: AppFonts.balooBhaijaan2(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'روی هر سکو بزن تا کارتون موردعلاقه‌ات پخش شود.',
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
/// 🏝️ CARTOON PLATFORM ITEM — سکوی شناور اختصاصی برای هر کارتون
/// ═══════════════════════════════════════════════════════════════
class _CartoonPlatformItem extends StatelessWidget {
  final Cartoon cartoon;
  final bool isLocked;
  final bool isFav;
  final VoidCallback onTap;
  final VoidCallback onToggleFav;

  const _CartoonPlatformItem({
    required this.cartoon,
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
          // قاب اصلی کارتون با هاله نور و گوشه‌های گرد
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
                      color: cartoon.themeColor.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: cartoon.themeColor.withOpacity(0.6),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // بدنه کارت / پوستر کارتون
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B38),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: cartoon.themeColor.withOpacity(0.8),
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
                      CartoonCoverImage(
                        videoHash: cartoon.episodes.isNotEmpty
                            ? cartoon.episodes.first.aparatHash
                            : null,
                        coverAsset: cartoon.coverAsset,
                        fallbackEmoji: cartoon.coverEmoji,
                        fallbackGradient: cartoon.gradient,
                        emojiSize: 42,
                        cacheWidth: 320,
                      ),
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
                      // نشانگر تعداد قسمت‌ها
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
                            '${cartoon.episodes.length} قسمت',
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
          // پایه سکوی سنگی زیر کارتون (Stone / Grass Platform Base)
          CustomPaint(
            size: const Size(90, 10),
            painter: _PlatformBasePainter(cartoon.themeColor),
          ),
          const SizedBox(height: 4),
          // بنر نام کارتون
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.soft,
            ),
            child: Text(
              cartoon.title,
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
}

/// نقاش سکوی سنگی زیر هر کارتون (مطابق سکوهای جزیره اصلی)
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
