import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../widgets/parent_widgets.dart';

/// تب محتوا و دسترس‌پذیری: فیلتر بخش‌ها، سن خودکار، چپ‌دست،
/// کوررنگی، کاهش حرکت، حالت تمرکز و صرفه‌جویی داده.
class ParentContentTab extends StatefulWidget {
  const ParentContentTab({super.key});

  @override
  State<ParentContentTab> createState() => _ParentContentTabState();
}

class _ParentContentTabState extends State<ParentContentTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // فیلتر محتوا
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '🎛️',
                title: 'فیلتر بخش‌ها',
                subtitle:
                    'می‌توانید هر بخش را از دید کودک پنهان کنید. یادگیری پایه همیشه باز می‌ماند.',
              ),
              const SizedBox(height: 6),
              ParentSwitchTile(
                title: 'کارتون‌کده',
                subtitle: 'بخش تماشای کارتون (نیازمند اینترنت)',
                value: GrowthStore.cartoonsAllowed,
                icon: Icons.live_tv_rounded,
                onChanged: (v) =>
                    setState(() => GrowthStore.setContentFilter(cartoons: v)),
              ),
              ParentSwitchTile(
                title: 'قصه‌خانه',
                subtitle: 'داستان‌های مصور تعاملی',
                value: GrowthStore.storiesAllowed,
                icon: Icons.menu_book_rounded,
                onChanged: (v) =>
                    setState(() => GrowthStore.setContentFilter(stories: v)),
              ),
              ParentSwitchTile(
                title: 'فروشگاه و سکه',
                subtitle: 'بخش خرید درون‌برنامه‌ای و فروشگاه',
                value: GrowthStore.shopAllowed,
                icon: Icons.storefront_rounded,
                onChanged: (v) =>
                    setState(() => GrowthStore.setContentFilter(shop: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // حالت‌های یادگیری
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '🧠',
                title: 'حالت‌های یادگیری',
              ),
              ParentSwitchTile(
                title: 'حالت تمرکز',
                subtitle: 'فقط یادگیری؛ فروشگاه و چیپ‌های پر زرق‌وبرق خاموش می‌شوند',
                value: GrowthStore.focusMode,
                icon: Icons.center_focus_strong_rounded,
                onChanged: (v) =>
                    setState(() => GrowthStore.setFocusMode(v)),
              ),
              ParentSwitchTile(
                title: 'حالت تمرین سخت‌کوشی',
                subtitle:
                    'پس از چند اشتباه، سختی کم می‌شود تا کودک ناامید نشود (خودکار)',
                value: true,
                icon: Icons.favorite_rounded,
                enabled: false,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // سن و سختی
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '🎂',
                title: 'سن تقریبی کودک',
                subtitle: 'سن، تعداد گزینه‌ها و سختی بازی‌ها را تنظیم می‌کند.',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      min: 3,
                      max: 8,
                      divisions: 5,
                      value: GameData.childAge.toDouble().clamp(3.0, 8.0),
                      label:
                          '${PersianDigits.toFa(GameData.childAge)} ساله',
                      onChanged: (v) => setState(() {
                        GameData.childAge = v.round();
                        GameData.save();
                      }),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${PersianDigits.toFa(GameData.childAge)} ساله',
                      style: AppFonts.vazirmatn(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                _ageHint(GameData.childAge),
                style: AppFonts.vazirmatn(
                    fontSize: 12, color: Colors.grey, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // دسترس‌پذیری
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '♿',
                title: 'دسترس‌پذیری',
                subtitle: 'تنظیم‌هایی برای راحتی همه‌ی کودکان.',
              ),
              ParentSwitchTile(
                title: 'کودک چپ‌دست است',
                subtitle: 'دکمه‌های مهم به سمت دست چپ می‌روند',
                value: GameData.isLeftHanded,
                icon: Icons.back_hand_rounded,
                onChanged: (v) => setState(() => GameData.setLeftHanded(v)),
              ),
              ParentSwitchTile(
                title: 'کاهش حرکت',
                subtitle: 'انیمیشن‌ها کمتر می‌شوند (مناسب حساسیت حرکتی)',
                value: GrowthStore.reduceMotion,
                icon: Icons.motion_photos_off_rounded,
                onChanged: (v) =>
                    setState(() => GrowthStore.setReduceMotion(v)),
              ),
              ParentSwitchTile(
                title: 'حالت کوررنگی',
                subtitle: 'پالت رنگی سازگار با کودکان کوررنگ',
                value: GrowthStore.colorBlindMode,
                icon: Icons.palette_rounded,
                onChanged: (v) =>
                    setState(() => GrowthStore.setColorBlindMode(v)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.text_fields, size: 20),
                  Expanded(
                    child: Slider(
                      min: 0.85,
                      max: 1.4,
                      divisions: 11,
                      value: GameData.textScale,
                      label:
                          '${(GameData.textScale * 100).round()}٪',
                      onChanged: (value) =>
                          setState(() => GameData.setTextScale(value)),
                    ),
                  ),
                  const Icon(Icons.text_fields, size: 28),
                ],
              ),
              Center(
                child: Text(
                  'اندازه متن: ${PersianDigits.toFa((GameData.textScale * 100).round())}٪',
                  style: AppFonts.vazirmatn(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // داده و شبکه
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '📶',
                title: 'اینترنت و داده',
                subtitle:
                    'بیشتر اپ کاملاً آفلاین است؛ فقط کارتون به اینترنت نیاز دارد.',
              ),
              ParentSwitchTile(
                title: 'صرفه‌جویی داده',
                subtitle: 'کاهش کیفیت کارتون آنلاین برای اینترنت همراه',
                value: GrowthStore.dataSaver,
                icon: Icons.data_saver_on_rounded,
                onChanged: (v) =>
                    setState(() => GrowthStore.setDataSaver(v)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _ageHint(int age) {
    if (age <= 4) return 'برای این سن: ۲ گزینه، صدای آرام و تشویق زیاد. 🧸';
    if (age <= 6) return 'برای این سن: ۳ گزینه، چالش‌های کوتاه و رنگ شاد. 🎒';
    return 'برای این سن: ۴ گزینه، مفاهیم پیش از دبستان و ریاضی پایه. 📚';
  }
}
