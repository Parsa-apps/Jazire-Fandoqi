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
import '../../../shared/widgets/fandoghi_premium.dart';
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
  Timer? _countdownTimer;
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
    // فاز ۳۱: در پس‌زمینه هیچ Timer فعالی باقی نمی‌ماند. این کار علاوه بر
    // ثابت نگه‌داشتن زمان، بیدارشدن دوره‌ای و مصرف باتری را هم حذف می‌کند.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pausedByBackground = true;
      _stopCountdown();
    } else if (state == AppLifecycleState.resumed) {
      final wasPaused = _pausedByBackground;
      _pausedByBackground = false;
      if (wasPaused) _startCountdown();
    }
  }

  @override
  void dispose() {
    _stopCountdown();
    WidgetsBinding.instance.removeObserver(this);
    FandoghiCoach.clear();
    super.dispose();
  }

  void _startGame(String type) {
    if (!canStartPlay(context)) return;
    _stopCountdown();
    _pausedByBackground = false;
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
    _startCountdown();
  }

  /// Runs only while the game is visible. A periodic timer is easier to stop
  /// at the lifecycle boundary than a delayed async loop, which would still
  /// wake up once per second while the app is in the background.
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (!mounted || !_started || _gameOver || _pausedByBackground || _timeLeft <= 0) {
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_started || _gameOver || _pausedByBackground) {
        _stopCountdown();
        return;
      }

      var shouldEnd = false;
      setState(() {
        if (_timeLeft > 0) _timeLeft--;
        shouldEnd = _timeLeft <= 0;
      });
      if (shouldEnd) _endGame(won: false);
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
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
    var bonus = 0;

    setState(() {
      _cards[index].isFlipped = true;
      _secondFlipped = index;
      _moves++;
      _busy = true;
      isMatch = _cards[firstIndex].emoji == _cards[index].emoji;

      if (isMatch) {
        _combo++;
        bonus = _combo > 2 ? _combo * 5 : 0;
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
    _stopCountdown();
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
      backgroundColor: const Color(0xFF1B1B2F),
      body: ConfettiOverlay(
        isActive: _showCelebration,
        onComplete: () {},
        child: SafeArea(
          child: _started
              ? (_gameOver ? _buildGameOver() : _buildGame())
              : _buildStartScreen(),
        ),
      ),
    );
  }

  Widget _buildGame() {
    int cols = 3;
    if (_cards.length > 12) cols = 4;
    if (_cards.length <= 4) cols = 2;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _glassBtn(Icons.arrow_back_rounded, () {
                _stopCountdown();
                Navigator.pop(context);
              }),
              const Spacer(),
              _statBadge(
                '$_timeLeft',
                Icons.timer_rounded,
                _timeLeft < 10 ? Colors.red : Colors.white,
              ),
              const SizedBox(width: 8),
              _statBadge('$_score', Icons.star_rounded, Colors.amber),
            ],
          ),
        ),
        // فاز ۳۱: نمایش حرکت‌ها و کمبو با دیزاین مدرن‌تر
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'حرکت‌ها: $_moves',
                style: AppFonts.vazirmatn(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_combo > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  ),
                  child: Text(
                    '$_combo جفت پیاپی! 🔥',
                    style: AppFonts.vazirmatn(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final pad = 24.0;
              final spacing = 12.0;

              final rows = (_cards.length / cols).ceil();
              final availableW = w - (pad * 2) - (spacing * (cols - 1));
              final availableH = h - (pad * 2) - (spacing * (rows - 1));

              final cardW = availableW / cols;
              final cardH = availableH / rows;
              final size = min(cardW, cardH).clamp(60.0, 110.0);

              return Center(
                child: SizedBox(
                  width: (size * cols) + (spacing * (cols - 1)),
                  height: (size * rows) + (spacing * (rows - 1)),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: 1,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return _buildCard(index, size);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCard(int index, double size) {
    final card = _cards[index];
    
    // Front face (hidden)
    final front = Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: size * 0.4,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // Back face (revealed)
    final back = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: card.isMatched
            ? [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)]
            : AppShadows.soft,
        border: Border.all(
          color: card.isMatched ? Colors.green : Colors.transparent,
          width: card.isMatched ? 3 : 0,
        ),
      ),
      child: Center(
        child: Text(
          card.emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: _CardFlipWidget(
        isFlipped: card.isFlipped || card.isMatched,
        front: front,
        back: back,
      ),
    );
  }

  Widget _statBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C195A), Color(0xFF1B1B2F)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const FandoghiPremium(size: 88, mood: FandoghiMood.happy, showParticles: false).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text(
              'بازی حافظه 🧠',
              style: AppFonts.vazirmatn(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: Colors.white24)),
              child: Text('۳ تم ایرانی — ۵ سطح — چرخش ۳بعدی ✨', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            Text(
              'کارت‌ها رو برگردون و جفت‌ها رو پیدا کن!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
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
      child: !isFlipped
          ? Container(key: const ValueKey('front'), child: front)
          : Container(key: const ValueKey('back'), child: back),
    );
  }
}
