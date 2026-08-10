import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/design_tokens.dart';
import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/premium_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ────────────────────────────────────────────────────────────
/// 🧪 فاز ۲۳: آزمایشگاه رنگ فندقی — ترکیب رنگ‌ها
///
/// دو رنگ در لوله‌ها دیده می‌شود و کودک باید نتیجه ترکیب را
/// از بین گزینه‌ها انتخاب کند (آبی+زرد=سبز و...). هر پاسخ
/// با بازخورد فندقی و رندر رنگ واقعی همراه است.
/// ────────────────────────────────────────────────────────────
class ColorsLabGame extends StatefulWidget {
  const ColorsLabGame({super.key});

  @override
  State<ColorsLabGame> createState() => _ColorsLabGameState();
}

class _ColorsLabGameState extends State<ColorsLabGame> {
  static const List<(String, String)> _mixes = <(String, String)>[
    ('آبی', 'زرد'),
    ('قرمز', 'زرد'),
    ('قرمز', 'آبی'),
    ('آبی', 'سفید'),
    ('زرد', 'سفید'),
    ('قرمز', 'سفید'),
  ];

  static const Map<String, String> _resultOf = <String, String>{
    'آبی+زرد': 'سبز',
    'قرمز+زرد': 'نارنجی',
    'قرمز+آبی': 'بنفش',
    'آبی+سفید': 'آبی روشن',
    'زرد+سفید': 'کرم',
    'قرمز+سفید': 'صورتی',
  };

  int _round = 0;
  int _score = 0;
  int _correct = 0;
  bool _locked = false;
  bool _finished = false;
  int? _selected;

  /// گزینه‌های دور جاری — یک‌بار ساخته و کش می‌شوند تا مقایسه پاسخ
  /// همیشه با همان لیستی که کودک دیده انجام شود (رفع باگ شافل مجدد).
  late List<String> _roundOptions;

  List<String> _buildOptions() {
    final correct = _resultOf['${_mixes[_round].$1}+${_mixes[_round].$2}']!;
    final others = _resultOf.values.where((v) => v != correct).toList()
      ..shuffle();
    return <String>[correct, others[0], others[1]]..shuffle();
  }

  @override
  void initState() {
    super.initState();
    _roundOptions = _buildOptions();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.instruction(
        'به آزمایشگاه رنگ فندقی خوش آمدی! دو رنگ را قاطی می‌کنیم؛ حدس بزن چه رنگی می‌شود! 🧪',
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  Color _colorOf(String name) => switch (name) {
        'قرمز' => const Color(0xFFE74C3C),
        'زرد' => const Color(0xFFF1C40F),
        'آبی' => const Color(0xFF2980B9),
        'سبز' => const Color(0xFF27AE60),
        'نارنجی' => const Color(0xFFE67E22),
        'بنفش' => const Color(0xFF8E44AD),
        'صورتی' => const Color(0xFFFD79A8),
        'کرم' => const Color(0xFFFDEBD0),
        'آبی روشن' => const Color(0xFF85C1E9),
        _ => const Color(0xFF95A5A6),
      };

  void _answer(int index) {
    if (_locked || _finished) return;
    if (!canStartPlay(context)) return;
    final mix = '${_mixes[_round].$1}+${_mixes[_round].$2}';
    final correct = _roundOptions[index] == _resultOf[mix];
    AudioService.tap();
    setState(() {
      _locked = true;
      _selected = index;
      if (correct) {
        _correct++;
        _score += 10;
      }
    });
    GameData.recordAnswer(correct: correct, skill: 'colors');
    GameData.progressMission('colors');
    if (correct) {
      HapticFeedback.lightImpact();
      FandoghiCoach.correct('آفرین! ${_resultOf[mix]} شد! 🎨');
      unawaited(AudioService.playCorrect());
    } else {
      FandoghiCoach.incorrect(_resultOf[mix]!);
      unawaited(AudioService.playWrong());
    }

    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_round + 1 >= _mixes.length) {
        setState(() => _finished = true);
        GameData.addCoins(_score);
        GameData.addStars(_correct);
        if (_correct >= 4) {
          unawaited(AudioService.win());
        } else {
          unawaited(AudioService.lose());
        }
        FandoghiCoach.reward('آزمایشگاه رنگ را عالی تمام کردی! دانشمند کوچولو! 🧪');
      } else {
        setState(() {
          _round++;
          _roundOptions = _buildOptions();
          _selected = null;
          _locked = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(
          child: _finished ? _buildResult() : _buildGame(),
        ),
      ),
    );
  }

  Widget _buildGame() {
    final a = _mixes[_round].$1;
    final b = _mixes[_round].$2;
    final options = _roundOptions;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              ChildTouchTarget(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white30)),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('آزمایشگاه رنگ 🧪 — دور ${_round + 1}/${_mixes.length}', textAlign: TextAlign.center, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.soft),
                child: Text('$_correct/6', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF6C5CE7))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const FandoghiPremium(size: 48, mood: FandoghiMood.happy, showParticles: false),
        const SizedBox(height: 24),
        // دو لوله رنگ
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _tube(_colorOf(a), a),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '+',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _tube(_colorOf(b), b),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'چه رنگی می‌شود؟',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 26),
        for (var i = 0; i < options.length; i++) ...[
          _optionButton(i, options[i]),
          const SizedBox(height: 12),
        ],
        const Spacer(),
        Text(
          'دور ${_round + 1} از ${_mixes.length}',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _tube(Color color, String name) {
    return Column(
      children: [
        Container(
          width: 74,
          height: 110,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(34),
              bottom: Radius.circular(14),
            ),
            border: Border.all(color: Colors.white38, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.45),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _optionButton(int index, String name) {
    final selected = _locked && _selected == index;
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _locked ? null : () => _answer(index),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            decoration: BoxDecoration(
              color: selected
                  ? (_correctFor(index) ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C))
                  : Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(selected ? 1 : 0.25),
                width: selected ? 2.5 : 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _colorOf(name),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 1.5),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _correctFor(int index) {
    final mix = '${_mixes[_round].$1}+${_mixes[_round].$2}';
    return _roundOptions[index] == _resultOf[mix];
  }

  Widget _buildResult() {
    final stars = _correct == _mixes.length ? 3 : _correct >= 4 ? 2 : _correct >= 2 ? 1 : 0;
    final isWin = _correct >= 4;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FandoghiPremium(size: 96, mood: isWin ? FandoghiMood.celebrating : FandoghiMood.shy, showParticles: isWin).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text('دانشمند رنگ‌ها! 🧪✨', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, size: 32, color: i < stars ? const Color(0xFFFFD700) : Colors.white24).animate(delay: (i * 100).ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut))),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: Colors.white24)),
              child: Column(children: [Text('$_correct درست از ${_mixes.length} — قاطی کردن بلدی!', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)), Text('امتیاز: $_score', style: TextStyle(color: Colors.white70, fontSize: 13))]),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: PremiumButton(text: 'بازی دوباره 🔄', icon: Icons.replay_rounded, onPressed: () { HapticFeedback.mediumImpact(); setState(() { _round = 0; _roundOptions = _buildOptions(); _score = 0; _correct = 0; _locked = false; _finished = false; _selected = null; }); })),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.home_rounded, size: 18, color: Colors.white), label: Text('برگشت به خانه', style: AppFonts.vazirmatn(color: Colors.white)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Colors.white54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))))),
          ],
        ),
      ),
    );
  }
}
