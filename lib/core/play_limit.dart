import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import 'game_data.dart';
import 'growth/parent_controls.dart';

/// Shows the same child-friendly limit message from every game entry point.
/// The parent panel is deliberately not opened directly from this dialog; a
/// parent gate is required before changing the limit.
Future<void> showPlayLimitDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('زمان بازی امروز تمام شد ⏰'),
      content: const Text(
        'امروز به اندازه کافی بازی کردی. فردا دوباره ماجراجویی ادامه دارد!\n\n'
        'اگر لازم است، یک بزرگ‌تر می‌تواند از پنل والدین تنظیمات را بررسی کند.',
        textAlign: TextAlign.center,
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('باشه'),
        ),
      ],
    ),
  );
}

/// ساعت خواب (تنظیم والد): فقط لالایی مجاز است؛ بقیه بازی‌ها متوقف می‌شوند.
Future<void> showBedtimeDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('وقت لالایی است 🌙'),
      content: const Text(
        'الان ساعت خواب است. فندقی فقط قصه و لالایی آرام پخش می‌کند.\n\n'
        'مامان/بابا می‌توانند از پنل والدین ساعت را تغییر دهند.',
        textAlign: TextAlign.center,
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('باشه'),
        ),
      ],
    ),
  );
}

bool canStartPlay(BuildContext context) {
  if (ParentControls.isBedtimeNow) {
    showBedtimeDialog(context);
    return false;
  }
  if (!GameData.isDailyLimitReached) return true;
  showPlayLimitDialog(context);
  return false;
}
