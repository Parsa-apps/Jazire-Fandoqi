import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/fandoghi_v2.dart';
import '../../../shared/widgets/illustration_tile.dart';
import '../../../shared/widgets/particle_celebration.dart';

/// ═══════════════════════════════════════════════
/// 🧠 MEMORY MATCH — Card Flip Game
/// Beautiful animated card matching with 3D flip
/// Uses Flutter animations for smooth card flips
/// ═══════════════════════════════════════════════
class MemoryMatchGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const MemoryMatchGame({
    super.key,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<MemoryMatchGame> createState() => _MemoryState();
}

class _MemoryState extends State<MemoryMatchGame>
    with WidgetsBindingObserver {
  // Game state
  late List<_CardData> _cards;
  int? _firstFlipped;
  int? _secondFlipped;
  int _matches = 0;
  int _moves = 0;
  int _score = 0;
  int _combo = 0;
  bool _busy = false; // prevent tapping during flip
  bool _started = false;
  bool _gameOver = false;
  bool _showCelebration = false;
  int _timeLeft = 120;
  String _selectedLevel = 'medium';
  int _gameToken = 0;
  bool _pausedByBackground = false;

  static const String _memoryAsset =
      'assets/illustrations/memory_cards.webp';

  // Generated, consistent illustrations replace emoji-only memory cards.
  static const _memorySet = [
    _MemoryItem('🚀', 'موشک', 0),
    _MemoryItem('☂️', 'چتر', 1),
    _MemoryItem('🪁', 'بادبادک', 2),
    _MemoryItem('🤖', 'ربات', 3),
    _MemoryItem('🦕', 'دایناسور', 4),
    _MemoryItem('🚢', 'زیردریایی', 5),
    _MemoryItem('🦋', 'پروانه', 6),
    _MemoryItem('🌈', 'رنگین‌کمان', 7),
  ];

  // فاز ۳۱: تم‌های ایرانی — حیوانات بومی و میوه‌های ایران
  static const _memorySetAnimals = [
    _MemoryItem('🐆', 'یوزپلنگ', 0),
    _MemoryItem('🐻', 'خرس', 1),
    _MemoryItem('🦊', 'روباه', 2),
    _MemoryItem('🐺', 'گرگ', 3),
    _MemoryItem('🦌', 'آهو', 4),
    _MemoryItem('🐏', 'قوچ', 5),
    _MemoryItem('🦅', 'عقاب', 6),
    _MemoryItem('🐢', 'لاک‌پشت', 7),
  ];

  static const _memorySetFruits = [
    _MemoryItem('🍎', 'سیب', 0),
    _MemoryItem('🍇', 'انگور', 1),
    _MemoryItem('🍉', 'هندوانه', 2),
    _MemoryItem('🍊', 'پرتقال', 3),
    _MemoryItem('🍌', 'موز', 4),
    _MemoryItem('🍒', 'گیلاس', 5),
    _MemoryItem('🍐', 'گلابی', 6),
    _MemoryItem('🍑', 'هلو', 7),
  ];

  /// فاز ۳۱: تم انتخابی (classic / animals / fruits)
  String _selectedTheme = 'classic';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.instruction(
          'دو کارت شبیه هم را پیدا کن! من داور حافظه‌ات هستم و هر جفت درست را جشن می‌گیرم 🧠',
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ فیکس عمیق فاز ۳۱: تایمر در پس‌زمینه متوقف می‌شود تا باتری نخورد
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pausedByBackground = true;
    } else if (state == AppLifecycleState.resumed) {
      _pausedByBackground = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FandoghiCoach.clear();
    super.dispose();
  }

  void _startGame(String type) {
    if (!canStartPlay(context)) return;
    _gameToken++;
    _selectedLevel = type;

    // فاز ۳۱: انتخاب مجموعه بر اساس تم
    final baseSet = switch (_selectedTheme) {
      'animals' => _memorySetAnimals,
      'fruits' => _memorySetFruits,
      _ => _memorySet,
    };
    List<_MemoryItem> dataSet;
    switch (type) {
      case 'very_easy':
        dataSet = baseSet.sublist(0, 2);
        _timeLeft = 40;
        break;
      case 'easy':
        dataSet = baseSet.sublist(0, 4);
        _timeLeft = 60;
        break;
      case 'medium':
        dataSet = baseSet.sublist(0, 6);
        _timeLeft = 90;
        break;
      case 'hard':
        dataSet = baseSet;
        _timeLeft = 120;
        break;
      case 'expert':
        dataSet = baseSet;
        _timeLeft = 150;
        break;
      default:
        dataSet = baseSet.sublist(0, 6);
        _timeLeft = 90;
    }

    _cards = <_CardData>[];
    for (final item in dataSet) {
      _cards.add(
        _CardData(
          emoji: item.emoji,
          name: item.name,
          imageIndex: item.imageIndex,
        ),
      );
      _cards.add(
        _CardData(
          emoji: item.emoji,
          name: item.name,
          imageIndex: item.imageIndex,
        ),
      );
    }
    _cards.shuffle();

    setState(() {
      _firstFlipped = null;
      _secondFlipped = null;
      _matches = 0;
      _moves = 0;
      _score = 0;
      _combo = 0;
      _busy = false;
      _started = true;
      _gameOver = false;
      _showCelebration = false;
    });

    FandoghiCoach.instruction(
      'کارت‌ها را با دقت نگاه کن؛ هر جفت درست یک امتیاز برایت دارد 🌰',
    );
    _tick(_gameToken);
  }

  Future<void> _tick(int token) async {
    while (token == _gameToken &&
        _timeLeft > 0 &&
        _started &&
        !_gameOver &&
        mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || token != _gameToken || _gameOver) return;
      // ✅ فیکس: اگر اپ در پس‌زمینه است، تایمر را کم نکن
      if (_pausedByBackground) continue;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _endGame(won: false);
    }
  }

  void _onCardTap(int index) {
    if (_busy || _gameOver || index < 0 || index >= _cards.length) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;
    if (!canStartPlay(context)) return;

    HapticFeedback.lightImpact();
    AudioService.tap();
    if (_firstFlipped == null) {
      setState(() {
        _cards[index].isFlipped = true;
        _firstFlipped = index;
      });
      return;
    }

    final token = _gameToken;
    final firstIndex = _firstFlipped!;
    var isMatch = false;
    var won = false;

    setState(() {
      _cards[index].isFlipped = true;
      _secondFlipped = index;
      _moves++;
      _busy = true;
      isMatch = _cards[firstIndex].emoji == _cards[index].emoji;

      if (isMatch) {
        _combo++;
        final bonus = _combo > 2 ? _combo * 5 : 0;
        _score += 10 + bonus;
        _matches++;
        _cards[firstIndex].isMatched = true;
        _cards[index].isMatched = true;
        _firstFlipped = null;
        _secondFlipped = null;
        _busy = false;
        won = _matches == _cards.length ~/ 2;
      } else {
        _combo = 0;
      }
    });

    GameData.recordAnswer(correct: isMatch, skill: 'memory');
    if (isMatch) {
      // فاز ۵۲: پیشرفت مأموریت روزانه حافظه
      GameData.progressMission('memory');
      FandoghiCoach.correct('جفت درست پیدا شد! حافظه‌ات عالی کار می‌کند 🧠🌟');
      AudioService.correct();
      if (bonus > 0) AudioService.coin();
      HapticFeedback.mediumImpact();
      if (won) {
        setState(() => _showCelebration = true);
        Future<void>.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && token == _gameToken) {
            setState(() => _showCelebration = false);
          }
        });
        _endGame(won: true);
      }
      return;
    }

    FandoghiCoach.say(
      'این دو کارت جفت نبودند؛ اشکالی ندارد، با دقت دوباره امتحان کن 💪',
      mood: FandoghiMood.thinking,
      tone: FandoghiCoachTone.encouragement,
    );
    AudioService.wrong();
    HapticFeedback.heavyImpact();
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (!mounted || token != _gameToken || _gameOver) return;
      setState(() {
        _cards[firstIndex].isFlipped = false;
        _cards[index].isFlipped = false;
        _firstFlipped = null;
        _secondFlipped = null;
        _busy = false;
      });
    });
  }

  void _endGame({required bool won}) {
    if (_gameOver) return;
    _gameOver = true;
    final timeBonus = won ? _timeLeft * 2 : 0;
    _score += timeBonus;

    if (mounted) setState(() {});
    GameData.addCoins(_score ~/ 2);
    GameData.addStars(_matches);
    GameData.updateHighScore(_score, 'quiz');
    if (won && widget.stageId != null) {
      GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
    }
    if (won) {
      AudioService.win();
    } else {
      AudioService.lose();
    }
    FandoghiCoach.reward(
      won
          ? 'همه جفت‌ها را پیدا کردی! فندقی به قهرمان حافظه تبریک می‌گوید 🏆'
          : 'زمان تمام شد؛ اشکالی ندارد، یک بار دیگر با هم تمرین می‌کنیم 💪',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  _buildTopBar(),

                  if (!_started) _buildStartScreen(),

                  if (_started && !_gameOver) ...[
                    // Stats bar
                    _buildStatsBar(),
                    const SizedBox(height: 16),
                    // Game grid
                    Expanded(child: _buildGrid()),
                  ],
                ],
              ),
            ),

            // Celebration
            ParticleCelebration(trigger: _showCelebration),

            // Game over
            if (_gameOver) _buildGameOver(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _glassBtn(Icons.arrow_back_rounded, () => Navigator.pop(context)),
          const Spacer(),
          Text(
            '🧠 بازی حافظه',
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          _glassBtn(Icons.refresh_rounded, () {
            if (_started) _startGame(_selectedLevel);
          }),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statChip('⏱', '$_timeLeft', _timeLeft <= 15 ? Colors.red : Colors.white),
          _statChip('🎯', '$_moves حرکت', Colors.white),
          _statChip('⭐', '$_score', Colors.amber),
          if (_combo > 1) _statChip('🔥', '${_combo}x', Colors.orange),
        ],
      ),
    );
  }

  Widget _statChip(String icon, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final crossCount = _cards.length <= 8 ? 4 : 4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: _cards.length,
        itemBuilder: (ctx, i) => _buildCard(i),
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: card.isMatched
              ? const LinearGradient(
                  colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
                )
              : card.isFlipped
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF2D3436), Color(0xFF636E72)],
                    ),
          border: card.isMatched
              ? Border.all(color: const Color(0xFF00B894), width: 2)
              : card.isFlipped
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 2)
                  : Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          boxShadow: [
            if (card.isFlipped || card.isMatched)
              BoxShadow(
                color: (card.isMatched ? const Color(0xFF00B894) : AppColors.primary)
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _CardFlipWidget(
            isFlipped: card.isFlipped || card.isMatched,
            front: _buildCardFront(card),
            back: _buildCardBack(),
          ),
        ),
      ),
    )
        .animate(
          delay: Duration(milliseconds: 100 * index),
          onPlay: (c) => c.forward(),
        )
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildCardFront(_CardData card) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: card.isMatched
            ? const LinearGradient(
                colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: IllustrationTile(
                asset: _memoryAsset,
                index: card.imageIndex,
                semanticLabel: card.name,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              card.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            if (card.isMatched)
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D3436),
            const Color(0xFF636E72),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '❓',
              style: TextStyle(fontSize: 32, color: Colors.white.withOpacity(0.3)),
            ),
            const SizedBox(height: 2),
            Text(
              '?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧠', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              'بازی حافظه',
              style: AppFonts.vazirmatn(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'کارت‌ها رو برگردون و جفت‌ها رو پیدا کن!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white.withOpacity(0.8),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            // فاز ۳۱: انتخاب تم ایرانی
            Text(
              'تم کارت‌ها:',
              style: AppFonts.vazirmatn(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _themeButton('کلاسیک', '🚀', 'classic'),
                const SizedBox(width: 10),
                _themeButton('حیوانات', '🐆', 'animals'),
                const SizedBox(width: 10),
                _themeButton('میوه‌ها', '🍎', 'fruits'),
              ],
            ),
            const SizedBox(height: 26),
            _levelButton('شروع آسان 🌱', '2 جفت • ۴۰ ثانیه', 'very_easy', const Color(0xFF55A3F0)),
            const SizedBox(height: 12),
            _levelButton('آسان 🌱', '4 جفت • ۶۰ ثانیه', 'easy', const Color(0xFF00B894)),
            const SizedBox(height: 12),
            _levelButton('متوسط ⭐', '6 جفت • ۹۰ ثانیه', 'medium', const Color(0xFFFDCB6E)),
            const SizedBox(height: 12),
            _levelButton('سخت 🔥', '8 جفت • ۱۲۰ ثانیه', 'hard', const Color(0xFFE17055)),
            const SizedBox(height: 12),
            _levelButton('حرفه‌ای 👑', '8 جفت • ۱۵۰ ثانیه', 'expert', const Color(0xFF9B59B6)),
          ],
        ),
      ),
    );
  }

  Widget _themeButton(String title, String emoji, String theme) {
    final selected = _selectedTheme == theme;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? AppColors.primary : Colors.white.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () => setState(() => _selectedTheme = theme),
      child: Text(
        '$emoji $title',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _levelButton(String title, String subtitle, String level, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: () => _startGame(level),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    final allMatched = _matches == _cards.length ~/ 2;
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                allMatched ? '🏆' : '⏰',
                style: const TextStyle(fontSize: 70),
              ),
              const SizedBox(height: 16),
              Text(
                allMatched ? 'آفرین!' : 'وقت تموم شد!',
                style: AppFonts.vazirmatn(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _resultRow('🎯 حرکت‌ها', '$_moves'),
              _resultRow('⭐ امتیاز', '$_score'),
              _resultRow('🃏 جفت‌ها', '$_matches/${_cards.length ~/ 2}'),
              _resultRow('⏱ زمان باقی‌مانده', '$_timeLeft ثانیه'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _startGame(_selectedLevel),
                    child: const Text(
                      'دوباره 🔄',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'برگرد 🏠',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 15)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _glassBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── Card Data ───────────────────────────────
class _MemoryItem {
  final String emoji;
  final String name;
  final int imageIndex;

  const _MemoryItem(this.emoji, this.name, this.imageIndex);
}

class _CardData {
  final String emoji;
  final String name;
  final int imageIndex;
  bool isFlipped = false;
  bool isMatched = false;

  _CardData({
    required this.emoji,
    required this.name,
    required this.imageIndex,
  });
}

// ─── 3D Card Flip Widget ─────────────────────
class _CardFlipWidget extends StatelessWidget {
  final bool isFlipped;
  final Widget front;
  final Widget back;

  const _CardFlipWidget({
    required this.isFlipped,
    required this.front,
    required this.back,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotateAnim,
          child: child,
          builder: (context, child) {
            final isFront = child!.key == const ValueKey('front');
            final tilt = ((isFront ? rotateAnim.value - pi : rotateAnim.value) / 2).abs();
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(isFront ? pi - tilt : tilt);
            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      child: isFlipped
          ? Container(key: const ValueKey('front'), child: front)
          : Container(key: const ValueKey('back'), child: back),
    );
  }
}
