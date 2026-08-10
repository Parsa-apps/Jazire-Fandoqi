import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'design_tokens.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';

/// =======================================================
/// 🎨 PREMIUM MATERIAL 3 THEME — کودک ایران
/// طراحی مدرن، نرم و حرفه‌ای برای کودکان
/// =======================================================

enum DayCycle { morning, noon, night }

class AppTheme {
  static DayCycle get currentCycle {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return DayCycle.morning;
    if (hour >= 12 && hour < 18) return DayCycle.noon;
    return DayCycle.night;
  }

  static TextTheme _textTheme(Brightness brightness, {double scaleFactor = 1.0}) {
    final foreground = brightness == Brightness.dark
        ? Colors.white
        : AppColors.textPrimary;
    
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

  static ThemeData getTheme(DayCycle cycle, Brightness systemBrightness, {double textScale = 1.0}) {
    final isDark = cycle == DayCycle.night || systemBrightness == Brightness.dark;
    return _buildTheme(isDark ? Brightness.dark : Brightness.light, textScale: textScale);
  }

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness, {double textScale = 1.0}) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF17182B) : AppColors.surface;
    final background = isDark ? const Color(0xFF101124) : AppColors.background;
    final foreground = isDark ? Colors.white : AppColors.textPrimary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: surface,
        surfaceContainerHighest: isDark 
            ? const Color(0xFF25263A) 
            : const Color(0xFFF8F4FF),
      ),
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(brightness, scaleFactor: textScale),
      
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
          color: foreground,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: foreground, size: 24),
      ),

      // Elevated Button Premium — با Design Tokens
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
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
      // ⚠️ CardThemeData فقط از Flutter 3.27+ وجود دارد؛ پروژه روی 3.24.3 است.
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        color: surface,
        shadowColor: Colors.black.withOpacity(0.08),
      ),

      // Bottom Navigation Premium
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? Colors.white54 : AppColors.textLight,
        elevation: 0,
        selectedLabelStyle: AppFonts.vazirmatn(fontWeight: FontWeight.w700, fontSize: 12 * textScale),
        unselectedLabelStyle: AppFonts.vazirmatn(fontWeight: FontWeight.w600, fontSize: 11 * textScale),
      ),

      // Chip Premium — Design Tokens
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        labelStyle: AppFonts.vazirmatn(fontWeight: FontWeight.w600, fontSize: 14 * textScale),
      ),

      // Input Premium — Design Tokens
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.06) : surface,
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
