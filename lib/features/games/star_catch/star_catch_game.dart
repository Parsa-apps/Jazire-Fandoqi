import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_colors.dart';
import '../../../app/design_tokens.dart';
import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/particle_celebration.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ═══════════════════════════════════════════════
/// ⭐ STAR CATCH GAME — Flame Engine Demo
/// Catch falling stars & letters with a basket
/// ═══════════════════════════════════════════════
class StarCatchGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const StarCatchGame({
    super.key,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<StarCatchGame> createState() => _StarCatchState();
}

class _StarCatchState extends State<StarCatchGame> {
  late StarCatchFlameGame _game;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    _game = StarCatchFlameGame(
      stageId: widget.stageId,
      stageNumber: widget.stageNumber,
      onScore: () {
        if (mounted) setState(() {});
      },
      onCelebrate: () {
        if (!mounted) return;
        setState(() => _showCelebration = true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _showCelebration = false);
        });
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.instruction(
          'ستاره‌ها را با سبد بگیر و از بمب‌ها دوری کن؛ من داور مسابقه‌ام ⭐',
        );
      }
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Flame game with drag wrapper
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (_game.started && !_game.gameOver) {
                _game.moveBasket(details.globalPosition.dx);
              }
            },
            child: GameWidget(game: _game),
          ),
          
          // UI overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ردیف بالا: دکمه برگشت، امتیاز، جان
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _glassBtn(Icons.arrow_back_rounded, () => Navigator.pop(context)),
                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              '${_game.score}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lives - ✅ فیکس عمیق فاز ۳۳: از ۳ به ۵ قلب (چون logic تا ۵ می‌رود)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: List.generate(5, (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              i < _game.lives ? '❤️' : '🖤',
                              style: const TextStyle(fontSize: 18),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // ردیف پایین: نمایش هدف فعلی
                  if (_game.started && !_game.gameOver)
                    _buildTargetHud(),
                ],
              ),
            ),
          ),
          
          // Game over overlay
          if (_game.gameOver) _buildGameOver(),
          
          // Celebration particles
          ParticleCelebration(trigger: _showCelebration),
          
          // Start screen
          if (!_game.started) _buildStartScreen(),
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
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildTargetHud() {
    final remaining = _game.catchesRequiredForNext - _game.correctCatchesOnTarget;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.amber.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'فقط ${_game.targetEmoji} را بگیر!',
              style: AppFonts.balooBhaijaan2(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (remaining > 1) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$remaining',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FandoghiPremium(size: 90, mood: FandoghiMood.excited, showParticles: true).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text(
                  'ستاره‌گیری',
                  style: AppFonts.balooBhaijaan2(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'ستاره‌ها رو با سبد بگیر!\nاز آیتم‌های قرمز دوری کن!',
                  textAlign: TextAlign.center,
                  style: AppFonts.balooBhaijaan2(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    if (canStartPlay(context)) {
                      _game.startGame();
                      setState(() {});
                    }
                  },
                  child: Text(
                    'شروع بازی! 🚀',
                    style: AppFonts.balooBhaijaan2(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: _glassBtn(
            Icons.arrow_back_rounded,
            () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOver() {
    final stars = _game.score >= 80 ? 3 : _game.score >= 40 ? 2 : _game.score >= 15 ? 1 : 0;
    final isWin = _game.score >= 40;
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            FandoghiPremium(size: 96, mood: isWin ? FandoghiMood.celebrating : FandoghiMood.happy, showParticles: isWin).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, size: 32, color: i < stars ? const Color(0xFFFFD700) : Colors.white24).animate(delay: (i * 100).ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut))),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 20),
            Text(
              'بازی تموم شد!',
              style: AppFonts.balooBhaijaan2(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'امتیاز: ${_game.score}',
              style: AppFonts.balooBhaijaan2(
                fontSize: 24,
                color: Colors.amber,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (canStartPlay(context)) {
                      _game.startGame();
                      setState(() {});
                    }
                  },
                  child: Text(
                    'دوباره 🔄',
                    style: AppFonts.balooBhaijaan2(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'برگرد 🏠',
                    style: AppFonts.balooBhaijaan2(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
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
}

// ═══════════════════════════════════════════════
// 🎮 FLAME GAME ENGINE
// ═══════════════════════════════════════════════
class StarCatchFlameGame extends FlameGame {
  final VoidCallback onScore;
  final VoidCallback onCelebrate;
  final String? stageId;
  final int? stageNumber;

  int score = 0;
  int lives = 3;
  int combo = 0;
  bool gameOver = false;
  bool started = false;

  late _Basket _basket;
  final _rng = Random();
  double _spawnTimer = 0;
  double _spawnInterval = 1.2;
  double _gameTime = 0;

  /// آیتم هدف فعلی که بچه باید بگیرد. هر چند موفقیت عوض می‌شود.
  String targetEmoji = '⭐';
  String targetLabel = 'ستاره';
  // چند گرفتن درست پشت سر هم = عوض شدن هدف.
  int correctCatchesOnTarget = 0;
  int catchesRequiredForNext = 3;
  int _targetsCompleted = 0;

  StarCatchFlameGame({
    required this.onScore,
    required this.onCelebrate,
    this.stageId,
    this.stageNumber,
  });

  void startGame() {
    score = 0;
    lives = 3;
    combo = 0;
    gameOver = false;
    started = true;
    _spawnInterval = 1.2;
    _gameTime = 0;
    _spawnTimer = 0;
    correctCatchesOnTarget = 0;
    _targetsCompleted = 0;

    // Remove old items
    children.whereType<_FallingItem>().toList().forEach((c) => c.removeFromParent());
    children.whereType<_Basket>().toList().forEach((c) => c.removeFromParent());

    // Add basket
    _basket = _Basket();
    _basket.position = Vector2(
      max(40, size.x / 2),
      max(40, size.y - 80),
    );
    add(_basket);

    _pickTarget();
    unawaited(AudioService.go());
    onScore();
  }

  /// انتخاب آیتم هدف جدید، متفاوت از هدف قبلی.
  void _pickTarget() {
    // ترکیب آیتم‌های خوب (نه بمب). بمب همیشه بد است.
    const goodItems = ['⭐', '🌟', '✨', '💛', '🔮', '🍎', '🌸', '🦋'];
    const goodLabels = ['ستاره', 'ستاره‌ی درخشان', 'درخشش', 'قلبِ زرد', 'کریستال', 'سیب قرمز', 'گل بهاری', 'پروانه'];
    String previous = targetEmoji;
    int attempts = 0;
    do {
      final idx = _rng.nextInt(goodItems.length);
      targetEmoji = goodItems[idx];
      targetLabel = goodLabels[idx];
      attempts++;
    } while (targetEmoji == previous && attempts < 8);
    correctCatchesOnTarget = 0;
    // با پیشرفت، تعداد لازم برای تغییر هدف بیشتر می‌شود.
    catchesRequiredForNext =
        (3 + _targetsCompleted ~/ 3).clamp(3, 7).toInt();
  }

  void moveBasket(double screenX) {
    if (!started || gameOver) return;
    final maxX = max(40.0, size.x - 40);
    _basket.position.x = screenX.clamp(40.0, maxX).toDouble();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!started || gameOver) return;
    
    _gameTime += dt;
    _spawnTimer += dt;
    
    // Increase difficulty
    final level = 1 + (_gameTime / 15).floor();
    _spawnInterval = (1.2 - level * 0.08).clamp(0.4, 1.2).toDouble();
    
    // Spawn items
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnItem(level);
    }
    
    // Check for missed items
    children
        .whereType<_FallingItem>()
        .where((item) => item.position.y > size.y + 50)
        .toList()
        .forEach((item) {
      if (item.isBad) {
        // بمب‌ها اگه از پایین رد بشن، هیچ اتفاقی نمی‌افتد
      } else if (item.emoji == targetEmoji) {
        // فقط هدف اگه جا بمونه، life کم می‌کنه
        FandoghiCoach.judge('$targetLabel $targetEmoji جا ماند؛ حواست به سبد باشد ⭐');
        unawaited(AudioService.wrong());
        GameData.recordAnswer(correct: false, skill: 'counting');
        lives--;
        HapticFeedback.heavyImpact();
        if (lives <= 0) _finishGame();
      }
      // آیتم خوب غیرهدف: هیچ مجازاتی ندارد
      item.removeFromParent();
    });
    
    // Check collisions
    children.whereType<_FallingItem>().where((item) => !item.isRemoving).toList().forEach((item) {
      final dx = (item.position.x - _basket.position.x).abs();
      final dy = (item.position.y - _basket.position.y).abs();
      if (dx < 45 && dy < 35) {
        _onCatch(item);
      }
    });
  }

  void _spawnItem(int level) {
    if (size.x < 80) return;
    final x = _rng.nextDouble() * (size.x - 80) + 40;
    final speed = 130.0 + level * 18 + _rng.nextDouble() * 50;
    final isBad = _rng.nextDouble() < (0.2 + level * 0.02).clamp(0.2, 0.65);
    
    if (isBad) {
      add(_FallingItem(
        x: x,
        speed: speed,
        emoji: '💥',
        isBad: true,
        itemSize: 35,
      ));
    } else {
      // آیتم‌های خوب + پاورآپ‌های جدید
      final rand = _rng.nextDouble();
      if (rand < 0.08) {
        // پاورآپ قلب (جان اضافی)
        add(_FallingItem(x: x, speed: speed * 0.7, emoji: '❤️', isBad: false, itemSize: 36, isPowerUp: true, powerType: 'heart'));
      } else if (rand < 0.15) {
        // پاورآپ امتیاز دوبل
        add(_FallingItem(x: x, speed: speed * 0.85, emoji: '💎', isBad: false, itemSize: 34, isPowerUp: true, powerType: 'double'));
      } else {
        final items = ['⭐', '🌟', '✨', '💛', '🔮', '🍎', '🌸', '🦋'];
        add(_FallingItem(
          x: x,
          speed: speed,
          emoji: items[_rng.nextInt(items.length)],
          isBad: false,
          itemSize: 32 + _rng.nextDouble() * 8,
        ));
      }
    }
  }

  void _onCatch(_FallingItem item) {
    if (gameOver) return;
    if (item.isBad) {
      FandoghiCoach.judge('اوه! این بمب بود، نه $targetLabel! با دقت‌تر بگیر 💥');
      unawaited(AudioService.wrong());
      lives--;
      GameData.recordAnswer(correct: false, skill: 'counting');
      HapticFeedback.heavyImpact();
      if (lives <= 0) _finishGame();
    } else if (item.isPowerUp) {
      // ===== پاورآپ‌های جدید =====
      if (item.powerType == 'heart') {
        lives = (lives + 1).clamp(1, 5);
        FandoghiCoach.reward('وای! قلب جادویی گرفتی! ❤️ جان اضافی!');
        unawaited(AudioService.unlock());
        HapticFeedback.mediumImpact();
      } else if (item.powerType == 'double') {
        score += 20;
        FandoghiCoach.correct('عالی! امتیاز دوبل! 💎');
        unawaited(AudioService.coin());
        HapticFeedback.lightImpact();
        if (score % 40 == 0) onCelebrate();
      }
    } else if (item.emoji == targetEmoji) {
      // آیتم درست = همان هدف فعلی
      FandoghiCoach.correct('$targetLabel را گرفتی! امتیاز برای قهرمان من ${item.emoji}🌟');
      unawaited(AudioService.star());
      unawaited(AudioService.correct());
      score += 10;
      combo++;
      GameData.recordAnswer(correct: true, skill: 'counting');
      HapticFeedback.lightImpact();
      correctCatchesOnTarget++;
      if (correctCatchesOnTarget >= catchesRequiredForNext) {
        // وقتی به تعداد لازم رسید، هدف عوض می‌شود
        _targetsCompleted++;
        _pickTarget();
        FandoghiCoach.instruction('هدف عوض شد! حالا فقط $targetEmoji را بگیر 🌰');
      }
      if (score % 50 == 0) onCelebrate();
    } else {
      // آیتم خوب ولی غیرهدف: فقط راهنمایی، بدون life کم
      FandoghiCoach.say(
        'این $targetLabel نبود؛ دنبال $targetEmoji بگرد 👀',
        mood: FandoghiMood.thinking,
        tone: FandoghiCoachTone.encouragement,
        duration: const Duration(seconds: 2),
      );
      score += 2; // امتیاز کم برای شرکت در بازی
      combo = 0; // کمبوی ناقص
      GameData.recordAnswer(correct: false, skill: 'counting');
      unawaited(AudioService.bubble());
      HapticFeedback.selectionClick();
    }
    item.removeFromParent();
    onScore();
  }

  void _finishGame() {
    if (gameOver) return;
    gameOver = true;
    GameData.addCoins(score);
    GameData.addStars(score ~/ 5);
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
          ? 'بازی تمام شد و رکورد درخشانی ساختی! فندقی داوری‌ات را تأیید می‌کند 🏆'
          : 'خسته نباشی! دفعه بعد ستاره‌های بیشتری می‌گیری 💪',
    );
    onScore();
  }
}

// ─── BASKET COMPONENT ─────────────────────────
class _Basket extends PositionComponent {
  _Basket() : super(anchor: Anchor.center, size: Vector2(80, 40));

  @override
  void render(Canvas canvas) {
    // Basket body
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD4A574), Color(0xFF8B6914)],
      ).createShader(const Rect.fromLTWH(-35, -15, 70, 40));
    
    final path = Path()
      ..moveTo(-35, -12)
      ..lineTo(35, -12)
      ..lineTo(30, 22)
      ..lineTo(-30, 22)
      ..close();
    
    canvas.drawPath(path, bodyPaint);
    
    // Basket rim
    final rimPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE8C99B), Color(0xFFA0722A)],
      ).createShader(const Rect.fromLTWH(-40, -18, 80, 10));
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-40, -18, 80, 10),
        const Radius.circular(6),
      ),
      rimPaint,
    );
    
    // Weave pattern
    final linePaint = Paint()
      ..color = const Color(0xFF6D4C41).withOpacity(0.4)
      ..strokeWidth = 1;
    
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(i * 13.0, -10),
        Offset(i * 11.0, 20),
        linePaint,
      );
    }
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(-32, -5.0 + i * 10),
        Offset(32, -5.0 + i * 10),
        linePaint,
      );
    }
  }
}

// ─── FALLING ITEM COMPONENT ───────────────────
class _FallingItem extends PositionComponent {
  final double speed;
  final String emoji;
  final bool isBad;
  final double itemSize;
  final double _rotation;
  final bool isPowerUp;
  final String? powerType;

  _FallingItem({
    required double x,
    required this.speed,
    required this.emoji,
    required this.isBad,
    required this.itemSize,
    this.isPowerUp = false,
    this.powerType,
  })  : _rotation = (Random().nextDouble() - 0.5) * 2,
        super(
          position: Vector2(x, -40),
          anchor: Anchor.center,
          size: Vector2.all(itemSize),
        );

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    angle += _rotation * dt;
  }

  @override
  void render(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: itemSize),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}
