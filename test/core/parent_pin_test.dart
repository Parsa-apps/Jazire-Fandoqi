import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';

void main() {
  setUp(() {
    GameData.resetForTesting();
  });

  test('parent PIN is rejected unless it is exactly four digits', () {
    expect(GameData.setParentPin('12'), isFalse);
    expect(GameData.setParentPin('abcd'), isFalse);
    expect(GameData.setParentPin('12345'), isFalse);
    expect(GameData.hasParentPin(), isFalse);
    expect(GameData.setParentPin('2580'), isTrue);
    expect(GameData.hasParentPin(), isTrue);
  });

  test('parent PIN is stored as a hash and verified without the raw value', () {
    expect(GameData.setParentPin('2580'), isTrue);
    expect(GameData.parentPinHash, isNotEmpty);
    expect(GameData.parentPinHash.contains('2580'), isFalse);
    expect(GameData.verifyParentPin('2580'), isTrue);
    expect(GameData.verifyParentPin('0000'), isFalse);
    expect(GameData.verifyParentPin('258'), isFalse);
  });

  test('removing the parent PIN clears the stored hash', () {
    GameData.setParentPin('1470');
    GameData.removeParentPin();
    expect(GameData.hasParentPin(), isFalse);
    expect(GameData.verifyParentPin('1470'), isFalse);
  });
}
