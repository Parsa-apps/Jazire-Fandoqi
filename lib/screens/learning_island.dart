import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/game_data.dart';
import '../core/theme.dart';
import '../widgets/fandoghi.dart';
import '../widgets/common.dart';
import '../widgets/island_platform.dart';

/// جزیره یادگیری حرفه‌ای - طراحی مثل تبلت Smart Kid
class LearningIsland extends StatefulWidget {
  const LearningIsland({super.key});
  @override
  State<LearningIsland> createState() => _LearningIslandState();
}

class _LearningIslandState extends State<LearningIsland> {
  bool _isMagicMode = true; // Magic Island toggle

  final List<_FloatingModule> _modules = [
    _FloatingModule(
      animal: '🐱',
      title: 'گربه مهربون',
      subtitle: 'الفبا',
      color: const Color(0xFFEC4899),
      gameName: 'الفبا',
      stars: 3,
    ),
    _FloatingModule(
      animal: '🐵',
      title: 'میمون باهوش',
      subtitle: 'ریاضیات',
      color: const Color(0xFFF97316),
      gameName: 'اعداد',
      stars: 3,
    ),
    _FloatingModule(
      animal: '🐰',
      title: 'خرگوش قصه‌گو',
      subtitle: 'داستان‌ها',
      color: const Color(0xFFFBBF24),
      gameName: 'داستان',
      stars: 2,
    ),
    _FloatingModule(
      animal: '🐼',
      title: 'پاندا دوست‌داشتنی',
      subtitle: 'حافظه',
      color: const Color(0xFF8B5CF6),
      gameName: 'حافظه',
      stars: 3,
    ),
    _FloatingModule(
      animal: '🐢',
      title: 'لاک‌پشت باهوش',
      subtitle: 'اشکال و رنگ',
      color: const Color(0xFF22C55E),
      gameName: 'اشکال',
      stars: 2,
    ),
    _FloatingModule(
      animal: '🦋',
      title: 'پروانه رنگارنگ',
      subtitle: 'رنگ‌ها',
      color: const Color(0xFF3B82F6),
      gameName: 'رنگ‌ها',
      stars: 3,
    ),
    _FloatingModule(
      animal: '🤖',
      title: 'دوست هوش مصنوعی',
      subtitle: 'AI Buddy',
      color: const Color(0xFF06B6D4),
      gameName: 'مسابقه',
      stars: 1,
      isPremium: true,
    ),
    _FloatingModule(
      animal: '🦆',
      title: 'جوجه دانا',
      subtitle: 'ماجراجویی',
      color: const Color(0xFF14B8A6),
      gameName: 'حیوانات',
      stars: 2,
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
              Color(0xFF87CEEB),
              Color(0xFFB0E0E6),
              Color(0xFF98FB98),
              Color(0xFF4ADE80),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 8),
              _buildMagicToggle(),
              Expanded(child: _buildFloatingIsland()),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const FandoghiMini(size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GameData.childName.isEmpty ? 'کودک دانا' : GameData.childName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  'لول ${GameData.level} • ${GameData.stars} ستاره',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${GameData.stars}',
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

  Widget _buildMagicToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton('Magic Island', true),
          _toggleButton('Free Play', false),
        ],
      ),
    );
  }

  Widget _toggleButton(String text, bool isMagic) {
    final selected = _isMagicMode == isMagic;
    return GestureDetector(
      onTap: () => setState(() => _isMagicMode = isMagic),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIsland() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Top row - 3 modules
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _modules.take(3).map((m) => _buildPlatform(m)).toList(),
          ),
          const SizedBox(height: 30),

          // Middle row - 3 modules
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _modules.skip(3).take(3).map((m) => _buildPlatform(m)).toList(),
          ),
          const SizedBox(height: 30),

          // Bottom row - remaining + AI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _modules.skip(6).map((m) => _buildPlatform(m)).toList(),
          ),

          const SizedBox(height: 40),

          // Cute duck mascot at bottom
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/game/حیوانات'),
            child: Column(
              children: [
                const Text('🦆', style: TextStyle(fontSize: 60))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .float(duration: 1400.ms, begin: -6, end: 6),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Text(
                    'جوجه دانا 🐥',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatform(_FloatingModule module) {
    return AnimalPlatform(
      animalEmoji: module.animal,
      title: module.title,
      subtitle: module.subtitle,
      platformColor: module.color,
      isLocked: module.isPremium && !GameData.aiBuddyUnlocked,
      onTap: () {
        if (module.isPremium && !GameData.aiBuddyUnlocked) {
          _showPremiumDialog();
        } else {
          Navigator.pushNamed(context, '/game/${module.gameName}');
          GameData.addStars(1);
          setState(() {});
        }
      },
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('ویژه کودک دانا'),
          ],
        ),
        content: const Text(
          'این ماژول برای کاربران ویژه است.\n\nبا خرید اشتراک ویژه، به تمام ماژول‌های هوش مصنوعی و محتوای انحصاری دسترسی پیدا کنید.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('بعداً'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text('خرید اشتراک'),
          ),
        ],
      ),
    );
  }
}

class _FloatingModule {
  final String animal;
  final String title;
  final String subtitle;
  final Color color;
  final String gameName;
  final int stars;
  final bool isPremium;

  _FloatingModule({
    required this.animal,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gameName,
    this.stars = 2,
    this.isPremium = false,
  });
}