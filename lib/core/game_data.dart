import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class GameData {
  static late SharedPreferences _p;

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

  // Player identity
  static String lastLogin = '';
  static String avatar = '😊';
  static String childName = '';
  static int childAge = 5;
  static bool onboardingSeen = false;

  // Features state
  static String lastWeekReset = '';
  static String lastLuckyDate = '';
  static String lastSurpriseClaimDate = '';
  static List<String> achievements = [];
  static List<String> stickers = [];
  static Map<String, int> missionProgress = {
    'questions': 0, 'alphabet': 0, 'drawing': 0, 'colors': 0
  };
  static Map<String, int> skills = {
    'math': 0, 'alphabet': 0, 'memory': 0, 'colors': 0, 'shapes': 0,
    'animals': 0, 'counting': 0, 'pattern': 0, 'fruits': 0, 'concepts': 0,
    'vocab': 0, 'body': 0, 'vehicles': 0, 'time': 0, 'weather': 0,
    'emotions': 0, 'jobs': 0
  };

  // Settings
  static int timeLimitMinutes = 60;
  static bool treasureOpened = false;
  static bool goldenChestOpened = false;
  static bool soundEnabled = true;
  static bool luckyWheelSpunToday = false;

  // Stage map progress
  static int currentStage = 1;
  static int currentIsland = 0;
  static Map<String, bool> completedStages = {};

  // Prize box
  static int prizeBoxTokens = 0;
  static List<String> openedPrizes = [];

  static Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    stars = _p.getInt('stars') ?? 0;
    coins = _p.getInt('c') ?? 0;
    level = _p.getInt('l') ?? 1;
    streak = _p.getInt('s') ?? 0;
    totalCorrect = _p.getInt('tc') ?? 0;
    totalWrong = _p.getInt('tw') ?? 0;
    lastLogin = _p.getString('ll') ?? '';
    avatar = _p.getString('av') ?? '😊';
    dailyMissions = _p.getInt('dm') ?? 0;

    for (final id in missionProgress.keys) {
      missionProgress[id] = _p.getInt('mp_$id') ?? 0;
    }
    dailyMissions = missionProgress.entries
        .where((e) => e.value >= (missionTargets[e.key] ?? 1))
        .length;

    sessionSeconds = _p.getInt('ss') ?? 0;
    achievements = _p.getStringList('ach') ?? [];
    stickers = _p.getStringList('st') ?? [];
    timeLimitMinutes = _p.getInt('tl') ?? 60;
    treasureOpened = _p.getBool('tr') ?? false;
    goldenChestOpened = _p.getBool('gc') ?? false;
    soundEnabled = _p.getBool('sn') ?? true;
    weeklyPlayMinutes = _p.getInt('wpm') ?? 0;
    todayPlaySeconds = _p.getInt('tps') ?? 0;
    lastWeekReset = _p.getString('lwr') ?? '';
    highScore = _p.getInt('hs') ?? 0;
    mathRaceHighScore = _p.getInt('mrhs') ?? 0;
    quizHighScore = _p.getInt('qhs') ?? 0;
    lastLuckyDate = _p.getString('lld') ?? '';
    lastSurpriseClaimDate = _p.getString('lscd') ?? '';
    onboardingSeen = _p.getBool('onboardingSeen') ?? false;
    childName = _p.getString('childName') ?? '';
    childAge = _p.getInt('childAge') ?? 5;

    currentStage = _p.getInt('currentStage') ?? 1;
    currentIsland = _p.getInt('currentIsland') ?? 0;
    completedStages = {};
    final csKeys = _p.getStringList('csKeys') ?? [];
    for (final k in csKeys) {
      completedStages[k] = _p.getBool('cs_$k') ?? false;
    }

    prizeBoxTokens = _p.getInt('pbt') ?? 0;
    openedPrizes = _p.getStringList('op') ?? [];

    luckyWheelSpunToday = lastLuckyDate == DateTime.now().toString().substring(0, 10);

    for (var k in skills.keys) {
      skills[k] = _p.getInt('sk_$k') ?? 0;
    }

    _checkStreak();
    _checkWeekReset();
  }

  static Future<void> save() async {
    await _p.setInt('stars', stars);
    await _p.setInt('c', coins);
    await _p.setInt('l', level);
    await _p.setInt('s', streak);
    await _p.setInt('tc', totalCorrect);
    await _p.setInt('tw', totalWrong);
    await _p.setString('ll', lastLogin);
    await _p.setString('av', avatar);
    await _p.setInt('dm', dailyMissions);
    for (final entry in missionProgress.entries) {
      await _p.setInt('mp_${entry.key}', entry.value);
    }
    await _p.setInt('ss', sessionSeconds);
    await _p.setStringList('ach', achievements);
    await _p.setStringList('st', stickers);
    await _p.setInt('tl', timeLimitMinutes);
    await _p.setBool('tr', treasureOpened);
    await _p.setBool('gc', goldenChestOpened);
    await _p.setBool('sn', soundEnabled);
    await _p.setInt('wpm', weeklyPlayMinutes);
    await _p.setInt('tps', todayPlaySeconds);
    await _p.setString('lwr', lastWeekReset);
    await _p.setInt('hs', highScore);
    await _p.setInt('mrhs', mathRaceHighScore);
    await _p.setInt('qhs', quizHighScore);
    await _p.setString('lld', lastLuckyDate);
    await _p.setString('lscd', lastSurpriseClaimDate);
    await _p.setBool('onboardingSeen', onboardingSeen);
    await _p.setString('childName', childName);
    await _p.setInt('childAge', childAge);
    await _p.setInt('currentStage', currentStage);
    await _p.setInt('currentIsland', currentIsland);
    await _p.setStringList('csKeys', completedStages.keys.toList());
    for (final e in completedStages.entries) {
      await _p.setBool('cs_${e.key}', e.value);
    }
    await _p.setInt('pbt', prizeBoxTokens);
    await _p.setStringList('op', openedPrizes);
    for (var k in skills.keys) await _p.setInt('sk_$k', skills[k] ?? 0);
  }

  static void _checkStreak() {
    String today = DateTime.now().toString().substring(0, 10);
    String yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toString()
        .substring(0, 10);
    if (lastLogin == yesterday) {
      streak++;
    } else if (lastLogin != today) {
      streak = 1;
    }
    lastLogin = today;
    String savedDay = _p.getString('missionDay') ?? '';
    if (savedDay != today) {
      dailyMissions = 0;
      for (final id in missionProgress.keys) {
        missionProgress[id] = 0;
      }
      treasureOpened = false;
      todayPlaySeconds = 0;
      openedPrizes.removeWhere((id) => id.startsWith('daily_'));
      _p.setString('missionDay', today);
    }
    save();
  }

  static void _checkWeekReset() {
    int weekOfYear =
        ((DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays) /
                7)
            .ceil();
    String currentWeek = "${DateTime.now().year}-W$weekOfYear";
    if (lastWeekReset != currentWeek) {
      weeklyPlayMinutes = 0;
      goldenChestOpened = false;
      openedPrizes.removeWhere((id) => id.startsWith('weekly_'));
      lastWeekReset = currentWeek;
      save();
    }
  }

  static void addStars(int amount) {
    stars += amount;
    save();
  }

  static void addCoins(int a) {
    coins += a;
    level = (coins ~/ 100) + 1;
    _autoAchieve();
    save();
  }

  static void recordCorrect() {
    totalCorrect++;
    save();
  }

  static void recordWrong() {
    totalWrong++;
    save();
  }

  static double get successRate =>
      totalCorrect + totalWrong == 0 ? 0 : totalCorrect / (totalCorrect + totalWrong);

  static void addSkill(String s) {
    skills[s] = (skills[s] ?? 0) + 1;
    save();
  }

  static const Map<String, int> missionTargets = {
    'questions': 5,
    'alphabet': 1,
    'drawing': 1,
    'colors': 1,
  };

  static void progressMission(String id, {int amount = 1}) {
    final target = missionTargets[id];
    if (target == null) return;
    missionProgress[id] = min(target, (missionProgress[id] ?? 0) + amount);
    dailyMissions = missionProgress.entries
        .where((e) => e.value >= (missionTargets[e.key] ?? 1))
        .length;
    save();
  }

  static bool isMissionDone(String id) =>
      (missionProgress[id] ?? 0) >= (missionTargets[id] ?? 1);

  static int missionValue(String id) => missionProgress[id] ?? 0;

  static void unlockAch(String id) {
    if (!achievements.contains(id)) {
      achievements.add(id);
      save();
    }
  }

  static void buySticker(String id, int price) {
    if (coins >= price && !stickers.contains(id)) {
      coins -= price;
      stickers.add(id);
      save();
    }
  }

  static void addPlayTime() {
    todayPlaySeconds++;
    if (todayPlaySeconds % 60 == 0) {
      weeklyPlayMinutes++;
      save();
    }
  }

  static void updateHighScore(int score, String game) {
    if (game == 'math_race' && score > mathRaceHighScore) mathRaceHighScore = score;
    if (game == 'quiz' && score > quizHighScore) quizHighScore = score;
    if (score > highScore) highScore = score;
    save();
  }

  static void spinLucky() {
    luckyWheelSpunToday = true;
    lastLuckyDate = DateTime.now().toString().substring(0, 10);
    save();
  }

  static void completeStage(String stageId) {
    completedStages[stageId] = true;
    addStars(3);
    prizeBoxTokens++;
    save();
  }

  static bool isStageCompleted(String stageId) =>
      completedStages[stageId] ?? false;

  static int get completedStageCount =>
      completedStages.values.where((v) => v).length;

  static void _autoAchieve() {
    if (coins >= 500) unlockAch("coin_500");
    if (coins >= 1000) unlockAch("coin_1000");
    if (coins >= 5000) unlockAch("coin_5000");
    if (streak >= 3) unlockAch("streak_3");
    if (streak >= 7) unlockAch("streak_7");
    if (streak >= 30) unlockAch("streak_30");
    if (level >= 3) unlockAch("level_3");
    if (level >= 5) unlockAch("level_5");
    if (level >= 10) unlockAch("level_10");
    if (level >= 20) unlockAch("level_20");
    if (totalCorrect >= 50) unlockAch("correct_50");
    if (totalCorrect >= 100) unlockAch("correct_100");
    if (totalCorrect >= 500) unlockAch("correct_500");
    if (stickers.length >= 5) unlockAch("collector");
    if (stickers.length >= 10) unlockAch("mega_collector");
  }

  static String getLevelName() {
    if (level >= 20) return "استاد بزرگ 👑";
    if (level >= 15) return "افسانه 🌟";
    if (level >= 10) return "قهرمان آموزش 🏆";
    if (level >= 7) return "نابغه کوچولو 🧠";
    if (level >= 5) return "یادگیرنده ⭐";
    if (level >= 3) return "تلاشگر 💪";
    return "نوآموز 🌱";
  }

  static String getMascot() {
    if (level >= 15) return "🧙";
    if (level >= 10) return "🦸";
    if (level >= 7) return "🧑‍🎓";
    if (level >= 5) return "🧒";
    if (level >= 3) return "👦";
    return "👶";
  }

  static bool surprise() => streak > 0 && streak % 3 == 0;
  static bool canOpenTreasure() => dailyMissions >= 3 && !treasureOpened;
  static bool canOpenGoldenChest() =>
      weeklyPlayMinutes >= 30 && !goldenChestOpened;
}
