import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// =======================================================
/// 🎨 PREMIUM MATERIAL 3 THEME — کودک ایران
/// طراحی مدرن، نرم و حرفه‌ای برای کودکان
/// =======================================================

class AppTheme {
  static TextTheme _textTheme(Brightness brightness) {
    final foreground = brightness == Brightness.dark
        ? Colors.white
        : AppColors.textPrimary;
    return GoogleFonts.vazirmatnTextTheme(
      brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    ).apply(
      bodyColor: foreground,
      displayColor: foreground,
    );
  }

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
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
      textTheme: _textTheme(brightness),
      
      // AppBar Premium
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.vazirmatn(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: foreground,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: foreground, size: 24),
      ),

      // Elevated Button Premium
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(56, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: GoogleFonts.vazirmatn(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // Card Premium
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
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
        selectedLabelStyle: GoogleFonts.vazirmatn(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600, fontSize: 11),
      ),

      // Chip Premium
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
      ),

      // Input Premium
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.06) : surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
