import 'package:flutter/material.dart';

/// Shared visual language for the refreshed Fandoghi island experience.
///
/// These tokens are intentionally additive: existing themes and screens keep
/// their current appearance until each feature is migrated in a later phase.
abstract final class IslandWorldPalette {
  static const Color sky = Color(0xFF68C9F1);
  static const Color skyMist = Color(0xFFEAF8FF);
  static const Color ocean = Color(0xFF39BBD4);
  static const Color deepOcean = Color(0xFF176F9A);
  static const Color foliage = Color(0xFF47B96D);
  static const Color foliageLight = Color(0xFF9BDD69);
  static const Color foliageDeep = Color(0xFF287A58);
  static const Color honey = Color(0xFFFFC94D);
  static const Color coral = Color(0xFFF47B64);
  static const Color rose = Color(0xFFEE91B5);
  static const Color lavender = Color(0xFF9984E8);
  static const Color wood = Color(0xFF9B603D);
  static const Color paper = Color(0xFFFFFAEF);
  static const Color ink = Color(0xFF294552);
  static const Color mutedInk = Color(0xFF617882);
  static const Color softOutline = Color(0xFFD8E6DB);
  static const Color success = Color(0xFF2C9B67);
}

abstract final class IslandWorldGradients {
  static const LinearGradient sky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [IslandWorldPalette.skyMist, IslandWorldPalette.sky],
  );

  static const LinearGradient ocean = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF73D8E5),
      IslandWorldPalette.ocean,
      IslandWorldPalette.deepOcean,
    ],
    stops: [0.0, 0.52, 1.0],
  );

  static const LinearGradient meadow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [IslandWorldPalette.foliageLight, IslandWorldPalette.foliage],
  );

  static const LinearGradient honeyButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE18A), IslandWorldPalette.honey],
  );

  static const LinearGradient magic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC7B9FF), IslandWorldPalette.lavender],
  );
}

abstract final class IslandWorldMetrics {
  static const double minimumTouchTarget = 48;
  static const double primaryActionHeight = 58;
  static const double cardRadius = 28;
  static const double buttonRadius = 22;
  static const double pressScale = 0.96;
  static const int ambientSparkleBudget = 10;

  static const Duration pressIn = Duration(milliseconds: 100);
  static const Duration pressOut = Duration(milliseconds: 190);
  static const Duration routeTransition = Duration(milliseconds: 260);
  static const Duration celebration = Duration(milliseconds: 520);
  static const Duration ambientLoop = Duration(seconds: 16);
}

abstract final class IslandWorldAssets {
  static const String mapHero = 'assets/gateway/island_world_hero_v2.webp';

  /// Primary Fandoghi mascot, matching the supplied squirrel artwork. The
  /// transparent, app-ready cutout is shared across the app so Fandoghi keeps
  /// one recognizable design in greetings, rewards, and celebrations.
  static const String fandoghiMain = 'assets/theme_v2/squirrel_hero.webp';
  static const String fandoghiWave = fandoghiMain;
  static const String fandoghiCelebrate = fandoghiMain;

  /// تزئیناتِ اختصاصیِ دنیای جزیره (سبک خمیریِ هم‌خانواده با سکوها،
  /// با پس‌زمینهٔ واقعاً شفاف و بهینه‌شده برای حجم کمِ APK)
  static const String decorPalmTree = 'assets/theme_map/decor_palm_tree.webp';
  static const String decorBlossomTree =
      'assets/theme_map/decor_blossom_tree.webp';
  static const String decorRainbow = 'assets/theme_map/decor_rainbow.webp';
  static const String decorBalloon = 'assets/theme_map/decor_balloon.webp';
}
