import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/life_skills_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/learning_topics.dart';
import 'package:jazireh_fandoghi/core/literacy/decodable_stories.dart';
import 'package:jazireh_fandoghi/core/literacy/literacy_path.dart';
import 'package:jazireh_fandoghi/core/math/grade1_math.dart';

/// قفل معلم کلاس اول: محتوا نباید چیز غلط یاد بدهد.
void main() {
  test('numbers 1-20 show the numeral itself, never a fruit or cake', () {
    final numbers = learningTopicById('numbers')!;
    expect(numbers.cards.length, 20);

    const fruits = {'🍎', '🍏', '🍊', '🍇', '🍉', '🍒', '🍑', '🍍', '🥝', '🎂', '🎉'};
    const expected = {
      'n1': '۱',
      'n2': '۲',
      'n3': '۳',
      'n4': '۴',
      'n5': '۵',
      'n6': '۶',
      'n7': '۷',
      'n8': '۸',
      'n9': '۹',
      'n10': '۱۰',
      'n11': '۱۱',
      'n12': '۱۲',
      'n13': '۱۳',
      'n14': '۱۴',
      'n15': '۱۵',
      'n16': '۱۶',
      'n17': '۱۷',
      'n18': '۱۸',
      'n19': '۱۹',
      'n20': '۲۰',
    };

    for (final card in numbers.cards) {
      expect(fruits.contains(card.emoji), isFalse, reason: '${card.id} must not be a fruit');
      expect(card.emoji, expected[card.id], reason: '${card.id} must show its Persian numeral');
    }

    expect(numbers.cards.firstWhere((c) => c.id == 'n11').fact, 'ده و یک');
    expect(numbers.cards.firstWhere((c) => c.id == 'n20').fact, 'دو بسته ده‌تایی');
  });

  test('cat says meow, not misha', () {
    final animals = learningTopicById('animals')!;
    final cat = animals.cards.firstWhere((c) => c.id == 'a14');
    expect(cat.fact, contains('میو'));
    expect(cat.fact, isNot(contains('میشا')));
  });

  test('leopard is not taught as a tiger', () {
    final animals = learningTopicById('animals')!;
    final leopard = animals.cards.firstWhere((c) => c.id == 'a5');
    expect(leopard.emoji, isNot('🐅'));
  });

  test('shapes do not reuse color swatches or an octagon stop sign', () {
    final shapes = learningTopicById('shapes')!;
    final square = shapes.cards.firstWhere((c) => c.id == 's2');
    final rectangle = shapes.cards.firstWhere((c) => c.id == 's4');
    final diamond = shapes.cards.firstWhere((c) => c.id == 's8');
    final pentagon = shapes.cards.firstWhere((c) => c.id == 's10');
    final colors = learningTopicById('colors')!;
    final gold = colors.cards.firstWhere((c) => c.id == 'c12');

    expect(square.emoji, isNot(gold.emoji));
    expect(rectangle.emoji, isNot('📏'));
    expect(diamond.emoji, isNot('💎'));
    expect(pentagon.emoji, isNot('🛑'));
  });

  test('rhyme lesson does not claim باران rhymes with بهار', () {
    final rhymes = LifeSkillsData.byId('rhymes')!;
    final rain = rhymes.questions.firstWhere((q) => q.id == 'r3');
    expect(rain.options.contains('بهار'), isFalse);
    expect(rain.fact.toLowerCase(), isNot(contains('بهار')));
    expect(rain.options[rain.correctIndex], 'یاران');
  });

  test('alphabet mastery is sequential and does not mark empty keys', () {
    GameData.resetForTesting();
    expect(GameData.isAlphabetMastered('g1-0-0'), isFalse);
    expect(GameData.markAlphabetMastered(''), isFalse);
    expect(GameData.markAlphabetMastered('g1-0-0'), isTrue);
    expect(GameData.isAlphabetMastered('g1-0-0'), isTrue);
    expect(GameData.markAlphabetMastered('g1-0-0'), isFalse);
    expect(GameData.isAlphabetMastered('g1-0-1'), isFalse);
    expect(GameData.markAlphabetMastered('g1-0-1'), isTrue);
    expect(GameData.isAlphabetMastered('g1-0-1'), isTrue);
    expect(GameData.masteredAlphabetKeys, ['g1-0-0', 'g1-0-1']);
  });

  test('literacy first-letter keys keep او and ای intact', () {
    expect(LiteracyUnit.firstLetter('او و'), 'او');
    expect(LiteracyUnit.firstLetter('ایـ ی'), 'ای');
    expect(LiteracyUnit.forLesson('او و', 'توت').sentence, contains('توت'));
  });

  test('decodable stories do not ask a first-grader to read خروشان', () {
    for (final story in DecodableStories.all) {
      final blob = '${story.title} ${story.pages.join(' ')}';
      expect(blob.contains('خروشان'), isFalse);
      expect(blob.contains('کوله‌پشتی'), isFalse);
      expect(blob.split(RegExp(r'\s+')).length, lessThan(12));
      expect(DecodableStories.usesOnly(blob, story.allowedLetters), isTrue);
    }
  });

  test('place value does not jump to second-grade numbers', () {
    expect(Grade1Math.placeValueTargets.every(Grade1Math.isInRange), isTrue);
    expect(Grade1Math.placeValueTargets.any((n) => n > 20), isFalse);
  });

  test('money lesson stays in first-grade addition, not multiplication', () {
    final money = LifeSkillsData.byId('money')!;
    for (final question in money.questions) {
      expect(question.vocab, isNot('ضرب'), reason: '${question.id} must not teach multiplication');
      expect(question.fact.contains('×'), isFalse, reason: '${question.id} must not show a times sign');
      expect(question.prompt.contains('×'), isFalse);
    }
  });
}
