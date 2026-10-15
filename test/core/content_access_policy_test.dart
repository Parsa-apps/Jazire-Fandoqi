import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/core/learning_content/children_stories_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/lullabies_data.dart';

void main() {
  group('ContentAccessPolicy', () {
    test('only the first two canonical cartoons are free', () {
      final cartoons = CartoonData.allCartoons;

      expect(ContentAccessPolicy.isCartoonFree(cartoons[0].id), isTrue);
      expect(ContentAccessPolicy.isCartoonFree(cartoons[1].id), isTrue);
      expect(ContentAccessPolicy.isCartoonFree(cartoons[2].id), isFalse);
      expect(ContentAccessPolicy.isCartoonFree('missing-cartoon'), isFalse);
    });

    test('only the first two canonical stories are free', () {
      final stories = ChildrenStoriesData.allStories;

      expect(ContentAccessPolicy.isStoryFree(stories[0].id), isTrue);
      expect(ContentAccessPolicy.isStoryFree(stories[1].id), isTrue);
      expect(ContentAccessPolicy.isStoryFree(stories[2].id), isFalse);
      expect(ContentAccessPolicy.isStoryFree('missing-story'), isFalse);
      expect(ContentAccessPolicy.isStoryFree('decodable-baba-ab'), isTrue);
    });

    test('only the first two canonical lullabies are free', () {
      final lullabies = LullabiesData.all;

      expect(ContentAccessPolicy.isLullabyFree(lullabies[0].id), isTrue);
      expect(ContentAccessPolicy.isLullabyFree(lullabies[1].id), isTrue);
      expect(ContentAccessPolicy.isLullabyFree(lullabies[2].id), isFalse);
      expect(ContentAccessPolicy.isLullabyFree('missing-lullaby'), isFalse);
    });

    test('alphabet top row and first-grade numbers 1-10 stay free', () {
      expect(ContentAccessPolicy.isAlphabetLessonFree(0), isTrue);
      expect(ContentAccessPolicy.isAlphabetLessonFree(7), isTrue);
      expect(ContentAccessPolicy.isAlphabetLessonFree(8), isFalse);
      expect(ContentAccessPolicy.isAlphabetLessonFree(-1), isFalse);

      expect(ContentAccessPolicy.isNumberFree(1), isTrue);
      expect(ContentAccessPolicy.isNumberFree(10), isTrue);
      expect(ContentAccessPolicy.isNumberFree(11), isFalse);
      expect(ContentAccessPolicy.isNumberFree(0), isFalse);
    });

    test('free game hubs are centrally allowlisted and premium games fail closed', () {
      for (final game in <String>[
        'اشکال',
        'مسابقه',
        'شهر بازی‌ها',
        'حرف اول',
        'شمارش خوش',
        'بزرگ و کوچک',
        'ترتیب اعداد',
        'متفاوت را پیدا کن',
        'داستان',
        'لالایی',
      ]) {
        expect(ContentAccessPolicy.isGameFree(game), isTrue, reason: game);
      }

      for (final game in <String>[
        'حافظه',
        'پازل',
        'الگو',
        'جزیره‌ساز',
        'کلمه‌ساز',
        'جمع تصویری',
        'حیوانات',
        'واژگان',
        'داستان ویژه',
      ]) {
        expect(ContentAccessPolicy.isGameFree(game), isFalse, reason: game);
      }
      expect(ContentAccessPolicy.isGameFree(' ناشناخته '), isFalse);
    });

    test('direct academy routes are free only for explicitly free topics', () {
      expect(ContentAccessPolicy.isAcademyTopicFree('colors'), isTrue);
      expect(ContentAccessPolicy.isAcademyTopicFree('shapes'), isTrue);
      for (final topic in <String>[
        'numbers',
        'animals',
        'fruits',
        'body',
        'jobs',
        'emotions',
        'concepts',
        'unknown',
        'COLORS',
      ]) {
        expect(ContentAccessPolicy.isAcademyTopicFree(topic), isFalse,
            reason: topic);
      }
    });
  });
}
