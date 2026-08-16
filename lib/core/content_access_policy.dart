import 'cartoons/cartoon_data.dart';
import 'learning_content/children_stories_data.dart';
import 'learning_content/lullabies_data.dart';
import 'literacy/decodable_stories.dart';

/// The single source of truth for partially-free content collections.
///
/// Item identity is checked against each collection's canonical order. This
/// keeps filtering, searching, and featured carousels from accidentally making
/// a premium item free just because it appears first in a filtered list.
abstract final class ContentAccessPolicy {
  static const int freeCartoonCount = 2;
  static const int freeStoryCount = 2;
  static const int freeLullabyCount = 2;
  static const int freeAlphabetTopRowCount = 8;
  /// شمارش ۱ تا ۱۰ هستهٔ ریاضی اول دبستان است و نباید پشت پرداخت قفل شود.
  static const int freeNumberCount = 10;

  static bool isCartoonFree(String id) => _isAmongFirst(
        id,
        CartoonData.allCartoons.map((item) => item.id),
        freeCartoonCount,
      );

  static bool isStoryFree(String id) {
    if (DecodableStories.isDecodableId(id)) return true;
    return _isAmongFirst(
      id,
      ChildrenStoriesData.allStories.map((item) => item.id),
      freeStoryCount,
    );
  }

  static bool isLullabyFree(String id) => _isAmongFirst(
        id,
        LullabiesData.all.map((item) => item.id),
        freeLullabyCount,
      );

  static bool isAlphabetLessonFree(int index) =>
      index >= 0 && index < freeAlphabetTopRowCount;

  static bool isNumberFree(int number) =>
      number >= 1 && number <= freeNumberCount;

  static bool _isAmongFirst(
    String id,
    Iterable<String> orderedIds,
    int freeCount,
  ) {
    var index = 0;
    for (final candidate in orderedIds) {
      if (candidate == id) return index < freeCount;
      index++;
    }
    return false;
  }
}
