import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/audio_service.dart';

void main() {
  group('offline learning voices', () {
    test('maps every color card to a bundled recording', () {
      for (var index = 1; index <= 12; index++) {
        expect(
          AudioService.learningVoiceAsset(
            topicId: 'colors',
            cardId: 'c$index',
          ),
          'assets/audio/learning/colors/c${index.toString().padLeft(2, '0')}.wav',
        );
      }
    });

    test('maps every shape card to a bundled recording', () {
      for (var index = 1; index <= 10; index++) {
        expect(
          AudioService.learningVoiceAsset(
            topicId: 'shapes',
            cardId: 's$index',
          ),
          'assets/audio/learning/shapes/s${index.toString().padLeft(2, '0')}.wav',
        );
      }
    });

    test('does not invent an asset for unsupported cards', () {
      expect(
        AudioService.learningVoiceAsset(topicId: 'animals', cardId: 'a1'),
        isNull,
      );
      expect(
        AudioService.learningVoiceAsset(topicId: 'colors', cardId: 'c13'),
        isNull,
      );
      expect(
        AudioService.learningVoiceAsset(topicId: 'shapes', cardId: 'bad-id'),
        isNull,
      );
    });
  });

  group('Persian/Arabic character hygiene', () {
    test('normalizes Arabic look-alikes to their Persian form', () {
      expect(AudioService.normalizeLetter('ك'), 'ک');
      expect(AudioService.normalizeLetter('ي'), 'ی');
      expect(AudioService.normalizeLetter('ى'), 'ی');
      expect(AudioService.normalizeLetter('ة'), 'ه');
      expect(AudioService.normalizeLetter('أ'), 'ا');
      expect(AudioService.normalizeLetter('إ'), 'ا');
      // اعراب و کشیده حذف می‌شوند
      expect(AudioService.normalizeLetter('بَ'), 'ب');
      expect(AudioService.normalizeLetter('كـ'), 'ک');
      expect(AudioService.normalizeLetter(' ی '), 'ی');
    });

    test('Arabic keyboard letters still find their Persian recording', () {
      expect(
        AudioService.letterAssetFor('ك'),
        AudioService.letterAssetFor('ک'),
      );
      expect(
        AudioService.letterAssetFor('ي'),
        AudioService.letterAssetFor('ی'),
      );
      expect(
        AudioService.letterAssetFor('أ'),
        AudioService.letterAssetFor('ا'),
      );
    });

    test('converts Persian and Arabic-Indic digits to latin', () {
      expect(AudioService.normalizeDigits('۱۲'), '12');
      expect(AudioService.normalizeDigits('٧'), '7');
      expect(AudioService.numberAssetForText('۷'),
          'assets/audio/numbers/n07.mp3');
      expect(AudioService.numberAssetForText('٢٠'),
          'assets/audio/numbers/n20.mp3');
      expect(AudioService.numberAssetForText('21'), isNull);
      expect(AudioService.numberAssetForText('حرف'), isNull);
    });
  });

  group('word reading vs. letter spelling', () {
    test('cleanSpokenText keeps the word but drops emoji and quotes', () {
      expect(AudioService.cleanSpokenText('باران 🌧️'), 'باران');
      expect(AudioService.cleanSpokenText('«سیب»'), 'سیب');
      expect(AudioService.cleanSpokenText('  دوست 🤝  '), 'دوست');
      expect(AudioService.cleanSpokenText('🇮🇷 ایران'), 'ایران');
      expect(AudioService.cleanSpokenText('🍿'), '');
    });

    test('cleanSpokenText preserves ZWNJ so Persian spelling stays intact', () {
      const withZwnj = 'می\u200Cخوانم';
      expect(AudioService.cleanSpokenText(withZwnj), withZwnj);
    });

    test('cleanSpokenText strips harakat but never the base letters', () {
      expect(AudioService.cleanSpokenText('اَنار'), 'انار');
      // کشیده (تطویل) حرف نیست و نباید خوانده شود
      expect(AudioService.cleanSpokenText('کـتاب'), 'کتاب');
    });

    test('every workshop word maps to real letter recordings when spelled', () {
      // هجی‌کردن باید برای همهٔ نویسه‌های کلمه‌های آموزشی فایل داشته باشد،
      // وگرنه کودک یک حرف را نمی‌شنود.
      const words = <String>[
        'آب',
        'بابا',
        'باران',
        'مادر',
        'دوست',
        'ایران',
        'خورشید',
        'صابون',
      ];
      for (final word in words) {
        final clean = AudioService.cleanSpokenText(word);
        for (final rune in clean.runes) {
          final ch = String.fromCharCode(rune);
          if (ch.trim().isEmpty || ch == '\u200C') continue;
          expect(
            AudioService.letterAssetFor(ch),
            isNotNull,
            reason: 'حرف «$ch» از کلمهٔ «$word» فایل صوتی ندارد',
          );
        }
      }
    });
  });

  group('offline word bank (کارگاه واژه‌سازی)', () {
    test('every workshop word in the game has a bundled recording', () {
      // منبع حقیقت: همان کلمه‌هایی که روی صفحه لمس می‌شوند.
      final source =
          File('lib/features/games/alphabet_academy/alphabet_academy_game.dart')
              .readAsStringSync();
      final blocks = RegExp(r'createdWords: \[(.*?)\]', dotAll: true)
          .allMatches(source);
      final words = <String>{};
      for (final block in blocks) {
        for (final m
            in RegExp(r"'([^']*)'").allMatches(block.group(1)!)) {
          words.add(AudioService.cleanSpokenText(m.group(1)!));
        }
      }

      expect(words, isNotEmpty);
      for (final word in words) {
        final path = AudioService.wordAssetFor(word);
        expect(path, isNotNull, reason: 'کلمهٔ «$word» ضبط نشده است');
        expect(File(path!).existsSync(), isTrue, reason: '$word → $path');
        expect(File(path).lengthSync(), greaterThan(4000), reason: word);
      }
    });

    test('every lesson example word also has a bundled recording', () {
      // کلمهٔ نمونهٔ هر نشانه («ب مثلِ بابا») هم روی صفحه لمس‌شدنی است.
      final source =
          File('lib/features/games/alphabet_academy/alphabet_academy_game.dart')
              .readAsStringSync();
      final words = <String>{};
      for (final m in RegExp(r"_LetterLesson\('[^']*', '([^']*)'")
          .allMatches(source)) {
        words.add(AudioService.cleanSpokenText(m.group(1)!));
      }

      expect(words, isNotEmpty);
      for (final word in words) {
        final path = AudioService.wordAssetFor(word);
        expect(path, isNotNull, reason: 'کلمهٔ نمونهٔ «$word» ضبط نشده است');
        expect(File(path!).existsSync(), isTrue, reason: '$word → $path');
      }
    });

    test('all 126 recordings are distinct files that exist on disk', () {
      expect(AudioService.wordAudioKeys, hasLength(126));
      final paths = AudioService.wordAudioKeys.keys
          .map(AudioService.wordAssetFor)
          .toSet();
      expect(paths, hasLength(126));
      for (final path in paths) {
        expect(File(path!).existsSync(), isTrue, reason: path);
      }
    });

    test('every allograph sample word has a bundled recording', () {
      // کارت «اشکال چهارگانه»: هر خانه یک کلمهٔ لمس‌شدنی دارد. اگر یکی
      // صدا نداشته باشد کودک به‌جای کلمه، هجی می‌شنود.
      final source =
          File('lib/features/games/alphabet_academy/alphabet_academy_game.dart')
              .readAsStringSync();
      final words = <String>{};
      for (final block in RegExp(r'allographWords: \[(.*?)\]', dotAll: true)
          .allMatches(source)) {
        for (final m in RegExp(r"'([^']*)'").allMatches(block.group(1)!)) {
          final word = AudioService.cleanSpokenText(m.group(1)!);
          if (word.isEmpty) continue;
          words.add(word);
        }
      }

      expect(words, isNotEmpty);
      for (final word in words) {
        final path = AudioService.wordAssetFor(word);
        expect(path, isNotNull, reason: 'کلمهٔ «$word» ضبط نشده است');
        expect(File(path!).existsSync(), isTrue, reason: '$word → $path');
      }
    });

    test('no two words share the same recording file', () {
      final files = AudioService.wordAudioKeys.values.toList();
      expect(files.toSet(), hasLength(files.length));
    });

    test('recorded allograph sample words resolve to their own clip', () {
      // این‌ها روی کارت «اشکال چهارگانه» لمس می‌شوند.
      expect(AudioService.wordAssetFor('بادام'), isNotNull);
      expect(AudioService.wordAssetFor('پرچم'), isNotNull);
      expect(AudioService.wordAssetFor('گاو'), isNotNull);
      expect(
        AudioService.wordAssetFor('توپ'),
        isNot(AudioService.wordAssetFor('سوپ')),
      );
    });

    test('lookup tolerates emoji and stray spaces around the word', () {
      expect(
        AudioService.wordAssetFor('باران 🌧️'),
        'assets/audio/words/w11.wav',
      );
      expect(
        AudioService.wordAssetFor('  ایران 🇮🇷 '),
        'assets/audio/words/w12.wav',
      );
      expect(AudioService.wordAssetFor('یک‌کلمهٔ‌نبوده'), isNull);
    });

    test('recordings are mono 22.05 kHz so the bundle stays small', () {
      var total = 0;
      for (final key in AudioService.wordAudioKeys.values) {
        final file = File('assets/audio/words/$key.wav');
        total += file.lengthSync();
        final header = file.openSync().readSync(32);
        // WAV header: channels @22, sample-rate @24 (little endian)
        final channels = header[22] | (header[23] << 8);
        final rate = header[24] |
            (header[25] << 8) |
            (header[26] << 16) |
            (header[27] << 24);
        expect(channels, 1, reason: key);
        expect(rate, 22050, reason: key);
      }
      // کل بستهٔ کلمات باید زیر ۸ مگابایت بماند.
      expect(total, lessThan(8 * 1024 * 1024));
    });
  });

  group('letter and number assets', () {
    test('gives آ and ا their own separate recordings', () {
      expect(AudioService.letterAssetFor('آ'), 'assets/audio/letters/l01.mp3');
      expect(AudioService.letterAssetFor('ا'), 'assets/audio/letters/l33.mp3');
      expect(
        AudioService.letterAssetFor('آ'),
        isNot(AudioService.letterAssetFor('ا')),
      );
    });

    test('every mapped letter has a bundled recording on disk', () {
      for (final entry in AudioService.letterIndex.entries) {
        final path = AudioService.letterAssetFor(entry.key);
        expect(path, isNotNull, reason: entry.key);
        expect(File(path!).existsSync(), isTrue, reason: '${entry.key} → $path');
        expect(File(path).lengthSync(), greaterThan(4000), reason: entry.key);
      }
    });

    test('the 33 letter recordings are all distinct files', () {
      final paths = AudioService.letterIndex.keys
          .map(AudioService.letterAssetFor)
          .toSet();
      expect(paths, hasLength(33));
    });

    test('every number 0-20 has a bundled recording on disk', () {
      for (var n = 0; n <= 20; n++) {
        final path = AudioService.numberAssetFor(n)!;
        expect(File(path).existsSync(), isTrue, reason: '$n → $path');
        expect(File(path).lengthSync(), greaterThan(3000), reason: '$n');
      }
    });

    test('maps the full Persian alphabet to l01-l32', () {
      const letters = <String>[
        'آ',
        'ب',
        'پ',
        'ت',
        'ث',
        'ج',
        'چ',
        'ح',
        'خ',
        'د',
        'ذ',
        'ر',
        'ز',
        'ژ',
        'س',
        'ش',
        'ص',
        'ض',
        'ط',
        'ظ',
        'ع',
        'غ',
        'ف',
        'ق',
        'ک',
        'گ',
        'ل',
        'م',
        'ن',
        'و',
        'ه',
        'ی',
      ];
      expect(letters, hasLength(32));
      for (var i = 0; i < letters.length; i++) {
        expect(
          AudioService.letterAssetFor(letters[i]),
          'assets/audio/letters/l${(i + 1).toString().padLeft(2, '0')}.mp3',
        );
      }
      // «ا» دیگر روی فایل «آ» سوار نمی‌شود؛ ضبط اختصاصی خودش را دارد.
      expect(AudioService.letterAssetFor('ا'), 'assets/audio/letters/l33.mp3');
      expect(AudioService.letterAssetFor('x'), isNull);
      expect(AudioService.letterAssetFor(''), isNull);
    });

    test('maps numbers 0-20 and rejects the rest', () {
      for (var n = 0; n <= 20; n++) {
        expect(
          AudioService.numberAssetFor(n),
          'assets/audio/numbers/n${n.toString().padLeft(2, '0')}.mp3',
        );
      }
      expect(AudioService.numberAssetFor(-1), isNull);
      expect(AudioService.numberAssetFor(21), isNull);
    });
  });

  group('premium sfx mix', () {
    test('every named effect has a volume under celebration ceiling', () {
      expect(AudioService.sfxNames, hasLength(21));
      for (final name in AudioService.sfxNames) {
        expect(AudioService.sfxVolumes.containsKey(name), isTrue, reason: name);
        final volume = AudioService.sfxVolumes[name]!;
        expect(volume, greaterThan(0.2));
        expect(volume, lessThanOrEqualTo(0.80));
      }
      expect(AudioService.sfxVolumes['tap']! < AudioService.sfxVolumes['win']!, isTrue);
      expect(AudioService.sfxVolumes['wrong']! < AudioService.sfxVolumes['correct']!, isTrue);
      expect(AudioService.sfxVolumes['lose']! < AudioService.sfxVolumes['win']!, isTrue);
    });

    test('bundled wav files exist and are richer than the old beep stubs', () {
      for (final name in AudioService.sfxNames) {
        final file = File('assets/audio/sfx/$name.wav');
        expect(file.existsSync(), isTrue, reason: name);
        // Old generator wrote 30–90 ms pure tones (~3–8 KB).
        // Premium taps/ticks still short, but must carry a decay tail.
        expect(file.lengthSync(), greaterThan(4000), reason: name);
      }
      expect(File('assets/audio/sfx/win.wav').lengthSync(), greaterThan(20000));
      expect(File('assets/audio/sfx/correct.wav').lengthSync(), greaterThan(12000));
      expect(File('assets/audio/sfx/sleep.wav').lengthSync(), greaterThan(20000));
    });

    test('story and lullaby recordings stay in their own folders', () {
      expect(Directory('assets/audio/stories').existsSync(), isTrue);
      expect(Directory('assets/audio/lullabies').existsSync(), isTrue);
      expect(
        Directory('assets/audio/stories')
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.mp3'))
            .length,
        greaterThanOrEqualTo(30),
      );
      expect(
        Directory('assets/audio/lullabies')
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.mp3'))
            .length,
        greaterThanOrEqualTo(10),
      );
    });
  });
}
