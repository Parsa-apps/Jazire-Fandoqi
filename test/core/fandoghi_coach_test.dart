import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/fandoghi_coach.dart';

void main() {
  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  test('coach publishes and clears judge feedback', () {
    FandoghiCoach.judge('این مرحله هنوز قفل است');
    expect(FandoghiCoach.current.value?.text, 'این مرحله هنوز قفل است');

    FandoghiCoach.clear();
    expect(FandoghiCoach.current.value, isNull);
  });

  test('persistent mascot presence stays off so it never blocks taps', () {
    FandoghiCoach.enablePersistentPresence();
    expect(FandoghiCoach.persistent.value, isFalse);
  });
}
