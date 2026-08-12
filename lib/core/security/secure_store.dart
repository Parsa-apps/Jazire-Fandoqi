import 'package:flutter/services.dart';

/// 🔐 Keystore-backed secure storage bridge (Android native side).
///
/// Used for high-value values that must survive a plaintext file edit: the
/// premium entitlement grant and the parent PIN hash. The native side
/// encrypts with an Android-Keystore AES-256/GCM key, so editing the Hive or
/// SharedPreferences files cannot forge these values.
///
/// On unsupported platforms (or when the native module is missing) reads
/// return null and writes are dropped silently — the app never crashes
/// because secure storage is unavailable; callers must treat null as "not
/// granted / not set" (fail closed).
class SecureStore {
  SecureStore._();

  static const MethodChannel _channel = MethodChannel('kudake_iran/secure_store');
  static final Map<String, String?> _cache = <String, String?>{};

  static Future<String?> read(String key) async {
    if (_cache.containsKey(key)) return _cache[key];
    try {
      final value = await _channel.invokeMethod<String>(
        'read',
        <String, Object?>{'key': key},
      );
      _cache[key] = value;
      return value;
    } catch (_) {
      _cache[key] = null;
      return null;
    }
  }

  static Future<void> write(String key, String value) async {
    _cache[key] = value;
    try {
      await _channel.invokeMethod<void>(
        'write',
        <String, Object?>{'key': key, 'value': value},
      );
    } catch (_) {
      // Best effort — a failing secure write must not crash the app.
    }
  }

  static Future<void> delete(String key) async {
    _cache[key] = null;
    try {
      await _channel.invokeMethod<void>(
        'delete',
        <String, Object?>{'key': key},
      );
    } catch (_) {
      // Best effort.
    }
  }
}
