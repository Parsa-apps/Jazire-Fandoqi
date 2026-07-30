import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF8E85FF);
  static const secondary = Color(0xFFFF9800);
  static const success = Color(0xFF4CAF50);
  static const danger = Color(0xFFE91E63);
  static const warning = Color(0xFFFFB84D);
  static const info = Color(0xFF2196F3);
  static const background = Color(0xFFF0F2F5);
  static const surface = Color(0xFFFFFBFF);

  // Island colors
  static const islandGreen = Color(0xFF2EAF63);
  static const islandBlue = Color(0xFF3B82F6);
  static const islandPurple = Color(0xFF8B5CF6);
  static const islandOrange = Color(0xFFF97316);
  static const islandPink = Color(0xFFEC4899);

  // Fandoghi colors
  static const fandoghiBrown = Color(0xFF8B5E3C);
  static const fandoghiLight = Color(0xFFD4A574);
  static const fandoghiCream = Color(0xFFF5E6D3);
}

class Gradients {
  static const primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
  );
  static const success = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
  );
  static const warning = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFB84D)],
  );
  static const purple = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
  );
  static const pink = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
  );
  static const island = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF87CEEB), Color(0xFF98FB98), Color(0xFF228B22)],
  );
  static const sunset = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
  );
  static const ocean = LinearGradient(
    colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
  );
  static const forest = LinearGradient(
    colors: [Color(0xFF134E5E), Color(0xFF71B280)],
  );
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.vazirmatnTextTheme(),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle:
                const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          elevation: 20,
        ),
      );
}
