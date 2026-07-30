import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/game_data.dart';
import '../core/theme.dart';
import '../widgets/fandoghi.dart';
import '../widgets/common.dart';

/// نقشه مرحله‌ها - نمایش پیشرفت کودک در مراحل مختلف
class StageMapScreen extends StatefulWidget {
  const StageMapScreen({super.key});
  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  final ScrollController _scrollCtrl = ScrollController();

  final List<_StageData> _stages = [
    _StageData(id: 's1', title: 'شروع ماجرا', emoji: '🌱', stars: 3,
        description: 'اولین قدم‌ها', color: const Color(0xFF4CAF50)),
    _StageData(id: 's2', title: 'حروف الفبا', emoji: '🔤', stars: 3,
        description: 'یادگیری حروف', color: const Color(0xFF9C27B0)),
    _StageData(id: 's3', title: 'اعداد جادویی', emoji: '🔢', stars: 3,
        description: 'شمارش و جمع', color: const Color(0xFF2196F3)),
    _StageData(id: 's4', title: 'رنگین‌کمان', emoji: '🌈', stars: 3,
        description: 'رنگ‌ها و اشکال', color: const Color(0xFFFF9800)),
    _StageData(id: 's5', title: 'جنگل حیوانات', emoji: '🦁', stars: 3,
        description: 'حیوانات و طبیعت', color: const Color(0xFF795548)),
    _StageData(id: 's6', title: 'شهر فکری', emoji: '🧠', stars: 3,
        description: 'بازی‌های حافظه', color: const Color(0xFFE91E63)),
    _StageData(id: 's7', title: 'آسمان دانش', emoji: '🚀', stars: 3,
        description: 'فضا و ستاره‌ها', color: const Color(0xFF3F51B5)),
    _StageData(id: 's8', title: 'قصر قهرمان', emoji: '🏰', stars: 3,
        description: 'چالش نهایی', color: const Color(0xFFFFD700)),
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
              Color(0xFF1A237E),
              Color(0xFF283593),
              Color(0xFF3949AB),
              Color(0xFF5C6BC0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMap()),
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
          const FandoghiMini(size: 32),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'نقشه مرحله‌ها',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${GameData.completedStageCount}/${_stages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _stages.length,
      itemBuilder: (context, i) {
        final stage = _stages[i];
        final isCompleted = GameData.isStageCompleted(stage.id);
        final isCurrent = i == GameData.completedStageCount;
        final isLocked = i > GameData.completedStageCount;
        final isEven = i % 2 == 0;

        return _buildStageNode(
          stage: stage,
          index: i,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLocked: isLocked,
          isEven: isEven,
          isLast: i == _stages.length - 1,
        );
      },
    );
  }

  Widget _buildStageNode({
    required _StageData stage,
    required int index,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required bool isEven,
    required bool isLast,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: isEven
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (isEven) const SizedBox(width: 20),
            if (!isEven) const Spacer(),
            BounceBtn(
              onTap: isLocked
                  ? () {}
                  : () => _onStageTap(stage, isCompleted),
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.withOpacity(0.3)
                      : isCompleted
                          ? stage.color.withOpacity(0.9)
                          : isCurrent
                              ? Colors.white.withOpacity(0.95)
                              : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: stage.color.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                  border: isCurrent
                      ? Border.all(color: stage.color, width: 3)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isLocked ? '🔒' : stage.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stage.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isLocked
                                      ? Colors.white54
                                      : isCompleted
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),
                              Text(
                                stage.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isLocked
                                      ? Colors.white38
                                      : isCompleted
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(3, (si) {
                        return Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: isCompleted
                              ? Colors.amber
                              : Colors.grey.withOpacity(0.4),
                        );
                      }),
                    ),
                    if (isCompleted)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'تکمیل شده',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isCurrent)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          '▶ شروع کن',
                          style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (!isEven) const SizedBox(width: 20),
            if (isEven) const Spacer(),
          ],
        ),
        // Connector line
        if (!isLast)
          Container(
            width: 3,
            height: 30,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.amber
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    ).animate().fadeIn(
          delay: Duration(milliseconds: index * 80),
        ).slideX(
          begin: isEven ? -0.1 : 0.1,
        );
  }

  void _onStageTap(_StageData stage, bool isCompleted) {
    if (isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('مرحله "${stage.title}" قبلاً تکمیل شده! 🌟'),
          backgroundColor: stage.color,
        ),
      );
    } else {
      // Navigate to the first game of this stage
      Navigator.of(context).pushNamed('/game/${stage.title}');
    }
  }
}

class _StageData {
  final String id;
  final String title;
  final String emoji;
  final int stars;
  final String description;
  final Color color;

  _StageData({
    required this.id,
    required this.title,
    required this.emoji,
    required this.stars,
    required this.description,
    required this.color,
  });
}
