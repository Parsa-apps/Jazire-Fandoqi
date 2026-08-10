import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_colors.dart';
import '../../../app/design_tokens.dart';
import '../../../app/app_fonts.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';

/// ────────────────────────────────────────────────────────────
/// 🏝️ ISLAND BUILDER PREMIUM V2 — پیشنهاد ۳۵ و ۵۵
/// Meta Game: هر ۵ لول یک جزیره جدید (بهار، جنگل، برف، صحرا)
/// با ۱۲ تزئین پریمیوم + انیمیشن + ذخیره دائمی
/// ────────────────────────────────────────────────────────────
class IslandBuilderGame extends StatefulWidget {
  const IslandBuilderGame({super.key});

  @override
  State<IslandBuilderGame> createState() => _IslandBuilderGameState();
}

class _IslandBuilderGameState extends State<IslandBuilderGame> {
  static const int _rows = 4;
  static const int _cols = 4;

  // ۱۲ تزئین پریمیوم — قیمت بالانس‌شده
  static const List<(String, String, int, String)> _decorations =
      <(String, String, int, String)>[
    ('palm', '🌴', 5, 'نخل'),
    ('house', '🏠', 10, 'خانه'),
    ('flower', '🌺', 5, 'گل'),
    ('star', '⭐', 8, 'ستاره'),
    ('rock', '🪨', 5, 'صخره'),
    ('shell', '🐚', 6, 'صدف'),
    ('cloud', '☁️', 6, 'ابر'),
    ('fountain', '⛲', 12, 'فواره'),
    ('tree', '🌳', 8, 'درخت'),
    ('castle', '🏰', 20, 'قلعه'),
    ('rainbow', '🌈', 15, 'رنگین‌کمان'),
    ('volcano', '🌋', 18, 'آتشفشان'),
  ];

  // ۴ جزیره بر اساس لول
  static const List<_Island> _islands = [
    _Island(id: 'spring', name: 'بهار', emoji: '🌸', level: 1, gradient: [Color(0xFF7FD3B7), Color(0xFF4CAF93)]),
    _Island(id: 'forest', name: 'جنگل', emoji: '🌲', level: 5, gradient: [Color(0xFF2E7D32), Color(0xFFAED581)]),
    _Island(id: 'snow', name: 'برفی', emoji: '❄️', level: 10, gradient: [Color(0xFFE3F2FD), Color(0xFF90CAF9)]),
    _Island(id: 'desert', name: 'صحرا', emoji: '🏜️', level: 15, gradient: [Color(0xFFFFE0B2), Color(0xFFFF8A65)]),
  ];

  String _selectedItem = 'palm';
  String _selectedIsland = 'spring';

  String _slotId(int row, int col) => '${_selectedIsland}_s$row-$col';

  _Island get _currentIsland => _islands.firstWhere((i) => i.id == _selectedIsland);

  bool _isIslandUnlocked(_Island island) => GameData.level >= island.level;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'این جزیره‌ی خودت است! هر ۵ لول یک جزیره جدید باز می‌شه 🏝️ سکه جمع کن و قشنگش کن!',
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _onSlotTap(String slot) {
    final existing = GameData.islandDecorations[slot];
    if (existing != null) {
      GameData.removeDecoration(slot);
      HapticFeedback.lightImpact();
      setState(() {});
      return;
    }
    final item = _decorations.firstWhere((d) => d.$1 == _selectedItem);
    final placed = GameData.placeDecoration(slot, item.$1, cost: item.$3);
    if (placed) {
      HapticFeedback.lightImpact();
      FandoghiCoach.correct('${item.$2} روی جزیره ${_currentIsland.name} نشست!');
      setState(() {});
    } else {
      FandoghiCoach.judge('سکه کافی نداری! اول در بازی‌ها سکه جمع کن 🪙');
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(colors: _currentIsland.gradient, begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  children: [
                    ChildTouchTarget(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white30)),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Text('جزیره‌ی ${_currentIsland.name} ${_currentIsland.emoji}', textAlign: TextAlign.center, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                          Text('لول ${GameData.level} • ${GameData.islandDecorations.length} تزئین', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.soft),
                      child: Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text('${GameData.coins}', style: AppFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF2D3436))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // انتخاب جزیره
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _islands.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final island = _islands[index];
                    final unlocked = _isIslandUnlocked(island);
                    final selected = island.id == _selectedIsland;
                    return GestureDetector(
                      onTap: () {
                        if (!unlocked) {
                          HapticFeedback.heavyImpact();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🔒 جزیره ${island.name} در لول ${island.level} باز می‌شه (الان لول ${GameData.level})')));
                          return;
                        }
                        HapticFeedback.selectionClick();
                        setState(() => _selectedIsland = island.id);
                      },
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        width: 78,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: island.gradient),
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          border: Border.all(color: selected ? Colors.white : Colors.white.withOpacity(0.5), width: selected ? 3 : 1.5),
                          boxShadow: selected ? AppShadows.colored(Colors.white, opacity: 0.3) : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(island.emoji, style: TextStyle(fontSize: 28, color: unlocked ? null : Colors.white.withOpacity(0.5))),
                                const SizedBox(height: 2),
                                Text(island.name, style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                                Text(unlocked ? 'لول ${island.level}' : '🔒 ${island.level}', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700)),
                              ],
                            ),
                            if (!unlocked)
                              Container(
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(AppRadii.lg)),
                                child: const Center(child: Icon(Icons.lock_rounded, color: Colors.white, size: 22)),
                              ),
                            if (selected && unlocked)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.check_rounded, size: 12, color: Color(0xFF00B894)),
                                ),
                              ),
                          ],
                        ),
                      ).animate(delay: (index * 80).ms).scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // زمین جزیره
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _currentIsland.gradient.map((c) => c.withOpacity(0.9)).toList(), begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      border: Border.all(color: Colors.white.withOpacity(0.6), width: 2.5),
                      boxShadow: AppShadows.strong,
                    ),
                    child: Stack(
                      children: [
                        // ابر شناور تزئینی
                        Positioned(
                          top: 10,
                          right: 16,
                          child: Text('☁️', style: TextStyle(fontSize: 22, color: Colors.white.withOpacity(0.7))).animate(onPlay: (c) => c.repeat(reverse: true)).moveX(begin: 0, end: 6, duration: 2000.ms, curve: Curves.easeInOut),
                        ),
                        Column(
                          children: [
                            for (var row = 0; row < _rows; row++)
                              Expanded(
                                child: Row(
                                  children: [
                                    for (var col = 0; col < _cols; col++) Expanded(child: _slot(row, col)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // پالت تزئینات پریمیوم
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _decorations.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _decorations[index];
                    final selected = item.$1 == _selectedItem;
                    final canAfford = GameData.coins >= item.$3;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedItem = item.$1),
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        width: 78,
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          border: Border.all(color: selected ? AppColors.primary : (canAfford ? Colors.white30 : Colors.red.withOpacity(0.4)), width: selected ? 2.5 : 1.2),
                          boxShadow: selected ? AppShadows.colored(AppColors.primary, opacity: 0.25) : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.$2, style: TextStyle(fontSize: 30, color: canAfford ? null : Colors.white.withOpacity(0.5))),
                            const SizedBox(height: 2),
                            Text(item.$4, style: AppFonts.vazirmatn(fontSize: 10, fontWeight: FontWeight.w800, color: selected ? AppColors.primary : Colors.white)),
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: canAfford ? const Color(0xFFFFD700) : Colors.red.withOpacity(0.7), borderRadius: BorderRadius.circular(AppRadii.pill)),
                              child: Text('${item.$3} 🪙', style: AppFonts.vazirmatn(fontSize: 10, fontWeight: FontWeight.w900, color: canAfford ? Colors.black87 : Colors.white)),
                            ),
                          ],
                        ),
                      ).animate(delay: (index * 30).ms).fadeIn(duration: 300.ms),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 6),
                  Text('بزن تا بذاری • دوباره بزن تا برداری', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  (String, String, int, String)? _findDecoration(String id) {
    for (final d in _decorations) {
      if (d.$1 == id) return d;
    }
    return null;
  }

  Widget _slot(int row, int col) {
    final slot = _slotId(row, col);
    final itemId = GameData.islandDecorations[slot];
    final item = itemId == null ? null : _findDecoration(itemId);
    return Padding(
      padding: const EdgeInsets.all(3),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onSlotTap(slot),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          decoration: BoxDecoration(
            color: item == null ? Colors.black.withOpacity(0.08) : Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: item == null ? Colors.white.withOpacity(0.3) : AppColors.primary.withOpacity(0.2)),
            boxShadow: item == null ? null : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
          ),
          child: Center(
            child: item == null
                ? const Icon(Icons.add_rounded, color: Colors.white70, size: 20)
                : Text(item.$2, style: const TextStyle(fontSize: 26)).animate().scale(begin: const Offset(0.5, 0.5), duration: 350.ms, curve: Curves.elasticOut),
          ),
        ),
      ),
    );
  }
}

class _Island {
  final String id;
  final String name;
  final String emoji;
  final int level;
  final List<Color> gradient;
  const _Island({required this.id, required this.name, required this.emoji, required this.level, required this.gradient});
}
