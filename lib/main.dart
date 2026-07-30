import 'package:flutter/material.dart';
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
// 🗄 Phase 16 - Local Database Manager
// ==========================================================
class GameData {
  static late SharedPreferences _prefs;
  static int coins = 0;
  static int level = 1;
  static int streak = 0;
  static int totalCorrect = 0;
  static int totalWrong = 0;
  static String lastLoginDate = '';
  static List<String> achievements = [];
  static String avatarFace = '😊';
  static int dailyMissionsCompleted = 0;

  static Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    coins = _prefs.getInt('coins') ?? 0;
    level = _prefs.getInt('level') ?? 1;
    streak = _prefs.getInt('streak') ?? 0;
    totalCorrect = _prefs.getInt('totalCorrect') ?? 0;
    totalWrong = _prefs.getInt('totalWrong') ?? 0;
    lastLoginDate = _prefs.getString('lastLogin') ?? '';
    avatarFace = _prefs.getString('avatar') ?? '😊';
    dailyMissionsCompleted = _prefs.getInt('dailyMissions') ?? 0;
    achievements = _prefs.getStringList('achievements') ?? [];
    _checkStreak();
  }

  static Future<void> save() async {
    await _prefs.setInt('coins', coins);
    await _prefs.setInt('level', level);
    await _prefs.setInt('streak', streak);
    await _prefs.setInt('totalCorrect', totalCorrect);
    await _prefs.setInt('totalWrong', totalWrong);
    await _prefs.setString('lastLogin', lastLoginDate);
    await _prefs.setString('avatar', avatarFace);
    await _prefs.setInt('dailyMissions', dailyMissionsCompleted);
    await _prefs.setStringList('achievements', achievements);
  }

  static void _checkStreak() {
    String today = DateTime.now().toString().substring(0, 10);
    String yesterday = DateTime.now().subtract(const Duration(days: 1)).toString().substring(0, 10);
    if (lastLoginDate == yesterday) {
      streak++;
    } else if (lastLoginDate != today) {
      streak = 1;
    }
    lastLoginDate = today;
    save();
  }

  static void addCoins(int amount) { coins += amount; _checkLevelUp(); save(); }

  static void _checkLevelUp() {
    int newLevel = (coins ~/ 100) + 1;
    if (newLevel > level) { level = newLevel; }
  }

  static void recordCorrect() { totalCorrect++; save(); }
  static void recordWrong() { totalWrong++; save(); }
  static double get successRate => totalCorrect + totalWrong == 0 ? 0 : totalCorrect / (totalCorrect + totalWrong);

  static void unlockAchievement(String id) {
    if (!achievements.contains(id)) { achievements.add(id); save(); }
  }

  static void completeDailyMission() { dailyMissionsCompleted++; save(); }
}

// ==========================================================
// 🧠 Phase 14 - Adaptive Difficulty Engine
// ==========================================================
class DifficultyEngine {
  static int getDifficulty() {
    if (GameData.successRate > 0.8) return 3;
    if (GameData.successRate > 0.5) return 2;
    return 1;
  }
  static String getDifficultyName() {
    switch (getDifficulty()) {
      case 3: return "سخت";
      case 2: return "متوسط";
      default: return "آسان";
    }
  }
}

// ==========================================================
// 🧸 Phase 12 - Mascot Message System
// ==========================================================
class MascotHelper {
  static String getMessage() {
    if (GameData.totalCorrect == 0) return "سلام دوست من! بیا بازی کنیم! 🎮";
    if (GameData.successRate > 0.8) return "آفرین! تو نابغه‌ای! 🌟";
    if (GameData.successRate > 0.5) return "ادامه بده داری عالی میشی! 💪";
    return "اشکال نداره! با تمرین بهتر میشی! 🎯";
  }

  static String getWeakSkill() {
    if (GameData.successRate < 0.5) return "بازی اعداد";
    return "الفبا";
  }

  static bool isFatigued(int mistakes, Duration sessionTime) {
    return mistakes > 5 && sessionTime.inMinutes > 15;
  }
}

// ==========================================================
// 🎨 Theme & App Setup
// ==========================================================
class KudakeIranApp extends StatelessWidget {
  const KudakeIranApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'کودک ایران',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        textTheme: GoogleFonts.vazirmatnTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================================
// 🚀 Phase 52 - Cinematic Splash
// ==========================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)])),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.auto_awesome, size: 120, color: Colors.white)
                .animate(onPlay: (c) => c.repeat()).scale(duration: 1000.ms).then().shake(),
            const SizedBox(height: 20),
            Text("کودک ایران", style: GoogleFonts.vazirmatn(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold))
                .animate().fadeIn().slideY(begin: 1),
            const SizedBox(height: 10),
            Text("نسخه ${GameData.level}.0", style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.white),
          ]),
        ),
      ),
    );
  }
}

// ==========================================================
// 📖 Phase 53 - Professional Onboarding with Guide
// ==========================================================
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _pages = [
    {"icon": Icons.school_rounded, "title": "یادگیری هوشمند", "desc": "سیستم هوشمند سختی تمرین را با سطح کودک تنظیم می‌کند.", "color": const Color(0xFF6C63FF)},
    {"icon": Icons.videogame_asset_rounded, "title": "بازی و جایزه", "desc": "با هر موفقیت سکه بگیر و لول آپ کن!", "color": const Color(0xFFFFB84D)},
    {"icon": Icons.family_restroom_rounded, "title": "پنل والدین", "desc": "گزارش پیشرفت دقیق فرزندتان.", "color": const Color(0xFF4CAF50)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          Align(alignment: Alignment.topLeft, child: TextButton(onPressed: _finish, child: const Text("رد کردن"))),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pages.length,
              itemBuilder: (c, i) => Padding(
                padding: const EdgeInsets.all(30),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: (_pages[i]['color'] as Color).withOpacity(0.1)),
                    child: Icon(_pages[i]['icon'], size: 100, color: _pages[i]['color']),
                  ).animate().scale(curve: Curves.elasticOut),
                  const SizedBox(height: 30),
                  Text(_pages[i]['title'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(_pages[i]['desc'], textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ]),
              ),
            ),
          ),
          if (_currentPage == _pages.length - 1)
            Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), minimumSize: const Size(double.infinity, 55)),
                onPressed: _finish,
                child: const Text("شروع ماجراجویی", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          else
            Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 25 : 8, height: 8,
                decoration: BoxDecoration(color: _currentPage == i ? _pages[_currentPage]['color'] : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ))),
              const SizedBox(height: 15),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("به چپ بکشید", style: TextStyle(color: Colors.grey)),
                const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey).animate(onPlay: (c) => c.repeat(reverse: true)).slideX(begin: 0.5, end: -0.5),
              ]),
              const SizedBox(height: 20),
            ]),
        ]),
      ),
    );
  }
  void _finish() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const KidDashboard()));
}

// ==========================================================
// 🏠 Phase 54 - Premium Kid Dashboard
// ==========================================================
class KidDashboard extends StatefulWidget {
  const KidDashboard({super.key});
  @override
  State<KidDashboard> createState() => _KidDashboardState();
}

class _KidDashboardState extends State<KidDashboard> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }
  @override
  void dispose() { _confetti.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Stack(children: [
        CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 200, floating: false, pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)])),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 40),
                  Text(GameData.avatarFace, style: const TextStyle(fontSize: 50)),
                  Text("لول ${GameData.level} | ${GameData.coins} ⭐", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("🔥 ${GameData.streak} روز پیاپی", style: const TextStyle(color: Colors.white70)),
                ]),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.face), onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (c) => const AvatarPage()));
                setState(() {});
              }),
              IconButton(icon: const Icon(Icons.settings), onPressed: () => _parentGate()),
            ],
          ),
          // Mascot Message
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Text("🧸", style: TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(child: Text(MascotHelper.getMessage(), style: const TextStyle(fontSize: 14))),
              ]),
            ),
          ),
          // Daily Missions
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("ماموریت امروز:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _missionItem("۳ سوال ریاضی حل کن", GameData.dailyMissionsCompleted >= 3),
                _missionItem("الفبا تمرین کن", GameData.dailyMissionsCompleted >= 1),
                _missionItem("یک نقاشی بکش", GameData.dailyMissionsCompleted >= 2),
              ]),
            ),
          ),
          // Menu Grid
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            delegate: SliverChildListDelegate([
              _menuItem("الفبای شاد", Icons.sort_by_alpha, Colors.purple, const AlphabetGame()),
              _menuItem("بازی اعداد", Icons.calculate, Colors.green, const NumberGame()),
              _menuItem("بازی حافظه", Icons.memory, Colors.teal, const MemoryGame()),
              _menuItem("نقاشی کن", Icons.brush, Colors.pink, const DrawingPage()),
              _menuItem("مدال‌ها", Icons.military_tech, Colors.amber, const AchievementsPage()),
              _menuItem("درباره ما", Icons.info, Colors.orange, const AboutUsPage()),
            ]),
          ),
        ]),
        Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confetti, blastDirectionality: BlastDirectionality.explosive)),
      ]),
    );
  }

  Widget _missionItem(String text, bool done) {
    return Row(children: [
      Icon(done ? Icons.check_circle : Icons.circle_outlined, color: done ? Colors.green : Colors.grey, size: 20),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(decoration: done ? TextDecoration.lineThrough : null)),
    ]);
  }

  Widget _menuItem(String title, IconData icon, Color color, Widget page) {
    return Card(
      margin: const EdgeInsets.all(10), elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (c) => page));
          setState(() {});
        },
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 50, color: color).animate(onPlay: (c) => c.repeat()).shimmer(delay: 2.seconds),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  void _parentGate() {
    int n1 = Random().nextInt(10) + 1, n2 = Random().nextInt(10) + 1;
    TextEditingController c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("ورود والدین"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("$n1 + $n2 = ?", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        TextField(controller: c, keyboardType: TextInputType.number, textAlign: TextAlign.center),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("انصراف")),
        ElevatedButton(onPressed: () {
          if (int.tryParse(c.text) == n1 + n2) { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (c) => const ParentPanel())); }
        }, child: const Text("تایید")),
      ],
    ));
  }
}

// ==========================================================
// 🎭 Phase 25 - Avatar System
// ==========================================================
class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});
  final List<String> avatars = const ['😊', '😎', '🤩', '🦁', '🐱', '🐶', '🦊', '🐼', '🐸', '🦄', '🐻', '🐯'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("انتخاب شخصیت")),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: avatars.length,
        itemBuilder: (c, i) => GestureDetector(
          onTap: () { GameData.avatarFace = avatars[i]; GameData.save(); Navigator.pop(context); },
          child: Container(
            decoration: BoxDecoration(
              color: GameData.avatarFace == avatars[i] ? Colors.purple.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: GameData.avatarFace == avatars[i] ? Border.all(color: Colors.purple, width: 3) : null,
            ),
            child: Center(child: Text(avatars[i], style: const TextStyle(fontSize: 40))),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// 🔤 Phase 5 - Full Alphabet Game
// ==========================================================
class AlphabetGame extends StatefulWidget {
  const AlphabetGame({super.key});
  @override
  State<AlphabetGame> createState() => _AlphabetGameState();
}

class _AlphabetGameState extends State<AlphabetGame> {
  final letters = ["ا","ب","پ","ت","ث","ج","چ","ح","خ","د","ذ","ر","ز","ژ","س","ش","ص","ض","ط","ظ","ع","غ","ف","ق","ک","گ","ل","م","ن","و","ه","ی"];
  String selected = "ا";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("آموزش الفبا"), backgroundColor: Colors.purple.shade100),
      body: Column(children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.purple, width: 3)),
            child: Center(child: Text(selected, style: const TextStyle(fontSize: 180, color: Colors.purple, fontWeight: FontWeight.bold)).animate(key: ValueKey(selected)).scale()),
          ),
        ),
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
            itemCount: letters.length,
            itemBuilder: (c, i) => GestureDetector(
              onTap: () { setState(() => selected = letters[i]); GameData.addCoins(1); GameData.completeDailyMission(); },
              child: Container(
                decoration: BoxDecoration(
                  color: selected == letters[i] ? Colors.purple : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
                ),
                child: Center(child: Text(letters[i], style: TextStyle(fontSize: 28, color: selected == letters[i] ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ==========================================================
// 🔢 Phase 5+14 - Smart Number Game with Adaptive Difficulty
// ==========================================================
class NumberGame extends StatefulWidget {
  const NumberGame({super.key});
  @override
  State<NumberGame> createState() => _NumberGameState();
}

class _NumberGameState extends State<NumberGame> {
  int num1 = 0, num2 = 0, correct = 0, score = 0, mistakes = 0;
  List<int> options = [];
  late ConfettiController _confetti;
  DateTime _sessionStart = DateTime.now();

  @override
  void initState() { super.initState(); _confetti = ConfettiController(duration: const Duration(seconds: 1)); _generate(); }
  @override
  void dispose() { _confetti.dispose(); super.dispose(); }

  void _generate() {
    final r = Random();
    int diff = DifficultyEngine.getDifficulty();
    int max = diff == 1 ? 5 : diff == 2 ? 10 : 20;
    setState(() {
      num1 = r.nextInt(max) + 1; num2 = r.nextInt(max) + 1;
      correct = num1 + num2;
      options = [correct, correct + r.nextInt(3) + 1, correct - r.nextInt(3) - 1, correct + r.nextInt(5) + 2]..shuffle();
    });
  }

  void _check(int ans) {
    if (MascotHelper.isFatigued(mistakes, DateTime.now().difference(_sessionStart))) {
      showDialog(context: context, builder: (c) => AlertDialog(
        title: const Text("🧸 یه استراحت کوچولو"),
        content: const Text("خسته شدی! یه کم آب بخور و بعد برگرد بازی"),
        actions: [TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(c); }, child: const Text("باشه"))],
      ));
      return;
    }
    if (ans == correct) {
      _confetti.play();
      GameData.addCoins(5); GameData.recordCorrect(); GameData.completeDailyMission();
      setState(() => score += 5);
      if (score >= 50) GameData.unlockAchievement("math_master");
      Future.delayed(const Duration(milliseconds: 800), _generate);
    } else {
      mistakes++; GameData.recordWrong();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("دوباره تلاش کن!"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("اعداد | امتیاز: $score | سختی: ${DifficultyEngine.getDifficultyName()}"),
        backgroundColor: Colors.green.shade100,
      ),
      body: Stack(children: [
        Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
            child: Text("$num1 + $num2 = ?", style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          const SizedBox(height: 30),
          GridView.count(shrinkWrap: true, crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
            children: options.map((o) => ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () => _check(o),
              child: Text("$o", style: const TextStyle(fontSize: 40, color: Colors.white)),
            )).toList(),
          ),
        ])),
        Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confetti, blastDirectionality: BlastDirectionality.explosive)),
      ]),
    );
  }
}

// ==========================================================
// 🧩 Phase 5 - Memory Card Game
// ==========================================================
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});
  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final List<String> emojis = ['🍎','🍌','🍇','🌸','🍎','🍌','🍇','🌸','🐶','🐱','🐶','🐱'];
  List<bool> revealed = [];
  int? firstIndex;
  int matches = 0;

  @override
  void initState() { super.initState(); emojis.shuffle(); revealed = List.filled(emojis.length, false); }

  void _tap(int index) {
    if (revealed[index]) return;
    setState(() => revealed[index] = true);
    if (firstIndex == null) { firstIndex = index; }
    else {
      if (emojis[firstIndex!] == emojis[index]) {
        matches++; GameData.addCoins(10); GameData.recordCorrect();
        if (matches == emojis.length ~/ 2) { GameData.unlockAchievement("memory_king"); }
        firstIndex = null;
      } else {
        GameData.recordWrong();
        int fi = firstIndex!; firstIndex = null;
        Future.delayed(const Duration(milliseconds: 600), () { setState(() { revealed[fi] = false; revealed[index] = false; }); });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("بازی حافظه | جفت: $matches"), backgroundColor: Colors.teal.shade100),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: emojis.length,
        itemBuilder: (c, i) => GestureDetector(
          onTap: () => _tap(i),
          child: Container(
            decoration: BoxDecoration(color: revealed[i] ? Colors.white : Colors.teal, borderRadius: BorderRadius.circular(15)),
            child: Center(child: Text(revealed[i] ? emojis[i] : "❓", style: const TextStyle(fontSize: 40))),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// 🎨 Phase 5 - Professional Drawing Page
// ==========================================================
class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});
  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<Map<String, dynamic>> strokes = [];
  List<Offset?> currentStroke = [];
  Color selectedColor = Colors.red;
  double strokeWidth = 5.0;
  final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.black, Colors.pink, Colors.brown];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نقاشی کن"),
        backgroundColor: Colors.pink.shade100,
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: () { if (strokes.isNotEmpty) setState(() => strokes.removeLast()); }),
          IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => setState(() { strokes.clear(); GameData.completeDailyMission(); })),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, itemCount: colors.length,
            itemBuilder: (c, i) => GestureDetector(
              onTap: () => setState(() => selectedColor = colors[i]),
              child: Container(
                margin: const EdgeInsets.all(8), width: 40, height: 40,
                decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle,
                  border: selectedColor == colors[i] ? Border.all(color: Colors.black, width: 3) : null),
              ),
            ),
          ),
        ),
        Slider(value: strokeWidth, min: 2, max: 20, onChanged: (v) => setState(() => strokeWidth = v)),
        Expanded(
          child: GestureDetector(
            onPanStart: (_) => currentStroke = [],
            onPanUpdate: (d) { RenderBox box = context.findRenderObject() as RenderBox; setState(() => currentStroke.add(box.globalToLocal(d.globalPosition))); },
            onPanEnd: (_) { strokes.add({'points': List<Offset?>.from(currentStroke), 'color': selectedColor, 'width': strokeWidth}); currentStroke = []; },
            child: Container(color: Colors.white, child: CustomPaint(painter: MultiDrawPainter(strokes, currentStroke, selectedColor, strokeWidth), size: Size.infinite)),
          ),
        ),
      ]),
    );
  }
}

class MultiDrawPainter extends CustomPainter {
  final List<Map<String, dynamic>> strokes;
  final List<Offset?> current;
  final Color currentColor;
  final double currentWidth;
  MultiDrawPainter(this.strokes, this.current, this.currentColor, this.currentWidth);

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      Paint p = Paint()..color = stroke['color']..strokeCap = StrokeCap.round..strokeWidth = stroke['width'];
      List<Offset?> pts = stroke['points'];
      for (int i = 0; i < pts.length - 1; i++) { if (pts[i] != null && pts[i + 1] != null) canvas.drawLine(pts[i]!, pts[i + 1]!, p); }
    }
    Paint cp = Paint()..color = currentColor..strokeCap = StrokeCap.round..strokeWidth = currentWidth;
    for (int i = 0; i < current.length - 1; i++) { if (current[i] != null && current[i + 1] != null) canvas.drawLine(current[i]!, current[i + 1]!, cp); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ==========================================================
// 🏅 Phase 47 - Achievements Page
// ==========================================================
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final allAchievements = [
      {"id": "math_master", "title": "نابغه ریاضی", "desc": "۵۰ امتیاز ریاضی بگیر", "icon": "🧮"},
      {"id": "memory_king", "title": "شاه حافظه", "desc": "بازی حافظه را کامل کن", "icon": "🧠"},
      {"id": "streak_7", "title": "۷ روز پیاپی", "desc": "۷ روز متوالی وارد شو", "icon": "🔥"},
      {"id": "coin_500", "title": "ثروتمند", "desc": "۵۰۰ سکه جمع کن", "icon": "💰"},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("مدال‌های من")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allAchievements.length,
        itemBuilder: (c, i) {
          bool unlocked = GameData.achievements.contains(allAchievements[i]['id']);
          return Card(
            color: unlocked ? Colors.amber.shade50 : Colors.grey.shade100,
            child: ListTile(
              leading: Text(unlocked ? allAchievements[i]['icon']! : "🔒", style: const TextStyle(fontSize: 30)),
              title: Text(allAchievements[i]['title']!, style: TextStyle(fontWeight: FontWeight.bold, color: unlocked ? Colors.black : Colors.grey)),
              subtitle: Text(allAchievements[i]['desc']!),
              trailing: unlocked ? const Icon(Icons.check_circle, color: Colors.green) : null,
            ),
          );
        },
      ),
    );
  }
}

// ==========================================================
// 👨‍👩‍👧 Phase 55 - Parent Panel
// ==========================================================
class ParentPanel extends StatelessWidget {
  const ParentPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("پنل والدین")),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        Card(child: ListTile(leading: const Icon(Icons.star), title: const Text("مجموع سکه"), trailing: Text("${GameData.coins}"))),
        Card(child: ListTile(leading: const Icon(Icons.trending_up), title: const Text("سطح"), trailing: Text("${GameData.level}"))),
        Card(child: ListTile(leading: const Icon(Icons.local_fire_department), title: const Text("روزهای پیاپی"), trailing: Text("${GameData.streak}"))),
        Card(child: ListTile(leading: const Icon(Icons.check), title: const Text("جواب‌های درست"), trailing: Text("${GameData.totalCorrect}"))),
        Card(child: ListTile(leading: const Icon(Icons.close), title: const Text("جواب‌های غلط"), trailing: Text("${GameData.totalWrong}"))),
        Card(child: ListTile(leading: const Icon(Icons.speed), title: const Text("نرخ موفقیت"), trailing: Text("${(GameData.successRate * 100).toStringAsFixed(0)}%"))),
        Card(child: ListTile(leading: const Icon(Icons.lightbulb), title: const Text("پیشنهاد"), subtitle: Text("بیشتر روی ${MascotHelper.getWeakSkill()} تمرین کنید."))),
        const SizedBox(height: 20),
        const Text("نمودار پیشرفت", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 200, child: LineChart(LineChartData(
          lineBarsData: [LineChartBarData(spots: [FlSpot(0, 1), FlSpot(1, GameData.successRate * 5), FlSpot(2, GameData.level.toDouble()), FlSpot(3, GameData.streak.toDouble())], isCurved: true, color: Colors.indigo, barWidth: 5)],
        ))),
      ])),
    );
  }
}

// ==========================================================
// ℹ️ Phase 67 - About Us (Parsa Apps™)
// ==========================================================
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});
  Future<void> _open(String url) async { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(backgroundColor: Colors.transparent, leading: const BackButton(color: Colors.white)),
      body: SingleChildScrollView(child: Column(children: [
        const Icon(Icons.workspace_premium, size: 100, color: Colors.amber).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
        Text("Parsa Apps™", style: GoogleFonts.exo2(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w900)),
        Text("مدیر عامل: فرشاد پارسا", style: GoogleFonts.vazirmatn(fontSize: 20, color: Colors.amber, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.amber.withOpacity(0.3))),
          child: Text("گروه برنامه‌نویسی پارسا با تکیه بر دانش روز و طراحی خلاقانه، تجربه‌ای متفاوت برای شما خلق می‌کند.",
              textAlign: TextAlign.center, style: GoogleFonts.vazirmatn(color: Colors.white70, fontSize: 16, height: 1.8)),
        )),
        const SizedBox(height: 30),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _btn(Icons.email, "ایمیل", Colors.red, () => _open('mailto:farshadparsa2019@gmail.com')),
          const SizedBox(width: 20),
          _btn(Icons.send, "تلگرام", Colors.blue, () => _open('https://t.me/Parsaappsadmin')),
        ]),
        const SizedBox(height: 30),
        const Text("© 2024 Parsa Apps", style: TextStyle(color: Colors.amberAccent)),
        const SizedBox(height: 20),
      ])),
    );
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Column(children: [
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.15), border: Border.all(color: color, width: 2)),
        child: Icon(icon, color: color, size: 30)),
      const SizedBox(height: 5),
      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    ]));
  }
}
