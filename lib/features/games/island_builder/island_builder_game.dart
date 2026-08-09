import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../shared/widgets/child_touch_target.dart';

/// ────────────────────────────────────────────────────────────
/// 🏝️ فاز ۴۰: جزیره‌سازی (Meta Game)
///
/// کودک با سکه‌هایی که از بازی‌ها به دست آورده، جزیره‌ی شخصی
/// خودش را تزئین می‌کند. تزئین‌ها ذخیره می‌شوند و در جزیره اصلی
/// هم دیده می‌شوند (GameData.islandDecorations).
/// ────────────────────────────────────────────────────────────
class IslandBuilderGame extends StatefulWidget {
  const IslandBuilderGame({super.key});

  @override
  State<IslandBuilderGame> createState() => _IslandBuilderGameState();
}

class _IslandBuilderGameState extends State<IslandBuilderGame> {
  static const int _rows = 4;
  static const int _cols = 4;

  static const List<(String, String, int)> _decorations =
      <(String, String, int)>[
    ('palm', '🌴', 5),
    ('house', '🏠', 10),
    ('flower', '🌺', 5),
    ('star', '⭐', 8),
    ('rock', '🪨', 5),
    ('shell', '🐚', 6),
    ('cloud', '☁️', 6),
    ('fountain', '⛲', 12),
  ];

  String _selectedItem = 'palm';

  String _slotId(int row, int col) => 's$row-$col';

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.instruction(
        'این جزیره‌ی خودت است! یک تزئین انتخاب کن و روی زمین بگذار. سکه‌هایت را خوب خرج کن 🏝️',
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
      // حذف تزئین (بدون بازگشت سکه — ضد تقلب)
      GameData.removeDecoration(slot);
      HapticFeedback.lightImpact();
      setState(() {});
      return;
    }
    final item = _decorations.firstWhere((d) => d.$1 == _selectedItem);
    final placed = GameData.placeDecoration(slot, item.$1);
    if (placed) {
      HapticFeedback.lightImpact();
      FandoghiCoach.correct('${item.$2} روی جزیره‌ات نشست!');
      setState(() {});
    } else {
      FandoghiCoach.judge('سکه کافی نداری! اول در بازی‌ها سکه جمع کن 🪙');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.ocean),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    ChildTouchTarget(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'جزیره‌ی من 🏝️',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // سکه
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      'سکه: ${GameData.coins}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // زمین جزیره
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF7FD3B7), Color(0xFF4CAF93)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white38, width: 2),
                    ),
                    child: Column(
                      children: [
                        for (var row = 0; row < _rows; row++)
                          Expanded(
                            child: Row(
                              children: [
                                for (var col = 0; col < _cols; col++)
                                  Expanded(child: _slot(row, col)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // پالت تزئینات
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _decorations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _decorations[index];
                    final selected = item.$1 == _selectedItem;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedItem = item.$1),
                      child: Container(
                        width: 76,
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.amber.withOpacity(0.3)
                              : Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? Colors.amber : Colors.white30,
                            width: selected ? 2.5 : 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.$2, style: const TextStyle(fontSize: 30)),
                            const SizedBox(height: 2),
                            Text(
                              '${item.$3} 🪙',
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'برای برداشتن تزئین، دوباره رویش بزن',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  (String, String, int)? _findDecoration(String id) {
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
        child: Container(
          decoration: BoxDecoration(
            color: item == null
                ? Colors.black.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: item == null
                ? const Icon(Icons.add, color: Colors.black26, size: 22)
                : Text(item.$2, style: const TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }
}
