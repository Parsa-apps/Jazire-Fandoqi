import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/core/learning_content/poems_data.dart';

void main() {
  group('📚 داده‌های شعر کودکانه', () {
    test('فهرست شعرها خالی نیست و حداقل ۸ شعر دارد', () {
      expect(PoemsData.all.length, greaterThanOrEqualTo(8));
    });

    test('شناسه‌ها یکتا و فقط با حروف انگلیسی/زیرخط هستند', () {
      final ids = PoemsData.all.map((p) => p.id).toSet();
      expect(ids, hasLength(PoemsData.all.length));
      for (final id in ids) {
        expect(RegExp(r'^[a-z_]+$').hasMatch(id), isTrue, reason: id);
      }
    });

    test('هر شعر عنوان، متن و پیام غیرخالی دارد', () {
      for (final poem in PoemsData.all) {
        expect(poem.title.trim(), isNotEmpty, reason: poem.id);
        expect(poem.subtitle.trim(), isNotEmpty, reason: poem.id);
        expect(poem.coverEmoji.trim(), isNotEmpty, reason: poem.id);
        expect(poem.message.trim(), isNotEmpty, reason: poem.id);
        expect(poem.lines.length, greaterThanOrEqualTo(4), reason: poem.id);
        for (final line in poem.lines) {
          expect(line.trim(), isNotEmpty, reason: '${poem.id}: خط خالی');
        }
      }
    });

    test('مسیر صوتی هر شعر از قرارداد assets/audio/poems پیروی می‌کند', () {
      for (final poem in PoemsData.all) {
        expect(
          poem.audioAsset,
          'assets/audio/poems/poem_${poem.id}.mp3',
          reason: poem.id,
        );
      }
    });

    test('متن خوانش TTS بدون خط خالی و با نقطه‌گذاری ساخته می‌شود', () {
      for (final poem in PoemsData.all) {
        final spoken = poem.spokenText;
        expect(spoken, isNotEmpty, reason: poem.id);
        expect(spoken.contains(RegExp(r'\s{2,}')), isFalse, reason: poem.id);
      }
    });

    test('byId شناسه معتبر را پیدا و نامعتبر را رد می‌کند', () {
      expect(PoemsData.byId(PoemsData.all.first.id), PoemsData.all.first);
      expect(PoemsData.byId('not-a-real-poem'), isNull);
    });
  });

  group('🔒 سیاست دسترسی شعرها', () {
    test('نیمهٔ اول رایگان و نیمهٔ دوم قفل است', () {
      final freeCount = ContentAccessPolicy.freePoemCount;
      expect(freeCount * 2, lessThanOrEqualTo(PoemsData.all.length + 1));
      for (var i = 0; i < PoemsData.all.length; i++) {
        final poem = PoemsData.all[i];
        expect(
          ContentAccessPolicy.isPoemFree(poem.id),
          i < freeCount,
          reason: '${poem.id} در اندیس $i',
        );
      }
    });

    test('شناسهٔ ناشناخته fail-closed است (قفل)', () {
      expect(ContentAccessPolicy.isPoemFree('unknown'), isFalse);
    });
  });

  group('🎧 دارایی‌های صوتی شعر', () {
    test('پوشهٔ ضبط‌ها و مانیفست نام‌گذاری در مخزن وجود دارد', () {
      expect(Directory('assets/audio/poems').existsSync(), isTrue);
      expect(
        File('assets/audio/poems/README.md').existsSync(),
        isTrue,
      );
    });
  });
}
