import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../core/growth/growth.dart';

Future<void> showSessionRecap(BuildContext context) async {
  final text = ActivityTracker.recapText();
  if (GrowthStore.sessionCorrect + GrowthStore.sessionWrong == 0) return;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌟', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text('جمع‌بندی این دور', style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(height: 1.6)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ActivityTracker.endSession();
              Navigator.pop(ctx);
            },
            child: const Text('آفرین، ادامه بده'),
          ),
        ],
      ),
    ),
  );
  ActivityTracker.endSession();
}
