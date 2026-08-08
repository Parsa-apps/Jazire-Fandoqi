import 'package:talker/talker.dart';

class LoggerService {
  static final Talker talker = Talker(
    settings: TalkerSettings(
      useConsoleLogs: true,
      useHistory: true,
      maxHistoryItems: 100,
    ),
  );

  static void i(String message) => talker.info(message);
  static void w(String message) => talker.warning(message);
  static void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      talker.handle(error ?? message, stackTrace, message);

  static String getHistory() {
    return talker.history.map((e) => e.generateTextField()).join('\n');
  }
}
