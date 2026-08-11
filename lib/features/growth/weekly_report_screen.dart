import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/growth/growth.dart';
import '../../shared/widgets/premium_button.dart';
import 'widgets/screen_time_chart.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final digest = WeeklyEngine.buildParentDigest();
    final challenge = WeeklyEngine.currentChallenge();
    return Scaffold(
      appBar: AppBar(title: const Text('گزارش هفتگی والدین')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ScreenTimeChart(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${challenge.emoji} چالش هفته: ${challenge.title}',
                    style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: WeeklyEngine.challengeRatio,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 6),
                Text(
                  '${PersianDigits.toFa(GrowthStore.weeklyChallengeProgress)} از ${PersianDigits.toFa(challenge.target)} ${challenge.unit}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(digest, style: const TextStyle(height: 1.7, fontSize: 14)),
          const SizedBox(height: 20),
          PremiumButton(
            text: 'کپی گزارش برای خانواده',
            icon: Icons.copy_rounded,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: digest));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('گزارش کپی شد — می‌توانید در پیام‌رسان بفرستید')),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          Text(
            'این متن جایی به‌صورت خودکار ارسال نمی‌شود.',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
