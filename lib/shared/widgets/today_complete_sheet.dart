import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/learning/today_path.dart';

/// پایان روز مثل Khan Kids: چهار کار واقعی + یک سؤال احساس، بدون نمرهٔ دروغ.
Future<void> showTodayCompleteSheet(BuildContext context) async {
  final done = TodayPath.recapLines();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFF8E7),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => _TodayCompleteBody(done: done),
  );
}

class _TodayCompleteBody extends StatefulWidget {
  final List<String> done;
  const _TodayCompleteBody({required this.done});

  @override
  State<_TodayCompleteBody> createState() => _TodayCompleteBodyState();
}

class _TodayCompleteBodyState extends State<_TodayCompleteBody> {
  String? _feeling;

  void _pick(String feeling, String skillNote) {
    HapticFeedback.lightImpact();
    AudioService.tap();
    setState(() => _feeling = feeling);
    GameData.recordAnswer(correct: true, skill: 'emotions');
    FandoghiCoach.celebrate(skillNote);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌟', style: TextStyle(fontSize: 42)),
          const SizedBox(height: 8),
          Text(
            'امروز کارت تمام شد',
            style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            widget.done.isEmpty
                ? 'فردا چهار کار تازه می‌آید.'
                : '${PersianDigits.toFa(widget.done.length)} کار واقعی: ${widget.done.join('، ')}.',
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.6, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            'الان چه حسی داری؟',
            style: AppFonts.vazirmatn(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _face('😊', 'خوشحال', 'خوشحالی‌ات قشنگ است. استراحت هم لازم است.'),
              _face('😌', 'آرام', 'آرام بودن یعنی بدنت هم یاد گرفته است.'),
              _face('😢', 'خسته', 'خستگی اشکال ندارد. فردا دوباره با هم می‌آییم.'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _feeling == null ? 'برگشت به جزیره' : 'آفرین، برو جزیره',
                style: AppFonts.vazirmatn(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _face(String emoji, String label, String note) {
    final selected = _feeling == label;
    return GestureDetector(
      onTap: () => _pick(label, note),
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE0B2) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFE65100) : const Color(0xFFFFCC80),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppFonts.vazirmatn(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
