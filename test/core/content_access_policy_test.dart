import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/core/growth/life_skills_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/children_stories_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/learning_topics.dart';
import 'package:jazireh_fandoghi/core/learning_content/lullabies_data.dart';

void main() {
  group('ContentAccessPolicy — نیمهٔ رایگان، نیمهٔ نسخهٔ کامل', () {
    test('نیمهٔ اول کارتون‌ها رایگان است و نیمهٔ دوم نه', () {
      final cartoons = CartoonData.allCartoons;
      final half = cartoons.length ~/ 2;

      expect(ContentAccessPolicy.freeCartoonCount, half);
      for (var i = 0; i < cartoons.length; i++) {
        expect(
          ContentAccessPolicy.isCartoonFree(cartoons[i].id),
          i < half,
          reason: 'کارتون شمارهٔ $i: ${cartoons[i].id}',
        );
      }
      expect(ContentAccessPolicy.isCartoonFree('missing-cartoon'), isFalse);
    });

    test('نیمهٔ اول قصه‌ها رایگان است', () {
      final stories = ChildrenStoriesData.allStories;
      final half = stories.length ~/ 2;

      expect(ContentAccessPolicy.freeStoryCount, half);
      for (var i = 0; i < stories.length; i++) {
        expect(
          ContentAccessPolicy.isStoryFree(stories[i].id),
          i < half,
          reason: 'قصهٔ شمارهٔ $i: ${stories[i].id}',
        );
      }
      expect(ContentAccessPolicy.isStoryFree('missing-story'), isFalse);
      // نخستین قصهٔ خواندنی هم در نیمهٔ رایگان است.
      expect(ContentAccessPolicy.isStoryFree('decodable-baba-ab'), isTrue);
    });

    test('نیمهٔ اول لالایی‌ها رایگان است و نیمهٔ دوم نه', () {
      final lullabies = LullabiesData.all;
      final half = lullabies.length ~/ 2;

      expect(ContentAccessPolicy.freeLullabyCount, half);
      for (var i = 0; i < lullabies.length; i++) {
        expect(
          ContentAccessPolicy.isLullabyFree(lullabies[i].id),
          i < half,
          reason: 'لالایی شمارهٔ $i: ${lullabies[i].id}',
        );
      }
      expect(ContentAccessPolicy.isLullabyFree('missing-lullaby'), isFalse);
    });

    test('نیمهٔ اول دنیاهای مهارت زندگی رایگان است (بر پایهٔ id)', () {
      final topics = LifeSkillsData.topics;
      final half = topics.length ~/ 2;

      expect(ContentAccessPolicy.freeLifeSkillCount, half);
      for (var i = 0; i < topics.length; i++) {
        expect(
          ContentAccessPolicy.isLifeSkillFree(topics[i].id),
          i < half,
          reason: 'دنیای شمارهٔ $i: ${topics[i].id}',
        );
      }
      // عنوان‌ها مرجع نیستند: تغییر متن نباید قفل را جابه‌جا کند.
      expect(ContentAccessPolicy.isLifeSkillFree('missing-world'), isFalse);
      expect(ContentAccessPolicy.isLifeSkillFree(''), isFalse);
    });

    test('الفبا: در حالت کلاس اول فقط بسته‌های ابتدایی رایگان‌اند', () {
      // حالت الفبایی سنتی (۳۳ نشانه) — نیمهٔ اول (۱۶ نشانه).
      expect(ContentAccessPolicy.isAlphabetLessonFree(0), isTrue);
      expect(ContentAccessPolicy.isAlphabetLessonFree(15), isTrue);
      expect(ContentAccessPolicy.isAlphabetLessonFree(16), isFalse);
      expect(ContentAccessPolicy.isAlphabetLessonFree(-1), isFalse);

      // حالت کلاس اول (۸ بسته) — نصفِ بسته‌ها (۴ بسته).
      expect(ContentAccessPolicy.isAlphabetBundleFree(0), isTrue);
      expect(ContentAccessPolicy.isAlphabetBundleFree(3), isTrue);
      expect(ContentAccessPolicy.isAlphabetBundleFree(4), isFalse);
      expect(ContentAccessPolicy.isAlphabetBundleFree(-1), isFalse);
    });

    test('اعداد ۱ تا ۱۰ همیشه رایگان می‌مانند (هستهٔ ریاضی اول)', () {
      expect(ContentAccessPolicy.isNumberFree(1), isTrue);
      expect(ContentAccessPolicy.isNumberFree(10), isTrue);
      expect(ContentAccessPolicy.isNumberFree(11), isFalse);
      expect(ContentAccessPolicy.isNumberFree(0), isFalse);
    });

    test('فهرست رایگان بازی‌ها مرکزی است و بازی پولی، بسته شکست می‌خورد', () {
      for (final game in <String>[
        // هاب‌های نیمه‌رایگان (ورودشان باید باز بماند)
        'الفبا',
        'املا',
        'داستان',
        'کتابخانه',
        'اعداد',
        'شهر بازی‌ها',
        'مهارت زندگی',
        'لالایی',
        // آیتم‌های پایه
        'جمع',
        'مسابقه',
        'تمساح',
        // ابزارهای شمارش‌سطح اول دبستان
        'چوب‌خط',
        'محور اعداد',
        'حباب‌ترکان',
        'بدن',
        'احساسات',
        'رنگ‌ها',
        'اشکال',
        'میوه',
        'میوه‌ها', // Stage-map alias, the same partially-free academy.
        'استیکر',
        // مجموعه‌های نیمه‌رایگانی که درِ ورودشان باید باز باشد
        'حیوانات',
        'شغل‌ها',
        'مفاهیم',
        'واژگان',
        // بازی‌های رایگان کارناوال
        'حرف اول',
        'شمارش خوش',
        'بزرگ و کوچک',
        'ترتیب اعداد',
        'متفاوت را پیدا کن',
      ]) {
        expect(ContentAccessPolicy.isGameFree(game), isTrue, reason: game);
      }

      for (final game in <String>[
        // نیمهٔ پولی هر بخش
        'صدا',
        'قاب ده‌تایی',
        'ساعت',
        'ارزش مکانی',
        'تقارن',
        'الگو',
        'ستاره‌گیری',
        'حافظه',
        'پازل',
        'جزیره‌ساز',
        'نقاشی',
        'آلبوم نقاشی',
        // بازی‌های پولی کارناوال
        'کلمه‌ساز',
        'جمع تصویری',
        'جورچین شکل‌ها',
        'ترکیب رنگ',
        'سبد دسته‌بندی',
        // مسیر قصه‌های خارج از مجموعهٔ استاندارد
        'داستان ویژه',
        ' ناشناخته ',
      ]) {
        expect(ContentAccessPolicy.isGameFree(game), isFalse, reason: game);
      }
    });

    test('all known academies have a free half; unknown topics stay locked', () {
      for (final topic in learningTopics) {
        expect(ContentAccessPolicy.isAcademyTopicFree(topic.id), isTrue,
            reason: topic.id);
      }
      expect(ContentAccessPolicy.isAcademyTopicFree('unknown'), isFalse);
      expect(ContentAccessPolicy.isAcademyTopicFree('COLORS'), isFalse);
    });

    test('alphabet search retains canonical letter identity', () {
      final letters = List.generate(33, (index) => 'letter-$index');
      expect(ContentAccessPolicy.isAlphabetLetterFree('letter-0', letters), isTrue);
      expect(ContentAccessPolicy.isAlphabetLetterFree('letter-15', letters), isTrue);
      expect(ContentAccessPolicy.isAlphabetLetterFree('letter-16', letters), isFalse);
      expect(ContentAccessPolicy.isAlphabetLetterFree('letter-32', letters), isFalse);
      expect(ContentAccessPolicy.isAlphabetLetterFree('unknown', letters), isFalse);
    });
  });
}
