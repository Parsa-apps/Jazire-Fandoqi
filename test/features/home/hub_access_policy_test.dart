import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/content_access_policy.dart';
import 'package:jazireh_fandoghi/features/home/widgets/fandoqi_hub_sheet.dart';

void main() {
  test('hub free/paid labels match the central game access policy', () {
    const hubs = <HubData>[
      FandoqiHubs.farsi,
      FandoqiHubs.math,
      FandoqiHubs.lettersAndSounds,
      FandoqiHubs.science,
      FandoqiHubs.games,
      FandoqiHubs.art,
    ];

    for (final hub in hubs) {
      for (final activity in hub.activities) {
        expect(
          ContentAccessPolicy.isGameFree(activity.gameName),
          activity.isFree,
          reason: '${hub.id}: ${activity.gameName}',
        );
      }
    }
  });
}
