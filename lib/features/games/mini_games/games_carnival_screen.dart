import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jazireh_fandoghi/shared/widgets/animated_gold_lock.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../app/design_tokens.dart';
import '../../../app/island_world_style.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/persian_digits.dart';
import '../../../core/monetization.dart';
import '../../../core/xp_system.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/island_kit.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎪 شهر بازی‌های تازه — هاب ۱۰ بازی جدید (نسخه ۷.۰.۰)
///
/// ورودی دنیای بازی‌های نسخه ۷ از نقشهٔ جزیره:
///  - نمایشگر «سطح جزیره» و نوار XP کودک
///  - ۱۰ کارت بازی؛ ۵ بازی رایگان و ۵ بازی نسخهٔ کامل
/// خروجی هر کارت روت اختصاصی همان بازی است.
/// ═══════════════════════════════════════════════════════════════
class GamesCarnivalScreen extends StatefulWidget {
  const GamesCarnivalScreen({super.key});

  @override
  State<GamesCarnivalScreen> createState() => _GamesCarnivalScreenState();
}

class _CarnivalGame {
  final String title;
  final String subtitle;
  final String emoji;
  final Color glow;
  final String route;
  final bool isFree;

  const _CarnivalGame({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.glow,
    required this.route,
    this.isFree = false,
  });
}

class _GamesCarnivalScreenState extends State<GamesCarnivalScreen> {
  static const List<_CarnivalGame> _games = <_CarnivalGame>[
    _CarnivalGame(
      title: 'حرف اول',
      subtitle: 'شروع خواندن و آواشناسی',
      emoji: '🔤',
      glow: Color(0xFF1E88E5),
      route: '/mini/first-letter',
      isFree: true,
    ),
    _CarnivalGame(
      title: 'کلمه‌ساز',
      subtitle: 'حرف گم‌شده را جا بگذار',
      emoji: '🧱',
      glow: Color(0xFF43A047),
      route: '/mini/word-builder',
    ),
    _CarnivalGame(
      title: 'شمارش خوش',
      subtitle: 'چند تا می‌بینی؟',
      emoji: '🔢',
      glow: Color(0xFFEC407A),
      route: '/mini/counting',
      isFree: true,
    ),
    _CarnivalGame(
      title: 'جمع تصویری',
      subtitle: 'جمع با سیب و ستاره',
      emoji: '➕',
      glow: Color(0xFFFB8C00),
      route: '/mini/visual-math',
    ),
    _CarnivalGame(
      title: 'بزرگ و کوچک',
      subtitle: 'مقایسهٔ اندازه‌ها',
      emoji: '🐘',
      glow: Color(0xFF8E24AA),
      route: '/mini/big-small',
      isFree: true,
    ),
    _CarnivalGame(
      title: 'جورچین شکل‌ها',
      subtitle: 'شکل درست را پیدا کن',
      emoji: '🔷',
      glow: Color(0xFF00ACC1),
      route: '/mini/shape-match',
    ),
    _CarnivalGame(
      title: 'ترکیب رنگ',
      subtitle: 'رنگ‌های تازه بساز',
      emoji: '🎨',
      glow: Color(0xFFD81B60),
      route: '/mini/color-mix',
    ),
    _CarnivalGame(
      title: 'ترتیب اعداد',
      subtitle: 'از کوچک به بزرگ',
      emoji: '🪜',
      glow: Color(0xFF3949AB),
      route: '/mini/number-order',
      isFree: true,
    ),
    _CarnivalGame(
      title: 'متفاوت را پیدا کن',
      subtitle: 'چشم تیز کارآگاه',
      emoji: '🕵️',
      glow: Color(0xFF5E35B1),
      route: '/mini/odd-one',
      isFree: true,
    ),
    _CarnivalGame(
      title: 'سبد دسته‌بندی',
      subtitle: 'سبد را درست پر کن',
      emoji: '🧺',
      glow: Color(0xFF00897B),
      route: '/mini/sort-basket',
    ),
  ];

  bool _hasFullVersion = false;
  bool _checkedPurchase = false;

  @override
  void initState() {
    super.initState();
    Monetization.accessStatus.addListener(_onAccessChanged);
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_checkPurchase());
      FandoghiCoach.instruction(
        'به شهر بازی‌های تازه خوش آمدی! یک بازی انتخاب کن؛ من همین‌جا هستم 🎪🐿️',
      );
    });
  }

  void _onAccessChanged() {
    if (!mounted) return;
    final status = Monetization.accessStatus.value;
    setState(() {
      _hasFullVersion = status.isVerified;
      _checkedPurchase = status != FullVersionAccessStatus.checking;
    });
  }

  @override
  void dispose() {
    Monetization.accessStatus.removeListener(_onAccessChanged);
    FandoghiCoach.clear();
    super.dispose();
  }

  Future<void> _checkPurchase() async {
    final has = await Monetization.hasFullVersion();
    if (!mounted) return;
    setState(() {
      _hasFullVersion = has;
      _checkedPurchase = true;
    });
  }

  void _open(_CarnivalGame game) {
    unawaited(AudioService.tap());
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, game.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.aurora),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildXpPanel(),
              Expanded(child: _buildGrid()),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          ChildTouchTarget(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: IslandWorldPalette.paper,
                shape: BoxShape.circle,
                border: Border.all(color: IslandWorldPalette.honey, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: IslandWorldPalette.ink,
                size: 21,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: IslandPanel(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              radius: 20,
              child: Text(
                'شهر بازی‌های تازه 🎪',
                textAlign: TextAlign.center,
                style: AppFonts.kids(
                  color: IslandWorldPalette.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  /// پنل سطح جزیره — قلب تجربهٔ پیشرفت نسخه ۷.
  Widget _buildXpPanel() {
    return ValueListenableBuilder<int>(
      valueListenable: GameData.changes,
      builder: (context, _, __) {
        final level = GameData.islandLevel;
        final progress = GameData.islandLevelProgress;
        final remaining = GameData.xpToNextIslandLevel;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: IslandPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('🐿️', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        XpSystem.levelLabel(level),
                        style: AppFonts.vazirmatn(
                          color: IslandWorldPalette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${PersianDigits.toFa(GameData.xp)} تجربه',
                      style: AppFonts.vazirmatn(
                        color: const Color(0xFF8A6D00),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFFFE9A8),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFB300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${PersianDigits.toFa(remaining)} تجربه تا سطح بعد',
                  style: AppFonts.vazirmatn(
                    color: IslandWorldPalette.ink.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.98,
      ),
      itemCount: _games.length,
      itemBuilder: (context, i) => _buildCard(_games[i]),
    );
  }

  Widget _buildCard(_CarnivalGame game) {
    final locked = !game.isFree && (!_checkedPurchase || !_hasFullVersion);
    return ChildTouchTarget(
      onTap: () => _open(game),
      minSize: 96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          // کارت کاغذی جزیره با هالهٔ رنگیِ خودِ بازی: هویت هر بازی
          // از رنگش پیداست، ولی جنس کارت در همهٔ شهر یکی است.
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDF7), Color(0xFFFFF6E0)],
          ),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: game.glow.withOpacity(0.65), width: 2),
          boxShadow: [
            BoxShadow(
              color: game.glow.withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: game.glow.withOpacity(0.14),
                      border:
                          Border.all(color: game.glow.withOpacity(0.35)),
                    ),
                    child: Text(game.emoji,
                        style: const TextStyle(fontSize: 34)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    game.title,
                    style: AppFonts.vazirmatn(
                      color: IslandWorldPalette.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.subtitle,
                    textAlign: TextAlign.center,
                    style: AppFonts.vazirmatn(
                      color: IslandWorldPalette.ink.withOpacity(0.55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (locked)
              Positioned.fill(
                child: _LockBadge(),
              ),
            if (!locked && game.isFree)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    'رایگان',
                    style: AppFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// نشان قفل نسخهٔ کامل — روی کارت‌های پریمیوم (تا زمان خرید).
/// قفلِ واقعی با آیکون قفل و متن صریح، هم‌سبک با نشان هاب‌ها.
class _LockBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'با نسخه کامل',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF294552).withOpacity(0.45),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4CE),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedGoldLock(size: 44),
              SizedBox(height: 4),
              Text(
                'نسخه کامل',
                style: TextStyle(
                  color: Color(0xFF714716),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
