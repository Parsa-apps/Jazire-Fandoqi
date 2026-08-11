import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'design_tokens.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';

/// =======================================================
/// 🎨 PREMIUM MATERIAL 3 THEME ENGINE — جزیره فندقی
/// پشتیبانی از ۶ تم اختصاصی و پویا برای کودکان و والدین
/// =======================================================

enum DayCycle { morning, noon, night }

class AppTheme {
  static DayCycle get currentCycle {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return DayCycle.morning;
    if (hour >= 12 && hour < 18) return DayCycle.noon;
    return DayCycle.night;
  }

  static TextTheme _textTheme(Brightness brightness, {double scaleFactor = 1.0, Color? textColor}) {
    final foreground = textColor ??
        (brightness == Brightness.dark ? Colors.white : AppColors.textPrimary);

    final baseTextTheme = AppFonts.vazirmatnTextTheme(
      brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    );

    if (scaleFactor == 1.0) {
      return baseTextTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
      );
    }

    return baseTextTheme.apply(
      bodyColor: foreground,
      displayColor: foreground,
      fontSizeFactor: scaleFactor,
    );
  }

  /// دریافت تم بر اساس تم انتخابی فعال (royal_gold, island, ocean, candy, galaxy, seasonal)
  static ThemeData getThemeForMode(
    String modeId,
    DayCycle cycle,
    Brightness systemBrightness, {
    double textScale = 1.0,
  }) {
    switch (modeId) {
      case 'royal_gold':
        return _buildCustomTheme(
          brightness: Brightness.dark,
          primary: AppColors.royalGoldSecondary,
          secondary: AppColors.royalGoldAccent,
          surface: AppColors.royalGoldSurface,
          background: AppColors.royalGoldBackground,
          cardColor: AppColors.royalGoldCard,
          textColor: Colors.white,
          textScale: textScale,
        );

      case 'island':
        return _buildCustomTheme(
          brightness: Brightness.light,
          primary: AppColors.islandPrimary,
          secondary: AppColors.islandAccent,
          surface: AppColors.islandSurface,
          background: AppColors.islandBackground,
          cardColor: Colors.white,
          textColor: AppColors.textPrimary,
          textScale: textScale,
        );

      case 'ocean':
        return _buildCustomTheme(
          brightness: Brightness.light,
          primary: AppColors.oceanPrimary,
          secondary: AppColors.oceanSecondary,
          surface: AppColors.oceanSurface,
          background: AppColors.oceanBackground,
          cardColor: Colors.white,
          textColor: AppColors.textPrimary,
          textScale: textScale,
        );

      case 'candy':
        return _buildCustomTheme(
          brightness: Brightness.light,
          primary: AppColors.candyPrimary,
          secondary: AppColors.candyAccent,
          surface: AppColors.candySurface,
          background: AppColors.candyBackground,
          cardColor: Colors.white,
          textColor: AppColors.textPrimary,
          textScale: textScale,
        );

      case 'galaxy':
        return _buildCustomTheme(
          brightness: Brightness.dark,
          primary: AppColors.galaxyPrimary,
          secondary: AppColors.galaxyAccent,
          surface: AppColors.galaxySurface,
          background: AppColors.galaxyBackground,
          cardColor: AppColors.galaxySurface,
          textColor: Colors.white,
          textScale: textScale,
        );

      case 'seasonal':
      default:
        final isDark = cycle == DayCycle.night || systemBrightness == Brightness.dark;
        return _buildTheme(isDark ? Brightness.dark : Brightness.light, textScale: textScale);
    }
  }

  static ThemeData getTheme(DayCycle cycle, Brightness systemBrightness, {double textScale = 1.0}) {
    final isDark = cycle == DayCycle.night || systemBrightness == Brightness.dark;
    return _buildTheme(isDark ? Brightness.dark : Brightness.light, textScale: textScale);
  }

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness, {double textScale = 1.0}) {
    final isDark = brightness == Brightness.dark;
    return _buildCustomTheme(
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: isDark ? const Color(0xFF17182B) : AppColors.surface,
      background: isDark ? const Color(0xFF101124) : AppColors.background,
      cardColor: isDark ? const Color(0xFF1D1F38) : AppColors.surface,
      textColor: isDark ? Colors.white : AppColors.textPrimary,
      textScale: textScale,
    );
  }

  static ThemeData _buildCustomTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color background,
    required Color cardColor,
    required Color textColor,
    double textScale = 1.0,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        surface: surface,
        surfaceContainerHighest: isDark
            ? Colors.white.withOpacity(0.08)
            : const Color(0xFFF8F4FF),
      ),
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(brightness, scaleFactor: textScale, textColor: textColor),

      // AppBar Premium
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppFonts.vazirmatn(
          fontSize: 22 * textScale,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textColor, size: 24),
      ),

      // Elevated Button Premium — با Design Tokens
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: isDark && primary == AppColors.royalGoldSecondary
              ? Colors.black
              : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(56, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          textStyle: AppFonts.vazirmatn(
            fontSize: 18 * textScale,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // Card Premium — Design Tokens
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        color: cardColor,
        shadowColor: isDark ? Colors.black45 : Colors.black.withOpacity(0.08),
      ),

      // Bottom Navigation Premium
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardColor,
        selectedItemColor: primary,
        unselectedItemColor: isDark ? Colors.white54 : AppColors.textLight,
        elevation: 0,
        selectedLabelStyle: AppFonts.vazirmatn(fontWeight: FontWeight.w700, fontSize: 12 * textScale),
        unselectedLabelStyle: AppFonts.vazirmatn(fontWeight: FontWeight.w600, fontSize: 11 * textScale),
      ),

      // Chip Premium
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        labelStyle: AppFonts.vazirmatn(fontWeight: FontWeight.w600, fontSize: 14 * textScale),
      ),

      // Input Premium
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.08) : surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: TextStyle(fontSize: 16 * textScale),
      ),

      // Page Transitions Premium
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
