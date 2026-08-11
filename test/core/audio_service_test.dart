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
}
