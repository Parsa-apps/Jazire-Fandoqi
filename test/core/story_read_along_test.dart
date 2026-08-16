import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/literacy/story_read_along.dart';

void main() {
  test('story text splits into first-grade sentences', () {
    const text =
        'فندقی لبخند زد. پشمالو گفت: نگران نباش! ما راهی پیدا می‌کنیم؟';
    final lines = StoryReadAlong.sentences(text);
    expect(lines.length, greaterThanOrEqualTo(2));
    expect(lines.first, contains('فندقی'));
    expect(lines.last, contains('راهی'));
  });

  test('progress lights the matching sentence then the matching word', () {
    const lines = ['بابا آب داد.', 'سیب سرخ است.'];
    expect(StoryReadAlong.activeIndex(lines, 0.1), 0);
    expect(StoryReadAlong.activeIndex(lines, 0.8), 1);

    final words = StoryReadAlong.words('بابا آب داد.');
    expect(words, ['بابا', 'آب', 'داد.']);
    expect(StoryReadAlong.activeIndex(words, 0.1), 0);
    expect(StoryReadAlong.activeIndex(words, 0.9), words.length - 1);
  });
}
