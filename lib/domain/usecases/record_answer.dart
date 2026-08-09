import '../../core/game_data.dart';

/// ثبت پاسخ درست/غلط و به‌روزرسانی مهارت‌ها — لایه Domain.
///
/// این UseCase منطق بازی را از UI جدا می‌کند: صفحه‌ها فقط `call` را صدا
/// می‌زنند و GameData (منبع حقیقت) به‌روزرسانی و ذخیره می‌شود.
class RecordAnswer {
  const RecordAnswer();

  void call({required bool correct, String? skill}) {
    GameData.recordAnswer(correct: correct, skill: skill);
  }

  /// برای آزمون‌ها: مقدار جدید مهارت را برمی‌گرداند.
  int skillValue(String skill) => GameData.skills[skill] ?? 0;
}
