import '../../core/game_data.dart';

/// پیکربندی تنظیمات والدین/کودک با مقداردهی امن (clamp).
class UpdateSettings {
  const UpdateSettings();

  void setTimeLimit(int minutes) => GameData.setTimeLimitMinutes(minutes);

  void setSound(bool enabled) => GameData.setSoundEnabled(enabled);

  Future<bool> setParentPin(String pin) => GameData.setParentPin(pin);

  Future<void> removeParentPin() => GameData.removeParentPin();

  Future<bool> verifyPin(String pin) => GameData.verifyParentPin(pin);

  bool hasPin() => GameData.hasParentPin();
}
