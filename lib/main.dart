import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameData.load();
  runApp(const KudakeIranApp());
}

// ==========================================================
// 🗄 GAME DATA MANAGER
// ==========================================================
class GameData {
  static late SharedPreferences _p;
  static int coins = 0, level = 1, streak = 0, totalCorrect = 0, totalWrong = 0, dailyMissions = 0, sessionSeconds = 0;
  static int weeklyPlayMinutes = 0, todayPlaySeconds = 0;
  static int highScore = 0, mathRaceHighScore = 0, quizHighScore = 0;
  static String lastLogin = '', avatar = '😊', lastWeekReset = '', lastLuckyDate = '', lastSurpriseClaimDate = '';
  static bool onboardingSeen = false;
  static String childName = '';
  static int childAge = 5;
  static List<String> achievements = [], stickers = [];
  // Separate progress for each daily challenge; a single activity must not
  // complete unrelated challenges.
  static Map<String, int> missionProgress = {'questions': 0, 'alphabet': 0, 'drawing': 0, 'colors': 0};
  static Map<String, int> skills = {
    'math': 0, 'alphabet': 0, 'memory': 0, 'colors': 0, 'shapes': 0, 'animals': 0,
    'counting': 0, 'pattern': 0, 'fruits': 0, 'concepts': 0, 'vocab': 0, 'body': 0,
    'vehicles': 0, 'time': 0, 'weather': 0, 'emotions': 0, 'jobs': 0
  };
  static int timeLimitMinutes = 60;
  static bool treasureOpened = false, goldenChestOpened = false, soundEnabled = true, luckyWheelSpunToday = false;

  static Future<void> load() async {
    _p = await SharedPreferences.getInstance();
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
    // Ignore the old shared counter: it could falsely mark all missions done.
    dailyMissions = missionProgress.entries
        .where((entry) => entry.value >= (missionTargets[entry.key] ?? 1))
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
    String today = DateTime.now().toString().substring(0, 10);
    luckyWheelSpunToday = lastLuckyDate == today;
    for (var k in skills.keys) skills[k] = _p.getInt('sk_$k') ?? 0;
    _checkStreak();
    _checkWeekReset();
  }

  static Future<void> save() async {
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
    for (var k in skills.keys) await _p.setInt('sk_$k', skills[k] ?? 0);
  }

  static void _checkStreak() {
    String today = DateTime.now().toString().substring(0, 10);
    String yesterday = DateTime.now().subtract(const Duration(days: 1)).toString().substring(0, 10);
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
      _p.setString('missionDay', today);
    }
    save();
  }

  static void _checkWeekReset() {
    int weekOfYear = ((DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays) / 7).ceil();
    String currentWeek = "${DateTime.now().year}-W$weekOfYear";
    if (lastWeekReset != currentWeek) {
      weeklyPlayMinutes = 0;
      goldenChestOpened = false;
      lastWeekReset = currentWeek;
      save();
    }
  }

  static void addCoins(int a) {
    coins += a;
    level = (coins ~/ 100) + 1;
    _autoAchieve();
    save();
  }

  static void recordCorrect() { totalCorrect++; save(); }
  static void recordWrong() { totalWrong++; save(); }
  static double get successRate => totalCorrect + totalWrong == 0 ? 0 : totalCorrect / (totalCorrect + totalWrong);
  static void addSkill(String s) { skills[s] = (skills[s] ?? 0) + 1; save(); }
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
        .where((entry) => entry.value >= (missionTargets[entry.key] ?? 1))
        .length;
    save();
  }

  static bool isMissionDone(String id) =>
      (missionProgress[id] ?? 0) >= (missionTargets[id] ?? 1);

  static int missionValue(String id) => missionProgress[id] ?? 0;
  static void unlockAch(String id) { if (!achievements.contains(id)) { achievements.add(id); save(); } }
  static void buySticker(String id, int price) { if (coins >= price && !stickers.contains(id)) { coins -= price; stickers.add(id); save(); } }
  static void addPlayTime() { todayPlaySeconds++; if (todayPlaySeconds % 60 == 0) { weeklyPlayMinutes++; save(); } }

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
  static bool canOpenGoldenChest() => weeklyPlayMinutes >= 30 && !goldenChestOpened;
}

// ==========================================================
// 🧠 AI SYSTEMS
// ==========================================================
class AI {
  static int difficulty() {
    if (GameData.successRate > 0.8) return 3;
    if (GameData.successRate > 0.5) return 2;
    return 1;
  }

  static String diffName() {
    switch (difficulty()) {
      case 3: return "سخت";
      case 2: return "متوسط";
      default: return "آسان";
    }
  }

  static String mascotMsg() {
    if (GameData.totalCorrect == 0) return "سلام! بیا بازی کنیم! 🎮";
    if (GameData.successRate > 0.8) return "آفرین نابغه! 🌟";
    if (GameData.successRate > 0.5) return "ادامه بده عالی میشی! 💪";
    return "اشکال نداره! تمرین کن! 🎯";
  }

  static String weakSkill() {
    var sorted = GameData.skills.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    Map<String, String> names = {
      'math': 'ریاضی', 'alphabet': 'الفبا', 'memory': 'حافظه', 'colors': 'رنگ‌ها',
      'shapes': 'اشکال', 'animals': 'حیوانات', 'counting': 'شمارش', 'pattern': 'الگو',
      'fruits': 'میوه‌ها', 'concepts': 'مفاهیم', 'vocab': 'لغات', 'body': 'بدن',
      'vehicles': 'وسایل نقلیه', 'time': 'زمان', 'weather': 'آب و هوا',
      'emotions': 'احساسات', 'jobs': 'شغل‌ها'
    };
    return names[sorted.first.key] ?? 'همه';
  }

  static bool fatigued(int mistakes, Duration time) => mistakes > 5 && time.inMinutes > 15;
}

// ==========================================================
// 🌟 KIND CHILD FEEDBACK
// ==========================================================
class ChildFeedback {
  static final _praise = ['آفرین! عالی بود! 🌟', 'باریکلا قهرمان! 🥳', 'درست گفتی! ادامه بده! 🚀'];
  static final _tryAgain = ['نزدیک بودی! یک‌بار دیگه امتحان کن 🌈', 'اشکال نداره عزیزم، با دقت نگاه کن 💛', 'تو می‌تونی! دوباره تلاش کن ✨'];

  static void correct(BuildContext context) => _show(context, _praise[Random().nextInt(_praise.length)], const Color(0xFF2EAF63));
  static void tryAgain(BuildContext context) => _show(context, _tryAgain[Random().nextInt(_tryAgain.length)], const Color(0xFFFF8A4C));

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        duration: const Duration(milliseconds: 1150),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ));
  }
}

// ==========================================================
// 🎨 GRADIENTS
// ==========================================================
class G {
  static const p = LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)]);
  static const s = LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)]);
  static const w = LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFFB84D)]);
  static const pu = LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)]);
  static const pk = LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFF48FB1)]);
}

// ==========================================================
// ⚡ BOUNCE BUTTON
// ==========================================================
class BounceBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BounceBtn({super.key, required this.child, required this.onTap});
  @override
  State<BounceBtn> createState() => _BounceBtnState();
}

class _BounceBtnState extends State<BounceBtn> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 150), lowerBound: 0.9, upperBound: 1.0)..value = 1.0;
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext c) => GestureDetector(
    onTapDown: (_) => _c.reverse(),
    onTapUp: (_) { _c.forward(); HapticFeedback.lightImpact(); widget.onTap(); },
    onTapCancel: () => _c.forward(),
    child: ScaleTransition(scale: _c, child: widget.child),
  );
}

// ==========================================================
// 🎨 APP ROOT
// ==========================================================
class KudakeIranApp extends StatelessWidget {
  const KudakeIranApp({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'کودک ایران',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
      scaffoldBackgroundColor: const Color(0xFFFFFBFF),
      textTheme: GoogleFonts.vazirmatnTextTheme(),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0, surfaceTintColor: Colors.transparent),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        elevation: 3, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      )),
    ),
    home: const SplashScreen(),
  );
}

// ==========================================================
// 🚀 SPLASH SCREEN
// ==========================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => GameData.onboardingSeen ? const Dashboard() : const OnboardingPage(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: G.p),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 120, color: Colors.white)
                .animate(onPlay: (c) => c.repeat())
                .scale(duration: 1000.ms)
                .then()
                .shake(),
            const SizedBox(height: 20),
            Text("کودک ایران",
              style: GoogleFonts.vazirmatn(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold),
            ).animate().fadeIn().slideY(begin: 1),
            const Text("Parsa Apps™", style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    ),
  );
}

// ==========================================================
// 📖 ONBOARDING
// ==========================================================
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingPage> {
  final PageController _ctrl = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _page = 0;
  int _selectedAge = 5;
  final _data = [
    {"i": Icons.school_rounded, "t": "یادگیری هوشمند", "d": "سختی تمرین با سطح کودک تنظیم می‌شود", "c": const Color(0xFF6C63FF)},
    {"i": Icons.videogame_asset_rounded, "t": "بازی و جایزه", "d": "سکه بگیر و لول آپ کن!", "c": const Color(0xFFFFB84D)},
    {"i": Icons.family_restroom_rounded, "t": "پنل والدین", "d": "گزارش دقیق پیشرفت فرزند", "c": const Color(0xFF4CAF50)},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = GameData.childName;
    _selectedAge = GameData.childAge;
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(children: [
        Align(alignment: Alignment.topLeft, child: TextButton(onPressed: _go, child: const Text("رد کردن"))),
        Expanded(
          child: PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _data.length,
            itemBuilder: (c, i) => Padding(
              padding: const EdgeInsets.all(30),
              child: i == 2 ? _profileForm() : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: (_data[i]['c'] as Color).withOpacity(0.1)),
                    child: Icon(_data[i]['i'] as IconData, size: 100, color: _data[i]['c'] as Color),
                  ).animate().scale(curve: Curves.elasticOut),
                  const SizedBox(height: 30),
                  Text(_data[i]['t'] as String, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(_data[i]['d'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ),
        if (_page == _data.length - 1)
          Padding(
            padding: const EdgeInsets.all(30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), minimumSize: const Size(double.infinity, 55)),
              onPressed: _go,
              child: const Text("شروع ماجراجویی", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          )
        else
          Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_data.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 25 : 8,
                height: 8,
                decoration: BoxDecoration(color: _page == i ? _data[_page]['c'] as Color : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              )),
            ),
            const SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("به چپ بکشید", style: TextStyle(color: Colors.grey)),
              const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .slideX(begin: 0.5, end: -0.5),
            ]),
            const SizedBox(height: 20),
          ]),
      ]),
    ),
  );

  Widget _profileForm() => SingleChildScrollView(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('سلام دوست کوچولو! 👋', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('بیا شخصیت خودت را برای ماجراجویی بسازیم.', textAlign: TextAlign.center, style: TextStyle(fontSize: 17)),
      const SizedBox(height: 20),
      TextField(controller: _nameController, textAlign: TextAlign.center, textInputAction: TextInputAction.done,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(labelText: 'اسمت چیه؟', hintText: 'مثلاً آوا', prefixIcon: const Icon(Icons.face_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)))),
      const SizedBox(height: 18),
      const Align(alignment: Alignment.centerRight, child: Text('چند سالته؟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: List.generate(8, (i) { final age = i + 3; return ChoiceChip(label: Text('$age سال', style: const TextStyle(fontSize: 16)), selected: _selectedAge == age, onSelected: (_) => setState(() => _selectedAge = age)); })),
      const SizedBox(height: 18),
      const Align(alignment: Alignment.centerRight, child: Text('آواتار مورد علاقه‌ات را انتخاب کن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: ['😊', '😎', '🤩', '🦁', '🐱', '🦊', '🐼', '🦄'].map((avatar) => GestureDetector(
        onTap: () => setState(() => GameData.avatar = avatar),
        child: AnimatedContainer(duration: const Duration(milliseconds: 180), width: 48, height: 48, alignment: Alignment.center,
          decoration: BoxDecoration(color: GameData.avatar == avatar ? const Color(0xFFE7E4FF) : Colors.grey.shade100, shape: BoxShape.circle, border: Border.all(color: GameData.avatar == avatar ? const Color(0xFF6C63FF) : Colors.transparent, width: 2)),
          child: Text(avatar, style: const TextStyle(fontSize: 29))),
      )).toList()),
    ]),
  );

  void _go() {
    GameData.childName = _nameController.text.trim().isEmpty ? 'قهرمان کوچولو' : _nameController.text.trim();
    GameData.childAge = _selectedAge;
    GameData.onboardingSeen = true;
    GameData.save();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const Dashboard()));
  }

  @override
  void dispose() { _ctrl.dispose(); _nameController.dispose(); super.dispose(); }
}

// ==========================================================
// 🏠 DASHBOARD
// ==========================================================
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashState();
}

class _DashState extends State<Dashboard> {
  late ConfettiController _conf;
  late Timer _sessionTimer;
  int _sessionSec = 0;
  bool _timeLimitDialogShown = false;

  @override
  void initState() {
    super.initState();
    _conf = ConfettiController(duration: const Duration(seconds: 2));
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _sessionSec++;
      GameData.addPlayTime();
      if (_sessionSec >= GameData.timeLimitMinutes * 60 && !_timeLimitDialogShown) {
        _timeLimitDialogShown = true;
        _showTimeLimit();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSurprise();
      _checkTreasure();
    });
  }

  @override
  void dispose() {
    _conf.dispose();
    _sessionTimer.cancel();
    super.dispose();
  }

  void _checkSurprise() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (GameData.surprise() && GameData.lastSurpriseClaimDate != today) {
      showDialog(context: context, builder: (c) => AlertDialog(
        title: const Text("🎁 جایزه غافلگیرکننده!"),
        content: Text("${GameData.streak} روز پیاپی اومدی! ۵۰ سکه جایزه!"),
        actions: [TextButton(onPressed: () {
          GameData.lastSurpriseClaimDate = today;
          GameData.addCoins(50);
          setState(() {});
          Navigator.pop(c);
        }, child: const Text("عالیه!"))],
      ));
    }
  }

  void _checkTreasure() {
    if (GameData.canOpenTreasure()) {
      showDialog(context: context, builder: (c) => AlertDialog(
        title: const Text("🎪 صندوق گنج!"),
        content: const Text("ماموریت‌های امروز رو کامل کردی! صندوق گنج رو باز کن!"),
        actions: [TextButton(onPressed: () { GameData.addCoins(100); GameData.treasureOpened = true; GameData.save(); _conf.play(); setState(() {}); Navigator.pop(c); }, child: const Text("باز کن! 🎁"))],
      ));
    }
  }

  void _showTimeLimit() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("⏰ زمان تموم شد!"),
      content: const Text("وقت استراحته! فردا برگرد!"),
      actions: [TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(c); }, child: const Text("باشه"))],
    ));
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: const Color(0xFFF0F2F5),
    body: Stack(children: [
      CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: G.p),
              child: Stack(fit: StackFit.expand, children: [
                Opacity(opacity: .34, child: Image.asset('assets/hero_kids.png', fit: BoxFit.cover)),
                SafeArea(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(GameData.avatar, style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 10),
                    Text(GameData.getMascot(), style: const TextStyle(fontSize: 40)),
                  ]),
                  Text(GameData.getLevelName(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("لول ${GameData.level} | ${GameData.coins} ⭐ | 🔥 ${GameData.streak} روز", style: const TextStyle(color: Colors.white70)),
                  ]),
                ),
              ]),
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.face), onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (c) => const AvatarPage()));
              setState(() {});
            }),
            IconButton(icon: const Icon(Icons.settings), onPressed: _parentGate),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Text("🧸", style: TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(child: Text(GameData.childName.isEmpty ? AI.mascotMsg() : 'سلام ${GameData.childName}! ${AI.mascotMsg()}')),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text("🎯 ماموریت امروز", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (GameData.canOpenTreasure()) const Text("🎪 صندوق آماده!", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 8),
              _mi("۵ سوال حل کن", 'questions', GameData.missionValue('questions'), 5),
              _mi("الفبا تمرین کن", 'alphabet', GameData.missionValue('alphabet'), 1),
              _mi("یک نقاشی بکش", 'drawing', GameData.missionValue('drawing'), 1),
              _mi("رنگ‌ها رو یاد بگیر", 'colors', GameData.missionValue('colors'), 1),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(child: _worldStrip()),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(child: _menuGroups()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ]),
      Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _conf, blastDirectionality: BlastDirectionality.explosive)),
    ]),
  );

  Widget _menuGroups() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('بازی‌ها و ماجراجویی‌ها', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
      _menuGroup('یادگیری پایه', 'الفبا، عددها، رنگ‌ها و مفاهیم', const Color(0xFF7B6CF6), [
        _m("الفبا", Icons.sort_by_alpha, G.pu, const AlphabetGame()),
        _m("اعداد", Icons.calculate, G.s, const NumberGame()),
        _m("شمارش", Icons.pin, const LinearGradient(colors: [Colors.indigo, Colors.blue]), const CountingGame()),
        _m("رنگ‌ها", Icons.palette, G.w, const ColorGame()),
        _m("اشکال", Icons.category, const LinearGradient(colors: [Colors.blue, Colors.lightBlue]), const ShapeGame()),
        _m("مفاهیم", Icons.compare_arrows, const LinearGradient(colors: [Colors.cyan, Colors.lightBlueAccent]), const ConceptGame()),
        _m("لغات", Icons.translate, const LinearGradient(colors: [Colors.deepPurple, Colors.deepPurpleAccent]), const VocabGame()),
      ], open: true),
      _menuGroup('بازی‌های فکری', 'حافظه، الگو، مسابقه و چالش', const Color(0xFFFF8B72), [
        _m("حافظه", Icons.memory, const LinearGradient(colors: [Colors.teal, Colors.tealAccent]), const MemoryGame()),
        _m("الگو", Icons.grid_view, const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]), const PatternGame()),
        _m("مسابقه", Icons.quiz, const LinearGradient(colors: [Colors.deepPurple, Colors.purple]), const QuizMaster()),
        _m("ترتیب", Icons.sort, const LinearGradient(colors: [Colors.orange, Colors.deepOrange]), const SequenceGame()),
        _m("مورد اضافه", Icons.help, const LinearGradient(colors: [Colors.pink, Colors.pinkAccent]), const OddOneOut()),
        _m("مسابقه ریاضی", Icons.speed, const LinearGradient(colors: [Colors.red, Colors.deepOrange]), const MathRace()),
        _m("چرخ شانس", Icons.casino, const LinearGradient(colors: [Colors.amber, Colors.orange]), const LuckyWheel()),
      ]),
      _menuGroup('دنیای اطراف من', 'حیوانات، طبیعت، بدن و دنیا', const Color(0xFF34BFA2), [
        _m("حیوانات", Icons.pets, const LinearGradient(colors: [Colors.brown, Colors.orange]), const AnimalGame()),
        _m("میوه‌ها", Icons.apple, const LinearGradient(colors: [Colors.red, Colors.redAccent]), const FruitGame()),
        _m("بدن", Icons.accessibility, const LinearGradient(colors: [Colors.pink, Colors.pinkAccent]), const BodyGame()),
        _m("وسایل نقلیه", Icons.directions_car, const LinearGradient(colors: [Colors.blue, Colors.blueAccent]), const VehicleGame()),
        _m("زمان", Icons.calendar_today, const LinearGradient(colors: [Colors.orange, Colors.deepOrange]), const TimeGame()),
        _m("آب و هوا", Icons.cloud, const LinearGradient(colors: [Colors.cyan, Colors.blueAccent]), const WeatherGame()),
        _m("احساسات", Icons.mood, const LinearGradient(colors: [Colors.yellow, Colors.amber]), const EmotionGame()),
        _m("شغل‌ها", Icons.work, const LinearGradient(colors: [Colors.indigo, Colors.deepPurple]), const JobGame()),
        _m("فضا", Icons.rocket_launch, const LinearGradient(colors: [Colors.indigo, Colors.deepPurple]), const SpaceGame()),
        _m("ورزش‌ها", Icons.sports_soccer, const LinearGradient(colors: [Colors.green, Colors.lightGreen]), const SportsGame()),
      ]),
      _menuGroup('خلاقیت و جایزه‌ها', 'داستان، موسیقی، نقاشی و افتخارها', const Color(0xFFFFB34D), [
        _m("داستان", Icons.book, const LinearGradient(colors: [Colors.brown, Colors.deepOrange]), const StoryTime()),
        _m("سازها", Icons.music_note, const LinearGradient(colors: [Colors.purple, Colors.deepPurple]), const MusicGame()),
        _m("نقاشی", Icons.brush, G.pk, const DrawingPage()),
        _m("جوایز", Icons.emoji_events, const LinearGradient(colors: [Colors.amber, Colors.yellow]), const TrophiesRoom()),
        _m("مدال‌ها", Icons.military_tech, const LinearGradient(colors: [Colors.amber, Colors.yellow]), const AchPage()),
        _m("فروشگاه", Icons.shopping_bag, const LinearGradient(colors: [Colors.red, Colors.pink]), const Shop()),
        _m("آمار", Icons.bar_chart, const LinearGradient(colors: [Colors.blueGrey, Colors.grey]), const StatsPage()),
      ]),
      _menuGroup('برای بزرگ‌ترها', 'اشتراک، راهنما و تنظیمات', Colors.blueGrey, [
        _m("اشتراک", Icons.workspace_premium, const LinearGradient(colors: [Colors.amber, Colors.orange]), const SubPage()),
        _m("راهنما", Icons.help_center, const LinearGradient(colors: [Colors.blue, Colors.cyan]), const HelpCenter()),
        _m("امتیاز بده", Icons.thumb_up, const LinearGradient(colors: [Colors.green, Colors.teal]), const RateApp()),
        _m("درباره ما", Icons.info, const LinearGradient(colors: [Colors.blueGrey, Colors.grey]), const AboutPage()),
      ]),
    ]),
  );

  Widget _menuGroup(String title, String subtitle, Color color, List<Widget> games, {bool open = false}) =>
    Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)]),
      child: ExpansionTile(
        initiallyExpanded: open, shape: const Border(), collapsedShape: const Border(),
        leading: CircleAvatar(backgroundColor: color.withOpacity(.14), child: Icon(Icons.auto_awesome_rounded, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        children: [Padding(padding: const EdgeInsets.fromLTRB(8, 0, 8, 10), child: GridView.count(crossAxisCount: 3, childAspectRatio: .9, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: games))],
      ),
    );

  Widget _worldStrip() => SizedBox(
    height: 142,
    child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
      _worldCard('یاد بگیر', 'الفبا، اعداد و رنگ‌ها', 'assets/learn_world.png', const Color(0xFF7B6CF6)),
      _worldCard('بازی کن', 'حافظه، الگو و سرگرمی', 'assets/play_world.png', const Color(0xFFFF8B72)),
      _worldCard('کشف کن', 'دنیا را بشناس', 'assets/explore_world.png', const Color(0xFF34BFA2)),
    ]),
  );

  Widget _worldCard(String title, String subtitle, String asset, Color color) => Container(
    width: 228, margin: const EdgeInsets.only(right: 12), clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 12, offset: const Offset(0, 5))]),
    child: Stack(children: [
      Positioned(right: -8, bottom: -14, width: 132, child: Image.asset(asset)),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5), SizedBox(width: 105, child: Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35))),
      ])),
    ]),
  );

  Widget _mi(String title, String id, int value, int target) {
    final done = GameData.isMissionDone(id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: done ? const Color(0xFF35B86B) : Colors.grey, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(title,
            style: TextStyle(decoration: done ? TextDecoration.lineThrough : null, fontSize: 13))),
        if (!done && target > 1)
          Text('$value/$target', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
      ]),
    );
  }

  Widget _m(String t, IconData i, Gradient g, Widget pg) => Padding(
    padding: const EdgeInsets.all(6),
    child: BounceBtn(
      onTap: () async {
        await Navigator.push(context, PageRouteBuilder(
          pageBuilder: (_, a, __) => pg,
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(a), child: c)),
        ));
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: g,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, size: 35, color: Colors.white).animate(onPlay: (c) => c.repeat()).shimmer(delay: 2.seconds),
          const SizedBox(height: 6),
          Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ),
    ),
  );

  void _parentGate() {
    int n1 = Random().nextInt(10) + 1, n2 = Random().nextInt(10) + 1;
    TextEditingController ct = TextEditingController();
    showDialog(context: context, builder: (cx) => AlertDialog(
      title: const Text("ورود والدین"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("$n1 + $n2 = ?", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        TextField(controller: ct, keyboardType: TextInputType.number, textAlign: TextAlign.center),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(cx), child: const Text("انصراف")),
        ElevatedButton(onPressed: () {
          if (int.tryParse(ct.text) == n1 + n2) {
            Navigator.pop(cx);
            Navigator.push(context, MaterialPageRoute(builder: (c) => const ParentPanel()));
          }
        }, child: const Text("تایید")),
      ],
    ));
  }
}

// ==========================================================
// 🎭 AVATAR PAGE
// ==========================================================
class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("شخصیت")),
    body: GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: 16,
      itemBuilder: (c, i) {
        final a = ['😊','😎','🤩','🦁','🐱','🐶','🦊','🐼','🐸','🦄','🐻','🐯','🐰','🐷','🐨','🦓'][i];
        return BounceBtn(
          onTap: () { GameData.avatar = a; GameData.save(); Navigator.pop(c); },
          child: Container(
            decoration: BoxDecoration(
              color: GameData.avatar == a ? Colors.purple.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: GameData.avatar == a ? Border.all(color: Colors.purple, width: 3) : null,
            ),
            child: Center(child: Text(a, style: const TextStyle(fontSize: 40))),
          ),
        );
      },
    ),
  );
}

// ==========================================================
// 🔤 ALPHABET GAME
// ==========================================================
class AlphabetGame extends StatefulWidget {
  const AlphabetGame({super.key});
  @override
  State<AlphabetGame> createState() => _AlphaState();
}

class _AlphaState extends State<AlphabetGame> {
  final l = ["ا","ب","پ","ت","ث","ج","چ","ح","خ","د","ذ","ر","ز","ژ","س","ش","ص","ض","ط","ظ","ع","غ","ف","ق","ک","گ","ل","م","ن","و","ه","ی"];
  String s = "ا";

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("الفبا"), backgroundColor: Colors.purple.shade100),
    body: Column(children: [
      Expanded(flex: 2, child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: G.pu, borderRadius: BorderRadius.circular(30)),
        child: Center(child: Text(s, style: const TextStyle(fontSize: 160, color: Colors.white, fontWeight: FontWeight.bold)).animate(key: ValueKey(s)).scale()),
      )),
      Expanded(flex: 3, child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
        itemCount: l.length,
        itemBuilder: (c, i) => BounceBtn(
          onTap: () { setState(() => s = l[i]); GameData.addCoins(1); GameData.addSkill('alphabet'); GameData.progressMission('alphabet'); },
          child: Container(
            decoration: BoxDecoration(
              color: s == l[i] ? Colors.purple : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
            ),
            child: Center(child: Text(l[i], style: TextStyle(fontSize: 26, color: s == l[i] ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
          ),
        ),
      )),
    ]),
  );
}

// ==========================================================
// 🔢 NUMBER GAME
// ==========================================================
class NumberGame extends StatefulWidget {
  const NumberGame({super.key});
  @override
  State<NumberGame> createState() => _NumState();
}

class _NumState extends State<NumberGame> {
  int n1 = 0, n2 = 0, ans = 0, sc = 0, mis = 0;
  List<int> opts = [];
  late ConfettiController _cf;
  final DateTime _st = DateTime.now();

  @override
  void initState() { super.initState(); _cf = ConfettiController(duration: const Duration(seconds: 1)); _gen(); }
  @override
  void dispose() { _cf.dispose(); super.dispose(); }

  void _gen() {
    final r = Random();
    int d = AI.difficulty(), mx = d == 1 ? 5 : d == 2 ? 10 : 20;
    setState(() {
      n1 = r.nextInt(mx) + 1;
      n2 = r.nextInt(mx) + 1;
      ans = n1 + n2;
      opts = {ans, ans + r.nextInt(3) + 1, (ans - r.nextInt(3) - 1).abs(), ans + r.nextInt(5) + 2}.toList()..shuffle();
      while (opts.length < 4) opts.add(ans + Random().nextInt(10));
      opts = opts.take(4).toList()..shuffle();
    });
  }

  void _chk(int a) {
    if (AI.fatigued(mis, DateTime.now().difference(_st))) {
      showDialog(context: context, builder: (c) => AlertDialog(
        title: const Text("🧸 استراحت کن!"),
        actions: [TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(c); }, child: const Text("باشه"))],
      ));
      return;
    }
    if (a == ans) {
      HapticFeedback.mediumImpact();
      _cf.play();
      GameData.addCoins(5); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('math'); GameData.progressMission('questions');
      setState(() => sc += 5);
      if (sc >= 50) GameData.unlockAch("math_50");
      Future.delayed(const Duration(milliseconds: 800), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      mis++;
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("اعداد | $sc | ${AI.diffName()}"), backgroundColor: Colors.green.shade100),
    body: Stack(children: [
      Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(gradient: G.s, borderRadius: BorderRadius.circular(20)),
          child: Text("$n1 + $n2 = ?", style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white))),
        const SizedBox(height: 30),
        GridView.count(shrinkWrap: true, crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
          children: opts.map((o) => BounceBtn(onTap: () => _chk(o),
            child: Container(decoration: BoxDecoration(gradient: G.w, borderRadius: BorderRadius.circular(20)),
              child: Center(child: Text("$o", style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)))))).toList()),
      ])),
      Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _cf, blastDirectionality: BlastDirectionality.explosive)),
    ]),
  );
}

// ==========================================================
// 🧩 MEMORY GAME
// ==========================================================
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});
  @override
  State<MemoryGame> createState() => _MemState();
}

class _MemState extends State<MemoryGame> {
  final List<String> em = ['🍎','🍌','🍇','🌸','🍎','🍌','🍇','🌸','🐶','🐱','🐶','🐱'];
  List<bool> rv = [];
  int? fi;
  int mt = 0;

  @override
  void initState() { super.initState(); em.shuffle(); rv = List.filled(em.length, false); }

  void _tap(int i) {
    if (rv[i]) return;
    HapticFeedback.lightImpact();
    setState(() => rv[i] = true);
    if (fi == null) {
      fi = i;
    } else {
      if (em[fi!] == em[i]) {
        mt++;
        GameData.addCoins(10); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('memory');
        if (mt == em.length ~/ 2) GameData.unlockAch("memory_king");
        fi = null;
      } else {
        GameData.recordWrong(); ChildFeedback.tryAgain(context);
        int f = fi!;
        fi = null;
        Future.delayed(const Duration(milliseconds: 600), () { if (mounted) setState(() { rv[f] = false; rv[i] = false; }); });
      }
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("حافظه | جفت: $mt"), backgroundColor: Colors.teal.shade100),
    body: GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: em.length,
      itemBuilder: (c, i) => BounceBtn(
        onTap: () => _tap(i),
        child: Container(
          decoration: BoxDecoration(color: rv[i] ? Colors.white : Colors.teal, borderRadius: BorderRadius.circular(15)),
          child: Center(child: Text(rv[i] ? em[i] : "❓", style: const TextStyle(fontSize: 40))),
        ),
      ),
    ),
  );
}

// ==========================================================
// 🔢 COUNTING GAME
// ==========================================================
class CountingGame extends StatefulWidget {
  const CountingGame({super.key});
  @override
  State<CountingGame> createState() => _CountState();
}

class _CountState extends State<CountingGame> {
  int target = 0, sc = 0;
  List<int> opts = [];
  String emoji = '';
  final emojis = ['🍎','🌟','⚽','🎈','🌺'];

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    final r = Random();
    setState(() {
      target = r.nextInt(8) + 1;
      emoji = emojis[r.nextInt(emojis.length)];
      opts = {target, target + 1, (target - 1).clamp(1, 99), target + 2}.toList()..shuffle();
    });
  }

  void _chk(int a) {
    if (a == target) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('counting'); GameData.progressMission('questions');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("شمارش | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("چندتاست؟", style: TextStyle(fontSize: 20)),
      const SizedBox(height: 20),
      Wrap(children: List.generate(target, (_) => Text(emoji, style: const TextStyle(fontSize: 50)))),
      const SizedBox(height: 30),
      GridView.count(shrinkWrap: true, crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((o) => BounceBtn(onTap: () => _chk(o),
          child: Container(decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text("$o", style: const TextStyle(fontSize: 40, color: Colors.white)))))).toList()),
    ])),
  );
}

// ==========================================================
// 🔷 PATTERN GAME
// ==========================================================
class PatternGame extends StatefulWidget {
  const PatternGame({super.key});
  @override
  State<PatternGame> createState() => _PatState();
}

class _PatState extends State<PatternGame> {
  List<String> pattern = [];
  String answer = '';
  List<String> opts = [];
  int sc = 0;
  final sets = [['🔴','🔵','🔴','🔵','?'], ['⭐','🌙','⭐','🌙','?'], ['🟢','🟢','🟡','🟢','🟢','?'], ['🔺','🔻','🔺','🔻','?']];
  final answers = ['🔴','⭐','🟡','🔺'];
  int idx = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    setState(() {
      idx = Random().nextInt(sets.length);
      pattern = List.from(sets[idx]);
      answer = answers[idx];
      opts = [answer, '🟠', '🟣', '⬛']..shuffle();
    });
  }

  void _chk(String a) {
    if (a == answer) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(5); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('pattern');
      setState(() => sc += 5);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("تشخیص الگو | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("الگو رو کامل کن:", style: TextStyle(fontSize: 20)),
      const SizedBox(height: 30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: pattern.map((e) => Text(e, style: const TextStyle(fontSize: 40))).toList()),
      const SizedBox(height: 40),
      GridView.count(shrinkWrap: true, crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((o) => BounceBtn(onTap: () => _chk(o),
          child: Container(decoration: BoxDecoration(color: Colors.deepPurple.shade100, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(o, style: const TextStyle(fontSize: 50)))))).toList()),
    ])),
  );
}

// ==========================================================
// 🌈 COLOR GAME
// ==========================================================
class ColorGame extends StatefulWidget {
  const ColorGame({super.key});
  @override
  State<ColorGame> createState() => _ColState();
}

class _ColState extends State<ColorGame> {
  final Map<String, Color> cl = {"قرمز": Colors.red, "آبی": Colors.blue, "سبز": Colors.green, "زرد": Colors.yellow, "بنفش": Colors.purple, "نارنجی": Colors.orange};
  late String tn;
  late Color tc;
  List<MapEntry<String, Color>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = cl.entries.toList()..shuffle();
    setState(() { tn = e.first.key; tc = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(Color c) {
    if (c == tc) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('colors'); GameData.progressMission('colors');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("رنگ‌ها | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("رنگ «$tn» کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: e.value, borderRadius: BorderRadius.circular(20))))).toList())),
    ])),
  );
}

// ==========================================================
// 🔷 SHAPE GAME
// ==========================================================
class ShapeGame extends StatefulWidget {
  const ShapeGame({super.key});
  @override
  State<ShapeGame> createState() => _ShpState();
}

class _ShpState extends State<ShapeGame> {
  final Map<String, IconData> sh = {"دایره": Icons.circle, "مربع": Icons.square, "مثلث": Icons.change_history, "ستاره": Icons.star, "قلب": Icons.favorite};
  late String tn;
  late IconData ti;
  List<MapEntry<String, IconData>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = sh.entries.toList()..shuffle();
    setState(() { tn = e.first.key; ti = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(IconData i) {
    if (i == ti) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('shapes');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("اشکال | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("شکل «$tn» کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue, width: 2)),
            child: Icon(e.value, size: 70, color: Colors.blue)))).toList())),
    ])),
  );
}

// ==========================================================
// 🐾 ANIMAL GAME
// ==========================================================
class AnimalGame extends StatefulWidget {
  const AnimalGame({super.key});
  @override
  State<AnimalGame> createState() => _AniState();
}

class _AniState extends State<AnimalGame> {
  final Map<String, String> an = {"شیر":"🦁","گربه":"🐱","سگ":"🐶","خرگوش":"🐰","فیل":"🐘","میمون":"🐵","ببر":"🐯","خرس":"🐻"};
  late String tn, te;
  List<MapEntry<String, String>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = an.entries.toList()..shuffle();
    setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(String e) {
    if (e == te) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('animals');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("حیوانات | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("$tn کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
    ])),
  );
}

// ==========================================================
// 🍎 FRUIT GAME
// ==========================================================
class FruitGame extends StatefulWidget {
  const FruitGame({super.key});
  @override
  State<FruitGame> createState() => _FrtState();
}

class _FrtState extends State<FruitGame> {
  final Map<String, String> fr = {"سیب":"🍎","موز":"🍌","انگور":"🍇","پرتقال":"🍊","توت‌فرنگی":"🍓","هندوانه":"🍉","گیلاس":"🍒","آناناس":"🍍"};
  late String tn, te;
  List<MapEntry<String, String>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = fr.entries.toList()..shuffle();
    setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(String e) {
    if (e == te) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('fruits');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("میوه‌ها | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("$tn کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
    ])),
  );
}

// ==========================================================
// ↔ CONCEPT GAME
// ==========================================================
class ConceptGame extends StatefulWidget {
  const ConceptGame({super.key});
  @override
  State<ConceptGame> createState() => _ConState();
}

class _ConState extends State<ConceptGame> {
  String q = '';
  bool ansIsBig = true;
  int sc = 0;
  final items = [
    {'q': '🐘 و 🐁 کدوم بزرگ‌تره؟', 'a': true},
    {'q': '🌳 و 🌱 کدوم کوچک‌تره؟', 'a': false},
    {'q': '🏔 و 🏠 کدوم بزرگ‌تره؟', 'a': true},
    {'q': '🚗 و 🚲 کدوم کوچک‌تره؟', 'a': false},
  ];

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var r = items[Random().nextInt(items.length)];
    setState(() { q = r['q'] as String; ansIsBig = r['a'] as bool; });
  }

  void _chk(bool b) {
    if (b == ansIsBig) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('concepts');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("مفاهیم | $sc")),
    body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(q, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      const SizedBox(height: 40),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        BounceBtn(onTap: () => _chk(true), child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
          child: const Center(child: Text("بزرگ‌تر", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))))),
        BounceBtn(onTap: () => _chk(false), child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
          child: const Center(child: Text("کوچک‌تر", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))))),
      ]),
    ])),
  );
}

// ==========================================================
// 📚 VOCAB GAME
// ==========================================================
class VocabGame extends StatefulWidget {
  const VocabGame({super.key});
  @override
  State<VocabGame> createState() => _VocState();
}

class _VocState extends State<VocabGame> {
  final vc = {"سیب":"Apple","کتاب":"Book","خانه":"House","آب":"Water","درخت":"Tree","خورشید":"Sun","ماه":"Moon","گل":"Flower","مدرسه":"School","دوست":"Friend"};
  late String tn, ta;
  List<String> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = vc.entries.toList()..shuffle();
    setState(() {
      tn = e.first.key;
      ta = e.first.value;
      opts = e.take(4).map((x) => x.value).toList()..shuffle();
    });
  }

  void _chk(String a) {
    if (a == ta) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(5); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('vocab');
      setState(() => sc += 5);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("لغات | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(gradient: G.pu, borderRadius: BorderRadius.circular(20)),
        child: Text(tn, style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold))),
      const SizedBox(height: 20),
      const Text("انگلیسی این کلمه چیست؟", style: TextStyle(fontSize: 16)),
      const SizedBox(height: 20),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((o) => BounceBtn(onTap: () => _chk(o),
          child: Container(decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(o, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)))))).toList())),
    ])),
  );
}

// ==========================================================
// 👤 BODY GAME
// ==========================================================
class BodyGame extends StatefulWidget {
  const BodyGame({super.key});
  @override
  State<BodyGame> createState() => _BdyState();
}

class _BdyState extends State<BodyGame> {
  final bp = {"چشم":"👁","دهان":"👄","گوش":"👂","دست":"✋","پا":"🦵","دماغ":"👃","مغز":"🧠","قلب":"❤️"};
  late String tn, te;
  List<MapEntry<String, String>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = bp.entries.toList()..shuffle();
    setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(String e) {
    if (e == te) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(4); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('body');
      setState(() => sc += 4);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("اعضای بدن | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("«$tn» کدومه؟", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
    ])),
  );
}

// ==========================================================
// 🚗 VEHICLE GAME
// ==========================================================
class VehicleGame extends StatefulWidget {
  const VehicleGame({super.key});
  @override
  State<VehicleGame> createState() => _VhState();
}

class _VhState extends State<VehicleGame> {
  final vh = {"ماشین":"🚗","اتوبوس":"🚌","دوچرخه":"🚲","هواپیما":"✈️","قطار":"🚂","کشتی":"🚢","موتور":"🏍","بالگرد":"🚁"};
  late String tn, te;
  List<MapEntry<String, String>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = vh.entries.toList()..shuffle();
    setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(String e) {
    if (e == te) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('vehicles');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("وسایل نقلیه | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("$tn کدومه؟", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
    ])),
  );
}

// ==========================================================
// 📅 TIME GAME
// ==========================================================
class TimeGame extends StatefulWidget {
  const TimeGame({super.key});
  @override
  State<TimeGame> createState() => _TmState();
}

class _TmState extends State<TimeGame> {
  final days = ["شنبه","یکشنبه","دوشنبه","سه‌شنبه","چهارشنبه","پنج‌شنبه","جمعه"];
  final months = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور","مهر","آبان","آذر","دی","بهمن","اسفند"];
  bool isDayMode = true;
  late String question;
  late int correctIdx;
  List<String> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    isDayMode = Random().nextBool();
    var list = isDayMode ? days : months;
    setState(() {
      correctIdx = Random().nextInt(list.length);
      question = isDayMode ? "روز ${correctIdx + 1}م هفته چیه؟" : "ماه ${correctIdx + 1}م سال چیه؟";
      opts = [list[correctIdx]];
      while (opts.length < 4) {
        String r = list[Random().nextInt(list.length)];
        if (!opts.contains(r)) opts.add(r);
      }
      opts.shuffle();
    });
  }

  void _chk(String a) {
    var list = isDayMode ? days : months;
    if (a == list[correctIdx]) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(4); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('time');
      setState(() => sc += 4);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("روزها و ماه‌ها | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(gradient: G.w, borderRadius: BorderRadius.circular(20)),
        child: Text(question, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((o) => BounceBtn(onTap: () => _chk(o),
          child: Container(decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(o, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)))))).toList())),
    ])),
  );
}

// ==========================================================
// ☀️ WEATHER GAME
// ==========================================================
class WeatherGame extends StatefulWidget {
  const WeatherGame({super.key});
  @override
  State<WeatherGame> createState() => _WtState();
}

class _WtState extends State<WeatherGame> {
  final wt = {"آفتابی":"☀️","بارانی":"🌧","برفی":"❄️","ابری":"☁️","طوفانی":"⛈","رنگین‌کمان":"🌈","بادی":"💨","مه":"🌫"};
  late String tn, te;
  List<MapEntry<String, String>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = wt.entries.toList()..shuffle();
    setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(String e) {
    if (e == te) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('weather');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("آب و هوا | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("هوای «$tn» کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.cyan.shade100, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
    ])),
  );
}

// ==========================================================
// 😊 EMOTION GAME
// ==========================================================
class EmotionGame extends StatefulWidget {
  const EmotionGame({super.key});
  @override
  State<EmotionGame> createState() => _EmState();
}

class _EmState extends State<EmotionGame> {
  final em = {"خوشحال":"😄","غمگین":"😢","عصبانی":"😡","تعجب":"😲","خواب‌آلود":"😴","عاشق":"😍","ترسیده":"😱","خجالتی":"😊"};
  late String tn, te;
  List<MapEntry<String, String>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = em.entries.toList()..shuffle();
    setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(String e) {
    if (e == te) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(4); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('emotions');
      setState(() => sc += 4);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("احساسات | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("چهره «$tn» کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.yellow.shade100, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
    ])),
  );
}

// ==========================================================
// 👨‍⚕️ JOB GAME
// ==========================================================
class JobGame extends StatefulWidget {
  const JobGame({super.key});
  @override
  State<JobGame> createState() => _JbState();
}

class _JbState extends State<JobGame> {
  final jb = {"دکتر":"👨‍⚕️","معلم":"👨‍🏫","پلیس":"👮","آشپز":"👨‍🍳","خلبان":"👨‍✈️","کشاورز":"👨‍🌾","دانشمند":"👨‍🔬","نقاش":"👨‍🎨"};
  late String tn, te;
  List<MapEntry<String, String>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = jb.entries.toList()..shuffle();
    setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(String e) {
    if (e == te) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(4); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('jobs');
      setState(() => sc += 4);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("شغل‌ها | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("$tn کدومه؟", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
    ])),
  );
}

// ==========================================================
// 🎯 QUIZ MASTER
// ==========================================================
class QuizMaster extends StatefulWidget {
  const QuizMaster({super.key});
  @override
  State<QuizMaster> createState() => _QzState();
}

class _QzState extends State<QuizMaster> {
  final questions = [
    {"q": "پایتخت ایران کجاست؟", "opts": ["تهران", "اصفهان", "شیراز", "مشهد"], "a": 0},
    {"q": "چند فصل داریم؟", "opts": ["۲", "۳", "۴", "۵"], "a": 2},
    {"q": "رنگ آسمان چیست؟", "opts": ["سبز", "آبی", "قرمز", "زرد"], "a": 1},
    {"q": "کدوم حیوان پرواز میکنه؟", "opts": ["ماهی", "پرنده", "سگ", "گربه"], "a": 1},
    {"q": "یک هفته چند روزه؟", "opts": ["۵", "۶", "۷", "۸"], "a": 2},
    {"q": "کدوم میوه زرده؟", "opts": ["سیب", "موز", "پرتقال", "انگور"], "a": 1},
    {"q": "خورشید کی طلوع میکنه؟", "opts": ["شب", "صبح", "ظهر", "عصر"], "a": 1},
    {"q": "کدوم یک وسیله نقلیه است؟", "opts": ["کتاب", "ماشین", "سیب", "درخت"], "a": 1},
  ];
  int currentQ = 0, sc = 0;
  bool _answerLocked = false;
  late ConfettiController _cf;

  @override
  void initState() {
    super.initState();
    _cf = ConfettiController(duration: const Duration(seconds: 1));
    questions.shuffle();
  }

  @override
  void dispose() { _cf.dispose(); super.dispose(); }

  void _answer(int idx) {
    if (_answerLocked) return;
    setState(() => _answerLocked = true);
    if (idx == questions[currentQ]['a']) {
      HapticFeedback.mediumImpact();
      _cf.play();
      GameData.addCoins(10); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.progressMission('questions');
      setState(() => sc += 10);
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }

    if (currentQ < questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() { currentQ++; _answerLocked = false; });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        GameData.updateHighScore(sc, 'quiz');
        showDialog(context: context, builder: (c) => AlertDialog(
          title: const Text("🎉 پایان مسابقه!"),
          content: Text("امتیاز شما: $sc\nرکورد: ${GameData.quizHighScore}"),
          actions: [TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(c); }, child: const Text("عالی!"))],
        ));
      });
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("مسابقه | ${currentQ + 1}/${questions.length}")),
    body: Stack(children: [
      Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        LinearProgressIndicator(value: (currentQ + 1) / questions.length, backgroundColor: Colors.grey.shade200, color: Colors.deepPurple, minHeight: 10),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(gradient: G.pu, borderRadius: BorderRadius.circular(20)),
          child: Text(questions[currentQ]['q'] as String, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        const SizedBox(height: 30),
        Text("امتیاز: $sc", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(child: ListView.builder(itemCount: (questions[currentQ]['opts'] as List).length,
          itemBuilder: (c, i) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: BounceBtn(
            onTap: () => _answer(i),
            child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.deepPurple.shade100, borderRadius: BorderRadius.circular(15)),
              child: Text((questions[currentQ]['opts'] as List)[i] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center)))))),
      ])),
      Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _cf, blastDirectionality: BlastDirectionality.explosive)),
    ]),
  );
}

// ==========================================================
// 🔢 SEQUENCE GAME
// ==========================================================
class SequenceGame extends StatefulWidget {
  const SequenceGame({super.key});
  @override
  State<SequenceGame> createState() => _SqState();
}

class _SqState extends State<SequenceGame> {
  List<int> numbers = [];
  List<int> userOrder = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    setState(() {
      numbers = List.generate(6, (i) => i + 1)..shuffle();
      userOrder = [];
    });
  }

  void _tap(int n) {
    if (userOrder.length >= numbers.length || userOrder.contains(n)) return;
    setState(() => userOrder.add(n));
    if (userOrder.length == numbers.length) {
      if (List.generate(userOrder.length, (i) => userOrder[i] == i + 1).every((e) => e)) {
        HapticFeedback.mediumImpact();
        GameData.addCoins(8); GameData.recordCorrect(); ChildFeedback.correct(context);
        setState(() => sc += 8);
        Future.delayed(const Duration(milliseconds: 800), () { if (mounted) _gen(); });
      } else {
        HapticFeedback.heavyImpact();
        GameData.recordWrong(); ChildFeedback.tryAgain(context);
        Future.delayed(const Duration(milliseconds: 500), () { if (mounted) setState(() => userOrder = []); });
      }
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("ترتیب اعداد | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      const Text("اعداد رو از ۱ تا ۶ به ترتیب کلیک کن", style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
      const SizedBox(height: 20),
      Text("انتخاب شده: ${userOrder.join(' → ')}", style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 3, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: numbers.map((n) => BounceBtn(onTap: () { if (!userOrder.contains(n)) _tap(n); },
          child: Container(decoration: BoxDecoration(color: userOrder.contains(n) ? Colors.grey : Colors.orange, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text("$n", style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold)))))).toList())),
    ])),
  );
}

// ==========================================================
// ❓ ODD ONE OUT
// ==========================================================
class OddOneOut extends StatefulWidget {
  const OddOneOut({super.key});
  @override
  State<OddOneOut> createState() => _OoState();
}

class _OoState extends State<OddOneOut> {
  final sets = [
    {"items": ["🍎", "🍌", "🍇", "🚗"], "odd": 3},
    {"items": ["🐶", "🐱", "🦁", "🌳"], "odd": 3},
    {"items": ["🚗", "🚌", "🚲", "🍕"], "odd": 3},
    {"items": ["⚽", "🏀", "🎾", "📱"], "odd": 3},
    {"items": ["🌸", "🌺", "🌻", "🐛"], "odd": 3},
  ];
  int idx = 0, sc = 0;

  @override
  void initState() { super.initState(); sets.shuffle(); }

  void _tap(int i) {
    if (i == sets[idx]['odd']) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(5); GameData.recordCorrect(); ChildFeedback.correct(context);
      setState(() { sc += 5; idx = (idx + 1) % sets.length; });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("مورد اضافه | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      const Text("کدوم به بقیه ربطی نداره؟", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: List.generate((sets[idx]['items'] as List).length, (i) => BounceBtn(
          onTap: () => _tap(i),
          child: Container(decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text((sets[idx]['items'] as List)[i] as String, style: const TextStyle(fontSize: 80)))))))),
    ])),
  );
}

// ==========================================================
// ⚡ MATH RACE
// ==========================================================
class MathRace extends StatefulWidget {
  const MathRace({super.key});
  @override
  State<MathRace> createState() => _MrState();
}

class _MrState extends State<MathRace> {
  int n1 = 0, n2 = 0, ans = 0, sc = 0, timeLeft = 30;
  List<int> opts = [];
  Timer? _t;
  bool _gameEnded = false;

  @override
  void initState() { super.initState(); _gen(); _startTimer(); }
  @override
  void dispose() { _t?.cancel(); super.dispose(); }

  void _startTimer() {
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _gameEnded) { t.cancel(); return; }
      if (timeLeft <= 1) {
        setState(() => timeLeft = 0);
        t.cancel();
        _endGame();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void _gen() {
    final r = Random();
    setState(() {
      n1 = r.nextInt(10) + 1;
      n2 = r.nextInt(10) + 1;
      ans = n1 + n2;
      opts = {ans, ans + 1, ans - 1, ans + 2}.toList()..shuffle();
      while (opts.length < 4) opts.add(ans + Random().nextInt(5) + 3);
      opts = opts.take(4).toList()..shuffle();
    });
  }

  void _chk(int a) {
    if (_gameEnded) return;
    if (a == ans) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(2); GameData.recordCorrect(); ChildFeedback.correct(context);
      setState(() => sc++);
      _gen();
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  void _endGame() {
    if (_gameEnded || !mounted) return;
    _gameEnded = true;
    GameData.updateHighScore(sc, 'math_race');
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("⏰ زمان تموم شد!"),
      content: Text("امتیاز: $sc\nرکورد: ${GameData.mathRaceHighScore}"),
      actions: [TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(c); }, child: const Text("باشه"))],
    ));
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("مسابقه ریاضی | امتیاز: $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      LinearProgressIndicator(value: timeLeft / 30, minHeight: 15, backgroundColor: Colors.grey.shade200,
        color: timeLeft > 10 ? Colors.green : Colors.red),
      const SizedBox(height: 10),
      Text("⏱ $timeLeft ثانیه", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(gradient: G.s, borderRadius: BorderRadius.circular(20)),
        child: Text("$n1 + $n2 = ?", style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold))),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((o) => BounceBtn(onTap: () => _chk(o),
          child: Container(decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text("$o", style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)))))).toList())),
    ])),
  );
}

// ==========================================================
// 📖 STORY TIME
// ==========================================================
class StoryTime extends StatefulWidget {
  const StoryTime({super.key});
  @override
  State<StoryTime> createState() => _StTState();
}

class _StTState extends State<StoryTime> {
  final stories = [
    {"title": "خرگوش و لاک‌پشت 🐰🐢", "text": "روزی خرگوش و لاک‌پشت مسابقه دادن. خرگوش تندتر بود اما وسط راه خوابش برد. لاک‌پشت آروم آروم رفت و برنده شد.\n\n📝 درس: صبر و پشتکار مهم‌تر از سرعته!"},
    {"title": "شیر و موش 🦁🐭", "text": "شیری موشی رو نگه داشت. موش خواهش کرد ولش کنه. شیر رحم کرد. بعداً شیر تو تور گیر کرد و موش ریسمان رو جوید و نجاتش داد.\n\n📝 درس: هیچکس رو کوچک نبین!"},
    {"title": "چوپان دروغگو 👦🐺", "text": "چوپانی از سر شوخی می‌گفت گرگ اومد! مردم می‌دویدن. یه روز واقعاً گرگ اومد اما کسی باور نکرد.\n\n📝 درس: دروغ نگو حتی به شوخی!"},
    {"title": "روباه و کلاغ 🦊🐦", "text": "کلاغ پنیر داشت. روباه تعریفش کرد و گفت آواز بخون. کلاغ خواند و پنیر افتاد. روباه پنیر رو برد.\n\n📝 درس: مواظب حرف‌های چاپلوسانه باش!"},
  ];
  int idx = 0;

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("داستان‌ها")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text(stories[idx]['title']!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      Expanded(child: SingleChildScrollView(child: Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(20)),
        child: Text(stories[idx]['text']!, style: const TextStyle(fontSize: 21, height: 1.95, fontWeight: FontWeight.w500))))),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton.icon(icon: const Icon(Icons.arrow_forward), label: const Text("قبلی"),
          onPressed: () => setState(() => idx = (idx - 1 + stories.length) % stories.length)),
        ElevatedButton.icon(icon: const Icon(Icons.arrow_back), label: const Text("بعدی"),
          onPressed: () { setState(() => idx = (idx + 1) % stories.length); GameData.addCoins(5); }),
      ]),
    ])),
  );
}

// ==========================================================
// 🎵 MUSIC GAME
// ==========================================================
class MusicGame extends StatefulWidget {
  const MusicGame({super.key});
  @override
  State<MusicGame> createState() => _McState();
}

class _McState extends State<MusicGame> {
  final ms = {"پیانو":"🎹","گیتار":"🎸","ویولن":"🎻","درام":"🥁","ساکسیفون":"🎷","ترومپت":"🎺","میکروفون":"🎤","هدفون":"🎧"};
  late String tn, te;
  List<MapEntry<String, String>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = ms.entries.toList()..shuffle();
    setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(String e) {
    if (e == te) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3); GameData.recordCorrect(); ChildFeedback.correct(context);
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("سازها | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("$tn کدومه؟", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
    ])),
  );
}

// ==========================================================
// 🚀 SPACE GAME
// ==========================================================
class SpaceGame extends StatefulWidget {
  const SpaceGame({super.key});
  @override
  State<SpaceGame> createState() => _SpState();
}

class _SpState extends State<SpaceGame> {
  final sp = {"خورشید":"☀️","ماه":"🌙","زمین":"🌍","ستاره":"⭐","موشک":"🚀","سیاره":"🪐","کهکشان":"🌌","ماهواره":"🛰"};
  late String tn, te;
  List<MapEntry<String, String>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = sp.entries.toList()..shuffle();
    setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(String e) {
    if (e == te) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(4); GameData.recordCorrect(); ChildFeedback.correct(context);
      setState(() => sc += 4);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("فضا و سیارات | $sc"), backgroundColor: Colors.indigo.shade100),
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F0F1E), Color(0xFF1E1E3F)])),
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Text("$tn کدومه؟", style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
          children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
            child: Container(decoration: BoxDecoration(color: Colors.indigo.shade900, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber, width: 2)),
              child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
      ]),
    ),
  );
}

// ==========================================================
// ⚽ SPORTS GAME
// ==========================================================
class SportsGame extends StatefulWidget {
  const SportsGame({super.key});
  @override
  State<SportsGame> createState() => _SgState();
}

class _SgState extends State<SportsGame> {
  final sp = {"فوتبال":"⚽","بسکتبال":"🏀","تنیس":"🎾","والیبال":"🏐","شنا":"🏊","دو":"🏃","بوکس":"🥊","دوچرخه‌سواری":"🚴"};
  late String tn, te;
  List<MapEntry<String, String>> opts = [];
  int sc = 0;

  @override
  void initState() { super.initState(); _gen(); }

  void _gen() {
    var e = sp.entries.toList()..shuffle();
    setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); });
  }

  void _chk(String e) {
    if (e == te) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3); GameData.recordCorrect(); ChildFeedback.correct(context);
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong(); ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("ورزش‌ها | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("$tn کدومه؟", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
    ])),
  );
}

// ==========================================================
// 🎡 LUCKY WHEEL
// ==========================================================
class LuckyWheel extends StatefulWidget {
  const LuckyWheel({super.key});
  @override
  State<LuckyWheel> createState() => _LwState();
}

class _LwState extends State<LuckyWheel> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool spinning = false;
  String result = "";
  final prizes = [10, 20, 50, 5, 100, 15, 30, 25];
  late ConfettiController _cf;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _cf = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() { _ctrl.dispose(); _cf.dispose(); super.dispose(); }

  void _spin() {
    if (GameData.luckyWheelSpunToday) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("امروز چرخ رو زدی! فردا برگرد"), backgroundColor: Colors.orange));
      return;
    }
    setState(() { spinning = true; result = ""; });
    _ctrl.forward(from: 0).then((_) {
      int prize = prizes[Random().nextInt(prizes.length)];
      GameData.addCoins(prize); GameData.spinLucky(); _cf.play();
      setState(() { spinning = false; result = "🎉 $prize سکه بردی!"; });
    });
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("چرخ شانس روزانه")),
    body: Stack(children: [
      Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        RotationTransition(turns: Tween(begin: 0.0, end: 10.0).animate(_ctrl),
          child: Container(width: 250, height: 250,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: const SweepGradient(colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.pink, Colors.cyan]),
              border: Border.all(color: Colors.amber, width: 8)),
            child: const Center(child: Icon(Icons.stars, size: 80, color: Colors.white)))),
        const SizedBox(height: 30),
        Text(result, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 20),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(200, 60)),
          onPressed: spinning ? null : _spin,
          child: Text(GameData.luckyWheelSpunToday ? "فردا برگرد!" : "بچرخون! 🎡", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      ])),
      Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _cf, blastDirectionality: BlastDirectionality.explosive)),
    ]),
  );
}

// ==========================================================
// 🎨 DRAWING PAGE
// ==========================================================
class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});
  @override
  State<DrawingPage> createState() => _DrawState();
}

class _DrawState extends State<DrawingPage> {
  List<Map<String, dynamic>> strokes = [];
  List<Offset?> cur = [];
  Color col = Colors.red;
  double w = 5;
  final cl = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.black, Colors.pink, Colors.brown];

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("نقاشی"), backgroundColor: Colors.pink.shade100, actions: [
      IconButton(icon: const Icon(Icons.undo), onPressed: () { if (strokes.isNotEmpty) setState(() => strokes.removeLast()); }),
      IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => setState(() => strokes.clear())),
    ]),
    body: Column(children: [
      SizedBox(height: 60, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: cl.length,
        itemBuilder: (c, i) => GestureDetector(onTap: () => setState(() => col = cl[i]),
          child: Container(margin: const EdgeInsets.all(8), width: 40, height: 40,
            decoration: BoxDecoration(color: cl[i], shape: BoxShape.circle, border: col == cl[i] ? Border.all(color: Colors.black, width: 3) : null))))),
      Slider(value: w, min: 2, max: 20, onChanged: (v) => setState(() => w = v)),
      Expanded(child: GestureDetector(
        onPanStart: (_) => cur = [],
        onPanUpdate: (d) { RenderBox b = context.findRenderObject() as RenderBox; setState(() => cur.add(b.globalToLocal(d.globalPosition))); },
        onPanEnd: (_) {
          if (cur.isNotEmpty) {
            setState(() {
              strokes.add({'p': List<Offset?>.from(cur), 'c': col, 'w': w});
              cur = [];
            });
            GameData.progressMission('drawing');
          }
        },
        child: Container(color: Colors.white, child: CustomPaint(painter: DP(strokes, cur, col, w), size: Size.infinite)),
      )),
    ]),
  );
}

class DP extends CustomPainter {
  final List<Map<String, dynamic>> s;
  final List<Offset?> c;
  final Color cc;
  final double cw;
  DP(this.s, this.c, this.cc, this.cw);

  @override
  void paint(Canvas cv, Size sz) {
    for (var st in s) {
      Paint p = Paint()..color = st['c']..strokeCap = StrokeCap.round..strokeWidth = st['w'];
      List<Offset?> pts = st['p'];
      for (int i = 0; i < pts.length - 1; i++) {
        if (pts[i] != null && pts[i + 1] != null) cv.drawLine(pts[i]!, pts[i + 1]!, p);
      }
    }
    Paint cp = Paint()..color = cc..strokeCap = StrokeCap.round..strokeWidth = cw;
    for (int i = 0; i < c.length - 1; i++) {
      if (c[i] != null && c[i + 1] != null) cv.drawLine(c[i]!, c[i + 1]!, cp);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => true;
}

// ==========================================================
// 📊 STATS PAGE
// ==========================================================
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("آمار کامل")),
    body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      Card(color: Colors.amber.shade50, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
        Text("${GameData.coins}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
        const Text("سکه‌های کل"),
      ]))),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [
          const Icon(Icons.trending_up, color: Colors.blue), Text("لول ${GameData.level}"), Text(GameData.getLevelName(), style: const TextStyle(fontSize: 12))])))),
        Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [
          const Icon(Icons.local_fire_department, color: Colors.orange), Text("${GameData.streak} روز"), const Text("پیاپی")])))),
      ]),
      Row(children: [
        Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [
          const Icon(Icons.check_circle, color: Colors.green), Text("${GameData.totalCorrect}"), const Text("درست")])))),
        Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [
          const Icon(Icons.timer, color: Colors.purple), Text("${GameData.weeklyPlayMinutes} دقیقه"), const Text("این هفته")])))),
      ]),
      const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("مدال‌ها", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("${GameData.achievements.length} مدال کسب شده"),
        const SizedBox(height: 10),
        Wrap(spacing: 5, children: GameData.achievements.map((a) => const Chip(label: Text("🏅"), backgroundColor: Colors.amber)).toList()),
      ]))),
      const SizedBox(height: 10),
      Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("استیکرها", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("${GameData.stickers.length} استیکر خریداری شده"),
      ]))),
    ])),
  );
}

// ==========================================================
// 🏆 TROPHIES ROOM
// ==========================================================
class TrophiesRoom extends StatelessWidget {
  const TrophiesRoom({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("اتاق افتخارات")),
    body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      Card(color: Colors.amber.shade50, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        const Text("🏆 رکوردهای شما", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ListTile(leading: const Icon(Icons.speed, color: Colors.orange), title: const Text("رکورد مسابقه ریاضی"),
          trailing: Text("${GameData.mathRaceHighScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
        ListTile(leading: const Icon(Icons.quiz, color: Colors.purple), title: const Text("رکورد مسابقه"),
          trailing: Text("${GameData.quizHighScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
        ListTile(leading: const Icon(Icons.emoji_events, color: Colors.amber), title: const Text("بیشترین امتیاز"),
          trailing: Text("${GameData.highScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
      ]))),
      const SizedBox(height: 20),
      Card(color: Colors.blue.shade50, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        const Text("🎖 آمار کلی", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Text("💰 ${GameData.coins} سکه جمع کردی", style: const TextStyle(fontSize: 16)),
        Text("⭐ به لول ${GameData.level} رسیدی", style: const TextStyle(fontSize: 16)),
        Text("🔥 ${GameData.streak} روز پیاپی", style: const TextStyle(fontSize: 16)),
        Text("🎯 ${GameData.totalCorrect} جواب درست", style: const TextStyle(fontSize: 16)),
        Text("🏅 ${GameData.achievements.length} مدال", style: const TextStyle(fontSize: 16)),
        Text("🎨 ${GameData.stickers.length} استیکر", style: const TextStyle(fontSize: 16)),
      ]))),
    ])),
  );
}

// ==========================================================
// ⚙️ SETTINGS PAGE
// ==========================================================
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _StState();
}

class _StState extends State<SettingsPage> {
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("تنظیمات")),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      SwitchListTile(secondary: const Icon(Icons.volume_up), title: const Text("صداها و لرزش"), value: GameData.soundEnabled,
        onChanged: (v) { setState(() => GameData.soundEnabled = v); GameData.save(); }),
      ListTile(leading: const Icon(Icons.timer), title: Text("محدودیت زمانی: ${GameData.timeLimitMinutes} دقیقه"),
        subtitle: Slider(value: GameData.timeLimitMinutes.toDouble(), min: 15, max: 120, divisions: 7,
          onChanged: (v) { setState(() => GameData.timeLimitMinutes = v.toInt()); GameData.save(); })),
      const Divider(),
      ListTile(leading: const Icon(Icons.refresh, color: Colors.red), title: const Text("پاک کردن همه اطلاعات"),
        onTap: () => showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text("مطمئنی؟"),
          content: const Text("همه امتیازات پاک می‌شن!"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("لغو")),
            ElevatedButton(onPressed: () async {
              await GameData._p.clear(); await GameData.load(); Navigator.pop(ctx); setState(() {});
            }, child: const Text("پاک کن"))
          ]))),
    ]),
  );
}

// ==========================================================
// 🛍 STICKER SHOP
// ==========================================================
class Shop extends StatefulWidget {
  const Shop({super.key});
  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  final st = [
    {"id":"s1","e":"⭐","p":20},{"id":"s2","e":"🌟","p":30},{"id":"s3","e":"🎈","p":40},
    {"id":"s4","e":"🎁","p":50},{"id":"s5","e":"🏆","p":100},{"id":"s6","e":"👑","p":150},
    {"id":"s7","e":"💎","p":200},{"id":"s8","e":"🚀","p":80},{"id":"s9","e":"🌈","p":60}
  ];

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text("فروشگاه | ${GameData.coins} ⭐")),
    body: GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: st.length,
      itemBuilder: (c, i) {
        bool ow = GameData.stickers.contains(st[i]['id']);
        bool cb = GameData.coins >= (st[i]['p'] as int);
        return BounceBtn(
          onTap: () {
            if (!ow && cb) {
              GameData.buySticker(st[i]['id'] as String, st[i]['p'] as int);
              setState(() {});
            }
          },
          child: Container(
            decoration: BoxDecoration(color: ow ? Colors.green.shade100 : Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)]),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(st[i]['e'] as String, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 5),
              ow ? const Text("✅", style: TextStyle(fontSize: 12)) : Text("${st[i]['p']} ⭐", style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ),
        );
      },
    ),
  );
}

// ==========================================================
// 🏅 ACHIEVEMENTS PAGE
// ==========================================================
class AchPage extends StatelessWidget {
  const AchPage({super.key});
  @override
  Widget build(BuildContext c) {
    final all = [
      {"id":"math_50","t":"ریاضیدان","d":"۵۰ امتیاز ریاضی","i":"🧮"},
      {"id":"memory_king","t":"شاه حافظه","d":"بازی حافظه کامل","i":"🧠"},
      {"id":"streak_3","t":"۳ روز پیاپی","d":"۳ روز متوالی","i":"🔥"},
      {"id":"streak_7","t":"۷ روز پیاپی","d":"۷ روز متوالی","i":"🏆"},
      {"id":"streak_30","t":"۳۰ روز پیاپی","d":"۳۰ روز متوالی","i":"🏅"},
      {"id":"coin_500","t":"ثروتمند","d":"۵۰۰ سکه","i":"💰"},
      {"id":"coin_1000","t":"میلیونر","d":"۱۰۰۰ سکه","i":"💎"},
      {"id":"coin_5000","t":"مولتی‌میلیونر","d":"۵۰۰۰ سکه","i":"💠"},
      {"id":"level_3","t":"تلاشگر","d":"لول ۳","i":"⭐"},
      {"id":"level_5","t":"استاد","d":"لول ۵","i":"🌟"},
      {"id":"level_10","t":"افسانه","d":"لول ۱۰","i":"👑"},
      {"id":"level_20","t":"استاد بزرگ","d":"لول ۲۰","i":"🎖"},
      {"id":"correct_50","t":"دقیق","d":"۵۰ جواب درست","i":"🎯"},
      {"id":"correct_100","t":"ماهر","d":"۱۰۰ جواب درست","i":"🏹"},
      {"id":"correct_500","t":"استاد پاسخ","d":"۵۰۰ جواب درست","i":"🎪"},
      {"id":"collector","t":"کلکسیونر","d":"۵ استیکر","i":"🎁"},
      {"id":"mega_collector","t":"سوپر کلکسیونر","d":"۱۰ استیکر","i":"🎊"},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("مدال‌ها")),
      body: GameData.achievements.isEmpty
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("🏆", style: TextStyle(fontSize: 80)),
            Text("هنوز مدالی نداری!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]))
        : ListView.builder(padding: const EdgeInsets.all(16), itemCount: all.length,
          itemBuilder: (c, i) {
            bool u = GameData.achievements.contains(all[i]['id']);
            return Card(color: u ? Colors.amber.shade50 : Colors.grey.shade100,
              child: ListTile(
                leading: Text(u ? all[i]['i']! : "🔒", style: const TextStyle(fontSize: 30)),
                title: Text(all[i]['t']!, style: TextStyle(fontWeight: FontWeight.bold, color: u ? Colors.black : Colors.grey)),
                subtitle: Text(all[i]['d']!),
                trailing: u ? const Icon(Icons.check_circle, color: Colors.green) : null,
              ),
            );
          },
        ),
    );
  }
}

// ==========================================================
// 💳 SUBSCRIPTION PAGE
// ==========================================================
class SubPage extends StatelessWidget {
  const SubPage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("اشتراک طلایی")),
    body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.workspace_premium, size: 100, color: Colors.amber).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
      const SizedBox(height: 20),
      const Text("نسخه طلایی", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      const Text("با خرید اشتراک به تمام محتوا دسترسی پیدا کنید", textAlign: TextAlign.center),
      const SizedBox(height: 20),
      const Card(child: Column(children: [
        ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text("تمام بازی‌ها")),
        ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text("بدون محدودیت زمانی")),
        ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text("گزارش PDF")),
      ])),
      const SizedBox(height: 20),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 55)),
        onPressed: () => ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text("پرداخت آنلاین به‌زودی فعال می‌شود."))),
        child: const Text("خرید از کافه بازار (ماهانه ۴۹ هزار تومان)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      const SizedBox(height: 10),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 55)),
        onPressed: () => ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text("پرداخت آنلاین به‌زودی فعال می‌شود."))),
        child: const Text("خرید سالانه ۳۹۹ هزار تومان (صرفه‌جویی ۳۰٪)", style: TextStyle(color: Colors.white))),
    ])),
  );
}

// ==========================================================
// 📚 HELP CENTER
// ==========================================================
class HelpCenter extends StatelessWidget {
  const HelpCenter({super.key});
  final faqs = const [
    {"q": "چطور سکه بگیرم؟", "a": "با بازی کردن و جواب درست دادن به سوالات سکه می‌گیری."},
    {"q": "چطور لول‌آپ کنم؟", "a": "هر ۱۰۰ سکه که جمع کنی یک لول بالا می‌ری."},
    {"q": "استریک چیه؟", "a": "اگر هر روز وارد بشی، تعداد روزهای پیاپی حساب می‌شه."},
    {"q": "چرخ شانس چطور کار میکنه؟", "a": "هر روز یک بار می‌تونی چرخ رو بچرخونی و سکه رایگان بگیری."},
    {"q": "مدال‌ها چطور باز می‌شن؟", "a": "با انجام کارهای خاص مثل ۷ روز پیاپی، ۵۰۰ سکه و... باز می‌شن."},
    {"q": "چطور استیکر بخرم؟", "a": "برو بخش فروشگاه و با سکه‌هایی که داری استیکر بخر."},
  ];

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("مرکز راهنما")),
    body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: faqs.length,
      itemBuilder: (c, i) => Card(child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: Colors.blue),
        title: Text(faqs[i]['q']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [Padding(padding: const EdgeInsets.all(16), child: Text(faqs[i]['a']!, style: const TextStyle(fontSize: 17, height: 1.8)))],
      )),
    ),
  );
}

// ==========================================================
// ⭐ RATE APP
// ==========================================================
class RateApp extends StatefulWidget {
  const RateApp({super.key});
  @override
  State<RateApp> createState() => _RaState();
}

class _RaState extends State<RateApp> {
  int rating = 0;

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("امتیاز به برنامه")),
    body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.star, size: 100, color: Colors.amber),
      const SizedBox(height: 20),
      const Text("چقدر کودک ایران رو دوست داری؟", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      const SizedBox(height: 30),
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) => IconButton(
          icon: Icon(Icons.star, size: 45, color: i < rating ? Colors.amber : Colors.grey.shade300),
          onPressed: () => setState(() => rating = i + 1),
        )),
      ),
      const SizedBox(height: 30),
      if (rating > 0) Text(rating >= 4 ? "🎉 عالیه! ممنون از حمایتت" : "🙏 نظرت برامون مهمه", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 40),
      ElevatedButton.icon(icon: const Icon(Icons.send), label: const Text("ثبت نظر در کافه بازار"),
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), backgroundColor: Colors.amber),
        onPressed: rating > 0 ? () async {
          final opened = await launchUrl(Uri.parse("bazaar://details?id=com.example.kudakeiran"), mode: LaunchMode.externalApplication);
          if (!opened && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("امکان باز کردن کافه بازار وجود ندارد.")));
          }
        } : null),
    ])),
  );
}

// ==========================================================
// 👨‍👩‍👧 PARENT PANEL
// ==========================================================
class ParentPanel extends StatelessWidget {
  const ParentPanel({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("پنل والدین")),
    body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      Card(child: ListTile(leading: const Icon(Icons.star, color: Colors.amber), title: const Text("سکه"), trailing: Text("${GameData.coins}"))),
      Card(child: ListTile(leading: const Icon(Icons.trending_up, color: Colors.blue), title: Text("سطح (${GameData.getLevelName()})"), trailing: Text("${GameData.level}"))),
      Card(child: ListTile(leading: const Icon(Icons.local_fire_department, color: Colors.orange), title: const Text("روزهای پیاپی"), trailing: Text("${GameData.streak}"))),
      Card(child: ListTile(leading: const Icon(Icons.check, color: Colors.green), title: const Text("جواب درست"), trailing: Text("${GameData.totalCorrect}"))),
      Card(child: ListTile(leading: const Icon(Icons.close, color: Colors.red), title: const Text("جواب غلط"), trailing: Text("${GameData.totalWrong}"))),
      Card(child: ListTile(leading: const Icon(Icons.speed), title: const Text("نرخ موفقیت"), trailing: Text("${(GameData.successRate * 100).toStringAsFixed(0)}%"))),
      Card(child: ListTile(leading: const Icon(Icons.lightbulb, color: Colors.yellow), title: const Text("پیشنهاد"),
        subtitle: Text("بیشتر روی ${AI.weakSkill()} تمرین کنید"))),
      Card(child: ListTile(leading: const Icon(Icons.settings, color: Colors.blueGrey), title: const Text("تنظیمات والدین"),
        trailing: const Icon(Icons.chevron_left), onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const SettingsPage())))),
      const SizedBox(height: 20),
      const Text("📊 مهارت‌ها", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 200, child: BarChart(BarChartData(
        barGroups: GameData.skills.entries.toList().asMap().entries.map((e) => BarChartGroupData(
          x: e.key, barRods: [BarChartRodData(toY: e.value.value.toDouble(), color: Colors.indigo, width: 16)])).toList(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
            final n = ['ریاضی','الفبا','حافظه','رنگ','شکل','حیوان','شمارش','الگو','میوه','مفاهیم','لغات','بدن','ماشین','زمان','هوا','حس','شغل'];
            int idx = v.toInt();
            if (idx < 0 || idx >= n.length) return const Text('');
            return Text(n[idx], style: const TextStyle(fontSize: 8));
          })),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ))),
    ])),
  );
}

// ==========================================================
// ℹ️ ABOUT PAGE
// ==========================================================
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  Future<void> _o(String u) async { await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication); }

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: const Color(0xFF0F0F1E),
    appBar: AppBar(backgroundColor: Colors.transparent, leading: const BackButton(color: Colors.white)),
    body: SingleChildScrollView(child: Column(children: [
      const Icon(Icons.workspace_premium, size: 100, color: Colors.amber).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
      Text("Parsa Apps™", style: GoogleFonts.exo2(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w900)),
      Text("مدیر عامل: فرشاد پارسا", style: GoogleFonts.vazirmatn(fontSize: 20, color: Colors.amber, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.amber.withOpacity(0.3))),
        child: Text("گروه برنامه‌نویسی پارسا با تکیه بر دانش روز، تجربه‌ای متفاوت برای شما خلق می‌کند.",
          textAlign: TextAlign.center, style: GoogleFonts.vazirmatn(color: Colors.white70, fontSize: 16, height: 1.8)),
      )),
      const SizedBox(height: 30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _b(Icons.email, "ایمیل", Colors.red, () => _o('mailto:farshadparsa2019@gmail.com')),
        const SizedBox(width: 20),
        _b(Icons.send, "تلگرام", Colors.blue, () => _o('https://t.me/Parsaappsadmin')),
      ]),
      const SizedBox(height: 30),
      const Text("© 2024 Parsa Apps", style: TextStyle(color: Colors.amberAccent)),
      const SizedBox(height: 20),
    ])),
  );

  Widget _b(IconData i, String l, Color c, VoidCallback t) => GestureDetector(
    onTap: t,
    child: Column(children: [
      Container(padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.15), border: Border.all(color: c, width: 2)),
        child: Icon(i, color: c, size: 30)),
      const SizedBox(height: 5),
      Text(l, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
    ]),
  );
}
