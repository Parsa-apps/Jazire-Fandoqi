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

  group('letter and number assets', () {
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
      expect(AudioService.letterAssetFor('ا'), AudioService.letterAssetFor('آ'));
      expect(AudioService.letterAssetFor('x'), isNull);
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
