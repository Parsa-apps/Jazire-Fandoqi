import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../core/growth/growth_store.dart';
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
  bool _showMusicControl = false;
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
            top: 4,
            left: 10,
            child: SafeArea(child: _buildSoundToggle()),
          ),

          if (_currentTab == 2)
            Positioned(
              left: 10,
              top: 52,
              child: SafeArea(
                child: IgnorePointer(
                  ignoring: !_showMusicControl,
                  child: Opacity(
                    opacity: _showMusicControl ? 1.0 : 0.0,
                    child: _buildMusicVolumeControl(),
                  ),
                ),
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
        ? const Color(0xFF80DEEA)
        : const Color(0xFFFF8A80);
    return Semantics(
      button: true,
      label: enabled ? 'قطع همه صداها' : 'روشن کردن صداها',
      child: Tooltip(
        message: enabled ? 'بی‌صدا (نگه دارید: تنظیم موسیقی)' : 'با صدا',
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
            onLongPress: () {
              HapticFeedback.mediumImpact();
              setState(() => _showMusicControl = !_showMusicControl);
            },
            child: Container(
              width: 35,
              height: 35,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.26),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: toggleColor,
                size: 19,
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

  // ─── نوار ناوبری شیشه‌ای سه‌بعدی هماهنگ با طرح مرجع جزیره ───────────────────────
  Widget _buildBottomNav() {
    final animationsDisabled =
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
            GrowthStore.reduceMotion;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xF2155A68),
            Color(0xF80B3540),
            Color(0xFF062128),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(26),
        ),
        border: const Border(
          top: BorderSide(color: Color(0x9980DEEA), width: 1.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.38),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _navItem(
                  index: 0,
                  emoji: '🏆',
                  iconColor: const Color(0xFFFFD54F),
                  label: 'دستاوردها',
                  animationsDisabled: animationsDisabled,
                ),
              ),
              Expanded(
                child: _navItem(
                  index: 1,
                  emoji: '🎒',
                  iconColor: const Color(0xFF4FC3F7),
                  label: 'کوله‌پشتی',
                  animationsDisabled: animationsDisabled,
                ),
              ),
              _buildCenterHomeNav(animationsDisabled: animationsDisabled),
              Expanded(
                child: _navItem(
                  index: 3,
                  emoji: '📘',
                  iconColor: const Color(0xFF81C784),
                  label: 'کارنامه',
                  animationsDisabled: animationsDisabled,
                ),
              ),
              Expanded(
                child: _navItem(
                  index: 4,
                  emoji: '👤',
                  iconColor: const Color(0xFFFFB74D),
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

  // ─── دکمه مرکزی خانه (برجسته و دایره‌ای سه‌بعدی) ──────────────────────
  Widget _buildCenterHomeNav({required bool animationsDisabled}) {
    final selected = _currentTab == 2;

    void activate() {
      HapticFeedback.mediumImpact();
      AudioService.tap();
      _selectTab(2);
    }

    final homeCircle = Container(
      width: 52,
      height: 52,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: selected
              ? const <Color>[Color(0xFFFFF176), Color(0xFFFF9800)]
              : const <Color>[Color(0xFF26A69A), Color(0xFF00695C)],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFFFFF9C4) : const Color(0x9980DEEA),
          width: selected ? 2.8 : 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: (selected
                    ? const Color(0xFFFFB300)
                    : const Color(0xFF004D40))
                .withOpacity(selected ? 0.45 : 0.25),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                circleWithMotion,
                Text(
                  'خانه',
                  style: AppFonts.kids(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: selected
                        ? const Color(0xFFFFF59D)
                        : const Color(0xFFB2EBF2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHouseIcon(bool selected) {
    final iconColor = selected
        ? const Color(0xFF4E2600)
        : Colors.white;
    final discColor = selected
        ? Colors.white.withOpacity(0.32)
        : Colors.white.withOpacity(0.14);

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: discColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.home_rounded, size: 28, color: iconColor),
          Positioned(
            bottom: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFF9C4)
                    : const Color(0xFF004D40),
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
    const inactiveColor = Color(0xFFB2EBF2);

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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: selected
                  ? iconColor.withOpacity(0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: selected ? 1.10 : 1.0,
                  duration: animationsDisabled
                      ? Duration.zero
                      : IslandWorldMetrics.pressOut,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: selected
                            ? <Color>[
                                iconColor.withOpacity(0.45),
                                iconColor.withOpacity(0.20),
                              ]
                            : const <Color>[
                                Color(0x55186A7A),
                                Color(0x550A3540),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: selected
                            ? iconColor.withOpacity(0.85)
                            : const Color(0x4480DEEA),
                        width: 1.4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: TextStyle(
                          fontSize: selected ? 20 : 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppFonts.kids(
                      fontSize: 12.5,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w700,
                      height: 1.15,
                      color: selected
                          ? const Color(0xFFFFF59D)
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

