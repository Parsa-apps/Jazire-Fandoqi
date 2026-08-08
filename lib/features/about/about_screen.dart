import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_colors.dart';
import '../../core/app_legal.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'درباره و پشتیبانی',
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _buildPublisherCard(),
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
              icon: Icons.copy_rounded,
              onTap: () => _copy(
                context,
                AppLegal.telegramHandle,
                'آیدی تلگرام',
              ),
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
                        style: GoogleFonts.vazirmatn(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'آموزش فندقی بدون حساب کاربری، تبلیغات، ردیابی و ارسال اطلاعات کودک به اینترنت طراحی شده است. لقب اختیاری، سن تقریبی و پیشرفت بازی فقط روی دستگاه ذخیره می‌شوند.',
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
          const Center(
            child: Text(
              'آموزش فندقی • نسخه ۴.۱.۲\nساخته‌شده با دقت برای کودکان ایران',
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
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const FandoghiV2(
            size: 72,
            animate: true,
            mood: FandoghiMood.happy,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'سازنده و ناشر',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLegal.developerName,
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'توسعه‌دهنده آموزش فندقی',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                  style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800),
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
