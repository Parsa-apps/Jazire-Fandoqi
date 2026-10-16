import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/core/growth/life_skills_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/children_stories_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/learning_topics.dart';
import 'package:jazireh_fandoghi/core/learning_content/lullabies_data.dart';

/// ⚖️ تستِ قراردادِ «نیمهٔ رایگان، نیمهٔ نسخهٔ کامل»
///
/// این تست قانون را از روی **خودِ داده** حساب می‌کند، نه از عددِ ثابت؛ پس اگر
/// مجموعه‌ای بزرگ یا کوچک شود، سهمِ رایگان خودبه‌خود درست می‌ماند و اگر کسی
/// ثابتی را دستکاری کند، تست قرمز می‌شود.
///
/// استثناهای عامدانه (در `ContentAccessPolicy` مستند شده‌اند):
///  * اعداد ۱ تا ۱۰ — هستهٔ ریاضی اول دبستان (۱۱ تا ۲۰ پولی)
///  * قصه‌های کوتاهِ خواندنی (`DecodableStories`) — تمرینِ حلقهٔ خواندن
void main() {
  group('قانونِ نصف/نصف روی مجموعه‌های مرتّب', () {
    test('کارتون‌ها: نیمهٔ اول رایگان، نیمهٔ دوم نه', () {
      final ids = CartoonData.allCartoons.map((c) => c.id).toList();
      final half = ids.length ~/ 2;
      expect(ContentAccessPolicy.freeCartoonCount, half);
      for (var i = 0; i < ids.length; i++) {
        expect(ContentAccessPolicy.isCartoonFree(ids[i]), i < half,
            reason: 'کارتون $i (${ids[i]})');
      }
      expect(ContentAccessPolicy.isCartoonFree('ناشناخته'), isFalse);
    });

    test('قصه‌های تعاملی: نیمهٔ اول رایگان، نیمهٔ دوم نه', () {
      final ids = ChildrenStoriesData.allStories.map((s) => s.id).toList();
      final half = ids.length ~/ 2;
      expect(ContentAccessPolicy.freeStoryCount, half);
      for (var i = 0; i < ids.length; i++) {
        expect(ContentAccessPolicy.isStoryFree(ids[i]), i < half,
            reason: 'قصهٔ $i (${ids[i]})');
      }
    });

    test('لالایی‌ها: نیمهٔ اول رایگان، نیمهٔ دوم نه', () {
      final ids = LullabiesData.all.map((l) => l.id).toList();
      final half = ids.length ~/ 2;
      expect(ContentAccessPolicy.freeLullabyCount, half);
      for (var i = 0; i < ids.length; i++) {
        expect(ContentAccessPolicy.isLullabyFree(ids[i]), i < half,
            reason: 'لالایی $i (${ids[i]})');
      }
    });

    test('مهارت زندگی: نیمهٔ اول رایگان، نیمهٔ دوم نه', () {
      final ids = LifeSkillsData.topics.map((t) => t.id).toList();
      final half = ids.length ~/ 2;
      expect(ContentAccessPolicy.freeLifeSkillCount, half);
      for (var i = 0; i < ids.length; i++) {
        expect(ContentAccessPolicy.isLifeSkillFree(ids[i]), i < half,
            reason: 'دنیای $i (${ids[i]})');
      }
    });
  });

  group('موضوعات یادگیری (حیوانات، شغل‌ها، مفاهیم، احساسات, ...)', () {
    test('هر موضوع دقیقاً نیمهٔ اولش را رایگان می‌دهد', () {
      for (final topic in learningTopics) {
        final half = topic.cards.length ~/ 2;
        for (var i = 0; i < topic.cards.length; i++) {
          expect(
            ContentAccessPolicy.isTopicCardFree(topic, topic.cards[i].id),
            i < half,
            reason: '${topic.id}: کارت $i (${topic.cards[i].name}) از '
                '${topic.cards.length} کارت — نیمه = $half',
          );
        }
      }
    });

    test('هیچ موضوعی کاملاً رایگان یا کاملاً پولی نیست', () {
      for (final topic in learningTopics) {
        expect(topic.cards.length, greaterThanOrEqualTo(2),
            reason: '${topic.id} آن‌قدر کوچک است که نصف/نصف معنا ندارد');
        final half = topic.cards.length ~/ 2;
        expect(half, greaterThan(0), reason: topic.id);
        expect(half, lessThan(topic.cards.length), reason: topic.id);
      }
    });

    test('allowedTopicCards نیمهٔ پولی را از pool بیرون می‌گذارد', () {
      for (final topic in learningTopics) {
        final half = topic.cards.length ~/ 2;
        final freePool = ContentAccessPolicy.allowedTopicCards(
          topic,
          hasFullVersion: false,
        );
        expect(freePool.length, half, reason: topic.id);
        expect(
          freePool.map((c) => c.id),
          topic.cards.take(half).map((c) => c.id),
          reason: '${topic.id}: pool باید همان ترتیبِ کتاب باشد',
        );

        final fullPool = ContentAccessPolicy.allowedTopicCards(
          topic,
          hasFullVersion: true,
        );
        expect(fullPool.length, topic.cards.length, reason: topic.id);
      }
    });

    test('کارتِ ناشناخته قفل است (افزودنِ محتوا نشت نمی‌سازد)', () {
      final topic = learningTopics.first;
      expect(ContentAccessPolicy.isTopicCardFree(topic, 'کارت-جدید-ناشناخته'),
          isFalse);
    });
  });

  group('قاعدهٔ عمومی isFreeHalfItem', () {
    test('نیمهٔ اولِ هر فهرستِ مرتّب رایگان است', () {
      const ids = <String>['a', 'b', 'c', 'd', 'e'];
      expect(ContentAccessPolicy.isFreeHalfItem('a', ids), isTrue);
      expect(ContentAccessPolicy.isFreeHalfItem('b', ids), isTrue);
      expect(ContentAccessPolicy.isFreeHalfItem('c', ids), isFalse);
      expect(ContentAccessPolicy.isFreeHalfItem('d', ids), isFalse);
      expect(ContentAccessPolicy.isFreeHalfItem('e', ids), isFalse);
      // fail-closed
      expect(ContentAccessPolicy.isFreeHalfItem('z', ids), isFalse);
      expect(ContentAccessPolicy.isFreeHalfItem('', ids), isFalse);
    });

    test('فهرستِ تک‌عضوی رایگان نمی‌ماند (نیمه = ۰)', () {
      const ids = <String>['تنها'];
      expect(ContentAccessPolicy.isFreeHalfItem('تنها', ids), isFalse);
    });
  });

  group('اعداد — استثنای آموزشیِ عمدی', () {
    test('۱ تا ۱۰ همیشه رایگان، ۱۱ تا ۲۰ پولی', () {
      for (var n = 1; n <= 10; n++) {
        expect(ContentAccessPolicy.isNumberFree(n), isTrue, reason: '$n');
      }
      for (var n = 11; n <= 20; n++) {
        expect(ContentAccessPolicy.isNumberFree(n), isFalse, reason: '$n');
      }
    });
  });
}
