import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/app_colors.dart';
import '../../../core/game_data.dart';
import '../../../shared/widgets/particle_celebration.dart';

/// ═══════════════════════════════════════════════
/// 🧠 MEMORY MATCH — Card Flip Game
/// Beautiful animated card matching with 3D flip
/// Uses Flutter animations for smooth card flips
/// ═══════════════════════════════════════════════
class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});
  @override
  State<MemoryMatchGame> createState() => _MemoryState();
}

class _MemoryState extends State<MemoryMatchGame>
    with TickerProviderStateMixin {
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

  late AnimationController _timerCtrl;
  late AnimationController _entryCtrl;

  // Card sets
  static const _animalSet = [
    ('🦁', 'شیر'), ('🐱', 'گربه'), ('🐶', 'سگ'), ('🐰', 'خرگوش'),
    ('🐘', 'فیل'), ('🐵', 'میمون'), ('🦊', 'روباه'), ('🐼', 'پاندا'),
  ];

  static const _fruitSet = [
    ('🍎', 'سیب'), ('🍌', 'موز'), ('🍇', 'انگور'), ('🍊', 'پرتقال'),
    ('🍓', 'توت‌فرنگی'), ('🍉', 'هندوانه'), ('🍒', 'گیلاس'), ('🍍', 'آناناس'),
  ];

  static const _colorSet = [
    ('🔴', 'قرمز'), ('🔵', 'آبی'), ('🟢', 'سبز'), ('🟡', 'زرد'),
    ('🟣', 'بنفش'), ('🟠', 'نارنجی'), ('⚪', 'سفید'), ('⚫', 'سیاه'),
  ];

  @override
  void initState() {
    super.initState();
    _timerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _timerCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _startGame(String type) {
    List<(String, String)> dataSet;
    int pairCount;

    switch (type) {
      case 'easy':
        dataSet = _animalSet.sublist(0, 4);
        pairCount = 4;
        _timeLeft = 60;
        break;
      case 'medium':
        dataSet = _fruitSet.sublist(0, 6);
        pairCount = 6;
        _timeLeft = 90;
        break;
      case 'hard':
        dataSet = _colorSet;
        pairCount = 8;
        _timeLeft = 120;
        break;
      default:
        dataSet = _animalSet.sublist(0, 6);
        pairCount = 6;
        _timeLeft = 90;
    }

    // Create pairs
    _cards = [];
    for (final (emoji, name) in dataSet) {
      _cards.add(_CardData(emoji: emoji, name: name));
      _cards.add(_CardData(emoji: emoji, name: name));
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
    });

    // Start timer
    _timerCtrl.repeat();
    _tick();
  }

  void _tick() async {
    while (_timeLeft > 0 && _started && !_gameOver && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && !_gameOver) {
        setState(() => _timeLeft--);
        if (_timeLeft <= 0) _endGame();
      }
    }
  }

  void _onCardTap(int index) {
    if (_busy || _gameOver) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;

    HapticFeedback.lightImpact();

    setState(() {
      _cards[index].isFlipped = true;

      if (_firstFlipped == null) {
        _firstFlipped = index;
      } else {
        _secondFlipped = index;
        _moves++;
        _busy = true;

        // Check match
        if (_cards[_firstFlipped!].emoji == _cards[index].emoji) {
          // Match!
          _combo++;
          final bonus = _combo > 2 ? _combo * 5 : 0;
          _score += 10 + bonus;
          _matches++;

          _cards[_firstFlipped!].isMatched = true;
          _cards[index].isMatched = true;

          HapticFeedback.mediumImpact();

          if (_matches == _cards.length ~/ 2) {
            // All matched!
            _showCelebration = true;
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) setState(() => _showCelebration = false);
            });
            _endGame();
          }

          _firstFlipped = null;
          _secondFlipped = null;
          _busy = false;
        } else {
          // No match
          _combo = 0;
          HapticFeedback.heavyImpact();

          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _cards[_firstFlipped!].isFlipped = false;
                _cards[index].isFlipped = false;
                _firstFlipped = null;
                _secondFlipped = null;
                _busy = false;
              });
            }
          });
        }
      }
    });
  }

  void _endGame() {
    _timerCtrl.stop();
    setState(() => _gameOver = true);

    // Bonus for time remaining
    final timeBonus = _timeLeft * 2;
    _score += timeBonus;

    // Save progress
    GameData.addCoins(_score ~/ 2);
    GameData.addStars(_matches);
    GameData.recordCorrect();
    GameData.addSkill('memory');
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
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          _glassBtn(Icons.refresh_rounded, () {
            if (_started) _startGame('medium');
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.emoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 4),
          Text(
            card.name,
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          if (card.isMatched)
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
        ],
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
              style: GoogleFonts.vazirmatn(
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
            const SizedBox(height: 40),
            _levelButton('آسان 🌱', '4 جفت • ۶۰ ثانیه', 'easy', const Color(0xFF00B894)),
            const SizedBox(height: 12),
            _levelButton('متوسط ⭐', '6 جفت • ۹۰ ثانیه', 'medium', const Color(0xFFFDCB6E)),
            const SizedBox(height: 12),
            _levelButton('سخت 🔥', '8 جفت • ۱۲۰ ثانیه', 'hard', const Color(0xFFE17055)),
          ],
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
                style: GoogleFonts.vazirmatn(
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
                    onPressed: () => _startGame('medium'),
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
class _CardData {
  final String emoji;
  final String name;
  bool isFlipped = false;
  bool isMatched = false;

  _CardData({required this.emoji, required this.name});
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
