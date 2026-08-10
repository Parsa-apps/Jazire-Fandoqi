import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/magnetic_drag.dart';
import '../../../shared/widgets/premium_button.dart';

/// ────────────────────────────────────────────────────────────
/// 🧍 فاز ۳۹: بازی بدن و حواس
///
/// کودک اعضای بدن (چشم، گوش، دست، پا) را با کشیدن روی بدن
/// کارتونی می‌گذارد. حواس پنج‌گانه هم با کلیک روی هر عضو گفته
/// می‌شود (TTS). آهنربا + ویبره نرم برای هر عضو درست.
/// ────────────────────────────────────────────────────────────
class BodyPartsGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const BodyPartsGame({super.key, this.stageId, this.stageNumber});

  @override
  State<BodyPartsGame> createState() => _BodyPartsGameState();
}

class _BodyPartsGameState extends State<BodyPartsGame> {
  static const List<(String, String, String, String)> _parts = <(String, String, String, String)>[
    ('چشم', '👀', 'می‌بینم', 'بینایی'),
    ('گوش', '👂', 'می‌شنوم', 'شنوایی'),
    ('دست', '✋', 'لمس می‌کنم', 'لامسه'),
    ('پا', '🦶', 'راه می‌روم', 'حرکت'),
  ];

  final Set<int> _placed = <int>{};
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.instruction(
        'هر عضو بدن را با انگشت بکش و سر جایش بگذار! بعد رویش بزن تا حرفش را بشنوی 🧍',
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _onDrop(int index, String emoji) {
    if (_placed.contains(index)) return;
    if (_parts[index].$2 != emoji) return;
    setState(() => _placed.add(index));
    HapticFeedback.lightImpact();
    FandoghiCoach.correct('${_parts[index].$1} سر جایش نشست!');
    unawaited(AudioService.playCorrect());
    if (_placed.length == _parts.length) {
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => _finished = true);
        GameData.recordAnswer(correct: true, skill: 'body');
        GameData.addCoins(12);
        GameData.addStars(2);
        if (widget.stageId != null) {
          GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
        }
        unawaited(AudioService.win());
        FandoghiCoach.reward('بدنت را کامل ساختی! حالا حواس پنج‌گانه را می‌شناسی 👏');
      });
    }
  }

  void _saySense(int index) {
    AudioService.tap();
    unawaited(AudioService.speak('${_parts[index].$1}، ${_parts[index].$3}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.forest),
        child: SafeArea(
          child: _finished ? _buildResult() : _buildGame(),
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              ChildTouchTarget(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'بدن من 🧍',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // بدن (اسلات‌ها)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _slot(0, 'چشم'),
                  _slot(1, 'گوش'),
                ],
              ),
              const SizedBox(height: 8),
              _slot(2, 'دست'),
              const SizedBox(height: 8),
              _slot(3, 'پا'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'اعضای بدن را بکش و بگذار سر جایش',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 12),
        // اعضای کشیدنی
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              for (var i = 0; i < _parts.length; i++)
                if (!_placed.contains(i))
                  MagneticDraggable(
                    data: _parts[i].$2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_parts[i].$2, style: const TextStyle(fontSize: 42)),
                        Text(
                          _parts[i].$1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _slot(int index, String label) {
    final filled = _placed.contains(index);
    final part = _parts[index];
    return Column(
      children: [
        DragTarget<String>(
          onWillAcceptWithDetails: (_) => !_placed.contains(index),
          onAcceptWithDetails: (details) => _onDrop(index, details.data),
          builder: (context, candidates, rejected) {
            final hovering = candidates.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: hovering
                    ? Colors.amber.withOpacity(0.25)
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hovering ? Colors.amber : Colors.white30,
                  width: hovering ? 3 : 2,
                ),
              ),
              child: filled
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(part.$2, style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 2),
                        Text(
                          part.$1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      style: const TextStyle(color: Colors.white38),
                    ),
            );
          },
        ),
        if (filled) ...[
          const SizedBox(height: 4),
          ChildTouchTarget(
            minSize: 40,
            onTap: () => _saySense(index),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                SizedBox(width: 2),
                Text(
                  'بشنو',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧍✨', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text(
            'بدنت کامل شد!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'چشم می‌بیند، گوش می‌شنود، دست لمس می‌کند و پا راه می‌رود!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.7),
          ),
          const SizedBox(height: 26),
          PremiumButton(
            text: 'دوباره 🔄',
            icon: Icons.replay_rounded,
            onPressed: () => setState(() {
              _placed.clear();
              _finished = false;
            }),
          ),
          const SizedBox(height: 12),
          PremiumButton(
            text: 'برگشت 🏠',
            icon: Icons.home_rounded,
            color: const Color(0xFF5C6BC0),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
