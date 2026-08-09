import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/game_data.dart';
import '../../../shared/widgets/child_touch_target.dart';

/// ────────────────────────────────────────────────────────────
/// 🎀 فاز ۵۹: آلبوم استیکر کودک
///
/// تمام استیکرهای خریداری‌شده را نمایش می‌دهد؛ استیکرهای نداشته
/// به‌صورت قفل دیده می‌شوند (انگیزه جمع‌آوری).
/// ────────────────────────────────────────────────────────────
class StickerAlbumScreen extends StatefulWidget {
  const StickerAlbumScreen({super.key});

  @override
  State<StickerAlbumScreen> createState() => _StickerAlbumScreenState();
}

class _StickerAlbumScreenState extends State<StickerAlbumScreen> {
  static const List<(String, String, String)> _catalog = <(String, String, String)>[
    ('sticker_star', '⭐', 'ستاره طلایی'),
    ('sticker_heart', '❤️', 'قلب قرمز'),
    ('sticker_rainbow', '🌈', 'رنگین‌کمان'),
    ('sticker_crown', '👑', 'تاج طلایی'),
    ('sticker_rocket', '🚀', 'موشک فضایی'),
    ('sticker_unicorn', '🦄', 'تک‌شاخ جادویی'),
    ('sticker_palm', '🌴', 'نخل جزیره'),
    ('sticker_flower', '🌺', 'گل بهاری'),
    ('sticker_bunny', '🐰', 'خرگوش فندقی'),
    ('sticker_butterfly', '🦋', 'پروانه رنگین'),
    ('sticker_icecream', '🍦', 'بستنی خوشمزه'),
    ('sticker_sun', '🌞', 'خورشید خانم'),
  ];

  @override
  void initState() {
    super.initState();
    GameData.changes.addListener(_onData);
  }

  void _onData() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GameData.changes.removeListener(_onData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final owned = <String>{
      ...GameData.ownedItems,
      ...GameData.stickers,
    };
    final ownedCount = _catalog.where((c) => owned.contains(c.$1)).length;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.candy),
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
                        'آلبوم استیکر 🎀',
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
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$ownedCount از ${_catalog.length} استیکر 🎁',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(20),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.9,
                  children: [
                    for (final item in _catalog)
                      _stickerCard(item.$1, item.$2, item.$3,
                          owned.contains(item.$1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stickerCard(String id, String emoji, String name, bool unlocked) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? Colors.white54 : Colors.white24,
          width: unlocked ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            unlocked ? emoji : '🔒',
            style: TextStyle(
              fontSize: 38,
              color: unlocked ? null : Colors.white38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
