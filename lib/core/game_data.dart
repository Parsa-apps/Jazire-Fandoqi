import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/hive_player_store.dart';

/// Single source of truth for the local player profile.
///
/// The app is intentionally offline-first: no child data leaves the device and
/// a temporary storage failure must not prevent the child from playing. The
/// class keeps the old SharedPreferences keys for backwards compatibility and
/// serialises writes so fast game events cannot overwrite one another.
class GameData {
  GameData._();

  static const int maxStageCount = 12;
  static const int _maxStoredCounter = 100000000;

  static SharedPreferences? _prefs;
  static Future<void>? _loadFuture;
  static Future<void> _saveQueue = Future<void>.value();
  static bool _isLoaded = false;
  static bool _persistenceAvailable = false;

  /// Screens listen to this value instead of trying to pass game state
  /// through every route. It also makes returning from a game update the
  /// dashboard/profile immediately.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static bool get isLoaded => _isLoaded;
  static bool get persistenceAvailable => _persistenceAvailable;

  // Player stats
  static int stars = 0;
  static int coins = 0;
  static int level = 1;
  static int streak = 0;
  static int totalCorrect = 0;
  static int totalWrong = 0;
  static int dailyMissions = 0;
  static int sessionSeconds = 0;
  static int weeklyPlayMinutes = 0;
  static int todayPlaySeconds = 0;
  static int highScore = 0;
  static int mathRaceHighScore = 0;
  static int quizHighScore = 0;

  // Player identity. Only a local nickname and age range are stored.
  static String lastLogin = '';
  static String avatar = '😊';
  static String childName = '';
  static int childAge = 5;
  static bool onboardingSeen = false;

  // Feature state
  static String lastWeekReset = '';
  static String _missionDay = '';
  static String lastLuckyDate = '';
  static String lastSurpriseClaimDate = '';
  static List<String> achievements = <String>[];
  static List<String> stickers = <String>[];
  static List<String> ownedItems = <String>[];
  static Map<String, int> missionProgress = <String, int>{
    'questions': 0,
    'alphabet': 0,
    'drawing': 0,
    'colors': 0,
  };
  static Map<String, int> skills = <String, int>{
    'math': 0,
    'alphabet': 0,
    'memory': 0,
    'colors': 0,
    'shapes': 0,
    'animals': 0,
    'counting': 0,
    'pattern': 0,
    'fruits': 0,
    'concepts': 0,
    'vocab': 0,
    'body': 0,
    'vehicles': 0,
    'time': 0,
    'weather': 0,
    'emotions': 0,
    'jobs': 0,
  };

  // Settings
  static int timeLimitMinutes = 60;
  static String parentPin = '';
  static bool treasureOpened = false;
  static bool goldenChestOpened = false;
  static bool soundEnabled = true;
  static bool luckyWheelSpunToday = false;
  static bool aiBuddyUnlocked = false;

  /// فاز ۷: مقیاس فونت قابل تنظیم توسط والدین (0.85 تا 1.4)
  static double textScale = 1.0;

  /// فاز ۱۶: ترجیح دست کودک (چپ‌دست / راست‌دست)
  static bool isLeftHanded = false;

  // Stage map progress
  static int currentStage = 1;
  static int currentIsland = 0;
  static Map<String, bool> completedStages = <String, bool>{};

  // Prize box
  static int prizeBoxTokens = 0;
  static List<String> openedPrizes = <String>[];

  // ✅ فیکس عمیق فاز ۳۰: achievement_system به playedGames نیاز داشت ولی نبود — باعث بیلد فیل خاموش
  static List<String> playedGames = <String>[];
  static final Set<String> _playedGamesSet = <String>{};

  /// Loads persisted state once. A second caller receives the same Future,
  /// which prevents two app-start reads from racing each other.
  static Future<void> load() {
    return _loadFuture ??= _loadInternal();
  }

  static Future<void> _loadInternal() async {
    try {
      // ── فاز ۴: دیتابیس Hive اول ─────────────────────────────
      // اگر اسنپ‌شات جدید Hive موجود بود، مستقیم از آن می‌خوانیم
      // (سریع‌تر و یکجا). در غیر این صورت SharedPreferences قدیمی
      // خوانده شده و با اولین save به Hive مهاجرت می‌کند.
      final hiveSnapshot = await HivePlayerStore.readSnapshot();
      if (hiveSnapshot != null) {
        _applySnapshot(hiveSnapshot);
        _isLoaded = true;
        _persistenceAvailable = true;
        final changed = _rolloverDates();
        if (changed) {
          await _writeAll();
        }
        _notify();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;

      stars = _readInt('stars', 0);
      coins = _readInt('c', 0);
      level = _readInt('l', 1, min: 1, max: _maxStoredCounter);
      streak = _readInt('s', 0, min: 0, max: 100000);
      totalCorrect = _readInt('tc', 0);
      totalWrong = _readInt('tw', 0);
      lastLogin = prefs.getString('ll') ?? '';
      avatar = _readString('av', '😊', maxLength: 8);
      childName = _readString('childName', '', maxLength: 24).trim();
      childAge = _readInt('childAge', 5, min: 3, max: 12);
      onboardingSeen = prefs.getBool('onboardingSeen') ?? false;
      dailyMissions = _readInt('dm', 0, min: 0, max: missionTargets.length);
      _missionDay = prefs.getString('missionDay') ?? '';

      for (final id in missionProgress.keys.toList()) {
        missionProgress[id] = _readInt('mp_$id', 0, min: 0, max: 100000);
      }

      sessionSeconds = _readInt('ss', 0);
      weeklyPlayMinutes = _readInt('wpm', 0);
      todayPlaySeconds = _readInt('tps', 0);
      achievements = _readList('ach');
      stickers = _readList('st');
      ownedItems = _readList('ownedItems');
      // Older builds stored every shop item in `st`. Keep those purchases.
      if (ownedItems.isEmpty) ownedItems = List<String>.from(stickers);
      timeLimitMinutes = _readInt('tl', 60, min: 15, max: 24 * 60);
      treasureOpened = prefs.getBool('tr') ?? false;
      goldenChestOpened = prefs.getBool('gc') ?? false;
      soundEnabled = prefs.getBool('sn') ?? true;
      textScale = (prefs.getDouble('tsc') ?? 1.0).clamp(0.85, 1.4).toDouble();
      isLeftHanded = prefs.getBool('lh') ?? false;
      lastWeekReset = prefs.getString('lwr') ?? '';
      highScore = _readInt('hs', 0);
      mathRaceHighScore = _readInt('mrhs', 0);
      quizHighScore = _readInt('qhs', 0);
      lastLuckyDate = prefs.getString('lld') ?? '';
      lastSurpriseClaimDate = prefs.getString('lscd') ?? '';
      aiBuddyUnlocked = prefs.getBool('aiBuddy') ?? false;

      currentStage = _readInt('currentStage', 1, min: 1, max: maxStageCount + 1);
      currentIsland = _readInt('currentIsland', 0, min: 0, max: maxStageCount);
      completedStages = <String, bool>{};
      final completedKeys = prefs.getStringList('csKeys') ?? <String>[];
      for (final key in completedKeys) {
        if (key.isEmpty || key.length > 64) continue;
        if (prefs.getBool('cs_$key') == true) {
          completedStages[key] = true;
        }
      }

      prizeBoxTokens = _readInt('pbt', 0);
      openedPrizes = _readList('op');
      // ✅ فیکس: بارگذاری playedGames برای achievement
      playedGames = _readList('pg');
      _playedGamesSet
        ..clear()
        ..addAll(playedGames);

      for (final key in skills.keys.toList()) {
        skills[key] = _readInt('sk_$key', 0, max: _maxStoredCounter);
      }

      _isLoaded = true;
      _persistenceAvailable = true;
      final changed = _rolloverDates();
      if (changed) {
        await prefs.setString('missionDay', _dateKey());
        await _writeAll();
      }
      _notify();
    } catch (_) {
      // Allow the caller to show a recoverable fallback. A later retry is
      // possible because the failed Future is cleared here.
      _loadFuture = null;
      rethrow;
    }
  }

  /// Used when the platform storage plugin is temporarily unavailable. The
  /// child can still use the app for this session; persistence is simply off.
  static void useMemoryFallback() {
    _prefs = null;
    _missionDay = '';
    _isLoaded = true;
    _persistenceAvailable = false;
    _loadFuture = Future<void>.value();
    _notify();
  }

  static int _readInt(
    String key,
    int fallback, {
    int min = 0,
    int max = _maxStoredCounter,
  }) {
    final value = _prefs?.getInt(key);
    if (value == null) return fallback;
    return value.clamp(min, max).toInt();
  }

  static String _readString(
    String key,
    String fallback, {
    required int maxLength,
  }) {
    final value = _prefs?.getString(key);
    if (value == null) return fallback;
    return value.length <= maxLength ? value : value.substring(0, maxLength);
  }

  static List<String> _readList(String key) {
    final values = _prefs?.getStringList(key) ?? <String>[];
    return values
        .where((value) => value.isNotEmpty && value.length <= 64)
        .toSet()
        .toList();
  }

  /// اعمال اسنپ‌شات Hive (فاز ۴) روی حالت حافظه با خواندن امن.
  static void _applySnapshot(Map<String, Object?> d) {
    int asInt(String key, int fallback) {
      final v = d[key];
      if (v is num) return v.toInt();
      return fallback;
    }

    String asString(String key, String fallback) {
      final v = d[key];
      if (v is String && v.isNotEmpty) return v;
      return fallback;
    }

    bool asBool(String key, bool fallback) {
      final v = d[key];
      if (v is bool) return v;
      return fallback;
    }

    List<String> asList(String key) {
      final v = d[key];
      if (v is List) {
        return v
            .whereType<String>()
            .where((s) => s.isNotEmpty && s.length <= 64)
            .toSet()
            .toList();
      }
      return <String>[];
    }

    Map<String, int> asSkillMap(String key) {
      final v = d[key];
      if (v is Map) {
        return v.map((k, val) => MapEntry(
              k.toString(),
              val is num ? val.toInt().clamp(0, _maxStoredCounter) : 0,
            ));
      }
      return <String, int>{};
    }

    stars = asInt('stars', 0).clamp(0, _maxStoredCounter);
    coins = asInt('c', 0).clamp(0, _maxStoredCounter);
    level = asInt('l', 1).clamp(1, _maxStoredCounter);
    streak = asInt('s', 0).clamp(0, 100000);
    totalCorrect = asInt('tc', 0).clamp(0, _maxStoredCounter);
    totalWrong = asInt('tw', 0).clamp(0, _maxStoredCounter);
    lastLogin = asString('ll', '');
    avatar = asString('av', '😊');
    if (avatar.length > 8) avatar = avatar.substring(0, 8);
    childName = asString('childName', '');
    if (childName.length > 24) childName = childName.substring(0, 24);
    childAge = asInt('childAge', 5).clamp(3, 12);
    onboardingSeen = asBool('onboardingSeen', false);
    dailyMissions = asInt('dm', 0).clamp(0, missionTargets.length);
    _missionDay = asString('missionDay', '');
    final mp = d['mp'];
    if (mp is Map) {
      for (final id in missionProgress.keys.toList()) {
        final val = mp[id];
        missionProgress[id] = val is num ? val.toInt().clamp(0, 100000) : 0;
      }
    }
    sessionSeconds = asInt('ss', 0).clamp(0, _maxStoredCounter);
    weeklyPlayMinutes = asInt('wpm', 0).clamp(0, _maxStoredCounter);
    todayPlaySeconds = asInt('tps', 0).clamp(0, _maxStoredCounter);
    achievements = asList('ach');
    stickers = asList('st');
    ownedItems = asList('ownedItems');
    if (ownedItems.isEmpty) ownedItems = List<String>.from(stickers);
    timeLimitMinutes = asInt('tl', 60).clamp(15, 24 * 60);
    treasureOpened = asBool('tr', false);
    goldenChestOpened = asBool('gc', false);
    soundEnabled = asBool('sn', true);
    isLeftHanded = asBool('lh', false);
    final tsc = d['tsc'];
    if (tsc is num) textScale = tsc.toDouble().clamp(0.85, 1.4).toDouble();
    lastWeekReset = asString('lwr', '');
    highScore = asInt('hs', 0).clamp(0, _maxStoredCounter);
    mathRaceHighScore = asInt('mrhs', 0).clamp(0, _maxStoredCounter);
    quizHighScore = asInt('qhs', 0).clamp(0, _maxStoredCounter);
    lastLuckyDate = asString('lld', '');
    lastSurpriseClaimDate = asString('lscd', '');
    aiBuddyUnlocked = asBool('aiBuddy', false);
    currentStage = asInt('currentStage', 1).clamp(1, maxStageCount + 1);
    currentIsland = asInt('currentIsland', 0).clamp(0, maxStageCount);
    completedStages = <String, bool>{};
    final cs = d['cs'];
    if (cs is Map) {
      cs.forEach((k, v) {
        if (k is String && k.isNotEmpty && k.length <= 64 && v == true) {
          completedStages[k] = true;
        }
      });
    }
    prizeBoxTokens = asInt('pbt', 0).clamp(0, _maxStoredCounter);
    openedPrizes = asList('op');
    playedGames = asList('pg');
    _playedGamesSet
      ..clear()
      ..addAll(playedGames);
    final sk = asSkillMap('skills');
    if (sk.isNotEmpty) skills = sk;
  }

  /// ساخت اسنپ‌شات Hive از وضعیت فعلی (فاز ۴).
  static Map<String, Object?> _buildSnapshot() => <String, Object?>{
        'stars': stars,
        'c': coins,
        'l': level,
        's': streak,
        'tc': totalCorrect,
        'tw': totalWrong,
        'll': lastLogin,
        'av': avatar,
        'childName': childName,
        'childAge': childAge,
        'onboardingSeen': onboardingSeen,
        'dm': dailyMissions,
        'missionDay': _missionDay,
        'mp': missionProgress,
        'ss': sessionSeconds,
        'wpm': weeklyPlayMinutes,
        'tps': todayPlaySeconds,
        'ach': achievements,
        'st': stickers,
        'ownedItems': ownedItems,
        'tl': timeLimitMinutes,
        'tr': treasureOpened,
        'gc': goldenChestOpened,
        'sn': soundEnabled,
        'tsc': textScale,
        'lh': isLeftHanded,
        'lwr': lastWeekReset,
        'hs': highScore,
        'mrhs': mathRaceHighScore,
        'qhs': quizHighScore,
        'lld': lastLuckyDate,
        'lscd': lastSurpriseClaimDate,
        'aiBuddy': aiBuddyUnlocked,
        'currentStage': currentStage,
        'currentIsland': currentIsland,
        'cs': completedStages,
        'pbt': prizeBoxTokens,
        'op': openedPrizes,
        'pg': playedGames,
        'skills': skills,
      };

  static String _dateKey([DateTime? date]) {
    final value = date ?? DateTime.now();
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String _weekKey([DateTime? date]) {
    final value = date ?? DateTime.now();
    final monday = value.subtract(Duration(days: value.weekday - 1));
    return _dateKey(monday);
  }

  static bool _rolloverDates() {
    final today = _dateKey();
    var changed = false;

    if (lastLogin == today) {
      // The app was opened earlier today; keep the current streak.
    } else if (lastLogin == _dateKey(DateTime.now().subtract(const Duration(days: 1)))) {
      streak = min(streak + 1, 100000);
      changed = true;
    } else {
      streak = 1;
      changed = true;
    }
    if (lastLogin != today) {
      lastLogin = today;
      changed = true;
    }

    final missionDay = _missionDay.isNotEmpty
        ? _missionDay
        : _prefs?.getString('missionDay') ?? '';
    if (missionDay != today) {
      for (final id in missionProgress.keys.toList()) {
        missionProgress[id] = 0;
      }
      dailyMissions = 0;
      treasureOpened = false;
      todayPlaySeconds = 0;
      openedPrizes.removeWhere((id) => id.startsWith('daily_'));
      _missionDay = today;
      changed = true;
    } else {
      _missionDay = today;
      _recalculateDailyMissions();
    }

    final week = _weekKey();
    if (lastWeekReset != week) {
      weeklyPlayMinutes = 0;
      goldenChestOpened = false;
      openedPrizes.removeWhere((id) => id.startsWith('weekly_'));
      lastWeekReset = week;
      changed = true;
    }

    luckyWheelSpunToday = lastLuckyDate == today;
    return changed;
  }

  static Future<void> save() {
    if (!_isLoaded || !_persistenceAvailable || _prefs == null) {
      return Future<void>.value();
    }

    // Recover the queue if an earlier disk write failed, then continue with
    // the newest snapshot. This is deliberately fire-and-forget at call sites
    // but remains awaitable for settings screens and tests.
    _saveQueue = _saveQueue
        .then<void>(
          (_) => _writeAll(),
          onError: (_, __) => _writeAll(),
        )
        .catchError((_) {
          // Local persistence is best-effort; gameplay remains available if
          // the platform storage becomes read-only or full.
        });
    return _saveQueue;
  }

  static Future<void> _writeAll() async {
    final prefs = _prefs;
    if (prefs == null) return;

    await prefs.setInt('stars', stars);
    await prefs.setInt('c', coins);
    await prefs.setInt('l', level);
    await prefs.setInt('s', streak);
    await prefs.setInt('tc', totalCorrect);
    await prefs.setInt('tw', totalWrong);
    await prefs.setString('ll', lastLogin);
    await prefs.setString('av', avatar);
    await prefs.setString('childName', childName);
    await prefs.setInt('childAge', childAge);
    await prefs.setBool('onboardingSeen', onboardingSeen);
    await prefs.setInt('dm', dailyMissions);
    await prefs.setString('missionDay', _missionDay);
    for (final entry in missionProgress.entries) {
      await prefs.setInt('mp_${entry.key}', entry.value);
    }
    await prefs.setInt('ss', sessionSeconds);
    await prefs.setStringList('ach', List<String>.from(achievements));
    await prefs.setStringList('st', List<String>.from(stickers));
    await prefs.setStringList('ownedItems', List<String>.from(ownedItems));
    await prefs.setInt('tl', timeLimitMinutes);
    await prefs.setBool('tr', treasureOpened);
    await prefs.setBool('gc', goldenChestOpened);
    await prefs.setBool('sn', soundEnabled);
    await prefs.setDouble('tsc', textScale);
    await prefs.setBool('lh', isLeftHanded);
    await prefs.setInt('wpm', weeklyPlayMinutes);
    await prefs.setInt('tps', todayPlaySeconds);
    await prefs.setString('lwr', lastWeekReset);
    await prefs.setInt('hs', highScore);
    await prefs.setInt('mrhs', mathRaceHighScore);
    await prefs.setInt('qhs', quizHighScore);
    await prefs.setString('lld', lastLuckyDate);
    await prefs.setString('lscd', lastSurpriseClaimDate);
    await prefs.setBool('aiBuddy', aiBuddyUnlocked);
    await prefs.setInt('currentStage', currentStage);
    await prefs.setInt('currentIsland', currentIsland);
    await prefs.setStringList('csKeys', completedStages.keys.toList());
    for (final entry in completedStages.entries) {
      await prefs.setBool('cs_${entry.key}', entry.value);
    }
    await prefs.setInt('pbt', prizeBoxTokens);
    await prefs.setStringList('op', List<String>.from(openedPrizes));
    await prefs.setStringList('pg', List<String>.from(playedGames));
    for (final key in skills.keys) {
      await prefs.setInt('sk_$key', skills[key] ?? 0);
    }

    // ── فاز ۴: همگام‌سازی با دیتابیس Hive ──
    // همواره هم‌زمان با SharedPreferences (سازگاری با نسخه‌های قدیم)
    await HivePlayerStore.writeSnapshot(_buildSnapshot());
  }

  static void _notify() {
    changes.value++;
  }

  static void _recalculateDailyMissions() {
    dailyMissions = missionProgress.entries
        .where((entry) => entry.value >= (missionTargets[entry.key] ?? 1))
        .length;
  }

  static void addStars(int amount) {
    if (!_isLoaded || amount <= 0) return;
    stars = min(_maxStoredCounter, stars + amount);
    _notify();
    unawaited(save());
  }

  static void addCoins(int amount) {
    if (!_isLoaded || amount <= 0) return;
    coins = min(_maxStoredCounter, coins + amount);
    level = min(_maxStoredCounter, (coins ~/ 100) + 1);
    _autoAchieve();
    _notify();
    unawaited(save());
  }

  static void recordCorrect({String? skill}) {
    recordAnswer(correct: true, skill: skill);
  }

  static void recordWrong({String? skill}) {
    recordAnswer(correct: false, skill: skill);
  }

  static void recordAnswer({required bool correct, String? skill}) {
    if (!_isLoaded) return;
    if (correct) {
      totalCorrect = min(_maxStoredCounter, totalCorrect + 1);
    } else {
      totalWrong = min(_maxStoredCounter, totalWrong + 1);
    }
    _progressMissionInternal('questions');
    if (skill != null && skills.containsKey(skill)) {
      skills[skill] = min(_maxStoredCounter, (skills[skill] ?? 0) + 1);
      // هر مهارت = یک نوع بازی، برای achievement
      if (_playedGamesSet.add(skill)) {
        playedGames = _playedGamesSet.toList();
      }
    }
    _autoAchieve();
    _notify();
    unawaited(save());
  }

  static double get successRate {
    final total = totalCorrect + totalWrong;
    return total == 0 ? 0 : totalCorrect / total;
  }

  static void addSkill(String skill) {
    if (!_isLoaded || !skills.containsKey(skill)) return;
    skills[skill] = min(_maxStoredCounter, (skills[skill] ?? 0) + 1);
    _notify();
    unawaited(save());
  }

  static const Map<String, int> missionTargets = <String, int>{
    'questions': 5,
    'alphabet': 1,
    'drawing': 1,
    'colors': 1,
  };

  static void progressMission(String id, {int amount = 1}) {
    if (!_isLoaded || amount <= 0 || !missionTargets.containsKey(id)) return;
    _progressMissionInternal(id, amount: amount);
    _recalculateDailyMissions();
    _notify();
    unawaited(save());
  }

  static void _progressMissionInternal(String id, {int amount = 1}) {
    final target = missionTargets[id];
    if (target == null) return;
    missionProgress[id] = min(target, (missionProgress[id] ?? 0) + amount);
    _recalculateDailyMissions();
  }

  static bool isMissionDone(String id) =>
      (missionProgress[id] ?? 0) >= (missionTargets[id] ?? 1);

  static int missionValue(String id) => missionProgress[id] ?? 0;

  static void unlockAch(String id) {
    if (!_isLoaded || id.isEmpty || achievements.contains(id)) return;
    achievements.add(id);
    _notify();
    unawaited(save());
  }

  static bool buyItem(String id, int price) {
    if (!_isLoaded || id.isEmpty || price < 0 || coins < price || hasItem(id)) {
      return false;
    }
    coins -= price;
    ownedItems.add(id);
    // Keep the legacy collection in sync because older UI versions read it.
    if (!stickers.contains(id)) stickers.add(id);
    _autoAchieve();
    _notify();
    unawaited(save());
    return true;
  }

  static bool buySticker(String id, int price) => buyItem(id, price);

  static bool hasItem(String id) =>
      ownedItems.contains(id) || stickers.contains(id);

  /// ✅ فیکس عمیق فاز ۳۰: ثبت بازی‌های انجام شده برای achievement
  static void recordGamePlayed(String gameId) {
    if (!_isLoaded || gameId.isEmpty) return;
    if (_playedGamesSet.contains(gameId)) return;
    _playedGamesSet.add(gameId);
    playedGames = _playedGamesSet.toList();
    _notify();
    unawaited(save());
  }

  /// Refreshes day/week boundaries while the app remains open across
  /// midnight. Previously the rollover only happened during app startup, so a
  /// child could carry yesterday's limit and missions into the next day.
  static void _refreshDateBoundaries() {
    final today = _dateKey();
    if (lastLogin == today &&
        _missionDay == today &&
        lastWeekReset == _weekKey()) {
      return;
    }

    if (_rolloverDates()) {
      _notify();
      unawaited(save());
    }
  }

  /// Adds foreground play time. It is called by the app session tracker, not
  /// from every game frame, so it has negligible battery/storage overhead.
  static void addPlayTime({int seconds = 1}) {
    if (!_isLoaded || seconds <= 0) return;
    _refreshDateBoundaries();
    final previousMinute = todayPlaySeconds ~/ 60;
    todayPlaySeconds = min(_maxStoredCounter, todayPlaySeconds + seconds);
    sessionSeconds = min(_maxStoredCounter, sessionSeconds + seconds);
    final currentMinute = todayPlaySeconds ~/ 60;
    weeklyPlayMinutes = min(
      _maxStoredCounter,
      weeklyPlayMinutes + max(0, currentMinute - previousMinute),
    );
    final shouldPublish =
        currentMinute != previousMinute || todayPlaySeconds % 15 == 0;
    if (shouldPublish) {
      _notify();
      unawaited(save());
    }
  }

  static bool get isDailyLimitReached =>
      timeLimitMinutes > 0 && todayPlaySeconds >= timeLimitMinutes * 60;

  static int get remainingPlaySeconds => max(
        0,
        timeLimitMinutes * 60 - todayPlaySeconds,
      );

  static void updateHighScore(int score, String game) {
    if (!_isLoaded || score <= 0) return;
    var changed = false;
    if (game == 'math_race' && score > mathRaceHighScore) {
      mathRaceHighScore = score;
      changed = true;
    }
    if (game == 'quiz' && score > quizHighScore) {
      quizHighScore = score;
      changed = true;
    }
    if (score > highScore) {
      highScore = score;
      changed = true;
    }
    if (changed) {
      _notify();
      unawaited(save());
    }
  }

  static void spinLucky() {
    if (!_isLoaded) return;
    luckyWheelSpunToday = true;
    lastLuckyDate = _dateKey();
    _notify();
    unawaited(save());
  }

  /// Completes a map stage exactly once. Returning false means the reward was
  /// already claimed, which prevents replaying a stage to farm currency.
  static bool completeStage(String stageId, {int? stageNumber}) {
    if (!_isLoaded || stageId.isEmpty || isStageCompleted(stageId)) return false;
    completedStages[stageId] = true;
    if (stageNumber != null && stageNumber == currentStage) {
      currentStage = min(maxStageCount + 1, currentStage + 1);
      currentIsland = ((currentStage - 1) ~/ 3).clamp(0, maxStageCount).toInt();
    }
    stars = min(_maxStoredCounter, stars + 3);
    prizeBoxTokens = min(_maxStoredCounter, prizeBoxTokens + 1);
    _autoAchieve();
    _notify();
    unawaited(save());
    return true;
  }

  static bool isStageCompleted(String stageId) => completedStages[stageId] ?? false;

  static int get completedStageCount =>
      completedStages.values.where((value) => value).length;

  /// ✅ فیکس عمیق فاز ۱۱: ذخیره آواتار انتخابی در onboarding
  static void completeOnboarding({
    String nickname = '',
    required int age,
    String avatarIcon = '🦊',
  }) {
    childName = nickname.trim();
    if (childName.length > 24) childName = childName.substring(0, 24);
    childAge = age.clamp(3, 12).toInt();
    avatar = avatarIcon;
    if (avatar.length > 8) avatar = avatar.substring(0, 8);
    onboardingSeen = true;
    _notify();
    unawaited(save());
  }

  static void setAvatar(String newAvatar) {
    if (newAvatar.isEmpty) return;
    avatar = newAvatar.length > 8 ? newAvatar.substring(0, 8) : newAvatar;
    _notify();
    unawaited(save());
  }

  static void setSoundEnabled(bool value) {
    soundEnabled = value;
    _notify();
    unawaited(save());
  }

  /// فاز ۷: تنظیم مقیاس فونت توسط والدین.
  static void setTextScale(double value) {
    textScale = value.clamp(0.85, 1.4).toDouble();
    _notify();
    unawaited(save());
  }

  /// فاز ۱۶: تنظیم ترجیح دست کودک.
  static void setLeftHanded(bool value) {
    isLeftHanded = value;
    _notify();
    unawaited(save());
  }

  static void setTimeLimitMinutes(int value) {
    timeLimitMinutes = value.clamp(15, 24 * 60).toInt();
    _notify();
    unawaited(save());
  }

  // ==================== PARENT CONTROL ====================
  static bool hasParentPin() => parentPin.isNotEmpty;

  static bool verifyParentPin(String pin) => pin == parentPin;

  static void setParentPin(String pin) {
    parentPin = pin;
    _notify();
    unawaited(save());
  }

  static void removeParentPin() {
    parentPin = '';
    _notify();
    unawaited(save());
  }

  // ==================== PARENT REPORT ====================
  static int get todayPlayMinutes => (todayPlaySeconds / 60).floor();
  static int get totalPlayMinutes => (sessionSeconds / 60).floor();

  static double get averageSuccessRate {
    final total = totalCorrect + totalWrong;
    return total == 0 ? 0.0 : (totalCorrect / total * 100);
  }

  static Map<String, int> get topSkills {
    final sorted = skills.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  static String getLevelName() {
    if (level >= 20) return 'استاد بزرگ 👑';
    if (level >= 15) return 'افسانه 🌟';
    if (level >= 10) return 'قهرمان آموزش 🏆';
    if (level >= 7) return 'نابغه کوچولو 🧠';
    if (level >= 5) return 'یادگیرنده ⭐';
    if (level >= 3) return 'تلاشگر 💪';
    return 'نوآموز 🌱';
  }

  static String getMascot() {
    if (level >= 15) return '🧙';
    if (level >= 10) return '🦸';
    if (level >= 7) return '🧑‍🎓';
    if (level >= 5) return '🧒';
    if (level >= 3) return '👦';
    return '👶';
  }

  static bool surprise() => streak > 0 && streak % 3 == 0;
  static bool canOpenTreasure() => dailyMissions >= 3 && !treasureOpened;
  static bool canOpenGoldenChest() => weeklyPlayMinutes >= 30 && !goldenChestOpened;

  static void _autoAchieve() {
    final candidates = <String>[];
    if (coins >= 500) candidates.add('coin_500');
    if (coins >= 1000) candidates.add('coin_1000');
    if (coins >= 5000) candidates.add('coin_5000');
    if (streak >= 3) candidates.add('streak_3');
    if (streak >= 7) candidates.add('streak_7');
    if (streak >= 30) candidates.add('streak_30');
    if (level >= 3) candidates.add('level_3');
    if (level >= 5) candidates.add('level_5');
    if (level >= 10) candidates.add('level_10');
    if (level >= 20) candidates.add('level_20');
    if (totalCorrect >= 50) candidates.add('correct_50');
    if (totalCorrect >= 100) candidates.add('correct_100');
    if (totalCorrect >= 500) candidates.add('correct_500');
    if (ownedItems.length >= 5 || stickers.length >= 5) candidates.add('collector');
    if (ownedItems.length >= 10 || stickers.length >= 10) {
      candidates.add('mega_collector');
    }
    for (final id in candidates) {
      if (!achievements.contains(id)) achievements.add(id);
    }
  }

  /// Resets only in-memory state. It is useful for deterministic widget tests
  /// and is never called by the production UI.
  @visibleForTesting
  static void resetForTesting() {
    _prefs = null;
    _isLoaded = true;
    _persistenceAvailable = false;
    _loadFuture = Future<void>.value();
    stars = 0;
    coins = 0;
    level = 1;
    streak = 0;
    totalCorrect = 0;
    totalWrong = 0;
    dailyMissions = 0;
    sessionSeconds = 0;
    weeklyPlayMinutes = 0;
    todayPlaySeconds = 0;
    highScore = 0;
    mathRaceHighScore = 0;
    quizHighScore = 0;
    lastLogin = '';
    avatar = '😊';
    childName = '';
    childAge = 5;
    onboardingSeen = false;
    lastWeekReset = '';
    _missionDay = '';
    lastLuckyDate = '';
    lastSurpriseClaimDate = '';
    achievements = <String>[];
    stickers = <String>[];
    ownedItems = <String>[];
    missionProgress = <String, int>{
      'questions': 0,
      'alphabet': 0,
      'drawing': 0,
      'colors': 0,
    };
    skills = <String, int>{
      'math': 0,
      'alphabet': 0,
      'memory': 0,
      'colors': 0,
      'shapes': 0,
      'animals': 0,
      'counting': 0,
      'pattern': 0,
      'fruits': 0,
      'concepts': 0,
      'vocab': 0,
      'body': 0,
      'vehicles': 0,
      'time': 0,
      'weather': 0,
      'emotions': 0,
      'jobs': 0,
    };
    timeLimitMinutes = 60;
    treasureOpened = false;
    goldenChestOpened = false;
    soundEnabled = true;
    textScale = 1.0;
    isLeftHanded = false;
    luckyWheelSpunToday = false;
    aiBuddyUnlocked = false;
    currentStage = 1;
    currentIsland = 0;
    completedStages = <String, bool>{};
    prizeBoxTokens = 0;
    openedPrizes = <String>[];
    playedGames = <String>[];
    _playedGamesSet.clear();
    _notify();
  }
}
