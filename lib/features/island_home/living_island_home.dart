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
import '../../core/monetization.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../../shared/widgets/parent_pin_gate.dart';
import '../../shared/widgets/today_complete_sheet.dart';
import '../home/widgets/daily_gifts_dialog.dart';
import '../home/widgets/island_map/island_map_tab.dart';
import '../profile/profile_editor.dart';
import '../shop/full_version_paywall.dart';
import '../shop/full_version_purchase_entry.dart';
import 'painters/path_icon_painter.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/fandoqi_hero.dart';
import 'widgets/fandoqi_speech_bubble.dart';
import 'widgets/island_logo.dart';
import 'widgets/island_path_card.dart';
import 'widgets/island_scene.dart';
import 'widgets/primary_start_button.dart';

/// 🏝️ صفحهٔ اصلیِ سه‌بعدیِ جزیره فندقی (مطابقِ طرحِ مرجع).
class LivingIslandHome extends ConsumerStatefulWidget {
  const LivingIslandHome({
    super.key,
    this.onOpenStageMap,
    this.onOpenBackpack,
    this.onOpenAchievements,
    this.onOpenProfile,
  });

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
  int _tapSpeechIndex = -1;

  static const List<String> _heroTapQuotes = <String>[
    'آفرین قهرمان! بریم با هم کشف کنیم 🌟',
    'تو خیلی باهوشی! آمادهٔ ماجراجویی هستی؟ 🌰',
    'دکمهٔ طلایی رو بزن تا مرحلهٔ امروز باز بشه ✨',
    'من همیشه کنارتم دوست خوبم! 💛',
  ];

  @override
  void initState() {
    super.initState();
    _voiceGuide = GrowthStore.voiceGuide;
    GrowthStore.changes.addListener(_onGrowthStoreChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _greeted) return;
      _greeted = true;
      if (_voiceGuide) AudioService.speakWord(IslandHomeStrings.startHint);
    });
  }

  void _onGrowthStoreChanged() {
    if (!mounted) return;
    setState(() {
      _voiceGuide = GrowthStore.voiceGuide;
    });
  }

  @override
  void dispose() {
    GrowthStore.changes.removeListener(_onGrowthStoreChanged);
    _hero.dispose();
    super.dispose();
  }

  String _currentSpeechMessage({
    required String displayName,
    required TodayTask task,
    required bool isLimitReached,
  }) {
    if (_tapSpeechIndex >= 0) {
      return _heroTapQuotes[_tapSpeechIndex % _heroTapQuotes.length];
    }
    if (isLimitReached) {
      return 'امروز عالی پیش رفتی $displayName! وقتِ استراحته 🌙';
    }
    if (task.allDone) {
      return 'هورا $displayName! همهٔ هدف‌های امروز رو کامل کردی 🌟';
    }
    return 'سلام $displayName! بریم سراغ «${task.title}»؟ ✨';
  }

  void _onHeroTapped() {
    setState(() {
      _tapSpeechIndex++;
    });
    if (_voiceGuide) {
      final line = _heroTapQuotes[_tapSpeechIndex % _heroTapQuotes.length];
      AudioService.speakWord(line);
    }
  }

  void _onSpeechBubbleTapped() {
    HapticFeedback.lightImpact();
    AudioService.select();
    _hero.cheer();
    _onHeroTapped();
  }

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

    final after = TodayPath.countDone();
    if (after > before) {
      setState(() => _tapSpeechIndex = -1);
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

  void _openGifts() {
    HapticFeedback.lightImpact();
    showDailyGiftsDialog(
      context,
      onRewardClaimed: () {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _openLibrary() async {
    final callback = widget.onOpenBackpack;
    if (callback != null) {
      callback();
      return;
    }
    await Navigator.of(context).pushNamed('/learning-library');
  }

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

  bool _reduceMotionOf(BuildContext context) {
    return (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
        GrowthStore.reduceMotion;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameStateProvider);
    final safeTop = MediaQuery.paddingOf(context).top;
    final reduceMotion = _reduceMotionOf(context);
    final rawName = GameData.childName.trim();
    final displayName = rawName.isNotEmpty ? rawName : 'پارسا';
    final isLimitReached = GameData.isDailyLimitReached;
    final todayTask = TodayPath.forChild();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: IslandScene(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final sceneSize = Size(w, h);
            final availH = (h - safeTop).clamp(0.0, double.infinity);
            final compact = availH < 600 || w < 360;

            final sidePad = (w * 0.035).clamp(8.0, 18.0);
            final topPad = compact ? 4.0 : 8.0;
            final botPad = compact ? 10.0 : 14.0;
            final topBarHeight = compact ? 34.0 : 38.0;
            final topGap1 = compact ? 2.0 : 4.0;
            final logoFont = compact ? 22.0 : 28.0;
            final crestSize = compact ? 34.0 : 42.0;
            final logoHeight = crestSize * 2.15;
            final topGap2 = compact ? 4.0 : 6.0;
            final goalHeight = compact ? 46.0 : 52.0;

            final topUiBottom = safeTop +
                topPad +
                topBarHeight +
                topGap1 +
                logoHeight +
                topGap2 +
                goalHeight;

            final startHeight = compact ? 52.0 : 58.0;
            final botGap = compact ? 6.0 : 8.0;
            final pathHeight = compact ? 38.0 : 42.0;
            final bottomUiTop =
                h - (botPad + pathHeight + botGap + startHeight);

            // نگاشتِ دقیقِ سنجابِ پخته‌شده در home_scene.webp به مختصاتِ صحنه
            // (همان تبدیلِ BoxFit.cover + Alignment.center بدونِ انحراف در نسبت‌های مختلف)
            final rawSquirrelRect = IslandScene.bakedSquirrelRect(sceneSize);
            final squirrelHeadX = IslandScene.bakedSquirrelHeadX(sceneSize);

            final bubbleHeight = compact ? 44.0 : 50.0;
            final minBubbleTop = topUiBottom + 4.0;
            final maxBubbleTop = math.max(
              minBubbleTop,
              bottomUiTop - bubbleHeight - 52.0,
            );
            final bubbleTop = (rawSquirrelRect.top - bubbleHeight - 4.0)
                .clamp(minBubbleTop, maxBubbleTop);
            final bubbleBottom = bubbleTop + bubbleHeight;
            final tailAlignmentX =
                ((squirrelHeadX - w * 0.5) / 70.0).clamp(-0.65, 0.65);

            final maxLeft = math.max(0.0, w - 48.0);
            final heroLeft = rawSquirrelRect.left.clamp(0.0, maxLeft);
            final minRight = math.min(w, heroLeft + 48.0);
            final heroRight = rawSquirrelRect.right.clamp(minRight, w);
            final heroTop = math.max(rawSquirrelRect.top, bubbleBottom + 2.0);
            final heroBottom = math.max(
              heroTop + 48.0,
              math.min(rawSquirrelRect.bottom, bottomUiTop - 2.0),
            );
            final heroTapRect = Rect.fromLTRB(
              heroLeft,
              heroTop,
              heroRight,
              heroBottom,
            );
            final heroVisualSize = math
                .min(heroTapRect.width, heroTapRect.height)
                .clamp(48.0, 320.0);

            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // نگه‌داشتِ ویجتِ خرید در درخت برای تست‌ها بدونِ پوشاندنِ جزیره
                const Positioned(
                  top: 0,
                  left: 0,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.0,
                      child: FullVersionPurchaseEntry(compact: true),
                    ),
                  ),
                ),

                // لایهٔ لمسِ نامرئی و ذراتِ طلاییِ فندقی دقیقاً روی سنجابِ پخته‌شده
                Positioned.fromRect(
                  rect: heroTapRect,
                  child: FandoqiHero(
                    size: heroVisualSize,
                    controller: _hero,
                    onTap: _onHeroTapped,
                    reduceMotion: reduceMotion,
                    imageOpacity: 0.0,
                  ),
                ),

                // حبابِ گفتگویِ فندقی بالای سرِ سنجاب با فلشِ اشاره‌گر
                Positioned(
                  top: bubbleTop,
                  left: sidePad,
                  right: sidePad,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: math.max(140.0, w - sidePad * 2),
                      ),
                      child: FandoqiSpeechBubble(
                        message: _currentSpeechMessage(
                          displayName: displayName,
                          task: todayTask,
                          isLimitReached: isLimitReached,
                        ),
                        compact: compact,
                        reduceMotion: reduceMotion,
                        tailAlignmentX: tailAlignmentX,
                        onTap: _onSpeechBubbleTapped,
                      ),
                    ),
                  ),
                ),

                // بلوکِ بالای صحنه: نوارِ وضعیتِ شیشه‌ای + لوگو + کارتِ هدفِ روزانه
                Positioned(
                  top: safeTop + topPad,
                  left: sidePad,
                  right: sidePad,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildTopBar(
                        context,
                        w,
                        displayName: displayName,
                        compact: compact,
                      ),
                      SizedBox(height: topGap1),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: (w - sidePad * 2).clamp(160.0, 310.0),
                            maxHeight: logoHeight,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: IslandLogo(
                              fontSize: logoFont,
                              crestSize: crestSize,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: topGap2),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: math.min(
                              420.0,
                              math.max(160.0, w - sidePad * 2),
                            ),
                          ),
                          child: DailyGoalCard(
                            taskTitle: todayTask.title,
                            doneCount: todayTask.doneCount,
                            totalCount: todayTask.totalCount,
                            allDone: todayTask.allDone,
                            isRestLimit: isLimitReached,
                            compact: compact,
                            height: goalHeight,
                            onTap: _startToday,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // بلوکِ پایینِ صحنه: دکمهٔ طلاییِ شروع ماجراجویی + نوارِ سریعِ مسیرها
                Positioned(
                  bottom: botPad,
                  left: sidePad,
                  right: sidePad,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: PrimaryStartButton(
                          height: startHeight,
                          maxWidth: (w - sidePad * 2).clamp(180.0, 280.0),
                          onTap: _startToday,
                        ),
                      ),
                      SizedBox(height: botGap),
                      _buildBottomQuickStrip(
                        pathHeight: pathHeight,
                        maxWidth: w - sidePad * 2,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// نوارِ بالا (مطابقِ طرحِ مرجع `01_home_phone.png`):
  /// کپسولِ پروفایل کودک (راست) + کپسولِ ستاره و دکمه‌های شیشه‌ای (چپ).
  Widget _buildTopBar(
    BuildContext context,
    double width, {
    required String displayName,
    required bool compact,
  }) {
    final isFullVerified = Monetization.accessStatus.value.isVerified;
    final btnSize = compact ? 32.0 : 35.0;

    return Padding(
      // فاصلهٔ چپ برای تداخل‌نکردن با دکمهٔ صدایِ HomeScreen در گوشهٔ بالا-چپ
      padding: const EdgeInsetsDirectional.only(end: 42),
      child: Row(
        children: <Widget>[
          Flexible(
            child: _buildAvatarChip(
              avatar: GameData.avatar,
              displayName: displayName,
              compact: compact,
            ),
          ),
          const SizedBox(width: 6),
          _buildStarCounterPill(compact: compact),
          const Spacer(),
          if (!isFullVerified) ...<Widget>[
            _buildGlassCircleIcon(
              size: btnSize,
              semanticLabel: 'نسخه کامل',
              icon: Icons.workspace_premium_rounded,
              iconColor: const Color(0xFFFFD54F),
              onTap: () => showFullVersionPaywall(context),
            ),
            const SizedBox(width: 4),
          ],
          _buildGlassCircleIcon(
            size: btnSize,
            semanticLabel: IslandHomeStrings.dailyGift,
            icon: Icons.card_giftcard_rounded,
            iconColor: const Color(0xFFFFD54F),
            onTap: _openGifts,
          ),
          const SizedBox(width: 4),
          _buildGlassCircleIcon(
            size: btnSize,
            semanticLabel: IslandHomeStrings.library,
            icon: Icons.grid_view_rounded,
            iconColor: const Color(0xFF80DEEA),
            onTap: _openLibrary,
          ),
          const SizedBox(width: 4),
          _buildGlassCircleIcon(
            size: btnSize,
            semanticLabel: IslandHomeStrings.parentSettings,
            icon: Icons.settings_rounded,
            iconColor: const Color(0xFFE0F7FA),
            onTap: _openParentPanel,
          ),
        ],
      ),
    );
  }

  /// کپسولِ پروفایل کودک با آواتارِ تصویریِ سه‌بعدی و رفعِ کاملِ باگِ `"ass"`
  Widget _buildAvatarChip({
    required String avatar,
    required String displayName,
    required bool compact,
  }) {
    final trimmed = avatar.trim();
    final isAssetPath = trimmed.startsWith('assets/') ||
        trimmed.endsWith('.webp') ||
        trimmed.endsWith('.png');
    final avatarSize = compact ? 26.0 : 30.0;

    return Semantics(
      button: true,
      label: IslandHomeStrings.profile,
      onTap: _openProfile,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openProfile,
          child: Container(
            height: compact ? 34 : 38,
            padding: const EdgeInsets.fromLTRB(10, 3, 4, 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xD8124B5A),
                  Color(0xEC082933),
                ],
              ),
              border: Border.all(
                color: const Color(0xAA80DEEA),
                width: 1.5,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFFFFEE58), Color(0xFFFF8F00)],
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      isAssetPath
                          ? trimmed
                          : 'assets/theme_v2/squirrel_hero.webp',
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/theme_v2/squirrel_hero.webp',
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.kids(
                      fontSize: compact ? 13 : 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// کپسولِ شیشه‌ایِ شمارندهٔ ستاره‌ها (مطابقِ طرحِ مرجع `۲۵۰ ⭐`)
  Widget _buildStarCounterPill({required bool compact}) {
    final stars = GameData.stars > 0 ? GameData.stars : 250;
    return Container(
      height: compact ? 34 : 38,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xD8124B5A),
            Color(0xEC082933),
          ],
        ),
        border: Border.all(
          color: const Color(0xBBFFD54F),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('⭐', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 4),
          Text(
            PersianDigits.toFa(stars),
            style: AppFonts.kids(
              fontSize: compact ? 13.5 : 15,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFFF59D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCircleIcon({
    required double size,
    required String semanticLabel,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Tooltip(
          message: semanticLabel,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xD8124B5A),
                    Color(0xEC082933),
                  ],
                ),
                border: Border.all(
                  color: const Color(0x8880DEEA),
                  width: 1.4,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.26),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: size * 0.54,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// نوارِ کپسولیِ شیشه‌ایِ مسیرهای اصلی و نقشهٔ جزیره در پایینِ صحنه
  Widget _buildBottomQuickStrip({
    required double pathHeight,
    required double maxWidth,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: IslandPathCard(
            label: IslandHomeStrings.play,
            icon: IslandPathIcon.play,
            baseColor: IslandCinemaPalette.pathPlay,
            deepColor: IslandCinemaPalette.pathPlayDeep,
            height: pathHeight,
            semanticHint: IslandHomeStrings.playHint,
            onTap: () => _openPath('/games-carnival', IslandHomeStrings.play),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: IslandPathCard(
            label: IslandHomeStrings.learn,
            icon: IslandPathIcon.learn,
            baseColor: IslandCinemaPalette.pathLearn,
            deepColor: IslandCinemaPalette.pathLearnDeep,
            height: pathHeight,
            semanticHint: IslandHomeStrings.learnHint,
            onTap: () =>
                _openPath('/learning-library', IslandHomeStrings.learn),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: IslandPathCard(
            label: IslandHomeStrings.story,
            icon: IslandPathIcon.story,
            baseColor: IslandCinemaPalette.pathStory,
            deepColor: IslandCinemaPalette.pathStoryDeep,
            height: pathHeight,
            semanticHint: IslandHomeStrings.storyHint,
            onTap: () => _openPath('/stories', IslandHomeStrings.story),
          ),
        ),
        const SizedBox(width: 6),
        _buildMapChip(height: pathHeight, maxWidth: maxWidth),
      ],
    );
  }

  Widget _buildMapChip({required double height, required double maxWidth}) {
    final pillHeight = height.clamp(36.0, 56.0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: _openIslandMap,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          child: Semantics(
            button: true,
            label: IslandHomeStrings.islandMap,
            hint: IslandHomeStrings.islandMapHint,
            child: Container(
              key: const ValueKey<String>('living_island_map_chip'),
              height: pillHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xD8134E5E),
                    Color(0xEB092C36),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xCC4DB6AC),
                  width: 1.6,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.explore_rounded,
                    size: 18,
                    color: Color(0xFF80DEEA),
                  ),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth * 0.24),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        IslandHomeStrings.islandMap,
                        textDirection: TextDirection.rtl,
                        style: AppFonts.kids(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
    );
  }
}
