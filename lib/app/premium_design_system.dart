import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ═══════════════════════════════════════════════════════════
/// 🎨 PREMIUM DESIGN SYSTEM — کودک ایران
/// سیستم طراحی یکپارچه برای تجربه کاربری لوکس
/// ═══════════════════════════════════════════════════════════

/// دسته‌بندی سایزها برای گوشی‌های مختلف
enum DeviceSize { small, medium, large, tablet }

class PremiumSpacing {
  /// فاصله‌های استاندارد
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// فاصله‌های نرم (برای لیست‌ها)
  static const double listItemGap = 12;
  static const double gridSpacing = 16;

  /// فاصله‌های کارت
  static const double cardPadding = 16;
  static const double cardMargin = 12;
  static const double cardRadius = 24;

  /// فاصله‌های صفحه
  static const double screenPadding = 16;
  static const double screenPaddingTablet = 32;

  /// محاسبه سایز بر اساس دستگاه
  static double responsiveSize(BuildContext context, double small, double medium, double large) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return small;
    if (width < 600) return medium;
    return large;
  }
}

class PremiumSizing {
  /// سایزهای آیکون
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  /// سایزهای دکمه
  static const double buttonHeightSm = 44;
  static const double buttonHeightMd = 56;
  static const double buttonHeightLg = 64;

  /// سایزهای کارت
  static const double cardHeightSm = 120;
  static const double cardHeightMd = 160;
  static const double cardHeightLg = 200;

  /// سایزهای آواتار
  static const double avatarSm = 32;
  static const double avatarMd = 48;
  static const double avatarLg = 64;
  static const double avatarXl = 96;

  /// سایز تاچ‌تاپلت
  static const double touchTargetMin = 48;
  static const double touchTargetLarge = 64;
}

/// رنگ‌های پریمیوم برای موضوعات مختلف
class PremiumColors {
  /// رنگ‌های موفقیت
  static const success = Color(0xFF00B894);
  static const successLight = Color(0xFF55EFC4);
  static const successDark = Color(0xFF00A381);

  /// رنگ‌های هشدار
  static const warning = Color(0xFFFDCB6E);
  static const warningLight = Color(0xFFFEE98D);
  static const warningDark = Color(0xFFE17055);

  /// رنگ‌های خطا
  static const error = Color(0xFFFF7675);
  static const errorLight = Color(0xFFFFADAD);
  static const errorDark = Color(0xFFD63031);

  /// رنگ‌های اطلاعات
  static const info = Color(0xFF74B9FF);
  static const infoLight = Color(0xFFA8D8FF);
  static const infoDark = Color(0xFF0984E3);

  /// رنگ‌های پریمیوم
  static const premium = Color(0xFFFFD700);
  static const premiumLight = Color(0xFFFFE566);
  static const premiumDark = Color(0xFFCC9900);

  /// رنگ‌های طلایی
  static const gold = Color(0xFFFFD700);
  static const silver = Color(0xFFC0C0C0);
  static const bronze = Color(0xFFCD7F32);

  /// گرادیان‌های پریمیوم
  static const successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFE566)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const rainbowGradient = LinearGradient(
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFFD93D),
      Color(0xFF6BCB77),
      Color(0xFF4D96FF),
      Color(0xFFC084FC),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// افکت‌های سایه پریمیوم
class PremiumShadows {
  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black26 : Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> elevated(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black38 : Colors.black.withOpacity(0.12),
        blurRadius: 30,
        offset: const Offset(0, 12),
      ),
    ];
  }

  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.4),
        blurRadius: 20,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: color.withOpacity(0.2),
        blurRadius: 40,
        spreadRadius: 5,
      ),
    ];
  }

  static List<BoxShadow> soft() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

/// انیمیشن‌های پریمیوم
class PremiumAnimations {
  /// مدت زمان‌های استاندارد
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration bounce = Duration(milliseconds: 700);

  /// منحنی‌های انیمیشن
  static const Curves elasticOut = Curves.elasticOut;
  static const Curves easeOutCubic = Curves.easeOutCubic;
  static const Curves easeOutBack = Curves.easeOutBack;
  static const Curves spring = Curves.elasticOut;
}

/// گرادیان‌های پس‌زمینه
class BackgroundGradients {
  static const ocean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const sunset = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
  );

  static const forest = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  static const sky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  );

  static const candy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
  );

  static const purple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const night = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
  );

  static const aurora = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
      Color(0xFF4ECDC4),
      Color(0xFF556270),
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  /// گرادیان بر اساس زمان روز
  static LinearGradient getByTimeOfDay() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 10) {
      // صبح - گرم و انرژی‌بخش
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFE259), Color(0xFFFFA751)],
      );
    } else if (hour >= 10 && hour < 17) {
      // روز - آبی آرام
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      );
    } else if (hour >= 17 && hour < 20) {
      // عصر - غروب آفتاب
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      );
    } else {
      // شب - تاریک و آرام
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F0C29), Color(0xFF302B63)],
      );
    }
  }
}

/// خلاصه‌کننده پالت رنگ برای استفاده سریع
class ColorPalette {
  /// رنگ‌های دسته‌بندی بازی
  static const learning = AppColors.catLearning;
  static const thinking = AppColors.catThinking;
  static const world = AppColors.catWorld;
  static const creative = AppColors.catCreative;
  static const fun = AppColors.catFun;

  /// رنگ‌های الفبا
  static const alphabetColors = [
    Color(0xFFFF6B6B), // الف
    Color(0xFFFF8E53), // ب
    Color(0xFFFFD93D), // پ
    Color(0xFF6BCB77), // ت
    Color(0xFF4ECDC4), // ث
    Color(0xFF4FACFE), // ج
    Color(0xFFC084FC), // چ
    Color(0xFF667EEA), // ح
    Color(0xFFFF6B9D), // خ
    Color(0xFFFFAB40), // د
  ];

  /// رنگ‌های رنگین‌کمان
  static const rainbow = [
    Color(0xFFFF0000), // قرمز
    Color(0xFFFF7F00), // نارنجی
    Color(0xFFFFFF00), // زرد
    Color(0xFF00FF00), // سبز
    Color(0xFF0000FF), // آبی
    Color(0xFF4B0082), // نیلی
    Color(0xFF9400D3), // بنفش
  ];
}
