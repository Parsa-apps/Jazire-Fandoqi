import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import 'game_data.dart';

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

bool canStartPlay(BuildContext context) {
  if (!GameData.isDailyLimitReached) return true;
  showPlayLimitDialog(context);
  return false;
}
