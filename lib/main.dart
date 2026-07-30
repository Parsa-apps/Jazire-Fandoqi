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
// 🗄 GAME DATA (Phase 16, 34, 61)
// ==========================================================
class GameData {
  static late SharedPreferences _p;
  static int coins = 0, level = 1, streak = 0, totalCorrect = 0, totalWrong = 0, dailyMissions = 0, sessionSeconds = 0;
  static String lastLogin = '', avatar = '😊';
  static List<String> achievements = [], stickers = [];
  static Map<String, int> skills = {'math': 0, 'alphabet': 0, 'memory': 0, 'colors': 0, 'shapes': 0, 'animals': 0, 'counting': 0, 'pattern': 0, 'fruits': 0, 'concepts': 0};
  static int timeLimitMinutes = 60;
  static bool treasureOpened = false;

  static Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    coins = _p.getInt('c') ?? 0; level = _p.getInt('l') ?? 1; streak = _p.getInt('s') ?? 0;
    totalCorrect = _p.getInt('tc') ?? 0; totalWrong = _p.getInt('tw') ?? 0;
    lastLogin = _p.getString('ll') ?? ''; avatar = _p.getString('av') ?? '😊';
    dailyMissions = _p.getInt('dm') ?? 0; sessionSeconds = _p.getInt('ss') ?? 0;
    achievements = _p.getStringList('ach') ?? []; stickers = _p.getStringList('st') ?? [];
    timeLimitMinutes = _p.getInt('tl') ?? 60;
    treasureOpened = _p.getBool('tr') ?? false;
    for (var k in skills.keys) skills[k] = _p.getInt('sk_$k') ?? 0;
    _checkStreak();
  }

  static Future<void> save() async {
    await _p.setInt('c', coins); await _p.setInt('l', level); await _p.setInt('s', streak);
    await _p.setInt('tc', totalCorrect); await _p.setInt('tw', totalWrong);
    await _p.setString('ll', lastLogin); await _p.setString('av', avatar);
    await _p.setInt('dm', dailyMissions); await _p.setInt('ss', sessionSeconds);
    await _p.setStringList('ach', achievements); await _p.setStringList('st', stickers);
    await _p.setInt('tl', timeLimitMinutes); await _p.setBool('tr', treasureOpened);
    for (var k in skills.keys) await _p.setInt('sk_$k', skills[k] ?? 0);
  }

  static void _checkStreak() {
    String today = DateTime.now().toString().substring(0, 10);
    String yesterday = DateTime.now().subtract(const Duration(days: 1)).toString().substring(0, 10);
    if (lastLogin == yesterday) streak++; else if (lastLogin != today) streak = 1;
    lastLogin = today;
    // Reset daily missions if new day
    String savedDay = _p.getString('missionDay') ?? '';
    if (savedDay != today) { dailyMissions = 0; treasureOpened = false; _p.setString('missionDay', today); }
    save();
  }

  static void addCoins(int a) { coins += a; level = (coins ~/ 100) + 1; _autoAchieve(); save(); }
  static void recordCorrect() { totalCorrect++; save(); }
  static void recordWrong() { totalWrong++; save(); }
  static double get successRate => totalCorrect + totalWrong == 0 ? 0 : totalCorrect / (totalCorrect + totalWrong);
  static void addSkill(String s) { skills[s] = (skills[s] ?? 0) + 1; save(); }
  static void doMission() { dailyMissions++; save(); }
  static void unlockAch(String id) { if (!achievements.contains(id)) { achievements.add(id); save(); } }
  static void buySticker(String id, int price) { if (coins >= price && !stickers.contains(id)) { coins -= price; stickers.add(id); save(); } }

  static void _autoAchieve() {
    if (coins >= 500) unlockAch("coin_500");
    if (coins >= 1000) unlockAch("coin_1000");
    if (streak >= 7) unlockAch("streak_7");
    if (streak >= 30) unlockAch("streak_30");
    if (level >= 5) unlockAch("level_5");
    if (level >= 10) unlockAch("level_10");
    if (totalCorrect >= 100) unlockAch("correct_100");
  }

  static String getLevelName() {
    if (level >= 10) return "قهرمان آموزش 🏆"; if (level >= 7) return "نابغه کوچولو 🧠";
    if (level >= 5) return "یادگیرنده ⭐"; if (level >= 3) return "تلاشگر 💪"; return "نوآموز 🌱";
  }

  static String getMascot() {
    if (level >= 7) return "🦸"; if (level >= 5) return "🧑‍🎓"; if (level >= 3) return "🧒"; return "👶";
  }

  static bool surprise() => streak > 0 && streak % 3 == 0;
  static bool canOpenTreasure() => dailyMissions >= 3 && !treasureOpened;
}

// ==========================================================
// 🧠 AI SYSTEMS (Phase 12, 14, 19, 50)
// ==========================================================
class AI {
  static int difficulty() { if (GameData.successRate > 0.8) return 3; if (GameData.successRate > 0.5) return 2; return 1; }
  static String diffName() { switch (difficulty()) { case 3: return "سخت"; case 2: return "متوسط"; default: return "آسان"; } }
  
  static String mascotMsg() {
    if (GameData.totalCorrect == 0) return "سلام! بیا بازی کنیم! 🎮";
    if (GameData.successRate > 0.8) return "آفرین نابغه! 🌟";
    if (GameData.successRate > 0.5) return "ادامه بده عالی میشی! 💪";
    return "اشکال نداره! تمرین کن! 🎯";
  }

  static String weakSkill() {
    var sorted = GameData.skills.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    Map<String, String> names = {'math': 'ریاضی', 'alphabet': 'الفبا', 'memory': 'حافظه', 'colors': 'رنگ‌ها', 'shapes': 'اشکال', 'animals': 'حیوانات', 'counting': 'شمارش', 'pattern': 'الگو', 'fruits': 'میوه‌ها', 'concepts': 'مفاهیم'};
    return names[sorted.first.key] ?? 'همه';
  }

  static bool fatigued(int mistakes, Duration time) => mistakes > 5 && time.inMinutes > 15;
}

// ==========================================================
// 🎨 THEME
// ==========================================================
class G {
  static const p = LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)]);
  static const s = LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)]);
  static const w = LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFFB84D)]);
  static const pu = LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)]);
  static const pk = LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFF48FB1)]);
}

class BounceBtn extends StatefulWidget {
  final Widget child; final VoidCallback onTap;
  const BounceBtn({super.key, required this.child, required this.onTap});
  @override State<BounceBtn> createState() => _BounceBtnState();
}
class _BounceBtnState extends State<BounceBtn> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 150), lowerBound: 0.9, upperBound: 1.0)..value = 1.0; }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext c) => GestureDetector(
    onTapDown: (_) => _c.reverse(), onTapUp: (_) { _c.forward(); HapticFeedback.lightImpact(); widget.onTap(); }, onTapCancel: () => _c.forward(),
    child: ScaleTransition(scale: _c, child: widget.child));
}

class KudakeIranApp extends StatelessWidget {
  const KudakeIranApp({super.key});
  @override Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'کودک ایران',
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)), textTheme: GoogleFonts.vazirmatnTextTheme()),
    home: const SplashScreen());
}

// ==========================================================
// 🚀 SPLASH
// ==========================================================
class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashState(); }
class _SplashState extends State<SplashScreen> {
  @override void initState() { super.initState(); Timer(const Duration(seconds: 3), () => Navigator.pushReplacement(context, PageRouteBuilder(
    pageBuilder: (_, a, __) => const OnboardingPage(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)))); }
  @override Widget build(BuildContext c) => Scaffold(body: Container(decoration: const BoxDecoration(gradient: G.p),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.auto_awesome, size: 120, color: Colors.white).animate(onPlay: (c) => c.repeat()).scale(duration: 1000.ms).then().shake(),
      const SizedBox(height: 20),
      Text("کودک ایران", style: GoogleFonts.vazirmatn(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold)).animate().fadeIn().slideY(begin: 1),
      const Text("Parsa Apps™", style: TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 30), const CircularProgressIndicator(color: Colors.white),
    ]))));
}

// ==========================================================
// 📖 ONBOARDING
// ==========================================================
class OnboardingPage extends StatefulWidget { const OnboardingPage({super.key}); @override State<OnboardingPage> createState() => _OnboardingState(); }
class _OnboardingState extends State<OnboardingPage> {
  final PageController _ctrl = PageController(); int _page = 0;
  final _data = [
    {"i": Icons.school_rounded, "t": "یادگیری هوشمند", "d": "سختی تمرین با سطح کودک تنظیم می‌شود", "c": const Color(0xFF6C63FF)},
    {"i": Icons.videogame_asset_rounded, "t": "بازی و جایزه", "d": "سکه بگیر و لول آپ کن!", "c": const Color(0xFFFFB84D)},
    {"i": Icons.family_restroom_rounded, "t": "پنل والدین", "d": "گزارش دقیق پیشرفت فرزند", "c": const Color(0xFF4CAF50)},
  ];

  @override Widget build(BuildContext c) => Scaffold(backgroundColor: Colors.white, body: SafeArea(child: Column(children: [
    Align(alignment: Alignment.topLeft, child: TextButton(onPressed: _go, child: const Text("رد کردن"))),
    Expanded(child: PageView.builder(controller: _ctrl, onPageChanged: (i) => setState(() => _page = i), itemCount: _data.length,
      itemBuilder: (c, i) => Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(shape: BoxShape.circle, color: (_data[i]['c'] as Color).withOpacity(0.1)),
          child: Icon(_data[i]['i'] as IconData, size: 100, color: _data[i]['c'] as Color)).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 30), Text(_data[i]['t'] as String, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10), Text(_data[i]['d'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ])))),
    if (_page == _data.length - 1)
      Padding(padding: const EdgeInsets.all(30), child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), minimumSize: const Size(double.infinity, 55)),
        onPressed: _go, child: const Text("شروع ماجراجویی", style: TextStyle(color: Colors.white, fontSize: 18))))
    else Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_data.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4),
        width: _page == i ? 25 : 8, height: 8, decoration: BoxDecoration(color: _page == i ? _data[_page]['c'] as Color : Colors.grey.shade300, borderRadius: BorderRadius.circular(10))))),
      const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("به چپ بکشید", style: TextStyle(color: Colors.grey)),
        const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey).animate(onPlay: (c) => c.repeat(reverse: true)).slideX(begin: 0.5, end: -0.5)]),
      const SizedBox(height: 20),
    ]),
  ])));
  void _go() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const Dashboard()));
}

// ==========================================================
// 🏠 DASHBOARD
// ==========================================================
class Dashboard extends StatefulWidget { const Dashboard({super.key}); @override State<Dashboard> createState() => _DashState(); }
class _DashState extends State<Dashboard> {
  late ConfettiController _conf;
  late Timer _sessionTimer;
  int _sessionSec = 0;

  @override void initState() {
    super.initState();
    _conf = ConfettiController(duration: const Duration(seconds: 2));
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) { _sessionSec++; GameData.sessionSeconds++; if (_sessionSec >= GameData.timeLimitMinutes * 60) _showTimeLimit(); });
    WidgetsBinding.instance.addPostFrameCallback((_) { _checkSurprise(); _checkTreasure(); });
  }
  @override void dispose() { _conf.dispose(); _sessionTimer.cancel(); super.dispose(); }

  void _checkSurprise() { if (GameData.surprise()) showDialog(context: context, builder: (c) => AlertDialog(
    title: const Text("🎁 جایزه غافلگیرکننده!"), content: Text("${GameData.streak} روز پیاپی اومدی! ۵۰ سکه جایزه!"),
    actions: [TextButton(onPressed: () { GameData.addCoins(50); setState(() {}); Navigator.pop(c); }, child: const Text("عالیه!"))])); }

  void _checkTreasure() { if (GameData.canOpenTreasure()) showDialog(context: context, builder: (c) => AlertDialog(
    title: const Text("🎪 صندوق گنج!"), content: const Text("ماموریت‌های امروز رو کامل کردی! صندوق گنج رو باز کن!"),
    actions: [TextButton(onPressed: () { GameData.addCoins(100); GameData.treasureOpened = true; GameData.save(); _conf.play(); setState(() {}); Navigator.pop(c); }, child: const Text("باز کن! 🎁"))])); }

  void _showTimeLimit() { showDialog(context: context, builder: (c) => AlertDialog(
    title: const Text("⏰ زمان تموم شد!"), content: const Text("وقت استراحته! فردا برگرد!"),
    actions: [TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(c); }, child: const Text("باشه"))])); }

  @override Widget build(BuildContext c) => Scaffold(backgroundColor: const Color(0xFFF0F2F5), body: Stack(children: [
    CustomScrollView(slivers: [
      SliverAppBar(expandedHeight: 220, floating: false, pinned: true,
        flexibleSpace: FlexibleSpaceBar(background: Container(decoration: const BoxDecoration(gradient: G.p),
          child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(GameData.avatar, style: const TextStyle(fontSize: 40)), const SizedBox(width: 10), Text(GameData.getMascot(), style: const TextStyle(fontSize: 40))]),
            Text(GameData.getLevelName(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text("لول ${GameData.level} | ${GameData.coins} ⭐ | 🔥 ${GameData.streak} روز", style: const TextStyle(color: Colors.white70)),
          ])))),
        actions: [
          IconButton(icon: const Icon(Icons.face), onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (c) => const AvatarPage())); setState(() {}); }),
          IconButton(icon: const Icon(Icons.settings), onPressed: _parentGate),
        ]),
      // Mascot
      SliverToBoxAdapter(child: Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [const Text("🧸", style: TextStyle(fontSize: 40)), const SizedBox(width: 12), Expanded(child: Text(AI.mascotMsg()))]))),
      // Daily Missions
      SliverToBoxAdapter(child: Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Text("🎯 ماموریت امروز", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Spacer(),
            if (GameData.canOpenTreasure()) const Text("🎪 صندوق آماده!", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          _mi("۵ سوال حل کن", GameData.dailyMissions >= 5), _mi("الفبا تمرین کن", GameData.dailyMissions >= 1),
          _mi("نقاشی بکش", GameData.dailyMissions >= 2), _mi("رنگ‌ها رو یاد بگیر", GameData.dailyMissions >= 3),
        ]))),
      const SliverToBoxAdapter(child: SizedBox(height: 10)),
      // Menu Grid
      SliverGrid(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.9),
        delegate: SliverChildListDelegate([
          _m("الفبا", Icons.sort_by_alpha, G.pu, const AlphabetGame()),
          _m("اعداد", Icons.calculate, G.s, const NumberGame()),
          _m("حافظه", Icons.memory, const LinearGradient(colors: [Colors.teal, Colors.tealAccent]), const MemoryGame()),
          _m("شمارش", Icons.pin, const LinearGradient(colors: [Colors.indigo, Colors.blue]), const CountingGame()),
          _m("الگو", Icons.grid_view, const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]), const PatternGame()),
          _m("رنگ‌ها", Icons.palette, G.w, const ColorGame()),
          _m("اشکال", Icons.category, const LinearGradient(colors: [Colors.blue, Colors.lightBlue]), const ShapeGame()),
          _m("حیوانات", Icons.pets, const LinearGradient(colors: [Colors.brown, Colors.orange]), const AnimalGame()),
          _m("میوه‌ها", Icons.apple, const LinearGradient(colors: [Colors.red, Colors.redAccent]), const FruitGame()),
          _m("مفاهیم", Icons.compare_arrows, const LinearGradient(colors: [Colors.cyan, Colors.lightBlueAccent]), const ConceptGame()),
          _m("نقاشی", Icons.brush, G.pk, const DrawingPage()),
          _m("مدال‌ها", Icons.military_tech, const LinearGradient(colors: [Colors.amber, Colors.yellow]), const AchPage()),
          _m("فروشگاه", Icons.shopping_bag, const LinearGradient(colors: [Colors.red, Colors.pink]), const Shop()),
          _m("اشتراک", Icons.workspace_premium, const LinearGradient(colors: [Colors.amber, Colors.orange]), const SubPage()),
          _m("درباره ما", Icons.info, const LinearGradient(colors: [Colors.grey, Colors.blueGrey]), const AboutPage()),
        ])),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
    ]),
    Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _conf, blastDirectionality: BlastDirectionality.explosive)),
  ]));

  Widget _mi(String t, bool d) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [
    Icon(d ? Icons.check_circle : Icons.circle_outlined, color: d ? Colors.green : Colors.grey, size: 18), const SizedBox(width: 8),
    Text(t, style: TextStyle(decoration: d ? TextDecoration.lineThrough : null, fontSize: 13))]));

  Widget _m(String t, IconData i, Gradient g, Widget pg) => Padding(padding: const EdgeInsets.all(6), child: BounceBtn(
    onTap: () async { await Navigator.push(context, PageRouteBuilder(pageBuilder: (_, a, __) => pg,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(a), child: c)))); setState(() {}); },
    child: Container(decoration: BoxDecoration(gradient: g, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(i, size: 35, color: Colors.white).animate(onPlay: (c) => c.repeat()).shimmer(delay: 2.seconds),
        const SizedBox(height: 6), Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ]))));

  void _parentGate() { int n1 = Random().nextInt(10)+1, n2 = Random().nextInt(10)+1; TextEditingController ct = TextEditingController();
    showDialog(context: context, builder: (cx) => AlertDialog(title: const Text("ورود والدین"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [Text("$n1 + $n2 = ?", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        TextField(controller: ct, keyboardType: TextInputType.number, textAlign: TextAlign.center)]),
      actions: [TextButton(onPressed: () => Navigator.pop(cx), child: const Text("انصراف")),
        ElevatedButton(onPressed: () { if (int.tryParse(ct.text) == n1+n2) { Navigator.pop(cx); Navigator.push(context, MaterialPageRoute(builder: (c) => const ParentPanel())); } }, child: const Text("تایید"))])); }
}

// ==========================================================
// 🎭 AVATAR
// ==========================================================
class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("شخصیت")),
    body: GridView.builder(padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: 16, itemBuilder: (c, i) { final a = ['😊','😎','🤩','🦁','🐱','🐶','🦊','🐼','🐸','🦄','🐻','🐯','🐰','🐷','🐨','🦓'][i];
        return BounceBtn(onTap: () { GameData.avatar = a; GameData.save(); Navigator.pop(c); },
          child: Container(decoration: BoxDecoration(color: GameData.avatar == a ? Colors.purple.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(20),
            border: GameData.avatar == a ? Border.all(color: Colors.purple, width: 3) : null),
            child: Center(child: Text(a, style: const TextStyle(fontSize: 40))))); }));
}

// ==========================================================
// 🔤 ALPHABET
// ==========================================================
class AlphabetGame extends StatefulWidget { const AlphabetGame({super.key}); @override State<AlphabetGame> createState() => _AlphaState(); }
class _AlphaState extends State<AlphabetGame> {
  final l = ["ا","ب","پ","ت","ث","ج","چ","ح","خ","د","ذ","ر","ز","ژ","س","ش","ص","ض","ط","ظ","ع","غ","ف","ق","ک","گ","ل","م","ن","و","ه","ی"];
  String s = "ا";
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("الفبا"), backgroundColor: Colors.purple.shade100),
    body: Column(children: [
      Expanded(flex: 2, child: Container(margin: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: G.pu, borderRadius: BorderRadius.circular(30)),
        child: Center(child: Text(s, style: const TextStyle(fontSize: 160, color: Colors.white, fontWeight: FontWeight.bold)).animate(key: ValueKey(s)).scale()))),
      Expanded(flex: 3, child: GridView.builder(padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
        itemCount: l.length, itemBuilder: (c, i) => BounceBtn(onTap: () { setState(() => s = l[i]); GameData.addCoins(1); GameData.addSkill('alphabet'); GameData.doMission(); },
          child: Container(decoration: BoxDecoration(color: s == l[i] ? Colors.purple : Colors.white, borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)]),
            child: Center(child: Text(l[i], style: TextStyle(fontSize: 26, color: s == l[i] ? Colors.white : Colors.black, fontWeight: FontWeight.bold)))))))]));
}

// ==========================================================
// 🔢 NUMBER GAME
// ==========================================================
class NumberGame extends StatefulWidget { const NumberGame({super.key}); @override State<NumberGame> createState() => _NumState(); }
class _NumState extends State<NumberGame> {
  int n1=0,n2=0,ans=0,sc=0,mis=0; List<int> opts=[]; late ConfettiController _cf; DateTime _st = DateTime.now();
  @override void initState() { super.initState(); _cf = ConfettiController(duration: const Duration(seconds: 1)); _gen(); }
  @override void dispose() { _cf.dispose(); super.dispose(); }
  void _gen() { final r = Random(); int d = AI.difficulty(), mx = d==1?5:d==2?10:20;
    setState(() { n1=r.nextInt(mx)+1; n2=r.nextInt(mx)+1; ans=n1+n2;
      opts = {ans, ans+r.nextInt(3)+1, (ans-r.nextInt(3)-1).abs(), ans+r.nextInt(5)+2}.toList()..shuffle();
      while (opts.length < 4) opts.add(ans+Random().nextInt(10)); opts = opts.take(4).toList()..shuffle(); }); }
  void _chk(int a) {
    if (AI.fatigued(mis, DateTime.now().difference(_st))) { showDialog(context: context, builder: (c) => AlertDialog(title: const Text("🧸 استراحت کن!"),
      actions: [TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(c); }, child: const Text("باشه"))])); return; }
    if (a == ans) { HapticFeedback.mediumImpact(); _cf.play(); GameData.addCoins(5); GameData.recordCorrect(); GameData.addSkill('math'); GameData.doMission();
      setState(() => sc+=5); if (sc>=50) GameData.unlockAch("math_50"); Future.delayed(const Duration(milliseconds: 800), _gen);
    } else { HapticFeedback.heavyImpact(); mis++; GameData.recordWrong(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("دوباره!"), backgroundColor: Colors.red)); }}
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("اعداد | $sc | ${AI.diffName()}"), backgroundColor: Colors.green.shade100),
    body: Stack(children: [Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(gradient: G.s, borderRadius: BorderRadius.circular(20)),
        child: Text("$n1 + $n2 = ?", style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white))),
      const SizedBox(height: 30),
      GridView.count(shrinkWrap: true, crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((o) => BounceBtn(onTap: () => _chk(o),
          child: Container(decoration: BoxDecoration(gradient: G.w, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text("$o", style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)))))).toList())])),
      Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _cf, blastDirectionality: BlastDirectionality.explosive))]));
}

// ==========================================================
// 🧩 MEMORY
// ==========================================================
class MemoryGame extends StatefulWidget { const MemoryGame({super.key}); @override State<MemoryGame> createState() => _MemState(); }
class _MemState extends State<MemoryGame> {
  final List<String> em = ['🍎','🍌','🍇','🌸','🍎','🍌','🍇','🌸','🐶','🐱','🐶','🐱']; List<bool> rv=[]; int? fi; int mt=0;
  @override void initState() { super.initState(); em.shuffle(); rv = List.filled(em.length, false); }
  void _tap(int i) { if (rv[i]) return; HapticFeedback.lightImpact(); setState(() => rv[i]=true);
    if (fi==null) fi=i; else { if (em[fi!]==em[i]) { mt++; GameData.addCoins(10); GameData.recordCorrect(); GameData.addSkill('memory');
      if (mt==em.length~/2) GameData.unlockAch("memory_king"); fi=null;
    } else { GameData.recordWrong(); int f=fi!; fi=null; Future.delayed(const Duration(milliseconds: 600), () => setState(() { rv[f]=false; rv[i]=false; })); }}}
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("حافظه | جفت: $mt"), backgroundColor: Colors.teal.shade100),
    body: GridView.builder(padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: em.length, itemBuilder: (c, i) => BounceBtn(onTap: () => _tap(i),
        child: Container(decoration: BoxDecoration(color: rv[i]?Colors.white:Colors.teal, borderRadius: BorderRadius.circular(15)),
          child: Center(child: Text(rv[i]?em[i]:"❓", style: const TextStyle(fontSize: 40)))))));
}

// ==========================================================
// 🔢 COUNTING
// ==========================================================
class CountingGame extends StatefulWidget { const CountingGame({super.key}); @override State<CountingGame> createState() => _CountState(); }
class _CountState extends State<CountingGame> {
  int target=0, sc=0; List<int> opts=[]; String emoji='';
  final emojis = ['🍎','🌟','⚽','🎈','🌺']; 
  @override void initState() { super.initState(); _gen(); }
  void _gen() { final r = Random(); setState(() { target = r.nextInt(8)+1; emoji = emojis[r.nextInt(emojis.length)];
    opts = {target, target+1, (target-1).clamp(1,99), target+2}.toList()..shuffle(); }); }
  void _chk(int a) { if (a==target) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.recordCorrect(); GameData.addSkill('counting'); GameData.doMission();
    setState(() => sc+=3); Future.delayed(const Duration(milliseconds: 500), _gen);
  } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); }}
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("شمارش | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("چندتاست؟", style: TextStyle(fontSize: 20)),
      const SizedBox(height: 20),
      Wrap(children: List.generate(target, (_) => Text(emoji, style: const TextStyle(fontSize: 50)))),
      const SizedBox(height: 30),
      GridView.count(shrinkWrap: true, crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((o) => BounceBtn(onTap: () => _chk(o),
          child: Container(decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text("$o", style: const TextStyle(fontSize: 40, color: Colors.white)))))).toList())])));
}

// ==========================================================
// 🔷 PATTERN
// ==========================================================
class PatternGame extends StatefulWidget { const PatternGame({super.key}); @override State<PatternGame> createState() => _PatState(); }
class _PatState extends State<PatternGame> {
  List<String> pattern=[]; String answer=''; List<String> opts=[]; int sc=0;
  final sets = [['🔴','🔵','🔴','🔵','?'], ['⭐','🌙','⭐','🌙','?'], ['🟢','🟢','🟡','🟢','🟢','?'], ['🔺','🔻','🔺','🔻','?']];
  final answers = ['🔴','⭐','🟡','🔺'];
  int idx = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { setState(() { idx = Random().nextInt(sets.length); pattern = List.from(sets[idx]); answer = answers[idx];
    opts = [answer, '🟠', '🟣', '⬛']..shuffle(); }); }
  void _chk(String a) { if (a==answer) { HapticFeedback.mediumImpact(); GameData.addCoins(5); GameData.recordCorrect(); GameData.addSkill('pattern');
    setState(() => sc+=5); Future.delayed(const Duration(milliseconds: 500), _gen);
  } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); }}
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("تشخیص الگو | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("الگو رو کامل کن:", style: TextStyle(fontSize: 20)),
      const SizedBox(height: 30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: pattern.map((e) => Text(e, style: const TextStyle(fontSize: 40))).toList()),
      const SizedBox(height: 40),
      GridView.count(shrinkWrap: true, crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((o) => BounceBtn(onTap: () => _chk(o),
          child: Container(decoration: BoxDecoration(color: Colors.deepPurple.shade100, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(o, style: const TextStyle(fontSize: 50)))))).toList())])));
}

// ==========================================================
// 🌈 COLOR
// ==========================================================
class ColorGame extends StatefulWidget { const ColorGame({super.key}); @override State<ColorGame> createState() => _ColState(); }
class _ColState extends State<ColorGame> {
  final Map<String, Color> cl = {"قرمز": Colors.red, "آبی": Colors.blue, "سبز": Colors.green, "زرد": Colors.yellow, "بنفش": Colors.purple, "نارنجی": Colors.orange};
  late String tn; late Color tc; List<MapEntry<String, Color>> opts=[]; int sc=0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = cl.entries.toList()..shuffle(); setState(() { tn=e.first.key; tc=e.first.value; opts=e.take(4).toList()..shuffle(); }); }
  void _chk(Color c) { if (c==tc) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.recordCorrect(); GameData.addSkill('colors'); GameData.doMission();
    setState(() => sc+=3); Future.delayed(const Duration(milliseconds: 500), _gen);
  } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); }}
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("رنگ‌ها | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("رنگ «$tn» کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: e.value, borderRadius: BorderRadius.circular(20))))).toList()))])));
}

// ==========================================================
// 🔷 SHAPE
// ==========================================================
class ShapeGame extends StatefulWidget { const ShapeGame({super.key}); @override State<ShapeGame> createState() => _ShpState(); }
class _ShpState extends State<ShapeGame> {
  final Map<String, IconData> sh = {"دایره": Icons.circle, "مربع": Icons.square, "مثلث": Icons.change_history, "ستاره": Icons.star, "قلب": Icons.favorite};
  late String tn; late IconData ti; List<MapEntry<String, IconData>> opts=[]; int sc=0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = sh.entries.toList()..shuffle(); setState(() { tn=e.first.key; ti=e.first.value; opts=e.take(4).toList()..shuffle(); }); }
  void _chk(IconData i) { if (i==ti) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.recordCorrect(); GameData.addSkill('shapes');
    setState(() => sc+=3); Future.delayed(const Duration(milliseconds: 500), _gen);
  } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); }}
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("اشکال | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("شکل «$tn» کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue, width: 2)),
            child: Icon(e.value, size: 70, color: Colors.blue)))).toList()))])));
}

// ==========================================================
// 🐾 ANIMAL
// ==========================================================
class AnimalGame extends StatefulWidget { const AnimalGame({super.key}); @override State<AnimalGame> createState() => _AniState(); }
class _AniState extends State<AnimalGame> {
  final Map<String, String> an = {"شیر":"🦁","گربه":"🐱","سگ":"🐶","خرگوش":"🐰","فیل":"🐘","میمون":"🐵","ببر":"🐯","خرس":"🐻"};
  late String tn,te; List<MapEntry<String, String>> opts=[]; int sc=0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = an.entries.toList()..shuffle(); setState(() { tn=e.first.key; te=e.first.value; opts=e.take(4).toList()..shuffle(); }); }
  void _chk(String e) { if (e==te) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.recordCorrect(); GameData.addSkill('animals');
    setState(() => sc+=3); Future.delayed(const Duration(milliseconds: 500), _gen);
  } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); }}
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("حیوانات | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("$tn کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList()))])));
}

// ==========================================================
// 🍎 FRUITS
// ==========================================================
class FruitGame extends StatefulWidget { const FruitGame({super.key}); @override State<FruitGame> createState() => _FrtState(); }
class _FrtState extends State<FruitGame> {
  final Map<String, String> fr = {"سیب":"🍎","موز":"🍌","انگور":"🍇","پرتقال":"🍊","توت‌فرنگی":"🍓","هندوانه":"🍉","گیلاس":"🍒","آناناس":"🍍"};
  late String tn,te; List<MapEntry<String, String>> opts=[]; int sc=0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = fr.entries.toList()..shuffle(); setState(() { tn=e.first.key; te=e.first.value; opts=e.take(4).toList()..shuffle(); }); }
  void _chk(String e) { if (e==te) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.recordCorrect(); GameData.addSkill('fruits');
    setState(() => sc+=3); Future.delayed(const Duration(milliseconds: 500), _gen);
  } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); }}
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("میوه‌ها | $sc")),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text("$tn کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
      Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
          child: Container(decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList()))])));
}

// ==========================================================
// ↔ CONCEPTS (Big/Small)
// ==========================================================
class ConceptGame extends StatefulWidget { const ConceptGame({super.key}); @override State<ConceptGame> createState() => _ConState(); }
class _ConState extends State<ConceptGame> {
  String q=''; bool ansIsBig=true; int sc=0;
  final items = [{'q':'🐘 و 🐁 کدوم بزرگ‌تره؟','a':true}, {'q':'🌳 و 🌱 کدوم کوچک‌تره؟','a':false}, {'q':'🏔 و 🏠 کدوم بزرگ‌تره؟','a':true}, {'q':'🚗 و 🚲 کدوم کوچک‌تره؟','a':false}];
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var r = items[Random().nextInt(items.length)]; setState(() { q=r['q'] as String; ansIsBig=r['a'] as bool; }); }
  void _chk(bool b) { if (b==ansIsBig) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.recordCorrect(); GameData.addSkill('concepts');
    setState(() => sc+=3); Future.delayed(const Duration(milliseconds: 500), _gen);
  } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); }}
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("مفاهیم | $sc")),
    body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(q, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      const SizedBox(height: 40),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        BounceBtn(onTap: () => _chk(true), child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
          child: const Center(child: Text("بزرگ‌تر", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))))),
        BounceBtn(onTap: () => _chk(false), child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
          child: const Center(child: Text("کوچک‌تر", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))))),
      ])])));
}

// ==========================================================
// 🎨 DRAWING
// ==========================================================
class DrawingPage extends StatefulWidget { const DrawingPage({super.key}); @override State<DrawingPage> createState() => _DrawState(); }
class _DrawState extends State<DrawingPage> {
  List<Map<String, dynamic>> strokes=[]; List<Offset?> cur=[]; Color col=Colors.red; double w=5;
  final cl = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.black, Colors.pink, Colors.brown];
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("نقاشی"), backgroundColor: Colors.pink.shade100, actions: [
    IconButton(icon: const Icon(Icons.undo), onPressed: () { if (strokes.isNotEmpty) setState(() => strokes.removeLast()); }),
    IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => setState(() { strokes.clear(); GameData.doMission(); GameData.addCoins(2); }))]),
    body: Column(children: [
      SizedBox(height: 60, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: cl.length,
        itemBuilder: (c, i) => GestureDetector(onTap: () => setState(() => col=cl[i]),
          child: Container(margin: const EdgeInsets.all(8), width: 40, height: 40,
            decoration: BoxDecoration(color: cl[i], shape: BoxShape.circle, border: col==cl[i]?Border.all(color: Colors.black, width: 3):null))))),
      Slider(value: w, min: 2, max: 20, onChanged: (v) => setState(() => w=v)),
      Expanded(child: GestureDetector(
        onPanStart: (_) => cur=[], onPanUpdate: (d) { RenderBox b = context.findRenderObject() as RenderBox; setState(() => cur.add(b.globalToLocal(d.globalPosition))); },
        onPanEnd: (_) { strokes.add({'p': List<Offset?>.from(cur), 'c': col, 'w': w}); cur=[]; },
        child: Container(color: Colors.white, child: CustomPaint(painter: DP(strokes, cur, col, w), size: Size.infinite))))]));
}
class DP extends CustomPainter {
  final List<Map<String, dynamic>> s; final List<Offset?> c; final Color cc; final double cw;
  DP(this.s, this.c, this.cc, this.cw);
  @override void paint(Canvas cv, Size sz) {
    for (var st in s) { Paint p = Paint()..color=st['c']..strokeCap=StrokeCap.round..strokeWidth=st['w'];
      List<Offset?> pts=st['p']; for (int i=0;i<pts.length-1;i++) if (pts[i]!=null&&pts[i+1]!=null) cv.drawLine(pts[i]!,pts[i+1]!,p); }
    Paint cp = Paint()..color=cc..strokeCap=StrokeCap.round..strokeWidth=cw;
    for (int i=0;i<c.length-1;i++) if (c[i]!=null&&c[i+1]!=null) cv.drawLine(c[i]!,c[i+1]!,cp); }
  @override bool shouldRepaint(covariant CustomPainter o) => true;
}

// ==========================================================
// 🛍 STICKER SHOP
// ==========================================================
class Shop extends StatefulWidget { const Shop({super.key}); @override State<Shop> createState() => _ShopState(); }
class _ShopState extends State<Shop> {
  final st = [{"id":"s1","e":"⭐","p":20},{"id":"s2","e":"🌟","p":30},{"id":"s3","e":"🎈","p":40},{"id":"s4","e":"🎁","p":50},
    {"id":"s5","e":"🏆","p":100},{"id":"s6","e":"👑","p":150},{"id":"s7","e":"💎","p":200},{"id":"s8","e":"🚀","p":80},{"id":"s9","e":"🌈","p":60}];
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("فروشگاه | ${GameData.coins} ⭐")),
    body: GridView.builder(padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: st.length, itemBuilder: (c, i) { bool ow=GameData.stickers.contains(st[i]['id']); bool cb=GameData.coins>=(st[i]['p'] as int);
        return BounceBtn(onTap: () { if (!ow&&cb) { GameData.buySticker(st[i]['id'] as String, st[i]['p'] as int); setState(() {}); } },
          child: Container(decoration: BoxDecoration(color: ow?Colors.green.shade100:Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)]),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(st[i]['e'] as String, style: const TextStyle(fontSize: 40)), const SizedBox(height: 5),
              ow?const Text("✅",style:TextStyle(fontSize:12)):Text("${st[i]['p']} ⭐",style: const TextStyle(fontWeight: FontWeight.bold))]))); }));
}

// ==========================================================
// 🏅 ACHIEVEMENTS
// ==========================================================
class AchPage extends StatelessWidget { const AchPage({super.key});
  @override Widget build(BuildContext c) {
    final all = [{"id":"math_50","t":"ریاضیدان","d":"۵۰ امتیاز ریاضی","i":"🧮"},{"id":"memory_king","t":"شاه حافظه","d":"بازی حافظه کامل","i":"🧠"},
      {"id":"streak_7","t":"۷ روز پیاپی","d":"۷ روز متوالی","i":"🔥"},{"id":"streak_30","t":"۳۰ روز پیاپی","d":"۳۰ روز متوالی","i":"🏅"},
      {"id":"coin_500","t":"ثروتمند","d":"۵۰۰ سکه","i":"💰"},{"id":"coin_1000","t":"میلیونر","d":"۱۰۰۰ سکه","i":"💎"},
      {"id":"level_5","t":"استاد","d":"لول ۵","i":"⭐"},{"id":"level_10","t":"افسانه","d":"لول ۱۰","i":"🏆"},{"id":"correct_100","t":"دقیق","d":"۱۰۰ جواب درست","i":"🎯"}];
    return Scaffold(appBar: AppBar(title: const Text("مدال‌ها")),
      body: GameData.achievements.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text("🏆", style: TextStyle(fontSize: 80)), const Text("هنوز مدالی نداری!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]))
      : ListView.builder(padding: const EdgeInsets.all(16), itemCount: all.length, itemBuilder: (c, i) { bool u=GameData.achievements.contains(all[i]['id']);
        return Card(color: u?Colors.amber.shade50:Colors.grey.shade100, child: ListTile(
          leading: Text(u?all[i]['i']!:"🔒", style: const TextStyle(fontSize: 30)),
          title: Text(all[i]['t']!, style: TextStyle(fontWeight: FontWeight.bold, color: u?Colors.black:Colors.grey)),
          subtitle: Text(all[i]['d']!), trailing: u?const Icon(Icons.check_circle, color: Colors.green):null)); })); }
}

// ==========================================================
// 💳 SUBSCRIPTION PAGE
// ==========================================================
class SubPage extends StatelessWidget { const SubPage({super.key});
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("اشتراک طلایی")),
    body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.workspace_premium, size: 100, color: Colors.amber).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
      const SizedBox(height: 20), const Text("نسخه طلایی", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10), const Text("با خرید اشتراک به تمام محتوا دسترسی پیدا کنید", textAlign: TextAlign.center),
      const SizedBox(height: 20),
      const Card(child: Column(children: [ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text("تمام بازی‌ها")),
        ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text("بدون محدودیت زمانی")),
        ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text("گزارش PDF"))])),
      const SizedBox(height: 20),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 55)),
        onPressed: () {}, child: const Text("خرید از کافه بازار (ماهانه ۴۹ هزار تومان)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      const SizedBox(height: 10),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 55)),
        onPressed: () {}, child: const Text("خرید سالانه ۳۹۹ هزار تومان (صرفه‌جویی ۳۰٪)", style: TextStyle(color: Colors.white))),
    ])));
}

// ==========================================================
// 👨‍👩‍👧 PARENT
// ==========================================================
class ParentPanel extends StatelessWidget { const ParentPanel({super.key});
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("پنل والدین")),
    body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      Card(child: ListTile(leading: const Icon(Icons.star, color: Colors.amber), title: const Text("سکه"), trailing: Text("${GameData.coins}"))),
      Card(child: ListTile(leading: const Icon(Icons.trending_up, color: Colors.blue), title: Text("سطح (${GameData.getLevelName()})"), trailing: Text("${GameData.level}"))),
      Card(child: ListTile(leading: const Icon(Icons.local_fire_department, color: Colors.orange), title: const Text("روزهای پیاپی"), trailing: Text("${GameData.streak}"))),
      Card(child: ListTile(leading: const Icon(Icons.check, color: Colors.green), title: const Text("جواب درست"), trailing: Text("${GameData.totalCorrect}"))),
      Card(child: ListTile(leading: const Icon(Icons.close, color: Colors.red), title: const Text("جواب غلط"), trailing: Text("${GameData.totalWrong}"))),
      Card(child: ListTile(leading: const Icon(Icons.speed), title: const Text("نرخ موفقیت"), trailing: Text("${(GameData.successRate*100).toStringAsFixed(0)}%"))),
      Card(child: ListTile(leading: const Icon(Icons.lightbulb, color: Colors.yellow), title: const Text("پیشنهاد"), subtitle: Text("بیشتر روی ${AI.weakSkill()} تمرین کنید"))),
      const SizedBox(height: 20), const Text("📊 مهارت‌ها", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 200, child: BarChart(BarChartData(
        barGroups: GameData.skills.entries.toList().asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.value.toDouble(), color: Colors.indigo, width: 16)])).toList(),
        titlesData: FlTitlesData(leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
            final n = ['ریاضی','الفبا','حافظه','رنگ','شکل','حیوان','شمارش','الگو','میوه','مفاهیم']; return Text(n[v.toInt()%10], style: const TextStyle(fontSize: 8)); })),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)))))),
    ])));
}

// ==========================================================
// ℹ️ ABOUT
// ==========================================================
class AboutPage extends StatelessWidget { const AboutPage({super.key});
  Future<void> _o(String u) async { await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication); }
  @override Widget build(BuildContext c) => Scaffold(backgroundColor: const Color(0xFF0F0F1E),
    appBar: AppBar(backgroundColor: Colors.transparent, leading: const BackButton(color: Colors.white)),
    body: SingleChildScrollView(child: Column(children: [
      const Icon(Icons.workspace_premium, size: 100, color: Colors.amber).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
      Text("Parsa Apps™", style: GoogleFonts.exo2(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w900)),
      Text("مدیر عامل: فرشاد پارسا", style: GoogleFonts.vazirmatn(fontSize: 20, color: Colors.amber, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.amber.withOpacity(0.3))),
        child: Text("گروه برنامه‌نویسی پارسا با تکیه بر دانش روز، تجربه‌ای متفاوت برای شما خلق می‌کند.",
          textAlign: TextAlign.center, style: GoogleFonts.vazirmatn(color: Colors.white70, fontSize: 16, height: 1.8)))),
      const SizedBox(height: 30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _b(Icons.email, "ایمیل", Colors.red, () => _o('mailto:farshadparsa2019@gmail.com')),
        const SizedBox(width: 20),
        _b(Icons.send, "تلگرام", Colors.blue, () => _o('https://t.me/Parsaappsadmin'))]),
      const SizedBox(height: 30), const Text("© 2024 Parsa Apps", style: TextStyle(color: Colors.amberAccent)), const SizedBox(height: 20)])));
  Widget _b(IconData i, String l, Color c, VoidCallback t) => GestureDetector(onTap: t, child: Column(children: [
    Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.15), border: Border.all(color: c, width: 2)),
      child: Icon(i, color: c, size: 30)), const SizedBox(height: 5), Text(l, style: TextStyle(color: c, fontWeight: FontWeight.bold))]));
}
