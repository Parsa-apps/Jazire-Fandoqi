import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/game_data.dart';
import '../core/theme.dart';
import '../widgets/fandoghi.dart';
import '../widgets/common.dart';

/// جزیره یادگیری - صفحه اصلی با طراحی جزیره‌ای
class LearningIsland extends StatefulWidget {
  const LearningIsland({super.key});
  @override
  State<LearningIsland> createState() => _LearningIslandState();
}

class _LearningIslandState extends State<LearningIsland> {
  int _selectedIsland = 0;

  final List<_IslandData> _islands = [
    _IslandData(
      name: 'جزیره الفبا',
      emoji: '🏝️',
      color: const Color(0xFF6C63FF),
      description: 'حروف و کلمات رو یاد بگیر',
      games: [
        _IslandGame('الفبا', '🔤', const Color(0xFF9C27B0)),
        _IslandGame('لغات', '📚', const Color(0xFF7B1FA2)),
        _IslandGame('داستان', '📖', const Color(0xFF6A1B9A)),
      ],
    ),
    _IslandData(
      name: 'جزیره اعداد',
      emoji: '🏖️',
      color: const Color(0xFF4CAF50),
      description: 'ریاضی و شمارش رو تمرین کن',
      games: [
        _IslandGame('اعداد', '🔢', const Color(0xFF388E3C)),
        _IslandGame('شمارش', '🧮', const Color(0xFF2E7D32)),
        _IslandGame('مسابقه ریاضی', '⚡', const Color(0xFF1B5E20)),
      ],
    ),
    _IslandData(
      name: 'جزیره رنگ‌ها',
      emoji: '🌴',
      color: const Color(0xFFFF9800),
      description: 'رنگ‌ها و اشکال رو بشناس',
      games: [
        _IslandGame('رنگ‌ها', '🎨', const Color(0xFFF57C00)),
        _IslandGame('اشکال', '🔷', const Color(0xFFE65100)),
        _IslandGame('نقاشی', '🖌️', const Color(0xFFBF360C)),
      ],
    ),
    _IslandData(
      name: 'جزیره حیوانات',
      emoji: '🌊',
      color: const Color(0xFF2196F3),
      description: 'حیوانات و طبیعت رو بشناس',
      games: [
        _IslandGame('حیوانات', '🐾', const Color(0xFF1976D2)),
        _IslandGame('میوه‌ها', '🍎', const Color(0xFF1565C0)),
        _IslandGame('آب و هوا', '☀️', const Color(0xFF0D47A1)),
      ],
    ),
    _IslandData(
      name: 'جزیره فکری',
      emoji: '⛰️',
      color: const Color(0xFFE91E63),
      description: 'بازی‌های فکری و چالشی',
      games: [
        _IslandGame('حافظه', '🧠', const Color(0xFFC2185B)),
        _IslandGame('الگو', '🔲', const Color(0xFFAD1457)),
        _IslandGame('مسابقه', '🎯', const Color(0xFF880E4F)),
      ],
    ),
    _IslandData(
      name: 'جزیره دنیا',
      emoji: '🌋',
      color: const Color(0xFF795548),
      description: 'دنیای اطراف رو کشف کن',
      games: [
        _IslandGame('بدن', '👤', const Color(0xFF5D4037)),
        _IslandGame('شغل‌ها', '👷', const Color(0xFF4E342E)),
        _IslandGame('فضا', '🚀', const Color(0xFF3E2723)),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky
              Color(0xFFB0E0E6), // Light blue
              Color(0xFF98FB98), // Light green
              Color(0xFF228B22), // Dark green
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Fandoghi
              _buildHeader(),
              // Island selector
              _buildIslandSelector(),
              // Selected island content
              Expanded(child: _buildIslandContent()),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جزیره یادگیری',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5276),
                  ),
                ),
                Text(
                  '${GameData.completedStageCount} مرحله تکمیل شده',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2471A3),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${GameData.stars}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A017),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslandSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _islands.length,
        itemBuilder: (context, i) {
          final island = _islands[i];
          final isSelected = _selectedIsland == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedIsland = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              width: 90,
              decoration: BoxDecoration(
                color: isSelected
                    ? island.color
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: island.color.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    island.emoji,
                    style: const TextStyle(fontSize: 30),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                        duration: Duration(seconds: 2 + i % 3),
                        begin: -3,
                        end: 3,
                      ),
                  const SizedBox(height: 4),
                  Text(
                    island.name.split(' ').last,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIslandContent() {
    final island = _islands[_selectedIsland];
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: island.color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Island header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [island.color, island.color.withOpacity(0.7)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Text(island.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        island.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        island.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Games grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: island.games.length,
                itemBuilder: (context, i) {
                  final game = island.games[i];
                  return BounceBtn(
                    onTap: () => _launchGame(game.name),
                    child: Container(
                      decoration: BoxDecoration(
                        color: game.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: game.color.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: game.color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              game.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            game.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: game.color,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: i * 100)).slideY(begin: 0.2),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchGame(String gameName) {
    // Navigate to the corresponding game via the home screen
    Navigator.of(context).pushNamed('/game/$gameName');
  }
}

class _IslandData {
  final String name;
  final String emoji;
  final Color color;
  final String description;
  final List<_IslandGame> games;

  _IslandData({
    required this.name,
    required this.emoji,
    required this.color,
    required this.description,
    required this.games,
  });
}

class _IslandGame {
  final String name;
  final String emoji;
  final Color color;

  _IslandGame(this.name, this.emoji, this.color);
}
