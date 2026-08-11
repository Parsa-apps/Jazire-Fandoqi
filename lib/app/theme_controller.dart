import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/game_data.dart';
import 'app_theme.dart';

/// ────────────────────────────────────────────────────────────
/// 🌗 کنترل‌کننده تم داینامیک و چندگانه
///
/// - تم بر اساس انتخاب کاربر (سلطنتی طلایی، جزیره، اقیانوس، آب‌نباتی، کهکشان، فصلی)
/// - چرخه روز (صبح/ظهر/شب) + حالت سیستم + مقیاس فونت والدین
/// - گوش دادن به `GameData.changes` جهت تغییر آنی تم در کل برنامه
/// ────────────────────────────────────────────────────────────
class ThemeController extends ChangeNotifier {
  Timer? _timer;
  DayCycle _cycle = AppTheme.currentCycle;
  double _lastTextScale = GameData.textScale;
  String _lastActiveTheme = GameData.activeTheme;

  ThemeController() {
    // به‌روزرسانی دوره‌ای چرخه روز (مثلاً وقتی ساعت ۱۲ ظهر می‌شود)
    _timer = Timer.periodic(const Duration(minutes: 15), (_) {
      final next = AppTheme.currentCycle;
      if (next != _cycle) {
        _cycle = next;
        notifyListeners();
      }
    });

    GameData.changes.addListener(_onGameDataChanged);
  }

  void _onGameDataChanged() {
    var changed = false;
    if (GameData.textScale != _lastTextScale) {
      _lastTextScale = GameData.textScale;
      changed = true;
    }
    if (GameData.activeTheme != _lastActiveTheme) {
      _lastActiveTheme = GameData.activeTheme;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  DayCycle get cycle => _cycle;

  double get textScale => GameData.textScale;

  String get activeTheme => GameData.activeTheme;

  /// هنگام برگشتن اپ به foreground، چرخه روز، تم و فونت را تازه می‌کنیم.
  void refresh() {
    final nextCycle = AppTheme.currentCycle;
    if (nextCycle != _cycle ||
        GameData.textScale != _lastTextScale ||
        GameData.activeTheme != _lastActiveTheme) {
      _cycle = nextCycle;
      _lastTextScale = GameData.textScale;
      _lastActiveTheme = GameData.activeTheme;
      notifyListeners();
    }
  }

  ThemeData themeFor(Brightness systemBrightness) => AppTheme.getThemeForMode(
        GameData.activeTheme,
        _cycle,
        systemBrightness,
        textScale: textScale,
      );

  void setTextScale(double value) {
    GameData.setTextScale(value);
    _lastTextScale = GameData.textScale;
    notifyListeners();
  }

  void setActiveTheme(String themeId) {
    GameData.setActiveTheme(themeId);
    _lastActiveTheme = GameData.activeTheme;
    notifyListeners();
  }

  @override
  void dispose() {
    GameData.changes.removeListener(_onGameDataChanged);
    _timer?.cancel();
    super.dispose();
  }
}
