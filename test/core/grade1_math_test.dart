import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/math/grade1_math.dart';

void main() {
  test('first grade stays within 0-20 and never multiplies', () {
    expect(Grade1Math.maxNumber, 20);
    expect(Grade1Math.isValidAdd(10, 10), isTrue);
    expect(Grade1Math.isValidAdd(11, 10), isFalse);
    expect(Grade1Math.isValidSubtract(12, 5), isTrue);
    expect(Grade1Math.isValidSubtract(5, 12), isFalse);
    expect(Grade1Math.equation(3, '+', 4), contains('۳'));
    expect(Grade1Math.equation(3, '+', 4), isNot(contains('*')));
    expect(Grade1Math.equation(3, '+', 4), isNot(contains('×')));
  });

  test('place-value targets stay inside first-grade numbers', () {
    expect(Grade1Math.placeValueTargets, isNot(contains(23)));
    expect(Grade1Math.placeValueTargets, isNot(contains(30)));
    expect(Grade1Math.placeValueTargets, isNot(contains(32)));
    for (final n in Grade1Math.placeValueTargets) {
      expect(Grade1Math.isInRange(n), isTrue, reason: '$n is not first-grade');
    }
    expect(Grade1Math.placeValuePhrase(14), contains('یک ده'));
    expect(Grade1Math.placeValuePhrase(14), contains('۴ یکی'));
    expect(Grade1Math.placeValuePhrase(20), 'دو ده');
  });

  test('generated add/subtract stays in first grade and level 1 stays to 10', () {
    final rng = Random(7);
    for (var i = 0; i < 40; i++) {
      final easy = Grade1Math.nextAddOrSubtract(random: rng, level: 1);
      final sum = easy.$3 == '+' ? easy.$1 + easy.$2 : easy.$1 - easy.$2;
      expect(sum, lessThanOrEqualTo(10));
      if (easy.$3 == '+') {
        expect(Grade1Math.isValidAdd(easy.$1, easy.$2), isTrue);
      } else {
        expect(Grade1Math.isValidSubtract(easy.$1, easy.$2), isTrue);
      }
      final hard = Grade1Math.nextAddOrSubtract(random: rng, level: 3);
      if (hard.$3 == '+') {
        expect(Grade1Math.isValidAdd(hard.$1, hard.$2), isTrue);
      } else {
        expect(Grade1Math.isValidSubtract(hard.$1, hard.$2), isTrue);
      }
    }
  });
}
