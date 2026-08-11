import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import 'package:jazireh_fandoghi/core/audio_service.dart';
import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/features/about/about_screen.dart';
import 'package:jazireh_fandoghi/features/profile/profile_screen.dart';
import 'package:jazireh_fandoghi/features/profile/sticker_album_screen.dart';

/// دروازهٔ اصلی جزیره با سلسله‌مراتب روشن:
/// ۱) کارتون، ۲) قصه، ۳) بازی و یادگیری، سپس امکانات تکمیلی.
class AppGatewayScreen extends StatefulWidget {
  const AppGatewayScreen({super.key});

  @override
  State<AppGatewayScreen> createState() => _AppGatewayScreenState();
}

class _AppGatewayScreenState extends State<AppGatewayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _resetCoach();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _resetCoach() {
    // مربیِ صفحات بازی نباید هنگام برگشت روی منوی اصلی باقی بماند.
    FandoghiCoach.disablePersistentPresence();
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صبح بخیر ☀️';
    if (hour >= 12 && hour < 17) return 'روز بخیر 🌤️';
    if (hour >= 17 && hour < 21) return 'عصر بخیر 🌇';
    return 'شب بخیر 🌙';
  }

  void _openSection(String route) {
    HapticFeedback.mediumImpact();
    AudioService.select();
    Navigator.of(context).pushNamed(route).then((_) {
      _resetCoach();
      if (mounted) setState(() {});
    });
  }

  void _openWidget(Widget screen) {
    HapticFeedback.mediumImpact();
    AudioService.select();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen))
        .then((_) {
      _resetCoach();
      if (mounted) setState(() {});
    });
  }

  void _openStickers() {
    _openWidget(const StickerAlbumScreen());
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
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
              child: const Text('تأیید'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (approved == true && context.mounted) {
      await Navigator.pushNamed(context, '/parent');
      _resetCoach();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        GameData.childName.isNotEmpty ? GameData.childName : 'دوست کوچولو';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),
          const Positioned.fill(child: _BackgroundOverlay()),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(name),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          children: [
                            _buildHeading(),
                            const SizedBox(height: 14),
                            _PrioritySectionCard(
                              semanticsLabel: 'بازکردن سینمای کارتون',
                              title: 'سینما کارتون',
                              subtitle: 'کارتون‌های محبوب، امن و تماشایی',
                              badge: 'انتخاب اول بچه‌ها',
                              actionLabel: 'شروع تماشا',
                              image: 'assets/gateway/cartoon_tile.png',
                              colors: const [
                                Color(0xFF7B2FF7),
                                Color(0xFFFF3D81),
                              ],
                              height: 180,
                              featured: true,
                              onTap: () => _openSection('/cartoons'),
                            )
                                .animate()
                                .fadeIn(duration: 450.ms)
                                .slideY(begin: 0.10, curve: Curves.easeOutCubic),
                            const SizedBox(height: 12),
                            _PrioritySectionCard(
                              semanticsLabel: 'بازکردن قصه‌خانه',
                              title: 'قصه‌خانه',
                              subtitle: 'داستان‌های تصویری و صوتی با جایزه',
                              badge: 'پیشنهاد فندقی',
                              actionLabel: 'یک قصه بخونیم',
                              image: 'assets/gateway/story_tile.png',
                              colors: const [
                                Color(0xFF4B3FBA),
                                Color(0xFF9B51E0),
                              ],
                              height: 142,
                              onTap: () => _openSection('/stories'),
                            )
                                .animate()
                                .fadeIn(delay: 90.ms, duration: 450.ms)
                                .slideY(begin: 0.10, curve: Curves.easeOutCubic),
                            const SizedBox(height: 12),
                            _PrioritySectionCard(
                              semanticsLabel: 'بازکردن بازی و یادگیری',
                              title: 'بازی و یادگیری',
                              subtitle: 'بازی‌های مهارتی، مرحله‌ها و آموزش',
                              badge: 'یادگیری شاد',
                              actionLabel: 'بزن بریم',
                              image: 'assets/gateway/learn_tile.png',
                              colors: const [
                                Color(0xFF0061A8),
                                Color(0xFF00BFA6),
                              ],
                              height: 132,
                              onTap: () => _openSection('/home'),
                            )
                                .animate()
                                .fadeIn(delay: 180.ms, duration: 450.ms)
                                .slideY(begin: 0.10, curve: Curves.easeOutCubic),
                            const SizedBox(height: 18),
                            _buildMoreTitle(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _CompactSectionCard(
                                    title: 'لالایی‌های شب',
                                    subtitle: 'خواب آروم',
                                    image: 'assets/gateway/lullaby_tile.png',
                                    accent: const Color(0xFF3949AB),
                                    onTap: () => _openSection('/lullabies'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _CompactSectionCard(
                                    title: 'پروفایل من',
                                    subtitle: 'مدال‌ها و پیشرفت',
                                    image: 'assets/gateway/profile_tile.png',
                                    accent: const Color(0xFF00A884),
                                    onTap: () =>
                                        _openWidget(const ProfileScreen()),
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .fadeIn(delay: 270.ms, duration: 450.ms),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickLink(
                                    emoji: '📚',
                                    label: 'کتابخانه یادگیری',
                                    onTap: () =>
                                        _openSection('/learning-library'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _QuickLink(
                                    emoji: '🎀',
                                    label: 'استیکرهای من',
                                    onTap: _openStickers,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _QuickLink(
                                    emoji: 'ℹ️',
                                    label: 'درباره ما',
                                    onTap: () =>
                                        _openWidget(const AboutScreen()),
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .fadeIn(delay: 340.ms, duration: 450.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _backgroundController,
        child: Image.asset(
          'assets/gateway/island_bg.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        builder: (context, child) {
          final progress = sin(_backgroundController.value * pi);
          return Transform.translate(
            offset: Offset(0, progress * 4),
            child: Transform.scale(
              scale: 1.035 + progress * 0.008,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17345B).withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_timeGreeting()} $name!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF183B5B),
                        ),
                      ),
                      Text(
                        'لول ${GameData.level}  •  ${GameData.getLevelName()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.vazirmatn(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF587087),
                        ),
                      ),
                    ],
                  ),
                ),
                _BalanceBadge(emoji: '⭐', count: '${GameData.stars}'),
                const SizedBox(width: 5),
                _BalanceBadge(emoji: '💰', count: '${GameData.coins}'),
                const SizedBox(width: 6),
                Semantics(
                  button: true,
                  label: 'ورود به بخش والدین',
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _parentGate(context),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF183B5B),
                          size: 20,
                        ),
                      ),
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

  Widget _buildAvatar() {
    final hasPhoto = GameData.profilePhotoPath.isNotEmpty &&
        File(GameData.profilePhotoPath).existsSync();
    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B2FF7), Color(0xFF00BFA6)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2FF7).withOpacity(0.22),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipOval(
        child: ColoredBox(
          color: Colors.white,
          child: hasPhoto
              ? Image.file(File(GameData.profilePhotoPath), fit: BoxFit.cover)
              : GameData.avatar.startsWith('assets/')
                  ? Image.asset(GameData.avatar, fit: BoxFit.cover)
                  : Center(
                      child: Text(
                        GameData.avatar,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildHeading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.95)),
      ),
      child: Column(
        children: [
          Text(
            'امروز کجا بریم؟ ✨',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF183B5B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'یک ماجراجویی قشنگ انتخاب کن',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF587087),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildMoreTitle() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white, thickness: 1.4)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            'بخش‌های بیشتر',
            style: AppFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF183B5B),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white, thickness: 1.4)),
      ],
    );
  }
}

class _BackgroundOverlay extends StatelessWidget {
  const _BackgroundOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFEAFBFF).withOpacity(0.58),
            const Color(0xFFB9E8F2).withOpacity(0.18),
            const Color(0xFF064B68).withOpacity(0.22),
          ],
          stops: const [0, 0.48, 1],
        ),
      ),
    );
  }
}

class _BalanceBadge extends StatelessWidget {
  final String emoji;
  final String count;

  const _BalanceBadge({required this.emoji, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD95A), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text(
            count,
            style: AppFonts.vazirmatn(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF183B5B),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrioritySectionCard extends StatefulWidget {
  final String semanticsLabel;
  final String title;
  final String subtitle;
  final String badge;
  final String actionLabel;
  final String image;
  final List<Color> colors;
  final double height;
  final bool featured;
  final VoidCallback onTap;

  const _PrioritySectionCard({
    required this.semanticsLabel,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.actionLabel,
    required this.image,
    required this.colors,
    required this.height,
    required this.onTap,
    this.featured = false,
  });

  @override
  State<_PrioritySectionCard> createState() => _PrioritySectionCardState();
}

class _PrioritySectionCardState extends State<_PrioritySectionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onHighlightChanged: (value) => setState(() => _pressed = value),
            onTap: widget.onTap,
            child: Ink(
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: widget.colors,
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors.first.withOpacity(0.34),
                    blurRadius: widget.featured ? 24 : 18,
                    offset: const Offset(0, 9),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.55),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      left: -10,
                      top: -20,
                      bottom: -20,
                      width: widget.featured ? 205 : 170,
                      child: Image.asset(
                        widget.image,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            widget.colors.first.withOpacity(0.98),
                            widget.colors.first.withOpacity(0.86),
                            widget.colors.last.withOpacity(0.22),
                          ],
                          stops: const [0, 0.48, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 110,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.20),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        20,
                        widget.featured ? 17 : 13,
                        widget.featured ? 145 : 122,
                        widget.featured ? 17 : 13,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.32),
                              ),
                            ),
                            child: Text(
                              widget.badge,
                              maxLines: 1,
                              style: AppFonts.vazirmatn(
                                fontSize: widget.featured ? 11 : 9.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: widget.featured ? 8 : 5),
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.vazirmatn(
                              fontSize: widget.featured ? 25 : 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.vazirmatn(
                              fontSize: widget.featured ? 12 : 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.90),
                            ),
                          ),
                          SizedBox(height: widget.featured ? 11 : 7),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.featured ? 13 : 10,
                              vertical: widget.featured ? 7 : 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.featured
                                      ? Icons.play_arrow_rounded
                                      : Icons.arrow_back_rounded,
                                  size: widget.featured ? 19 : 16,
                                  color: widget.colors.first,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.actionLabel,
                                  style: AppFonts.vazirmatn(
                                    fontSize: widget.featured ? 11.5 : 10,
                                    fontWeight: FontWeight.w900,
                                    color: widget.colors.first,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final Color accent;
  final VoidCallback onTap;

  const _CompactSectionCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'بازکردن $title',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            height: 112,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.93),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.20),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.vazirmatn(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF183B5B),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.vazirmatn(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF587087),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Icon(
                          Icons.arrow_back_rounded,
                          color: accent,
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadiusDirectional.horizontal(
                    end: Radius.circular(22),
                  ),
                  child: Image.asset(
                    image,
                    width: 74,
                    height: double.infinity,
                    fit: BoxFit.cover,
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

class _QuickLink extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _QuickLink({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.90),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF183B5B).withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 21)),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF183B5B),
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
