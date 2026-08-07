import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/app_colors.dart';
import '../../../core/game_data.dart';
import '../../../core/play_limit.dart';

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

class _BubblePopState extends State<BubblePopGame> {
  late BubblePopFlameGame _game;

  @override
  void initState() {
    super.initState();
    _game = BubblePopFlameGame(
      stageId: widget.stageId,
      stageNumber: widget.stageNumber,
      onUpdate: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (details) {
              if (_game.started && !_game.gameOver) {
                _game.handleTap(details.localPosition);
              }
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text('حباب‌های ${_game.targetLabel} رو بترکون!',
            style: GoogleFonts.vazirmatn(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(_game.targetEmoji, style: const TextStyle(fontSize: 36)),
        ],
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
            const Text('🫧', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('حباب‌ترکان', style: GoogleFonts.vazirmatn(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 12),
            Text('حباب‌های درست رو بترکون!\nحواست به حباب‌های اشتباه باشه!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.white.withOpacity(0.85), height: 1.6)),
            const SizedBox(height: 40),
            _startButton('حروف الفبا 🔤', () => _game.startGame(BubbleMode.letters)),
            const SizedBox(height: 12),
            _startButton('اعداد 🔢', () => _game.startGame(BubbleMode.numbers)),
            const SizedBox(height: 12),
            _startButton('رنگ‌ها 🎨', () => _game.startGame(BubbleMode.colors)),
          ],
        ),
      ),
    );
  }

  Widget _startButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: () {
        if (canStartPlay(context)) onTap();
      },
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildGameOver() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_game.score >= 100 ? '🏆' : '🎉', style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(_game.score >= 100 ? 'قهرمان!' : 'آفرین!',
              style: GoogleFonts.vazirmatn(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 12),
            Text('امتیاز: ${_game.score}',
              style: const TextStyle(fontSize: 28, color: Colors.amber, fontWeight: FontWeight.bold)),
            Text('بهترین کمبو: ${_game.bestCombo}x',
              style: const TextStyle(fontSize: 18, color: Colors.orange)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    if (canStartPlay(context)) {
                      _game.startGame(_game.mode);
                      setState(() {});
                    }
                  },
                  child: const Text('دوباره 🔄', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('برگرد 🏠', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
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
    _nextTargetScore = 50;

    children.whereType<_Bubble>().toList().forEach((c) => c.removeFromParent());
    children.whereType<_PopParticle>().toList().forEach((c) => c.removeFromParent());
    _pickTarget();
    onUpdate();
  }

  void _pickTarget() {
    switch (mode) {
      case BubbleMode.letters:
        const letters = ['ا', 'ب', 'پ', 'ت', 'ث', 'ج', 'چ', 'ح', 'خ', 'د'];
        _targetKey = letters[_rng.nextInt(letters.length)];
        targetEmoji = _targetKey;
        targetLabel = 'حرف';
        _bubblePool..clear()..addAll(letters.map((l) => _BubbleData(l, l == _targetKey, _letterColor(l))));
        break;
      case BubbleMode.numbers:
        final numbers = List.generate(10, (i) => '${i + 1}');
        _targetKey = numbers[_rng.nextInt(numbers.length)];
        targetEmoji = _targetKey;
        targetLabel = 'عدد';
        _bubblePool..clear()..addAll(numbers.map((n) => _BubbleData(n, n == _targetKey, _numberColor(n))));
        break;
      case BubbleMode.colors:
        const colorNames = ['قرمز', 'آبی', 'سبز', 'زرد', 'بنفش', 'نارنجی'];
        const colorEmojis = ['🔴', '🔵', '🟢', '🟡', '🟣', '🟠'];
        const colorValues = ['red', 'blue', 'green', 'yellow', 'purple', 'orange'];
        final idx = _rng.nextInt(colorNames.length);
        _targetKey = colorValues[idx];
        targetEmoji = colorEmojis[idx];
        targetLabel = 'رنگ ${colorNames[idx]}';
        _bubblePool..clear()..addAll(List.generate(colorNames.length, (i) => _BubbleData(colorEmojis[i], i == idx, _colorFromName(colorValues[i]))));
        break;
    }
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
      combo++;
      if (combo > bestCombo) bestCombo = combo;
      score += 10 + (combo > 3 ? combo * 2 : 0);
      if (mode == BubbleMode.letters) GameData.progressMission('alphabet');
      if (mode == BubbleMode.colors) GameData.progressMission('colors');
      HapticFeedback.lightImpact();
      if (score >= _nextTargetScore) {
        _nextTargetScore += 50;
        // Existing bubbles belong to the previous target. Removing them is
        // less confusing than showing an old target after the HUD changes.
        children.whereType<_Bubble>().toList().forEach((bubble) {
          bubble.removeFromParent();
        });
        _pickTarget();
      }
    } else {
      combo = 0;
      lives--;
      HapticFeedback.heavyImpact();
    }
    if (lives <= 0) _finishGame();
    onUpdate();
  }

  void _onBubbleMiss(bool wasTarget) {
    if (!wasTarget) return;
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
