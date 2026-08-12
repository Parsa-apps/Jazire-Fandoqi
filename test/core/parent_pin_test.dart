import 'dart:convert';

import 'package:cryptography/dart.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/security/secure_store.dart';

void main() {
  setUp(() async {
    GameData.resetForTesting();
    // پاک‌کردن کش امن بین تست‌ها (channel در تست نصب نیست).
    await SecureStore.delete('parent_pin_hash');
  });

  test('parent PIN is rejected unless it is exactly four digits', () async {
    expect(await GameData.setParentPin('12'), isFalse);
    expect(await GameData.setParentPin('abcd'), isFalse);
    expect(await GameData.setParentPin('12345'), isFalse);
    expect(GameData.hasParentPin(), isFalse);
    expect(await GameData.setParentPin('2580'), isTrue);
    expect(GameData.hasParentPin(), isTrue);
  });

  test('parent PIN is stored as a hardened hash and verified without the raw value',
      () async {
    expect(await GameData.setParentPin('2580'), isTrue);
    expect(GameData.parentPinHash, isNotEmpty);
    expect(GameData.parentPinHash.contains('2580'), isFalse);
    // هش جدید باید فرمت PBKDF2 (مقاوم در برابر brute-force) باشد.
    expect(GameData.parentPinHash.startsWith('pbkdf2:'), isTrue);
    expect(await GameData.verifyParentPin('2580'), isTrue);
    expect(await GameData.verifyParentPin('0000'), isFalse);
    expect(await GameData.verifyParentPin('258'), isFalse);
  });

  test('legacy SHA-256 hash is still verified and upgraded to PBKDF2', () async {
    // شبیه‌سازی هش قدیمی (قبل از ۶.۳)
    GameData.parentPinHash = _legacyHash('1470');
    expect(await GameData.verifyParentPin('1470'), isTrue);
    expect(GameData.parentPinHash.startsWith('pbkdf2:'), isTrue);
    expect(await GameData.verifyParentPin('1470'), isTrue);
  });

  test('removing the parent PIN clears the stored hash', () async {
    await GameData.setParentPin('1470');
    await GameData.removeParentPin();
    expect(GameData.hasParentPin(), isFalse);
    expect(await GameData.verifyParentPin('1470'), isFalse);
  });
}

/// همان فرمول قدیمی SHA-256 با دامنه‌ی یکسان — برای تست سازگاری.
String _legacyHash(String pin) {
  final digest = const DartSha256().hashSync(
    utf8.encode('fandoghi-parent-pin-v1:$pin'),
  );
  return base64Encode(digest.bytes);
}
