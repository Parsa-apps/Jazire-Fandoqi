import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/game_data.dart';
import '../core/theme.dart';
import '../widgets/fandoghi.dart';
import '../widgets/common.dart';

/// نقشه جزیره جادویی - طراحی حرفه‌ای مثل تصویر تبلت
class StageMapScreen extends StatefulWidget {
  const StageMapScreen({super.key});
  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  final ScrollController _scrollCtrl = ScrollController();

  final List<_MagicStage> _stages = [
    _MagicStage(
      id: 's1',
      title: 'شروع ماجرا',
      emoji: '🌱',
      color: const Color(0xFF22C55E),
      game: 'الفبا',
      description: 'اولین قدم‌ها',
    ),
    _MagicStage(
      id: 's2',
      title: 'الفبا جادویی',
      emoji: '🔤',
      color: const Color(0xFFEC4899),
      game: 'الفبا',
      description: 'حروف و کلمات',
    ),
    _MagicStage(
      id: 's3',
      title: 'اعداد جادویی',
      emoji: '🔢',
      color: const Color(0xFF3B82F6),
      game: 'اعداد',
      description: 'ریاضی و شمارش',
    ),
    _MagicStage(
      id: 's4',
      title: 'رنگین‌کمان',
      emoji: '🌈',
      color: const Color(0xFFF59E0B),
      game: 'رنگ‌ها',
      description: 'رنگ‌ها و اشکال',
    ),
    _MagicStage(
      id: 's5',
      title: 'جنگل حیوانات',
      emoji: '🦁',
      color: const Color(0xFF8B5CF6),
      game: 'حیوانات',
      description: 'حیوانات و طبیعت',
    ),
    _MagicStage(
      id: 's6',
      title: 'شهر فکری',
      emoji: '🧠',
      color: const Color(0xFF06B6D4),
      game: 'حافظه',
      description: 'بازی‌های حافظه',
    ),
    _MagicStage(
      id: 's7',
      title: 'آسمان دانش',
      emoji: '🚀',
      color: const Color(0xFF6366F1),
      game: 'فضا',
      description: 'فضا و ستاره‌ها',
    ),
    _MagicStage(
      id: 's8',
      title: 'قصر قهرمان',
      emoji: '🏰',
      color: const Color(0xFFF43F5E),
      game: 'مسابقه',
      description: 'چالش نهایی',
    ),
  ];

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0EA5E9),
              Color(0xFF22D3EE),
              Color(0xFF4ADE80),
              Color(0xFF16A34A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMagicalPath()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const FandoghiMini(size: 34),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'نقشه جزیره جادویی',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 5),
                Text(
                  '${GameData.completedStageCount}/${_stages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicalPath() {
    return Stack(
      children: [
        // Background path
        Positioned.fill(
          child: CustomPaint(
            painter: _PathPainter(),
          ),
        ),

        // Stages
        ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          itemCount: _stages.length,
          itemBuilder: (context, index) {
            final stage = _stages[index];
            final completed = GameData.isStageCompleted(stage.id);
            final current = index == GameData.completedStageCount;
            final locked = index > GameData.completedStageCount;

            final isLeft = index % 2 == 0;

            return Padding(
              padding: EdgeInsets.only(
                left: isLeft ? 20 : 120,
                right: isLeft ? 120 : 20,
                bottom: 32,
              ),
              child: _buildStageCard(
                stage: stage,
                isCompleted: completed,
                isCurrent: current,
                isLocked: locked,
                isLeft: isLeft,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStageCard({
    required _MagicStage stage,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              if (isCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${stage.title} قبلاً تکمیل شده!'),
                    backgroundColor: stage.color,
                  ),
                );
              } else {
                Navigator.pushNamed(context, '/game/${stage.game}');
                GameData.completeStage(stage.id);
                setState(() {});
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 170,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLocked
                ? [Colors.grey.shade400, Colors.grey.shade600]
                : isCompleted
                    ? [stage.color, stage.color.withOpacity(0.85)]
                    : [Colors.white, Colors.white.withOpacity(0.95)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: isCurrent
                  ? stage.color.withOpacity(0.6)
                  : Colors.black.withOpacity(0.15),
              blurRadius: isCurrent ? 25 : 12,
              offset: const Offset(0, 8),
              spreadRadius: isCurrent ? 3 : 1,
            ),
          ],
          border: isCurrent
              ? Border.all(color: stage.color, width: 4)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isLocked ? '🔒' : stage.emoji,
                  style: const TextStyle(fontSize: 34),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isLocked || isCompleted
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        stage.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: isLocked || isCompleted
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ...List.generate(
                  3,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: isCompleted
                        ? Colors.amber
                        : Colors.grey.withOpacity(0.4),
                  ),
                ),
                const Spacer(),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: stage.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'شروع',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isCompleted)
                  const Icon(Icons.check_circle,
                      color: Colors.white, size: 18),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (80 * _stages.indexOf(stage)).ms).slideX(
            begin: isLeft ? -0.3 : 0.3,
          ),
    );
  }
}

class _MagicStage {
  final String id;
  final String title;
  final String emoji;
  final Color color;
  final String game;
  final String description;

  _MagicStage({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    required this.game,
    required this.description,
  });
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Winding magical path
    path.moveTo(size.width * 0.35, 40);
    path.quadraticBezierTo(
        size.width * 0.65, 120, size.width * 0.3, 200);
    path.quadraticBezierTo(
        size.width * 0.75, 290, size.width * 0.4, 370);
    path.quadraticBezierTo(
        size.width * 0.2, 460, size.width * 0.55, 550);
    path.quadraticBezierTo(
        size.width * 0.7, 640, size.width * 0.35, 730);
    path.quadraticBezierTo(
        size.width * 0.6, 820, size.width * 0.45, 920);

    canvas.drawPath(path, paint);

    // Decorative dots
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.6);
    for (int i = 0; i < 12; i++) {
      final t = i / 11;
      final offset = path.computeMetrics().first.getTangentForOffset(
          path.computeMetrics().first.length * t)!;
      canvas.drawCircle(offset.position, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}