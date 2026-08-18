import 'dart:async';

import '../../data/datasources/hive_player_store.dart';
import '../game_data.dart';
import '../jalali_calendar.dart';

/// وضعیت بسته رشد ۶.۲ — مستقل از GameData تا تست‌های قدیمی نشکنند.
///
/// همهٔ تنظیمات والد، فعالیت اخیر، خواهر/برادر، واژه‌نامه و آمار هفتگی
/// اینجا می‌ماند و با کلید `growth_v62` در Hive ذخیره می‌شود.
class GrowthStore {
  GrowthStore._();

  static const String hiveKey = 'growth_v62';
  static const String appVersion = '6.2.2';

  static final ValueNotifierLike changes = ValueNotifierLike();

  static bool _loaded = false;
  static bool _persistenceAvailable = false;
  static bool get isLoaded => _loaded;

  // ── کنترل والدین ────────────────────────────────────────
  static bool bedtimeEnabled = false;
  static int bedtimeHour = 21; // 21:00
  static int wakeHour = 7;
  static bool cartoonsAllowed = true;
  static bool shopAllowed = true;
  static bool storiesAllowed = true;
  static bool quietHoursEnabled = true;
  static bool reduceMotion = false;
  static bool colorBlindMode = false;
  static bool focusMode = false;
  static bool dataSaver = false;

  // ── فعالیت و ادامه بازی ─────────────────────────────────
  static String lastRoute = '';
  static String lastTitle = '';
  static String lastKind = 'learning'; // learning | entertainment | rest
  static String lastCartoonId = '';
  static List<String> recentRoutes = <String>[];
  static List<String> favoriteGames = <String>[];

  // ── زمان ۷ روزه + یادگیری/سرگرمی ────────────────────────
  static Map<String, int> dailyMinutes = <String, int>{};
  static Map<String, int> learningMinutes = <String, int>{};
  static Map<String, int> entertainmentMinutes = <String, int>{};
  static Map<String, String> lastSkillPractice = <String, String>{};
  static int sessionLearningSeconds = 0;
  static int sessionEntertainmentSeconds = 0;
  static int sessionCorrect = 0;
  static int sessionWrong = 0;

  // ── واژه‌نامه و مهارت زندگی ─────────────────────────────
  static List<String> vocabWords = <String>[];
  static Map<String, int> lifeSkillPoints = <String, int>{};
  static List<String> completedLifeTopics = <String>[];

  // ── چالش هفتگی و صندوق یادگیری ──────────────────────────
  static String weeklyChallengeId = '';
  static int weeklyChallengeProgress = 0;
  static int weeklyGoalMinutes = 30;
  static String weeklyGoalSkill = 'alphabet';
  static int learningChestMinutes = 0;
  static String learningChestDay = '';

  // ── تبدیل و رشد ─────────────────────────────────────────
  static int lockedTaps = 0;
  static bool referralClaimed = false;
  static String lastWhatsNewVersion = '';
  static bool reviewerNotesSeen = false;

  // ── پروفایل خواهر/برادر ─────────────────────────────────
  static String activeSiblingId = 'default';
  static List<Map<String, Object?>> siblings = <Map<String, Object?>>[];
  static Map<String, Map<String, Object?>> siblingSnapshots =
      <String, Map<String, Object?>>{};

  // ── رویدادهای آنالیتیکس محلی ────────────────────────────
  static List<Map<String, Object?>> localEvents = <Map<String, Object?>>[];

  static Future<void> load() async {
    try {
      final raw = await HivePlayerStore.readValue(hiveKey);
      if (raw is Map) {
        _apply(Map<String, Object?>.from(
          raw.map((k, v) => MapEntry(k.toString(), v)),
        ));
      }
    } catch (_) {
      // حافظه کافی است؛ کودک نباید صفحه سفید ببیند.
    }
    _ensureDefaultSibling();
    _rolloverWeek();
    _loaded = true;
    _persistenceAvailable = true;
    changes.bump();
  }

  static void useMemoryFallback() {
    _loaded = true;
    _persistenceAvailable = false;
    _ensureDefaultSibling();
    changes.bump();
  }

  static Future<void> save() async {
    if (!_loaded || !_persistenceAvailable) return;
    try {
      await HivePlayerStore.writeValue(hiveKey, _snapshot());
    } catch (_) {}
  }

  static void _notify() {
    changes.bump();
    unawaited(save());
  }

  static Map<String, Object?> _snapshot() => <String, Object?>{
        'bedtimeEnabled': bedtimeEnabled,
        'bedtimeHour': bedtimeHour,
        'wakeHour': wakeHour,
        'cartoonsAllowed': cartoonsAllowed,
        'shopAllowed': shopAllowed,
        'storiesAllowed': storiesAllowed,
        'quietHoursEnabled': quietHoursEnabled,
        'reduceMotion': reduceMotion,
        'colorBlindMode': colorBlindMode,
        'focusMode': focusMode,
        'dataSaver': dataSaver,
        'lastRoute': lastRoute,
        'lastTitle': lastTitle,
        'lastKind': lastKind,
        'lastCartoonId': lastCartoonId,
        'recentRoutes': recentRoutes,
        'favoriteGames': favoriteGames,
        'dailyMinutes': dailyMinutes,
        'learningMinutes': learningMinutes,
        'entertainmentMinutes': entertainmentMinutes,
        'lastSkillPractice': lastSkillPractice,
        'vocabWords': vocabWords,
        'lifeSkillPoints': lifeSkillPoints,
        'completedLifeTopics': completedLifeTopics,
        'weeklyChallengeId': weeklyChallengeId,
        'weeklyChallengeProgress': weeklyChallengeProgress,
        'weeklyGoalMinutes': weeklyGoalMinutes,
        'weeklyGoalSkill': weeklyGoalSkill,
        'learningChestMinutes': learningChestMinutes,
        'learningChestDay': learningChestDay,
        'lockedTaps': lockedTaps,
        'referralClaimed': referralClaimed,
        'lastWhatsNewVersion': lastWhatsNewVersion,
        'reviewerNotesSeen': reviewerNotesSeen,
        'activeSiblingId': activeSiblingId,
        'siblings': siblings,
        'siblingSnapshots': siblingSnapshots,
        'localEvents': localEvents,
      };

  static void _apply(Map<String, Object?> d) {
    bool asBool(String k, bool f) => d[k] is bool ? d[k] as bool : f;
    int asInt(String k, int f) {
      final v = d[k];
      return v is num ? v.toInt() : f;
    }

    String asStr(String k, String f) {
      final v = d[k];
      return v is String ? v : f;
    }

    List<String> asList(String k) {
      final v = d[k];
      if (v is List) {
        return v.whereType<String>().where((s) => s.isNotEmpty).toList();
      }
      return <String>[];
    }

    Map<String, int> asIntMap(String k) {
      final v = d[k];
      if (v is Map) {
        return v.map((key, val) => MapEntry(
              key.toString(),
              val is num ? val.toInt() : 0,
            ));
      }
      return <String, int>{};
    }

    Map<String, String> asStrMap(String k) {
      final v = d[k];
      if (v is Map) {
        return v.map((key, val) => MapEntry(key.toString(), val.toString()));
      }
      return <String, String>{};
    }

    bedtimeEnabled = asBool('bedtimeEnabled', false);
    bedtimeHour = asInt('bedtimeHour', 21).clamp(18, 23);
    wakeHour = asInt('wakeHour', 7).clamp(5, 10);
    cartoonsAllowed = asBool('cartoonsAllowed', true);
    shopAllowed = asBool('shopAllowed', true);
    storiesAllowed = asBool('storiesAllowed', true);
    quietHoursEnabled = asBool('quietHoursEnabled', true);
    reduceMotion = asBool('reduceMotion', false);
    colorBlindMode = asBool('colorBlindMode', false);
    focusMode = asBool('focusMode', false);
    dataSaver = asBool('dataSaver', false);
    lastRoute = asStr('lastRoute', '');
    lastTitle = asStr('lastTitle', '');
    lastKind = asStr('lastKind', 'learning');
    lastCartoonId = asStr('lastCartoonId', '');
    recentRoutes = asList('recentRoutes');
    favoriteGames = asList('favoriteGames');
    dailyMinutes = asIntMap('dailyMinutes');
    learningMinutes = asIntMap('learningMinutes');
    entertainmentMinutes = asIntMap('entertainmentMinutes');
    lastSkillPractice = asStrMap('lastSkillPractice');
    vocabWords = asList('vocabWords');
    lifeSkillPoints = asIntMap('lifeSkillPoints');
    completedLifeTopics = asList('completedLifeTopics');
    weeklyChallengeId = asStr('weeklyChallengeId', '');
    weeklyChallengeProgress = asInt('weeklyChallengeProgress', 0);
    weeklyGoalMinutes = asInt('weeklyGoalMinutes', 30).clamp(10, 180);
    weeklyGoalSkill = asStr('weeklyGoalSkill', 'alphabet');
    learningChestMinutes = asInt('learningChestMinutes', 0);
    learningChestDay = asStr('learningChestDay', '');
    lockedTaps = asInt('lockedTaps', 0);
    referralClaimed = asBool('referralClaimed', false);
    lastWhatsNewVersion = asStr('lastWhatsNewVersion', '');
    reviewerNotesSeen = asBool('reviewerNotesSeen', false);
    activeSiblingId = asStr('activeSiblingId', 'default');

    siblings = <Map<String, Object?>>[];
    final sibs = d['siblings'];
    if (sibs is List) {
      for (final item in sibs) {
        if (item is Map) {
          siblings.add(Map<String, Object?>.from(
            item.map((k, v) => MapEntry(k.toString(), v)),
          ));
        }
      }
    }

    siblingSnapshots = <String, Map<String, Object?>>{};
    final snaps = d['siblingSnapshots'];
    if (snaps is Map) {
      snaps.forEach((key, value) {
        if (value is Map) {
          siblingSnapshots[key.toString()] = Map<String, Object?>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
        }
      });
    }

    localEvents = <Map<String, Object?>>[];
    final evs = d['localEvents'];
    if (evs is List) {
      for (final item in evs.take(200)) {
        if (item is Map) {
          localEvents.add(Map<String, Object?>.from(
            item.map((k, v) => MapEntry(k.toString(), v)),
          ));
        }
      }
    }
  }

  static void _ensureDefaultSibling() {
    if (siblings.isNotEmpty) return;
    siblings.add(<String, Object?>{
      'id': 'default',
      'name': GameData.childName.isEmpty ? 'دوست کوچولو' : GameData.childName,
      'age': GameData.childAge,
      'avatar': GameData.avatar,
    });
    activeSiblingId = 'default';
  }

  static void _rolloverWeek() {
    final week = _weekKey();
    if (weeklyChallengeId.startsWith(week)) return;
    weeklyChallengeId = '';
    weeklyChallengeProgress = 0;
  }

  static String dateKey([DateTime? date]) {
    final value = date ?? DateTime.now();
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '${value.year}-$m-$d';
  }

  static String _weekKey([DateTime? date]) {
    final value = date ?? DateTime.now();
    final monday = value.subtract(Duration(days: value.weekday - 1));
    return dateKey(monday);
  }

  static String jalaliToday() => JalaliDate.today().format();

  // ── setters ─────────────────────────────────────────────
  static void setBedtime({required bool enabled, int? hour, int? wake}) {
    bedtimeEnabled = enabled;
    if (hour != null) bedtimeHour = hour.clamp(18, 23);
    if (wake != null) wakeHour = wake.clamp(5, 10);
    _notify();
  }

  static void setContentFilter({
    bool? cartoons,
    bool? shop,
    bool? stories,
  }) {
    if (cartoons != null) cartoonsAllowed = cartoons;
    if (shop != null) shopAllowed = shop;
    if (stories != null) storiesAllowed = stories;
    _notify();
  }

  static void setQuietHours(bool value) {
    quietHoursEnabled = value;
    _notify();
  }

  static void setReduceMotion(bool value) {
    reduceMotion = value;
    _notify();
  }

  static void setColorBlindMode(bool value) {
    colorBlindMode = value;
    _notify();
  }

  static void setFocusMode(bool value) {
    focusMode = value;
    _notify();
  }

  static void setDataSaver(bool value) {
    dataSaver = value;
    _notify();
  }

  static void setWeeklyGoal({int? minutes, String? skill}) {
    if (minutes != null) weeklyGoalMinutes = minutes.clamp(10, 180);
    if (skill != null && skill.isNotEmpty) weeklyGoalSkill = skill;
    _notify();
  }

  static void markWhatsNewSeen() {
    lastWhatsNewVersion = appVersion;
    _notify();
  }

  static bool get shouldShowWhatsNew => lastWhatsNewVersion != appVersion;

  static void resetForTesting() {
    _loaded = true;
    _persistenceAvailable = false;
    bedtimeEnabled = false;
    bedtimeHour = 21;
    wakeHour = 7;
    cartoonsAllowed = true;
    shopAllowed = true;
    storiesAllowed = true;
    quietHoursEnabled = true;
    reduceMotion = false;
    colorBlindMode = false;
    focusMode = false;
    dataSaver = false;
    lastRoute = '';
    lastTitle = '';
    lastKind = 'learning';
    lastCartoonId = '';
    recentRoutes = <String>[];
    favoriteGames = <String>[];
    dailyMinutes = <String, int>{};
    learningMinutes = <String, int>{};
    entertainmentMinutes = <String, int>{};
    lastSkillPractice = <String, String>{};
    sessionLearningSeconds = 0;
    sessionEntertainmentSeconds = 0;
    sessionCorrect = 0;
    sessionWrong = 0;
    vocabWords = <String>[];
    lifeSkillPoints = <String, int>{};
    completedLifeTopics = <String>[];
    weeklyChallengeId = '';
    weeklyChallengeProgress = 0;
    weeklyGoalMinutes = 30;
    weeklyGoalSkill = 'alphabet';
    learningChestMinutes = 0;
    learningChestDay = '';
    lockedTaps = 0;
    referralClaimed = false;
    lastWhatsNewVersion = '';
    reviewerNotesSeen = false;
    activeSiblingId = 'default';
    siblings = <Map<String, Object?>>[];
    siblingSnapshots = <String, Map<String, Object?>>{};
    localEvents = <Map<String, Object?>>[];
    _ensureDefaultSibling();
    changes.bump();
  }
}

/// ناتیفایر سبک بدون وابستگی به Flutter در لایهٔ داده.
class ValueNotifierLike {
  final List<void Function()> _listeners = <void Function()>[];
  int value = 0;

  void addListener(void Function() fn) => _listeners.add(fn);
  void removeListener(void Function() fn) => _listeners.remove(fn);
  void bump() {
    value++;
    for (final fn in List<void Function()>.from(_listeners)) {
      fn();
    }
  }
}


