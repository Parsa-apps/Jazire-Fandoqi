import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/premium_button.dart';

/// ────────────────────────────────────────────────────────────
/// 🧩 فاز ۳۵: پازل کشیدنی کودکانه
///
/// تصویر ایموجی به تکه‌های ۲×۲ تا ۳×۳ تقسیم می‌شود؛ کودک هر
/// تکه را با آهنربای کناری روی جای درست می‌گذارد. ویبره نرم و
/// تشویق فندقی بعد از هر تکه درست.
/// ────────────────────────────────────────────────────────────
class PuzzleGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const PuzzleGame({super.key, this.stageId, this.stageNumber});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  static const List<List<String>> _pictures = <List<String>>[
    ['🐰', '🌳', '🌞', '🌼'],
    ['🐱', '🐟', '🌊', '🦋'],
    ['🚀', '⭐', '🌙', '🪐'],
    ['🍎', '🍇', '🍊', '🍉'],
  ];

  late int _gridSize; // 2 یا 3
  late List<String> _tiles; // تصویر کامل به‌صورت تکه
  late List<String> _shuffled;
  final List<String?> _placed = <String?>[];
  int _correctPlaced = 0;
  bool _finished = false;
  int _pictureIndex = 0;

  @override
  void initState() {
    super.initState();
    _newPuzzle();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.instruction(
        'تکه‌های پازل را با انگشت به جای درست بکش! آهنربا کمکت می‌کند 🧲',
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _newPuzzle() {
    _pictureIndex = (_pictureIndex + 1) % _pictures.length;
    final picture = _pictures[_pictureIndex];
    _gridSize = picture.length == 4 ? 2 : 3;
    _tiles = List<String>.of(picture);
    if (_gridSize == 3) {
      // برای شبکه ۳×۳ یک تصویر ۹تکه می‌سازیم
      _tiles = <String>[
        '🐰', '🐰', '🌳', '🌳', '🌞', '🌞', '🌼', '🌼', '⭐',
      ];
    }
    _shuffled = List<String>.of(_tiles)..shuffle(Random());
    _placed = List<String?>.filled(_tiles.length, null);
    _correctPlaced = 0;
    _finished = false;
  }

  void _onDrop(int slotIndex, String tile) {
    if (_placed[slotIndex] != null) return;
    final correct = tile == _tiles[slotIndex];
    if (!correct) return; // تکه اشتباه برنمی‌گردد، فقط نمی‌چسبد
    setState(() {
      _placed[slotIndex] = tile;
      _correctPlaced++;
      if (_correctPlaced == _tiles.length) _finish();
    });
    if (correct && !_finished) {
      FandoghiCoach.correct('تکه درست سر جایش نشست! 🧩');
      HapticFeedback.lightImpact();
      unawaited(AudioService.playCorrect());
    }
  }

  void _finish() {
    setState(() => _finished = true);
    GameData.recordAnswer(correct: true, skill: 'pattern');
    GameData.addCoins(12);
    GameData.addStars(2);
    if (widget.stageId != null) {
      GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
    }
    FandoghiCoach.reward('پازل کامل شد! تو یک حل‌کننده‌ی حرفه‌ای هستی 🏆');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.ocean),
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
                  'پازل جادویی 🧩',
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
        const SizedBox(height: 14),
        // اسلات‌های خالی
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: _buildSlotGrid(),
        ),
        const SizedBox(height: 18),
        const Text(
          'تکه‌ها را بکش و بگذار سر جایش',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 12),
        // تکه‌های کشیدنی
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final tile in _shuffled)
                // فقط تکه‌هایی که هنوز جایشان خالی است نمایش داده می‌شوند
                // (در پازل ۳×۳ تکه‌های تکراری داریم؛ یکی که نشست،
                //  بقیه همان تکه باید همچنان قابل کشیدن باشند)
                if (_countUnplaced(tile) > 0)
                  MagneticDraggable(
                    data: tile,
                    child: _tile(tile),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  int _countUnplaced(String tile) {
    return _shuffled.where((t) => t == tile).length -
        _placed.where((p) => p == tile).length;
  }

  Widget _buildSlotGrid() {
    final size = (MediaQuery.of(context).size.width - 90) / _gridSize;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < _gridSize; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var col = 0; col < _gridSize; col++)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: _slot(row * _gridSize + col, size),
                ),
            ],
          ),
      ],
    );
  }

  Widget _slot(int slotIndex, double size) {
    final tile = _placed[slotIndex];
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => _placed[slotIndex] == null,
      onAcceptWithDetails: (details) => _onDrop(slotIndex, details.data),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: hovering
                ? Colors.amber.withOpacity(0.25)
                : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hovering ? Colors.amber : Colors.white24,
              width: hovering ? 3 : 2,
            ),
          ),
          child: Center(
            child: tile == null
                ? Text(
                    '؟',
                    style: TextStyle(
                      fontSize: size * 0.4,
                      color: Colors.white24,
                    ),
                  )
                : FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      tile,
                      style: TextStyle(fontSize: size * 0.6),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _tile(String emoji) {
    return Draggable<String>(
      data: emoji,
      feedback: Material(
        color: Colors.transparent,
        child: Text(emoji, style: const TextStyle(fontSize: 44)),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Text(emoji, style: const TextStyle(fontSize: 40)),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 40)),
    );
  }

  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧩✨', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text(
            'پازل کامل شد!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          PremiumButton(
            text: 'پازل جدید 🎲',
            icon: Icons.casino_rounded,
            onPressed: () => setState(_newPuzzle),
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
