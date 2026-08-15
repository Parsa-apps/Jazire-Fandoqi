import '../game_data.dart';
import 'growth_store.dart';
import 'seasonal_events.dart';

/// تبدیل هوشمند بدون فشار روی کودک — فقط بعد از درگیر شدن والد.
class SmartConversion {
  SmartConversion._();

  static const int paywallThreshold = 3;

  static void noteLockedTap() {
    GrowthStore.lockedTaps++;
    GrowthStore.save();
  }

  static bool get shouldOfferPaywall =>
      GrowthStore.lockedTaps > 0 &&
      GrowthStore.lockedTaps % paywallThreshold == 0;

  static String familyPackCopy(String? featureName) {
    final feature = featureName == null ? 'همه دنیاها' : '«$featureName» و بقیه دنیاها';
    return 'نسخه خانوادگی: $feature برای همیشه باز می‌شود. یک‌بار پرداخت، بدون تمدید، بدون تبلیغ. مناسب خواهر و برادر روی همین گوشی.';
  }

  static String shareAppText() {
    final name =
        GameData.childName.isNotEmpty ? GameData.childName : 'فرزندتان';
    return 'ما با $name جزیره فندقی بازی می‌کنیم — آموزش الفبا و بازی آفلاین بدون تبلیغ. در فروشگاه برنامه‌ها جستجو کنید: جزیره فندقی';
  }

  static bool claimReferralCoins({int reward = 20}) {
    if (GrowthStore.referralClaimed) return false;
    GrowthStore.referralClaimed = true;
    GameData.addCoins(reward);
    GrowthStore.save();
    return true;
  }

  static bool get isFreeWeekendUnlock => SeasonalEvents.isFamilyWeekend();
}
