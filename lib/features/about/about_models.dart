part of 'about_screen.dart';

class _UpcomingApp {
  const _UpcomingApp({
    required this.title,
    required this.description,
    required this.asset,
  });

  final String title;
  final String description;
  final String asset;
}

class _ContactDestination {
  const _ContactDestination({
    required this.name,
    required this.meta,
    required this.icon,
    required this.colors,
    required this.glowColor,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final String name;
  final String meta;
  final IconData icon;
  final List<Color> colors;
  final Color glowColor;
  final Color iconColor;
  final VoidCallback onTap;
}

class _AboutPalette {
  const _AboutPalette.dark()
      : isLight = false,
        background = const Color(0xFF050816),
        backgroundSecondary = const Color(0xFF0B1220),
        surface = const Color(0x0FFFFFFF),
        surfaceStrong = const Color(0x1AFFFFFF),
        line = const Color(0x24FFFFFF),
        text = const Color(0xFFF6F8FC),
        muted = const Color(0xFF9AA7BD),
        orange = const Color(0xFFEF7A1A),
        gold = const Color(0xFFFBD06F),
        leaf = const Color(0xFF2BB3A0),
        violet = const Color(0xFF6D5DF6);

  const _AboutPalette.light()
      : isLight = true,
        background = const Color(0xFFEEF2F9),
        backgroundSecondary = const Color(0xFFE4EAF4),
        surface = const Color(0xB3FFFFFF),
        surfaceStrong = const Color(0xE6FFFFFF),
        line = const Color(0x1A0F172A),
        text = const Color(0xFF0F172A),
        muted = const Color(0xFF55637A),
        orange = const Color(0xFFEF7A1A),
        gold = const Color(0xFFD69A19),
        leaf = const Color(0xFF168E7E),
        violet = const Color(0xFF6D5DF6);

  final bool isLight;
  final Color background;
  final Color backgroundSecondary;
  final Color surface;
  final Color surfaceStrong;
  final Color line;
  final Color text;
  final Color muted;
  final Color orange;
  final Color gold;
  final Color leaf;
  final Color violet;
}
