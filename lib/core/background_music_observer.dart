import 'dart:async';

import 'package:flutter/material.dart';

import 'audio_service.dart';

/// انتخاب موسیقی هر صفحه از یک نقطهٔ مرکزی؛ با push/pop موسیقی صفحهٔ زیرین
/// نیز درست برمی‌گردد و صفحه‌ها مجبور نیستند پلیر مستقل بسازند.
///
/// از نسخهٔ جدید، موسیقی پس‌زمینه فقط روی صفحهٔ اصلی (دروازه/خانه) پخش
/// می‌شود. هر صفحهٔ دیگری که باز شود موسیقی می‌ایستد و با بازگشت به
/// صفحهٔ اصلی دوباره از سر گرفته می‌شود.
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
    // تنها صفحهٔ اصلی موسیقی دارد؛ هر مسیر دیگری = سکوت.
    if (name == '/gateway' || name == '/home') return 'home';
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
