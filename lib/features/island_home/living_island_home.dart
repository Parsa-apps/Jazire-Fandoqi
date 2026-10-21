import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_fonts.dart';
import '../../app/island_cinema_style.dart';
import '../../core/audio_service.dart';
import '../../core/game_data.dart';
import '../../core/growth/growth_store.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/learning/today_path.dart';
import '../../core/xp_system.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../../shared/widgets/parent_pin_gate.dart';
import '../../shared/widgets/today_complete_sheet.dart';
import '../home/widgets/daily_gifts_dialog.dart';
import '../home/widgets/island_map/island_map_tab.dart';
import '../profile/profile_editor.dart';
import '../shop/full_version_purchase_entry.dart';
import 'painters/path_icon_painter.dart';
import 'widgets/fandoqi_hero.dart';
import 'widgets/island_logo.dart';
import 'widgets/island_path_card.dart';
import 'widgets/island_scene.dart';
import 'widgets/primary_start_button.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ خانهٔ زندهٔ فندقی — صفحهٔ اصلیِ بازطراحی‌شده
///
/// هدفِ طراحی: «دنیایی غنی برای نگاه‌کردن، سه تصمیم برای گرفتن».
/// کودکِ ۵ساله‌ای که هنوز نمی‌خواند با یک نگاه می‌فهمد:
///   وسطِ تصویر دوستش فندقی است، زیرِ دستش دکمهٔ طلاییِ شروع است،
///   و سه راهِ اصلی با سه نشانِ کاملاً متفاوت جلوی چشم‌اند.
///
/// آنچه حذف شده: منوهای متعدد، بنر، شمارنده‌های تزئینی و متنِ بلند.
/// آنچه حذف نشده: هیچ قابلیتی. نقشهٔ کاملِ جزیره با همهٔ هاب‌ها،
/// مسیرِ خرید، هدیهٔ روزانه، کتابخانه و تنظیماتِ والدین سرِ جایند.
///
/// مسئولیت‌ها اینجا فقط «چیدمان + ناوبری» است؛ رنگ و زمان‌بندی در
/// [IslandCinemaPalette] و صحنه در [IslandScene] زندگی می‌کنند.
/// ═══════════════════════════════════════════════════════════════
class LivingIslandHome extends ConsumerStatefulWidget {
  const LivingIslandHome({
    super.key,
    this.onOpenStageMap,
    this.onOpenBackpack,
    this.onOpenAchievements,
    this.onOpenProfile,
  });

  /// بازکردنِ نقشهٔ مرحله‌ای (تبِ خانه در [HomeScreen] این را می‌دهد)
  final VoidCallback? onOpenStageMap;

  final VoidCallback? onOpenBackpack;
  final VoidCallback? onOpenAchievements;
  final VoidCallback? onOpenProfile;

  @override
  ConsumerState<LivingIslandHome> createState() => _LivingIslandHomeState();
}

class _LivingIslandHomeState extends ConsumerState<LivingIslandHome> {
  final FandoqiHeroController _hero = FandoqiHeroController();

  bool _voiceGuide = false;
  bool _greeted = false;

  @override
  void initState() {
    super.initState();
    _voiceGuide = GrowthStore.voiceGuide;
    // راهنمای صوتی فقط یک‌بار در هر نشست و فقط اگر والد آن را روشن
    // کرده باشد شنیده می‌شود — هیچ صدایِ ناخواسته‌ای پخش نمی‌شود.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _greeted) return;
      _greeted = true;
      if (_voiceGuide) AudioService.speakWord(IslandHomeStrings.startHint);
    });
  }

  @override
  void dispose() {
    _hero.dispose();
    super.dispose();
  }

  // ───────────────────────── ناوبری ─────────────────────────

  /// لمسِ دکمهٔ اصلی: مسیرِ هدایت‌شدهٔ امروز (همان منطقِ [NextTodayButton])
  Future<void> _startToday() async {
    HapticFeedback.mediumImpact();
    AudioService.select();

    if (GameData.isDailyLimitReached) {
      await _showRestDaySheet();
      return;
    }

    final before = TodayPath.countDone();
    final task = TodayPath.forChild();

    if (task.allDone) {
      await showTodayCompleteSheet(context);
      if (!mounted) return;
      _hero.cheer();
      return;
    }

    await Navigator.of(context).pushNamed(task.route);
    if (!mounted) return;

    // برگشت از فعالیت: اگر واقعاً یک ایستگاه تمام شده باشد، تشویقِ کوتاه.
    final after = TodayPath.countDone();
    if (after > before) {
      _hero.cheer();
      AudioService.success();
      if (_voiceGuide) AudioService.speakWord(IslandHomeStrings.cheer);
    }
  }

  Future<void> _openPath(String route, String spokenLabel) async {
    if (_voiceGuide) AudioService.speakWord(spokenLabel);
    await Navigator.of(context).pushNamed(route);
  }

  Future<void> _openIslandMap() async {
    HapticFeedback.lightImpact();
    AudioService.select();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/island-map'),
        builder: (BuildContext context) => IslandMapTab(
          onOpenStageMap: widget.onOpenStageMap,
          onOpenBackpack: widget.onOpenBackpack,
          onOpenAchievements: widget.onOpenAchievements,
        ),
      ),
    );
  }

  Future<void> _openParentPanel() async {
    HapticFeedback.lightImpact();
    final allowed = await requestParentAccess(context);
    if (!mounted || !allowed) return;
    await Navigator.of(context).pushNamed('/parent');
    if (!mounted) return;
    setState(() => _voiceGuide = GrowthStore.voiceGuide);
  }

  Future<void> _openProfile() async {
    HapticFeedback.lightImpact();
    AudioService.select();
    final callback = widget.onOpenProfile;
    if (callback != null) {
      callback();
      return;
    }
    await showProfileEditor(context);
    if (!mounted) return;
    setState(() {});
  }

  /// [showDailyGiftsDialog] هم‌زمان نیست: دیالوگ را می‌سازد و بلافاصله
  /// برمی‌گردد، بنابراین اینجا await معنا ندارد (و روی void خطای
  /// کامپایل می‌دهد). پاداش از طریقِ onRewardClaimed برمی‌گردد.
  void _openGifts() {
    HapticFeedback.lightImpact();
    showDailyGiftsDialog(context, onRewardClaimed: () {
      if (mounted) setState(() {});
    });
  }

  Future<void> _openLibrary() async {
    final callback = widget.onOpenBackpack;
    if (callback != null) {
      callback();
      return;
    }
    await Navigator.of(context).pushNamed('/learning-library');
  }

  void _toggleVoiceGuide() {
    HapticFeedback.selectionClick();
    setState(() {
      _voiceGuide = !_voiceGuide;
      GrowthStore.setVoiceGuide(_voiceGuide);
    });
    if (_voiceGuide) {
      AudioService.speakWord(IslandHomeStrings.start);
    }
  }

  /// پیامِ مثبت برای پایانِ زمانِ بازی — نه تنبیه، نه ترس، نه شرمساری
  Future<void> _showRestDaySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: IslandCinemaPalette.paper,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: IslandCinemaPalette.gold, width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: IslandCinemaPalette.shade.withOpacity(0.20),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🌙', style: TextStyle(fontSize: 46)),
              const SizedBox(height: 10),
              Text(
                IslandHomeStrings.restDay,
                textDirection: TextDirection.rtl,
                style: AppFonts.kids(
                  fontSize: 22,
                  color: IslandCinemaPalette.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                IslandHomeStrings.dailyLimitBody,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppFonts.vazirmatn(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.7,
                  color: IslandCinemaPalette.inkSoft,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: IslandCinemaPalette.gold,
                    foregroundColor: IslandCinemaPalette.woodDeep,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'باشه',
                    style: AppFonts.kids(fontSize: 19),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── چیدمان ─────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.watch(gameStateProvider);

    return IslandScene(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // نوارِ وضعیت حذف می‌شود؛ فضایِ نوارِ پایین را خودِ
          // BottomNavigationBar مدیریت می‌کند. LayoutBuilder *داخل*
          // SafeArea است تا ارتفاعِ در-دسترس دقیق باشد و ستون به‌خاطر
          // نوارِ وضعیت قابلیتِ اسکرولِ اضافه پیدا نکند.
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final compact = h < 660;

                final heroSize = (math.min(w, h) * 0.40).clamp(112.0, 250.0);
                final startHeight =
                    compact ? 66.0 : IslandCinemaMetrics.startButtonHeight;
                final cardHeight =
                    compact ? 104.0 : IslandCinemaMetrics.pathCardHeight;
                final logoFont = (w * 0.072).clamp(20.0, 34.0);
                final crestSize = (w * 0.11).clamp(34.0, 52.0);

                // فاصله‌ها بر اساسِ فضایِ آزاد پخش می‌شوند تا روی صفحهٔ
                // بلند کشیده و روی صفحهٔ کوتاه فشرده شود — همیشه بدون سرریز.
                final fixed = 56.0 + // نوارِ بالا
                    (crestSize + 14) +
                    heroSize +
                    (startHeight + 9) +
                    (cardHeight + 9) +
                    46 + // چیپِ نقشه
                    132; // فضایِ رزرو برای دکمه‌های شناور و کنترلِ موسیقی
                final rawGap = (h - fixed) / 6;
                final gap = rawGap.isFinite ? rawGap.clamp(6.0, 30.0) : 8.0;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildTopBar(context, w),
                        SizedBox(height: gap),
                        Center(
                          child: _fitToWidth(
                            maxWidth: w - 24,
                            child: IslandLogo(
                              fontSize: logoFont,
                              crestSize: crestSize,
                            ),
                          ),
                        ),
                        SizedBox(height: gap),
                        Center(
                          child: FandoqiHero(
                            size: heroSize,
                            controller: _hero,
                            reduceMotion: _reduceMotionOf(context),
                          ),
                        ),
                        SizedBox(height: gap),
                        Center(
                          child: PrimaryStartButton(
                            height: startHeight,
                            maxWidth: w - 24,
                            onTap: _startToday,
                          ),
                        ),
                        SizedBox(height: gap),
                        _buildPathRow(cardHeight),
                        SizedBox(height: gap * 0.6),
                        _buildMapChip(w),
                        const SizedBox(height: 132),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // مسیرِ خرید (هرگز حذف یا شبیه‌سازی نمی‌شود)
          const PositionedDirectional(
            bottom: 112,
            start: 10,
            child: FullVersionPurchaseEntry(compact: true),
          ),

          // هدیهٔ روزانه و کتابخانه
          PositionedDirectional(
            bottom: 112,
            end: 10,
            child: _buildFloatingShortcuts(),
          ),
        ],
      ),
    );
  }

  bool _reduceMotionOf(BuildContext context) {
    return (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
        GrowthStore.reduceMotion;
  }

  /// روی گوشی‌های خیلی باریک (۳۲۰dp) محتوا هرگز از عرضِ صفحه بیرون
  /// نمی‌زند: اگر از فضایِ موجود بزرگ‌تر بود، با همان نسبت کوچک می‌شود
  /// (در غیر این صورت یک RenderFlex سرریز می‌داد). روی صفحهٔ معمولی
  /// هیچ اثری ندارد، چون [BoxFit.scaleDown] هرگز چیزی را بزرگ نمی‌کند.
  Widget _fitToWidth({required double maxWidth, required Widget child}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: FittedBox(fit: BoxFit.scaleDown, child: child),
    );
  }

  /// نوارِ بالا: پروفایل، سطحِ واقعی، راهنمای صوتی و تنظیماتِ والدین.
  ///
  /// همهٔ این‌ها در یک ردیفِ «چسبیده به آغاز» (سمتِ راست در RTL) جمع
  /// شده‌اند و انتهایِ ردیف با Spacer خالی می‌ماند تا با دکمهٔ صدایِ
  /// سراسریِ [HomeScreen] تداخل نکند.
  Widget _buildTopBar(BuildContext context, double width) {
    final name = GameData.childName.trim();
    // نام فقط وقتی جا دارد که عرض واقعاً کافی باشد؛ در غیر این صورت
    // فقط آواتار نمایش داده می‌شود تا چهار کنترلِ ردیف روی هم سوار نشوند.
    final showName = width >= 430 && name.isNotEmpty;
    // روی گوشیِ ۳۲۰dp فاصله‌ها و نشانِ سطح کمی جمع می‌شوند تا چهار
    // کنترلِ این ردیف قطعاً در عرضِ در-دسترس جا بگیرند.
    final tight = width < 380;
    final barGap = tight ? 6.0 : 8.0;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 10, 0),
      child: Row(
        children: <Widget>[
          _ProfileChip(
            avatar: GameData.avatar,
            name: showName ? name : null,
            onTap: _openProfile,
          ),
          SizedBox(width: barGap),
          _LevelBadge(
            level: GameData.islandLevel,
            progress: GameData.islandLevelProgress,
            width: tight ? 74.0 : 96.0,
          ),
          SizedBox(width: barGap),
          _RoundGlassButton(
            icon: _voiceGuide
                ? Icons.record_voice_over
                : Icons.voice_chat_outlined,
            color: _voiceGuide
                ? IslandCinemaPalette.pathLearn
                : IslandCinemaPalette.inkSoft,
            tooltip: _voiceGuide
                ? IslandHomeStrings.voiceGuideOn
                : IslandHomeStrings.voiceGuideOff,
            onTap: _toggleVoiceGuide,
          ),
          const SizedBox(width: 8),
          _RoundGlassButton(
            icon: Icons.shield_rounded,
            color: IslandCinemaPalette.forestDeep,
            tooltip: IslandHomeStrings.parentSettings,
            onTap: _openParentPanel,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFloatingShortcuts() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _RoundGlassButton(
          icon: Icons.card_giftcard_rounded,
          color: const Color(0xFFE91E63),
          tooltip: IslandHomeStrings.dailyGift,
          onTap: _openGifts,
        ),
        const SizedBox(height: 10),
        _RoundGlassButton(
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF00897B),
          tooltip: IslandHomeStrings.library,
          onTap: _openLibrary,
        ),
      ],
    );
  }

  Widget _buildPathRow(double cardHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: IslandPathCard(
              label: IslandHomeStrings.play,
              icon: IslandPathIcon.play,
              baseColor: IslandCinemaPalette.pathPlay,
              deepColor: IslandCinemaPalette.pathPlayDeep,
              height: cardHeight,
              semanticHint: IslandHomeStrings.playHint,
              onTap: () => _openPath('/games-carnival', IslandHomeStrings.play),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: IslandPathCard(
              label: IslandHomeStrings.learn,
              icon: IslandPathIcon.learn,
              baseColor: IslandCinemaPalette.pathLearn,
              deepColor: IslandCinemaPalette.pathLearnDeep,
              height: cardHeight,
              semanticHint: IslandHomeStrings.learnHint,
              onTap: () =>
                  _openPath('/learning-library', IslandHomeStrings.learn),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: IslandPathCard(
              label: IslandHomeStrings.story,
              icon: IslandPathIcon.story,
              baseColor: IslandCinemaPalette.pathStory,
              deepColor: IslandCinemaPalette.pathStoryDeep,
              height: cardHeight,
              semanticHint: IslandHomeStrings.storyHint,
              onTap: () => _openPath('/stories', IslandHomeStrings.story),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapChip(double width) {
    // نکتهٔ مهم: ویجتِ لمسی (InkWell) هرگز داخل FittedBox پیچیده نمی‌شود،
    // چون FittedBox مختصاتِ اشاره‌گر را تبدیل نمی‌کند و لمس به خطا می‌رود.
    // فقط برچسبِ متنی کوچک می‌شود.
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _openIslandMap,
          child: Listener(
            // InkWell به‌طور پیش‌فرض فقط جایی لمس را قبول می‌کند که یکی از
            // فرزندانش خودش قابل‌لمس باشد (deferToChild). آیکون و متن کلِ
            // سطحِ این چیپ را نمی‌پوشانند، پس لمسِ وسطِ دکمه عملاً گم می‌شد
            // و نقشه باز نمی‌شد. این Listener با رفتارِ translucent کلِ سطح
            // را قابل‌لمس می‌کند، بی‌آنکه رویداد را ببلعد — پس موجِ InkWell
            // هم سر جایش می‌ماند.
            behavior: HitTestBehavior.translucent,
            child: Semantics(
              button: true,
              label: IslandHomeStrings.islandMap,
              hint: IslandHomeStrings.islandMapHint,
              child: Container(
                key: const ValueKey<String>('living_island_map_chip'),
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: IslandCinemaPalette.paper.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: IslandCinemaPalette.forest.withOpacity(0.7),
                    width: 2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: IslandCinemaPalette.shade.withOpacity(0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.explore_rounded,
                      size: 22,
                      color: IslandCinemaPalette.forestDeep,
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: width * 0.5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          IslandHomeStrings.islandMap,
                          textDirection: TextDirection.rtl,
                          style: AppFonts.kids(
                            fontSize: 16,
                            color: IslandCinemaPalette.forestDeep,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── اجزایِ کوچک ─────────────────────────

/// چیپِ پروفایل: آواتارِ واقعیِ کودک و (در صفحهٔ عریض) نامش
class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.avatar,
    required this.name,
    required this.onTap,
  });

  final String avatar;
  final String? name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: IslandHomeStrings.profile,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          height: 48,
          padding: const EdgeInsetsDirectional.fromSTEB(6, 4, 14, 4),
          decoration: BoxDecoration(
            color: IslandCinemaPalette.paper.withOpacity(0.94),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: IslandCinemaPalette.goldDeep.withOpacity(0.9),
              width: 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: IslandCinemaPalette.shade.withOpacity(0.14),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: IslandCinemaGradients.meadow,
                ),
                child: Text(
                  avatar,
                  style: const TextStyle(fontSize: 21),
                ),
              ),
              if (name != null) ...<Widget>[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 84),
                  child: Text(
                    name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: AppFonts.kids(
                      fontSize: 15.5,
                      color: IslandCinemaPalette.ink,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// نشانِ سطح: فقط عددِ واقعیِ [XpSystem]، هیچ امتیازِ ساختگی
class _LevelBadge extends StatelessWidget {
  const _LevelBadge({
    required this.level,
    required this.progress,
    this.width = 96,
  });

  final int level;
  final double progress;

  /// روی صفحهٔ باریک باریک‌تر می‌شود تا ردیفِ بالا سرریز نکند.
  final double width;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    return Semantics(
      container: true,
      label: XpSystem.levelLabel(level),
      value: '${(clampedProgress * 100).round()} درصد تا سطح بعد',
      child: ExcludeSemantics(
        child: Container(
          width: width,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: IslandCinemaPalette.paper.withOpacity(0.94),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: IslandCinemaPalette.forest.withOpacity(0.7),
              width: 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: IslandCinemaPalette.shade.withOpacity(0.14),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.eco_rounded,
                    size: 15,
                    color: IslandCinemaPalette.forest,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'سطح ${PersianDigits.toFa(level)}',
                        maxLines: 1,
                        textDirection: TextDirection.rtl,
                        style: AppFonts.kids(
                          fontSize: 13.5,
                          color: IslandCinemaPalette.forestDeep,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 5,
                  child: LinearProgressIndicator(
                    value: clampedProgress,
                    backgroundColor: IslandCinemaPalette.mint.withOpacity(0.40),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      IslandCinemaPalette.gold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// دکمهٔ گردِ شیشه‌ای برای کنترل‌های ثانویه
class _RoundGlassButton extends StatelessWidget {
  const _RoundGlassButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: ExcludeSemantics(
        child: Tooltip(
          message: tooltip,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              AudioService.tap();
              onTap();
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: IslandCinemaPalette.paper.withOpacity(0.95),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.45), width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: IslandCinemaPalette.shade.withOpacity(0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 24, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
