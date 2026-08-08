import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amoozesh_fandoghi/shared/widgets/draggable_fandoghi.dart';

void main() {
  test('mascot position keeps the whole frame on-screen', () {
    final position = FandoghiPosition.instance;
    final original = position.value;
    addTearDown(() => position.value = original);

    position.updateFromPixels(
      Offset.zero,
      const Size(200, 100),
      mascotSize: 40,
    );
    expect(position.value, const Offset(0.1, 0.2));

    position.updateFromPixels(
      const Offset(200, 100),
      const Size(200, 100),
      mascotSize: 40,
    );
    expect(position.value, const Offset(0.9, 0.8));
  });

  test('position converts back to the same pixel center', () {
    final position = FandoghiPosition.instance;
    final original = position.value;
    addTearDown(() => position.value = original);

    position.value = const Offset(0.25, 0.75);
    expect(
      position.toPixels(const Size(400, 200)),
      const Offset(100, 150),
    );
  });
}
