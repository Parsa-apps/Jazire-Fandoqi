import 'dart:math' show cos, pi, sin;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ═══════════════════════════════════════════════════════════
/// 🔐 PARENT GATE — دروازه والدین پیشرفته
/// با سوال ریاضی و تشخیص هوشمند
/// ═══════════════════════════════════════════════════════════

class AdvancedParentGate extends StatefulWidget {
  final VoidCallback onApproved;
  final VoidCallback onCancelled;
  final int difficulty;

  const AdvancedParentGate({
    super.key,
    required this.onApproved,
    required this.onCancelled,
    this.difficulty = 1,
  });

  @override
  State<AdvancedParentGate> createState() => _AdvancedParentGateState();
}

class _AdvancedParentGateState extends State<AdvancedParentGate> {
  late int _num1;
  late int _num2;
  late String _operator;
  late int _answer;
  final _controller = TextEditingController();
  String _errorMessage = '';
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    if (widget.difficulty == 1) {
      _num1 = random % 10 + 1;
      _num2 = random % 10 + 1;
      _operator = '+';
      _answer = _num1 + _num2;
    } else if (widget.difficulty == 2) {
      _num1 = random % 15 + 5;
      _num2 = random % 10 + 1;
      _operator = '+';
      _answer = _num1 + _num2;
    } else {
      _num1 = random % 12 + 1;
      _num2 = random % 12 + 1;
      _operator = '×';
      _answer = _num1 * _num2;
    }
  }

  void _checkAnswer() {
    final input = _controller.text.trim();
    final persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    final englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    
    String normalized = input;
    for (var i = 0; i < persianDigits.length; i++) {
      normalized = normalized.replaceAll(persianDigits[i], englishDigits[i]);
    }

    if (int.tryParse(normalized) == _answer) {
      HapticFeedback.heavyImpact();
      widget.onApproved();
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        _attempts++;
        _errorMessage = 'جواب درست نیست! دوباره تلاش کن 💪';
        _controller.clear();
      });
      
      if (_attempts >= 3) {
        _generateQuestion();
        setState(() {
          _attempts = 0;
          _errorMessage = 'سوال جدید:';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 60,
                  color: Color(0xFF6C5CE7),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🔒 ورود به بخش والدین',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'برای حفاظت از فرزندتان، لطفاً این سوال را حل کنید:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F4FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '$_num1 $_operator $_num2 = ?',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: 'جواب رو اینجا بنویس...',
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF6C5CE7),
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _checkAnswer(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: widget.onCancelled,
                      child: const Text('انصراف'),
                    ),
                    ElevatedButton(
                      onPressed: _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'تایید ✓',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🎁 REWARD CHEST — صندوق جایزه متحرک
/// ═══════════════════════════════════════════════════════════

class RewardChest extends StatefulWidget {
  final int coins;
  final VoidCallback? onOpened;

  const RewardChest({
    super.key,
    this.coins = 50,
    this.onOpened,
  });

  @override
  State<RewardChest> createState() => _RewardChestState();
}

class _RewardChestState extends State<RewardChest>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isOpened = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openChest() {
    HapticFeedback.heavyImpact();
    setState(() => _isOpened = true);
    _controller.forward().then((_) {
      widget.onOpened?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isOpened ? null : _openChest,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              if (!_isOpened)
                Container(
                  width: 120 + sin(_controller.value * pi * 4) * 10,
                  height: 120 + sin(_controller.value * pi * 4) * 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              
              // Chest body
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateX(_controller.value * -0.5),
                child: Icon(
                  _isOpened
                      ? Icons.inventory_2_rounded
                      : Icons.auto_awesome,
                  size: 80,
                  color: _isOpened ? Colors.amber : Colors.orange,
                ),
              ),
              
              // Coins flying out
              if (_isOpened)
                ...List.generate(5, (index) {
                  final angle = (index / 5) * 2 * pi;
                  final distance = _controller.value * 80;
                  return Transform.translate(
                    offset: Offset(
                      cos(angle) * distance,
                      sin(angle) * distance - _controller.value * 50,
                    ),
                    child: const Text(
                      '💰',
                      style: TextStyle(fontSize: 24),
                    ),
                  );
                }),
              
              // Coin count
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${widget.coins}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 📊 SKILL RADAR CHART — نمودار راداری مهارت‌ها
/// نمایش مهارت‌های کودک به والدین
/// ═══════════════════════════════════════════════════════════

class SkillRadarChart extends StatelessWidget {
  final Map<String, double> skills;
  final double size;

  const SkillRadarChart({
    super.key,
    required this.skills,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: Text('هنوز مهارتی ثبت نشده'),
        ),
      );
    }

    final entries = skills.entries.toList();
    final count = entries.length;
    
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(
          skills: entries,
          count: count,
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> skills;
  final int count;

  _RadarChartPainter({required this.skills, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;

    // Draw background circles
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * i / 5, bgPaint);
    }

    // Draw axis lines
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi - pi / 2;
      final end = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawLine(center, end, bgPaint);
    }

    // Draw skill polygon
    final skillPaint = Paint()
      ..style = PaintingStyle.fill;

    for (var i = 0; i < skills.length; i++) {
      final value = skills[i].value.clamp(0.0, 1.0);
      final angle = (i / count) * 2 * pi - pi / 2;
      final distance = radius * value;
      
      final point = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      if (i == 0) {
        skillPaint.shader = LinearGradient(
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.5),
            const Color(0xFF00CEC9).withOpacity(0.5),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
        skillPaint.color = const Color(0xFF6C5CE7).withOpacity(0.3);
        canvas.drawPath(Path()..moveTo(point.dx, point.dy), skillPaint);
      } else {
        canvas.drawPath(
          Path()
            ..moveTo(skills[0].value, skills[0].value) // Placeholder
            ..lineTo(point.dx, point.dy),
          skillPaint,
        );
      }
    }

    // Draw skill points and labels
    for (var i = 0; i < count; i++) {
      final value = skills[i].value.clamp(0.0, 1.0);
      final angle = (i / count) * 2 * pi - pi / 2;
      final distance = radius * value;
      
      final point = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      // Draw point
      canvas.drawCircle(point, 6, Paint()..color = const Color(0xFF6C5CE7));
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);

      // Draw label
      final labelRadius = radius + 25;
      final labelPoint = Offset(
        center.dx + cos(angle) * labelRadius,
        center.dy + sin(angle) * labelRadius,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: skills[i].key,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3436),
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          labelPoint.dx - textPainter.width / 2,
          labelPoint.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
