import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/core/growth/parent_controls.dart';

void main() {
  setUp(() {
    GrowthStore.resetForTesting();
  });

  test('defaults are child-safe and parent-neutral', () {
    expect(GrowthStore.bedtimeEnabled, isFalse);
    expect(GrowthStore.cartoonsAllowed, isTrue);
    expect(GrowthStore.shopAllowed, isTrue);
    expect(GrowthStore.activeSiblingId, 'default');
    expect(GrowthStore.siblings, isNotEmpty);
  });

  test('bedtime setter clamps hours to valid ranges', () {
    GrowthStore.setBedtime(enabled: true, hour: 40, wake: 23);
    expect(GrowthStore.bedtimeHour, 23);
    expect(GrowthStore.wakeHour, 10);

    GrowthStore.setBedtime(enabled: true, hour: 5, wake: 1);
    expect(GrowthStore.bedtimeHour, 18);
    expect(GrowthStore.wakeHour, 5);
  });

  test('content filters toggle independently', () {
    GrowthStore.setContentFilter(cartoons: false);
    expect(GrowthStore.cartoonsAllowed, isFalse);
    expect(GrowthStore.storiesAllowed, isTrue);

    GrowthStore.setContentFilter(stories: false, shop: false);
    expect(GrowthStore.storiesAllowed, isFalse);
    expect(GrowthStore.shopAllowed, isFalse);
  });

  test('weekly goal stays inside 10..180 minutes', () {
    GrowthStore.setWeeklyGoal(minutes: 5);
    expect(GrowthStore.weeklyGoalMinutes, 10);
    GrowthStore.setWeeklyGoal(minutes: 999);
    expect(GrowthStore.weeklyGoalMinutes, 180);
  });

  test('whats-new is shown once per version', () {
    expect(GrowthStore.shouldShowWhatsNew, isTrue);
    GrowthStore.markWhatsNewSeen();
    expect(GrowthStore.shouldShowWhatsNew, isFalse);
  });

  test('parent controls block cartoon routes only when filtered', () {
    GrowthStore.setContentFilter(cartoons: false);
    expect(ParentControls.isRouteBlocked('/cartoons'), isTrue);
    expect(ParentControls.isRouteBlocked('/game/الفبا'), isFalse);

    GrowthStore.setContentFilter(cartoons: true);
    expect(ParentControls.isRouteBlocked('/cartoons'), isFalse);
  });

  test('parent panel and lullabies are never blocked', () {
    GrowthStore.setBedtime(enabled: true, hour: 18, wake: 10);
    // ساعت خواب فعال است؛ پنل والد و لالایی همیشه باز می‌مانند.
    expect(ParentControls.isRouteBlocked('/parent'), isFalse);
    expect(ParentControls.isRouteBlocked('/lullabies'), isFalse);
  });
}
