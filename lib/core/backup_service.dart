import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../data/datasources/hive_player_store.dart';
import 'game_data.dart';

/// ────────────────────────────────────────────────────────────
/// 💾 BACKUP SERVICE PREMIUM — پیشنهاد ۲ و ۴۹
/// بکاپ رمزگذاری‌شده .parsa + بازیابی — والد با یک تپ Export/Import
/// کاملاً آفلاین، بدون سرور، امن برای کودک
/// ────────────────────────────────────────────────────────────
class BackupService {
  static const String _fileName = 'kudake_backup.parsa';

  /// خروجی بکاپ رمزگذاری‌شده (Base64 ساده + checksum)
  static Future<String> exportBackup() async {
    final snapshot = await HivePlayerStore.readSnapshot() ?? <String, dynamic>{};
    // اگر Hive خالی بود، از GameData snapshot بساز (fallback)
    final effective = snapshot.isEmpty ? _fallbackSnapshot() : snapshot;
    final jsonStr = jsonEncode(effective);
    final bytes = utf8.encode(jsonStr);
    final b64 = base64Encode(bytes);
    final reversed = b64.split('').reversed.join();
    final checksum = _checksum(jsonStr);
    final payload = jsonEncode({'v': 1, 'data': reversed, 'checksum': checksum, 'date': DateTime.now().toIso8601String()});

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    await file.writeAsString(payload);
    HapticFeedback.mediumImpact();
    return file.path;
  }

  static Map<String, dynamic> _fallbackSnapshot() {
    // snapshot حداقلی از GameData برای بکاپ — بدون دسترسی به private
    return {
      'c': GameData.coins,
      'stars': GameData.stars,
      'l': GameData.level,
      's': GameData.streak,
      'tc': GameData.totalCorrect,
      'childName': GameData.childName,
      'av': GameData.avatar,
    };
  }

  /// بازیابی از فایل .parsa
  static Future<bool> importBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      final content = await file.readAsString();
      final map = jsonDecode(content) as Map<String, dynamic>;
      final dataReversed = map['data'] as String;
      final checksum = map['checksum'] as String;
      final b64 = dataReversed.split('').reversed.join();
      final jsonStr = utf8.decode(base64Decode(b64));
      if (_checksum(jsonStr) != checksum) return false;
      final snapshot = jsonDecode(jsonStr) as Map<String, dynamic>;
      await HivePlayerStore.writeSnapshot(snapshot);
      await GameData.load();
      HapticFeedback.heavyImpact();
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _checksum(String input) {
    var sum = 0;
    for (var i = 0; i < input.length; i++) {
      sum = (sum + input.codeUnitAt(i) * (i + 1)) % 100000;
    }
    return sum.toString();
  }

  /// مسیر پیشنهادی برای ذخیره در Downloads (برای اشتراک)
  static Future<String> get backupFilePath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_fileName';
  }
}
