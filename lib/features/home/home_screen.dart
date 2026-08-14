import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../gateway/learning_library_screen.dart';
import '../profile/profile_screen.dart';
import '../stage_map/stage_map_screen.dart';
import 'widgets/achievements_tab.dart';
import 'widgets/island_map/island_map_tab.dart';
import 'widgets/report_card_tab.dart';

/// ═══════════════════════════════════════════════
/// 🏠 HOME SCREEN — صفحه اصلی جزیره فندقی
/// نوار پایینی لوکس دقیقا مطابق طرح اسکرین‌شات
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
    _tabWidgets[2] = IslandMapTab(
      onOpenStageMap: () => _openStageMapScreen(),
      onOpenBackpack: () => _selectTab(1),
      onOpenAchievements: () => _selectTab(0),
    );

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

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentTab,
              children: List<Widget>.generate(5, _tabFor),
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
                color: Colors.white.withOpacity(0.94),
                border: Border.all(color: const Color(0xFF81D4FA), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: enabled ? const Color(0xFF0277BD) : const Color(0xFFE65100),
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
        width: 224,
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF80CBC4).withOpacity(0.9),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00695C).withOpacity(0.18),
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
                        ? const Color(0xFFE65100)
                        : const Color(0xFF00897B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'صدای موسیقی',
                    style: AppFonts.kids(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF37474F),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$percent٪',
                    style: AppFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF00796B),
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
                  color: const Color(0xFF00897B),
                  disabledColor: const Color(0xFFB0BEC5),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 5,
                      activeTrackColor: const Color(0xFF26A69A),
                      inactiveTrackColor: const Color(0xFFB2DFDB),
                      thumbColor: const Color(0xFFFFB300),
                      overlayColor:
                          const Color(0xFFFFB300).withOpacity(0.16),
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
                  color: const Color(0xFF00897B),
                  disabledColor: const Color(0xFFB0BEC5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabFor(int index) {
    final existing = _tabWidgets[index];
    if (existing != null) return existing;

    final Widget widget = switch (index) {
      0 => const AchievementsTab(),
      1 => const LearningLibraryScreen(embedded: true),
      2 => IslandMapTab(
          onOpenStageMap: () => _openStageMapScreen(),
          onOpenBackpack: () => _selectTab(1),
          onOpenAchievements: () => _selectTab(0),
        ),
      3 => const ReportCardTab(),
      4 => const ProfileScreen(embedded: true),
      _ => IslandMapTab(
          onOpenStageMap: () => _openStageMapScreen(),
        ),
    };
    _tabWidgets[index] = widget;
    return widget;
  }

  // ─── نوار ناوبری پایینی دقیقا مطابق تصویر نمونه ──────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0277BD).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          // هر خانه سهم مساوی می‌گیرد تا فونتِ درشت‌ترِ کودکانه هیچ‌وقت
          // روی گوشی‌های باریک سرریز نکند.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ۱. دستاوردها (سمت چپ)
              Expanded(
                child: _navItem(
                  index: 0,
                  emoji: '🏆',
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFFFB300),
                  label: 'دستاوردها',
                ),
              ),

              // ۲. کوله‌پشتی
              Expanded(
                child: _navItem(
                  index: 1,
                  emoji: '🎒',
                  icon: Icons.backpack_rounded,
                  iconColor: const Color(0xFF1E88E5),
                  label: 'کوله‌پشتی',
                ),
              ),

              // ۳. خانه (دکمه مرکزی شناور و برجسته با دایره آبی و آیکون خانه)
              _buildCenterHomeNav(),

              // ۴. کارنامه
              Expanded(
                child: _navItem(
                  index: 3,
                  emoji: '📘',
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFF00ACC1),
                  label: 'کارنامه',
                ),
              ),

              // ۵. پروفایل
              Expanded(
                child: _navItem(
                  index: 4,
                  emoji: '👤',
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF42A5F5),
                  label: 'پروفایل',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── دکمه مرکزی خانه (برجسته و دایره‌ای) ──────────────────────
  Widget _buildCenterHomeNav() {
    final selected = _currentTab == 2;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        AudioService.tap();
        _selectTab(2);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // دایره با حاشیه آبی روشن و پس‌زمینه سفید و آیکون کلبه نارنجی
          Container(
            width: 58,
            height: 58,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? const Color(0xFF039BE5)
                    : const Color(0xFF81D4FA).withOpacity(0.8),
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (selected ? const Color(0xFF039BE5) : const Color(0xFF0288D1))
                      .withOpacity(0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _buildHomeHouseIcon(selected),
            ),
          )
              .animate(target: selected ? 1 : 0)
              .scale(begin: const Offset(0.96, 0.96), end: const Offset(1.06, 1.06), duration: 200.ms),

          Text(
            'خانه',
            style: AppFonts.kids(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: selected ? const Color(0xFF0277BD) : const Color(0xFF546E7A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeHouseIcon(bool selected) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC80).withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.home_rounded,
            size: 32,
            color: Color(0xFFE65100),
          ),
          Positioned(
            bottom: 6,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
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
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    final selected = _currentTab == index;
    final activeColor = iconColor;
    final inactiveColor = const Color(0xFF78909C);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        AudioService.tap();
        _selectTab(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected
                      ? activeColor.withOpacity(0.18)
                      : Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? activeColor.withOpacity(0.5) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: selected ? 22 : 20,
                      color: selected ? null : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            // روی صفحه‌های خیلی باریک فقط کمی کوچک می‌شود، نه اینکه بشکند
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: AppFonts.kids(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  height: 1.2,
                  color: selected ? activeColor : inactiveColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
