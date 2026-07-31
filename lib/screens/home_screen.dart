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

/// صفحه اصلی با Bottom Navigation
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
      _checkTreasure();
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
                title: Row(
                  children: [
                    const FandoghiMini(size: 28),
                    const SizedBox(width: 8),
                    const Text("جایزه فندقی!"),
                  ],
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
                      child: const Text("عالیه! 🎉"))
                ],
              ));
    }
  }

  void _checkTreasure() {
    if (GameData.canOpenTreasure()) {
      showDialog(
          context: context,
          builder: (c) => AlertDialog(
                title: Row(
                  children: [
                    const Text('🎪'),
                    const SizedBox(width: 8),
                    const Text("صندوق گنج!"),
                  ],
                ),
                content: const Text(
                    "ماموریت‌های امروز رو کامل کردی! صندوق گنج رو باز کن!"),
                actions: [
                  TextButton(
                      onPressed: () {
                        GameData.addCoins(100);
                        GameData.addStars(5);
                        GameData.treasureOpened = true;
                        GameData.save();
                        _conf.play();
                        setState(() {});
                        Navigator.pop(c);
                      },
                      child: const Text("باز کن! 🎁"))
                ],
              ));
    }
  }

  void _showTimeLimit() {
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: const Text("⏰ زمان تموم شد!"),
              content: const Text("وقت استراحته! فردا برگرد!"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(c);
                      Navigator.pop(c);
                    },
                    child: const Text("باشه"))
              ],
            ));
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
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primary : Colors.grey,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
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
        margin: const EdgeInsets.only(top: 8),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: isSelected ? null : Gradients.primary,
          color: isSelected ? AppColors.primary : null,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.map_outlined,
          color: Colors.white,
          size: 28,
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
            duration: 2000.ms,
            begin: -2,
            end: 2,
          ),
    );
  }
}

// Tab contents using named routes to avoid circular imports
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return _DashboardContent();
  }
}

class _IslandTab extends StatelessWidget {
  const _IslandTab();
  @override
  Widget build(BuildContext context) {
    return const LearningIsland();
  }
}

class _MapTab extends StatelessWidget {
  const _MapTab();
  @override
  Widget build(BuildContext context) {
    return const StageMapScreen();
  }
}

class _PrizeTab extends StatelessWidget {
  const _PrizeTab();
  @override
  Widget build(BuildContext context) {
    return const PrizeBoxScreen();
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}

/// محتوای داشبورد اصلی
class _DashboardContent extends StatefulWidget {
  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: Gradients.primary),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(GameData.avatar,
                            style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 8),
                        const FandoghiMini(size: 36),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      GameData.getLevelName(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "لول ${GameData.level}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const Text(" | ",
                            style: TextStyle(color: Colors.white38)),
                        Text(
                          "${GameData.coins} ⭐",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const Text(" | ",
                            style: TextStyle(color: Colors.white38)),
                        Text(
                          "🔥 ${GameData.streak} روز",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const StarDisplay(color: Colors.amber, size: 16),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.face, color: Colors.white),
              onPressed: () async {
                await Navigator.pushNamed(context, '/avatar');
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => _parentGate(context),
            ),
          ],
        ),

        // Fandoghi message
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fandoghiCream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.fandoghiLight.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                const Fandoghi(size: 50, animate: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    GameData.childName.isEmpty
                        ? AI.mascotMsg()
                        : 'سلام ${GameData.childName}! ${AI.mascotMsg()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Daily missions
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("🎯 ماموریت امروز",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    if (GameData.canOpenTreasure())
                      const Text("🎪 صندوق آماده!",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                _mi("۵ سوال حل کن", 'questions',
                    GameData.missionValue('questions'), 5),
                _mi("الفبا تمرین کن", 'alphabet',
                    GameData.missionValue('alphabet'), 1),
                _mi("یک نقاشی بکش", 'drawing',
                    GameData.missionValue('drawing'), 1),
                _mi("رنگ‌ها رو یاد بگیر", 'colors',
                    GameData.missionValue('colors'), 1),
              ],
            ),
          ),
        ),

        // Quick game buttons
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(child: _quickGames()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Game categories
        SliverToBoxAdapter(child: _gameCategories()),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _quickGames() {
    final quickGames = [
      {'name': 'الفبا', 'emoji': '🔤', 'color': const Color(0xFF9C27B0)},
      {'name': 'اعداد', 'emoji': '🔢', 'color': const Color(0xFF4CAF50)},
      {'name': 'رنگ‌ها', 'emoji': '🎨', 'color': const Color(0xFFFF9800)},
      {'name': 'حافظه', 'emoji': '🧠', 'color': const Color(0xFF009688)},
      {'name': 'حیوانات', 'emoji': '🐾', 'color': const Color(0xFF795548)},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: quickGames.length,
        itemBuilder: (context, i) {
          final g = quickGames[i];
          return BounceBtn(
            onTap: () => Navigator.pushNamed(context, '/game/${g['name']}'),
            child: Container(
              width: 85,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: (g['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (g['color'] as Color).withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(g['emoji'] as String,
                      style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 4),
                  Text(
                    g['name'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: g['color'] as Color,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: i * 80)),
          );
        },
      ),
    );
  }

  Widget _gameCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'همه بازی‌ها',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _categoryCard(
            'یادگیری پایه',
            'الفبا، عددها، رنگ‌ها',
            const Color(0xFF7B6CF6),
            Icons.school_rounded,
            ['الفبا', 'اعداد', 'شمارش', 'رنگ‌ها', 'اشکال', 'مفاهیم', 'لغات'],
          ),
          const SizedBox(height: 10),
          _categoryCard(
            'بازی‌های فکری',
            'حافظه، الگو، مسابقه',
            const Color(0xFFFF8B72),
            Icons.psychology_rounded,
            ['حافظه', 'الگو', 'مسابقه', 'ترتیب', 'مورد اضافه', 'مسابقه ریاضی', 'چرخ شانس'],
          ),
          const SizedBox(height: 10),
          _categoryCard(
            'دنیای اطراف',
            'حیوانات، طبیعت، بدن',
            const Color(0xFF34BFA2),
            Icons.public_rounded,
            ['حیوانات', 'میوه‌ها', 'بدن', 'وسایل نقلیه', 'زمان', 'آب و هوا', 'احساسات', 'شغل‌ها', 'فضا', 'ورزش‌ها'],
          ),
          const SizedBox(height: 10),
          _categoryCard(
            'خلاقیت',
            'داستان، موسیقی، نقاشی',
            const Color(0xFFFFB34D),
            Icons.palette_rounded,
            ['داستان', 'سازها', 'نقاشی'],
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(String title, String subtitle, Color color,
      IconData icon, List<String> games) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: games
                  .map((g) => BounceBtn(
                        onTap: () =>
                            Navigator.pushNamed(context, '/game/$g'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: color.withOpacity(0.3)),
                          ),
                          child: Text(
                            g,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mi(String title, String id, int value, int target) {
    final done = GameData.isMissionDone(id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: done ? const Color(0xFF35B86B) : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                style: TextStyle(
                  decoration:
                      done ? TextDecoration.lineThrough : null,
                  fontSize: 13,
                )),
          ),
          if (!done && target > 1)
            Text('$value/$target',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF))),
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
                  Text("$n1 + $n2 = ?",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  TextField(
                      controller: ct,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(cx),
                    child: const Text("انصراف")),
                ElevatedButton(
                    onPressed: () {
                      if (int.tryParse(ct.text) == n1 + n2) {
                        Navigator.pop(cx);
                        Navigator.pushNamed(context, '/parent');
                      }
                    },
                    child: const Text("تایید")),
              ],
            ));
  }
}
