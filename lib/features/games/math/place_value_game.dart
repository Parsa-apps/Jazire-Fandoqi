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
/// 🧮 بازی جدول ارزش مکانی (یکان و دهگان) پایه اول
///
/// آموزش مفهوم دهگان و یکان با ستون‌های رنگی و مهره‌های لمسی:
/// ۱ بسته ده‌تایی + ۵ یکی = ۱۵
/// ────────────────────────────────────────────────────────────
class PlaceValueGame extends StatefulWidget {
  const PlaceValueGame({super.key});

  @override
  State<PlaceValueGame> createState() => _PlaceValueGameState();
}

class _PlaceValueGameState extends State<PlaceValueGame> {
  int _tens = 0;
  int _ones = 0;
  int _target = 14;
  int _round = 1;
  int _score = 0;
  bool _won = false;
  final List<int> _levels = [14, 23, 17, 30, 8, 25, 19, 32];

  int get _currentValue => (_tens * 10) + _ones;

  @override
  void initState() {
    super.initState();
    _target = _levels[0];
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'با مهره‌ها عدد $_target را در جدول ارزش مکانی بساز! ده‌تایی و یکی بنداز 🧮',
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 4),
      );
      unawaited(AudioService.speak('عدد $_target را بساز. ده‌تایی و یکی'));
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _addTen() {
    if (_won || _tens >= 9) return;
    if (!canStartPlay(context)) return;
    HapticFeedback.lightImpact();
    AudioService.coin();
    setState(() => _tens++);
    _checkAnswer();
  }

  void _removeTen() {
    if (_won || _tens <= 0) return;
    HapticFeedback.selectionClick();
    AudioService.back();
    setState(() => _tens--);
  }

  void _addOnes() {
    if (_won || _ones >= 9) return;
    if (!canStartPlay(context)) return;
    HapticFeedback.lightImpact();
    AudioService.tap();
    setState(() => _ones++);
    _checkAnswer();
  }

  void _removeOnes() {
    if (_won || _ones <= 0) return;
    HapticFeedback.selectionClick();
    AudioService.back();
    setState(() => _ones--);
  }

  void _checkAnswer() {
    if (_currentValue == _target) {
      setState(() => _won = true);
      _score += 15;
      GameData.recordAnswer(correct: true, skill: 'counting');
      GameData.addCoins(12);
      GameData.addStars(1);
      AudioService.win();
      FandoghiCoach.celebrate(
        'آفرین! $_tens ده‌تایی و $_ones یکی دقیقاً شد عدد $_target 🎉',
      );

      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        if (_round < _levels.length) {
          setState(() {
            _round++;
            _target = _levels[_round - 1];
            _tens = 0;
            _ones = 0;
            _won = false;
          });
          FandoghiCoach.say(
            'مرحله $_round: حالا عدد $_target را بساز 🧮',
            mood: FandoghiMood.happy,
          );
          unawaited(AudioService.speak('مرحله $_round: عدد $_target را بساز'));
        } else {
          FandoghiCoach.reward('شاهکار کردی! جدول ارزش مکانی را کامل یاد گرفتی 🏆');
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
            colors: [Color(0xFF6C5CE7), Color(0xFF8E44AD), Color(0xFF2C3E50)],
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
                  _buildTargetCard(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildPlaceValueTable(),
                            const SizedBox(height: 16),
                            _buildSumFormula(),
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
              'جدول ارزش مکانی 🧮',
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

  Widget _buildTargetCard() {
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
          const FandoghiPremium(size: 46, mood: FandoghiMood.happy, showParticles: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عدد هدف: $_target',
                  style: AppFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6C5CE7),
                  ),
                ),
                Text(
                  'عدد ساخته‌شده: $_currentValue',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _currentValue == _target ? Colors.green : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'خواندن صوتی',
            onPressed: () {
              HapticFeedback.lightImpact();
              AudioService.speak('عدد هدف: $_target. تو عدد $_currentValue را ساختی');
            },
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF6C5CE7)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceValueTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.medium,
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
        children: [
          // ستون ده‌تایی‌ها (قرمز / نارنجی)
          Expanded(
            child: _buildColumn(
              title: 'ده‌تایی‌ها (۱۰)',
              count: _tens,
              color: const Color(0xFFE74C3C),
              beadIcon: '🔴',
              onAdd: _addTen,
              onRemove: _removeTen,
            ),
          ),
          Container(width: 2, height: 260, color: Colors.grey.shade300),
          // ستون یکی‌ها (آبی / بنفش)
          Expanded(
            child: _buildColumn(
              title: 'یکی‌ها (۱)',
              count: _ones,
              color: const Color(0xFF3498DB),
              beadIcon: '🔵',
              onAdd: _addOnes,
              onRemove: _removeOnes,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn({
    required String title,
    required int count,
    required Color color,
    required String beadIcon,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              title,
              style: AppFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // محفظه مهره‌ها
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < count; i++)
                  Text(beadIcon, style: const TextStyle(fontSize: 22))
                      .animate()
                      .scale(duration: 250.ms, curve: Curves.easeOutBack),
                if (count == 0)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 45),
                      child: Text('خالی', style: TextStyle(color: Colors.black26, fontSize: 11)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: AppFonts.vazirmatn(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: count > 0 ? onRemove : null,
                icon: const Icon(Icons.remove_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: color.withOpacity(0.85),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: count < 9 ? onAdd : null,
                icon: const Icon(Icons.add_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSumFormula() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '$_tens بسته ۱۰ تایی (${_tens * 10}) + $_ones تا یکی ($_ones) = $_currentValue',
        textAlign: TextAlign.center,
        style: AppFonts.vazirmatn(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
