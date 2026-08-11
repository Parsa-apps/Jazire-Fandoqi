import 'growth_store.dart';

/// قوانین کنترل والد برای ساعت خواب، فیلتر محتوا، سکوت شب و تمرکز.
class ParentControls {
  ParentControls._();

  static bool get isBedtimeNow {
    if (!GrowthStore.bedtimeEnabled) return false;
    final hour = DateTime.now().hour;
    final bed = GrowthStore.bedtimeHour;
    final wake = GrowthStore.wakeHour;
    // مثلاً ۲۱ تا ۷ صبح
    if (bed > wake) {
      return hour >= bed || hour < wake;
    }
    return hour >= bed && hour < wake;
  }

  /// در ساعت خواب فقط لالایی و پنل والدین مجاز است.
  static bool isRouteBlocked(String route) {
    if (route.contains('parent') ||
        route.contains('lullab') ||
        route.contains('about') ||
        route.contains('privacy') ||
        route.contains('whats-new') ||
        route.contains('booklet')) {
      return false;
    }
    if (isBedtimeNow) return true;
    if (!GrowthStore.cartoonsAllowed && route.contains('cartoon')) {
      return true;
    }
    if (!GrowthStore.storiesAllowed &&
        (route.contains('stor') || route.contains('قصه'))) {
      return true;
    }
    if (!GrowthStore.shopAllowed &&
        (route.contains('shop') || route.contains('فروش'))) {
      return true;
    }
    return false;
  }

  static String blockReason(String route) {
    if (isBedtimeNow) {
      return 'ساعت خواب است؛ فندقی فقط لالایی پخش می‌کند تا چشم‌ها استراحت کنند 🌙';
    }
    if (!GrowthStore.cartoonsAllowed && route.contains('cartoon')) {
      return 'مامان/بابا تماشای کارتون را موقتاً بسته‌اند.';
    }
    if (!GrowthStore.storiesAllowed && route.contains('stor')) {
      return 'قصه‌خانه فعلاً از پنل والدین خاموش است.';
    }
    if (!GrowthStore.shopAllowed && route.contains('shop')) {
      return 'فروشگاه از پنل والدین مخفی شده است.';
    }
    return 'این بخش الان در دسترس نیست.';
  }

  static bool get shouldMuteSound {
    if (!GrowthStore.quietHoursEnabled) return false;
    return isBedtimeNow;
  }

  static bool get shouldReduceMotion => GrowthStore.reduceMotion;
  static bool get colorBlindMode => GrowthStore.colorBlindMode;
  static bool get focusMode => GrowthStore.focusMode;
  static bool get dataSaver => GrowthStore.dataSaver;
  static bool get shopVisible =>
      GrowthStore.shopAllowed && !GrowthStore.focusMode;
}
