import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_fonts.dart';
import '../../../app/app_theme.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_launch.dart';
import '../../../core/growth/growth.dart';
import '../../../core/monetization.dart';
import '../../shop/full_version_paywall.dart';
import 'island_map/hub_island_node.dart';
import 'island_map/island_map_background.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ مدل اطلاعات هر هاب آموزشی / بازی
/// ═══════════════════════════════════════════════════════════════
class HubActivity {
  final String title;
  final String subtitle;
  final String emoji;
  final String route;
  final String? image;
  final bool isFree;
  final String gameName;

  const HubActivity({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.route,
    this.image,
    this.isFree = true,
    required this.gameName,
  });

  /// نام کوتاهِ روی پلاکِ سکو. عنوان کامل («آکادمی الفبای فارسی») برای
  /// پلاک بلند است و متن را ریز می‌کند، ولی `gameName` همیشه یک اسمِ
  /// کوتاه و بچگانه است («الفبا»)، پس همان را روی سکو می‌نویسیم.
  String get shortTitle => gameName;
}

class HubData {
  final String id;
  final String title;
  final String subtitle;
  final String mascotImage;
  final List<Color> gradient;
  final Color primaryColor;
  final Color shadowColor;
  final String coachGreeting;
  final List<HubActivity> activities;

  const HubData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.mascotImage,
    required this.gradient,
    required this.primaryColor,
    required this.shadowColor,
    required this.coachGreeting,
    required this.activities,
  });
}

/// ═══════════════════════════════════════════════════════════════
/// 🎨 داده‌های ۶ هاب اصلی جزیره فندقی
/// ═══════════════════════════════════════════════════════════════
class FandoqiHubs {
  static const HubData farsi = HubData(
    id: 'farsi',
    title: 'سرزمین فارسی و ادبیات',
    subtitle: 'الفبا، خواندن، قصه‌گویی و گنجینه واژگان شیرین فارسی',
    mascotImage: 'assets/mascot/owl_professor_clean.png',
    gradient: [Color(0xFFD35400), Color(0xFFE67E22), Color(0xFFF39C12)],
    primaryColor: Color(0xFFD35400),
    shadowColor: Color(0xFF873600),
    coachGreeting: 'به دنیای زیبای زبان فارسی خوش اومدی دانا کوچولو! 📖🦉',
    activities: [
      HubActivity(
        title: 'آکادمی الفبای فارسی',
        subtitle: 'آموزش گام به گام ۳۲ حرف فارسی با صوت و تصویر',
        emoji: '🔤',
        route: '/game/الفبا',
        image: 'assets/illustrations/alphabet_world.webp',
        gameName: 'الفبا',
        isFree: true,
      ),
      HubActivity(
        title: 'قصه‌خانه صوتی فندقی',
        subtitle: 'داستان‌های آموزنده و صوتی با تصاویر جذاب',
        emoji: '📖',
        route: '/stories',
        image: 'assets/gateway/bubble_story.webp',
        gameName: 'داستان',
        isFree: true,
      ),
      HubActivity(
        title: 'گنجینه واژگان و کلمات',
        subtitle: 'کشف کلمات جدید و تقویت دایره لغات کودک',
        emoji: '📚',
        route: '/vocabulary',
        gameName: 'واژگان',
        isFree: false,
      ),
      HubActivity(
        title: 'بازی تشخیص صداها',
        subtitle: 'گوش بده و صدای درست حروف رو حدس بزن',
        emoji: '🎧',
        route: '/sound_match',
        gameName: 'صدا',
        isFree: false,
      ),
    ],
  );

  static const HubData math = HubData(
    id: 'math',
    title: 'دنیای شگفت‌انگیز ریاضی',
    subtitle: 'اعداد، شمارش، جمع، تفریق، مسابقه سرعت و بازی‌های فکری',
    mascotImage: 'assets/mascot/dino_math_clean.png',
    gradient: [Color(0xFF8E44AD), Color(0xFF9B59B6), Color(0xFFAF7AC5)],
    primaryColor: Color(0xFF8E44AD),
    shadowColor: Color(0xFF512E5F),
    coachGreeting: 'آماده‌ای با دایناسور مهربون اعداد رو فتح کنیم؟ 🦖🔢',
    activities: [
      HubActivity(
        title: 'آکادمی اعداد و شمارش',
        subtitle: 'آموزش شمارش ۱ تا ۲۰ با بازی‌های تعاملی و صوتی',
        emoji: '🔢',
        route: '/game/اعداد',
        image: 'assets/premium/numbers_premium.webp',
        gameName: 'اعداد',
        isFree: true,
      ),
      HubActivity(
        title: 'مسابقه سرعت و هوش ریاضی',
        subtitle: 'رانندگی هیجانی در پیست با پاسخ سریع به سوالات',
        emoji: '🏎️',
        route: '/math_race',
        gameName: 'مسابقه',
        isFree: true,
      ),
      HubActivity(
        title: 'کشف الگوها و توالی‌ها',
        subtitle: 'تقویت منطق و تشخیص نظم اشکال و رنگ‌ها',
        emoji: '🔮',
        route: '/pattern',
        image: 'assets/premium/patterns_premium.webp',
        gameName: 'الگو',
        isFree: false,
      ),
      HubActivity(
        title: 'مقایسه و مفاهیم ریاضی',
        subtitle: 'کوچک‌تر و بزرگ‌تر، سبک و سنگین، کم و زیاد',
        emoji: '⚖️',
        route: '/concepts',
        gameName: 'مفاهیم',
        isFree: false,
      ),
    ],
  );

  static const HubData lettersAndSounds = HubData(
    id: 'letters',
    title: 'سرزمین حروف و صداها',
    subtitle: 'آواشناسی، مشق دیجیتال، تلفظ صوتی و تمرین شنیداری',
    mascotImage: 'assets/mascot/penguin_letters_clean.png',
    gradient: [Color(0xFF2980B9), Color(0xFF3498DB), Color(0xFF5DADE2)],
    primaryColor: Color(0xFF2980B9),
    shadowColor: Color(0xFF1B4F72),
    coachGreeting: 'پنگوئن بامزه منتظرته تا صداهای جادویی رو بشنویم! 🐧🎶',
    activities: [
      HubActivity(
        title: 'مشق و ترسیم حروف الفبا',
        subtitle: 'ردیابی و کشیدن فرم صحیح حروف با انگشت',
        emoji: '✏️',
        route: '/alphabet',
        image: 'assets/illustrations/alphabet_world.webp',
        gameName: 'الفبا',
        isFree: true,
      ),
      HubActivity(
        title: 'بازی تطبیق صدای آواها',
        subtitle: 'کدام حرف صدای «آ» یا «ب» می‌دهد؟ انتخاب کن!',
        emoji: '🎵',
        route: '/sound_match',
        gameName: 'صدا',
        isFree: false,
      ),
      HubActivity(
        title: 'حباب‌ترکان حروف و کلمات',
        subtitle: 'ترکاندن حباب‌های حروف الفبا با صدای زنده',
        emoji: '🫧',
        route: '/bubble_pop',
        gameName: 'حباب‌ترکان',
        isFree: true,
      ),
      HubActivity(
        title: 'کتابخانه یادگیری جامع',
        subtitle: 'مجموعه دسته‌بندی‌شده حروف، لغات و مفاهیم',
        emoji: '📖',
        route: '/learning-library',
        gameName: 'کتابخانه',
        isFree: true,
      ),
    ],
  );

  static const HubData science = HubData(
    id: 'science',
    title: 'دنیای کاوش و علوم',
    subtitle: 'دایرةالمعارف حیوانات، اعضای بدن، طبیعت و مهارت‌های زندگی',
    mascotImage: 'assets/mascot/squirrel_science_clean.png',
    gradient: [Color(0xFF27AE60), Color(0xFF2ECC71), Color(0xFF58D68D)],
    primaryColor: Color(0xFF27AE60),
    shadowColor: Color(0xFF1E8449),
    coachGreeting: 'ذره‌بین فندقی رو بردار بریم جهان رو کشف کنیم! 🐿️🔍',
    activities: [
      HubActivity(
        title: 'دایرةالمعارف حیوانات',
        subtitle: 'شناخت محل زندگی، صدا و غذای حیوانات شگفت‌انگیز',
        emoji: '🦁',
        route: '/game/حیوانات',
        image: 'assets/illustrations/animals_cards.webp',
        gameName: 'حیوانات',
        isFree: false,
      ),
      HubActivity(
        title: 'شناخت اعضای بدن',
        subtitle: 'آشنایی با شگفتی‌های حواس پنجگانه و بدن انسان',
        emoji: '🫀',
        route: '/body_parts',
        image: 'assets/illustrations/body_cards.webp',
        gameName: 'بدن',
        isFree: false,
      ),
      HubActivity(
        title: 'مهارت‌های زندگی و سلامت',
        subtitle: 'قوانین عبور از خیابان، بهداشت فردی و تغذیه سالم',
        emoji: '🧭',
        route: '/life-skills',
        gameName: 'مهارت زندگی',
        isFree: false,
      ),
      HubActivity(
        title: 'مفاهیم علوم و دنیای اطراف',
        subtitle: 'فصل‌ها، آب‌وهوا، شب و روز و پدیده‌های طبیعی',
        emoji: '🌍',
        route: '/concepts',
        gameName: 'مفاهیم',
        isFree: false,
      ),
    ],
  );

  static const HubData games = HubData(
    id: 'games',
    title: 'شهربازی و مینی‌گیم‌ها',
    subtitle: 'بازی‌های شاد، سرگرم‌کننده، رکوردی و پر از سکه و جایزه',
    mascotImage: 'assets/mascot/pirate_treasure_clean.png',
    gradient: [Color(0xFFE67E22), Color(0xFFF39C12), Color(0xFFF8C471)],
    primaryColor: Color(0xFFE67E22),
    shadowColor: Color(0xFFB9770E),
    coachGreeting: 'صندوق گنج پر از بازی‌های شاد و جوایز منتظرته! 🏴‍☠️🎁',
    activities: [
      HubActivity(
        title: 'حباب‌ترکان هیجانی',
        subtitle: 'ترکاندن سریع حباب‌های شاد و رنگی قبل از پرواز',
        emoji: '🫧',
        route: '/bubble_pop',
        gameName: 'حباب‌ترکان',
        isFree: true,
      ),
      HubActivity(
        title: 'ستاره‌گیری کهکشانی',
        subtitle: 'گرفتن ستاره‌های طلایی با سبد جادویی در آسمان',
        emoji: '⭐',
        route: '/star_catch',
        image: 'assets/premium/star_catch_icon.webp',
        gameName: 'ستاره‌گیری',
        isFree: true,
      ),
      HubActivity(
        title: 'حافظه تصویری',
        subtitle: 'تقویت هوش و حافظه دیداری با پیدا کردن کارت‌های جفت',
        emoji: '🧠',
        route: '/memory_match',
        image: 'assets/illustrations/memory_cards.webp',
        gameName: 'حافظه',
        isFree: false,
      ),
      HubActivity(
        title: 'جورچین و پازل تصویری',
        subtitle: 'چیدن قطعات و ساخت تصاویر زیبا و شاداب',
        emoji: '🧩',
        route: '/puzzle',
        gameName: 'پازل',
        isFree: false,
      ),
      HubActivity(
        title: 'جزیره‌ساز فندقی',
        subtitle: 'ساخت و تزئین جزیره اختصاصی خودت با درخت‌ها و قصرهای زیبا',
        emoji: '🏝️',
        route: '/island_builder',
        gameName: 'جزیره‌ساز',
        isFree: false,
      ),
    ],
  );

  static const HubData art = HubData(
    id: 'art',
    title: 'کارگاه هنر و خلاقیت',
    subtitle: 'نقاشی آزاد، ترکیب جادویی رنگ‌ها، اشکال و لالایی‌های آرامش‌بخش',
    mascotImage: 'assets/mascot/bunny_artist_clean.png',
    gradient: [Color(0xFFC0392B), Color(0xFFE74C3C), Color(0xFFF1948A)],
    primaryColor: Color(0xFFE74C3C),
    shadowColor: Color(0xFF922B21),
    coachGreeting: 'قلم‌مو و پالت رنگ رو بردار؛ شاهکار جدیدت رو بکش! 🐰🎨',
    activities: [
      HubActivity(
        title: 'دفتر نقاشی و رنگ‌آمیزی',
        subtitle: 'بوم نقاشی دیجیتال با انواع قلم‌ها، استیکرها و رنگ‌ها',
        emoji: '🖌️',
        route: '/game/نقاشی',
        image: 'assets/illustrations/drawing_stickers.webp',
        gameName: 'نقاشی',
        isFree: true,
      ),
      HubActivity(
        title: 'آزمایشگاه ترکیب رنگ‌ها',
        subtitle: 'کشف راز ساخت رنگ‌های جادویی از ترکیب رنگ‌های اصلی',
        emoji: '🎨',
        route: '/colors_lab',
        image: 'assets/illustrations/colors_cards.webp',
        gameName: 'رنگ‌ها',
        isFree: true,
      ),
      HubActivity(
        title: 'دنیای اشکال هندسی',
        subtitle: 'شناخت دایره، مربع، مثلث و اشکال بامزه محیط اطراف',
        emoji: '🔷',
        route: '/game/اشکال',
        image: 'assets/illustrations/shapes_cards.webp',
        gameName: 'اشکال',
        isFree: true,
      ),
      HubActivity(
        title: 'لالایی‌های آرامش‌بخش شب',
        subtitle: 'موسیقی‌های آرامش‌بخش و رویایی برای خواب راحت کودک',
        emoji: '🌙',
        route: '/lullabies',
        gameName: 'لالایی',
        isFree: true,
      ),
      HubActivity(
        title: 'آلبوم استیکرهای طلایی',
        subtitle: 'مجموعه استیکرهای برنده شده و دستاوردهای هنری',
        emoji: '🐠',
        route: '/stickers',
        gameName: 'استیکر',
        isFree: true,
      ),
    ],
  );
}

/// ═══════════════════════════════════════════════════════════════
/// 🚀 صفحهٔ جزیره‌ایِ هر هاب
///
/// قبلاً فعالیت‌های هر هاب یک لیستِ کارتِ سفید بود که با تمِ نقشهٔ
/// جزیره هیچ ربطی نداشت. حالا همان فعالیت‌ها روی سکوهای شناور
/// می‌نشینند: همان آسمان و دریا، همان حباب‌ها، همان پلاک‌های کِرِمی
/// و همان انیمیشن‌ها. یعنی کودک هرجای برنامه برود، در همان جزیره است.
/// ═══════════════════════════════════════════════════════════════
void showFandoqiHubSheet(BuildContext context, HubData hub) {
  HapticFeedback.mediumImpact();
  AudioService.select();
  FandoghiCoach.instruction(hub.coachGreeting);

  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => _FandoqiHubSheetWidget(hub: hub),
      transitionsBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

class _FandoqiHubSheetWidget extends StatefulWidget {
  final HubData hub;
  const _FandoqiHubSheetWidget({required this.hub});

  @override
  State<_FandoqiHubSheetWidget> createState() => _FandoqiHubSheetWidgetState();
}

class _FandoqiHubSheetWidgetState extends State<_FandoqiHubSheetWidget>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _bubbleCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _bubbleCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchActivity(BuildContext context, HubActivity act) async {
    HapticFeedback.heavyImpact();
    AudioService.select();

    if (ParentControls.isRouteBlocked(act.route) || ParentControls.isBedtimeNow) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ParentControls.blockReason(act.route))),
      );
      return;
    }

    if (!act.isFree && !await Monetization.hasFullVersion()) {
      SmartConversion.noteLockedTap();
      if (context.mounted) {
        await showFullVersionPaywall(context, featureName: act.gameName);
      }
      return;
    }

    if (context.mounted) {
      Navigator.pop(context);
      ActivityTracker.recordOpen(route: act.route, title: act.gameName);
      Navigator.pushNamed(
        context,
        act.route,
        arguments: GameLaunch(gameName: act.gameName),
      );
    }
  }

  void _close() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hub = widget.hub;
    final size = MediaQuery.of(context).size;
    final w = size.width;

    final islandW = (w * 0.46).clamp(150.0, 220.0);
    final islandH = islandW * HubIslandNode.blankAspect;

    // مسیر مارپیچ: سکوها یکی‌درمیان چپ و راست، مثل نقشهٔ اصلی
    const stepFactor = 0.86; // فاصلهٔ عمودی بر حسب ارتفاع سکو
    final step = islandH * stepFactor;
    final n = hub.activities.length;
    final pathHeight = step * (n - 1) + islandH + 24;

    final rects = <Rect>[];
    for (var i = 0; i < n; i++) {
      final left = i.isEven ? w * 0.045 : w - w * 0.045 - islandW;
      rects.add(Rect.fromLTWH(left, 12 + step * i, islandW, islandH));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: IslandMapBackground(
              scrollOffset: 0,
              cycle: AppTheme.currentCycle,
              progress: 0.55,
            ),
          ),
          Positioned.fill(
            child: FloatingBubbles(animation: _bubbleCtrl, count: 12),
          ),

          SafeArea(
            child: Column(
              children: [
                _header(hub),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: w,
                      height: pathHeight + 24,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // پل‌ها زیر سکوها کشیده می‌شوند
                          for (var i = 0; i < n - 1; i++)
                            _bridge(rects[i], rects[i + 1]),

                          for (var i = 0; i < n; i++)
                            Positioned(
                              left: rects[i].left,
                              top: rects[i].top,
                              width: islandW,
                              child: HubIslandNode(
                                label: hub.activities[i].shortTitle,
                                emoji: hub.activities[i].emoji,
                                image: hub.activities[i].image,
                                width: islandW,
                                floatPhase: (i * 0.23) % 1.0,
                                floatAnimation: _floatCtrl,
                                accent: hub.primaryColor,
                                locked: !hub.activities[i].isFree,
                                onTap: () =>
                                    _launchActivity(context, hub.activities[i]),
                              ),
                            ),
                        ],
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

  /// پلِ طنابی بین دو سکو — مثل نقشهٔ اصلی، از لنگرِ خودِ سکوها
  Widget _bridge(Rect a, Rect b) {
    final p1 = Offset(a.left + a.width * 0.55, a.top + a.height * 0.52);
    final p2 = Offset(b.left + b.width * 0.45, b.top + b.height * 0.40);
    final d = p2 - p1;
    final bw = d.distance * 1.04;
    final bh = bw * 281 / 720;

    return Positioned(
      left: (p1.dx + p2.dx) / 2 - bw / 2,
      top: (p1.dy + p2.dy) / 2 - bh / 2,
      width: bw,
      height: bh,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: d.direction,
          child: Image.asset(
            'assets/theme_map/bridge.png',
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }

  /// تابلوی بالای صفحه: مسکات هاب + نام + دکمهٔ بازگشت
  Widget _header(HubData hub) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: [
          _roundButton(
            icon: Icons.arrow_back_rounded,
            onTap: _close,
            color: hub.primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: hub.primaryColor, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: hub.primaryColor.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      hub.mascotImage,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hub.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.kids(
                        fontSize: 19,
                        color: const Color(0xFF2E4756),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF7),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
