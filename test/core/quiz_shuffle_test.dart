import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/learning_content/children_stories_data.dart';
import 'package:jazireh_fandoghi/core/literacy/quiz_shuffle.dart';

void main() {
  test('shuffling keeps the same correct text, not always the first slot', () {
    const options = ['درست', 'غلط ۱', 'غلط ۲'];
    final first = ShuffledChoices.of(options, 0, random: Random(1));
    final second = ShuffledChoices.of(options, 0, random: Random(2));
    expect(first.options[first.correctIndex], 'درست');
    expect(second.options[second.correctIndex], 'درست');
    expect(first.options.toSet(), options.toSet());
  });

  test('story quizzes are not all first-option-correct after shuffle', () {
    var firstSlotWins = 0;
    var total = 0;
    for (final story in ChildrenStoriesData.allStories) {
      for (final q in story.quizQuestions) {
        total++;
        final shuffled = ShuffledChoices.of(
          q.options,
          q.correctIndex,
          random: Random(story.id.hashCode + q.question.hashCode),
        );
        if (shuffled.correctIndex == 0) firstSlotWins++;
        expect(shuffled.options[shuffled.correctIndex], q.options[q.correctIndex]);
      }
    }
    expect(total, greaterThan(10));
    expect(firstSlotWins, lessThan(total));
  });
}
