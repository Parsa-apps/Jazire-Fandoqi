import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/game_data.dart';
import 'package:jazireh_fandoghi/core/growth/activity_tracker.dart';
import 'package:jazireh_fandoghi/core/growth/certificate_builder.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/core/growth/seasonal_events.dart';
import 'package:jazireh_fandoghi/core/growth/sibling_profiles.dart';
import 'package:jazireh_fandoghi/core/growth/smart_conversion.dart';
import 'package:jazireh_fandoghi/core/jalali_calendar.dart';

void main() {
  setUp(() {
    GameData.resetForTesting();
    GrowthStore.resetForTesting();
  });

  test('activity tracker records opens and classifies kinds', () {
    ActivityTracker.recordOpen(route: '/cartoons', title: 'سینما کارتون');
    expect(GrowthStore.lastKind, 'entertainment');

    ActivityTracker.recordOpen(route: '/game/الفبا', title: 'الفبا', skill: 'alphabet');
    expect(GrowthStore.lastKind, 'learning');
    expect(GrowthStore.lastRoute, '/game/الفبا');
    expect(ActivityTracker.recent.first.$2, 'الفبا');

    ActivityTracker.noteAnswer(correct: true);
    ActivityTracker.noteAnswer(correct: false);
    expect(GrowthStore.sessionCorrect, 1);
    expect(GrowthStore.sessionWrong, 1);
    expect(ActivityTracker.recapText(), contains('۱'));

    ActivityTracker.endSession();
    expect(GrowthStore.sessionCorrect, 0);
  });

  test('favorites toggle on and off', () {
    ActivityTracker.toggleFavorite('/game/الفبا|الفبا');
    expect(ActivityTracker.isFavorite('/game/الفبا|الفبا'), isTrue);
    ActivityTracker.toggleFavorite('/game/الفبا|الفبا');
    expect(ActivityTracker.isFavorite('/game/الفبا|الفبا'), isFalse);
  });

  test('seasonal events fire on their jalali dates only', () {
    expect(SeasonalEvents.current(JalaliDate(1405, 1, 5))?.id, 'nowruz');
    expect(SeasonalEvents.current(JalaliDate(1405, 9, 30))?.id, 'yalda');
    expect(SeasonalEvents.current(JalaliDate(1405, 5, 10)), isNull);
  });

  test('seasonal bonus is one claim per event per year', () {
    // اگر امروز رویدادی نیست، هیچ سکه‌ای نباید صادر شود.
    final result = SeasonalEvents.claimSeasonalBonus();
    if (SeasonalEvents.current() == null) {
      expect(result, isFalse);
    } else {
      expect(result, isTrue);
      expect(SeasonalEvents.claimSeasonalBonus(), isFalse);
    }
  });

  test('sibling profiles cap at three and keep separate progress', () {
    expect(SiblingProfiles.all.length, 1);
    expect(SiblingProfiles.add(name: 'سارا', age: 4), isTrue);
    expect(SiblingProfiles.add(name: 'علی', age: 7), isTrue);
    expect(SiblingProfiles.add(name: 'زیاد', age: 5), isFalse);

    GameData.addStars(9);
    final newId = SiblingProfiles.all.last['id'].toString();
    expect(SiblingProfiles.switchTo(newId), isTrue);
    // کودک تازه با پیشرفت صفر شروع می‌کند.
    expect(GameData.stars, 0);

    // برگشت به کودک اول، ستاره‌هایش را برمی‌گرداند.
    expect(SiblingProfiles.switchTo('default'), isTrue);
    expect(GameData.stars, 9);
  });

  test('smart conversion spaces the paywall and pays referral once', () {
    expect(SmartConversion.shouldOfferPaywall, isFalse);
    for (var i = 0; i < SmartConversion.paywallThreshold; i++) {
      SmartConversion.noteLockedTap();
    }
    expect(SmartConversion.shouldOfferPaywall, isTrue);

    final coinsBefore = GameData.coins;
    expect(SmartConversion.claimReferralCoins(), isTrue);
    expect(GameData.coins, coinsBefore + 20);
    expect(SmartConversion.claimReferralCoins(), isFalse);
  });

  test('certificates are earned only when the requirement is met', () {
    expect(CertificateBuilder.all().length, 6);
    expect(CertificateBuilder.earnedCount, 0);

    for (var i = 0; i < 20; i++) {
      GameData.recordAnswer(correct: true, skill: 'alphabet');
    }
    expect(
      CertificateBuilder.all().firstWhere((c) => c.id == 'cert_alpha').earned,
      isTrue,
    );
    expect(CertificateBuilder.achievementCardText('خوشنویس'), contains('مدال'));
  });

  test('jalali weekday names map 1..7 to Monday..Sunday', () {
    // 2026-08-10 یک دوشنبه است.
    expect(JalaliDate.weekdayName(DateTime(2026, 8, 10)), 'دوشنبه');
    expect(JalaliDate.weekdayName(DateTime(2026, 8, 14)), 'جمعه');
    expect(JalaliDate.weekdayName(DateTime(2026, 8, 16)), 'یکشنبه');
  });
}
