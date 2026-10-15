import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_fonts.dart';
import '../../../../app/app_theme.dart';
import '../../../../app/island_world_style.dart';
import '../../../../core/audio_service.dart';
import '../../../../core/fandoghi_coach.dart';
import '../../../../core/game_data.dart';
import '../../../../core/growth/growth.dart';
import '../../../../core/learning/today_path.dart';
import '../../../../presentation/providers/game_state_provider.dart';
import '../../../../shared/widgets/today_complete_sheet.dart';
import '../../../profile/profile_editor.dart';
import '../../../stage_map/stage_map_screen.dart';
import '../daily_gifts_dialog.dart';
import '../fandoqi_hub_sheet.dart';
import 'island_decorations.dart';
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
  bool _reduceMotion = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;

    if (reduceMotion) {
      _floatCtrl
        ..stop()
        ..value = 0;
      _bubbleCtrl
        ..stop()
        ..value = 0;
    } else {
      _floatCtrl.repeat();
      _bubbleCtrl.repeat();
    }
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

  void _openParentPanel() {
    HapticFeedback.lightImpact();
    AudioService.select();
    Navigator.pushNamed(context, '/parent');
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
              ambientAnimation: _bubbleCtrl,
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
                final topInset = MediaQuery.of(context).padding.top +
                    (GameData.classroomLightMode ? 178 : 58);

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
                      child: _buildMapContent(w, mapH, cycle),
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
                child: Column(
                  children: [
                    // ورود نرم نوار بالا: از بالا می‌لغزد و ظاهر می‌شود
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: _reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 550),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, child) => Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, -10 * (1 - t)),
                          child: child,
                        ),
                      ),
                      child: _buildTopBar(),
                    ),
                    if (GameData.classroomLightMode) ...[
                      const SizedBox(height: 8),
                      _classroomDoors(),
                      const SizedBox(height: 6),
                      _todayPathChip(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// سکویی که «مسیر امروز» کودک به آن اشاره می‌کند؛ فندقی با چراغ
  /// طلایی همان را نشان می‌دهد تا شروع بازی نیاز به خواندن نداشته
  /// باشد. نگاشت مسیر به سکو محافظه‌کارانه است: خواندن/نوشتن به
  /// سکوی فارسی، قصه به قصه‌ها و بقیه به سکوی مرکزی بازی‌ها.
  String _suggestedAssetForToday() {
    final route = TodayPath.forChild().route;
    if (route.startsWith('/stories')) {
      return 'assets/theme_map/island_tales.png';
    }
    if (route.startsWith('/cartoons')) {
      return 'assets/theme_map/island_cartoon.png';
    }
    if (route.startsWith('/lullabies')) {
      return 'assets/theme_map/island_lullaby.png';
    }
    if (route == '/alphabet' ||
        route.startsWith('/dictation') ||
        route.startsWith('/vocabulary') ||
        route.startsWith('/sound_match') ||
        route.startsWith('/game/الفبا')) {
      return 'assets/theme_map/island_story.png';
    }
    return 'assets/theme_map/island_game.png';
  }

  // ─── محتوای نقشه: سکوها، پل‌ها و ناحیهٔ زیرِ آب ─────────────
  Widget _buildMapContent(double w, double mapH, DayCycle cycle) {
    // سکوها عمداً درشت‌اند: برچسب‌ها نسبت به عرضِ سکو اندازه می‌گیرند،
    // پس سکوی بزرگ‌تر یعنی متنِ کارتونی و درشتِ خوانا برای بچهٔ کوچک.
    final islandW = (w * 0.56).clamp(150.0, 250.0);
    final heroW = (w * 0.42).clamp(120.0, 200.0);

    // چیدمان مارپیچ: هر سکو با جای عمودی، سمت (چپ/وسط/راست) و ضریب اندازه
    // نسخه ۷: سکوی «شهر بازی‌های تازه» اضافه شد و ریتم عمودی کمی فشرده‌تر
    // شد تا هشت سکو بدون تصادم روی مسیر جا بگیرند.
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
        top: 0.2580,
        side: 1,
        widthMul: 1.00,
        phase: 0.22,
        onTap: () => _go('/stories'),
      ),
      _Slot(
        asset: 'assets/theme_map/island_story.png',
        label: 'فارسی',
        top: 0.3560,
        side: -1,
        widthMul: 1.00,
        phase: 0.35,
        onTap: () => _openHub(FandoqiHubs.farsi),
      ),
      _Slot(
        asset: 'assets/theme_map/island_game.png',
        label: 'بازی‌ها',
        top: 0.4540,
        side: 0,
        widthMul: 1.10,
        phase: 0.55,
        onTap: () => _openHub(FandoqiHubs.games),
      ),
      _Slot(
        asset: 'assets/theme_map/island_lullaby.png',
        label: 'لالایی',
        top: 0.5520,
        side: 1,
        widthMul: 1.00,
        phase: 0.72,
        onTap: () => _go('/lullabies'),
      ),
      // 🎪 نسخه ۷: شهر بازی‌های تازه — ده بازی جدید با سیستم XP
      _Slot(
        asset: 'assets/theme_map/island_carnival.png',
        label: 'بازی‌های تازه',
        top: 0.6490,
        side: -1,
        widthMul: 1.06,
        phase: 0.40,
        badge: 'جدید',
        onTap: () => _go('/games-carnival'),
      ),
      _Slot(
        asset: 'assets/theme_map/island_profile.png',
        label: 'پروفایل من',
        top: 0.7420,
        side: -1,
        widthMul: 1.00,
        phase: 0.20,
        onTap: () => showProfileEditor(context),
      ),
      _Slot(
        asset: 'assets/theme_map/island_about.png',
        label: 'دربارهٔ ما',
        top: 0.8350,
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

    final mapHeroHeight = w * (1376 / 768);
    final mapNightShade = switch (cycle) {
      DayCycle.night => const Color(0x550B1C45),
      DayCycle.sunset => const Color(0x18FF8D59),
      _ => Colors.transparent,
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // دیورامای عمودیِ جزیره در ابتدای مسیر؛ تصویر روی نقاط قابل‌لمس
        // قرار نمی‌گیرد و فقط صحنهٔ پس‌زمینه را غنی‌تر می‌کند.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: mapHeroHeight,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    IslandWorldAssets.mapHero,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    filterQuality: FilterQuality.medium,
                    cacheWidth: (w * MediaQuery.devicePixelRatioOf(context))
                        .round()
                        .clamp(1, 768)
                        .toInt(),
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: AppColors.mapBackground),
                  ),
                  ColoredBox(color: mapNightShade),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: mapHeroHeight * 0.16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            (cycle == DayCycle.night
                                    ? const Color(0xFF163451)
                                    : const Color(0xFF58C7D5))
                                .withOpacity(0.24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── تزئینات زندهٔ دنیا: رنگین‌کمان، بالن، درخت‌ها و ذرات نور ──
        // زیر پل‌ها و سکوها می‌نشینند تا دنیا پر و کامل به نظر برسد،
        // ولی هیچ‌وقت روی ناحیهٔ لمس بازی‌ها نمی‌افتند.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: mapH,
          // تزئینات خودشان لایهٔ لمسیِ جدا دارند (واکنش گل و درخت)؛
          // ذرات نور داخلشان IgnorePointer است و مزاحم اسکرول نیست.
          child: IslandDecorations(
            width: w,
            mapHeight: mapH,
            floatAnimation: _floatCtrl,
          ),
        ),

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
              badge: slots[i].badge,
              entranceDelay: Duration(milliseconds: 70 * i),
              highlight: slots[i].asset == _suggestedAssetForToday(),
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
              // ماهی‌ها، جلبک‌ها، مرجان و ستارهٔ دریاییِ کف دریا
              Positioned.fill(
                child: UnderwaterDecor(animation: _bubbleCtrl),
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

  /// شناوریِ بسیار ملایم دکمه‌های کناری روی همان ضرب‌آهنگ نقشه،
  /// با فاز مخالف هم تا ریتم صفحه یکدست و زنده بماند.
  Widget _floatingSide({required double phase, required Widget child}) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (context, inner) {
        final bob = sin(((_floatCtrl.value + phase) % 1.0) * 2 * pi);
        return Transform.translate(offset: Offset(0, bob * 2.5), child: inner);
      },
      child: child,
    );
  }

  /// دکمه‌های شناور کنارهٔ صفحه: هدیهٔ روزانه و کتابخانه
  Widget _buildSideButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _floatingSide(
          phase: 0.0,
          child: _sideButton(
            icon: Icons.card_giftcard_rounded,
            color: const Color(0xFFE91E63),
            tooltip: 'هدیهٔ روزانه',
            onTap: _openGifts,
          ),
        ),
        const SizedBox(height: 10),
        _floatingSide(
          phase: 0.5,
          child: _sideButton(
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
    final compact = MediaQuery.sizeOf(context).width < 370;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => showProfileEditor(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 4 : 10,
              vertical: compact ? 4 : 6,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFDF7), Color(0xFFFFF0C9)],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFFFB300), width: 1.6),
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
                  width: compact ? 34 : 38,
                  height: compact ? 34 : 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF81D4FA),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF039BE5), width: 2.2),
                  ),
                  child: Center(
                    child: GameData.avatar.isNotEmpty && GameData.avatar.startsWith('assets/')
                        ? ClipOval(
                            child: Image.asset(
                              GameData.avatar,
                              width: compact ? 34 : 38,
                              height: compact ? 34 : 38,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Text('👦', style: TextStyle(fontSize: 20)),
                            ),
                          )
                        : Text(
                            GameData.avatar.isNotEmpty ? GameData.avatar : '👦',
                            style: const TextStyle(fontSize: 20),
                          ),
                  ),
                ),
                if (!compact) ...[
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
              ],
            ),
          ),
        ),
        Row(
          children: [
            _statChip(
              Icons.star_rounded,
              const Color(0xFFFFB300),
              stars,
              compact: compact,
            ),
            SizedBox(width: compact ? 4 : 6),
            _statChip(
              Icons.monetization_on_rounded,
              const Color(0xFFFF9800),
              coins,
              compact: compact,
            ),
            SizedBox(width: compact ? 4 : 6),
            GestureDetector(
              onTap: _openStageMap,
              child: Container(
                padding: EdgeInsets.all(compact ? 7 : 9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFFFFCC80), width: 1.5),
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
            SizedBox(width: compact ? 4 : 6),
            GestureDetector(
              onTap: _openParentPanel,
              child: Container(
                padding: EdgeInsets.all(compact ? 7 : 9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFFFFCC80), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: Color(0xFF6D4C41), size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// چهار در بزرگ کلاس اول — کودک ۶ ساله نباید دنبال بازی بگردد.
  Widget _classroomDoors() {
    final doors = <(String, String, String)>[
      ('الفبا', '🔤', '/game/الفبا'),
      ('اعداد', '🔢', '/numbers'),
      ('املا', '👂', '/dictation'),
      ('نقاشی', '🖌️', '/game/نقاشی'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7).withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFCC80), width: 2),
      ),
      child: Row(
        children: [
          for (final door in doors)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: GestureDetector(
                  onTap: () => _go(door.$3),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(door.$2, style: const TextStyle(fontSize: 20)),
                        Text(
                          door.$1,
                          style: AppFonts.kids(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4E342E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _todayPathChip() {
    final task = TodayPath.forChild();
    final progress =
        '${PersianDigits.toFa(task.doneCount)} از ${PersianDigits.toFa(task.totalCount)}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (task.allDone) {
            showTodayCompleteSheet(context);
            return;
          }
          _go(task.route);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7).withOpacity(0.96),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFB74D)),
          ),
          child: Text(
            task.allDone
                ? 'امروز کارت تمام شد 🌟'
                : 'امروز $progress — ${task.title}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.kids(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4E342E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(
    IconData icon,
    Color color,
    int value, {
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 8,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFDF7), Color(0xFFFFF3D6)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.45), width: 1.4),
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
          // مدال رنگی دور آیکون — هم‌خانواده با پلاک‌های جزیره
          Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.85), color],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: compact ? 12 : 14),
          ),
          SizedBox(width: compact ? 3 : 5),
          Text(
            PersianDigits.toFa(value),
            style: AppFonts.kids(
              fontSize: compact ? 13 : 15,
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

  /// نشان گوشهٔ سکو (مثلاً «جدید») — اختیاری
  final String? badge;

  final VoidCallback onTap;

  const _Slot({
    required this.asset,
    required this.label,
    required this.top,
    required this.side,
    required this.widthMul,
    required this.phase,
    required this.onTap,
    this.badge,
  });
}
