import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/core/learning_content/quran_data.dart';

void main() {
  group('🕌 داده‌های قرآن کودک', () {
    test('۸ سوره کوتاه جزء ۳۰ فهرست شده است', () {
      expect(QuranData.all, hasLength(8));
    });

    test('شناسه‌ها یکتا هستند', () {
      final ids = QuranData.all.map((s) => s.id).toSet();
      expect(ids, hasLength(QuranData.all.length));
    });

    test('تعداد آیات هر سوره با متن قرآن مطابق است', () {
      const expectedVerseCounts = <String, int>{
        'fatiha': 7,
        'ikhlas': 4,
        'falaq': 5,
        'nas': 6,
        'kawthar': 3,
        'asr': 3,
        'nasr': 3,
        'fil': 5,
      };
      expect(QuranData.totalVerses, 36);
      for (final surah in QuranData.all) {
        expect(
          surah.verseCount,
          expectedVerseCounts[surah.id],
          reason: surah.id,
        );
      }
    });

    test('هر آیه متن عربی و معنی فارسی غیرخالی دارد', () {
      for (final surah in QuranData.all) {
        expect(surah.arabicName.trim(), isNotEmpty, reason: surah.id);
        expect(surah.persianName.trim(), isNotEmpty, reason: surah.id);
        expect(surah.revelation.trim(), isNotEmpty, reason: surah.id);
        for (final verse in surah.verses) {
          expect(verse.arabic.trim(), isNotEmpty, reason: surah.id);
          expect(verse.meaning.trim(), isNotEmpty, reason: surah.id);
          // متن عربی باید واقعاً نویسه عربی داشته باشد.
          expect(
            RegExp(r'[؀-ۿ]').hasMatch(verse.arabic),
            isTrue,
            reason: '${surah.id}: عربی نیست',
          );
        }
      }
    });

    test('بسمه فقط برای حمد آیه است و برای بقیه سرصفحه دارد', () {
      final fatiha = QuranData.byId('fatiha')!;
      expect(fatiha.showBasmalaHeader, isFalse);
      expect(fatiha.verses.first.arabic, Surah.basmala);
      for (final surah in QuranData.all.where((s) => s.id != 'fatiha')) {
        expect(surah.showBasmalaHeader, isTrue, reason: surah.id);
      }
    });

    test('مسیر تلاوت از قرارداد assets/audio/quran پیروی می‌کند', () {
      for (final surah in QuranData.all) {
        expect(
          surah.audioAsset,
          'assets/audio/quran/quran_${surah.id}.mp3',
          reason: surah.id,
        );
      }
    });

    test('byId شناسه معتبر را پیدا و نامعتبر را رد می‌کند', () {
      expect(QuranData.byId('ikhlas')?.persianName, 'سوره اخلاص');
      expect(QuranData.byId('not-real'), isNull);
    });
  });

  group('🔒 سیاست دسترسی قرآن', () {
    test('همه سوره‌ها (حتی شناسه‌های آینده) رایگان‌اند', () {
      for (final surah in QuranData.all) {
        expect(ContentAccessPolicy.isSurahFree(surah.id), isTrue);
      }
      // شناسه نامعتبر نمی‌تواند محتوای جعلی رایگان بسازد.
      expect(ContentAccessPolicy.isSurahFree('unknown'), isFalse);
    });
  });

  group('🎧 دارایی‌های صوتی قرآن', () {
    test('پوشهٔ تلاوت‌ها و مانیفست ضبط در مخزن وجود دارد', () {
      expect(Directory('assets/audio/quran').existsSync(), isTrue);
      expect(File('assets/audio/quran/README.md').existsSync(), isTrue);
    });
  });
}
