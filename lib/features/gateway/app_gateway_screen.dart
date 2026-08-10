import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import 'package:amoozesh_fandoghi/core/audio_service.dart';
import 'package:amoozesh_fandoghi/core/fandoghi_coach.dart';
import 'package:amoozesh_fandoghi/core/game_data.dart';
import 'package:amoozesh_fandoghi/features/about/about_screen.dart';
import 'package:amoozesh_fandoghi/features/profile/profile_screen.dart';
import 'package:amoozesh_fandoghi/features/profile/sticker_album_screen.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ APP GATEWAY — جزیره فندقی
///
/// صفحهٔ اول به‌شکل یک جزیره واقعی: آسمان، خورشید، ابرها،
/// اقیانوس موج‌دار و یک جزیره شنی/چمنی. شش سکوی شناور سه‌بعدی
/// دور جزیره چیده شده‌اند:
///   ۱. بازی و یادگیری 🚀   ۲. سینما کارتون 🍿
///   ۳. قصه‌خانه 📚        ۴. لالایی‌های شب 🌙
///   ۵. پروفایل من 👑      ۶. درباره ما ℹ️
///
/// فندقی (راهنما/معلم) در صفحهٔ اول نیست و فقط داخل بخش
/// بازی و یادگیری حاضر می‌شود.
/// ═══════════════════════════════════════════════════════════════
class AppGatewayScreen extends StatefulWidget {
  const AppGatewayScreen({super.key});

  @override
  State<AppGatewayScreen> createState() => _AppGatewayScreenState();
}

class _AppGatewayScreenState extends State<AppGatewayScreen>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    // فندقی در صفحهٔ اول جزیره حاضر نیست تا فضا تمیز بماند.
    FandoghiCoach.disablePersistentPresence();
    FandoghiCoach.clear();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
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
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
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
                if (int.tryParse(controller.text) == n1 + n2) {
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
          // ── آسمان ──
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF7FC8FF),
                    Color(0xFFB6E4FF),
                    Color(0xFFD8F3FF),
                  ],
                ),
              ),
            ),
          ),

          // خورشید و ابرها
          const Positioned.fill(child: _SkyDecorations()),

          // ── اقیانوس و جزیره (پس‌زمینه) ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (_, __) => CustomPaint(
                painter: _OceanIslandPainter(_waveCtrl.value),
              ),
            ),
          ),

          // ── محتوای روی جزیره ──
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(name),
                _buildHeading(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child:
                  Text(GameData.avatar, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_timeGreeting()} $name! 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F3A5F),
                  ),
                ),
                Text(
                  'لول ${GameData.level} • ${GameData.getLevelName()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF1F3A5F).withOpacity(0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _iconPill(
            Icons.lock_outline_rounded,
            () => _parentGate(context),
          ),
        ],
      ),
    );
  }

  Widget _iconPill(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1F3A5F), size: 22),
      ),
    );
  }

  // ─── تیتر ───────────────────────────────────────────
  Widget _buildHeading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      child: Column(
        children: [
          Text(
            '🏝️ جزیره فندقی',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1F3A5F),
              letterSpacing: 0.5,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -3, duration: 2200.ms, curve: Curves.easeInOut),
          const SizedBox(height: 2),
          Text(
            'یه سکو رو انتخاب کن تا ماجراجویی شروع بشه!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F3A5F).withOpacity(0.75),
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
    final tileSize = ((maxWidth - gap * 2) / 3)
        .clamp(78.0, 132.0); // سه ستونه برای ۶ سکو

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
        SizedBox(height: gap + 4),
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
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
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 900.ms, duration: 500.ms)
          .slideY(begin: 0.4, curve: Curves.easeOutBack),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// داده و سکوی شناور
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
    Future.delayed(Duration(milliseconds: widget.index * 220), () {
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
    final imageBox = size * 0.82;

    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (context, child) {
        final wave = sin(_floatCtrl.value * pi * 2 + widget.index * 0.8);
        final dy = wave * 7;
        final tilt = wave * 0.05;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0018)
            ..rotateZ(tilt * 0.25)
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
            // مکعب تصویر
            AnimatedScale(
              scale: _pressed ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Container(
                width: imageBox,
                height: imageBox,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(imageBox * 0.22),
                  boxShadow: [
                    BoxShadow(
                      color: widget.tile.glow.withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      blurRadius: 4,
                      offset: const Offset(0, -3),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(imageBox * 0.22 - 3),
                  child: Image.asset(
                    widget.tile.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            // سکوی چوبی/چمنی زیر مکعب
            Transform.translate(
              offset: const Offset(0, -8),
              child: CustomPaint(
                size: Size(size, size * 0.26),
                painter: _PlatformPainter(widget.tile.glow),
              ),
            ),
            // لیبل
            Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: widget.tile.glow.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: widget.tile.glow.withOpacity(0.4),
                    width: 1.8,
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
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 250 + widget.index * 130),
          duration: 500.ms,
        )
        // ورود هیجانی: از بالا با پرش الاستیک + بزرگ‌نمایی + چرخش
        .slideY(
          begin: -1.4,
          end: 0,
          curve: Curves.elasticOut,
          duration: 1100.ms,
          delay: Duration(milliseconds: 200 + widget.index * 130),
        )
        .scale(
          begin: const Offset(0.25, 0.25),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 1100.ms,
          delay: Duration(milliseconds: 200 + widget.index * 130),
        )
        .rotate(
          begin: -0.18,
          end: 0,
          curve: Curves.elasticOut,
          duration: 1100.ms,
          delay: Duration(milliseconds: 200 + widget.index * 130),
        );
  }
}

// ═══════════════════════════════════════════════════════════
// نقاش اقیانوس و جزیره
// ═══════════════════════════════════════════════════════════
class _OceanIslandPainter extends CustomPainter {
  final double t;
  _OceanIslandPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // اقیانوس در پایین صفحه
    final waterTop = size.height * 0.62;
    final waterRect = Rect.fromLTWH(0, waterTop, size.width, size.height - waterTop);

    // بدنه آب
    final waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
      ).createShader(waterRect);
    canvas.drawRect(waterRect, waterPaint);

    // موج‌های متحرک
    _drawWave(canvas, size, waterTop + 6, 26, 1.0, 0.5, const Color(0x66B3E5FC));
    _drawWave(canvas, size, waterTop + 22, 18, 1.6, 0.7, const Color(0x88E1F5FE));
    _drawWave(canvas, size, waterTop + 44, 14, 2.2, 0.9, const Color(0x55FFFFFF));

    // جزیره: بیضی شنی بزرگ روی آب
    final islandCenter = Offset(size.width * 0.5, size.height * 0.74);
    final islandW = size.width * 0.92;
    final islandH = size.height * 0.2;

    // سایه/عمق شن
    final sandDeep = Paint()..color = const Color(0xFFE0A96B);
    canvas.drawOval(
      Rect.fromCenter(
        center: islandCenter.translate(0, islandH * 0.22),
        width: islandW,
        height: islandH * 0.7,
      ),
      sandDeep,
    );
    // شن روشن
    final sandLight = Paint()..color = const Color(0xFFF6D49A);
    canvas.drawOval(
      Rect.fromCenter(
        center: islandCenter,
        width: islandW * 0.95,
        height: islandH * 0.62,
      ),
      sandLight,
    );
    // چمن روی جزیره
    final grass = Paint()..color = const Color(0xFF7CC45A);
    canvas.drawOval(
      Rect.fromCenter(
        center: islandCenter.translate(0, -islandH * 0.12),
        width: islandW * 0.82,
        height: islandH * 0.42,
      ),
      grass,
    );
    final grassLight = Paint()..color = const Color(0xFF9BD877);
    canvas.drawOval(
      Rect.fromCenter(
        center: islandCenter.translate(0, -islandH * 0.18),
        width: islandW * 0.62,
        height: islandH * 0.26,
      ),
      grassLight,
    );

    // چند نارگیل/تخته‌سنگ کوچک تزئینی
    final dot = Paint()..color = const Color(0xFFB97B45);
    canvas.drawCircle(
        islandCenter.translate(-islandW * 0.28, -islandH * 0.04), 5, dot);
    canvas.drawCircle(
        islandCenter.translate(islandW * 0.3, -islandH * 0.02), 4, dot);
  }

  void _drawWave(Canvas canvas, Size size, double baseY, double amplitude,
      double speed, double phase, Color color) {
    final path = Path();
    path.moveTo(0, baseY);
    for (double x = 0; x <= size.width; x += 6) {
      final y =
          baseY + sin((x / size.width) * pi * 2 * speed + t * pi * 2 + phase) * amplitude;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _OceanIslandPainter oldDelegate) =>
      oldDelegate.t != t;
}

// ═══════════════════════════════════════════════════════════
// نقاش سکوی چوبی زیر هر مکعب
// ═══════════════════════════════════════════════════════════
class _PlatformPainter extends CustomPainter {
  final Color glow;
  _PlatformPainter(this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    final w = size.width;
    final h = size.height;

    // کناره چوبی (حجم سه‌بعدی)
    final side = Path()
      ..moveTo(w * 0.08, h * 0.45)
      ..quadraticBezierTo(w * 0.5, h * 0.95, w * 0.92, h * 0.45)
      ..quadraticBezierTo(w * 0.5, h * 0.7, w * 0.08, h * 0.45);
    canvas.drawPath(side, Paint()..color = const Color(0xFFB07A43));

    // رویه سکو (چمن روشن)
    final top = Path()
      ..moveTo(w * 0.05, h * 0.5)
      ..quadraticBezierTo(w * 0.5, -h * 0.15, w * 0.95, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.28, w * 0.05, h * 0.5);
    canvas.drawPath(top, Paint()..color = const Color(0xFF7CC45A));

    // هاله نور
    canvas.drawOval(
      Rect.fromCenter(
          center: center.translate(0, h * 0.1), width: w * 0.8, height: h * 0.5),
      Paint()..color = glow.withOpacity(0.18),
    );
  }

  @override
  bool shouldRepaint(covariant _PlatformPainter oldDelegate) =>
      oldDelegate.glow != glow;
}

// ═══════════════════════════════════════════════════════════
// خورشید و ابرها
// ═══════════════════════════════════════════════════════════
class _SkyDecorations extends StatelessWidget {
  const _SkyDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -36,
          left: -36,
          child: Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFFFE58A), Color(0xFFFFB74D)],
              ),
            ),
          ),
        ),
        // پرتو‌های نرم خورشید
        Positioned(
          top: -70,
          left: -70,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE58A).withOpacity(0.25),
            ),
          ),
        ),
        Positioned(
          top: 54,
          right: 22,
          child: _Cloud(width: 90, opacity: 0.9),
        ),
        Positioned(
          top: 110,
          left: 26,
          child: _Cloud(width: 66, opacity: 0.75),
        ),
        Positioned(
          top: 30,
          right: 130,
          child: _Cloud(width: 46, opacity: 0.6),
        ),
      ],
    );
  }
}

class _Cloud extends StatelessWidget {
  final double width;
  final double opacity;
  const _Cloud({required this.width, this.opacity = 0.8});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: width,
        height: width * 0.55,
        child: CustomPaint(painter: _CloudPainter()),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final r = size.height * 0.5;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.6), r, paint);
    canvas.drawCircle(
        Offset(size.width * 0.45, size.height * 0.35), r * 1.15, paint);
    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.5), r * 0.95, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            size.width * 0.1, size.height * 0.45, size.width * 0.7, r),
        Radius.circular(r),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
