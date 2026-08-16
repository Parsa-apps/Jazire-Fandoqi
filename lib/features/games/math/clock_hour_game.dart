import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/persian_digits.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/next_today_button.dart';
import '../../../shared/widgets/particle_celebration.dart';

/// ساعت کامل اول دبستان — فقط ساعت‌های رند (۳:۰۰، ۷:۰۰).
class ClockHourGame extends StatefulWidget {
  const ClockHourGame({super.key});

  @override
  State<ClockHourGame> createState() => _ClockHourGameState();
}

class _ClockHourGameState extends State<ClockHourGame> {
  static const int _rounds = 6;
  final Random _rng = Random();
  late int _hour;
  late List<int> _options;
  int _index = 0;
  int _correct = 0;
  bool _locked = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _deal();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'ساعت کامل است؛ عقربهٔ کوچک ساعت را نشان می‌دهد. عدد درست را بزن.',
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _deal() {
    _hour = 1 + _rng.nextInt(12);
    final pool = <int>{_hour};
    while (pool.length < 3) {
      pool.add(1 + _rng.nextInt(12));
    }
    _options = pool.toList()..shuffle(_rng);
  }

  void _pick(int value) {
    if (_locked || _finished) return;
    if (!canStartPlay(context)) return;
    final ok = value == _hour;
    setState(() {
      _locked = true;
      if (ok) _correct++;
    });
    GameData.recordAnswer(correct: ok, skill: 'time');
    if (ok) {
      AudioService.playCorrect();
      FandoghiCoach.correct('ساعت ${PersianDigits.toFa(_hour)} تمام!');
    } else {
      AudioService.playWrong();
      FandoghiCoach.instruction(
        'عقربهٔ کوتاه روی ${PersianDigits.toFa(_hour)} است.',
      );
    }
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_index + 1 >= _rounds) {
        setState(() => _finished = true);
        GameData.addCoins(_correct * 2);
        GameData.addStars(_correct ~/ 2);
        if (_correct >= 4) {
          unawaited(AudioService.win());
          FandoghiCoach.reward('ساعت را خوب خواندی 🏆');
        }
      } else {
        setState(() {
          _index++;
          _locked = false;
          _deal();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: _finished ? _result() : _game(),
      ),
    );
  }

  Widget _game() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          child: Row(
            children: [
              ChildTouchTarget(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded, size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ساعت کامل 🕐',
                  style: AppFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0D47A1),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'سؤال ${PersianDigits.toFa(_index + 1)} از ${PersianDigits.toFa(_rounds)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          'ساعت چند است؟',
          style: AppFonts.vazirmatn(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(painter: _ClockPainter(hour: _hour)),
        ),
        const SizedBox(height: 24),
        for (final option in _options)
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _locked ? null : () => _pick(option),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFF64B5F6), width: 2),
                  ),
                ),
                child: Text(
                  'ساعت ${PersianDigits.toFa(option)}',
                  style: AppFonts.vazirmatn(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _result() {
    final passed = _correct >= 4;
    return Stack(
      children: [
        if (passed)
          const Positioned.fill(
            child: IgnorePointer(
              child: ParticleCelebration(trigger: true, particleCount: 36),
            ),
          ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FandoghiPremium(
                size: 90,
                mood: passed ? FandoghiMood.celebrating : FandoghiMood.shy,
                showParticles: passed,
              ),
              const SizedBox(height: 10),
              Text(
                '${PersianDigits.toFa(_correct)} از ${PersianDigits.toFa(_rounds)} درست',
                style: AppFonts.vazirmatn(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: NextTodayButton(justFinished: 'math'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _index = 0;
                    _correct = 0;
                    _locked = false;
                    _finished = false;
                    _deal();
                  });
                },
                child: const Text('دور دوباره'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('برگشت'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClockPainter extends CustomPainter {
  final int hour;
  const _ClockPainter({required this.hour});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    final face = Paint()..color = Colors.white;
    final rim = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(c, r, face);
    canvas.drawCircle(c, r, rim);

    final tick = Paint()
      ..color = const Color(0xFF1565C0)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i <= 12; i++) {
      final a = (i - 3) * pi / 6;
      final outer = Offset(c.dx + cos(a) * (r - 10), c.dy + sin(a) * (r - 10));
      final inner = Offset(c.dx + cos(a) * (r - 22), c.dy + sin(a) * (r - 22));
      canvas.drawLine(inner, outer, tick);
      final tp = TextPainter(
        text: TextSpan(
          text: PersianDigits.toFa(i),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D47A1),
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          c.dx + cos(a) * (r - 38) - tp.width / 2,
          c.dy + sin(a) * (r - 38) - tp.height / 2,
        ),
      );
    }

    final hourAngle = (hour % 12 - 3) * pi / 6;
    final minuteAngle = -pi / 2; // دقیقه روی ۱۲ — ساعت کامل
    final hourHand = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final minuteHand = Paint()
      ..color = const Color(0xFF546E7A)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      c,
      Offset(c.dx + cos(hourAngle) * r * 0.45, c.dy + sin(hourAngle) * r * 0.45),
      hourHand,
    );
    canvas.drawLine(
      c,
      Offset(
        c.dx + cos(minuteAngle) * r * 0.7,
        c.dy + sin(minuteAngle) * r * 0.7,
      ),
      minuteHand,
    );
    canvas.drawCircle(c, 6, Paint()..color = const Color(0xFFE53935));
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.hour != hour;
}
