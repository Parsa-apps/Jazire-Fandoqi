import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/learning/today_path.dart';

void main() {
  setUp(GameData.resetForTesting);

  test('a new child is sent to alef, not a fake high score', () {
    final task = TodayPath.forChild(today: '2026-08-16');
    expect(task.route, '/alphabet');
    expect(task.title, contains('آ'));
    expect(task.reason, isNot(contains('۸۰')));
    expect(task.station, 'literacy');
    expect(task.doneCount, 0);
  });

  test('due review beats a new letter', () {
    GameData.recordAlphabetPass('g1-0-0', today: '2026-08-16');
    final task = TodayPath.forChild(today: '2026-08-17');
    expect(task.route, '/alphabet');
    expect(task.title, contains('مرور'));
    expect(GameData.isTodayStationDone('literacy', today: '2026-08-17'), isFalse);
  });

  test('after letters exist, missing math is next', () {
    GameData.recordAlphabetPass('g1-0-0', today: '2026-08-16');
    GameData.skills['alphabet'] = 4;
    final task = TodayPath.forChild(today: '2026-08-16');
    expect(task.route, '/math/add');
    expect(task.title, contains('جمع'));
    expect(task.station, 'math');
    expect(task.doneCount, 1);
  });

  test('stations advance in order and finish the day', () {
    GameData.recordAlphabetPass('g1-0-0', today: '2026-08-16');
    expect(TodayPath.forChild(today: '2026-08-16').station, 'math');

    GameData.markTodayStation('math', today: '2026-08-16');
    expect(TodayPath.forChild(today: '2026-08-16').route, '/game/نقاشی');

    GameData.markTodayStation('drawing', today: '2026-08-16');
    final storyTask = TodayPath.forChild(today: '2026-08-16');
    expect(storyTask.route, '/stories/read');
    expect(storyTask.title, contains('کلاس اول'));

    GameData.markTodayStation('story', today: '2026-08-16');
    final done = TodayPath.forChild(today: '2026-08-16');
    expect(done.allDone, isTrue);
    expect(done.route, '/home');
    expect(done.doneCount, 4);
  });

  test('today path does not leak into the next calendar day', () {
    GameData.markTodayStation('literacy', today: '2026-08-16');
    GameData.markTodayStation('math', today: '2026-08-16');
    expect(GameData.isTodayStationDone('literacy', today: '2026-08-17'), isFalse);
    expect(TodayPath.forChild(today: '2026-08-17').station, 'literacy');
  });

  test('recap lists only stations that were really done', () {
    expect(TodayPath.recapLines(today: '2026-08-16'), isEmpty);
    GameData.markTodayStation('literacy', today: '2026-08-16');
    GameData.markTodayStation('math', today: '2026-08-16');
    expect(TodayPath.recapLines(today: '2026-08-16'), ['الفبا', 'جمع تا ۲۰']);
    expect(TodayPath.recapLines(today: '2026-08-17'), isEmpty);
  });
}
