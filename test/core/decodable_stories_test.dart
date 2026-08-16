import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/literacy/decodable_stories.dart';

void main() {
  setUp(GameData.resetForTesting);

  test('every decodable page uses only its allowed letters', () {
    expect(DecodableStories.all.length, greaterThanOrEqualTo(8));
    for (final story in DecodableStories.all) {
      expect(DecodableStories.isDecodableId(story.id), isTrue);
      expect(story.pages.length, inInclusiveRange(2, 4));
      expect(DecodableStories.usesOnly(story.title, story.allowedLetters), isTrue,
          reason: '${story.id} title sneaks a later letter');
      for (final page in story.pages) {
        expect(page.split(' ').length, lessThanOrEqualTo(5),
            reason: '${story.id} page is too long for grade 1: $page');
        expect(
          DecodableStories.usesOnly(page, story.allowedLetters),
          isTrue,
          reason: '${story.id} page "$page" uses ${DecodableStories.lettersIn(page)}',
        );
      }
    }
  });

  test('مادر waits for ر and سیب waits for ی', () {
    final early = DecodableStories.all
        .where((s) => !s.allowedLetters.contains('ر'))
        .expand((s) => [...s.pages, s.title]);
    expect(early.any((t) => t.contains('مادر')), isFalse);

    final beforeYe = DecodableStories.all
        .where((s) => !s.allowedLetters.contains('ی'))
        .expand((s) => [...s.pages, s.title]);
    expect(beforeYe.any((t) => t.contains('سیب')), isFalse);
    expect(beforeYe.any((t) => t.contains('ایران')), isFalse);
  });

  test('first story is only آ ا ب and stays locked until ب', () {
    final first = DecodableStories.all.first;
    expect(first.allowedLetters, {'آ', 'ا', 'ب'});
    expect(DecodableStories.lettersIn(first.pages.join()), {'آ', 'ا', 'ب'});
    expect(DecodableStories.isUnlocked(first), isFalse);

    GameData.markAlphabetMastered('g1-0-0');
    expect(DecodableStories.isUnlocked(first), isFalse);

    GameData.markAlphabetMastered('g1-0-1');
    expect(DecodableStories.isUnlocked(first), isTrue);
  });

  test('today picks the hardest unread unlocked story', () {
    GameData.markAlphabetMastered('g1-0-1');
    GameData.markAlphabetMastered('g1-0-3');
    expect(DecodableStories.forToday().id, 'decodable-baba-dad');

    GameData.markStoryCompleted('decodable-baba-dad');
    expect(DecodableStories.forToday().id, 'decodable-baba-ab');
  });

  test('alpha-mode letters can unlock the first reader', () {
    expect(
      DecodableStories.isUnlocked(
        DecodableStories.all.first,
        masteredKeys: ['alpha-0', 'alpha-1', 'alpha-2'],
      ),
      isTrue,
    );
  });

  test('decodable readers are free classroom work, not a paywall', () {
    for (final story in DecodableStories.all) {
      expect(ContentAccessPolicy.isStoryFree(story.id), isTrue);
    }
    expect(ContentAccessPolicy.isStoryFree('missing-story'), isFalse);
  });
}
