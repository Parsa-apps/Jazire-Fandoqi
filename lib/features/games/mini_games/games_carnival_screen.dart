import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../app/design_tokens.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/persian_digits.dart';
import '../../../core/monetization.dart';
import '../../../core/xp_system.dart';
import '../../../shared/widgets/child_touch_target.dart';

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
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_checkPurchase());
      FandoghiCoach.instruction(
        'به شهر بازی‌های تازه خوش آمدی! یک بازی انتخاب کن؛ من همین‌جا هستم 🎪🐿️',
      );
    });
  }

  @override
  void dispose() {
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: Colors.white30),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'شهر بازی‌های تازه 🎪',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
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
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: Colors.white24),
          ),
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
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${PersianDigits.toFa(GameData.xp)} تجربه',
                    style: AppFonts.vazirmatn(
                      color: const Color(0xFFFFF176),
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
                    backgroundColor: Colors.white.withOpacity(0.22),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFD700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${PersianDigits.toFa(remaining)} تجربه تا سطح بعد',
                style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 12),
              ),
            ],
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
    final locked = _checkedPurchase && !_hasFullVersion && !game.isFree;
    return ChildTouchTarget(
      onTap: () => _open(game),
      minSize: 96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
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
                  Text(game.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 6),
                  Text(
                    game.title,
                    style: AppFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.subtitle,
                    textAlign: TextAlign.center,
                    style: AppFonts.vazirmatn(
                      color: Colors.white70,
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
class _LockBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('👑', style: TextStyle(fontSize: 30)),
          SizedBox(height: 4),
          Text(
            'نسخهٔ کامل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
