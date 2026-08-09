import '../../core/game_data.dart';

/// پیکربندی تنظیمات والدین/کودک با مقداردهی امن (clamp).
class UpdateSettings {
  const UpdateSettings();

  void setTimeLimit(int minutes) => GameData.setTimeLimitMinutes(minutes);

  void setSound(bool enabled) => GameData.setSoundEnabled(enabled);

  void setParentPin(String pin) => GameData.setParentPin(pin);

  void removeParentPin() => GameData.removeParentPin();

  bool verifyPin(String pin) => GameData.verifyParentPin(pin);

  bool hasPin() => GameData.hasParentPin();
}
