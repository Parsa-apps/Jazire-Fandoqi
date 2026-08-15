import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import '../../core/app_legal.dart';
import '../../core/billing_service.dart';
import '../../core/store_rating_service.dart';
import '../../shared/widgets/parsa_gold_aura.dart';
import '../../shared/widgets/parsa_website_card.dart';
import '../../shared/widgets/theme_selector_widget.dart';
import '../../shared/widgets/fandoghi_v2.dart';

/// Publisher, support and privacy information for parents and store review.
/// It intentionally does not invent a registration number or address.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _copy(BuildContext context, String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label کپی شد.')),
    );
  }

  Future<void> _openWebsite(BuildContext context) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(AppLegal.websiteUrl),
        mode: LaunchMode.externalApplication,
      );
    } on PlatformException {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('امکان باز کردن سایت وجود ندارد.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'درباره و پشتیبانی',
          style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _buildPublisherCard(),
          const SizedBox(height: 22),
          ParsaWebsiteCard(
            title: AppLegal.websiteName,
            onTap: () => _openWebsite(context),
          )
              .animate()
              .fadeIn(duration: 650.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.14, end: 0, duration: 700.ms)
              .scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1, 1),
                duration: 700.ms,
              ),
          const SizedBox(height: 22),
          const ThemeSelectorWidget(),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.email_outlined,
            title: 'ایمیل پشتیبانی',
            child: _contactRow(
              context,
              label: 'ایمیل',
              value: AppLegal.supportEmail,
              icon: Icons.copy_rounded,
              onTap: () => _copy(
                context,
                AppLegal.supportEmail,
                'ایمیل پشتیبانی',
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildSection(
            icon: Icons.send_rounded,
            title: 'پشتیبانی تلگرام',
            child: _contactRow(
              context,
              label: 'آیدی تلگرام',
              value: AppLegal.telegramHandle,
              icon: Icons.open_in_new_rounded,
              onTap: () async {
                final opened = await launchUrl(Uri.parse(AppLegal.telegramUrl), mode: LaunchMode.externalApplication);
                if (!opened && context.mounted) await _copy(context, AppLegal.telegramHandle, 'آیدی تلگرام');
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'حریم خصوصی و ایمنی',
                        style: AppFonts.vazirmatn(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'جزیره فندقی بدون حساب کاربری، تبلیغات، ردیابی و ارسال اطلاعات کودک به اینترنت طراحی شده است. لقب اختیاری، سن تقریبی و پیشرفت بازی فقط روی دستگاه ذخیره می‌شوند.',
                    style: TextStyle(height: 1.7),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'متن کامل سیاست حریم خصوصی در فایل PRIVACY_POLICY_FA.md، همین برنامه و صفحه انتشار قرار می‌گیرد.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/privacy'),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('خواندن متن کامل در برنامه'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // فاز ۷۶: ریتینگ هوشمند (فقط برای والدین — داخل پنل اطلاعات)
          Card(
            child: ListTile(
              leading: const Icon(Icons.star_rounded, color: Colors.amber),
              title: Text(
                'امتیاز به جزیره فندقی',
                style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('اگر از اپ راضی هستید، نظر بدهید'),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => _showRatingDialog(context),
            ),
          ),
          const SizedBox(height: 12),
          // فاز ۹۴: بازخورد داخل اپ — نظر مامان/بابا
          Card(
            child: ListTile(
              leading: const Icon(Icons.feedback_outlined, color: AppColors.primary),
              title: Text(
                'نظر مامان/بابا',
                style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('پیشنهاد یا گزارش باگ بفرستید'),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => _showFeedbackDialog(context),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                  title: Text(
                    'تازه‌های نسخه ۶.۲',
                    style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text('مهارت زندگی، گزارش هفتگی، پروفایل خواهر/برادر و…'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => Navigator.pushNamed(context, '/whats-new'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                  title: Text(
                    'راهنمای والدین',
                    style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text('۸ نکته برای رشد بهتر کودک'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => Navigator.pushNamed(context, '/parent-booklet'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'جزیره فندقی • نسخه ۶.۲.۰ پریمیوم\nساخته‌شده با دقت برای کودکان ایران',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.7,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublisherCard() {
    return const ParsaGoldAuraCard();
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _contactRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(color: AppColors.textSecondary)),
        Expanded(
          child: SelectableText(
            value,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          tooltip: 'کپی',
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.primary),
        ),
      ],
    );
  }
}

/// فاز ۷۶: دیالوگ امتیاز (۵ ستاره، آفلاین — بدون درخواست فروشگاه).
void _showRatingDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('از جزیره فندقی چقدر راضی هستید؟ ⭐'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'انتخاب شما فقط روی همین دستگاه ذخیره می‌شود و به ما کمک می‌کند بهتر شویم.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('⭐', style: TextStyle(fontSize: 30)),
              Text('⭐', style: TextStyle(fontSize: 30)),
              Text('⭐', style: TextStyle(fontSize: 30)),
              Text('⭐', style: TextStyle(fontSize: 30)),
              Text('⭐', style: TextStyle(fontSize: 30)),
            ],
          ),
          SizedBox(height: 6),
          Text('می‌توانید در فروشگاه هم به ما امتیاز بدهید 💚',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('بعداً'),
        ),
        ElevatedButton(
          onPressed: () async {
            await StoreRatingService.markPrompted();
            await StoreRatingService.markRated();
            await BillingService.openStoreReview();
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: const Text('ثبت امتیاز ⭐'),
        ),
      ],
    ),
  );
}

/// فاز ۹۴: فرم بازخورد والدین (آفلاین — فقط نمایش اطلاعات تماس).
void _showFeedbackDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('نظر شما برای ما ارزشمند است 💌'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'پیشنهادها و گزارش باگ خود را به این راه‌ها بفرستید:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 14),
          Text('📧 ${AppLegal.supportEmail}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('✈️ ${AppLegal.telegramHandle}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          const Text(
            '(کپی کنید و برای ما بفرستید — هیچ دیتایی به‌صورت خودکار ارسال نمی‌شود)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('باشه'),
        ),
      ],
    ),
  );
}
