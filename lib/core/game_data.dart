import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart' show DartSha256;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/hive_player_store.dart';
import 'drawing/drawing_album.dart';
import 'literacy/literacy_path.dart';
import 'security/secure_store.dart';

/// Single source of truth for the local player profile.
///
/// The app is intentionally offline-first: no child data leaves the device and
/// a temporary storage failure must not prevent the child from playing. The
/// class keeps the old SharedPreferences keys for backwards compatibility and
/// serialises writes so fast game events cannot overwrite one another.
class GameData {
  GameData._();

  /// فاز ۵۸: نقشه ۵۰ مرحله‌ای
  static const int maxStageCount = 50;
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

  /// دستیارهای سبک برای ذخیره‌سازی تنظیمات بولین (مانند تیک‌های اطلاع‌رسانی والدین).
  static bool? getBool(String key) => _prefs?.getBool(key);
  static Future<void> setBool(String key, bool value) async {
    if (_prefs == null) return;
    await _prefs!.setBool(key, value);
  }

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

  /// When false, the full-screen Fandoghi walkthrough is shown after splash.
  /// It only becomes true when the user ticks «دوباره نمایش نده» on the final
  /// tutorial slide.
  static bool tutorialDoNotShow = false;

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
    'math': 0,
    'memory': 0,
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
    'stories': 0,
    'lullaby': 0,
  };

  // Settings
  static int timeLimitMinutes = 60;
  /// SHA-256 digest of the 4-digit parent PIN. The raw PIN is never persisted.
  static String parentPinHash = '';
  static bool treasureOpened = false;
  static bool goldenChestOpened = false;
  static bool soundEnabled = true;

  /// بلندی موسیقی پس‌زمینه به‌صورت نرمال‌شده (۰ = قطع، ۱ = بیشترین حد امن).
  /// مقدار پیش‌فرض ۵۰٪ دقیقاً معادل میکس قبلی برنامه است.
  static const double defaultMusicVolume = 0.5;
  static double musicVolume = defaultMusicVolume;

  static bool luckyWheelSpunToday = false;
  static bool aiBuddyUnlocked = false;

  /// فاز ۷: مقیاس فونت قابل تنظیم توسط والدین (0.85 تا 1.4)
  static double textScale = 1.0;

  /// تم پویا و فعال برنامه
  static String activeTheme = 'island_map';

  /// فاز ۱۶: ترجیح دست کودک (چپ‌دست / راست‌دست)
  static bool isLeftHanded = false;

  /// نشانه‌هایی که معلم خط‌شان را تأیید کرده (کلید پایدار بسته:درس).
  static List<String> masteredAlphabetKeys = <String>[];

  /// تعداد قبولی خط برای هر نشانه — تسلط واقعی بعد از ۳ بار.
  static Map<String, int> alphabetPassCounts = <String, int>{};

  /// آخرین روز قبولی هر نشانه (yyyy-MM-dd) برای مرور فاصله‌دار.
  static Map<String, String> alphabetLastPassDay = <String, String>{};

  /// حالت روشن کلاس: پس‌زمینه کرم و دکمه‌های درشت برای ۶ ساله.
  static bool classroomLightMode = true;

  /// ایستگاه‌های تمام‌شدهٔ مسیر امروز (literacy/math/drawing/story).
  static List<String> todayPathDone = <String>[];

  /// روز مسیر امروز (yyyy-MM-dd) تا ایستگاه‌ها با عوض‌شدن تاریخ صفر شوند.
  static String todayPathDay = '';

  /// پین والد در همین نشست تأیید شده — کودک نباید صفحهٔ خرید ببیند.
  static bool parentUnlockedThisSession = false;

  // Stage map progress
  static int currentStage = 1;
  static int currentIsland = 0;
  static Map<String, bool> completedStages = <String, bool>{};

  // Prize box
  static int prizeBoxTokens = 0;
  static List<String> openedPrizes = <String>[];

  // فاز ۴۰: تزئینات جزیره‌ی شخصی (slotKey → itemId)
  static Map<String, String> islandDecorations = <String, String>{};

  // فاز ۲۹ (تکمیل): داستان‌های خوانده‌شده — پاداش فقط یک‌بار برای هر داستان
  static List<String> completedStories = <String>[];
  static List<String> storyFavorites = <String>[];
  // ذخیره‌ی وضعیت خواندن داستان برای ادامه‌ی مطالعه
  static String lastStoryPageStoryId = '';
  static int lastStoryPageIndex = 0;

  // 🎬 کارتون‌ها و انیمیشن‌ها — علاقه‌مندی‌ها و تاریخچه تماشا
  static List<String> cartoonFavorites = <String>[];
  static List<String> watchedCartoons = <String>[];
  static int cartoonWatchSeconds = 0;
  static bool appRated = false;

  // 🌙 لالایی‌ها — علاقه‌مندی‌ها و تاریخچهٔ شنیدن (هم‌زبان با قصه/کارتون)
  static List<String> lullabyFavorites = <String>[];
  static List<String> listenedLullabies = <String>[];

  // ✅ فیکس عمیق فاز ۳۰: achievement_system به playedGames نیاز داشت ولی نبود — باعث بیلد فیل خاموش
  static List<String> playedGames = <String>[];
  static final Set<String> _playedGamesSet = <String>{};

  /// Loads persisted state once. A second caller receives the same Future,
  /// which prevents two app-start reads from racing each other.
  static Future<void> load() {
    return _loadFuture ??= _loadInternal();
  }

  /// Reloads the latest local snapshot after an import or an external storage
  /// operation. [load] is intentionally idempotent during app startup, so an
  /// explicit reload is needed when the completed Future is already cached.
  static Future<void> reload() async {
    _loadFuture = null;
    _isLoaded = false;
    _persistenceAvailable = false;
    await load();
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
        await _applySecurePinOverride();
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
      avatar = _readString('av', '😊', maxLength: 128);
      childName = _readString('childName', '', maxLength: 24).trim();
      childAge = _readInt('childAge', 5, min: 3, max: 12);
      // A missing flag means a fresh install. Existing installs that already
      // wrote the flag keep their previous onboarding decision.
      onboardingSeen = prefs.getBool('onboardingSeen') ?? false;
      tutorialDoNotShow = prefs.getBool('tutorialDoNotShow') ?? false;
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
      parentPinHash = _readString('parentPinHash', '', maxLength: 512);
      treasureOpened = prefs.getBool('tr') ?? false;
      goldenChestOpened = prefs.getBool('gc') ?? false;
      soundEnabled = prefs.getBool('sn') ?? true;
      musicVolume = _normalizeMusicVolume(prefs.getDouble('mv'));
      textScale = (prefs.getDouble('tsc') ?? 1.0).clamp(0.85, 1.4).toDouble();
      activeTheme = prefs.getString('activeTheme') ?? 'island_map';
      isLeftHanded = prefs.getBool('lh') ?? false;
      classroomLightMode = prefs.getBool('clm') ?? true;
      masteredAlphabetKeys = _readList('alk');
      alphabetPassCounts = _readColonIntMap('alc');
      alphabetLastPassDay = _readColonStringMap('ald');
      todayPathDone = _readList('tpd');
      todayPathDay = prefs.getString('tpk') ?? '';
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
      islandDecorations = _readIslandDecorations();
      completedStories = _readList('stories');
      storyFavorites = _readList('sfav');
      lastStoryPageStoryId = _prefs?.getString('lastStoryId') ?? '';
      lastStoryPageIndex = _prefs?.getInt('lastStoryPage') ?? 0;
      cartoonFavorites = _readList('cfav');
      watchedCartoons = _readList('cw');
      cartoonWatchSeconds = _readInt('cws', 0);
      appRated = prefs.getBool('appRated') ?? false;
      lullabyFavorites = _readList('lfav');
      listenedLullabies = _readList('ll_done');
      // ✅ فیکس: بارگذاری playedGames برای achievement
      playedGames = _readList('pg');
      _playedGamesSet
        ..clear()
        ..addAll(playedGames);

      for (final key in skills.keys.toList()) {
        skills[key] = _readInt('sk_$key', 0, max: _maxStoredCounter);
      }

      await _applySecurePinOverride();
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
    HivePlayerStore.useMemoryStorage();
    _prefs = null;
    _missionDay = '';
    _isLoaded = true;
    _persistenceAvailable = false;
    _loadFuture = Future<void>.value();
    _notify();
  }

  /// 🔐 کپی Keystore پین والدین مرجع است: اگر کسی فایل Hive یا
  /// SharedPreferences را دستکاری کرده باشد، مقدار امن از Keystore
  /// بازیابی می‌شود تا پنل والدین غیرقابل دور زدن بماند.
  static Future<void> _applySecurePinOverride() async {
    try {
      final secure = await SecureStore.read('parent_pin_hash');
      if (secure != null && secure.isNotEmpty) {
        parentPinHash = secure;
        _pinHashSecureCache = secure;
      }
    } catch (_) {
      // Secure storage unavailable → keep the local mirror as-is.
    }
  }

  static double _normalizeMusicVolume(Object? value) {
    if (value is! num || !value.isFinite) return defaultMusicVolume;
    return value.toDouble().clamp(0.0, 1.0).toDouble();
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

  static Map<String, String> _readIslandDecorations() {
    final raw = _readList('idc');
    final map = <String, String>{};
    for (final entry in raw) {
      final parts = entry.split(':');
      if (parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }

  static Map<String, int> _readColonIntMap(String key) =>
      _parseColonIntList(_readList(key));

  static Map<String, String> _readColonStringMap(String key) =>
      _parseColonStringList(_readList(key));

  static Map<String, int> _parseColonIntList(List<String> raw) {
    final map = <String, int>{};
    for (final entry in raw) {
      final split = entry.lastIndexOf(':');
      if (split <= 0) continue;
      final count = int.tryParse(entry.substring(split + 1));
      if (count == null) continue;
      map[entry.substring(0, split)] = count.clamp(0, 99);
    }
    return map;
  }

  static Map<String, String> _parseColonStringList(List<String> raw) {
    final map = <String, String>{};
    for (final entry in raw) {
      final split = entry.lastIndexOf(':');
      if (split <= 0) continue;
      final value = entry.substring(split + 1);
      if (value.isEmpty) continue;
      map[entry.substring(0, split)] = value;
    }
    return map;
  }

  static List<String> _encodeColonIntMap(Map<String, int> map) =>
      map.entries.map((e) => '${e.key}:${e.value}').toList();

  static List<String> _encodeColonStringMap(Map<String, String> map) =>
      map.entries.map((e) => '${e.key}:${e.value}').toList();

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
    if (avatar.length > 128) avatar = avatar.substring(0, 128);
    childName = asString('childName', '');
    if (childName.length > 24) childName = childName.substring(0, 24);
    childAge = asInt('childAge', 5).clamp(3, 12);
    onboardingSeen = asBool('onboardingSeen', true);
    tutorialDoNotShow = asBool('tutorialDoNotShow', false);
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
    parentPinHash = asString('parentPinHash', '');
    if (parentPinHash.length > 512) parentPinHash = parentPinHash.substring(0, 512);
    treasureOpened = asBool('tr', false);
    goldenChestOpened = asBool('gc', false);
    soundEnabled = asBool('sn', true);
    musicVolume = _normalizeMusicVolume(d['mv']);
    isLeftHanded = asBool('lh', false);
    classroomLightMode = asBool('clm', true);
    todayPathDone = asList('tpd');
    todayPathDay = asString('tpk', '');
    masteredAlphabetKeys = asList('alk');
    alphabetPassCounts = asSkillMap('alc');
    if (alphabetPassCounts.isEmpty) {
      alphabetPassCounts = _parseColonIntList(asList('alc'));
    }
    alphabetLastPassDay = <String, String>{};
    final ald = d['ald'];
    if (ald is Map) {
      ald.forEach((k, v) {
        if (k is String && v is String && k.isNotEmpty && v.isNotEmpty) {
          alphabetLastPassDay[k] = v;
        }
      });
    } else {
      alphabetLastPassDay = _parseColonStringList(asList('ald'));
    }
    final tsc = d['tsc'];
    if (tsc is num) textScale = tsc.toDouble().clamp(0.85, 1.4).toDouble();
    activeTheme = asString('activeTheme', 'island_map');
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
    completedStories = asList('stories');
    storyFavorites = asList('sfav');
    lastStoryPageStoryId = asString('lastStoryId', '');
    final lsp = d['lastStoryPage'];
    lastStoryPageIndex = (lsp is num ? lsp.toInt() : 0).clamp(0, 100);
    cartoonFavorites = asList('cfav');
    watchedCartoons = asList('cw');
    cartoonWatchSeconds = asInt('cws', 0).clamp(0, _maxStoredCounter);
    appRated = asBool('appRated', false);
    lullabyFavorites = asList('lfav');
    listenedLullabies = asList('ll_done');
    islandDecorations = <String, String>{};
    final idc = d['idc'];
    if (idc is Map) {
      idc.forEach((k, v) {
        if (k is String && v is String && k.isNotEmpty && v.isNotEmpty) {
          islandDecorations[k] = v;
        }
      });
    }
    playedGames = asList('pg');
    _playedGamesSet
      ..clear()
      ..addAll(playedGames);
    final sk = asSkillMap('skills');
    if (sk.isNotEmpty) {
      // Merge old snapshots into the current skill schema so new PR80
      // achievements (stories/lullaby) are not lost during migration.
      skills = <String, int>{...skills, ...sk};
    }
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
        'tutorialDoNotShow': tutorialDoNotShow,
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
        'parentPinHash': parentPinHash,
        'tr': treasureOpened,
        'gc': goldenChestOpened,
        'sn': soundEnabled,
        'mv': musicVolume,
        'tsc': textScale,
        'activeTheme': activeTheme,
        'lh': isLeftHanded,
        'clm': classroomLightMode,
        'tpd': todayPathDone,
        'tpk': todayPathDay,
        'alk': masteredAlphabetKeys,
        'alc': alphabetPassCounts,
        'ald': alphabetLastPassDay,
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
        'stories': completedStories,
        'sfav': storyFavorites,
        'lastStoryId': lastStoryPageStoryId,
        'lastStoryPage': lastStoryPageIndex,
        'cfav': cartoonFavorites,
        'cw': watchedCartoons,
        'cws': cartoonWatchSeconds,
        'appRated': appRated,
        'lfav': lullabyFavorites,
        'll_done': listenedLullabies,
        'idc': islandDecorations,
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
      todayPathDone = <String>[];
      todayPathDay = today;
      _missionDay = today;
      changed = true;
    } else {
      _missionDay = today;
      _recalculateDailyMissions();
    }
    if (todayPathDay != today) {
      todayPathDone = <String>[];
      todayPathDay = today;
      changed = true;
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
    if (!_isLoaded || !_persistenceAvailable) {
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
    // Hive snapshot mode is the normal path after the first migrated load.
    // Do not silently drop writes just because SharedPreferences is absent.
    if (prefs == null) {
      await HivePlayerStore.writeSnapshot(_buildSnapshot());
      return;
    }

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
    await prefs.setBool('tutorialDoNotShow', tutorialDoNotShow);
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
    await prefs.setString('parentPinHash', parentPinHash);
    await prefs.setBool('tr', treasureOpened);
    await prefs.setBool('gc', goldenChestOpened);
    await prefs.setBool('sn', soundEnabled);
    await prefs.setDouble('mv', musicVolume);
    await prefs.setDouble('tsc', textScale);
    await prefs.setString('activeTheme', activeTheme);
    await prefs.setBool('lh', isLeftHanded);
    await prefs.setBool('clm', classroomLightMode);
    await prefs.setStringList('tpd', List<String>.from(todayPathDone));
    await prefs.setString('tpk', todayPathDay);
    await prefs.setStringList('alk', List<String>.from(masteredAlphabetKeys));
    await prefs.setStringList('alc', _encodeColonIntMap(alphabetPassCounts));
    await prefs.setStringList('ald', _encodeColonStringMap(alphabetLastPassDay));
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
    await prefs.setStringList('stories', List<String>.from(completedStories));
    await prefs.setStringList('sfav', List<String>.from(storyFavorites));
    await prefs.setString('lastStoryId', lastStoryPageStoryId);
    await prefs.setInt('lastStoryPage', lastStoryPageIndex);
    await prefs.setStringList('cfav', List<String>.from(cartoonFavorites));
    await prefs.setStringList('cw', List<String>.from(watchedCartoons));
    await prefs.setInt('cws', cartoonWatchSeconds);
    await prefs.setBool('appRated', appRated);
    await prefs.setStringList('lfav', List<String>.from(lullabyFavorites));
    await prefs.setStringList(
      'll_done',
      List<String>.from(listenedLullabies),
    );
    await prefs.setStringList(
      'idc',
      islandDecorations.entries
          .map((e) => '${e.key}:${e.value}')
          .toList(),
    );
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

  /// Spends currency atomically. Negative calls to [addCoins] used to be
  /// silently ignored, which made the PR80 ice-heart purchase appear to work
  /// while never charging the child.
  static bool spendCoins(int amount) {
    if (!_isLoaded || amount <= 0 || coins < amount) return false;
    coins -= amount;
    _notify();
    unawaited(save());
    return true;
  }

  /// Uses the ice heart once to restart a broken streak without allowing a
  /// negative balance or a fake purchase.
  static bool activateIceHeart({int cost = 50}) {
    if (!_isLoaded || cost <= 0 || !spendCoins(cost)) return false;
    streak = max(1, streak);
    lastLogin = _dateKey();
    _notify();
    unawaited(save());
    return true;
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
    'math': 3, // فاز ۵۲: مأموریت ریاضی
    'memory': 2, // دو دور کوتاه برای تکمیل مأموریت حافظه
  };

  static void progressMission(String id, {int amount = 1}) {
    if (!_isLoaded || amount <= 0 || !missionTargets.containsKey(id)) return;
    _progressMissionInternal(id, amount: amount);
    _recalculateDailyMissions();
    if (id == 'drawing') markTodayStation('drawing');
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

  /// صندوق مأموریت روزانه فقط یک بار در هر روز قابل دریافت است.
  static bool get canClaimDailyMissionChest =>
      _isLoaded && dailyMissions >= 3 && lastSurpriseClaimDate != _dateKey();

  static bool claimDailyMissionChest({int reward = 20}) {
    if (!_isLoaded || reward <= 0) return false;
    if (_missionDay.isNotEmpty) _refreshDateBoundaries();
    if (!canClaimDailyMissionChest) return false;
    lastSurpriseClaimDate = _dateKey();
    coins = min(_maxStoredCounter, coins + reward);
    _autoAchieve();
    _notify();
    unawaited(save());
    return true;
  }

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

  // ==================== ISLAND BUILDER (فاز ۴۰) ====================

  /// قرار دادن تزئین روی یک خانه از جزیره.
  /// [cost] قیمت واقعی آیتم است (دور ۸: قبلاً همیشه ۵ کم می‌شد).
  static bool placeDecoration(String slot, String itemId, {int cost = 5}) {
    if (!_isLoaded || slot.isEmpty || itemId.isEmpty || cost < 0) return false;
    if (islandDecorations.containsKey(slot)) return false;
    if (coins < cost) return false;
    coins -= cost;
    level = min(_maxStoredCounter, (coins ~/ 100) + 1);
    islandDecorations[slot] = itemId;
    _notify();
    unawaited(save());
    return true;
  }

  static void removeDecoration(String slot) {
    if (!_isLoaded) return;
    islandDecorations.remove(slot);
    _notify();
    unawaited(save());
  }

  // ==================== STORIES (فاز ۲۹) ====================
  static bool hasCompletedStory(String id) => completedStories.contains(id);

  /// ثبت داستان تکمیل‌شده؛ خروجی false یعنی قبلاً خوانده شده
  /// (ضد farming — پاداش فقط یک‌بار).
  static bool markStoryCompleted(String id) {
    if (!_isLoaded || id.isEmpty || completedStories.contains(id)) return false;
    completedStories.add(id);
    // Keep the dedicated story skill in sync for the PR80 story achievements.
    if (skills.containsKey('stories')) {
      skills['stories'] = min(_maxStoredCounter, (skills['stories'] ?? 0) + 1);
    }
    markTodayStation('story');
    _notify();
    unawaited(save());
    return true;
  }

  static bool isStoryFavorite(String id) => storyFavorites.contains(id);

  static void saveStoryProgress(String storyId, int pageIndex) {
    if (!_isLoaded) return;
    lastStoryPageStoryId = storyId;
    lastStoryPageIndex = pageIndex;
    unawaited(save());
  }

  static String get lastStoryId => lastStoryPageStoryId;
  static int get lastStoryPage => lastStoryPageIndex;

  static void toggleStoryFavorite(String id) {
    if (!_isLoaded || id.isEmpty) return;
    if (storyFavorites.contains(id)) {
      storyFavorites.remove(id);
    } else {
      storyFavorites.add(id);
    }
    _notify();
    unawaited(save());
  }

  // ==================== CARTOONS (کارتون‌ها) ====================
  static bool isCartoonFavorite(String id) => cartoonFavorites.contains(id);

  static void toggleCartoonFavorite(String id) {
    if (!_isLoaded || id.isEmpty) return;
    if (cartoonFavorites.contains(id)) {
      cartoonFavorites.remove(id);
    } else {
      cartoonFavorites.add(id);
    }
    _notify();
    unawaited(save());
  }

  static void recordCartoonWatched(String id, {int durationSeconds = 60}) {
    if (!_isLoaded || id.isEmpty) return;
    var changed = false;
    if (!watchedCartoons.contains(id)) {
      watchedCartoons.add(id);
      coins = min(_maxStoredCounter, coins + 5);
      changed = true;
    }
    cartoonWatchSeconds = min(_maxStoredCounter, cartoonWatchSeconds + durationSeconds);
    _autoAchieve();
    _notify();
    unawaited(save());
  }

  // ==================== LULLABIES (لالایی‌ها) ====================
  static bool hasListenedLullaby(String id) => listenedLullabies.contains(id);

  static bool isLullabyFavorite(String id) => lullabyFavorites.contains(id);

  static void toggleLullabyFavorite(String id) {
    if (!_isLoaded || id.isEmpty) return;
    if (lullabyFavorites.contains(id)) {
      lullabyFavorites.remove(id);
    } else {
      lullabyFavorites.add(id);
    }
    _notify();
    unawaited(save());
  }

  /// ثبت لالایی شنیده‌شده؛ خروجی false یعنی قبلاً شنیده شده
  /// (مهارت `lullaby` فقط یک‌بار برای هر لالایی بالا می‌رود).
  static bool markLullabyListened(String id) {
    if (!_isLoaded || id.isEmpty || listenedLullabies.contains(id)) {
      return false;
    }
    listenedLullabies.add(id);
    if (skills.containsKey('lullaby')) {
      skills['lullaby'] = min(_maxStoredCounter, (skills['lullaby'] ?? 0) + 1);
    }
    _notify();
    unawaited(save());
    return true;
  }

  static bool claimRatingReward() {
    if (!_isLoaded || appRated) return false;
    appRated = true;
    coins = min(_maxStoredCounter, coins + 50);
    stars = min(_maxStoredCounter, stars + 5);
    _autoAchieve();
    _notify();
    unawaited(save());
    return true;
  }

  /// ✅ فیکس عمیق فاز ۳۰: ثبت بازی‌های انجام شده برای achievement
  static void recordGamePlayed(String gameId) {
    if (!_isLoaded || gameId.isEmpty) return;
    if (_playedGamesSet.contains(gameId)) return;
    _playedGamesSet.add(gameId);
    playedGames = _playedGamesSet.toList();
    _notify();
    unawaited(save());
  }

  // ── پیشنهاد پریمیوم ۴۶: ضد اعتیاد هوشمند ──────────────────
  // اگر کودک ۵ بار پشت سر هم یک بازی را باز کند، فندقی پیشنهاد
  // «بریم یه دنیای دیگه؟» می‌دهد تا تنوع ایجاد شود.
  static String? _lastGameOpened;
  static int _sameGameStreak = 0;

  /// هر بار که بازی‌ای باز می‌شود صدا زده شود. اگر ۵ بار پشت سر هم
  /// همان بازی باشد، نام همان بازی برمی‌گردد تا پیام تنوع نشان داده شود.
  static String? recordGameOpened(String gameName) {
    final name = gameName.trim();
    if (name.isEmpty) return null;
    if (_lastGameOpened == name) {
      _sameGameStreak++;
    } else {
      _lastGameOpened = name;
      _sameGameStreak = 1;
    }
    if (_sameGameStreak >= 5) {
      // رسیدن به آستانه — شمارنده ریست می‌شود تا پیام تکراری نشود
      _sameGameStreak = 0;
      return name;
    }
    return null;
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
    if (avatar.length > 128) avatar = avatar.substring(0, 128);
    onboardingSeen = true;
    _notify();
    unawaited(save());
  }

  /// Completes the first guide without asking the child any assessment
  /// questions. [onboardingSeen] also ensures the optional profile offer is
  /// made only once, while the tutorial can still replay on future launches.
  static Future<void> completeInitialGuide({
    required bool doNotShowTutorialAgain,
  }) async {
    onboardingSeen = true;
    tutorialDoNotShow = doNotShowTutorialAgain;
    _notify();
    await save();
  }

  static void updateProfile({
    required String name,
    String? avatarIcon,
    int? age,
  }) {
    final trimmed = name.trim();
    childName = trimmed.substring(0, trimmed.length.clamp(0, 24).toInt());
    if (avatarIcon != null && avatarIcon.isNotEmpty) avatar = avatarIcon;
    if (age != null) childAge = age.clamp(3, 12).toInt();
    _notify();
    unawaited(save());
  }

  static void setAvatar(String newAvatar) {
    if (newAvatar.isEmpty) return;
    avatar = newAvatar.length > 128 ? newAvatar.substring(0, 128) : newAvatar;
    _notify();
    unawaited(save());
  }

  static void setSoundEnabled(bool value) {
    soundEnabled = value;
    _notify();
    unawaited(save());
  }

  /// تنظیم و ذخیرهٔ بلندی موسیقی، مستقل از افکت‌ها و صدای گوینده.
  static void setMusicVolume(double value) {
    musicVolume = _normalizeMusicVolume(value);
    _notify();
    unawaited(save());
  }

  /// فاز ۷: تنظیم مقیاس فونت توسط والدین.
  static void setTextScale(double value) {
    textScale = value.clamp(0.85, 1.4).toDouble();
    _notify();
    unawaited(save());
  }

  /// تنظیم و ذخیره‌سازی تم پویای برنامه.
  static void setActiveTheme(String themeId) {
    if (themeId.isEmpty) return;
    activeTheme = themeId;
    _notify();
    unawaited(save());
  }

  /// فاز ۱۶: تنظیم ترجیح دست کودک.
  static void setLeftHanded(bool value) {
    isLeftHanded = value;
    _notify();
    unawaited(save());
  }

  static void setClassroomLightMode(bool value) {
    classroomLightMode = value;
    _notify();
    unawaited(save());
  }

  static bool isAlphabetMastered(String key) =>
      key.isNotEmpty && masteredAlphabetKeys.contains(key);

  /// مهر معلم روی یک نشانه. خروجی false یعنی قبلاً ثبت شده.
  static bool markAlphabetMastered(String key) {
    if (!_isLoaded || key.isEmpty || masteredAlphabetKeys.contains(key)) {
      return false;
    }
    masteredAlphabetKeys = [...masteredAlphabetKeys, key];
    _notify();
    unawaited(save());
    return true;
  }

  static int alphabetPassCount(String key) => alphabetPassCounts[key] ?? 0;

  static bool isAlphabetFluent(String key) =>
      alphabetPassCount(key) >= AlphabetReview.fluentPassCount;

  /// یک قبولی تازه: حرف بعدی باز می‌شود و شمارندهٔ تسلط بالا می‌رود.
  static int recordAlphabetPass(String key, {String? today}) {
    if (!_isLoaded || key.isEmpty) return 0;
    final next = min(20, alphabetPassCount(key) + 1);
    alphabetPassCounts = {...alphabetPassCounts, key: next};
    alphabetLastPassDay = {...alphabetLastPassDay, key: today ?? _dateKey()};
    markAlphabetMastered(key);
    markTodayStation('literacy', today: today);
    _notify();
    unawaited(save());
    return next;
  }

  static void markTodayStation(String station, {String? today}) {
    if (!_isLoaded || station.isEmpty) return;
    final day = today ?? _dateKey();
    if (todayPathDay != day) {
      todayPathDay = day;
      todayPathDone = <String>[];
    }
    if (todayPathDone.contains(station)) return;
    todayPathDone = [...todayPathDone, station];
    _notify();
    unawaited(save());
  }

  static bool isTodayStationDone(String station, {String? today}) {
    final day = today ?? _dateKey();
    if (todayPathDay != day) return false;
    return todayPathDone.contains(station);
  }

  static bool isAlphabetDueForReview(String key, {String? today}) {
    return AlphabetReview.isDue(
      passCount: alphabetPassCount(key),
      lastDay: alphabetLastPassDay[key] ?? '',
      today: today ?? _dateKey(),
    );
  }

  static List<String> dueAlphabetReviewKeys({String? today}) {
    final day = today ?? _dateKey();
    return alphabetPassCounts.keys
        .where((key) => isAlphabetDueForReview(key, today: day))
        .toList();
  }

  static void setTimeLimitMinutes(int value) {
    timeLimitMinutes = value.clamp(15, 24 * 60).toInt();
    _notify();
    unawaited(save());
  }

  // ==================== SIBLING / GROWTH EXPORT ====================
  static const List<String> _childProgressKeys = <String>[
    'stars', 'c', 'l', 's', 'tc', 'tw', 'av', 'childName',
    'childAge', 'dm', 'missionDay', 'mp', 'ss', 'wpm', 'tps', 'ach', 'st',
    'ownedItems', 'hs', 'mrhs', 'qhs', 'lld', 'lscd', 'aiBuddy', 'currentStage',
    'currentIsland', 'cs', 'pbt', 'op', 'stories', 'sfav', 'lastStoryId',
    'lastStoryPage', 'cfav', 'cw', 'cws', 'appRated', 'idc', 'pg', 'skills',
    'lfav', 'll_done', 'alk', 'alc', 'ald', 'clm', 'tpd', 'tpk',
  ];

  /// پیشرفت کودک بدون تنظیمات والد (پین، محدودیت، تم).
  static Map<String, Object?> exportChildProgress() {
    final all = _buildSnapshot();
    final out = <String, Object?>{};
    for (final key in _childProgressKeys) {
      if (all.containsKey(key)) out[key] = all[key];
    }
    return out;
  }

  static void importChildProgress(Map<String, Object?> child) {
    final merged = _buildSnapshot()..addAll(child);
    _applySnapshot(merged);
    _notify();
    unawaited(save());
  }

  /// پروفایل خواهر/برادر تازه: پیشرفت صفر، تنظیمات والد سر جایش.
  static void resetChildProgressKeepingParent() {
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
    avatar = '🧒';
    childName = '';
    childAge = 5;
    achievements = <String>[];
    stickers = <String>[];
    ownedItems = <String>[];
    missionProgress = <String, int>{
      'questions': 0,
      'alphabet': 0,
      'drawing': 0,
      'colors': 0,
      'math': 0,
      'memory': 0,
    };
    for (final key in skills.keys.toList()) {
      skills[key] = 0;
    }
    currentStage = 1;
    currentIsland = 0;
    completedStages = <String, bool>{};
    prizeBoxTokens = 0;
    openedPrizes = <String>[];
    islandDecorations = <String, String>{};
    completedStories = <String>[];
    storyFavorites = <String>[];
    lastStoryPageStoryId = '';
    lastStoryPageIndex = 0;
    cartoonFavorites = <String>[];
    watchedCartoons = <String>[];
    cartoonWatchSeconds = 0;
    lullabyFavorites = <String>[];
    listenedLullabies = <String>[];
    playedGames = <String>[];
    _playedGamesSet.clear();
    masteredAlphabetKeys = <String>[];
    alphabetPassCounts = <String, int>{};
    alphabetLastPassDay = <String, String>{};
    todayPathDone = <String>[];
    todayPathDay = '';
    unawaited(DrawingAlbum.clearAll());
    _notify();
    unawaited(save());
  }

  // ==================== PARENT CONTROL ====================
  // 🔐 Hardened PIN storage (v6.3):
  //  - hash = PBKDF2-HMAC-SHA256 (150k iterations) + salt تصادفی ۱۶ بایتی،
  //    به‌جای SHA-256 خام قدیمی (که با ۱۰٬۰۰۰ ترکیب ممکن، فوراً
  //    brute-force می‌شد).
  //  - کپی معتبر در SecureStore (Android Keystore) نگه داشته می‌شود؛
  //    دستکاری فایل Hive/SharedPreferences دیگر نمی‌تواند پین را پاک کند.
  static const String _parentPinDomain = 'fandoghi-parent-pin-v1';
  static const int _pinKdfIterations = 150000;
  static final Random _secureRandom = Random.secure();

  /// نسخهٔ هش Keystore (SecureStore) — در [load] و [resetForTesting] هم صفر می‌شود.
  static String? _pinHashSecureCache;

  static bool _isValidPin(String pin) => RegExp(r'^\d{4}$').hasMatch(pin);

  /// هش مقاوم پین: `pbkdf2:<iterations>:<saltB64>:<hashB64>`.
  static Future<String> hashParentPin(String pin) async {
    final salt = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pinKdfIterations,
      bits: 256,
    );
    final key = await pbkdf2.deriveKeyFromPassword(
      password: '$_parentPinDomain:$pin',
      nonce: salt,
    );
    final bytes = await key.extractBytes();
    return 'pbkdf2:$_pinKdfIterations:${base64Encode(salt)}:${base64Encode(bytes)}';
  }

  /// فرمت قدیمی (قبل از ۶.۳) — فقط برای تأیید هش‌های ساخته‌شده توسط
  /// نسخه‌های قدیمی؛ بعد از اولین تأیید موفق، خودکار به PBKDF2 ارتقا می‌یابد.
  static String _legacyParentPinHash(String pin) {
    final digest = const DartSha256().hashSync(
      utf8.encode('$_parentPinDomain:$pin'),
    );
    return base64Encode(digest.bytes);
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  /// کپی Keystore مرجع است؛ در نبود آن (مهاجرت از نسخهٔ قدیمی) به آینهٔ
  /// prefs/Hive برمی‌گردیم.
  static Future<String> _authoritativeParentPinHash() async {
    if (_pinHashSecureCache != null) return _pinHashSecureCache!;
    final secure = await SecureStore.read('parent_pin_hash');
    if (secure != null && secure.isNotEmpty) {
      _pinHashSecureCache = secure;
      return secure;
    }
    return parentPinHash;
  }

  static bool hasParentPin() => parentPinHash.isNotEmpty;

  static Future<bool> verifyParentPin(String pin) async {
    if (parentPinHash.isEmpty || !_isValidPin(pin)) return false;
    final stored = await _authoritativeParentPinHash();
    if (stored.isEmpty) return false;

    if (stored.startsWith('pbkdf2:')) {
      final parts = stored.split(':');
      if (parts.length != 4) return false;
      final iterations = int.tryParse(parts[1]) ?? 0;
      // پارامتر جعلی/ضعیف یا بیش‌ازحد بزرگ (DoS با هش سنگین) را رد کن.
      if (iterations < 10000 || iterations > 1000000) return false;
      final List<int> saltBytes;
      final List<int> expectedBytes;
      try {
        saltBytes = base64Decode(parts[2]);
        expectedBytes = base64Decode(parts[3]);
      } catch (_) {
        return false;
      }
      if (expectedBytes.length != 32) return false;
      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: expectedBytes.length * 8,
      );
      final key = await pbkdf2.deriveKeyFromPassword(
        password: '$_parentPinDomain:$pin',
        nonce: saltBytes,
      );
      final actual = await key.extractBytes();
      return _constantTimeEquals(actual, expectedBytes);
    }

    // فرمت قدیمی SHA-256: بپذیر و همان‌جا به فرمت سخت‌شده ارتقا بده.
    final ok = _constantTimeEquals(
      _legacyParentPinHash(pin).codeUnits,
      stored.codeUnits,
    );
    if (ok) await setParentPin(pin);
    return ok;
  }

  static Future<bool> setParentPin(String pin) async {
    if (!_isValidPin(pin)) return false;
    final hash = await hashParentPin(pin);
    parentPinHash = hash;
    await SecureStore.write('parent_pin_hash', hash);
    _pinHashSecureCache = hash;
    _notify();
    unawaited(save());
    return true;
  }

  static Future<void> removeParentPin() async {
    parentPinHash = '';
    await SecureStore.delete('parent_pin_hash');
    _pinHashSecureCache = null;
    _notify();
    unawaited(save());
  }

  /// بعد از restore بکاپ، وضعیت نهایی پین را در SecureStore همگام می‌کند
  /// تا کپی Keystore با آینهٔ prefs/Hive یکی بماند.
  static Future<void> persistPinHashToSecureStore() async {
    await SecureStore.write('parent_pin_hash', parentPinHash);
    _pinHashSecureCache = parentPinHash;
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
    if (watchedCartoons.isNotEmpty) candidates.add('cartoon_watcher');
    if (watchedCartoons.length >= 5) candidates.add('cartoon_fan');
    for (final id in candidates) {
      if (!achievements.contains(id)) achievements.add(id);
    }
  }

  /// Resets only in-memory state. It is useful for deterministic widget tests
  /// and is never called by the production UI.
  @visibleForTesting
  static void resetForTesting() {
    HivePlayerStore.useMemoryStorage(clear: true);
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
    tutorialDoNotShow = false;
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
      'math': 0,
      'memory': 0,
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
      'stories': 0,
      'lullaby': 0,
    };
    timeLimitMinutes = 60;
    parentPinHash = '';
    _pinHashSecureCache = null;
    treasureOpened = false;
    goldenChestOpened = false;
    soundEnabled = true;
    musicVolume = defaultMusicVolume;
    textScale = 1.0;
    isLeftHanded = false;
    luckyWheelSpunToday = false;
    aiBuddyUnlocked = false;
    currentStage = 1;
    currentIsland = 0;
    completedStages = <String, bool>{};
    prizeBoxTokens = 0;
    openedPrizes = <String>[];
    islandDecorations = <String, String>{};
    completedStories = <String>[];
    storyFavorites = <String>[];
    cartoonFavorites = <String>[];
    watchedCartoons = <String>[];
    cartoonWatchSeconds = 0;
    appRated = false;
    lullabyFavorites = <String>[];
    listenedLullabies = <String>[];
    playedGames = <String>[];
    _playedGamesSet.clear();
    masteredAlphabetKeys = <String>[];
    alphabetPassCounts = <String, int>{};
    alphabetLastPassDay = <String, String>{};
    todayPathDone = <String>[];
    todayPathDay = '';
    parentUnlockedThisSession = false;
    classroomLightMode = true;
    DrawingAlbum.useMemoryForTesting();
    _notify();
  }
}
