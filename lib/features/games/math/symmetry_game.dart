import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../app/design_tokens.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/particle_celebration.dart';

/// ────────────────────────────────────────────────────────────
/// 🦋 بازی تقارن شطرنجی پایه اول (Symmetry)
///
/// آموزش مفهوم خط تقارن: نیمه سمت راست رسم شده است و کودک با لمس
/// خانه‌های قرینه در سمت چپ، شکل متقارن (پروانه، قلب، درخت) را کامل می‌کند.
/// ────────────────────────────────────────────────────────────
class SymmetryGame extends StatefulWidget {
  const SymmetryGame({super.key});

  @override
  State<SymmetryGame> createState() => _SymmetryGameState();
}

class _SymmetryPattern {
  final String title;
  final String emoji;
  final int rows;
  final int cols; // کل ستون‌ها (مثلا ۶ ستون: ۳ تا چپ، ۳ تا راست)
  final Set<(int, int)> rightCells; // خانه‌های پرشده در سمت راست (row, col)

  const _SymmetryPattern({
    required this.title,
    required this.emoji,
    required this.rows,
    required this.cols,
    required this.rightCells,
  });
}

class _SymmetryGameState extends State<SymmetryGame> {
  static const List<_SymmetryPattern> _patterns = [
    // پروانه ۶×۶ (ستون‌های ۳, ۴, ۵ سمت راست‌اند؛ ستون‌های ۰, ۱, ۲ سمت چپ)
    _SymmetryPattern(
      title: 'پروانه زیبا',
      emoji: '🦋',
      rows: 6,
      cols: 6,
      rightCells: {
        (0, 4), (0, 5),
        (1, 3), (1, 4), (1, 5),
        (2, 3), (2, 4),
        (3, 3), (3, 4), (3, 5),
        (4, 3), (4, 4),
        (5, 4),
      },
    ),
    // قلب ۶×۶
    _SymmetryPattern(
      title: 'قلب درخشان',
      emoji: '❤️',
      rows: 6,
      cols: 6,
      rightCells: {
        (0, 4),
        (1, 3), (1, 4), (1, 5),
        (2, 3), (2, 4), (2, 5),
        (3, 3), (3, 4),
        (4, 3),
      },
    ),
    // درخت کاج ۶×۶
    _SymmetryPattern(
      title: 'درخت کاج',
      emoji: '🌲',
      rows: 6,
      cols: 6,
      rightCells: {
        (0, 3),
        (1, 3), (1, 4),
        (2, 3), (2, 4), (2, 5),
        (3, 3), (3, 4),
        (4, 3), (4, 4), (4, 5),
        (5, 3),
      },
    ),
  ];

  int _round = 0;
  final Set<(int, int)> _userLeftCells = {};
  int _score = 0;
  bool _won = false;

  _SymmetryPattern get _pattern => _patterns[_round];

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _announceRound();
    });
  }

  void _announceRound() {
    FandoghiCoach.say(
      'نیمه سمت چپ «${_pattern.title}» را قرینه سمت راست کامل کن! 🦋',
      mood: FandoghiMood.excited,
      duration: const Duration(seconds: 4),
    );
    unawaited(AudioService.speak('شکل ${_pattern.title} را متقارن کامل کن'));
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _toggleCell(int r, int c) {
    if (_won) return;
    final mid = _pattern.cols ~/ 2;
    if (c >= mid) return; // فقط سمت چپ قابل ویرایش توسط کاربر است

    if (!canStartPlay(context)) return;
    HapticFeedback.selectionClick();

    setState(() {
      if (_userLeftCells.contains((r, c))) {
        _userLeftCells.remove((r, c));
        AudioService.back();
      } else {
        _userLeftCells.add((r, c));
        AudioService.tap();
      }
    });

    _checkSymmetry();
  }

  void _checkSymmetry() {
    final mid = _pattern.cols ~/ 2;
    // محاسبه خانه‌های قرینه مورد انتظار در سمت چپ:
    // اگر (r, rightCol) در rightCells باشد، قرینه‌اش (r, mid - 1 - (rightCol - mid)) است
    final expectedLeft = <(int, int)>{};
    for (final cell in _pattern.rightCells) {
      final r = cell.$1;
      final rightCol = cell.$2;
      final distFromMid = rightCol - mid;
      final leftCol = mid - 1 - distFromMid;
      expectedLeft.add((r, leftCol));
    }

    if (_userLeftCells.length == expectedLeft.length &&
        _userLeftCells.containsAll(expectedLeft)) {
      setState(() => _won = true);
      _score += 20;
      GameData.recordAnswer(correct: true, skill: 'shapes');
      GameData.addCoins(15);
      GameData.addStars(2);
      AudioService.win();
      FandoghiCoach.celebrate('فوق‌العاده بود! تقارن ${_pattern.title} ۱۰۰٪ کامل شد 🌟');

      Future.delayed(const Duration(milliseconds: 2200), () {
        if (!mounted) return;
        if (_round + 1 < _patterns.length) {
          setState(() {
            _round++;
            _userLeftCells.clear();
            _won = false;
          });
          _announceRound();
        } else {
          FandoghiCoach.reward('آفرین به مهندس کوچولو! همه تقارن‌ها را کامل کردی 🏆');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E44AD), Color(0xFF9B59B6), Color(0xFF2C3E50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 6),
                  _buildPatternCard(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildSymmetryGrid(),
                            const SizedBox(height: 16),
                            _buildHelpText(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_won)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleCelebration(trigger: true, particleCount: 50),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Row(
        children: [
          ChildTouchTarget(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: Colors.white30),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'بازی تقارن اول دبستان 🦋',
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.black87),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: AppFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          Text(_pattern.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شکل: ${_pattern.title}',
                  style: AppFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF8E44AD),
                  ),
                ),
                Text(
                  'خانه‌های سمت چپ را قرینه سمت راست کن',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymmetryGrid() {
    final mid = _pattern.cols ~/ 2;
    final size = MediaQuery.of(context).size.width * 0.85;
    final cellSize = (size / _pattern.cols).clamp(40.0, 56.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: AppShadows.medium,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_pattern.rows, (r) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_pattern.cols, (c) {
                  final isLeft = c < mid;
                  final isRight = c >= mid;
                  final isFilledRight = isRight && _pattern.rightCells.contains((r, c));
                  final isFilledLeft = isLeft && _userLeftCells.contains((r, c));

                  return GestureDetector(
                    onTap: isLeft ? () => _toggleCell(r, c) : null,
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isFilledRight
                            ? const Color(0xFFE67E22)
                            : (isFilledLeft ? const Color(0xFF9B59B6) : (isLeft ? Colors.purple.shade50 : Colors.orange.shade50)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLeft ? Colors.purple.shade200 : Colors.orange.shade200,
                        ),
                      ),
                      child: isFilledLeft || isFilledRight
                          ? const Center(
                              child: Text('✨', style: TextStyle(fontSize: 14)),
                            )
                          : null,
                    ),
                  );
                }),
              );
            }),
          ),
          // خط قرمز وسط (خط تقارن)
          Positioned(
            top: 0,
            bottom: 0,
            left: (cellSize + 4) * mid + 8,
            child: Container(
              width: 3,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'خط قرمز وسط، «خط تقارن» است 🔴 فاصله‌ات از خط قرمز را اندازه بگیر!',
        textAlign: TextAlign.center,
        style: AppFonts.vazirmatn(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
