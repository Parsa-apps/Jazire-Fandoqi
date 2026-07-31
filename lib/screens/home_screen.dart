import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../core/game_data.dart';
import '../core/ai_system.dart';
import '../core/theme.dart';
import '../widgets/fandoghi.dart';
import '../widgets/star_display.dart';
import '../widgets/common.dart';
import 'learning_island.dart';
import 'stage_map.dart';
import 'profile_screen.dart';
import 'prize_box.dart';

/// صفحه اصلی حرفه‌ای با طراحی مطابق تصاویر
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  late ConfettiController _conf;
  late Timer _sessionTimer;
  int _sessionSec = 0;
  bool _timeLimitDialogShown = false;

  @override
  void initState() {
    super.initState();
    _conf = ConfettiController(duration: const Duration(seconds: 2));
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _sessionSec++;
      GameData.addPlayTime();
      if (_sessionSec >= GameData.timeLimitMinutes * 60 &&
          !_timeLimitDialogShown) {
        _timeLimitDialogShown = true;
        _showTimeLimit();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSurprise();
    });
  }

  @override
  void dispose() {
    _conf.dispose();
    _sessionTimer.cancel();
    super.dispose();
  }

  void _checkSurprise() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (GameData.surprise() && GameData.lastSurpriseClaimDate != today) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [FandoghiMini(size: 28), SizedBox(width: 8), Text("جایزه فندقی!")],
          ),
          content: Text(
              "${GameData.streak} روز پیاپی اومدی! ۵۰ سکه + ۲ ستاره جایزه!"),
          actions: [
            TextButton(
              onPressed: () {
                GameData.lastSurpriseClaimDate = today;
                GameData.addCoins(50);
                GameData.addStars(2);
                setState(() {});
                Navigator.pop(c);
              },
              child: const Text("عالیه! 🎉"),
            )
          ],
        ),
      );
    }
  }

  void _showTimeLimit() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("⏰ زمان تموم شد!"),
        content: const Text("وقت استراحته! فردا برگرد!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("باشه"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTab,
            children: const [
              _DashboardTab(),
              _IslandTab(),
              _MapTab(),
              _PrizeTab(),
              _ProfileTab(),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _conf,
              blastDirectionality: BlastDirectionality.explosive,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'خانه'),
              _navItem(1, Icons.map_rounded, 'جزیره'),
              _navItemCenter(),
              _navItem(3, Icons.card_giftcard_rounded, 'جایزه'),
              _navItem(4, Icons.person_rounded, 'پروفایل'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppColors.primary : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _navItemCenter() {
    final isSelected = _currentTab == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = 2),
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: isSelected ? null : Gradients.primary,
          color: isSelected ? AppColors.primary : null,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.map_outlined, color: Colors.white, size: 28),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).float(duration: 2000.ms, begin: -2, end: 2),
    );
  }
}

// ==================== DASHBOARD ====================
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return const _DashboardContent();
  }
}

class _IslandTab extends StatelessWidget {
  const _IslandTab();
  @override
  Widget build(BuildContext context) => const LearningIsland();
}

class _MapTab extends StatelessWidget {
  const _MapTab();
  @override
  Widget build(BuildContext context) => const StageMapScreen();
}

class _PrizeTab extends StatelessWidget {
  const _PrizeTab();
  @override
  Widget build(BuildContext context) => const PrizeBoxScreen();
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) => const ProfileScreen();
}

class _DashboardContent extends StatefulWidget {
  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  bool _isMagicMode = true;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Professional Top Bar (like tablet screenshot)
        SliverAppBar(
          expandedHeight: 165,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(GameData.avatar, style: const TextStyle(fontSize: 38)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  GameData.childName.isEmpty ? 'کودک دانا' : GameData.childName,
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  'لول ${GameData.level} • ${GameData.getLevelName()}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          // Stats badges
                          _statBadge(Icons.star_rounded, '${GameData.stars}', Colors.amber),
                          const SizedBox(width: 8),
                          _statBadge(Icons.local_fire_department, '${GameData.streak}', Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Magic Island Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _magicToggle('Magic Island', true),
                            _magicToggle('Free Play', false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => _parentGate(context),
            ),
          ],
        ),

        // Daily Missions
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🎯 ماموریت‌های امروز", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 12),
                _missionItem("۵ سوال حل کن", 'questions', GameData.missionValue('questions'), 5),
                _missionItem("الفبا تمرین کن", 'alphabet', GameData.missionValue('alphabet'), 1),
                _missionItem("یک نقاشی بکش", 'drawing', GameData.missionValue('drawing'), 1),
                _missionItem("رنگ‌ها رو یاد بگیر", 'colors', GameData.missionValue('colors'), 1),
              ],
            ),
          ),
        ),

        // Quick Games
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("بازی‌های سریع", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 95,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _quickGameCard('الفبا', '🔤', const Color(0xFFEC4899)),
                      _quickGameCard('اعداد', '🔢', const Color(0xFF3B82F6)),
                      _quickGameCard('رنگ‌ها', '🎨', const Color(0xFFF59E0B)),
                      _quickGameCard('حافظه', '🧠', const Color(0xFF8B5CF6)),
                      _quickGameCard('حیوانات', '🐾', const Color(0xFF22C55E)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Categories
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("همه ماژول‌ها", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _categoryCard('یادگیری پایه', 'الفبا • اعداد • رنگ‌ها', const Color(0xFF6366F1), ['الفبا', 'اعداد', 'رنگ‌ها', 'اشکال']),
                const SizedBox(height: 10),
                _categoryCard('بازی‌های فکری', 'حافظه • الگو • مسابقه', const Color(0xFF8B5CF6), ['حافظه', 'الگو', 'مسابقه']),
                const SizedBox(height: 10),
                _categoryCard('دنیای اطراف', 'حیوانات • بدن • شغل‌ها', const Color(0xFF22C55E), ['حیوانات', 'بدن', 'شغل‌ها']),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _statBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _magicToggle(String text, bool magic) {
    final selected = _isMagicMode == magic;
    return GestureDetector(
      onTap: () => setState(() => _isMagicMode = magic),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? const Color(0xFF6366F1) : Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _quickGameCard(String name, String emoji, Color color) {
    return BounceBtn(
      onTap: () => Navigator.pushNamed(context, '/game/$name'),
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard(String title, String subtitle, Color color, List<String> games) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(Icons.category, color: color, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: games
                  .map((g) => BounceBtn(
                        onTap: () => Navigator.pushNamed(context, '/game/$g'),
                        child: Chip(
                          label: Text(g),
                          backgroundColor: color.withOpacity(0.1),
                          labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionItem(String title, String id, int value, int target) {
    final done = GameData.isMissionDone(id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: done ? const Color(0xFF22C55E) : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: TextStyle(decoration: done ? TextDecoration.lineThrough : null))),
          if (!done) Text('$value/$target', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
        ],
      ),
    );
  }

  void _parentGate(BuildContext context) {
    int n1 = Random().nextInt(10) + 1, n2 = Random().nextInt(10) + 1;
    TextEditingController ct = TextEditingController();
    showDialog(
      context: context,
      builder: (cx) => AlertDialog(
        title: const Text("ورود والدین"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$n1 + $n2 = ?", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            TextField(controller: ct, keyboardType: TextInputType.number, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(cx), child: const Text("انصراف")),
          ElevatedButton(
            onPressed: () {
              if (int.tryParse(ct.text) == n1 + n2) {
                Navigator.pop(cx);
                Navigator.pushNamed(context, '/parent');
              }
            },
            child: const Text("تایید"),
          ),
        ],
      ),
    );
  }
}