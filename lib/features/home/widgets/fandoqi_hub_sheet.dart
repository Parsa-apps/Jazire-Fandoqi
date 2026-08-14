import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_launch.dart';
import '../../../core/growth/growth.dart';
import '../../../core/monetization.dart';
import '../../shop/full_version_paywall.dart';

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
        isFree: true,
      ),
      HubActivity(
        title: 'بازی تشخیص صداها',
        subtitle: 'گوش بده و صدای درست حروف رو حدس بزن',
        emoji: '🎧',
        route: '/sound_match',
        gameName: 'صدا',
        isFree: true,
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
        isFree: true,
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
        isFree: true,
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
        isFree: true,
      ),
      HubActivity(
        title: 'مفاهیم علوم و دنیای اطراف',
        subtitle: 'فصل‌ها، آب‌وهوا، شب و روز و پدیده‌های طبیعی',
        emoji: '🌍',
        route: '/concepts',
        gameName: 'مفاهیم',
        isFree: true,
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
/// 🚀 Bottom Sheet نمایش فعالیت‌های هر هاب
/// ═══════════════════════════════════════════════════════════════
void showFandoqiHubSheet(BuildContext context, HubData hub) {
  HapticFeedback.mediumImpact();
  AudioService.select();
  FandoghiCoach.instruction(hub.coachGreeting);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _FandoqiHubSheetWidget(hub: hub),
  );
}

class _FandoqiHubSheetWidget extends StatelessWidget {
  final HubData hub;
  const _FandoqiHubSheetWidget({required this.hub});

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      constraints: BoxConstraints(
        maxHeight: size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // دستگیره بالای شیت
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),

          // هدر رنگی هاب با مسکات و گرادیان
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: hub.gradient,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: hub.shadowColor.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // عکس مسکات با افکت درخشان
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                  ),
                  child: Image.asset(
                    hub.mascotImage,
                    fit: BoxFit.contain,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hub.title,
                        style: AppFonts.vazirmatn(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hub.subtitle,
                        style: AppFonts.vazirmatn(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.92),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // لیست فعالیت‌های داخل هاب
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              itemCount: hub.activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final act = hub.activities[index];
                return _ActivityCard(
                  activity: act,
                  hubColor: hub.primaryColor,
                  index: index,
                  onTap: () => _launchActivity(context, act),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final HubActivity activity;
  final Color hubColor;
  final int index;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.activity,
    required this.hubColor,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final act = widget.activity;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.hubColor.withOpacity(0.25),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // تصویر یا ایموجی کارت
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: widget.hubColor.withOpacity(0.12),
                  border: Border.all(
                    color: widget.hubColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: act.image != null
                      ? Image.asset(act.image!, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            act.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            act.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.vazirmatn(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        if (!act.isFree) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 12),
                                SizedBox(width: 2),
                                Text(
                                  'ویژه',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      act.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.vazirmatn(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // دکمه شروع بازی / ورود
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.hubColor,
                      widget.hubColor.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.hubColor.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'شروع 🚀',
                  style: AppFonts.vazirmatn(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 100 + widget.index * 60),
      duration: 350.ms,
    ).slideX(begin: 0.1, curve: Curves.easeOutCubic);
  }
}
