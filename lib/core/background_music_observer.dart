import 'dart:async';

import 'package:flutter/material.dart';

import 'audio_service.dart';

/// انتخاب موسیقی هر دنیا از یک نقطهٔ مرکزی؛ با push/pop موسیقی صفحهٔ زیرین
/// نیز درست برمی‌گردد و صفحه‌ها مجبور نیستند پلیر مستقل بسازند.
class BackgroundMusicObserver extends NavigatorObserver {
  void _sync(Route<dynamic>? route) {
    if (route == null) {
      AudioService.stopBgm();
      return;
    }
    final name = route.settings.name ?? '';
    // دیالوگ‌ها و bottom-sheetهای بدون نام نباید موسیقی صفحهٔ زیرین را قطع کنند.
    if (name.isEmpty) return;
    final section = sectionForRoute(name);
    if (section == null) {
      AudioService.stopBgm();
    } else {
      unawaited(AudioService.playBgmSection(section));
    }
  }

  @visibleForTesting
  static String? sectionForRoute(String name) {
    if (name == '/gateway' || name == '/home') return 'home';
    if (name == '/cartoons') return 'cartoons';
    // خود ویدیو موسیقی جدا نمی‌خواهد تا با دیالوگ کارتون تداخل نکند.
    if (name == '/cartoon_player' || name.startsWith('/cartoon/')) return null;
    if (name == '/stories' || name.startsWith('/story/')) return 'stories';
    // فایل لالایی خودش موسیقی اصلی صفحه است.
    if (name == '/lullabies' || name.startsWith('/lullaby/')) return null;

    if (name.startsWith('/game/') ||
        const <String>{
          '/alphabet', '/memory_match', '/bubble_pop', '/star_catch',
          '/colors_lab', '/puzzle', '/math_race', '/pattern',
          '/sound_match', '/body_parts', '/island_builder',
        }.contains(name)) {
      return 'games';
    }

    if (name.startsWith('/academy/') ||
        name.startsWith('/life-skills') ||
        const <String>{
          '/learning-library', '/animals', '/numbers', '/jobs',
          '/concepts', '/sel', '/vocabulary',
        }.contains(name)) {
      return 'learning';
    }
    return null;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _sync(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _sync(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _sync(newRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _sync(previousRoute);
}
