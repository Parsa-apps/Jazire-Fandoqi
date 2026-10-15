import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('direct premium game routes are guarded at the destination', () {
    final source = File('lib/main.dart').readAsStringSync();

    for (final route in <String>[
      "'/memory_match': (context) => GameAccessGate(",
      "'/puzzle': (context) => GameAccessGate(",
      "'/pattern': (context) => GameAccessGate(",
      "'/island_builder': (context) => GameAccessGate(",
      // این دو مسیر به نیمهٔ پولی منتقل شده‌اند؛ بدون محافظِ
      // مقصد، از مسیرهای آزاد (نقشهٔ دستگاه‌ها، جست‌وجو و کارنامه) باز
      // می‌ماندند و قفل فقط ظاهری بود.
      "'/star_catch': (context) => GameAccessGate(",
      "'/drawing-album': (context) => GameAccessGate(",
    ]) {
      expect(source, contains(route), reason: route);
    }
  });

  test('direct academy routes fail closed unless their topic is explicitly free', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains("ContentAccessPolicy.isAcademyTopicFree(topicId)"));
    expect(source, contains("GameAccessGate(gameName: 'آکادمی', child: academy)"));
  });

  test('unlisted story ids do not inherit the free story-hub entitlement', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains("gameName: 'داستان ویژه'"));
  });

  test('life-skill worlds are checked by id against the central policy', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains('ContentAccessPolicy.isLifeSkillFree(topic.id)'));
  });

  test('dashboard and hub use the same game policy as route gates', () {
    final dashboard =
        File('lib/features/home/widgets/dashboard_tab.dart').readAsStringSync();
    final hub = File('lib/features/home/widgets/fandoqi_hub_sheet.dart')
        .readAsStringSync();
    final gate = File('lib/features/shop/game_access_gate.dart').readAsStringSync();

    expect(dashboard, contains('ContentAccessPolicy.isGameFree(gameName)'));
    expect(hub, contains('ContentAccessPolicy.isGameFree(act.gameName)'));
    expect(gate, contains('ContentAccessPolicy.isGameFree(widget.gameName)'));
  });

  test('premium carnival cards remain visibly locked until status is checked', () {
    final source = File(
      'lib/features/games/mini_games/games_carnival_screen.dart',
    ).readAsStringSync();
    expect(
      source,
      contains('!game.isFree && (!_checkedPurchase || !_hasFullVersion)'),
    );
  });
}
