import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/drawing/drawing_album.dart';
import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/data/datasources/hive_player_store.dart';

void main() {
  setUp(() {
    HivePlayerStore.useMemoryStorage(clear: true);
    DrawingAlbum.useMemoryForTesting();
    GameData.resetForTesting();
  });

  test('a drawing is kept on the device album, not discarded after save', () async {
    final png = Uint8List.fromList(List<int>.generate(32, (i) => i));
    final record = await DrawingAlbum.savePng(png, today: '2026-08-16');
    expect(record, isNotNull);
    expect(DrawingAlbum.items, hasLength(1));
    expect(DrawingAlbum.items.first.createdDay, '2026-08-16');

    final loaded = await DrawingAlbum.loadBytes(record!.id);
    expect(loaded, png);
  });

  test('album drops the oldest drawing after the classroom cap', () async {
    for (var i = 0; i < DrawingAlbum.maxDrawings + 2; i++) {
      await DrawingAlbum.savePng(Uint8List.fromList([i]));
    }
    expect(DrawingAlbum.items.length, DrawingAlbum.maxDrawings);
  });

  test('resetting the child also clears the drawing album', () async {
    await DrawingAlbum.savePng(Uint8List.fromList([1, 2, 3]));
    expect(DrawingAlbum.items, isNotEmpty);
    GameData.resetChildProgressKeepingParent();
    await Future<void>.delayed(Duration.zero);
    expect(DrawingAlbum.items, isEmpty);
  });
}
