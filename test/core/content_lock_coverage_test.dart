import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 🔒 نگهبانِ پوششِ قفل محتوا
///
/// نشتِ قبلی از این جنس بود: قانون دسترسی در `ContentAccessPolicy` درست و
/// کامل بود و مسیر deep-link هم گیت شده بود، ولی **خودِ صفحه‌ای که مجموعه را
/// فهرست می‌کرد** مستقیم `MaterialPageRoute` می‌ساخت و از کنار قانون رد
/// می‌شد. نتیجه: نیمهٔ پولیِ آن مجموعه برای همه رایگان بود.
///
/// این تست‌ها جلوی تکرار همان خطا را می‌گیرند — هر صفحه‌ای که یک مجموعهٔ
/// محتواییِ تحتِ قانون را نشان می‌دهد، باید خودش هم قانون را صدا بزند.
void main() {
  final featureDir = Directory('lib/features');

  List<File> featureDartFiles() => featureDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  /// آیا این فایل به‌نحوی تصمیمِ دسترسی می‌گیرد؟
  ///
  /// یا قانون مرکزی را صدا می‌زند، یا درِ یکپارچهٔ `ensureContentAccess`
  /// را، یا خودش را پشتِ `GameAccessGate`/`Monetization` می‌برد.
  bool decidesAccess(String source) =>
      source.contains('ContentAccessPolicy') ||
      source.contains('ensureContentAccess') ||
      source.contains('Monetization') ||
      source.contains('showFullVersionPaywall') ||
      source.contains('GameAccessGate');

  test('هر صفحه‌ای که مجموعه‌ای تحتِ قانون را فهرست می‌کند، قانون را صدا می‌زند',
      () {
    // «منبعِ دادهٔ مجموعه» → توضیحِ مجموعه (برای پیامِ خطا)
    final collections = <String, String>{
      'LifeSkillsData.topics': 'دنیاهای مهارت زندگی (نیمهٔ دوم پولی)',
      'CartoonData.allCartoons': 'کارتون‌ها (نیمهٔ دوم پولی)',
      'ChildrenStoriesData.allStories': 'قصه‌های تعاملی (نیمهٔ دوم پولی)',
      'LullabiesData.all': 'لالایی‌ها (نیمهٔ دوم پولی)',
      'learningTopics': 'مجموعه‌های یادگیری (حیوانات، شغل‌ها، مفاهیم)',
    };

    for (final file in featureDartFiles()) {
      final source = file.readAsStringSync();
      for (final entry in collections.entries) {
        if (!source.contains(entry.key)) continue;
        expect(
          decidesAccess(source),
          isTrue,
          reason: '${file.path} مجموعهٔ «${entry.value}» را نشان می‌دهد '
              'ولی هیچ تصمیمِ دسترسی نمی‌گیرد؛ نیمهٔ پولی‌اش بی‌صدا رایگان '
              'می‌شود.',
        );
      }
    }
  });

  test('هاب مهارت زندگی نیمهٔ پولی را درِ ورودیِ خودش قفل می‌کند', () {
    final source =
        File('lib/features/growth/life_skills_hub_screen.dart').readAsStringSync();

    // هاب نباید مستقیم LifeSkillsGame را باز کند؛ اول باید قانون را بپرسد.
    expect(source, contains('ContentAccessPolicy.isLifeSkillFree(topic.id)'));
    expect(source, contains('ensureContentAccess('));
    // قفلِ دیده‌شده باید همان شرطِ لمس باشد.
    expect(
      source,
      contains('!_hasFullVersion && !ContentAccessPolicy.isLifeSkillFree(topic.id)'),
    );
    // و تا وقتی وضعیت خرید نامعلوم است، پیش‌فرض باید «قفل» باشد.
    expect(source, contains('bool _hasFullVersion = false;'));
  });

  test('درِ یکپارچهٔ قفل، بدون تأیید فروشگاه دسترسی نمی‌دهد', () {
    final source = File('lib/features/shop/content_lock.dart').readAsStringSync();

    // آیتم پولی فقط بعد از تأییدِ واقعیِ entitlement عبور می‌کند؛ بسته‌شدنِ
    // دیالوگ یا انصرافِ والد هرگز نباید دسترسی بسازد.
    expect(source, contains('return Monetization.hasFullVersion();'));
    expect(source, contains('if (!unlocked) return false;'));
    // آیتمِ رایگان نباید درگیر استور/شبکه شود.
    expect(source, contains('if (isFree) return true;'));
  });
}
