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
/// - به `GameData.changes` گوش می‌دهد تا تغییر «اندازه متن» والدین
///   بلافاصله در کل اپ اعمال شود (فیکس بازبینی دور ۶)
/// ────────────────────────────────────────────────────────────
class ThemeController extends ChangeNotifier {
  Timer? _timer;
  DayCycle _cycle = AppTheme.currentCycle;
  double _lastTextScale = GameData.textScale;

  ThemeController() {
    // به‌روزرسانی دوره‌ای چرخه روز (مثلاً وقتی ساعت ۱۲ ظهر می‌شود)
    _timer = Timer.periodic(const Duration(minutes: 15), (_) {
      final next = AppTheme.currentCycle;
      if (next != _cycle) {
        _cycle = next;
        notifyListeners();
      }
    });

    // دور ۶: تغییر فونت/تم از GameData باید بلافاصله منعکس شود
    GameData.changes.addListener(_onGameDataChanged);
  }

  void _onGameDataChanged() {
    var changed = false;
    if (GameData.textScale != _lastTextScale) {
      _lastTextScale = GameData.textScale;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  DayCycle get cycle => _cycle;

  double get textScale => GameData.textScale;

  /// هنگام برگشتن اپ به foreground، چرخه روز و فونت را تازه می‌کنیم.
  void refresh() {
    final next = AppTheme.currentCycle;
    if (next != _cycle || GameData.textScale != _lastTextScale) {
      _cycle = next;
      _lastTextScale = GameData.textScale;
      notifyListeners();
    }
  }

  ThemeData themeFor(Brightness systemBrightness) =>
      AppTheme.getTheme(_cycle, systemBrightness, textScale: textScale);

  void setTextScale(double value) {
    GameData.setTextScale(value);
    _lastTextScale = GameData.textScale;
    notifyListeners();
  }

  @override
  void dispose() {
    GameData.changes.removeListener(_onGameDataChanged);
    _timer?.cancel();
    super.dispose();
  }
}
