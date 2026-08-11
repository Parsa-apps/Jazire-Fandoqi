import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jazireh_fandoghi/app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import 'package:jazireh_fandoghi/app/design_tokens.dart';
import 'package:jazireh_fandoghi/core/audio_service.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/fandoghi_models.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/about/about_screen.dart';
import 'package:jazireh_fandoghi/features/profile/profile_screen.dart';
import 'package:jazireh_fandoghi/features/profile/sticker_album_screen.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ APP GATEWAY — جزیره جادویی فندقی (طراحی فوق حرفه‌ای سه‌بعدی)
///
/// صفحهٔ اصلی اپلیکیشن با تصویرسازی سه‌بعدی لوکس، اقیانوس کریستالی،
/// آبشارهای جادویی و شش سکوی شناور ماجراجویی:
///   ۱. بازی و یادگیری 🚀   ۲. سینما کارتون 🍿
///   ۳. قصه‌خانه 📚        ۴. لالایی‌های شب 🌙
///   ۵. پروفایل من 👑      ۶. درباره ما ℹ️
/// ═══════════════════════════════════════════════════════════════
class AppGatewayScreen extends StatefulWidget {
  const AppGatewayScreen({super.key});

  @override
  State<AppGatewayScreen> createState() => _AppGatewayScreenState();
}

class _AppGatewayScreenState extends State<AppGatewayScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _sparkleCtrl;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.disablePersistentPresence();
    FandoghiCoach.clear();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _sparkleCtrl.dispose();
    super.dispose();
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صبح بخیر ☀️';
    if (hour >= 12 && hour < 17) return 'روز بخیر 🌤️';
    if (hour >= 17 && hour < 21) return 'عصر بخیر 🌇';
    return 'شب بخیر 🌙';
  }

  void _openSection(String route, {String? announcement}) {
    HapticFeedback.heavyImpact();
    AudioService.select();
    if (announcement != null) {
      FandoghiCoach.say(
        announcement,
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 2),
      );
    }
    Navigator.of(context).pushNamed(route).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openWidget(Widget screen, {String? announcement}) {
    HapticFeedback.heavyImpact();
    AudioService.select();
    if (announcement != null) {
      FandoghiCoach.say(
        announcement,
        mood: FandoghiMood.happy,
        duration: const Duration(seconds: 2),
      );
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen))
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openStickers() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StickerAlbumScreen()),
    );
  }

  String _normalizeDigits(String input) {
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    String result = input;
    for (int i = 0; i < persianDigits.length; i++) {
      result = result.replaceAll(persianDigits[i], englishDigits[i]);
    }
    return result;
  }

  Future<void> _parentGate(BuildContext context) async {
    final n1 = Random().nextInt(10) + 1;
    final n2 = Random().nextInt(10) + 1;
    final controller = TextEditingController();
    var errorText = '';

    final approved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🔒 ورود والدین'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'این بخش برای بزرگ‌ترهاست. لطفاً پاسخ دهید:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$n1 + $n2 = ?',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'جواب',
                  errorText: errorText.isEmpty ? null : errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                final normalized = _normalizeDigits(controller.text.trim());
                if (int.tryParse(normalized) == n1 + n2) {
                  Navigator.pop(dialogContext, true);
                } else {
                  setDialogState(() => errorText = 'جواب نادرست است.');
                }
              },
              child: const Text('تایید'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (approved == true && context.mounted) {
      await Navigator.pushNamed(context, '/parent');
    }
  }

  List<_IslandTile> get _tiles => [
        _IslandTile(
          title: 'بازی و یادگیری',
          image: 'assets/gateway/learn_tile.png',
          glow: const Color(0xFF6C5CE7),
          onTap: () => _openSection(
            '/home',
            announcement: 'بریم با هم بازی کنیم و یاد بگیریم! 🚀',
          ),
        ),
        _IslandTile(
          title: 'سینما کارتون',
          image: 'assets/gateway/cartoon_tile.png',
          glow: const Color(0xFFFF2A6D),
          onTap: () => _openSection(
            '/cartoons',
            announcement: 'چراغ‌ها خاموش، فیلم شروع شد! 🍿🎬',
          ),
        ),
        _IslandTile(
          title: 'قصه‌خانه',
          image: 'assets/gateway/story_tile.png',
          glow: const Color(0xFFAB47BC),
          onTap: () => _openSection(
            '/stories',
            announcement: 'بیا یه قصه قشنگ بخونیم 📚✨',
          ),
        ),
        _IslandTile(
          title: 'لالایی‌های شب',
          image: 'assets/gateway/lullaby_tile.png',
          glow: const Color(0xFF3949AB),
          onTap: () => _openSection(
            '/lullabies',
            announcement: 'وقت خواب قشنگه... لالایی می‌خوای؟ 🌙💤',
          ),
        ),
        _IslandTile(
          title: 'پروفایل من',
          image: 'assets/gateway/profile_tile.png',
          glow: const Color(0xFF00B894),
          onTap: () => _openWidget(
            const ProfileScreen(),
            announcement: 'اینجا همه مدال‌ها و رکوردهات! 🏅',
          ),
        ),
        _IslandTile(
          title: 'درباره ما',
          image: 'assets/gateway/about_tile.png',
          glow: const Color(0xFF0984E3),
          onTap: () => _openWidget(const AboutScreen()),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final name =
        GameData.childName.isNotEmpty ? GameData.childName : 'دوست کوچولو';

    return Scaffold(
      body: Stack(
        children: [
          // ── پس‌زمینه تصویر جزیره سه‌بعدی لوکس با تنفس و شناوری ملایم ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (context, child) {
                final dy = sin(_floatCtrl.value * pi) * 6;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.scale(
                    scale: 1.04 + sin(_floatCtrl.value * pi) * 0.01,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/gateway/island_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // هاله گرادیان ملایم برای ایجاد کنتراست عالی متن‌ها
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.35),
                    Colors.transparent,
                    Colors.black.withOpacity(0.12),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── محتوای روی جزیره ──
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(name),
                const SizedBox(height: 6),
                _buildHeading(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: _buildPlatformsGrid(constraints),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildStickerButton(),
                const SizedBox(height: 10),
                _buildLearningLibraryButton(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── نوار بالا ──────────────────────────────────────
  Widget _buildTopBar(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6C5CE7),
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.2),
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
                            width: 44,
                            height: 44,
                          )
                        : GameData.avatar.startsWith('assets/')
                            ? Image.asset(
                                GameData.avatar,
                                fit: BoxFit.cover,
                                width: 44,
                                height: 44,
                              )
                            : Center(
                                child: Text(
                                  GameData.avatar,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_timeGreeting()} $name! 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.vazirmatn(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1F3A5F),
                        ),
                      ),
                      Text(
                        'لول ${GameData.level} • ${GameData.getLevelName()}',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF1F3A5F).withOpacity(0.75),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _balanceBadge('⭐', '${GameData.stars}'),
                const SizedBox(width: 6),
                _balanceBadge('💰', '${GameData.coins}'),
                const SizedBox(width: 6),
                _iconPill(
                  Icons.lock_outline_rounded,
                  () => _parentGate(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _balanceBadge(String emoji, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text(
            count,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F3A5F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconPill(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1F3A5F), size: 20),
      ),
    );
  }

  // ─── تیتر ───────────────────────────────────────────
  Widget _buildHeading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
      child: Column(
        children: [
          Text(
            '🏝️ جزیره فندقی',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1F3A5F),
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
                Shadow(
                  color: Colors.white.withOpacity(0.7),
                  blurRadius: 4,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -3, duration: 2200.ms, curve: Curves.easeInOut),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'یک بخش را انتخاب کن تا ماجراجویی شروع بشه!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F3A5F).withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── گرید ۳×۲ سکوهای شناور ─────────────────────────
  Widget _buildPlatformsGrid(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 360.0;
    final gap = 12.0;
    final tileSize = ((maxWidth - gap * 2) / 3).clamp(80.0, 130.0);

    final tiles = _tiles;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FloatingPlatform(
                tile: tiles[0], size: tileSize, index: 0),
            SizedBox(width: gap),
            _FloatingPlatform(
                tile: tiles[1], size: tileSize, index: 1),
            SizedBox(width: gap),
            _FloatingPlatform(
                tile: tiles[2], size: tileSize, index: 2),
          ],
        ),
        SizedBox(height: gap + 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FloatingPlatform(
                tile: tiles[3], size: tileSize, index: 3),
            SizedBox(width: gap),
            _FloatingPlatform(
                tile: tiles[4], size: tileSize, index: 4),
            SizedBox(width: gap),
            _FloatingPlatform(
                tile: tiles[5], size: tileSize, index: 5),
          ],
        ),
      ],
    );
  }

  // ─── دکمه آلبوم استیکر ──────────────────────────────
  Widget _buildStickerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GestureDetector(
        onTap: _openStickers,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFF8E53).withOpacity(0.6), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8E53).withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎀', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'آلبوم استیکرهای من',
                style: AppFonts.vazirmatn(
                  color: const Color(0xFF1F3A5F),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFFFF8E53),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 600.ms, duration: 400.ms)
          .slideY(begin: 0.3, curve: Curves.easeOutBack),
    );
  }

  Widget _buildLearningLibraryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GestureDetector(
        onTap: () => _openSection(
          '/learning-library',
          announcement: 'کتابخانه یادگیری باز شد؛ دنیای مورد علاقه‌ات را انتخاب کن 📚',
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF00B894)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: AppShadows.colored(AppColors.primary, opacity: 0.28),
          ),
          child: Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'کتابخانه یادگیری — حیوانات، اعداد، شغل‌ها و احساسات',
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 800.ms, duration: 400.ms)
          .slideY(begin: 0.3, curve: Curves.easeOutBack),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// مدل کاشی و سکوی شناور سه‌بعدی
// ═══════════════════════════════════════════════════════════
class _IslandTile {
  final String title;
  final String image;
  final Color glow;
  final VoidCallback onTap;

  const _IslandTile({
    required this.title,
    required this.image,
    required this.glow,
    required this.onTap,
  });
}

class _FloatingPlatform extends StatefulWidget {
  final _IslandTile tile;
  final double size;
  final int index;

  const _FloatingPlatform({
    required this.tile,
    required this.size,
    required this.index,
  });

  @override
  State<_FloatingPlatform> createState() => _FloatingPlatformState();
}

class _FloatingPlatformState extends State<_FloatingPlatform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) _floatCtrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final imageBox = size * 0.84;

    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (context, child) {
        final wave = sin(_floatCtrl.value * pi * 2 + widget.index * 0.8);
        final dy = wave * 6;
        final tilt = wave * 0.04;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0018)
            ..rotateZ(tilt * 0.22)
            ..translate(0.0, dy, 0.0),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.tile.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مکعب تصویر سه‌بعدی با هاله رنگی درخشان
            AnimatedScale(
              scale: _pressed ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Container(
                width: imageBox,
                height: imageBox,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(imageBox * 0.24),
                  boxShadow: [
                    BoxShadow(
                      color: widget.tile.glow.withOpacity(0.55),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.85),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.tile.glow.withOpacity(0.9),
                      widget.tile.glow,
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(imageBox * 0.24 - 3),
                  child: Image.asset(
                    widget.tile.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // برچسب نام بخش
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: widget.tile.glow.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: widget.tile.glow.withOpacity(0.45),
                  width: 1.6,
                ),
              ),
              child: Text(
                widget.tile.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.vazirmatn(
                  fontSize: size < 95 ? 10.5 : 12,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1F3A5F),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 200 + widget.index * 100),
          duration: 400.ms,
        )
        .slideY(
          begin: -0.8,
          end: 0,
          curve: Curves.elasticOut,
          duration: 1000.ms,
          delay: Duration(milliseconds: 150 + widget.index * 100),
        )
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 1000.ms,
          delay: Duration(milliseconds: 150 + widget.index * 100),
        );
  }
}
