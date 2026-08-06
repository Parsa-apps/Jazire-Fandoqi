import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/app_colors.dart';
import '../../../core/game_data.dart';
import '../../../shared/widgets/particle_celebration.dart';

/// ═══════════════════════════════════════════════
/// ⭐ STAR CATCH GAME — Flame Engine Demo
/// Catch falling stars & letters with a basket
/// ═══════════════════════════════════════════════
class StarCatchGame extends StatefulWidget {
  const StarCatchGame({super.key});
  @override
  State<StarCatchGame> createState() => _StarCatchState();
}

class _StarCatchState extends State<StarCatchGame> {
  late StarCatchFlameGame _game;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _game = StarCatchFlameGame(
      onScore: () => setState(() {}),
      onCelebrate: () {
        setState(() => _showCelebration = true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _showCelebration = false);
        });
      },
    );
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
              child: Row(
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
                  // Lives
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: List.generate(3, (i) => Padding(
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

  Widget _buildStartScreen() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              'ستاره‌گیری',
              style: GoogleFonts.vazirmatn(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ستاره‌ها رو با سبد بگیر!\nاز آیتم‌های قرمز دوری کن!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.85),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                _game.startGame();
                setState(() {});
              },
              child: const Text(
                'شروع بازی! 🚀',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              'بازی تموم شد!',
              style: GoogleFonts.vazirmatn(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'امتیاز: ${_game.score}',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    _game.startGame();
                    setState(() {});
                  },
                  child: const Text(
                    'دوباره 🔄',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'برگرد 🏠',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
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
  
  int score = 0;
  int lives = 3;
  bool gameOver = false;
  bool started = false;
  
  late _Basket _basket;
  final _rng = Random();
  double _spawnTimer = 0;
  double _spawnInterval = 1.2;
  double _gameTime = 0;
  
  StarCatchFlameGame({required this.onScore, required this.onCelebrate});

  void startGame() {
    score = 0;
    lives = 3;
    gameOver = false;
    started = true;
    _spawnInterval = 1.2;
    _gameTime = 0;
    _spawnTimer = 0;
    
    // Remove old items
    children.whereType<_FallingItem>().toList().forEach((c) => c.removeFromParent());
    children.whereType<_Basket>().toList().forEach((c) => c.removeFromParent());
    
    // Add basket
    _basket = _Basket();
    _basket.position = Vector2(size.x / 2, size.y - 80);
    add(_basket);
    
    onScore();
  }

  void moveBasket(double screenX) {
    if (!started || gameOver) return;
    _basket.position.x = screenX.clamp(40.0, size.x - 40).toDouble();
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
    children.whereType<_FallingItem>().where((item) => item.position.y > size.y + 50).toList().forEach((item) {
      if (!item.isBad) {
        lives--;
        if (lives <= 0) {
          gameOver = true;
          GameData.addCoins(score);
          GameData.addStars(score ~/ 5);
          onScore();
        }
      }
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
    final x = _rng.nextDouble() * (size.x - 80) + 40;
    final speed = 130.0 + level * 18 + _rng.nextDouble() * 50;
    final isBad = _rng.nextDouble() < 0.2 + level * 0.02;
    
    if (isBad) {
      add(_FallingItem(
        x: x,
        speed: speed,
        emoji: '💥',
        isBad: true,
        itemSize: 35,
      ));
    } else {
      final items = ['⭐', '🌟', '✨', '💛', '🔮'];
      add(_FallingItem(
        x: x,
        speed: speed,
        emoji: items[_rng.nextInt(items.length)],
        isBad: false,
        itemSize: 32 + _rng.nextDouble() * 8,
      ));
    }
  }

  void _onCatch(_FallingItem item) {
    if (item.isBad) {
      lives--;
      HapticFeedback.heavyImpact();
      if (lives <= 0) {
        gameOver = true;
        GameData.addCoins(score);
        GameData.addStars(score ~/ 5);
      }
      onScore();
    } else {
      score += 10;
      HapticFeedback.lightImpact();
      GameData.recordCorrect();
      if (score % 50 == 0) onCelebrate();
      onScore();
    }
    item.removeFromParent();
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

  _FallingItem({
    required double x,
    required this.speed,
    required this.emoji,
    required this.isBad,
    required this.itemSize,
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
