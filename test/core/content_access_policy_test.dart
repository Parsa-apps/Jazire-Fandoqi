import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/core/growth/life_skills_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/children_stories_data.dart';
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

    test('نیمهٔ اول قصه‌های تعاملی رایگان است و قصه‌های خواندنی همیشه باز', () {
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
      // قصه‌های کوتاه خواندنی با تسلط کودک باز می‌شوند و نباید قفل شوند.
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
      // حالت الفبایی سنتی (۳۳ نشانه) — ۸ نشانهٔ نخست.
      expect(ContentAccessPolicy.isAlphabetLessonFree(0), isTrue);
      expect(ContentAccessPolicy.isAlphabetLessonFree(7), isTrue);
      expect(ContentAccessPolicy.isAlphabetLessonFree(8), isFalse);
      expect(ContentAccessPolicy.isAlphabetLessonFree(-1), isFalse);

      // حالت کلاس اول (۸ بسته) — دو بستهٔ اول.
      expect(ContentAccessPolicy.isAlphabetBundleFree(0), isTrue);
      expect(ContentAccessPolicy.isAlphabetBundleFree(1), isTrue);
      expect(ContentAccessPolicy.isAlphabetBundleFree(2), isFalse);
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
        'استیکر',
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
        'واژگان',
        'صدا',
        'قاب ده‌تایی',
        'ساعت',
        'ارزش مکانی',
        'تقارن',
        'الگو',
        'مفاهیم',
        'حیوانات',
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

    test('آکادمی‌های مستقیم فقط برای موضوع‌های صریحاً رایگان باز است', () {
      for (final topic in <String>['colors', 'shapes', 'emotions', 'fruits']) {
        expect(ContentAccessPolicy.isAcademyTopicFree(topic), isTrue,
            reason: topic);
      }
      for (final topic in <String>[
        // اعداد عمداً قفل است: آکادمی اعداد ۱ تا ۲۰ را یک‌جا می‌دهد و
        // اگر رایگان شود قفل ۱۱ تا ۲۰ دور می‌خورد. مسیر درست: /numbers.
        'numbers',
        'animals',
        'body',
        'jobs',
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
