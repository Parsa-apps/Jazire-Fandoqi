import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/achievement_system.dart';
import '../../core/game_data.dart';

/// ────────────────────────────────────────────────────────────
/// 🚀 فاز ۳: State Management مقیاس‌پذیر با Riverpod
///
/// یک Snapshot غیرقابل‌تغییر از وضعیت بازیکن که همه صفحه‌ها می‌توانند
/// با `ref.watch(gameStateProvider)` به آن واکنش نشان دهند — به‌جای
/// `addListener` دستی روی [GameData.changes] در هر StatefulWidget.
///
/// الگو: Riverpod StateNotifier (پیشنهاد فاز ۳) + ChangeNotifier داخلی.
/// ────────────────────────────────────────────────────────────
class GameStateSnapshot {
  final int revision;
  final int stars;
  final int coins;
  final int level;
  final int streak;
  final int totalCorrect;
  final int totalWrong;
  final int todayPlaySeconds;
  final int dailyMissions;
  final int currentStage;
  final int completedStages;
  final bool onboardingSeen;
  final bool isDailyLimitReached;
  final double successRate;

  const GameStateSnapshot({
    required this.revision,
    required this.stars,
    required this.coins,
    required this.level,
    required this.streak,
    required this.totalCorrect,
    required this.totalWrong,
    required this.todayPlaySeconds,
    required this.dailyMissions,
    required this.currentStage,
    required this.completedStages,
    required this.onboardingSeen,
    required this.isDailyLimitReached,
    required this.successRate,
  });

  factory GameStateSnapshot.fromGameData() => GameStateSnapshot(
        revision: GameData.changes.value,
        stars: GameData.stars,
        coins: GameData.coins,
        level: GameData.level,
        streak: GameData.streak,
        totalCorrect: GameData.totalCorrect,
        totalWrong: GameData.totalWrong,
        todayPlaySeconds: GameData.todayPlaySeconds,
        dailyMissions: GameData.dailyMissions,
        currentStage: GameData.currentStage,
        completedStages: GameData.completedStageCount,
        onboardingSeen: GameData.onboardingSeen,
        isDailyLimitReached: GameData.isDailyLimitReached,
        successRate: GameData.successRate,
      );
}

class GameStateNotifier extends StateNotifier<GameStateSnapshot> {
  GameStateNotifier() : super(GameStateSnapshot.fromGameData()) {
    // یک شنونده مرکزی؛ هر صفحه فقط `ref.watch` می‌کند.
    GameData.changes.addListener(_onGameDataChanged);
  }

  void _onGameDataChanged() {
    // فاز ۵۴: هر تغییری در وضعیت، مدال‌های تازه بازشده را ثبت می‌کند
    AchievementSystem.checkAndUnlock();
    state = GameStateSnapshot.fromGameData();
  }

  @override
  void dispose() {
    GameData.changes.removeListener(_onGameDataChanged);
    super.dispose();
  }
}

/// منبع وضعیت سراسری بازی — جایگزین `ValueNotifier<int> changes` برای UI.
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameStateSnapshot>((ref) {
  return GameStateNotifier();
});
