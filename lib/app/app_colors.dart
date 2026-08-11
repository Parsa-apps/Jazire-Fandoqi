import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════
// 🎨 JAZIREH FANDOGHI — Professional Color System
// ═══════════════════════════════════════════════

class AppColors {
  // Primary palette
  static const primary = Color(0xFF6C5CE7);
  static const primaryLight = Color(0xFFA29BFE);
  static const primaryDark = Color(0xFF4834D4);
  
  // Accent colors
  static const accent = Color(0xFF00CEC9);
  static const accentLight = Color(0xFF81ECEC);
  
  // Semantic colors
  static const success = Color(0xFF00B894);
  static const successLight = Color(0xFF55EFC4);
  static const warning = Color(0xFFFDCB6E);
  static const danger = Color(0xFFFF7675);
  static const dangerLight = Color(0xFFFFB8B8);
  static const info = Color(0xFF74B9FF);
  
  // Neutral palette
  static const background = Color(0xFFF8F9FE);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDim = Color(0xFFF1F3F8);
  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const textLight = Color(0xFFB2BEC3);
  
  // Special gradients colors
  static const sunset1 = Color(0xFFFF6B6B);
  static const sunset2 = Color(0xFFFF8E53);
  static const ocean1 = Color(0xFF4FACFE);
  static const ocean2 = Color(0xFF00F2FE);
  static const forest1 = Color(0xFF43E97B);
  static const forest2 = Color(0xFF38F9D7);
  static const candy1 = Color(0xFFFA709A);
  static const candy2 = Color(0xFFFEE140);
  static const aurora1 = Color(0xFFA18CD1);
  static const aurora2 = Color(0xFFFBC2EB);
  static const sky1 = Color(0xFF667EEA);
  static const sky2 = Color(0xFF764BA2);
  
  // Fandoghi character colors
  static const fandoghiBody = Color(0xFF8B6914);
  static const fandoghiLight = Color(0xFFD4A574);
  static const fandoghiDark = Color(0xFF5D4037);
  static const fandoghiCheek = Color(0xFFFFB8B8);
  
  // Game category colors
  static const catLearning = Color(0xFF6C5CE7);
  static const catThinking = Color(0xFF00CEC9);
  static const catWorld = Color(0xFF00B894);
  static const catCreative = Color(0xFFE17055);
  static const catFun = Color(0xFFFDCB6E);
}

class AppGradients {
  // Hero gradients
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
  );
  
  static const hero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6C5CE7), Color(0xFF4834D4), Color(0xFF3023AE)],
  );
  
  static const sunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
  );
  
  static const ocean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  );
  
  static const forest = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
  );
  
  static const candy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
  );
  
  static const aurora = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
  );
  
  static const nightSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
  );
  
  static const starField = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
  );
  
  static const island = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF87CEEB), Color(0xFF98FB98), Color(0xFF228B22)],
  );
  
  static const success = LinearGradient(
    colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
  );
  
  static const warning = LinearGradient(
    colors: [Color(0xFFFDCB6E), Color(0xFFF8B739)],
  );
  
  static const purple = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
  );
  
  static const pink = LinearGradient(
    colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
  );
  
  // Glass effect gradient
  static final glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.25),
      Colors.white.withOpacity(0.05),
    ],
  );
}
