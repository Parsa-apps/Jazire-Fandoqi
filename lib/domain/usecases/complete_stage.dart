import '../../core/game_data.dart';

/// تکمیل یک مرحله از نقشه — یک‌بار جایزه، بدون farming.
///
/// خروجی `true` یعنی مرحله برای اولین بار کامل شده و جایزه (ستاره/توکن)
/// اعطا شده است. `false` یعنی تکراری بود.
class CompleteStage {
  const CompleteStage();

  bool call({required String stageId, int? stageNumber}) =>
      GameData.completeStage(stageId, stageNumber: stageNumber);

  bool isCompleted(String stageId) => GameData.isStageCompleted(stageId);

  int get completedCount => GameData.completedStageCount;
}
