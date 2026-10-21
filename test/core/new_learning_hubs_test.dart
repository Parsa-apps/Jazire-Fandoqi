import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/coloring/coloring_pages.dart';
import 'package:jazireh_fandoghi/core/background_music_observer.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/core/learning_content/poems_data.dart';
import 'package:jazireh_fandoghi/core/learning_content/quran_data.dart';
import 'package:jazireh_fandoghi/core/music/music_data.dart';
import 'package:jazireh_fandoghi/core/science/science_experiments.dart';

/// 📚 قراردادِ محتوای هاب‌های تازهٔ «دسته‌بندی‌ها»
///
/// این تست‌ها بدون اجرای رابط کاربری، سلامتِ داده و دارایی‌های پنج هابِ تازه
/// را نگه می‌دارند: شعر، قرآن، موسیقی، رنگ‌آمیزی و آزمایشگاه علوم.
void main() {
  group('شعرهای کودکانه', () {
    test('شناسه‌ها یکتا و هر شعر کامل است', () {
      expect(PoemsData.all.length, greaterThanOrEqualTo(8));
      final ids = PoemsData.all.map((poem) => poem.id).toSet();
      expect(ids, hasLength(PoemsData.all.length));

      for (final poem in PoemsData.all) {
        expect(poem.title.trim(), isNotEmpty, reason: poem.id);
        expect(poem.theme.trim(), isNotEmpty, reason: poem.id);
        expect(poem.message.trim(), isNotEmpty, reason: poem.id);
        expect(poem.lines.length, greaterThanOrEqualTo(4), reason: poem.id);

        for (final line in poem.lines) {
          expect(line.text.trim(), isNotEmpty, reason: poem.id);
          expect(line.beats, inInclusiveRange(1, 12), reason: poem.id);
        }

        expect(poem.totalBeats, greaterThan(0), reason: poem.id);
        expect(poem.fullText, contains('\n'), reason: poem.id);
        expect(poem.options, hasLength(3), reason: poem.id);
        expect(poem.options.toSet(), hasLength(3), reason: poem.id);
        expect(
          poem.options,
          contains(poem.answer),
          reason: '${poem.id}: پاسخ در گزینه‌ها نیست',
        );
        expect(poem.question.trim(), isNotEmpty, reason: poem.id);
      }
    });

    test('byId فقط شعرِ موجود را برمی‌گرداند', () {
      final first = PoemsData.all.first;
      expect(PoemsData.byId(first.id)?.title, first.title);
      expect(PoemsData.byId('poem-ناموجود'), isNull);
    });
  });

  group('قرآنِ کودک', () {
    test('سوره‌ها، آیه‌ها و شماره‌ها منظم‌اند', () {
      expect(QuranData.all.length, greaterThanOrEqualTo(8));
      final ids = QuranData.all.map((surah) => surah.id).toSet();
      expect(ids, hasLength(QuranData.all.length));

      for (final surah in QuranData.all) {
        expect(surah.name.trim(), isNotEmpty, reason: surah.id);
        expect(surah.meaning.trim(), isNotEmpty, reason: surah.id);
        expect(surah.kidMessage.trim(), isNotEmpty, reason: surah.id);
        expect(surah.ayahCount, surah.ayahs.length, reason: surah.id);
        expect(surah.ayahCount, greaterThanOrEqualTo(3), reason: surah.id);

        for (var i = 0; i < surah.ayahs.length; i++) {
          final ayah = surah.ayahs[i];
          expect(ayah.number, i + 1, reason: '${surah.id}: ترتیبِ آیه‌ها');
          expect(ayah.arabic.trim(), isNotEmpty, reason: surah.id);
          expect(ayah.persian.trim(), isNotEmpty, reason: surah.id);
          expect(
            ayah.arabic,
            isNot(contains('پلاسهولدر')),
            reason: surah.id,
          );
        }
      }

      expect(QuranData.bismillah.trim(), isNotEmpty);
      expect(QuranData.etiquette, isNotEmpty);
      expect(QuranData.byId('fatiha')?.name, contains('فاتحه'));
      expect(QuranData.byId('ناموجود'), isNull);
    });

    test('فاتحه بسم‌الله را آیهٔ اول دارد و بقیه جدا نشان می‌دهند', () {
      for (final surah in QuranData.all) {
        if (surah.id == 'fatiha') {
          expect(surah.startsWithBismillah, isFalse);
          expect(surah.ayahs.first.arabic, QuranData.bismillah);
        } else {
          expect(surah.startsWithBismillah, isTrue, reason: surah.id);
        }
      }
    });

    test('سورهٔ امروز همیشه یکی از سوره‌های موجود است', () {
      final start = DateTime(2026, 1, 3);
      for (var i = 0; i < 14; i++) {
        final surah = QuranData.surahOfTheDay(
          start.add(Duration(days: i)),
        );
        expect(
          QuranData.all,
          contains(surah),
          reason: 'روزِ $i',
        );
      }
    });
  });

  group('آزمایشگاه علوم', () {
    test('شش آزمایشِ یکتا با همهٔ نوع‌ها', () {
      expect(ScienceData.all, hasLength(6));
      expect(
        ScienceData.all.map((item) => item.id).toSet(),
        hasLength(ScienceData.all.length),
      );
      expect(
        ScienceData.all.map((item) => item.kind).toSet(),
        ScienceKind.values.toSet(),
      );

      for (final experiment in ScienceData.all) {
        expect(experiment.title.trim(), isNotEmpty, reason: experiment.id);
        expect(experiment.emoji.trim(), isNotEmpty, reason: experiment.id);
        expect(experiment.subtitle.trim(), isNotEmpty, reason: experiment.id);
        expect(experiment.bigQuestion.trim(), isNotEmpty, reason: experiment.id);
        expect(experiment.explanation.trim(), isNotEmpty, reason: experiment.id);
        expect(experiment.homeActivity.trim(), isNotEmpty, reason: experiment.id);
        expect(experiment.safetyTip.trim(), isNotEmpty, reason: experiment.id);
        expect(
          experiment.explanation.length,
          greaterThanOrEqualTo(40),
          reason: '${experiment.id}: توضیح کوتاه‌تر از حدِ کودکانه نیست',
        );
      }
    });
  });

  group('استودیوی موسیقی', () {
    test('نت‌ها و فایل‌های صوتی همه موجودند', () {
      expect(MusicNotes.all, hasLength(8));
      expect(
        MusicNotes.all.map((note) => note.id).toSet(),
        hasLength(MusicNotes.all.length),
      );
      for (final note in MusicNotes.all) {
        expect(note.persianName.trim(), isNotEmpty, reason: note.id);
        expect(note.solfege.trim(), isNotEmpty, reason: note.id);
        expect(
          File(note.asset).existsSync(),
          isTrue,
          reason: 'فایل ${note.asset} در بسته نیست',
        );
      }
    });

    test('آهنگ‌ها و الگوهای ریتم در محدودهٔ نت‌ها هستند', () {
      expect(KidsSongs.all.length, greaterThanOrEqualTo(5));
      expect(KidsSongs.all.map((song) => song.id).toSet(),
          hasLength(KidsSongs.all.length));
      for (final song in KidsSongs.all) {
        expect(song.title.trim(), isNotEmpty, reason: song.id);
        expect(song.steps, isNotEmpty, reason: song.id);
        expect(song.bpm, inInclusiveRange(60, 180), reason: song.id);
        for (final step in song.steps) {
          expect(step.note, inInclusiveRange(0, MusicNotes.all.length - 1),
              reason: song.id);
          expect(step.beats, inInclusiveRange(1, 4), reason: song.id);
        }
      }

      for (final pad in PercussionPads.all) {
        expect(pad.label.trim(), isNotEmpty, reason: pad.id);
        expect(
          File(pad.asset).existsSync(),
          isTrue,
          reason: 'فایل ${pad.asset} در بسته نیست',
        );
      }

      expect(RhythmPatterns.all.length, greaterThanOrEqualTo(4));
      for (final pattern in RhythmPatterns.all) {
        expect(pattern.pads.length, greaterThanOrEqualTo(4), reason: pattern.id);
        expect(pattern.bpm, inInclusiveRange(60, 180), reason: pattern.id);
        for (final pad in pattern.pads) {
          expect(pad, inInclusiveRange(0, PercussionPads.all.length - 1),
              reason: pattern.id);
        }
      }
    });

    test('سازها نمونهٔ صوتیِ معتبر دارند', () {
      expect(MusicInstruments.all, hasLength(8));
      for (final instrument in MusicInstruments.all) {
        expect(instrument.name.trim(), isNotEmpty, reason: instrument.id);
        expect(instrument.family.trim(), isNotEmpty, reason: instrument.id);
        expect(instrument.fact.trim(), isNotEmpty, reason: instrument.id);
        expect(instrument.playHint.trim(), isNotEmpty, reason: instrument.id);
        if (instrument.percussion) {
          expect(instrument.demoPads, isNotEmpty, reason: instrument.id);
          for (final pad in instrument.demoPads) {
            expect(pad, inInclusiveRange(0, PercussionPads.all.length - 1),
                reason: instrument.id);
          }
        } else {
          expect(instrument.demoNotes, isNotEmpty, reason: instrument.id);
          for (final note in instrument.demoNotes) {
            expect(note, inInclusiveRange(0, MusicNotes.all.length - 1),
                reason: instrument.id);
          }
        }
      }
    });
  });

  group('کتاب رنگ‌آمیزی', () {
    test('هر صفحه نواحیِ قابلِ لمس و مسیرِ سالم دارد', () {
      expect(ColoringPages.all.length, greaterThanOrEqualTo(10));
      expect(
        ColoringPages.all.map((page) => page.id).toSet(),
        hasLength(ColoringPages.all.length),
      );

      const size = Size(360, 360);
      for (final page in ColoringPages.all) {
        expect(page.title.trim(), isNotEmpty, reason: page.id);
        expect(page.hint.trim(), isNotEmpty, reason: page.id);
        expect(page.regions.length, greaterThanOrEqualTo(3), reason: page.id);
        expect(
          page.regions.map((region) => region.id).toSet(),
          hasLength(page.regions.length),
          reason: '${page.id}: شناسهٔ ناحیه‌ها تکراری است',
        );
        for (final region in page.regions) {
          expect(region.label.trim(), isNotEmpty, reason: page.id);
          // Rect فقط isEmpty دارد؛ isNotEmpty روی آن وجود ندارد.
          expect(
            region.buildPath(size).getBounds().isEmpty,
            isFalse,
            reason: '${page.id}/${region.id}: مسیرِ خالی',
          );
        }
        for (final detail in page.details) {
          expect(
            detail.buildPath(size).getBounds().isEmpty,
            isFalse,
            reason: '${page.id}: جزئیاتِ خالی',
          );
        }
      }
    });

  });

  group('قانونِ نیمهٔ رایگان روی مجموعه‌های تازه', () {
    void expectHalfFree(String name, List<String> ids) {
      expect(ids.length.isEven, isTrue, reason: name);
      final half = ids.length ~/ 2;
      for (var i = 0; i < ids.length; i++) {
        expect(
          ContentAccessPolicy.isFreeHalfItem(ids[i], ids),
          i < half,
          reason: '$name: آیتم $i (${ids[i]})',
        );
      }
    }

    test('شعر، رنگ‌آمیزی، موسیقی و علوم دقیقاً نیمهٔ اول را آزاد می‌کنند', () {
      expectHalfFree('شعرها', PoemsData.all.map((p) => p.id).toList());
      expectHalfFree('رنگ‌آمیزی', ColoringPages.all.map((p) => p.id).toList());
      expectHalfFree(
        'سازها',
        MusicInstruments.all.map((i) => i.id).toList(),
      );
      expectHalfFree(
        'آزمایش‌ها',
        ScienceData.all.map((e) => e.id).toList(),
      );
    });

    test('شناسهٔ ناشناخته هرگز رایگان نیست', () {
      expect(
        ContentAccessPolicy.isFreeHalfItem(
          'آیتم-ناشناخته',
          PoemsData.all.map((p) => p.id),
        ),
        isFalse,
      );
    });
  });

  group('موسیقیِ پس‌زمینهٔ هاب‌های تازه', () {
    test('هاب‌های یادگیری موسیقیِ آرام می‌گیرند و استودیو ساکت می‌ماند', () {
      expect(BackgroundMusicObserver.sectionForRoute('/wildlife'), 'learning');
      expect(BackgroundMusicObserver.sectionForRoute('/basics'), 'learning');
      expect(BackgroundMusicObserver.sectionForRoute('/emotions'), 'learning');
      expect(
        BackgroundMusicObserver.sectionForRoute('/science-lab/magnet'),
        'learning',
      );
      expect(
        BackgroundMusicObserver.sectionForRoute('/coloring/fish'),
        'learning',
      );
      expect(
        BackgroundMusicObserver.sectionForRoute('/poems/poem_mom'),
        'learning',
      );
      expect(BackgroundMusicObserver.sectionForRoute('/stage-map'), 'games');
      // استودیوی موسیقی و قرآن باید بی‌موسیقی باشند تا صدای اصلی گم نشود.
      expect(BackgroundMusicObserver.sectionForRoute('/art-studio'), isNull);
      expect(BackgroundMusicObserver.sectionForRoute('/quran/fatiha'), isNull);
    });
  });

  group('دارایی‌های بسته', () {
    test('فونتِ قرآنی و صداهای استودیو در pubspec ثبت شده‌اند', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('family: Amiri'));
      expect(pubspec, contains('assets/fonts/Amiri-Regular.ttf'));
      expect(pubspec, contains('assets/audio/studio/notes/'));
      expect(pubspec, contains('assets/audio/studio/perc/'));
      expect(pubspec, contains('assets/fonts/OFL-Amiri.txt'));
      expect(File('assets/fonts/OFL-Amiri.txt').existsSync(), isTrue);

      expect(File('assets/fonts/Amiri-Regular.ttf').existsSync(), isTrue);
      expect(
        File('assets/fonts/Amiri-Regular.ttf').lengthSync(),
        greaterThan(100000),
      );
    });

    test('هیچ متنِ جای‌نگهدار در محتوای تازه نیست', () {
      for (final path in <String>[
        'lib/core/learning_content/poems_data.dart',
        'lib/core/learning_content/quran_data.dart',
        'lib/core/science/science_experiments.dart',
        'lib/core/music/music_data.dart',
        'lib/core/coloring/coloring_pages.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final marker in <String>['TODO', 'placeholder', 'Lorem ipsum']) {
          expect(
            source.contains(marker),
            isFalse,
            reason: '$path شاملِ «$marker» است',
          );
        }
      }
    });
  });
}
