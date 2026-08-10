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
import '../../../core/play_limit.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/premium_button.dart';

/// ────────────────────────────────────────────────────────────
/// 🧩 فاز ۳۵: پازل کشیدنی کودکانه
///
/// پازل بدون اینترنت و بدون تصویر شبکه‌ای سنگین کار می‌کند. هر کارت یک
/// تکهٔ شماره‌دار دارد؛ بنابراین حتی وقتی دو تکه ظاهر یکسان دارند، کودک
/// همیشه فقط می‌تواند هر تکه را در جای واقعی خودش بنشاند. اندازه‌های ۴، ۶،
/// ۹ و ۱۲ تکه برای حرکت تدریجی از آسان به چالش‌برانگیز در دسترس‌اند.
/// ────────────────────────────────────────────────────────────
class PuzzleGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const PuzzleGame({super.key, this.stageId, this.stageNumber});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  static const List<_PuzzleTheme> _themes = <_PuzzleTheme>[
    _PuzzleTheme(
      title: 'باغ نوروزی',
      pieces: <String>['🌸', '🐰', '🥚', '🌿', '🪻', '🦋', '🌞', '🪺', '🌷', '🍃', '🐞', '🌈'],
      labels: <String>['شکوفه', 'خرگوش', 'تخم‌مرغ', 'سبزه', 'سنبل', 'پروانه', 'خورشید', 'لانه', 'لاله', 'برگ', 'کفشدوزک', 'رنگین‌کمان'],
    ),
    _PuzzleTheme(
      title: 'حیوانات ایران',
      pieces: <String>['🐆', '🦌', '🦊', '🦅', '🐻', '🐢', '🐏', '🐺', '🦋', '🐍', '🦉', '🐇'],
      labels: <String>['یوزپلنگ', 'آهو', 'روباه', 'عقاب', 'خرس', 'لاک‌پشت', 'قوچ', 'گرگ', 'پروانه', 'مار', 'جغد', 'خرگوش'],
    ),
    _PuzzleTheme(
      title: 'خوراکی‌های رنگی',
      pieces: <String>['🍎', '🍇', '🍉', '🍊', '🥒', '🌽', '🥕', '🍓', '🍋', '🍐', '🍑', '🥝'],
      labels: <String>['سیب', 'انگور', 'هندوانه', 'پرتقال', 'خیار', 'ذرت', 'هویج', 'توت‌فرنگی', 'لیمو', 'گلابی', 'هلو', 'کیوی'],
    ),
  ];

  static const List<_PuzzleLayout> _layouts = <_PuzzleLayout>[
    _PuzzleLayout(rows: 2, columns: 2),
    _PuzzleLayout(rows: 2, columns: 3),
    _PuzzleLayout(rows: 3, columns: 3),
    _PuzzleLayout(rows: 3, columns: 4),
  ];

  late List<_PuzzleTile> _tiles;
  late List<_PuzzleTile> _shuffledTiles;
  late List<_PuzzleTile?> _placed;

  int _themeIndex = 0;
  int _layoutIndex = 0;
  int _correctPlaced = 0;
  bool _finished = false;

  _PuzzleTheme get _theme => _themes[_themeIndex];
  _PuzzleLayout get _layout => _layouts[_layoutIndex];

  @override
  void initState() {
    super.initState();
    _newPuzzle(advanceTheme: false);
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameData.isDailyLimitReached) {
        showPlayLimitDialog(context).then((_) {
          if (mounted) Navigator.pop(context);
        });
        return;
      }
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

  void _newPuzzle({bool advanceTheme = true}) {
    if (advanceTheme) {
      _themeIndex = (_themeIndex + 1) % _themes.length;
    }

    final count = _layout.count;
    _tiles = List<_PuzzleTile>.generate(
      count,
      (index) => _PuzzleTile(
        id: index,
        emoji: _theme.pieces[index],
        label: _theme.labels[index],
      ),
      growable: false,
    );
    _shuffledTiles = List<_PuzzleTile>.of(_tiles);

    // جلوگیری از شروع بازی با صفحه‌ای که تصادفاً از اول حل شده است.
    final random = Random();
    var attempts = 0;
    do {
      _shuffledTiles.shuffle(random);
      attempts++;
    } while (_isSolvedOrder() && attempts < 8);

    _placed = List<_PuzzleTile?>.filled(count, null);
    _correctPlaced = 0;
    _finished = false;
  }

  bool _isSolvedOrder() {
    for (var index = 0; index < _shuffledTiles.length; index++) {
      if (_shuffledTiles[index].id != index) return false;
    }
    return true;
  }

  void _selectLayout(int index) {
    if (index == _layoutIndex || GameData.isDailyLimitReached) return;
    setState(() {
      _layoutIndex = index;
      _newPuzzle(advanceTheme: false);
    });
    FandoghiCoach.instruction(
      'این بار ${_layouts[index].count} تکه داریم؛ قدم‌به‌قدم جلو می‌رویم 🌟',
    );
  }

  void _requestNewPuzzle() {
    if (GameData.isDailyLimitReached) {
      showPlayLimitDialog(context);
      return;
    }
    setState(() => _newPuzzle());
  }

  void _onDrop(int slotIndex, _PuzzleTile tile) {
    if (GameData.isDailyLimitReached ||
        _finished ||
        slotIndex < 0 ||
        slotIndex >= _placed.length ||
        _placed[slotIndex] != null) {
      return;
    }

    // تکیه بر id به‌جای emoji، باگ تکه‌های تکراری را هم از بین می‌برد.
    if (tile.id != slotIndex) {
      HapticFeedback.selectionClick();
      FandoghiCoach.say(
        'این تکه برای جای دیگری است؛ به شکل و شماره‌اش دوباره نگاه کن 👀',
        mood: FandoghiMood.thinking,
        tone: FandoghiCoachTone.encouragement,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _placed[slotIndex] = tile;
      _correctPlaced++;
    });

    HapticFeedback.lightImpact();
    unawaited(AudioService.playCorrect());
    if (_correctPlaced == _tiles.length) {
      _finish();
    } else {
      FandoghiCoach.correct('تکه درست سر جایش نشست! 🧩');
    }
  }

  void _finish() {
    if (_finished) return;
    setState(() => _finished = true);
    GameData.recordAnswer(correct: true, skill: 'pattern');
    GameData.addCoins(12);
    GameData.addStars(2);
    if (widget.stageId != null) {
      GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
    }
    unawaited(AudioService.win());
    FandoghiCoach.reward('پازل کامل شد! تو یک حل‌کنندهٔ حرفه‌ای هستی 🏆');
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
        _buildHeader(),
        _buildPieceSelector(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              children: [
                _buildProgress(),
                const SizedBox(height: 12),
                _buildSlotGrid(),
                const SizedBox(height: 16),
                Text(
                  'تکه‌های «${_theme.title}» را بکش و سر جایشان بگذار',
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRemainingTiles(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          ChildTouchTarget(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Text(
                  'پازل جادویی 🧩',
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${_layout.count} تکه • ${_correctPlaced}/${_tiles.length} درست',
                  style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ChildTouchTarget(
            onTap: _requestNewPuzzle,
            child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 27),
          ),
        ],
      ),
    );
  }

  Widget _buildPieceSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'سختی:',
              style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(width: 8),
            for (var index = 0; index < _layouts.length; index++) ...[
              _pieceButton(index),
              if (index != _layouts.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pieceButton(int index) {
    final selected = index == _layoutIndex;
    return Semantics(
      button: true,
      selected: selected,
      label: '${_layouts[index].count} تکه',
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => _selectLayout(index),
        label: Text('${_layouts[index].count} تکه'),
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white.withOpacity(0.12),
        side: BorderSide(color: Colors.white.withOpacity(0.18)),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: _correctPlaced / _tiles.length,
              backgroundColor: Colors.white.withOpacity(0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${_correctPlaced}/${_tiles.length}',
          style: AppFonts.vazirmatn(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotGrid() {
    const spacing = 8.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cellSize = min(
      112.0,
      (screenWidth - 32 - spacing * (_layout.columns - 1)) / _layout.columns,
    ).clamp(56.0, 112.0).toDouble();
    final boardWidth = cellSize * _layout.columns + spacing * (_layout.columns - 1);

    return SizedBox(
      width: boardWidth,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _tiles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _layout.columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) => _slot(index, cellSize),
      ),
    );
  }

  Widget _slot(int slotIndex, double size) {
    final tile = _placed[slotIndex];
    return DragTarget<_PuzzleTile>(
      onWillAcceptWithDetails: (_) => _placed[slotIndex] == null,
      onAcceptWithDetails: (details) => _onDrop(slotIndex, details.data),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: AppMotion.fast,
          decoration: BoxDecoration(
            color: tile != null
                ? AppColors.success.withOpacity(0.82)
                : hovering
                    ? AppColors.warning.withOpacity(0.3)
                    : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: tile != null
                  ? Colors.white
                  : hovering
                      ? AppColors.warning
                      : Colors.white24,
              width: hovering || tile != null ? 3 : 2,
            ),
            boxShadow: tile != null ? AppShadows.colored(AppColors.success) : null,
          ),
          child: Center(
            child: tile == null
                ? Text(
                    '${slotIndex + 1}',
                    style: TextStyle(
                      fontSize: size * 0.32,
                      color: Colors.white38,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : _tileVisual(tile, size: size, compact: true),
          ),
        );
      },
    );
  }

  Widget _buildRemainingTiles() {
    final placedIds = _placed.whereType<_PuzzleTile>().map((tile) => tile.id).toSet();
    final remaining = _shuffledTiles.where((tile) => !placedIds.contains(tile.id));
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: remaining.map(_tile).toList(growable: false),
    );
  }

  Widget _tile(_PuzzleTile tile) {
    return Draggable<_PuzzleTile>(
      data: tile,
      maxSimultaneousDrags: 1,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 78,
          height: 78,
          child: _tileVisual(tile, size: 78),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: SizedBox(width: 78, height: 78, child: _tileVisual(tile, size: 78)),
      ),
      child: SizedBox(
        width: 78,
        height: 78,
        child: _tileVisual(tile, size: 78),
      ),
    );
  }

  Widget _tileVisual(
    _PuzzleTile tile, {
    required double size,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(compact ? 0.12 : 0.94),
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        border: Border.all(
          color: compact ? Colors.white54 : Colors.white,
          width: compact ? 1 : 2,
        ),
        boxShadow: compact ? null : AppShadows.soft,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: Text(
              tile.emoji,
              style: TextStyle(fontSize: compact ? size * 0.46 : size * 0.38),
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 2),
            Text(
              tile.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.vazirmatn(
                color: AppColors.textPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FandoghiPremium(
              size: 96,
              mood: FandoghiMood.celebrating,
              showParticles: true,
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text(
              'پازل کامل شد! 🧩✨',
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 10),
            Text(
              'پازل «${_theme.title}» را با ${_tiles.length} تکه حل کردی.',
              textAlign: TextAlign.center,
              style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: AppRadii.card,
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                'جایزه: +۱۲ سکه • +۲ ستاره 🏆',
                style: AppFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'پازل جدید 🎲',
              icon: Icons.casino_rounded,
              onPressed: _requestNewPuzzle,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home_rounded, size: 18, color: Colors.white),
              label: Text(
                'برگشت به خانه',
                style: AppFonts.vazirmatn(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PuzzleTheme {
  final String title;
  final List<String> pieces;
  final List<String> labels;

  const _PuzzleTheme({
    required this.title,
    required this.pieces,
    required this.labels,
  });
}

class _PuzzleLayout {
  final int rows;
  final int columns;

  const _PuzzleLayout({required this.rows, required this.columns});

  int get count => rows * columns;
}

class _PuzzleTile {
  final int id;
  final String emoji;
  final String label;

  const _PuzzleTile({
    required this.id,
    required this.emoji,
    required this.label,
  });
}
