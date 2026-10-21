import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../shared/widgets/html_web_view.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../gateway/learning_library_screen.dart';
import '../island_home/living_island_home.dart';
import '../profile/profile_screen.dart';
import '../stage_map/stage_map_screen.dart';
import 'widgets/achievements_tab.dart';
import 'widgets/report_card_tab.dart';

/// ═══════════════════════════════════════════════
/// 🏠 HOME SCREEN — صفحه اصلی جزیره فندقی
/// نوار ناوبری کودکانه با خانهٔ برجسته و هویت بصری جزیره
/// ═══════════════════════════════════════════════
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // تب خانه (مرکزی) تب پیش‌فرض شروع برنامه است
  int _currentTab = 2;
  late double _musicVolume;
  final List<Widget?> _tabWidgets = List<Widget?>.filled(5, null);

  @override
  void initState() {
    super.initState();
    _musicVolume = GameData.musicVolume;
    _tabWidgets[2] = _buildIslandHome();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameData.playedGames.length >= 5 || GameData.streak >= 7) {
        FandoghiCoach.celebrate(
          'چه عالی که دوباره برگشتی! ادامه بده قهرمان 🌟',
        );
      }
    });
  }

  void _selectTab(int index) {
    setState(() => _currentTab = index);
    AudioService.playBgmSection(index == 1 ? 'learning' : 'home');
  }

  void _openStageMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/game/stage-map'),
        builder: (_) => const StageMapScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameStateProvider);
    final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;

    return Scaffold(
      body: Stack(
        children: [
          // ── لایهٔ پس‌زمینهٔ لایو والپیپر فوق حرفه‌ای (HTML) ──
          Positioned.fill(
            child: IgnorePointer(
              child: HtmlWebView(assetPath: 'assets/web/live_wallpaper.html'),
            ),
          ),

          // ── لایهٔ پس‌زمینهٔ اپلیکیشن جادویی حیرت‌انگیز (HTML) ──
          Positioned.fill(
            child: IgnorePointer(
              child: HtmlWebView(assetPath: 'assets/web/magic_wonder.html'),
            ),
          ),

          Positioned.fill(
            child: IndexedStack(
              index: _currentTab,
              // صفحات حفظ‌شده در IndexedStack زنده می‌مانند؛ فقط صفحهٔ قابل‌دیدن
              // اجازهٔ ادامهٔ تیکرهای انیمیشن را دارد.
              children: List<Widget>.generate(
                5,
                (index) => TickerMode(
                  enabled: index == _currentTab && routeIsCurrent,
                  child: _tabFor(index),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 10,
            child: SafeArea(child: _buildSoundToggle()),
          ),

          if (_currentTab == 2)
            Positioned(
              left: 10,
              bottom: 10,
              child: SafeArea(
                top: false,
                child: _buildMusicVolumeControl(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSoundToggle() {
    final enabled = GameData.soundEnabled;
    final toggleColor = enabled
        ? IslandWorldPalette.deepOcean
        : IslandWorldPalette.coral;
    return Semantics(
      button: true,
      label: enabled ? 'قطع همه صداها' : 'روشن کردن صداها',
      child: Tooltip(
        message: enabled ? 'بی‌صدا' : 'با صدا',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              HapticFeedback.selectionClick();
              GameData.setSoundEnabled(!enabled);
              await AudioService.syncSoundSetting();
              if (mounted) setState(() {});
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: IslandWorldPalette.paper.withOpacity(0.96),
                border: Border.all(
                  color: IslandWorldPalette.softOutline,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: IslandWorldPalette.ink.withOpacity(0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: toggleColor,
                size: 29,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _previewMusicVolume(double value) {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    setState(() => _musicVolume = normalized);
    AudioService.setBgmVolume(normalized);
  }

  void _saveMusicVolume(double value) {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    GameData.setMusicVolume(normalized);
    AudioService.setBgmVolume(normalized);
  }

  void _stepMusicVolume(int step) {
    final nextStep = ((_musicVolume * 10).round() + step).clamp(0, 10);
    final next = nextStep / 10.0;
    if (next == _musicVolume) return;
    HapticFeedback.selectionClick();
    AudioService.tap();
    _previewMusicVolume(next);
    _saveMusicVolume(next);
  }

  Widget _buildMusicVolumeControl() {
    final percent = (_musicVolume * 100).round();
    final isMuted = percent == 0;

    return Semantics(
      container: true,
      label: 'تنظیم صدای موسیقی',
      value: '$percent درصد',
      child: Container(
        key: const Key('music-volume-control'),
        // Material's Slider keeps a minimum gesture width. At 224px the two
        // step buttons left too little room and overflowed even on a normal
        // phone; 248px still fits a 320px viewport beside the map shortcuts.
        width: 248,
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
        decoration: BoxDecoration(
          color: IslandWorldPalette.paper.withOpacity(0.98),
          borderRadius: BorderRadius.circular(IslandWorldMetrics.buttonRadius),
          border: Border.all(
            color: IslandWorldPalette.foliage.withOpacity(0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: IslandWorldPalette.deepOcean.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                children: [
                  Icon(
                    isMuted
                        ? Icons.music_off_rounded
                        : Icons.music_note_rounded,
                    size: 20,
                    color: isMuted
                        ? IslandWorldPalette.coral
                        : IslandWorldPalette.foliageDeep,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'صدای موسیقی',
                    style: AppFonts.kids(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: IslandWorldPalette.ink,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$percent٪',
                    style: AppFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: IslandWorldPalette.deepOcean,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  key: const Key('decrease-music-volume'),
                  tooltip: 'کاهش صدای موسیقی',
                  onPressed:
                      _musicVolume > 0 ? () => _stepMusicVolume(-1) : null,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 38,
                    height: 38,
                  ),
                  icon: const Icon(Icons.volume_down_rounded, size: 23),
                  color: IslandWorldPalette.foliageDeep,
                  disabledColor: IslandWorldPalette.mutedInk.withOpacity(0.55),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 5,
                      activeTrackColor: IslandWorldPalette.foliage,
                      inactiveTrackColor: IslandWorldPalette.softOutline,
                      thumbColor: IslandWorldPalette.honey,
                      overlayColor:
                          IslandWorldPalette.honey.withOpacity(0.16),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 9,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 17,
                      ),
                    ),
                    child: Slider(
                      key: const Key('music-volume-slider'),
                      value: _musicVolume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      onChanged: _previewMusicVolume,
                      onChangeEnd: _saveMusicVolume,
                      semanticFormatterCallback: (value) =>
                          '${(value * 100).round()} درصد',
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('increase-music-volume'),
                  tooltip: 'افزایش صدای موسیقی',
                  onPressed:
                      _musicVolume < 1 ? () => _stepMusicVolume(1) : null,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 38,
                    height: 38,
                  ),
                  icon: const Icon(Icons.volume_up_rounded, size: 23),
                  color: IslandWorldPalette.foliageDeep,
                  disabledColor: IslandWorldPalette.mutedInk.withOpacity(0.55),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🏝️ تبِ خانه: دنیای زندهٔ جزیره.
  ///
  /// نقشهٔ کامل ([IslandMapTab]) حذف نشده است؛ از درونِ همین صفحه با
  /// «نقشه جزیره» باز می‌شود، بنابراین همهٔ هاب‌ها سرِ جای خود مانده‌اند.
  Widget _buildIslandHome() {
    return LivingIslandHome(
      onOpenStageMap: _openStageMapScreen,
      onOpenBackpack: () => _selectTab(1),
      onOpenAchievements: () => _selectTab(0),
      onOpenProfile: () => _selectTab(4),
    );
  }

  Widget _tabFor(int index) {
    final existing = _tabWidgets[index];
    if (existing != null) return existing;

    final Widget widget = switch (index) {
      0 => const AchievementsTab(),
      1 => const LearningLibraryScreen(embedded: true),
      2 => _buildIslandHome(),
      3 => const ReportCardTab(),
      4 => const ProfileScreen(embedded: true),
      _ => _buildIslandHome(),
    };
    _tabWidgets[index] = widget;
    return widget;
  }

  // ─── نوار ناوبری هماهنگ با هویت بصری جزیره ───────────────────────
  Widget _buildBottomNav() {
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Container(
      decoration: BoxDecoration(
        color: IslandWorldPalette.paper.withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(IslandWorldMetrics.cardRadius),
        ),
        border: const Border(
          top: BorderSide(color: IslandWorldPalette.softOutline, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: IslandWorldPalette.deepOcean.withOpacity(0.11),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          // سهم برابر خانه‌ها، متن فارسی را روی گوشی باریک هم خوانا نگه می‌دارد.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _navItem(
                  index: 0,
                  emoji: '🏆',
                  iconColor: IslandWorldPalette.honey,
                  label: 'دستاوردها',
                  animationsDisabled: animationsDisabled,
                ),
              ),
              Expanded(
                child: _navItem(
                  index: 1,
                  emoji: '🎒',
                  iconColor: IslandWorldPalette.sky,
                  label: 'کوله‌پشتی',
                  animationsDisabled: animationsDisabled,
                ),
              ),
              _buildCenterHomeNav(animationsDisabled: animationsDisabled),
              Expanded(
                child: _navItem(
                  index: 3,
                  emoji: '📘',
                  iconColor: IslandWorldPalette.foliage,
                  label: 'کارنامه',
                  animationsDisabled: animationsDisabled,
                ),
              ),
              Expanded(
                child: _navItem(
                  index: 4,
                  emoji: '👤',
                  iconColor: IslandWorldPalette.lavender,
                  label: 'پروفایل',
                  animationsDisabled: animationsDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── دکمه مرکزی خانه (برجسته و دایره‌ای) ──────────────────────
  Widget _buildCenterHomeNav({required bool animationsDisabled}) {
    final selected = _currentTab == 2;

    void activate() {
      HapticFeedback.mediumImpact();
      AudioService.tap();
      _selectTab(2);
    }

    final homeCircle = Container(
      width: 58,
      height: 58,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: IslandWorldPalette.paper,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? IslandWorldPalette.deepOcean
              : IslandWorldPalette.softOutline,
          width: selected ? 3.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: IslandWorldPalette.deepOcean.withOpacity(
              selected ? 0.22 : 0.1,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: _buildHomeHouseIcon(selected)),
    );
    final Widget circleWithMotion = animationsDisabled
        ? homeCircle
        : homeCircle
            .animate(target: selected ? 1 : 0)
            .scale(
              begin: const Offset(0.96, 0.96),
              end: const Offset(1.06, 1.06),
              duration: IslandWorldMetrics.pressOut,
            );

    return Semantics(
      button: true,
      selected: selected,
      label: 'خانه',
      onTap: activate,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: activate,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              circleWithMotion,
              Text(
                'خانه',
                style: AppFonts.kids(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: selected
                      ? IslandWorldPalette.deepOcean
                      : IslandWorldPalette.mutedInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHouseIcon(bool selected) {
    final iconColor = selected
        ? IslandWorldPalette.deepOcean
        : IslandWorldPalette.wood;
    final discColor = selected
        ? IslandWorldPalette.honey.withOpacity(0.3)
        : IslandWorldPalette.skyMist;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: discColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.home_rounded, size: 32, color: iconColor),
          Positioned(
            bottom: 6,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: IslandWorldPalette.paper,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── آیتم‌های استاندارد نوار پایین ────────────────────────────
  Widget _navItem({
    required int index,
    required String emoji,
    required Color iconColor,
    required String label,
    required bool animationsDisabled,
  }) {
    final selected = _currentTab == index;
    final inactiveColor = IslandWorldPalette.mutedInk;

    void activate() {
      HapticFeedback.lightImpact();
      AudioService.tap();
      _selectTab(index);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: activate,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: activate,
          child: AnimatedContainer(
            duration: animationsDisabled
                ? Duration.zero
                : IslandWorldMetrics.pressOut,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? iconColor.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(IslandWorldMetrics.buttonRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: selected ? 1.12 : 1.0,
                  duration: animationsDisabled
                      ? Duration.zero
                      : IslandWorldMetrics.pressOut,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: selected
                          ? iconColor.withOpacity(0.18)
                          : IslandWorldPalette.skyMist.withOpacity(0.62),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? iconColor.withOpacity(0.5)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: TextStyle(
                          fontSize: selected ? 22 : 20,
                          color: selected ? null : inactiveColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppFonts.kids(
                      fontSize: 13.5,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w700,
                      height: 1.2,
                      color: selected
                          ? IslandWorldPalette.deepOcean
                          : inactiveColor,
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
}

