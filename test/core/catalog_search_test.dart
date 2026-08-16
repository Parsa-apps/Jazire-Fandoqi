import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/growth/catalog_search.dart';
import 'package:jazireh_fandoghi/core/growth/adaptive_coach.dart';
import 'package:jazireh_fandoghi/core/growth/vocabulary_journal.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';

void main() {
  setUp(() {
    GrowthStore.resetForTesting();
  });

  test('catalog covers games, stories, cartoons and life skills', () {
    final items = CatalogSearch.allItems();
    expect(items.length, greaterThan(20));
    final categories = items.map((e) => e.category).toSet();
    expect(categories, containsAll(<String>['قصه', 'کارتون', 'مهارت زندگی']));
  });

  test('empty query returns a starter set, unknown query returns empty', () {
    expect(CatalogSearch.query('').length, lessThanOrEqualTo(12));
    expect(CatalogSearch.query('zzz-not-a-real-item'), isEmpty);
  });

  test('query matches title, subtitle and tags', () {
    expect(CatalogSearch.query('ترافیک'), isNotEmpty);
    expect(CatalogSearch.query('لالایی'), isNotEmpty);
    expect(CatalogSearch.query('تمساح'), isNotEmpty);
    expect(CatalogSearch.query('قاب'), isNotEmpty);
    expect(CatalogSearch.query('املا'), isNotEmpty);
  });

  test('adaptive coach scales options and difficulty by age', () {
    expect(AdaptiveCoach.optionCountForAge(3), 2);
    expect(AdaptiveCoach.optionCountForAge(6), 3);
    expect(AdaptiveCoach.optionCountForAge(8), 4);
    expect(AdaptiveCoach.difficultyForAge(4), 1);
    expect(AdaptiveCoach.difficultyForAge(7), 3);
    expect(AdaptiveCoach.shouldSkip(2), isFalse);
    expect(AdaptiveCoach.shouldSkip(3), isTrue);
  });

  test('hint text gets kinder after repeated mistakes', () {
    expect(AdaptiveCoach.hintAfterMistakes(0, 'سیب'), isEmpty);
    expect(AdaptiveCoach.hintAfterMistakes(1, 'سیب'), contains('نزدیک بود'));
    expect(AdaptiveCoach.hintAfterMistakes(2, 'سیب'), contains('سیب'));
  });

  test('vocabulary journal dedupes and rejects long words', () {
    expect(VocabularyJournal.add('شنبه'), isTrue);
    expect(VocabularyJournal.add('شنبه'), isFalse);
    expect(VocabularyJournal.add(''), isFalse);
    expect(VocabularyJournal.add('ک' * 40), isFalse);
    expect(VocabularyJournal.count, 1);
    VocabularyJournal.addAll(['جمعه', 'شنبه', 'هفته']);
    expect(VocabularyJournal.words, ['شنبه', 'جمعه', 'هفته']);
  });
}
