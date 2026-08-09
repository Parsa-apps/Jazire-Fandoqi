import 'package:flutter_test/flutter_test.dart';
import 'package:amoozesh_fandoghi/core/ai_system.dart';
import 'package:amoozesh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:amoozesh_fandoghi/core/game_data.dart';

void main() {
  setUp(() {
    GameData.resetForTesting();
  });

  test('cartoon catalog has valid data and categories', () {
    expect(CartoonData.allCartoons.length, greaterThanOrEqualTo(15));

    final ids = CartoonData.allCartoons.map((c) => c.id).toSet();
    expect(ids.length, CartoonData.allCartoons.length, reason: 'شناسه کارتون‌ها نباید تکراری باشد');

    for (final cartoon in CartoonData.allCartoons) {
      expect(cartoon.title, isNotEmpty);
      expect(cartoon.description, isNotEmpty);
      expect(cartoon.episodes, isNotEmpty);
      expect(cartoon.catchphrase, isNotEmpty);
      for (final ep in cartoon.episodes) {
        expect(ep.id, isNotEmpty);
        expect(ep.title, isNotEmpty);
        expect(ep.duration, isNotEmpty);
        expect(ep.webUrl, isNotEmpty);
      }
    }
  });

  test('featured cartoons and category filter work accurately', () {
    final featured = CartoonData.getFeatured();
    expect(featured, isNotEmpty);

    final iranian = CartoonData.getByCategory(CartoonCategoryType.iranian);
    expect(iranian, isNotEmpty);
    for (final c in iranian) {
      expect(c.category, CartoonCategoryType.iranian);
    }
  });

  test('search finds cartoons by name and keywords', () {
    final results = CartoonData.search('شکرستان');
    expect(results, isNotEmpty);
    expect(results.first.title, contains('شکرستان'));

    final pahlavan = CartoonData.search('پوریای ولی');
    expect(pahlavan, isNotEmpty);
  });

  test('AI suggests cartoon appropriate for child age', () {
    GameData.childAge = 4;
    final youngSuggestion = AI.suggestCartoon();
    expect(youngSuggestion, isNotEmpty);

    GameData.childAge = 8;
    final olderSuggestion = AI.suggestCartoon();
    expect(olderSuggestion, isNotEmpty);
  });
}
