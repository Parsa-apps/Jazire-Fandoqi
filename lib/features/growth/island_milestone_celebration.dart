import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../core/game_data.dart';
import '../../core/growth/certificate_builder.dart';
import '../../core/xp_system.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎉 جشن گواهی افتخار نقاط عطف سطح جزیره — نسخهٔ ۷.۱
///
/// وقتی کودک به یکی از لقب‌های بزرگ (سطح ۳/۵/۷/۹) می‌رسد، فقط صدا و
/// پیام فندقی کافی نیست: گواهی افتخارِ همان نقطهٔ عطف با نام کودک
/// نمایش داده می‌شود و والد می‌تواند متن گواهی را برای استوری کپی کند.
///
/// این کلاس از کلید ناوبری سراسری (main) صدا زده می‌شود؛ جشن حین هر
/// بازی و در هر صفحه‌ای که ارتقا رخ دهد بالا می‌آید.
/// ═══════════════════════════════════════════════════════════════
class IslandMilestoneCelebration {
  IslandMilestoneCelebration._();

  /// همین نقاط عطف جشن گواهی می‌گیرند.
  static bool isMilestone(int level) =>
      CertificateBuilder.isIslandMilestone(level);

  /// نمایش جشن گواهی برای سطح داده‌شده؛ اگر نقطهٔ عطف نباشد، بی‌صدا
  /// هیچ کاری نمی‌کند.
  static Future<void> show(BuildContext context, {required int level}) async {
    final certificate = CertificateBuilder.islandCertificateFor(level);
    if (certificate == null) return;
    HapticFeedback.mediumImpact();
    var copied = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFFDF7),
        title: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'گواهی افتخار جدید!',
                style: AppFonts.kids(
                  color: const Color(0xFF3B2B52),
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: _certificateCard(certificate, level),
        actions: <Widget>[
          StatefulBuilder(
            builder: (context, setDialogState) => TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: certificate.shareText(GameData.childName),
                  ),
                );
                setDialogState(() => copied = true);
              },
              icon: Icon(
                copied ? Icons.check_circle_rounded : Icons.copy_rounded,
                size: 18,
                color: const Color(0xFF43A047),
              ),
              label: Text(
                copied ? 'کپی شد ✓' : 'کپی متن گواهی',
                style: AppFonts.kids(
                  color: const Color(0xFF43A047),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'ادامهٔ بازی ⭐',
              style: AppFonts.kids(
                color: const Color(0xFFFFFDF7),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _certificateCard(ChildCertificate certificate, int level) {
    final name =
        GameData.childName.isEmpty ? 'قهرمان کوچولو' : GameData.childName;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(certificate.emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 6),
          Text(
            name,
            style: AppFonts.kids(
              color: const Color(0xFF3B2B52),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'به ${XpSystem.levelLabel(level)} رسید',
            style: const TextStyle(
              color: Color(0xFF6D4C41),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.25),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'گواهی «${certificate.title}»',
              style: AppFonts.kids(
                color: const Color(0xFF3B2B52),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
