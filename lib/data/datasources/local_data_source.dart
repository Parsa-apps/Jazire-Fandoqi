import 'package:hive_flutter/hive_flutter.dart';

abstract class LocalDataSource {
  Future<void> init();
  Map<dynamic, dynamic>? getPlayerData();
  Future<void> savePlayerData(Map<dynamic, dynamic> data);
}

class HiveLocalDataSource implements LocalDataSource {
  static const String _playerBoxName = 'playerBox';
  static const String _playerKey = 'playerData';

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_playerBoxName);
  }

  @override
  Map<dynamic, dynamic>? getPlayerData() {
    final box = Hive.box(_playerBoxName);
    final data = box.get(_playerKey);
    return data != null ? Map<dynamic, dynamic>.from(data) : null;
  }

  @override
  Future<void> savePlayerData(Map<dynamic, dynamic> data) async {
    final box = Hive.box(_playerBoxName);
    await box.put(_playerKey, data);
  }
}
