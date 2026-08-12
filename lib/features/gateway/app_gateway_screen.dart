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
import 'package:jazireh_fandoghi/core/growth/growth.dart';
import 'package:jazireh_fandoghi/core/jalali_calendar.dart';
import 'package:jazireh_fandoghi/features/about/about_screen.dart';
import 'package:jazireh_fandoghi/features/profile/profile_screen.dart';
import 'package:jazireh_fandoghi/features/profile/sticker_album_screen.dart';

/// دروازهٔ جزیره مرجانی — چیدمان حبابی مطابق طرح انتخاب‌شده.
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GrowthStore.isLoaded && GrowthStore.shouldShowWhatsNew) {
        Navigator.of(context).pushNamed('/whats-new');
      }
    });
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
    FandoghiCoach.disablePersistentPresence();
  }

  String _timeGreeting() {
    final weekday = JalaliDate.weekdayName(DateTime.now());
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '$weekday بخیر ☀️';
    if (hour >= 12 && hour < 17) return '$weekday به‌خیر 🌤️';
    if (hour >= 17 && hour < 21) return 'عصر $weekday بخیر 🌇';
    return 'شب $weekday بخیر 🌙';
  }

  void _openSection(String route) {
    HapticFeedback.mediumImpact();
    AudioService.select();
    if (ParentControls.isRouteBlocked(route)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ParentControls.blockReason(route))),
      );
      return;
    }
    ActivityTracker.recordOpen(route: route, title: route);
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

  String _normalizeDigits(String input) {
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var result = input;
    for (var i = 0; i < persianDigits.length; i++) {
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
    final width = MediaQuery.sizeOf(context).width;
    final bubble = (width * 0.38).clamp(118.0, 168.0);
    final learnBubble = (width * 0.36).clamp(110.0, 156.0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(name),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          children: [
                            _buildSeashellTitle(),
                            const SizedBox(height: 8),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _BubblePortal(
                                      key: const Key('gateway.cartoon'),
                                      semanticsLabel: 'بازکردن کارتون',
                                      title: 'کارتون',
                                      actionLabel: 'شروع تماشا',
                                      image: 'assets/gateway/bubble_cartoon.webp',
                                      actionColor: const Color(0xFF00A8B5),
                                      size: bubble,
                                      titleSize: 22,
                                      onTap: () => _openSection('/cartoons'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _BubblePortal(
                                      key: const Key('gateway.stories'),
                                      semanticsLabel: 'بازکردن داستان',
                                      title: 'داستان',
                                      actionLabel: 'بخونیم',
                                      image: 'assets/gateway/bubble_story.webp',
                                      actionColor: const Color(0xFFC44BD1),
                                      size: bubble,
                                      titleSize: 22,
                                      onTap: () => _openSection('/stories'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 420.ms)
                                .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                            const SizedBox(height: 6),
                            _BubblePortal(
                              key: const Key('gateway.learning'),
                              semanticsLabel: 'بازکردن بازی و یادگیری',
                              title: 'بازی و یادگیری',
                              actionLabel: 'بزن بریم',
                              image: 'assets/gateway/bubble_learn.webp',
                              actionColor: const Color(0xFF2E9B4A),
                              size: learnBubble,
                              titleSize: 18,
                              onTap: () => _openSection('/home'),
                            )
                                .animate()
                                .fadeIn(delay: 120.ms, duration: 420.ms)
                                .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _SandOvalTile(
                                    emoji: '⭐',
                                    title: 'پروفایل من',
                                    onTap: () =>
                                        _openWidget(const ProfileScreen()),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SandOvalTile(
                                    emoji: '🌙',
                                    title: 'لالایی‌های شب',
                                    onTap: () => _openSection('/lullabies'),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _CoralCircle(
                                    emoji: '🪸',
                                    title: 'درباره ما',
                                    onTap: () =>
                                        _openWidget(const AboutScreen()),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _CoralCircle(
                                    emoji: '🐠',
                                    title: 'استیکرهای من',
                                    onTap: () =>
                                        _openWidget(const StickerAlbumScreen()),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _CoralCircle(
                                    emoji: '📚',
                                    title: 'کتابخانه یادگیری',
                                    onTap: () =>
                                        _openSection('/learning-library'),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 280.ms, duration: 400.ms),
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
          'assets/gateway/coral_world_bg.webp',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        builder: (context, child) {
          final progress = sin(_backgroundController.value * pi);
          return Transform.translate(
            offset: Offset(0, progress * 4),
            child: Transform.scale(
              scale: 1.03 + progress * 0.008,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF7E8C8).withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17345B).withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 8),
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
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF5A3A1B),
                        ),
                      ),
                      Text(
                        'لول ${GameData.level}  •  ${GameData.getLevelName()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.vazirmatn(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8A6A45),
                        ),
                      ),
                    ],
                  ),
                ),
                _SandChip(
                  emoji: '💰',
                  count: PersianDigits.toFa(GameData.coins),
                ),
                const SizedBox(width: 5),
                _SandChip(
                  emoji: '⭐',
                  count: PersianDigits.toFa(GameData.stars),
                ),
                const SizedBox(width: 5),
                _HeaderIcon(
                  icon: Icons.search_rounded,
                  label: 'جستجو در جزیره',
                  onTap: () => _openSection('/search'),
                ),
                const SizedBox(width: 5),
                _HeaderIcon(
                  icon: Icons.lock_outline_rounded,
                  label: 'ورود به بخش والدین',
                  onTap: () => _parentGate(context),
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
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFF00BFA6)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB347).withOpacity(0.28),
            blurRadius: 8,
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

  Widget _buildSeashellTitle() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8E8C9).withOpacity(0.94),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5A2B).withOpacity(0.16),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'امروز کجا بریم؟',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFC2185B),
            ),
          ),
          Text(
            'یک ماجراجویی قشنگ انتخاب کن',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6D4C2B),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

class _SandChip extends StatelessWidget {
  final String emoji;
  final String count;

  const _SandChip({required this.emoji, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8C56B), width: 1.2),
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
              color: const Color(0xFF5A3A1B),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: const Color(0xFFFFF6E0),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: const Color(0xFF5A3A1B), size: 18),
          ),
        ),
      ),
    );
  }
}

class _BubblePortal extends StatefulWidget {
  final String semanticsLabel;
  final String title;
  final String actionLabel;
  final String image;
  final Color actionColor;
  final double size;
  final double titleSize;
  final VoidCallback onTap;

  const _BubblePortal({
    super.key,
    required this.semanticsLabel,
    required this.title,
    required this.actionLabel,
    required this.image,
    required this.actionColor,
    required this.size,
    required this.titleSize,
    required this.onTap,
  });

  @override
  State<_BubblePortal> createState() => _BubblePortalState();
}

class _BubblePortalState extends State<_BubblePortal> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onHighlightChanged: (value) => setState(() => _pressed = value),
            onTap: widget.onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0277BD).withOpacity(0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(widget.image, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6E4B8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 1.4),
                  ),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: AppFonts.vazirmatn(
                      fontSize: widget.titleSize,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4A2E12),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.actionColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.actionColor.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.actionLabel,
                    style: AppFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
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
}

class _SandOvalTile extends StatelessWidget {
  final String emoji;
  final String title;
  final VoidCallback onTap;

  const _SandOvalTile({
    required this.emoji,
    required this.title,
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
          borderRadius: BorderRadius.circular(40),
          child: Ink(
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF3D7A0),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5A2B).withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.vazirmatn(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4A2E12),
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

class _CoralCircle extends StatelessWidget {
  final String emoji;
  final String title;
  final VoidCallback onTap;

  const _CoralCircle({
    required this.emoji,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF8A80), Color(0xFFE57373)],
                  ),
                  border: Border.all(color: const Color(0xFFFFCDD2), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE57373).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
