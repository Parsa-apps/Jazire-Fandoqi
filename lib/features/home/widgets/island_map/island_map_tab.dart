import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_fonts.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/audio_service.dart';
import '../../../../core/fandoghi_coach.dart';
import '../../../../core/game_data.dart';
import '../../../../core/growth/growth.dart';
import '../../../../presentation/providers/game_state_provider.dart';
import '../../../profile/profile_editor.dart';
import '../../../stage_map/stage_map_screen.dart';
import '../daily_gifts_dialog.dart';
import '../fandoqi_hub_sheet.dart';
import 'island_map_background.dart';
import 'island_node.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🗺️ نقشهٔ جزیرهٔ فندقی — تم اصلی برنامه
///
/// یک نقشهٔ عمودیِ اسکرول‌شونده که کودک از بالا (قهرمان فندقی) تا پایین
/// (صخرهٔ زیرِ آب) پیش می‌رود. هر سکو یک دارایی جداگانه با پس‌زمینهٔ
/// شفاف است، پس می‌شود مستقل انیمیت و جابه‌جا شود.
///
/// چیدمان مارپیچ (S) از بالا به پایین:
///   ۱. تابلوی چوبی آویزان خوش‌آمدگویی
///   ۲. 🌰 قهرمان فندقی (وسط و بزرگ‌تر از همه)
///   ۳. کارتون‌ها (چپ)
///   ۴. قصه‌ها (راست)
///   ۵. فارسی (چپ)
///   ۶. بازی‌ها (وسط)
///   ۷. لالایی (راست)
///   ۸. پروفایل من (چپ)
///   ۹. دربارهٔ ما (راست)
///  ۱۰. ناحیهٔ زیرِ آب: ریاضی، حروف، علوم، هنر
///
/// همهٔ ۶ هاب یادگیری در دسترس‌اند: فارسی و بازی‌ها سکوی اختصاصی دارند و
/// ریاضی، حروف، علوم و هنر در حباب‌های زیرِ آب.
/// ═══════════════════════════════════════════════════════════════
class IslandMapTab extends ConsumerStatefulWidget {
  final VoidCallback? onOpenStageMap;
  final VoidCallback? onOpenBackpack;
  final VoidCallback? onOpenAchievements;

  const IslandMapTab({
    super.key,
    this.onOpenStageMap,
    this.onOpenBackpack,
    this.onOpenAchievements,
  });

  @override
  ConsumerState<IslandMapTab> createState() => _IslandMapTabState();
}

class _IslandMapTabState extends ConsumerState<IslandMapTab>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _bubbleCtrl;
  late final ScrollController _scrollCtrl;

  double _scrollOffset = 0;

  /// ارتفاع کل نقشه نسبت به ارتفاع صفحه — نقشه حدود ۲٫۵ صفحه بلند است
  static const double _mapHeightFactor = 3.41;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _scrollCtrl = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FandoghiCoach.welcome();
    });
  }

  /// پیشرفت سفر از ۰ (بالای نقشه) تا ۱ (انتهای زیرِ آب)
  double get _progress {
    if (!_scrollCtrl.hasClients) return 0;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (max <= 0) return 0;
    return (_scrollCtrl.offset / max).clamp(0.0, 1.0);
  }

  void _onScroll() {
    // فقط پس‌زمینه را با پارالاکس تازه می‌کنیم؛ سکوها دست نمی‌خورند
    final next = _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0;
    if ((next - _scrollOffset).abs() > 1.5) {
      setState(() => _scrollOffset = next);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _floatCtrl.dispose();
    _bubbleCtrl.dispose();
    super.dispose();
  }

  // ─── ناوبری ───────────────────────────────────────────────
  void _openHub(HubData hub) => showFandoqiHubSheet(context, hub);

  void _go(String route) {
    HapticFeedback.lightImpact();
    AudioService.select();
    Navigator.pushNamed(context, route);
  }

  void _openGifts() {
    showDailyGiftsDialog(context, onRewardClaimed: () {
      if (mounted) setState(() {});
    });
  }

  void _openStageMap() {
    HapticFeedback.mediumImpact();
    AudioService.select();
    if (widget.onOpenStageMap != null) {
      widget.onOpenStageMap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StageMapScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameStateProvider);
    final cycle = AppTheme.currentCycle;

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          // ── لایهٔ ۱: آسمان، ابر، خورشید، اقیانوس ──
          Positioned.fill(
            child: IslandMapBackground(
              scrollOffset: _scrollOffset,
              cycle: cycle,
              progress: _progress,
            ),
          ),

          // ── لایهٔ ۲: نقشهٔ اسکرول‌شونده ──
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final mapH = h * _mapHeightFactor;
                // فضای خالی بالای نقشه تا تابلو زیر نوار وضعیت پنهان نشود
                final topInset = MediaQuery.of(context).padding.top + 58;

                return SingleChildScrollView(
                  controller: _scrollCtrl,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: topInset),
                    child: SizedBox(
                      height: mapH,
                      width: w,
                      child: _buildMapContent(w, mapH),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── لایهٔ ۳: دکمه‌های شناور کنارهٔ صفحه ──
          Positioned(
            right: 10,
            bottom: 22,
            child: SafeArea(top: false, child: _buildSideButtons()),
          ),

          // ── لایهٔ ۴: نوار وضعیت ثابت بالای صفحه ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                child: _buildTopBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── محتوای نقشه: سکوها، پل‌ها و ناحیهٔ زیرِ آب ─────────────
  Widget _buildMapContent(double w, double mapH) {
    // سکوها عمداً درشت‌اند: برچسب‌ها نسبت به عرضِ سکو اندازه می‌گیرند،
    // پس سکوی بزرگ‌تر یعنی متنِ کارتونی و درشتِ خوانا برای بچهٔ کوچک.
    final islandW = (w * 0.56).clamp(150.0, 250.0);
    final heroW = (w * 0.42).clamp(120.0, 200.0);

    // چیدمان مارپیچ: هر سکو با جای عمودی، سمت (چپ/وسط/راست) و ضریب اندازه
    final slots = <_Slot>[
      _Slot(
        asset: 'assets/theme_map/island_cartoon.png',
        label: 'کارتون‌ها',
        top: 0.1605,
        side: -1,
        widthMul: 1.00,
        phase: 0.10,
        onTap: () => _go('/cartoons'),
      ),
      // قصه‌ها: درست یک پله پایین‌تر از کارتون‌ها — فندقی روی چمن نشسته
      // و کتاب باز دستش است.
      _Slot(
        asset: 'assets/theme_map/island_tales.png',
        label: 'قصه‌ها',
        top: 0.2646,
        side: 1,
        widthMul: 1.00,
        phase: 0.22,
        onTap: () => _go('/stories'),
      ),
      _Slot(
        asset: 'assets/theme_map/island_story.png',
        label: 'فارسی',
        top: 0.3815,
        side: -1,
        widthMul: 1.00,
        phase: 0.35,
        onTap: () => _openHub(FandoqiHubs.farsi),
      ),
      _Slot(
        asset: 'assets/theme_map/island_game.png',
        label: 'بازی‌ها',
        top: 0.4852,
        side: 0,
        widthMul: 1.10,
        phase: 0.55,
        onTap: () => _openHub(FandoqiHubs.games),
      ),
      _Slot(
        asset: 'assets/theme_map/island_lullaby.png',
        label: 'لالایی',
        top: 0.5832,
        side: 1,
        widthMul: 1.00,
        phase: 0.72,
        onTap: () => _go('/lullabies'),
      ),
      _Slot(
        asset: 'assets/theme_map/island_profile.png',
        label: 'پروفایل من',
        top: 0.6795,
        side: -1,
        widthMul: 1.00,
        phase: 0.20,
        onTap: () => showProfileEditor(context),
      ),
      _Slot(
        asset: 'assets/theme_map/island_about.png',
        label: 'دربارهٔ ما',
        top: 0.7898,
        side: 1,
        widthMul: 0.94,
        phase: 0.88,
        onTap: () => _go('/about'),
      ),
    ];

    // هندسهٔ هر سکو: مستطیل واقعی‌اش روی نقشه
    const margin = 0.025;
    final rects = <Rect>[];
    for (final s in slots) {
      final iw = islandW * s.widthMul;
      final ih = iw * (PillRect.aspectByAsset[s.asset] ?? 1.15);
      final left = switch (s.side) {
        < 0 => w * margin,
        > 0 => w - w * margin - iw,
        _ => (w - iw) / 2,
      };
      rects.add(Rect.fromLTWH(left, mapH * s.top, iw, ih));
    }

    final signW = (w * 0.72).clamp(210.0, 340.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── پل‌ها زیر سکوها کشیده می‌شوند تا دو سرشان زیر چمن پنهان شود ──
        for (var i = 0; i < rects.length - 1; i++)
          _connectingBridge(rects[i], rects[i + 1]),

        // ── تابلوی آویزان خوش‌آمدگویی ──
        Positioned(
          top: mapH * 0.003,
          left: (w - signW) / 2,
          width: signW,
          child: _welcomeSign(signW),
        ),

        // ── 🌰 قهرمان فندقی: وسط، بزرگ‌تر از همه، شخصیت اصلی برنامه ──
        // هالهٔ طلایی از خود فندقی بزرگ‌تر است، پس کادر را به اندازهٔ هاله
        // می‌گیریم تا چیزی بریده نشود.
        Positioned(
          top: mapH * 0.082,
          left: (w - heroW * HeroFandoq.haloFactor) / 2,
          width: heroW * HeroFandoq.haloFactor,
          child: HeroFandoq(
            width: heroW,
            floatAnimation: _floatCtrl,
            onTap: () => FandoghiCoach.celebrate(
              'سلام قهرمان! کدوم جزیره رو بگردیم؟ 🌰✨',
            ),
          ),
        ),

        // ── سکوهای جزیره ──
        for (var i = 0; i < slots.length; i++)
          Positioned(
            left: rects[i].left,
            top: rects[i].top,
            width: rects[i].width,
            child: IslandNode(
              asset: slots[i].asset,
              label: slots[i].label,
              width: rects[i].width,
              floatPhase: slots[i].phase,
              floatAnimation: _floatCtrl,
              onTap: slots[i].onTap,
            ),
          ),

        // ── ناحیهٔ زیرِ آب: حباب‌های شناور و چهار دنیای یادگیری ──
        Positioned(
          top: mapH * 0.908,
          left: 0,
          right: 0,
          height: mapH * 0.092,
          child: Stack(
            children: [
              Positioned.fill(
                child: FloatingBubbles(animation: _bubbleCtrl),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 10,
                child: _underwaterBar(w),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// پل چوبی که دو سکوی پشت‌سرهم را واقعاً به هم وصل می‌کند:
  /// طول و زاویه از فاصلهٔ همان دو سکو حساب می‌شود، نه عدد ثابت.
  Widget _connectingBridge(Rect a, Rect b) {
    // نقطهٔ اتصال روی لبهٔ چمنِ هر سکو
    final p1 = Offset(a.left + a.width * 0.55, a.top + a.height * 0.46);
    final p2 = Offset(b.left + b.width * 0.45, b.top + b.height * 0.34);
    final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    final dist = (p2 - p1).distance;
    final bw = dist * 1.04;
    final bh = bw * (PillRect.aspectByAsset['assets/theme_map/bridge.png'] ?? 0.39);
    final angle = (p2 - p1).direction;

    return Positioned(
      left: mid.dx - bw / 2,
      top: mid.dy - bh / 2,
      width: bw,
      height: bh,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: angle,
          child: Image.asset(
            'assets/theme_map/bridge.png',
            width: bw,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }

  /// تابلوی چوبی آویزان بالای نقشه.
  /// تختهٔ چوب در تصویر عمداً خالی تولید شده؛ متن فارسی اینجا دقیقاً
  /// روی آن می‌نشیند (تخته از ۰٫۳۰ تا ۰٫۹۷ ارتفاع تصویر است).
  Widget _welcomeSign(double signW) {
    final childName =
        GameData.childName.isNotEmpty ? GameData.childName : 'قهرمان';
    final signH =
        signW * (PillRect.aspectByAsset['assets/theme_map/sign_board.png'] ?? 0.67);

    return SizedBox(
      width: signW,
      height: signH,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/theme_map/sign_board.png',
              width: signW,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
          Positioned(
            left: signW * 0.07,
            right: signW * 0.07,
            top: signH * 0.34,
            height: signH * 0.58,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'جزیرهٔ فندقی',
                    style: AppFonts.kids(
                      fontSize: signW * 0.125,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5D3A12),
                      height: 1.1,
                      shadows: const [
                        Shadow(
                          color: Color(0x55FFFFFF),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'خوش اومدی $childName!',
                    style: AppFonts.kids(
                      fontSize: signW * 0.065,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7B4E1C),
                      height: 1.15,
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

  /// نوار حباب‌های زیرِ آب — چهار دنیای یادگیری که سکوی اختصاصی ندارند.
  /// (فارسی و بازی‌ها روی خودِ نقشه سکو دارند، پس اینجا تکرار نمی‌شوند.)
  Widget _underwaterBar(double w) {
    // حباب‌ها هم‌خانوادهٔ سکوها هستند: اندازه‌شان با عرض صفحه بالا و پایین
    // می‌رود و برچسبشان همان پلاک کپسولیِ سکوهاست.
    final bubbleW = ((w - 24) / 4 * 0.86).clamp(58.0, 104.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hubBubble(FandoqiHubs.math, 'ریاضی', 'bubble_math', bubbleW, 0.05),
          _hubBubble(FandoqiHubs.lettersAndSounds, 'حروف', 'bubble_letters',
              bubbleW, 0.30),
          _hubBubble(
              FandoqiHubs.science, 'علوم', 'bubble_science', bubbleW, 0.55),
          _hubBubble(FandoqiHubs.art, 'هنر', 'bubble_art', bubbleW, 0.80),
        ],
      ),
    );
  }

  /// یک حباب شیشه‌ای که یک هاب یادگیری را باز می‌کند — همان زبانِ تصویریِ
  /// سکوها: تصویر سه‌بعدی + پلاک کپسولیِ کرم با حاشیهٔ عسلی.
  Widget _hubBubble(
      HubData hub, String label, String asset, double width, double phase) {
    return BubbleNode(
      asset: 'assets/theme_map/$asset.png',
      label: label,
      width: width,
      floatAnimation: _floatCtrl,
      floatPhase: phase,
      onTap: () => _openHub(hub),
    );
  }

  /// دکمه‌های شناور کنارهٔ صفحه: هدیهٔ روزانه و کتابخانه
  Widget _buildSideButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sideButton(
          icon: Icons.card_giftcard_rounded,
          color: const Color(0xFFE91E63),
          tooltip: 'هدیهٔ روزانه',
          onTap: _openGifts,
        ),
        const SizedBox(height: 10),
        _sideButton(
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF00897B),
          tooltip: 'کتابخانه',
          onTap: () {
            if (widget.onOpenBackpack != null) {
              widget.onOpenBackpack!();
            } else {
              _go('/learning-library');
            }
          },
        ),
      ],
    );
  }

  Widget _sideButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          AudioService.tap();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.35), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  // ─── نوار وضعیت بالا (پروفایل + ستاره + سکه) ─────────────
  Widget _buildTopBar() {
    final childName =
        GameData.childName.isNotEmpty ? GameData.childName : 'آریا';
    final stars = GameData.stars;
    final coins = GameData.coins;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => showProfileEditor(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.94),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF81D4FA),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF039BE5), width: 2.2),
                  ),
                  child: Center(
                    child: Text(
                      GameData.avatar.isNotEmpty && !GameData.avatar.startsWith('assets/')
                          ? GameData.avatar
                          : '👦',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'سلام $childName!',
                  style: AppFonts.kids(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mapText,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            _statChip(Icons.star_rounded, const Color(0xFFFFB300), stars),
            const SizedBox(width: 6),
            _statChip(Icons.monetization_on_rounded,
                const Color(0xFFFF9800), coins),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _openStageMap,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.map_rounded,
                    color: Color(0xFF00897B), size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, Color color, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 3),
          Text(
            PersianDigits.toFa(value),
            style: AppFonts.kids(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.mapText,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// توصیف یک جایگاه روی نقشه: کدام دارایی، چه برچسبی، کجا و با چه رفتاری.
class _Slot {
  final String asset;
  final String label;

  /// جای عمودی به‌صورت کسری از ارتفاع کل نقشه
  final double top;

  /// ‎-۱ چپ، ۰ وسط، ۱ راست
  final int side;

  final double widthMul;
  final double phase;
  final VoidCallback onTap;

  const _Slot({
    required this.asset,
    required this.label,
    required this.top,
    required this.side,
    required this.widthMul,
    required this.phase,
    required this.onTap,
  });
}
