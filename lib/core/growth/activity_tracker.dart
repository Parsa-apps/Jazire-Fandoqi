import '../game_data.dart';
import 'growth_store.dart';
import 'offline_analytics.dart';
import 'persian_digits.dart';

/// ردگیری آخرین فعالیت، بازی‌های اخیر، علاقه‌مندی و جمع‌بندی نشست.
class ActivityTracker {
  ActivityTracker._();

  static const Set<String> entertainmentHints = {
    'cartoon',
    'کارتون',
    'star',
    'ستاره',
    'bubble',
    'حباب',
    'lucky',
    'چرخ',
    'wheel',
  };

  static String kindFor(String route, String title) {
    final hay = '$route $title'.toLowerCase();
    if (hay.contains('lullab') || hay.contains('لالایی')) return 'rest';
    for (final hint in entertainmentHints) {
      if (hay.contains(hint)) return 'entertainment';
    }
    return 'learning';
  }

  static void recordOpen({
    required String route,
    required String title,
    String? skill,
    String? cartoonId,
  }) {
    GrowthStore.lastRoute = route;
    GrowthStore.lastTitle = title;
    GrowthStore.lastKind = kindFor(route, title);
    if (cartoonId != null && cartoonId.isNotEmpty) {
      GrowthStore.lastCartoonId = cartoonId;
    }
    final recents = List<String>.from(GrowthStore.recentRoutes);
    recents.remove(route);
    recents.insert(0, '$route|$title');
    if (recents.length > 8) recents.removeRange(8, recents.length);
    GrowthStore.recentRoutes = recents;
    if (skill != null && skill.isNotEmpty) {
      GrowthStore.lastSkillPractice[skill] = GrowthStore.dateKey();
    }
    OfflineAnalytics.event('open', {'route': route, 'kind': GrowthStore.lastKind});
    GrowthStore.changes.bump();
    // fire-and-forget persist
    GrowthStore.save();
  }

  static void toggleFavorite(String routeTitle) {
    final list = List<String>.from(GrowthStore.favoriteGames);
    if (list.contains(routeTitle)) {
      list.remove(routeTitle);
    } else {
      list.add(routeTitle);
    }
    GrowthStore.favoriteGames = list;
    GrowthStore.save();
    GrowthStore.changes.bump();
  }

  static bool isFavorite(String routeTitle) =>
      GrowthStore.favoriteGames.contains(routeTitle);

  static List<(String route, String title)> get recent {
    return GrowthStore.recentRoutes.map((raw) {
      final parts = raw.split('|');
      if (parts.length >= 2) return (parts[0], parts.sublist(1).join('|'));
      return (raw, raw);
    }).toList();
  }

  static void noteAnswer({required bool correct}) {
    if (correct) {
      GrowthStore.sessionCorrect++;
    } else {
      GrowthStore.sessionWrong++;
    }
  }

  static void tickSecond() {
    if (!GameData.onboardingSeen) return;
    final key = GrowthStore.dateKey();
    if (GrowthStore.lastKind == 'entertainment') {
      GrowthStore.sessionEntertainmentSeconds++;
      if (GrowthStore.sessionEntertainmentSeconds % 60 == 0) {
        GrowthStore.entertainmentMinutes[key] =
            (GrowthStore.entertainmentMinutes[key] ?? 0) + 1;
        GrowthStore.dailyMinutes[key] = (GrowthStore.dailyMinutes[key] ?? 0) + 1;
      }
    } else if (GrowthStore.lastKind == 'learning') {
      GrowthStore.sessionLearningSeconds++;
      if (GrowthStore.sessionLearningSeconds % 60 == 0) {
        GrowthStore.learningMinutes[key] =
            (GrowthStore.learningMinutes[key] ?? 0) + 1;
        GrowthStore.dailyMinutes[key] = (GrowthStore.dailyMinutes[key] ?? 0) + 1;
        GrowthStore.learningChestMinutes++;
      }
    }
  }

  static void endSession() {
    GrowthStore.sessionLearningSeconds = 0;
    GrowthStore.sessionEntertainmentSeconds = 0;
    GrowthStore.sessionCorrect = 0;
    GrowthStore.sessionWrong = 0;
    GrowthStore.save();
  }

  static String recapText() {
    final name =
        GameData.childName.isNotEmpty ? GameData.childName : 'قهرمان کوچولو';
    final correct = GrowthStore.sessionCorrect;
    final wrong = GrowthStore.sessionWrong;
    if (correct + wrong == 0) {
      return '$name امروز با فندقی بازی کرد. فردا یک ماجراجویی تازه داریم!';
    }
    return '$name در این دور ${PersianDigits.toFa(correct)} پاسخ درست و ${PersianDigits.toFa(wrong)} تمرین داشت. فندقی افتخار می‌کند!';
  }

  static String? skillDecayMessage() {
    final today = DateTime.now();
    String? oldestSkill;
    var oldestDays = 0;
    GrowthStore.lastSkillPractice.forEach((skill, date) {
      final parts = date.split('-');
      if (parts.length != 3) return;
      final then = DateTime(
        int.tryParse(parts[0]) ?? today.year,
        int.tryParse(parts[1]) ?? today.month,
        int.tryParse(parts[2]) ?? today.day,
      );
      final days = today.difference(then).inDays;
      if (days > oldestDays) {
        oldestDays = days;
        oldestSkill = skill;
      }
    });
    if (oldestSkill == null || oldestDays < 4) return null;
    return 'چند روز است سراغ «$oldestSkill» نرفته‌ایم. یک دور کوتاه با فندقی چطور است؟';
  }
}
