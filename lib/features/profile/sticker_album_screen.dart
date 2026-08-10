import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import '../../app/design_tokens.dart';
import '../../app/app_fonts.dart';
import '../../core/game_data.dart';
import '../../core/fandoghi_models.dart';
import '../../shared/widgets/child_touch_target.dart';
import '../../shared/widgets/fandoghi_premium.dart';

/// ────────────────────────────────────────────────────────────
/// 🎀 فاز ۵۹ + بخش کارتون‌ها: آلبوم جامع استیکرهای کودک
/// ────────────────────────────────────────────────────────────
class StickerAlbumScreen extends StatefulWidget {
  const StickerAlbumScreen({super.key});

  @override
  State<StickerAlbumScreen> createState() => _StickerAlbumScreenState();
}

class _StickerAlbumScreenState extends State<StickerAlbumScreen> {
  int _selectedTab = 0; // 0: All, 1: Cartoons, 2: Games

  static const List<(String, String, String, String)> _allStickers = <(String, String, String, String)>[
    // Cartoon Stickers
    ('sticker_shekarestan', '🏰', 'شکرستان', 'cartoons'),
    ('sticker_pahlavanan', '⚔️', 'پوریای ولی', 'cartoons'),
    ('sticker_paw_patrol', '🐾', 'سگ‌های نگهبان', 'cartoons'),
    ('sticker_spongebob', '🧽', 'باب اسفنجی', 'cartoons'),
    ('sticker_shaun_sheep', '🐑', 'بره ناقلا', 'cartoons'),
    ('sticker_peppa_pig', '🐷', 'پپا پیگ', 'cartoons'),
    ('sticker_dirin_dirin', '🦖', 'دیرین دیرین', 'cartoons'),
    ('sticker_tom_jerry', '🐱', 'تام و جری', 'cartoons'),
    ('sticker_cars_mcqueen', '🏎️', 'مک‌کویین', 'cartoons'),
    ('sticker_boss_baby', '🍼', 'بچه رئیس', 'cartoons'),
    ('sticker_minions', '🍌', 'مینیون‌ها', 'cartoons'),
    ('sticker_cocomelon_fa', '🍉', 'کوکوملون', 'cartoons'),
    ('sticker_alphabet_song_cartoon', '🔤', 'الفبای موزیکال', 'cartoons'),
    ('sticker_numbers_song_cartoon', '🔢', 'اعداد موزیکال', 'cartoons'),
    ('sticker_babi_babo', '🍓', 'ببعی و ببعو', 'cartoons'),
    ('sticker_pocoyo', '🎈', 'پوکویو', 'cartoons'),
    ('sticker_kungfu_panda', '🐼', 'پاندا کونگ‌فو', 'cartoons'),
    ('sticker_persian_classics', '🦅', 'سیمرغ کهن', 'cartoons'),

    // Game Stickers
    ('sticker_star', '⭐', 'ستاره طلایی', 'games'),
    ('sticker_heart', '❤️', 'قلب قرمز', 'games'),
    ('sticker_rainbow', '🌈', 'رنگین‌کمان', 'games'),
    ('sticker_crown', '👑', 'تاج طلایی', 'games'),
    ('sticker_rocket', '🚀', 'موشک فضایی', 'games'),
    ('sticker_unicorn', '🦄', 'تک‌شاخ جادویی', 'games'),
    ('sticker_palm', '🌴', 'نخل جزیره', 'games'),
    ('sticker_flower', '🌺', 'گل بهاری', 'games'),
    ('sticker_bunny', '🧒', 'فندقی کوچولو', 'games'),
    ('sticker_butterfly', '🦋', 'پروانه رنگین', 'games'),
    ('sticker_icecream', '🍦', 'بستنی خوشمزه', 'games'),
    ('sticker_sun', '🌞', 'خورشید خانم', 'games'),
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

  List<(String, String, String, String)> get _filteredStickers {
    if (_selectedTab == 1) {
      return _allStickers.where((s) => s.$4 == 'cartoons').toList();
    } else if (_selectedTab == 2) {
      return _allStickers.where((s) => s.$4 == 'games').toList();
    }
    return _allStickers;
  }

  @override
  Widget build(BuildContext context) {
    final owned = <String>{
      ...GameData.ownedItems,
      ...GameData.stickers,
    };
    final totalOwnedCount = _allStickers.where((c) => owned.contains(c.$1)).length;
    final currentList = _filteredStickers;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    ChildTouchTarget(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'آلبوم استیکرهای فندقی 🎀',
                        textAlign: TextAlign.center,
                        style: AppFonts.vazirmatn(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const FandoghiPremium(size: 56, mood: FandoghiMood.happy, showParticles: false),
              const SizedBox(height: 8),
              // Total Badge پریمیوم
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: totalOwnedCount == _allStickers.length
                      ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8E53)])
                      : null,
                  color: totalOwnedCount == _allStickers.length ? null : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: totalOwnedCount == _allStickers.length ? const Color(0xFFFFD700) : Colors.white24, width: totalOwnedCount == _allStickers.length ? 2 : 1),
                  boxShadow: totalOwnedCount == _allStickers.length ? AppShadows.colored(const Color(0xFFFFD700)) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(totalOwnedCount == _allStickers.length ? '🏆' : '🎀', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '$totalOwnedCount از ${_allStickers.length} استیکر — ${(totalOwnedCount / _allStickers.length * 100).round()}٪',
                      style: AppFonts.vazirmatn(
                        color: totalOwnedCount == _allStickers.length ? Colors.white : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 14),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _tabButton(0, 'همه (${_allStickers.length})'),
                    const SizedBox(width: 8),
                    _tabButton(1, 'کارتون‌ها 🎬'),
                    const SizedBox(width: 8),
                    _tabButton(2, 'بازی‌ها 🎮'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.88,
                  children: [
                    for (final item in currentList)
                      _stickerCard(item.$1, item.$2, item.$3, owned.contains(item.$1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? Colors.white38 : Colors.transparent),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _stickerCard(String id, String emoji, String name, bool unlocked) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? Colors.white.withOpacity(0.12)
            : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? Colors.amber.withOpacity(0.6) : Colors.white12,
          width: unlocked ? 2 : 1,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            unlocked ? emoji : '🔒',
            style: TextStyle(
              fontSize: 38,
              color: unlocked ? null : Colors.white24,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unlocked ? Colors.white : Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
