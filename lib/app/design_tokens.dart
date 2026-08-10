import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 💎 DESIGN TOKENS — سیستم طراحی یکپارچه کودک ایران
/// پیشنهاد پریمیوم شماره ۱۱ — همه مقادیر از این فایل می‌آیند
/// تا یک تغییر = کل اپ یکدست شود (مثل Duolingo / Toca Boca)
/// ═══════════════════════════════════════════════════════════════

// ── Spacing ──────────────────────────────────────────────────
class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 24);
}

// ── Radius ───────────────────────────────────────────────────
class AppRadii {
  static const double xs = 12;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 28;
  static const double xxl = 32;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(xl);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get sheet => BorderRadius.vertical(top: Radius.circular(xl));
  static BorderRadius get avatar => BorderRadius.circular(xxl);
}

// ── Shadows ──────────────────────────────────────────────────
class AppShadows {
  static List<BoxShadow> get soft => [
        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
      ];
  static List<BoxShadow> get medium => [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
      ];
  static List<BoxShadow> get strong => [
        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 32, offset: const Offset(0, 12)),
      ];
  static List<BoxShadow> colored(Color color, {double opacity = 0.3}) => [
        BoxShadow(color: color.withOpacity(opacity), blurRadius: 20, offset: const Offset(0, 8)),
      ];
  static List<BoxShadow> get glowPrimary => colored(const Color(0xFF6C5CE7), opacity: 0.25);
}

// ── Durations & Curves ───────────────────────────────────────
class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  static const Curve entrance = Curves.easeOutCubic;
  static const Curve entranceBack = Curves.easeOutBack;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOut;

  // Stagger delays for lists
  static Duration stagger(int index, {Duration base = const Duration(milliseconds: 80), Duration step = const Duration(milliseconds: 70)}) =>
      base + step * index;
}

// ── Typography Scale ─────────────────────────────────────────
class AppTypography {
  static const double displayLarge = 48;
  static const double displayMedium = 32;
  static const double titleLarge = 26;
  static const double titleMedium = 20;
  static const double bodyLarge = 17;
  static const double bodyMedium = 15;
  static const double labelLarge = 18;
  static const double labelSmall = 12;
  static const double caption = 13;
}

// ── Seasonal Theme Tokens ────────────────────────────────────
enum SeasonalTheme { normal, nowruz, yalda, mehregan }

class SeasonalTokens {
  static SeasonalTheme get current {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;
    // نوروز: ۱ تا ۱۳ فروردین (Mar 21 - Apr 2)
    if ((month == 3 && day >= 21) || (month == 4 && day <= 2)) return SeasonalTheme.nowruz;
    // یلدا: ۳۰ آذر (Dec 20-21)
    if (month == 12 && day >= 20 && day <= 21) return SeasonalTheme.yalda;
    // مهرگان: اوایل مهر (Sep 23 - Oct 1)
    if ((month == 9 && day >= 23) || (month == 10 && day == 1)) return SeasonalTheme.mehregan;
    return SeasonalTheme.normal;
  }

  static String get emoji => switch (current) {
        SeasonalTheme.nowruz => '🌸',
        SeasonalTheme.yalda => '🍉',
        SeasonalTheme.mehregan => '🍂',
        SeasonalTheme.normal => '🌟',
      };

  static String get greeting => switch (current) {
        SeasonalTheme.nowruz => 'نوروزت پیروز! 🌸',
        SeasonalTheme.yalda => 'یلدات مبارک! 🍉',
        SeasonalTheme.mehregan => 'جشن مهرگان مبارک! 🍂',
        SeasonalTheme.normal => 'سلام قهرمان! 🌟',
      };

  static List<Color> get gradient => switch (current) {
        SeasonalTheme.nowruz => [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
        SeasonalTheme.yalda => [const Color(0xFFC0392B), const Color(0xFF8E44AD)],
        SeasonalTheme.mehregan => [const Color(0xFFE67E22), const Color(0xFFF1C40F)],
        SeasonalTheme.normal => [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
      };
}

// ── Breakpoints (Tablet / Phone) ─────────────────────────────
class AppBreakpoints {
  static const double tablet = 600;
  static const double largeTablet = 900;

  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= tablet;
  static bool isLargeTablet(BuildContext context) => MediaQuery.of(context).size.width >= largeTablet;
}
