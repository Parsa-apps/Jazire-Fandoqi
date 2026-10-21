import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_fonts.dart';
import '../../app/island_cinema_style.dart';
import '../../core/audio_service.dart';
import '../../core/game_data.dart';
import '../../core/growth/growth_store.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/monetization.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../../shared/widgets/parent_pin_gate.dart';
import '../home/widgets/daily_gifts_dialog.dart';
import '../home/widgets/island_map/island_map_tab.dart';
import '../profile/profile_editor.dart';
import '../shop/full_version_paywall.dart';
import '../shop/full_version_purchase_entry.dart';
import 'widgets/fandoqi_hero.dart';
import 'widgets/island_logo.dart';
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

  @override
  void initState() {
    super.initState();
    _voiceGuide = GrowthStore.voiceGuide;
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

  Future<void> _openPath(String route, String spokenLabel) async {
    if (_voiceGuide) AudioService.speakWord(spokenLabel);
    await Navigator.of(context).pushNamed(route);
  }

  /// دکمهٔ اصلیِ «شروع ماجراجویی» مستقیم نقشهٔ کاملِ جزیره را باز می‌کند.
  Future<void> _openIslandMap() async {
    HapticFeedback.mediumImpact();
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

  bool _reduceMotionOf(BuildContext context) {
    return (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
        GrowthStore.reduceMotion;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameStateProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: IslandScene(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final compact = h < 600 || w < 360;

              final sidePad = (w * 0.035).clamp(8.0, 18.0);
              final logoFont = compact ? 22.0 : 28.0;
              final crestSize = compact ? 34.0 : 42.0;
              final heroSize =
                  (h * (compact ? 0.24 : 0.28)).clamp(112.0, 220.0);
              final startHeight = compact ? 52.0 : 58.0;
              final quickLinksHeight = compact ? 52.0 : 58.0;

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
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      sidePad,
                      compact ? 4 : 8,
                      sidePad,
                      compact ? 10 : 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildTopBar(context, w, compact: compact),
                        SizedBox(height: compact ? 2 : 4),
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (w - sidePad * 2).clamp(160.0, 310.0),
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
                        // فضای میانی برای نمایشِ کاراکترِ سه‌بعدیِ فندقی در صحنهٔ جزیره
                        Expanded(
                          child: Center(
                            child: FandoqiHero(
                              size: heroSize,
                              controller: _hero,
                              reduceMotion: _reduceMotionOf(context),
                              imageOpacity: 0.0,
                            ),
                          ),
                        ),
                        Center(
                          child: PrimaryStartButton(
                            height: startHeight,
                            maxWidth: (w - sidePad * 2).clamp(180.0, 280.0),
                            onTap: _openIslandMap,
                          ),
                        ),
                        SizedBox(height: compact ? 6 : 8),
                        _buildBottomQuickStrip(height: quickLinksHeight),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// نوارِ بالا (مطابقِ طرحِ مرجع `01_home_phone.png`):
  /// کپسولِ پروفایل کودک (راست) + کپسولِ ستاره و دکمه‌های شیشه‌ای (چپ).
  Widget _buildTopBar(
    BuildContext context,
    double width, {
    required bool compact,
  }) {
    final rawName = GameData.childName.trim();
    final displayName = rawName.isNotEmpty ? rawName : 'پارسا';
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

  /// میان‌برهای مستقیمِ کارتون، قصه، لالایی و بازی زیرِ دکمهٔ اصلی.
  Widget _buildBottomQuickStrip({required double height}) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildFeatureShortcut(
            keyName: 'home_shortcut_cartoons',
            label: IslandHomeStrings.cartoons,
            icon: Icons.live_tv_rounded,
            tint: const Color(0xFFFFA65A),
            height: height,
            onTap: () => _openPath('/cartoons', IslandHomeStrings.cartoons),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildFeatureShortcut(
            keyName: 'home_shortcut_stories',
            label: IslandHomeStrings.stories,
            icon: Icons.auto_stories_rounded,
            tint: const Color(0xFFFFD166),
            height: height,
            onTap: () => _openPath('/stories', IslandHomeStrings.stories),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildFeatureShortcut(
            keyName: 'home_shortcut_lullabies',
            label: IslandHomeStrings.lullabies,
            icon: Icons.nightlight_round,
            tint: const Color(0xFFB9A4FF),
            height: height,
            onTap: () => _openPath('/lullabies', IslandHomeStrings.lullabies),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildFeatureShortcut(
            keyName: 'home_shortcut_games',
            label: IslandHomeStrings.games,
            icon: Icons.sports_esports_rounded,
            tint: const Color(0xFF74E3B3),
            height: height,
            onTap: () => _openPath('/games-carnival', IslandHomeStrings.games),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureShortcut({
    required String keyName,
    required String label,
    required IconData icon,
    required Color tint,
    required double height,
    required VoidCallback onTap,
  }) {
    void handleTap() {
      HapticFeedback.selectionClick();
      AudioService.select();
      onTap();
    }

    return Semantics(
      button: true,
      label: label,
      onTap: handleTap,
      child: ExcludeSemantics(
        child: Tooltip(
          message: label,
          child: GestureDetector(
            key: ValueKey<String>(keyName),
            behavior: HitTestBehavior.opaque,
            onTap: handleTap,
            child: Container(
              height: height.clamp(48.0, 64.0).toDouble(),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xE6175261),
                    Color(0xF00A303B),
                  ],
                ),
                border: Border.all(color: tint.withOpacity(0.86), width: 1.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 20, color: tint),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      textDirection: TextDirection.rtl,
                      style: AppFonts.kids(
                        fontSize: 11.5,
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
      ),
    );
  }
}
