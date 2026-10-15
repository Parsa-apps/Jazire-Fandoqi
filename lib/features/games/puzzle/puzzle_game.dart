import 'dart:async';
import 'dart:math';

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
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/next_today_button.dart';
import '../../../shared/widgets/particle_celebration.dart';

/// 🧩 PUZZLE GAME (Interactive and beautiful)
class PuzzleGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const PuzzleGame({
    super.key,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  /// اندازه‌های دوستانهٔ کودک: ۴ / ۶ / ۹ / ۱۲ تکه (۲×۲، ۲×۳، ۳×۳، ۳×۴).
  static const List<int> _sizeOptions = [4, 6, 9, 12];

  int _cols = 2;
  int _rows = 2;
  List<int> _tiles = [];
  int _moves = 0;
  bool _won = false;

  int get _pieceCount => _cols * _rows;

  @override
  void initState() {
    super.initState();
    _initPuzzle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.instruction(
          'تیکه‌های پازل رو جابجا کن تا تصویر کامل بشه! 🧩',
        );
      }
    });
  }
  
  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _initPuzzle() {
    _tiles = List.generate(_pieceCount, (index) => index);
    _moves = 0;
    _won = false;
    _shufflePuzzle();
  }

  void _selectSize(int pieces) {
    setState(() {
      switch (pieces) {
        case 4:
          _cols = 2;
          _rows = 2;
        case 6:
          _cols = 2;
          _rows = 3;
        case 9:
          _cols = 3;
          _rows = 3;
        case 12:
          _cols = 3;
          _rows = 4;
      }
      // تغییر اندازه پیشرفت را بدون خروج از بازی ریست می‌کند.
      _initPuzzle();
    });
    AudioService.tap();
  }
  
  void _shufflePuzzle() {
    // Ensuring it is solvable by making random valid moves
    final rng = Random();
    int emptyIndex = _pieceCount - 1;
    for (int i = 0; i < 50; i++) {
      final validMoves = _getValidMoves(emptyIndex);
      if (validMoves.isNotEmpty) {
        final move = validMoves[rng.nextInt(validMoves.length)];
        _swapTiles(emptyIndex, move);
        emptyIndex = move;
      }
    }
  }

  List<int> _getValidMoves(int emptyIndex) {
    List<int> moves = [];
    int row = emptyIndex ~/ _cols;
    int col = emptyIndex % _cols;

    if (row > 0) moves.add(emptyIndex - _cols); // Top
    if (row < _rows - 1) moves.add(emptyIndex + _cols); // Bottom
    if (col > 0) moves.add(emptyIndex - 1); // Left
    if (col < _cols - 1) moves.add(emptyIndex + 1); // Right
    return moves;
  }

  void _swapTiles(int i, int j) {
    final temp = _tiles[i];
    _tiles[i] = _tiles[j];
    _tiles[j] = temp;
  }

  void _onTileTap(int index) {
    if (_won) return;
    
    int emptyIndex = _tiles.indexOf(_pieceCount - 1);
    final validMoves = _getValidMoves(emptyIndex);
    
    if (validMoves.contains(index)) {
      HapticFeedback.lightImpact();
      AudioService.tap();
      setState(() {
        _swapTiles(index, emptyIndex);
        _moves++;
      });
      _checkWin();
    }
  }

  void _checkWin() {
    bool isWon = true;
    for (int i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i) {
        isWon = false;
        break;
      }
    }
    
    if (isWon) {
      setState(() => _won = true);
      HapticFeedback.heavyImpact();
      AudioService.win();
      FandoghiCoach.reward('آفرین! پازل رو کامل کردی! 🎉');
      
      GameData.addCoins(20);
      GameData.addStars(2);
      GameData.recordAnswer(correct: true, skill: 'logic');
      if (widget.stageId != null) {
        GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
      }
    }
  }

  Widget _sizeChip(int pieces) {
    final selected = _pieceCount == pieces;
    return ChildTouchTarget(
      onTap: () => _selectSize(pieces),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(selected ? 0.9 : 0.25),
          ),
        ),
        child: Text(
          '$pieces تکه',
          style: AppFonts.vazirmatn(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      // اسکرول‌محور تا در صفحه‌های کوچک هم RenderFlex overflow رخ ندهد.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ChildTouchTarget(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'حرکت: $_moves',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'پازل جادویی 🧩',
                    style: AppFonts.vazirmatn(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [for (final pieces in _sizeOptions) _sizeChip(pieces)],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_moves/$_pieceCount',
                    key: const ValueKey('puzzle_progress'),
                    style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),

                  // Puzzle Grid
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _cols,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: _tiles.length,
                          itemBuilder: (context, index) {
                            final tileValue = _tiles[index];
                            final isEmpty = tileValue == _pieceCount - 1;

                            if (isEmpty && !_won) {
                              return const SizedBox.shrink();
                            }

                            return GestureDetector(
                              onTap: () => _onTileTap(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: _won ? Colors.green : Colors.blue.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Center(
                                  child: Text(
                                    _won && isEmpty ? '✨' : '${tileValue + 1}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (_won)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const FandoghiPremium(size: 80, mood: FandoghiMood.celebrating, showParticles: true)
                              .animate()
                              .scale(curve: Curves.elasticOut),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              setState(() {
                                _initPuzzle();
                              });
                            },
                            child: Text('بازی دوباره',
                                style: AppFonts.vazirmatn(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
