import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_fonts.dart';
import '../../../core/ai_system.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../../../core/monetization.dart';
import '../../growth/widgets/growth_home_strip.dart';
import '../../growth/widgets/session_recap_sheet.dart';
import '../../../presentation/providers/game_state_provider.dart';
import '../../../shared/widgets/premium_daily_missions.dart';
import '../../../shared/widgets/premium_streak_calendar.dart';
import '../../../shared/widgets/premium/particle_celebration.dart';
import '../../profile/profile_editor.dart';
import '../../shop/full_version_paywall.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ DASHBOARD TAB — دنیای بازی و یادگیری جزیره فندقی
/// با تم سه‌بعدی لوکس، اقیانوس کریستالی، سکوهای شناور و انیمیشن‌های زنده
/// ═══════════════════════════════════════════════════════════════
class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<DashboardTab>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  _GameCategory _selectedCategory = _GameCategory.all;
  bool _showCelebration = false;

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

  static const _freeGames = {
    'الفبا',
    'اعداد',
    'رنگ‌ها',
    'ستاره‌گیری',
    'حباب‌ترکان',
    'نقاشی',
  };

  Future<void> _openGame(String route, String gameName) async {
    HapticFeedback.heavyImpact();
    AudioService.select();
    if (ParentControls.isRouteBlocked(route) || ParentControls.isBedtimeNow) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ParentControls.blockReason(route))),
      );
      return;
    }
    if (!_freeGames.contains(gameName) && !await Monetization.hasFullVersion()) {
      SmartConversion.noteLockedTap();
      if (mounted) {
        await showFullVersionPaywall(context, featureName: gameName);
      }
      return;
    }
    if (mounted) {
      ActivityTracker.recordOpen(route: route, title: gameName);
      Navigator.pushNamed(context, route).then((_) {
        if (mounted) {
          setState(() => _showCelebration = true);
          showSessionRecap(context);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _showCelebration = false);
          });
        }
      });
    }
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صبح بخیر ☀️';
    if (hour >= 12 && hour < 17) return 'روز بخیر 🌤️';
    if (hour >= 17 && hour < 21) return 'عصر بخیر 🌇';
    return 'شب بخیر 🌙';
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

  List<_GameTile> get _allGames => [
        _GameTile(
          title: 'الفبا',
          gameName: 'الفبا',
          route: '/game/الفبا',
          image: 'assets/illustrations/alphabet_world.webp',
          emoji: '🔤',
          glow: const Color(0xFF6C5CE7),
          category: _GameCategory.base,
          subtitle: 'یادگیری حروف فارسی',
        ),
        _GameTile(
          title: 'اعداد',
          gameName: 'اعداد',
          route: '/game/اعداد',
          image: 'assets/premium/numbers_premium.webp',
          emoji: '🔢',
          glow: const Color(0xFFFF8E53),
          category: _GameCategory.base,
          subtitle: 'شمارش و ریاضی',
        ),
        _GameTile(
          title: 'رنگ‌ها',
          gameName: 'رنگ‌ها',
          route: '/game/رنگ‌ها',
          image: 'assets/illustrations/colors_cards.webp',
          emoji: '🎨',
          glow: const Color(0xFFFA709A),
          category: _GameCategory.base,
          subtitle: 'ترکیب و آزمایش رنگ',
        ),
        _GameTile(
          title: 'شکل‌ها',
          gameName: 'اشکال',
          route: '/game/اشکال',
          image: 'assets/illustrations/shapes_cards.webp',
          emoji: '🔷',
          glow: const Color(0xFF00CEC9),
          category: _GameCategory.base,
          subtitle: 'شناخت اشکال هندسی',
        ),
        _GameTile(
          title: 'حافظه',
          gameName: 'حافظه',
          route: '/memory_match',
          image: 'assets/illustrations/memory_cards.webp',
          emoji: '🧠',
          glow: const Color(0xFFE17055),
          category: _GameCategory.brain,
          subtitle: 'تقویت هوش و حافظه',
        ),
        _GameTile(
          title: 'حباب‌ترکان',
          gameName: 'حباب‌ترکان',
          route: '/bubble_pop',
          emoji: '🫧',
          glow: const Color(0xFF00B894),
          category: _GameCategory.fun,
          subtitle: 'ترکاندن حباب‌های شاد',
        ),
        _GameTile(
          title: 'ستاره‌گیری',
          gameName: 'ستاره‌گیری',
          route: '/star_catch',
          image: 'assets/premium/star_catch_icon.webp',
          emoji: '⭐',
          glow: const Color(0xFFFF5252),
          category: _GameCategory.fun,
          subtitle: 'شکار ستاره‌های درخشان',
        ),
        _GameTile(
          title: 'دفتر نقاشی',
          gameName: 'نقاشی',
          route: '/game/نقاشی',
          image: 'assets/illustrations/drawing_stickers.webp',
          emoji: '🖌️',
          glow: const Color(0xFFBA68C8),
          category: _GameCategory.fun,
          subtitle: 'رنگ‌آمیزی و نقاشی آزاد',
        ),
        _GameTile(
          title: 'حیوانات',
          gameName: 'حیوانات',
          route: '/game/حیوانات',
          image: 'assets/illustrations/animals_cards.webp',
          emoji: '🦁',
          glow: const Color(0xFF43A047),
          category: _GameCategory.world,
          subtitle: 'آشنایی با دنیای حیوانات',
        ),
        _GameTile(
          title: 'شغل‌ها',
          gameName: 'شغل‌ها',
          route: '/game/شغل‌ها',
          image: 'assets/illustrations/jobs_cards.webp',
          emoji: '👨‍🚒',
          glow: const Color(0xFF1E88E5),
          category: _GameCategory.world,
          subtitle: 'شناخت شغل‌های آینده',
        ),
        _GameTile(
          title: 'بدن من',
          gameName: 'بدن',
          route: '/body_parts',
          image: 'assets/illustrations/body_cards.webp',
          emoji: '🫀',
          glow: const Color(0xFFE91E63),
          category: _GameCategory.world,
          subtitle: 'شناخت اعضای بدن',
        ),
        _GameTile(
          title: 'میوه‌ها',
          gameName: 'میوه',
          route: '/game/میوه',
          image: 'assets/illustrations/fruits_cards.webp',
          emoji: '🍎',
          glow: const Color(0xFFFF9800),
          category: _GameCategory.world,
          subtitle: 'خوراکی‌ها و ویتامین‌ها',
        ),
        _GameTile(
          title: 'پازل',
          gameName: 'پازل',
          route: '/puzzle',
          emoji: '🧩',
          glow: const Color(0xFF3F51B5),
          category: _GameCategory.brain,
          subtitle: 'چیدن قطعات جورچین',
        ),
        _GameTile(
          title: 'مسابقه سرعت',
          gameName: 'مسابقه',
          route: '/math_race',
          emoji: '🏁',
          glow: const Color(0xFFFF6F00),
          category: _GameCategory.brain,
          subtitle: 'مسابقه هوش و سرعت',
        ),
        _GameTile(
          title: 'صداها',
          gameName: 'صدا',
          route: '/sound_match',
          emoji: '🎵',
          glow: const Color(0xFF00BCD4),
          category: _GameCategory.brain,
          subtitle: 'تشخیص صداهای محیطی',
        ),
        _GameTile(
          title: 'الگوها',
          gameName: 'الگو',
          route: '/pattern',
          image: 'assets/premium/patterns_premium.webp',
          emoji: '🔮',
          glow: const Color(0xFF9C27B0),
          category: _GameCategory.brain,
          subtitle: 'کشف نظم و توالی',
        ),
        const _GameTile(
          title: 'مهارت زندگی',
          gameName: 'مهارت زندگی',
          route: '/life-skills',
          emoji: '🧭',
          glow: Color(0xFF00897B),
          category: _GameCategory.world,
          subtitle: 'خیابان، بهداشت و ایران',
        ),
      ];

  List<_GameTile> get _filteredGames {
    if (_selectedCategory == _GameCategory.all) return _allGames;
    return _allGames
        .where((game) => game.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameStateProvider);
    final name =
        GameData.childName.isNotEmpty ? GameData.childName : 'دوست کوچولو';

    return Scaffold(
      body: ConfettiOverlay(
        isActive: _showCelebration,
        onComplete: () => setState(() => _showCelebration = false),
        child: Stack(
          children: [
          // ── پس‌زمینه جزیره جادویی یادگیری با شناوری ملایم ──
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
                'assets/gateway/learn_island_bg.webp',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // لایه هاله نرم برای شفافیت و خوانایی بی‌نقص
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.35),
                    Colors.transparent,
                    Colors.black.withOpacity(0.15),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── محتوای دنیای بازی‌ها ──
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(name),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 580),
                            child: Column(
                              children: [
                                _buildHeading(),
                                const SizedBox(height: 12),
                                const GrowthHomeStrip(),
                                const SizedBox(height: 16),
                                _sectionTitle('دسته‌بندی بازی‌ها'),
                                const SizedBox(height: 8),
                                _buildCategoryPills(),
                                const SizedBox(height: 14),
                                _buildPlatformsGrid(constraints),
                                const SizedBox(height: 20),
                                _sectionTitle('بازی‌های سریع'),
                                const SizedBox(height: 8),
                                _buildQuickGamesRow(),
                                const SizedBox(height: 16),
                                // 🔥 پریمیوم استریک تقویم شمسی + قلب یخی (پیشنهاد ۳۳)
                                PremiumStreakCalendar(
                                  onHeartIceTap: () {
                                    if (GameData.streak == 0) {
                                      if (GameData.activateIceHeart()) {
                                        // قلب یخی یک روز streak را نجات می‌دهد
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('🧊 قلب یخی فعال شد! فردا جای خالی را پر می‌کند — ۵۰ سکه کم شد')),
                                        );
                                        setState(() {});
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('برای قلب یخی به ۵۰ سکه نیاز داری 💰')),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('🔥 استریک ${GameData.streak} روزه‌ات عالیه! ادامه بده تا صندوق طلایی!')),
                                      );
                                    }
                                  },
                                  onCalendarTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('📅 تقویم کامل شمسی به زودی — فعلاً ۷ روز آخر را اینجا می‌بینی!')),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                _sectionTitle('ماموریت‌های امروز'),
                                const SizedBox(height: 8),
                                PremiumDailyMissions(
                                  onClaimChest: () {
                                    if (GameData.claimDailyMissionChest()) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('صندوق روزانه باز شد! +۲۰ سکه گرفتی 🎁')),
                                      );
                                      setState(() {});
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildDailyMotivationCard(),
                                if (AI.needsBreak() &&
                                    !GameData.isDailyLimitReached) ...[
                                  const SizedBox(height: 12),
                                  _buildBreakReminder(),
                                ],
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  // ─── نوار بالا ──────────────────────────────────────
  Widget _buildTopBar(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                _iconPill(
                  Icons.arrow_back_rounded,
                  () {
                    HapticFeedback.lightImpact();
                    AudioService.tap();
                    Navigator.maybePop(context);
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => showProfileEditor(context),
                  child: Container(
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
                      child: GameData.avatar.startsWith('assets/')
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
                ),
                const SizedBox(width: 8),
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
                          fontSize: 14,
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
                _balanceBadge('⭐', PersianDigits.toFa(GameData.stars)),
                const SizedBox(width: 5),
                _balanceBadge('💰', PersianDigits.toFa(GameData.coins)),
                const SizedBox(width: 5),
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: Column(
        children: [
          Text(
            '🚀 دنیای بازی و یادگیری',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1F3A5F),
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -3, duration: 2200.ms, curve: Curves.easeInOut),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
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
              'یک بازی انتخاب کن و ماجراجویی کن!',
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

  // ─── دسته‌بندی‌ها (Filter Pills) ───────────────────
  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: _GameCategory.values.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                AudioService.tap();
                setState(() => _selectedCategory = cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6C5CE7)
                      : Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF5A4BD8)
                        : Colors.white,
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF6C5CE7).withOpacity(0.35)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      cat.title,
                      style: AppFonts.vazirmatn(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1F3A5F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── گرید سکوهای شناور سه‌بعدی بازی‌ها ─────────────
  /// عنوان بخش‌های داشبورد — یک سبک واحد برای همه سرتیترها.
  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          text,
          style: AppFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1F3A5F),
          ),
        ),
      ),
    );
  }

  /// ردیف افقی بازی‌های رایگان برای شروع فوری بدون پرداخت.
  Widget _buildQuickGamesRow() {
    final quickTiles = _allGames
        .where((tile) => _freeGames.contains(tile.gameName))
        .take(6)
        .toList();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: quickTiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final tile = quickTiles[i];
          return ActionChip(
            avatar: Text(tile.emoji, style: const TextStyle(fontSize: 16)),
            label: Text(
              tile.gameName,
              style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            onPressed: () => _openGame(tile.route, tile.gameName),
          );
        },
      ),
    );
  }

  Widget _buildPlatformsGrid(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 360.0;
    final gap = 12.0;
    final tileSize = ((maxWidth - gap * 2) / 3).clamp(84.0, 125.0);

    final games = _filteredGames;
    final rows = <Widget>[];

    for (var i = 0; i < games.length; i += 3) {
      final rowGames = games.skip(i).take(3).toList();
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var j = 0; j < rowGames.length; j++) ...[
              if (j > 0) SizedBox(width: gap),
              _GameFloatingPlatform(
                tile: rowGames[j],
                size: tileSize,
                index: i + j,
                onTap: () => _openGame(rowGames[j].route, rowGames[j].gameName),
              ),
            ],
          ],
        ),
      );
      if (i + 3 < games.length) {
        rows.add(SizedBox(height: gap + 6));
      }
    }

    return Column(children: rows);
  }

  // ─── کارت انگیزش روزانه و ستاره‌ها ─────────────────
  Widget _buildDailyMotivationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStatItem('🔥', '${GameData.streak} روز', 'پشتکار'),
          Container(width: 1, height: 32, color: Colors.grey.withOpacity(0.2)),
          _miniStatItem('⭐', '${GameData.totalCorrect}', 'پاسخ درست'),
          Container(width: 1, height: 32, color: Colors.grey.withOpacity(0.2)),
          _miniStatItem('🏅', '${GameData.achievements.length}', 'مدال افتخار'),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3);
  }

  Widget _miniStatItem(String emoji, String value, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F3A5F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F3A5F).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // ─── یادآوری استراحت چشم (قانون 20-20-20) ───────────
  Widget _buildBreakReminder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD).withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
          Text('😴', style: TextStyle(fontSize: 32)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'وقت یک استراحت کوتاه است؛ ۲۰ ثانیه به منظره دور نگاه کن تا چشم‌های قشنگت خسته نشن! 🌈',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1565C0),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// دسته‌بندی‌ها
// ═══════════════════════════════════════════════════════════
enum _GameCategory {
  all('همه', '🌟'),
  base('آموزش پایه', '🔤'),
  brain('بازی فکری', '🧠'),
  fun('سرگرمی و هنر', '🎨'),
  world('دنیای اطراف', '🌍');

  final String title;
  final String emoji;
  const _GameCategory(this.title, this.emoji);
}

// ═══════════════════════════════════════════════════════════
// مدل کاشی بازی
// ═══════════════════════════════════════════════════════════
class _GameTile {
  final String title;
  final String gameName;
  final String route;
  final String? image;
  final String emoji;
  final Color glow;
  final _GameCategory category;
  final String subtitle;

  const _GameTile({
    required this.title,
    required this.gameName,
    required this.route,
    this.image,
    required this.emoji,
    required this.glow,
    required this.category,
    required this.subtitle,
  });
}

// ═══════════════════════════════════════════════════════════
// سکوی شناور سه‌بعدی بازی (هم‌تم با جزیره)
// ═══════════════════════════════════════════════════════════
class _GameFloatingPlatform extends StatefulWidget {
  final _GameTile tile;
  final double size;
  final int index;
  final VoidCallback onTap;

  const _GameFloatingPlatform({
    required this.tile,
    required this.size,
    required this.index,
    required this.onTap,
  });

  @override
  State<_GameFloatingPlatform> createState() => _GameFloatingPlatformState();
}

class _GameFloatingPlatformState extends State<_GameFloatingPlatform>
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
    Future.delayed(Duration(milliseconds: widget.index * 120), () {
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
    final tile = widget.tile;

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
        onTap: widget.onTap,
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
                      color: tile.glow.withOpacity(0.55),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.85),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2.8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tile.glow.withOpacity(0.88),
                      tile.glow,
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(imageBox * 0.24 - 2.8),
                  child: tile.image != null
                      ? Image.asset(
                          tile.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Center(
                          child: Text(
                            tile.emoji,
                            style: TextStyle(fontSize: imageBox * 0.44),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            // برچسب نام بازی
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: tile.glow.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: tile.glow.withOpacity(0.45),
                  width: 1.6,
                ),
              ),
              child: Text(
                tile.title,
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
          delay: Duration(milliseconds: 150 + widget.index * 50),
          duration: 400.ms,
        )
        .slideY(
          begin: -0.7,
          end: 0,
          curve: Curves.elasticOut,
          duration: 900.ms,
          delay: Duration(milliseconds: 100 + widget.index * 50),
        )
        .scale(
          begin: const Offset(0.4, 0.4),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 900.ms,
          delay: Duration(milliseconds: 100 + widget.index * 50),
        );
  }
}
