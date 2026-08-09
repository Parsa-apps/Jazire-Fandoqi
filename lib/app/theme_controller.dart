import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/game_data.dart';
import 'app_theme.dart';

/// ────────────────────────────────────────────────────────────
/// 🌗 فاز ۷: کنترل‌کننده تم داینامیک
///
/// - تم بر اساس چرخه روز (صبح/ظهر/شب) + حالت سیستم + مقیاس فونت والدین
/// - هر ۱۵ دقیقه چرخه روز دوباره محاسبه می‌شود و هنگام بازگشت اپ
///   از پس‌زمینه هم به‌روزرسانی می‌شود
/// - مقیاس فونت (textScale) مستقیماً از GameData خوانده می‌شود تا
///   تنظیم والدین در همه‌جا اثر کند
/// ────────────────────────────────────────────────────────────
class ThemeController extends ChangeNotifier {
  Timer? _timer;
  DayCycle _cycle = AppTheme.currentCycle;

  ThemeController() {
    // به‌روزرسانی دوره‌ای چرخه روز (مثلاً وقتی ساعت ۱۲ ظهر می‌شود)
    _timer = Timer.periodic(const Duration(minutes: 15), (_) {
      final next = AppTheme.currentCycle;
      if (next != _cycle) {
        _cycle = next;
        notifyListeners();
      }
    });
  }

  DayCycle get cycle => _cycle;

  double get textScale => GameData.textScale;

  /// هنگام برگشتن اپ به foreground، چرخه روز و فونت را تازه می‌کنیم.
  void refresh() {
    final next = AppTheme.currentCycle;
    if (next != _cycle || GameData.textScale != textScale) {
      _cycle = next;
      notifyListeners();
    }
  }

  ThemeData themeFor(Brightness systemBrightness) =>
      AppTheme.getTheme(_cycle, systemBrightness, textScale: textScale);

  void setTextScale(double value) {
    GameData.setTextScale(value);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
