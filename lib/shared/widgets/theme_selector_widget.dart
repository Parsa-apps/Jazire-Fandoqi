import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/design_tokens.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import '../../core/game_data.dart';

class ThemeSelectorWidget extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const ThemeSelectorWidget({super.key, this.onThemeChanged});

  @override
  State<ThemeSelectorWidget> createState() => _ThemeSelectorWidgetState();
}

class _ThemeSelectorWidgetState extends State<ThemeSelectorWidget> {
  final List<Map<String, dynamic>> _themes = [
    {
      'id': 'island_map',
      'title': 'نقشه جزیره فندقی 🗺️',
      'subtitle': 'تم اصلی برنامه — نقشه شناور و دریایی',
      'gradient': const [Color(0xFF2E9BD6), Color(0xFF8FD8F7)],
      'accent': const Color(0xFFFFB300),
      'icon': Icons.map_rounded,
    },
    {
      'id': 'royal_gold',
      'title': 'سلطنتی طلایی 👑',
      'subtitle': 'تم لوکس و درخشان پارسا اپس',
      'gradient': const [Color(0xFF130F26), Color(0xFF3023AE)],
      'accent': const Color(0xFFFFD700),
      'icon': Icons.stars_rounded,
    },
    {
      'id': 'island',
      'title': 'جزیره زمردی 🏝️',
      'subtitle': 'طبیعت شاد و پرانرژی',
      'gradient': const [Color(0xFF00B894), Color(0xFF00CEC9)],
      'accent': const Color(0xFFFDCB6E),
      'icon': Icons.landscape_rounded,
    },
    {
      'id': 'ocean',
      'title': 'اقیانوس آرام 🌊',
      'subtitle': 'آبی دریا و تمرکز بالا',
      'gradient': const [Color(0xFF0984E3), Color(0xFF74B9FF)],
      'accent': const Color(0xFF81ECEC),
      'icon': Icons.water_rounded,
    },
    {
      'id': 'candy',
      'title': 'آب‌نباتی پاستلی 🍬',
      'subtitle': 'رنگ‌های صورتی و شاد خردسالان',
      'gradient': const [Color(0xFFE84393), Color(0xFFFD79A8)],
      'accent': const Color(0xFFFFE140),
      'icon': Icons.cake_rounded,
    },
    {
      'id': 'galaxy',
      'title': 'کهکشان ستاره‌ای 🌌',
      'subtitle': 'تاریک و آرامش‌بخش شبانه',
      'gradient': const [Color(0xFF0F0C29), Color(0xFF302B63)],
      'accent': const Color(0xFFA29BFE),
      'icon': Icons.bedtime_rounded,
    },
    {
      'id': 'seasonal',
      'title': 'هوشمند فصلی 🌸',
      'subtitle': 'تغییر خودکار بر اساس تقویم و ساعت',
      'gradient': const [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
      'accent': const Color(0xFF00B894),
      'icon': Icons.auto_awesome_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeTheme = GameData.activeTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.palette_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'انتخاب تم بصری برنامه',
              style: AppFonts.vazirmatn(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 125,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _themes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _themes[index];
              final isSelected = activeTheme == item['id'];
              final List<Color> colors = item['gradient'];
              final Color accent = item['accent'];

              return GestureDetector(
                onTap: () {
                  GameData.setActiveTheme(item['id']);
                  setState(() {});
                  widget.onThemeChanged?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text('تم «${item['title']}» فعال شد ✨'),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  width: 155,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? accent : Colors.white24,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accent.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(item['icon'] as IconData, color: accent, size: 24),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: AppFonts.vazirmatn(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
