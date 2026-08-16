import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/game_data.dart';
import '../../core/learning/today_path.dart';
import 'today_complete_sheet.dart';

/// دکمهٔ «کار بعدی امروز» — حلقهٔ هدایت‌شده بعد از تمام‌شدن یک فعالیت.
class NextTodayButton extends StatelessWidget {
  final String? justFinished;
  final bool outlined;

  const NextTodayButton({
    super.key,
    this.justFinished,
    this.outlined = false,
  });

  static const Map<String, String> _labels = <String, String>{
    'literacy': 'بعدی: الفبا',
    'math': 'بعدی: جمع تا ۲۰',
    'drawing': 'بعدی: نقاشی',
    'story': 'بعدی: قصهٔ کلاس اول',
  };

  static Future<void> go(BuildContext context, {String? justFinished}) async {
    if (justFinished != null) {
      GameData.markTodayStation(justFinished);
    }
    if (!context.mounted) return;
    final next = TodayPath.forChild();
    HapticFeedback.lightImpact();
    AudioService.select();
    if (next.allDone || next.route == '/home' || next.route == '/parent') {
      if (next.allDone && context.mounted) {
        await showTodayCompleteSheet(context);
      }
      if (!context.mounted) return;
      Navigator.of(context).popUntil(
        (route) => route.isFirst || route.settings.name == '/home',
      );
      return;
    }
    Navigator.of(context).pop();
    if (context.mounted) {
      Navigator.of(context).pushNamed(next.route);
    }
  }

  String get _label {
    final next = TodayPath.nextStationAfter(justFinished);
    if (next == null) return 'برگشت به جزیره';
    return _labels[next] ?? 'کار بعدی امروز';
  }

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => go(context, justFinished: justFinished),
          child: Text(_label, style: AppFonts.vazirmatn(fontWeight: FontWeight.w800)),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => go(context, justFinished: justFinished),
        icon: const Icon(Icons.flag_rounded),
        label: Text(_label, style: AppFonts.vazirmatn(fontWeight: FontWeight.w900)),
      ),
    );
  }
}
