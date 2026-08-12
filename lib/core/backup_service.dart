import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../data/datasources/hive_player_store.dart';
import 'game_data.dart';

/// ────────────────────────────────────────────────────────────
/// 💾 BACKUP SERVICE PREMIUM — پیشنهاد ۲ و ۴۹
/// بکاپ رمزگذاری‌شده AES-GCM با فرمت .parsa + بازیابی
/// والد با یک تپ Export/Import — کاملاً آفلاین، بدون سرور
///
/// امنیت: AES-256-GCM + nonce تصادفی. کلید v3 از PIN والدین مشتق می‌شود.
/// ────────────────────────────────────────────────────────────
class BackupService {
  static const String _fileName = 'kudake_backup.parsa';
  static const MethodChannel _fileChannel = MethodChannel('kudake_iran/backup');

  /// Legacy v2 key — only used to decrypt backups written before PIN-derived v3.
  static final List<int> _legacyAppKey =
      utf8.encode('kudake-iran-fandoghi-2025-backup-secret');

  static AesGcm get _algorithm => AesGcm.with256bits();
  static final Random _secureRandom = Random.secure();

  /// v4: کلید از PIN والدین با PBKDF2-HMAC-SHA256 و salt تصادفی مشتق می‌شود
  /// تا brute-force آفلاین فایل بکاپ عملاً غیرممکن شود (برخلاف v3 که از
  /// SHA-256 خام استفاده می‌کرد و با ۱۰٬۰۰۰ ترکیب ۴ رقمی فوراً قابل
  /// شکستن بود).
  static const int _kdfIterations = 150000;

  static Future<SecretKey> _buildLegacyKey() async {
    final hash = await Sha256().hash(_legacyAppKey);
    return SecretKey(hash.bytes);
  }

  /// v3 (قدیمی) — فقط برای خواندن بکاپ‌های قبلی.
  static Future<SecretKey> _buildPinKey(String pin) async {
    final hash = await Sha256().hash(utf8.encode('kudake-backup-v3:$pin'));
    return SecretKey(hash.bytes);
  }

  /// v4 — مشتق‌سازی مقاوم کلید از PIN.
  static Future<SecretKey> _buildPinKeyV4(String pin, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _kdfIterations,
      bits: 256,
    );
    return pbkdf2.deriveKeyFromPassword(
      password: 'kudake-backup-v4:$pin',
      nonce: salt,
    );
  }

  /// خروجی بکاپ رمزنگاری‌شدهٔ AES-GCM (فرمت v3 وابسته به PIN والدین)
  static Future<String> exportBackup({required String pin}) async {
    if (!await GameData.verifyParentPin(pin)) {
      throw StateError('parent pin required for backup export');
    }
    // The last write may still be queued after a game reward. Flush it before
    // reading Hive so the exported file contains the newest progress.
    await GameData.save();
    final snapshot = await HivePlayerStore.readSnapshot() ?? <String, dynamic>{};
    // اگر Hive خالی بود، از GameData snapshot بساز (fallback)
    final effective = snapshot.isEmpty ? _fallbackSnapshot() : snapshot;
    final jsonStr = jsonEncode(effective);
    final clearText = utf8.encode(jsonStr);

    // v4: salt تصادفی + PBKDF2 — فایل بکاپ دیگر با دیکشنری PIN شکسته
    // نمی‌شود و حتی دو بکاپ با یک PIN خروجی کاملاً متفاوت دارند.
    final salt = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
    final secretKey = await _buildPinKeyV4(pin, salt);
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      clearText,
      secretKey: secretKey,
      nonce: nonce,
    );

    final payload = jsonEncode({
      'v': 4,
      'salt': base64Encode(salt),
      'iv': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'data': base64Encode(secretBox.cipherText),
      'date': DateTime.now().toIso8601String(),
    });

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

  /// بازیابی از فایل .parsa — v3 با PIN؛ v2 قدیمی فقط برای سازگاری
  static Future<bool> importBackup(String filePath, {required String pin}) async {
    try {
      if (!await GameData.verifyParentPin(pin)) return false;
      final file = File(filePath);
      if (!await file.exists()) return false;
      final content = await file.readAsString();
      if (content.length > 2 * 1024 * 1024) return false;
      final map = jsonDecode(content) as Map<String, dynamic>;
      final version = map['v'] as int? ?? 1;

      final String jsonStr;
      if (version == 4) {
        final salt = map['salt'] as String?;
        if (salt == null || salt.isEmpty) return false;
        final List<int> saltBytes;
        try {
          saltBytes = base64Decode(salt);
        } catch (_) {
          return false;
        }
        if (saltBytes.length < 8 || saltBytes.length > 64) return false;
        jsonStr = await _decryptPayload(map, await _buildPinKeyV4(pin, saltBytes));
      } else if (version == 3) {
        jsonStr = await _decryptPayload(map, await _buildPinKey(pin));
      } else if (version == 2) {
        jsonStr = await _decryptPayload(map, await _buildLegacyKey());
      } else {
        return false;
      }

      final snapshot = jsonDecode(jsonStr) as Map<String, dynamic>;
      final keepPinHash = GameData.parentPinHash;
      // Let any reward write already queued by the current session finish
      // before the imported snapshot becomes the source of truth.
      await GameData.save();
      await HivePlayerStore.writeSnapshot(snapshot);
      await GameData.reload();
      if (keepPinHash.isNotEmpty && GameData.parentPinHash != keepPinHash) {
        GameData.parentPinHash = keepPinHash;
        await GameData.save();
      }
      // همگام‌سازی کپی امن (Keystore) با وضعیت نهایی پین بعد از import.
      await GameData.persistPinHashToSecureStore();
      HapticFeedback.heavyImpact();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String> _decryptPayload(
    Map<String, dynamic> map,
    SecretKey secretKey,
  ) async {
    final iv = base64Decode(map['iv'] as String);
    final mac = base64Decode(map['mac'] as String);
    final cipher = base64Decode(map['data'] as String);
    final secretBox = SecretBox(
      cipher,
      nonce: iv,
      mac: Mac(mac),
    );
    final clear = await _algorithm.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(clear);
  }

  /// Opens the native document picker and imports a selected `.parsa` file.
  /// Android copies the content URI to a private temporary file first, so the
  /// crypto layer stays platform-independent and never needs broad storage
  /// permissions.
  static Future<bool> pickAndImportBackup({required String pin}) async {
    try {
      final path = await _fileChannel.invokeMethod<String>('pickBackupFile');
      if (path == null || path.trim().isEmpty) return false;
      return importBackup(path, pin: pin);
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// مسیر پیشنهادی برای ذخیره در Downloads (برای اشتراک)
  static Future<String> get backupFilePath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_fileName';
  }
}
