import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';
import 'package:jazireh_fandoghi/core/content_access.dart';
import 'package:jazireh_fandoghi/core/learning_content/children_stories_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/lullabies_data.dart';

/// قوانین نسخهٔ رایگان یک قرارداد تجاری است؛ اگر کسی ترتیب داده‌ها را
/// عوض کند یا یک شرط را بردارد، این تست‌ها سریع می‌شکنند.
void main() {
  group('ContentAccess — نسخهٔ رایگان', () {
    test('فقط ۲ کارتون اول باز است', () {
      final all = CartoonData.allCartoons;
      expect(ContentAccess.isCartoonUnlocked(all[0].id), isTrue);
      expect(ContentAccess.isCartoonUnlocked(all[1].id), isTrue);
      for (final c in all.skip(2)) {
        expect(ContentAccess.isCartoonUnlocked(c.id), isFalse,
            reason: 'کارتون ${c.title} نباید رایگان باشد');
      }
    });

    test('فقط ۲ قصهٔ اول باز است', () {
      final all = ChildrenStoriesData.allStories;
      expect(ContentAccess.isStoryUnlocked(all[0].id), isTrue);
      expect(ContentAccess.isStoryUnlocked(all[1].id), isTrue);
      for (final s in all.skip(2)) {
        expect(ContentAccess.isStoryUnlocked(s.id), isFalse);
      }
    });

    test('فقط ۲ لالایی اول باز است', () {
      final all = LullabiesData.all;
      expect(ContentAccess.isLullabyUnlocked(all[0].id), isTrue);
      expect(ContentAccess.isLullabyUnlocked(all[1].id), isTrue);
      for (final l in all.skip(2)) {
        expect(ContentAccess.isLullabyUnlocked(l.id), isFalse);
      }
    });

    test('در الفبا فقط ردیف اول (۸ حرف) باز است', () {
      for (var i = 0; i < ContentAccess.alphabetRowSize; i++) {
        expect(ContentAccess.isLetterUnlocked(i), isTrue);
      }
      expect(ContentAccess.isLetterUnlocked(ContentAccess.alphabetRowSize),
          isFalse);
      expect(ContentAccess.isLetterUnlocked(31), isFalse);
    });

    test('در اعداد فقط ۲ عدد اول باز است', () {
      expect(ContentAccess.isNumberUnlocked(1), isTrue);
      expect(ContentAccess.isNumberUnlocked(2), isTrue);
      for (var n = 3; n <= 20; n++) {
        expect(ContentAccess.isNumberUnlocked(n), isFalse);
      }
    });

    test('واژگان و صدا در بخش فارسی قفل‌اند', () {
      expect(ContentAccess.isRouteUnlocked('/vocabulary'), isFalse);
      expect(ContentAccess.isRouteUnlocked('/sound_match'), isFalse);
      expect(ContentAccess.isGameUnlocked('واژگان'), isFalse);
      expect(ContentAccess.isGameUnlocked('صدا'), isFalse);
    });

    test('همهٔ موارد بخش علوم قفل‌اند', () {
      for (final route in ['/animals', '/body_parts', '/life-skills', '/concepts']) {
        expect(ContentAccess.isRouteUnlocked(route), isFalse,
            reason: '$route باید در نسخه رایگان قفل باشد');
      }
      for (final game in ['حیوانات', 'بدن', 'مهارت زندگی', 'مفاهیم']) {
        expect(ContentAccess.isGameUnlocked(game), isFalse);
      }
    });

    test('بازی‌های پایه همچنان رایگان می‌مانند', () {
      for (final game in ContentAccess.freeGameNames) {
        expect(ContentAccess.isGameUnlocked(game), isTrue);
      }
    });
  });
}
