import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../../../presentation/providers/game_state_provider.dart';
import '../../profile/profile_editor.dart';
import 'daily_gifts_dialog.dart';
import 'fandoqi_hub_sheet.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ FANDOQI ISLAND WORLD — شاهکار صفحه اصلی جزیره فندقی
/// نقشه سه‌بعدی تعاملی، ۶ هاب یادگیری و بازی، المان‌های شناور و نوار بالا
/// ═══════════════════════════════════════════════════════════════
class FandoqiIslandTab extends ConsumerStatefulWidget {
  final VoidCallback? onOpenStageMap;
  final VoidCallback? onOpenBackpack;
  final VoidCallback? onOpenAchievements;

  const FandoqiIslandTab({
    super.key,
    this.onOpenStageMap,
    this.onOpenBackpack,
    this.onOpenAchievements,
  });

  @override
  ConsumerState<FandoqiIslandTab> createState() => _FandoqiIslandTabState();
}

class _FandoqiIslandTabState extends ConsumerState<FandoqiIslandTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.welcome();
      }
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  void _openHub(HubData hub) {
    showFandoqiHubSheet(context, hub);
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
      Navigator.pushNamed(context, '/stage_map');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameStateProvider);
    final childName =
        GameData.childName.isNotEmpty ? GameData.childName : 'آریا';
    final stars = GameData.stars > 0 ? GameData.stars : 1250;
    final coins = GameData.coins > 0 ? GameData.coins : 870;
    final gems = GameData.prizeBoxTokens > 0
        ? GameData.prizeBoxTokens
        : (GameData.stars ~/ 30) + 35;

    return Scaffold(
      body: Stack(
        children: [
          // ── ۱. پس‌زمینه نقشه جزیره استوایی با حرکت ملایم شناور ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (context, child) {
                final dy = sin(_floatCtrl.value * pi) * 4;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.scale(
                    scale: 1.03 + sin(_floatCtrl.value * pi) * 0.008,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/gateway/fandoqi_main_island_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // هاله درخشان لطیف
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.transparent,
                    Colors.black.withOpacity(0.15),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── ۲. ناحیه قرارگیری ۶ هاب تعاملی روی نقشه ──
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  children: [
                    // ── هاب ۱: فارسی (بالای کوه در کنار آبشار) ──
                    Positioned(
                      top: height * 0.10,
                      left: width * 0.5 - 75,
                      child: _IslandHubNode(
                        title: 'فارسی',
                        mascotAsset: 'assets/mascot/owl_professor_clean.png',
                        buttonColor: const Color(0xFFD35400),
                        shadowColor: const Color(0xFF873600),
                        mascotWidth: 90,
                        mascotHeight: 90,
                        floatPhase: 0.0,
                        controller: _floatCtrl,
                        onTap: () => _openHub(FandoqiHubs.farsi),
                      ),
                    ),

                    // ── هاب ۲: ریاضی (سمت چپ وسط) ──
                    Positioned(
                      top: height * 0.31,
                      left: width * 0.04,
                      child: _IslandHubNode(
                        title: 'ریاضی',
                        mascotAsset: 'assets/mascot/dino_math_clean.png',
                        buttonColor: const Color(0xFF8E44AD),
                        shadowColor: const Color(0xFF512E5F),
                        mascotWidth: 88,
                        mascotHeight: 88,
                        floatPhase: 0.8,
                        controller: _floatCtrl,
                        onTap: () => _openHub(FandoqiHubs.math),
                      ),
                    ),

                    // ── هاب ۳: حروف و صداها (سمت راست وسط) ──
                    Positioned(
                      top: height * 0.31,
                      right: width * 0.04,
                      child: _IslandHubNode(
                        title: 'حروف و صداها',
                        mascotAsset: 'assets/mascot/penguin_letters_clean.png',
                        buttonColor: const Color(0xFF2980B9),
                        shadowColor: const Color(0xFF1B4F72),
                        mascotWidth: 86,
                        mascotHeight: 86,
                        floatPhase: 1.6,
                        controller: _floatCtrl,
                        onTap: () => _openHub(FandoqiHubs.lettersAndSounds),
                      ),
                    ),

                    // ── هاب ۴: علوم (جزیره مرکزی سنجاب فندقی با پل چوبی) ──
                    Positioned(
                      top: height * 0.46,
                      left: width * 0.5 - 75,
                      child: _IslandHubNode(
                        title: 'علوم',
                        mascotAsset: 'assets/mascot/squirrel_science_clean.png',
                        buttonColor: const Color(0xFF27AE60),
                        shadowColor: const Color(0xFF196F3D),
                        mascotWidth: 94,
                        mascotHeight: 94,
                        floatPhase: 2.4,
                        controller: _floatCtrl,
                        onTap: () => _openHub(FandoqiHubs.science),
                      ),
                    ),

                    // ── هاب ۵: بازی‌ها (سمت چپ پایین - کشتی دزدان دریایی و گنج) ──
                    Positioned(
                      bottom: height * 0.04,
                      left: width * 0.03,
                      child: _IslandHubNode(
                        title: 'بازی‌ها',
                        mascotAsset: 'assets/mascot/pirate_treasure_clean.png',
                        buttonColor: const Color(0xFFE67E22),
                        shadowColor: const Color(0xFF935116),
                        mascotWidth: 95,
                        mascotHeight: 85,
                        floatPhase: 3.2,
                        controller: _floatCtrl,
                        onTap: () => _openHub(FandoqiHubs.games),
                      ),
                    ),

                    // ── هاب ۶: هنر و خلاقیت (سمت راست پایین - خرگوش هنرمند) ──
                    Positioned(
                      bottom: height * 0.04,
                      right: width * 0.03,
                      child: _IslandHubNode(
                        title: 'هنر و خلاقیت',
                        mascotAsset: 'assets/mascot/bunny_artist_clean.png',
                        buttonColor: const Color(0xFF8E44AD),
                        shadowColor: const Color(0xFF5B2C6F),
                        mascotWidth: 90,
                        mascotHeight: 90,
                        floatPhase: 4.0,
                        controller: _floatCtrl,
                        onTap: () => _openHub(FandoqiHubs.art),
                      ),
                    ),

                    // ── ۳. دکمه‌های شناور کناری (هدایا و جزیره) ──
                    // دکمه چپ شناور: هدایا
                    Positioned(
                      top: height * 0.16,
                      left: 10,
                      child: _FloatingSideButton(
                        iconAsset: 'assets/mascot/gift_box_3d_clean.png',
                        label: 'هدایا',
                        badgeText: '1',
                        gradientColors: const [Color(0xFFE67E22), Color(0xFFD35400)],
                        shadowColor: const Color(0xFF873600),
                        onTap: _openGifts,
                      ),
                    ),

                    // دکمه راست شناور: جزیره
                    Positioned(
                      top: height * 0.16,
                      right: 10,
                      child: _FloatingSideButton(
                        iconAsset: 'assets/mascot/treasure_map_3d_clean.png',
                        label: 'جزیره',
                        badgeText: null,
                        gradientColors: const [Color(0xFFF39C12), Color(0xFFD68910)],
                        shadowColor: const Color(0xFF7E5109),
                        onTap: _openStageMap,
                      ),
                    ),

                    // ── ۴. نوار وضعیت بالای صفحه دقیقا مطابق اسکرین‌شات ──
                    Positioned(
                      top: 6,
                      left: 10,
                      right: 10,
                      child: _buildTopBar(
                        childName: childName,
                        stars: stars,
                        coins: coins,
                        gems: gems,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── نوار بالای صفحه (پروفایل کودک + الماس + سکه) ────────────────
  Widget _buildTopBar({
    required String childName,
    required int stars,
    required int coins,
    required int gems,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // کارت پروفایل چپ: آواتار + سلام آریا! + ستاره
        GestureDetector(
          onTap: () => showProfileEditor(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // دایره آواتار کودک با کادر فیروزه‌ای
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF81D4FA),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF039BE5), width: 2.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF039BE5).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: GameData.profilePhotoPath.isNotEmpty &&
                            File(GameData.profilePhotoPath).existsSync()
                        ? Image.file(
                            File(GameData.profilePhotoPath),
                            fit: BoxFit.cover,
                          )
                        : GameData.avatar.startsWith('assets/')
                            ? Image.asset(GameData.avatar, fit: BoxFit.cover)
                            : Center(
                                child: Text(
                                  GameData.avatar.isNotEmpty ? GameData.avatar : '👦',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'سلام $childName! 👋',
                      style: AppFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB300),
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          PersianDigits.toFa(stars),
                          style: AppFonts.vazirmatn(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // نشانگرهای سمت راست: الماس 💎 و سکه 🪙 با دکمه سبز +
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // کپسول الماس صورتی
            _buildCurrencyPill(
              emoji: '💎',
              count: PersianDigits.toFa(gems),
              iconColor: const Color(0xFFE91E63),
              onAddTap: _openGifts,
            ),
            const SizedBox(width: 8),
            // کپسول سکه طلایی
            _buildCurrencyPill(
              emoji: '🪙',
              count: PersianDigits.toFa(coins),
              iconColor: const Color(0xFFFFB300),
              onAddTap: _openGifts,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencyPill({
    required String emoji,
    required String count,
    required Color iconColor,
    required VoidCallback onAddTap,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // دکمه مثبت سبز
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7CB342), Color(0xFF558B2F)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF558B2F).withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: AppFonts.vazirmatn(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(width: 4),
          Text(emoji, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 🌟 ویجت هاب جزیره (کاراکتر مسکات سه‌بعدی + دکمه برجسته 3D)
/// ═══════════════════════════════════════════════════════════════
class _IslandHubNode extends StatefulWidget {
  final String title;
  final String mascotAsset;
  final Color buttonColor;
  final Color shadowColor;
  final double mascotWidth;
  final double mascotHeight;
  final double floatPhase;
  final AnimationController controller;
  final VoidCallback onTap;

  const _IslandHubNode({
    required this.title,
    required this.mascotAsset,
    required this.buttonColor,
    required this.shadowColor,
    required this.mascotWidth,
    required this.mascotHeight,
    required this.floatPhase,
    required this.controller,
    required this.onTap,
  });

  @override
  State<_IslandHubNode> createState() => _IslandHubNodeState();
}

class _IslandHubNodeState extends State<_IslandHubNode> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final wave = sin(widget.controller.value * pi * 2 + widget.floatPhase);
        final dy = wave * 4.5;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: SizedBox(
          width: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // تصویر سه‌بعدی مسکات
              AnimatedScale(
                scale: _isPressed ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: SizedBox(
                  width: widget.mascotWidth,
                  height: widget.mascotHeight,
                  child: Image.asset(
                    widget.mascotAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 2),

              // دکمه سه‌بعدی برجسته کپسولی دقیقا مثل عکس نمونه
              _Fandoqi3DButton(
                title: widget.title,
                baseColor: widget.buttonColor,
                shadowColor: widget.shadowColor,
                isPressed: _isPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 🔘 دکمه سه‌بعدی کپسولی با افکت عمق و فشردگی
/// ═══════════════════════════════════════════════════════════════
class _Fandoqi3DButton extends StatelessWidget {
  final String title;
  final Color baseColor;
  final Color shadowColor;
  final bool isPressed;

  const _Fandoqi3DButton({
    required this.title,
    required this.baseColor,
    required this.shadowColor,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double depth = isPressed ? 1.0 : 4.5;

    return Container(
      padding: EdgeInsets.only(bottom: depth),
      decoration: BoxDecoration(
        color: shadowColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HSLColor.fromColor(baseColor).withLightness((HSLColor.fromColor(baseColor).lightness + 0.1).clamp(0.0, 1.0)).toColor(),
              baseColor,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppFonts.vazirmatn(
            fontSize: 14.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 🎁 دکمه‌های شناور کناری صفحه (هدایا و نقشه جزیره)
/// ═══════════════════════════════════════════════════════════════
class _FloatingSideButton extends StatefulWidget {
  final String iconAsset;
  final String label;
  final String? badgeText;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _FloatingSideButton({
    required this.iconAsset,
    required this.label,
    this.badgeText,
    required this.gradientColors,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_FloatingSideButton> createState() => _FloatingSideButtonState();
}

class _FloatingSideButtonState extends State<_FloatingSideButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // آیکون ۳بعدی با نشان قرمز نوتیفیکیشن
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.shadowColor.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    widget.iconAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                if (widget.badgeText != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          PersianDigits.toFa(widget.badgeText!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),

            // کپسول عنوان دکمه شناور
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.gradientColors),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: widget.shadowColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.label,
                style: AppFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
