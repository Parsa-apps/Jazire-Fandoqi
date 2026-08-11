import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_colors.dart';
import '../../../app/design_tokens.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/fandoghi_premium.dart';

/// 🫧 BUBBLE POP — Flame Engine with Flutter GestureDetector
class BubblePopGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const BubblePopGame({
    super.key,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<BubblePopGame> createState() => _BubblePopState();
}

class _BubblePopState extends State<BubblePopGame>
    with WidgetsBindingObserver {
  late BubblePopFlameGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FandoghiCoach.enablePersistentPresence();
    _game = BubblePopFlameGame(
      stageId: widget.stageId,
      stageNumber: widget.stageNumber,
      onUpdate: () {
        if (mounted) setState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.instruction(
          'حباب هدف را پیدا کن و فقط همان را بترکان؛ من داور حباب‌ها هستم 🫧',
        );
      }
    });
  }

  /// فاز ۶۵: توقف موتور Flame در پس‌زمینه (صرفه‌جویی باتری)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _game.pauseEngine();
    } else if (state == AppLifecycleState.resumed) {
      _game.resumeEngine();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FandoghiCoach.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (details) {
              if (!_game.started || _game.gameOver) return;
              if (!canStartPlay(context)) return;
              _game.handleTap(details.localPosition);
            },
            child: GameWidget(game: _game),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _glassBtn(Icons.arrow_back_rounded, () => Navigator.pop(context)),
                      const Spacer(),
                      _scoreBadge('${_game.score}', Icons.star_rounded, Colors.amber),
                      const SizedBox(width: 10),
                      _scoreBadge('${_game.combo}x', Icons.local_fire_department_rounded, Colors.orange),
                    ],
                  ),
                  const Spacer(),
                  if (_game.started && !_game.gameOver) _buildTargetDisplay(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (!_game.started) _buildStartScreen(),
          if (_game.gameOver) _buildGameOver(),
        ],
      ),
    );
  }

  Widget _buildTargetDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
            child: const Text('🎯', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('حباب ${_game.targetLabel} را بترکان!', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              Text('هر ۳۰ امتیاز یا ${(_game.mode == BubbleMode.letters ? 2 : 2)} ترکاندن = هدف جدید', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.soft),
            child: Text(_game.targetEmoji, style: const TextStyle(fontSize: 26, height: 1)),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildStartScreen() {
    return Container(
      color: Colors.black.withOpacity(0.65),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FandoghiPremium(size: 90, mood: FandoghiMood.excited, showParticles: true).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text('حباب‌ترکان 🫧', style: AppFonts.vazirmatn(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: Colors.white24)),
                  child: Text('ترکیدن زنجیره‌ای + تلفظ فندقی 🎤', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                Text('حباب‌های درست رو بترکون!\nحواست به حباب‌های اشتباه باشه — زنجیره‌ای می‌ترکن!', textAlign: TextAlign.center, style: AppFonts.vazirmatn(fontSize: 15, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600, height: 1.6)).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 28),
                _startButton('حروف الفبا 🔤', () => _game.startGame(BubbleMode.letters)),
                const SizedBox(height: 10),
                _startButton('اعداد 🔢', () => _game.startGame(BubbleMode.numbers)),
                const SizedBox(height: 10),
                _startButton('رنگ‌ها 🎨', () => _game.startGame(BubbleMode.colors)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _miniBadge('⭐', 'امتیاز'),
                    const SizedBox(width: 8),
                    _miniBadge('🔥', 'کمبو'),
                    const SizedBox(width: 8),
                    _miniBadge('🫧', 'زنجیره'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniBadge(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: Colors.white24)),
      child: Row(children: [Text(emoji, style: const TextStyle(fontSize: 12)), const SizedBox(width: 4), Text(label, style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))]),
    );
  }

  Widget _startButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: () {
        if (canStartPlay(context)) onTap();
      },
      child: Text(text,
        style: AppFonts.balooBhaijaan2(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildGameOver() {
    final isWin = _game.score >= 100;
    final stars = _game.score >= 150 ? 3 : _game.score >= 80 ? 2 : _game.score >= 40 ? 1 : 0;
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FandoghiPremium(size: 100, mood: isWin ? FandoghiMood.celebrating : FandoghiMood.happy, showParticles: isWin).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(isWin ? 'قهرمان حباب‌ها! 🏆' : 'آفرین! 🎉', style: AppFonts.vazirmatn(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, size: 32, color: i < stars ? const Color(0xFFFFD700) : Colors.white24)
                      .animate(delay: (i * 120).ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut),
                )),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: Colors.white24)),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadii.pill)), child: Row(children: [const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16), const SizedBox(width: 4), Text('${_game.score}', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white))])),
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadii.pill)), child: Row(children: [const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 16), const SizedBox(width: 4), Text('${_game.bestCombo}x کمبو', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('زنجیره‌ای ترکید! 🫧✨', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (canStartPlay(context)) {
                      _game.startGame(_game.mode);
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  label: Text('دوباره بترکان 🔄', style: AppFonts.vazirmatn(fontSize: 16, fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: Text('برگشت به خانه', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 44, height: 44,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.2))),
        child: Icon(icon, color: Colors.white, size: 22)),
    );
  }

  Widget _scoreBadge(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.2))),
      child: Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 6), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))]),
    );
  }
}

// ═══════════════════════════════════════════════
// 🎮 FLAME GAME ENGINE
// ═══════════════════════════════════════════════
enum BubbleMode { letters, numbers, colors }

class BubblePopFlameGame extends FlameGame {
  final VoidCallback onUpdate;
  final String? stageId;
  final int? stageNumber;

  int score = 0;
  int combo = 0;
  int bestCombo = 0;
  int lives = 5;
  bool gameOver = false;
  bool started = false;
  BubbleMode mode = BubbleMode.letters;

  String targetEmoji = '';
  String targetLabel = '';
  String _targetKey = '';
  // چند ترکاندن درست = عوض شدن هدف.
  int _correctHitsOnTarget = 0;
  // تعداد هدف‌های فعلی که باید درست بزنیم تا عوض شود.
  int _hitsRequiredForNext = 2;
  int _targetsCompleted = 0;

  double _spawnTimer = 0;
  double _spawnInterval = 1.5;
  double _gameTime = 0;
  final _rng = Random();
  final List<_BubbleData> _bubblePool = [];
  int _nextTargetScore = 50;

  BubblePopFlameGame({
    required this.onUpdate,
    this.stageId,
    this.stageNumber,
  });

  void startGame(BubbleMode m) {
    mode = m;
    score = 0; combo = 0; bestCombo = 0; lives = 5;
    gameOver = false; started = true;
    _gameTime = 0; _spawnTimer = 0; _spawnInterval = 1.5;
    _targetsCompleted = 0;
    _targetKey = '';
    _nextTargetScore = 30; // هدف هر ۳۰ امتیاز عوض می‌شود تا تنوع بیشتر شود

    children.whereType<_Bubble>().toList().forEach((c) => c.removeFromParent());
    children.whereType<_PopParticle>().toList().forEach((c) => c.removeFromParent());
    _pickTarget();
    final modeName = switch (mode) {
      BubbleMode.letters => 'حروف',
      BubbleMode.numbers => 'اعداد',
      BubbleMode.colors => 'رنگ‌ها',
    };
    FandoghiCoach.instruction('آماده‌ای؟ حباب‌های درستِ $modeName را بترکان! من حواسم هست 🌰');
    onUpdate();
  }

  void _pickTarget() {
    // اطمینان از اینکه هدف جدید با هدف قبلی فرق می‌کند.
    String? previousKey = _targetKey.isEmpty ? null : _targetKey;
    int attempts = 0;
    const maxAttempts = 20;

    switch (mode) {
      case BubbleMode.letters:
        const letters = ['ا', 'ب', 'پ', 'ت', 'ث', 'ج', 'چ', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'ژ', 'س', 'ش'];
        do {
          _targetKey = letters[_rng.nextInt(letters.length)];
          attempts++;
        } while (previousKey != null && _targetKey == previousKey && attempts < maxAttempts);
        targetEmoji = _targetKey;
        targetLabel = 'حرف';
        _bubblePool
          ..clear()
          ..addAll(letters.map((l) => _BubbleData(l, l == _targetKey, _letterColor(l))));
        break;
      case BubbleMode.numbers:
        // اعداد ۱ تا ۱۵ برای تنوع بیشتر.
        final numbers = List.generate(15, (i) => '${i + 1}');
        do {
          _targetKey = numbers[_rng.nextInt(numbers.length)];
          attempts++;
        } while (previousKey != null && _targetKey == previousKey && attempts < maxAttempts);
        targetEmoji = _targetKey;
        targetLabel = 'عدد';
        _bubblePool
          ..clear()
          ..addAll(numbers.map((n) => _BubbleData(n, n == _targetKey, _numberColor(n))));
        break;
      case BubbleMode.colors:
        const colorNames = ['قرمز', 'آبی', 'سبز', 'زرد', 'بنفش', 'نارنجی', 'صورتی', 'قهوه‌ای'];
        const colorEmojis = ['🔴', '🔵', '🟢', '🟡', '🟣', '🟠', '🩷', '🟤'];
        const colorValues = ['red', 'blue', 'green', 'yellow', 'purple', 'orange', 'pink', 'brown'];
        int idx;
        do {
          idx = _rng.nextInt(colorNames.length);
          attempts++;
        } while (previousKey != null && colorValues[idx] == previousKey && attempts < maxAttempts);
        _targetKey = colorValues[idx];
        targetEmoji = colorEmojis[idx];
        targetLabel = 'رنگ ${colorNames[idx]}';
        _bubblePool
          ..clear()
          ..addAll(List.generate(colorNames.length, (i) => _BubbleData(colorEmojis[i], i == idx, _colorFromName(colorValues[i]))));
        break;
    }
    // شمارنده‌ی هدف جدید
    _correctHitsOnTarget = 0;
    // تعداد درست‌های لازم برای عوض شدن هدف، با پیشرفت بازی بیشتر می‌شود.
    _hitsRequiredForNext =
        (1 + _targetsCompleted ~/ 2).clamp(1, 4).toInt();
  }

  Color _letterColor(String l) {
    const colors = [Color(0xFFE040FB), Color(0xFF40C4FF), Color(0xFF69F0AE), Color(0xFFFFD740), Color(0xFFFF8A65), Color(0xFFE57373), Color(0xFF81C784), Color(0xFF64B5F6), Color(0xFFBA68C8), Color(0xFFFFB74D)];
    return colors[l.codeUnitAt(0) % colors.length];
  }

  Color _numberColor(String n) {
    const colors = [Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF43A047), Color(0xFFFDD835), Color(0xFF8E24AA), Color(0xFFFF6D00), Color(0xFF00ACC1), Color(0xFF3949AB), Color(0xFFD81B60), Color(0xFF00897B)];
    return colors[int.parse(n) % colors.length];
  }

  Color _colorFromName(String name) {
    switch (name) {
      case 'red': return const Color(0xFFE53935);
      case 'blue': return const Color(0xFF1E88E5);
      case 'green': return const Color(0xFF43A047);
      case 'yellow': return const Color(0xFFFDD835);
      case 'purple': return const Color(0xFF8E24AA);
      case 'orange': return const Color(0xFFFF6D00);
      case 'pink': return const Color(0xFFEC407A);
      case 'brown': return const Color(0xFF795548);
      default: return Colors.grey;
    }
  }

  void handleTap(Offset screenPos) {
    if (!started || gameOver) return;
    final tapPos = Vector2(screenPos.dx, screenPos.dy);
    final tapped = children.whereType<_Bubble>().where((b) => (b.position - tapPos).length < b.radius + 15).toList();
    if (tapped.isNotEmpty) {
      tapped.sort((a, b) => (a.position - tapPos).length.compareTo((b.position - tapPos).length));
      tapped.first.pop();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!started || gameOver) return;
    _gameTime += dt;
    _spawnTimer += dt;

    final level = 1 + (_gameTime / 20).floor();
    _spawnInterval = (1.5 - level * 0.1).clamp(0.5, 1.5).toDouble();

    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnBubble();
    }

    if (lives <= 0) _finishGame();
  }

  void _finishGame() {
    if (gameOver) return;
    gameOver = true;
    GameData.addCoins(score ~/ 2);
    GameData.addStars(score ~/ 10);
    GameData.updateHighScore(score, 'quiz');
    if (stageId != null && score >= 50) {
      GameData.completeStage(stageId!, stageNumber: stageNumber);
    }
    if (score >= 50) {
      unawaited(AudioService.win());
    } else {
      unawaited(AudioService.lose());
    }
    FandoghiCoach.reward(
      score >= 50
          ? 'چه مسابقه‌ای بود! امتیازت عالی شد؛ فندقی بهت افتخار می‌کند 🏆'
          : 'خسته نباشی! با چند تمرین دیگر رکوردت را بهتر می‌کنی 💪',
    );
    onUpdate();
  }

  void _spawnBubble() {
    if (size.x < 80 || _bubblePool.isEmpty) return;
    final data = _bubblePool[_rng.nextInt(_bubblePool.length)];
    final x = 40.0 + _rng.nextDouble() * (size.x - 80);
    final speed = 50.0 + _rng.nextDouble() * 40 + (_gameTime / 10);
    final wobble = _rng.nextDouble() * 2 - 1;
    add(_Bubble(data: data, x: x, speed: speed, wobble: wobble, gameSize: size,
      onPop: (isCorrect) => _onBubblePop(isCorrect),
      onMiss: () => _onBubbleMiss(data.isTarget)));
  }

  void _onBubblePop(bool isCorrect) {
    GameData.recordAnswer(
      correct: isCorrect,
      skill: mode == BubbleMode.letters
          ? 'alphabet'
          : mode == BubbleMode.numbers
              ? 'counting'
              : 'colors',
    );
    if (isCorrect) {
      FandoghiCoach.correct('ترکاندی! این حباب هدف بود 🫧🌟');
      unawaited(AudioService.bubble());
      unawaited(AudioService.correct());
      combo++;
      if (combo > bestCombo) bestCombo = combo;
      score += 10 + (combo > 3 ? combo * 2 : 0);
      if (mode == BubbleMode.letters) GameData.progressMission('alphabet');
      if (mode == BubbleMode.colors) GameData.progressMission('colors');
      HapticFeedback.lightImpact();
      // فاز ۳۲: ترکیدن زنجیره‌ای حباب‌های هم‌ارزش (بدون امتیاز اضافه)
      children.whereType<_Bubble>().toList().forEach((bubble) {
        if (bubble.data.display == targetEmoji) bubble.popVisual();
      });
      // فاز ۳۲: تلفظ هدف توسط فندقی
      switch (mode) {
        case BubbleMode.letters:
          unawaited(AudioService.pronounceLetter(_targetKey));
        case BubbleMode.numbers:
          final n = int.tryParse(_targetKey);
          if (n != null) {
            unawaited(AudioService.speakNumber(n));
          } else {
            unawaited(AudioService.speak(_targetKey));
          }
        case BubbleMode.colors:
          unawaited(AudioService.speak(targetLabel));
      }
      // شمارش ترکاندن‌های درست روی هدف فعلی
      _correctHitsOnTarget++;
      // شرط اول: چند ترکاندن درست پشت سر هم = عوض شدن هدف (تجربه‌ی متنوع)
      // شرط دوم: هر ۳۰ امتیاز هم هدف عوض شود (برای بازی طولانی)
      final byHits = _correctHitsOnTarget >= _hitsRequiredForNext;
      final byScore = score >= _nextTargetScore;
      if (byHits || byScore) {
        if (byScore) _nextTargetScore += 30;
        _targetsCompleted++;
        // حباب‌های قبلی مربوط به هدف قدیمی هستند؛ حذف‌شان می‌کنیم تا
        // بچه با دیدن حباب‌های متفرقه گیج نشود.
        children.whereType<_Bubble>().toList().forEach((bubble) {
          bubble.removeFromParent();
        });
        _pickTarget();
        FandoghiCoach.instruction('هدف عوض شد! حالا دنبال ${targetEmoji} بگرد 🌰');
      }
    } else {
      FandoghiCoach.judge('اوه! این حباب هدف نبود؛ فندقی می‌گوید با دقت‌تر نگاه کن 👀');
      unawaited(AudioService.bubble());
      unawaited(AudioService.wrong());
      combo = 0;
      lives--;
      HapticFeedback.heavyImpact();
    }
    if (lives <= 0) _finishGame();
    onUpdate();
  }

  void _onBubbleMiss(bool wasTarget) {
    if (!wasTarget) return;
    FandoghiCoach.judge('حباب هدف فرار کرد! دفعه بعد زودتر بترکانش 🫧');
    unawaited(AudioService.wrong());
    GameData.recordAnswer(correct: false);
    combo = 0;
    lives--;
    HapticFeedback.heavyImpact();
    if (lives <= 0) _finishGame();
    onUpdate();
  }
}

class _BubbleData {
  final String display;
  final bool isTarget;
  final Color color;
  _BubbleData(this.display, this.isTarget, this.color);
}

class _Bubble extends PositionComponent {
  final _BubbleData data;
  final double speed, wobble;
  final Vector2 gameSize;
  final void Function(bool) onPop;
  final VoidCallback onMiss;
  double _time = 0, _baseX = 0, radius = 32;
  bool _popped = false, _popping = false;
  double _popTime = 0, _scale = 1.0;

  _Bubble({required this.data, required double x, required this.speed, required this.wobble, required this.gameSize, required this.onPop, required this.onMiss}) : _baseX = x {
    position = Vector2(x, -64);
    radius = 28 + Random().nextDouble() * 12;
    size = Vector2.all(radius * 2);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_popping) {
      _popTime += dt;
      _scale = 1.0 + _popTime * 3;
      if (_popTime > 0.2) { removeFromParent(); return; }
    } else {
      position.y += speed * dt;
      position.x = _baseX + sin(_time * 2 + wobble * 5) * 20;
      if (position.y > gameSize.y + radius * 2) { onMiss(); removeFromParent(); }
    }
  }

  void pop() {
    if (_popped) return;
    _popped = true; _popping = true;
    parent?.add(_PopParticle(position: position.clone(), color: data.color));
    onPop(data.isTarget);
  }

  /// فاز ۳۲: ترکیدن زنجیره‌ای — فقط بصری، بدون احتساب امتیاز.
  void popVisual() {
    if (_popped) return;
    _popped = true;
    _popping = true;
    parent?.add(_PopParticle(position: position.clone(), color: data.color));
  }

  @override
  void render(Canvas canvas) {
    final alpha = _popping ? (1.0 - _popTime / 0.2).clamp(0.0, 1.0).toDouble() : 1.0;
    canvas.save();
    canvas.translate(radius, radius);
    canvas.scale(_scale);

    canvas.drawCircle(const Offset(3, 3), radius, Paint()..color = Colors.black.withOpacity(0.1 * alpha));
    canvas.drawCircle(Offset.zero, radius, Paint()
      ..shader = RadialGradient(center: const Alignment(-0.3, -0.3), colors: [data.color.withOpacity(0.9 * alpha), data.color.withOpacity(0.6 * alpha)])
        .createShader(Rect.fromCircle(center: Offset.zero, radius: radius)));
    canvas.drawOval(Rect.fromCenter(center: Offset(-radius * 0.25, -radius * 0.3), width: radius * 0.5, height: radius * 0.35),
      Paint()..color = Colors.white.withOpacity(0.35 * alpha));
    canvas.drawCircle(Offset.zero, radius, Paint()..color = Colors.white.withOpacity(0.3 * alpha)..style = PaintingStyle.stroke..strokeWidth = 2);

    if (!_popping) {
      final tp = TextPainter(text: TextSpan(text: data.display, style: TextStyle(fontSize: data.display.length > 2 ? radius * 0.6 : radius * 0.85, fontWeight: FontWeight.w900, color: Colors.white)), textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    }
    canvas.restore();
  }
}

class _PopParticle extends PositionComponent {
  final Color color;
  double _time = 0;
  final List<_ParticleData> _particles = [];
  final _rng = Random();

  _PopParticle({required super.position, required this.color}) {
    anchor = Anchor.center;
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + _rng.nextDouble() * 0.5;
      final speed = 80.0 + _rng.nextDouble() * 120;
      _particles.add(_ParticleData(vx: cos(angle) * speed, vy: sin(angle) * speed, size: 3 + _rng.nextDouble() * 4, rotation: _rng.nextDouble() * 2 * pi));
    }
  }

  @override
  void update(double dt) { super.update(dt); _time += dt; if (_time > 0.5) removeFromParent(); }

  @override
  void render(Canvas canvas) {
    final alpha = (1.0 - _time / 0.5).clamp(0.0, 1.0).toDouble();
    for (final p in _particles) {
      final x = p.vx * _time;
      final y = p.vy * _time + 100 * _time * _time;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + _time * 3);
      final paint = Paint()..color = color.withOpacity(alpha);
      canvas.drawCircle(Offset.zero, p.size * alpha, paint);
      canvas.restore();
    }
  }
}

class _ParticleData {
  final double vx, vy, size, rotation;
  _ParticleData({required this.vx, required this.vy, required this.size, required this.rotation});
}
