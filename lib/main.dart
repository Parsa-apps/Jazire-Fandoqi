import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/game_data.dart';
import 'core/ai_system.dart';
import 'core/theme.dart';
import 'core/monetization.dart';
import 'widgets/common.dart';
import 'widgets/fandoghi.dart';
import 'widgets/star_display.dart';
import 'widgets/island_platform.dart';
import 'screens/home_screen.dart';
import 'screens/learning_island.dart';
import 'screens/stage_map.dart';
import 'screens/profile_screen.dart';
import 'screens/prize_box.dart';
import 'screens/celebration_page.dart';
import 'screens/subscription_page.dart';
import 'screens/shop_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameData.load();
  runApp(const KudakeIranApp());
}

class KudakeIranApp extends StatelessWidget {
  const KudakeIranApp({super.key});

  @override
  Widget build(BuildContext c) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'کودک ایران',
        theme: AppTheme.light,
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [Locale('fa', 'IR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
          final uri = settings.name ?? '';

          // Game routes
          if (uri.startsWith('/game/')) {
            final gameName = uri.replaceFirst('/game/', '');
            final gameWidget = GameRegistry.getGame(gameName);
            if (gameWidget != null) {
              return MaterialPageRoute(builder: (_) => gameWidget);
            }
          }

          // Named routes
          switch (uri) {
            case '/settings':
              return MaterialPageRoute(builder: (_) => const SettingsPage());
            case '/parent':
              return MaterialPageRoute(builder: (_) => const ParentPanel());
            case '/avatar':
              return MaterialPageRoute(builder: (_) => const AvatarPage());
            case '/stats':
              return MaterialPageRoute(builder: (_) => const StatsPage());
            case '/subscription':
              return MaterialPageRoute(builder: (_) => const SubPage());
            case '/help':
              return MaterialPageRoute(builder: (_) => const HelpCenter());
            case '/rate':
              return MaterialPageRoute(builder: (_) => const RateApp());
            case '/about':
              return MaterialPageRoute(builder: (_) => const AboutPage());
            case '/shop':
              return MaterialPageRoute(builder: (_) => const Shop());
            case '/achievements':
              return MaterialPageRoute(builder: (_) => const AchPage());
            case '/trophies':
              return MaterialPageRoute(builder: (_) => const TrophiesRoom());
            default:
              return MaterialPageRoute(
                  builder: (_) => const SplashScreen());
          }
        },
      );
}

// ==========================================================
// 🎮 GAME REGISTRY
// ==========================================================
class GameRegistry {
  static Widget? getGame(String name) {
    switch (name) {
      case 'الفبا':
        return const AlphabetGame();
      case 'اعداد':
        return const NumberGame();
      case 'شمارش':
        return const CountingGame();
      case 'رنگ‌ها':
        return const ColorGame();
      case 'اشکال':
        return const ShapeGame();
      case 'مفاهیم':
        return const ConceptGame();
      case 'لغات':
        return const VocabGame();
      case 'حافظه':
        return const MemoryGame();
      case 'الگو':
        return const PatternGame();
      case 'مسابقه':
        return const QuizMaster();
      case 'ترتیب':
        return const SequenceGame();
      case 'مورد اضافه':
        return const OddOneOut();
      case 'مسابقه ریاضی':
        return const MathRace();
      case 'چرخ شانس':
        return const LuckyWheel();
      case 'حیوانات':
        return const AnimalGame();
      case 'میوه‌ها':
        return const FruitGame();
      case 'بدن':
        return const BodyGame();
      case 'وسایل نقلیه':
        return const VehicleGame();
      case 'زمان':
        return const TimeGame();
      case 'آب و هوا':
        return const WeatherGame();
      case 'احساسات':
        return const EmotionGame();
      case 'شغل‌ها':
        return const JobGame();
      case 'فضا':
        return const SpaceGame();
      case 'ورزش‌ها':
        return const SportsGame();
      case 'داستان':
        return const StoryTime();
      case 'سازها':
        return const MusicGame();
      case 'نقاشی':
        return const DrawingPage();
      // Stage map titles
      case 'شروع ماجرا':
        return const AlphabetGame();
      case 'حروف الفبا':
        return const AlphabetGame();
      case 'اعداد جادویی':
        return const NumberGame();
      case 'رنگین‌کمان':
        return const ColorGame();
      case 'جنگل حیوانات':
        return const AnimalGame();
      case 'شهر فکری':
        return const MemoryGame();
      case 'آسمان دانش':
        return const SpaceGame();
      case 'قصر قهرمان':
        return const QuizMaster();
      // Island game names
      case 'جوایز':
        return const TrophiesRoom();
      case 'مدال‌ها':
        return const AchPage();
      case 'فروشگاه':
        return const Shop();
      case 'آمار':
        return const StatsPage();
      default:
        return null;
    }
  }
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
          pageBuilder: (_, a, __) => GameData.onboardingSeen
              ? const HomeScreen()
              : const OnboardingPage(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: Gradients.primary),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Fandoghi(size: 100, animate: true, showBubble: false),
                const SizedBox(height: 20),
                Text(
                  "کودک ایران",
                  style: GoogleFonts.vazirmatn(
                      fontSize: 45,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ).animate().fadeIn().slideY(begin: 1),
                const Text("Parsa Apps™",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
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
            Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                    onPressed: _go, child: const Text("رد کردن"))),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: 4,
                itemBuilder: (c, i) {
                  if (i == 0) {
                    return _fandoghiIntro();
                  } else if (i == 1) {
                    return _featurePage(
                      Icons.videogame_asset_rounded,
                      "بازی و جایزه",
                      "سکه و ستاره بگیر و لول آپ کن!",
                      const Color(0xFFFFB84D),
                    );
                  } else if (i == 2) {
                    return _featurePage(
                      Icons.family_restroom_rounded,
                      "پنل والدین",
                      "گزارش دقیق پیشرفت فرزند",
                      const Color(0xFF4CAF50),
                    );
                  } else {
                    return _profileForm();
                  }
                },
              ),
            ),
            if (_page == 3)
              Padding(
                padding: const EdgeInsets.all(30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      minimumSize: const Size(double.infinity, 55)),
                  onPressed: _go,
                  child: const Text("شروع ماجراجویی 🌟",
                      style: TextStyle(
                          color: Colors.white, fontSize: 18)),
                ),
              )
            else
              Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _page == i ? 25 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _page == i
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )),
                ),
                const SizedBox(height: 20),
              ]),
          ]),
        ),
      );

  Widget _fandoghiIntro() => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Fandoghi(size: 120, animate: true, showBubble: false)
                .animate()
                .scale(curve: Curves.elasticOut),
            const SizedBox(height: 20),
            const Text(
              'سلام! من فندقی‌ام! 🌰',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'راهنمای تو در دنیای یادگیری!\nبا هم بازی می‌کنیم، یاد می‌گیریم و ستاره جمع می‌کنیم!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.6),
            ),
          ],
        ),
      );

  Widget _featurePage(
          IconData icon, String title, String desc, Color color) =>
      Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1)),
              child: Icon(icon, size: 100, color: color),
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 30),
            Text(title,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(desc,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );

  Widget _profileForm() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('سلام دوست کوچولو! 👋',
                  style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('بیا شخصیت خودت رو بسازیم.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17)),
              const SizedBox(height: 20),
              TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      labelText: 'اسمت چیه؟',
                      hintText: 'مثلاً آوا',
                      prefixIcon: const Icon(Icons.face_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18)))),
              const SizedBox(height: 18),
              const Align(
                  alignment: Alignment.centerRight,
                  child: Text('چند سالته؟',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 8,
                  children: List.generate(8, (i) {
                    final age = i + 3;
                    return ChoiceChip(
                        label: Text('$age سال',
                            style: const TextStyle(fontSize: 16)),
                        selected: _selectedAge == age,
                        onSelected: (_) =>
                            setState(() => _selectedAge = age));
                  })),
              const SizedBox(height: 18),
              const Align(
                  alignment: Alignment.centerRight,
                  child: Text('آواتار مورد علاقه‌ات',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: ['😊', '😎', '🤩', '🦁', '🐱', '🦊', '🐼', '🦄']
                      .map((avatar) => GestureDetector(
                            onTap: () =>
                                setState(() => GameData.avatar = avatar),
                            child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 180),
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: GameData.avatar == avatar
                                        ? const Color(0xFFE7E4FF)
                                        : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: GameData.avatar == avatar
                                            ? const Color(0xFF6C63FF)
                                            : Colors.transparent,
                                        width: 2)),
                                child: Text(avatar,
                                    style:
                                        const TextStyle(fontSize: 29))),
                          ))
                      .toList()),
            ]),
      );

  void _go() {
    GameData.childName = _nameController.text.trim().isEmpty
        ? 'قهرمان کوچولو'
        : _nameController.text.trim();
    GameData.childAge = _selectedAge;
    GameData.onboardingSeen = true;
    GameData.save();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (c) => const HomeScreen()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameController.dispose();
    super.dispose();
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
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10),
          itemCount: 16,
          itemBuilder: (c, i) {
            final a = [
              '😊', '😎', '🤩', '🦁', '🐱', '🐶', '🦊', '🐼',
              '🐸', '🦄', '🐻', '🐯', '🐰', '🐷', '🐨', '🦓'
            ][i];
            return BounceBtn(
              onTap: () {
                GameData.avatar = a;
                GameData.save();
                Navigator.pop(c);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: GameData.avatar == a
                      ? Colors.purple.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: GameData.avatar == a
                      ? Border.all(color: Colors.purple, width: 3)
                      : null,
                ),
                child: Center(
                    child:
                        Text(a, style: const TextStyle(fontSize: 40))),
              ),
            );
          },
        ),
      );
}

// ==========================================================
// ALL GAME IMPLEMENTATIONS (preserved from original)
// ==========================================================

// 🔤 ALPHABET GAME
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
        appBar: AppBar(
            title: const Text("الفبا"),
            backgroundColor: Colors.purple.shade100),
        body: Column(children: [
          Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: Gradients.purple,
                    borderRadius: BorderRadius.circular(30)),
                child: Center(
                    child: Text(s,
                        style: const TextStyle(
                            fontSize: 160,
                            color: Colors.white,
                            fontWeight: FontWeight.bold))
                        .animate(key: ValueKey(s))
                        .scale()),
              )),
          Expanded(
              flex: 3,
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8),
                itemCount: l.length,
                itemBuilder: (c, i) => BounceBtn(
                  onTap: () {
                    setState(() => s = l[i]);
                    GameData.addCoins(1);
                    GameData.addStars(1);
                    GameData.addSkill('alphabet');
                    GameData.progressMission('alphabet');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          s == l[i] ? Colors.purple : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5)
                      ],
                    ),
                    child: Center(
                        child: Text(l[i],
                            style: TextStyle(
                                fontSize: 26,
                                color: s == l[i]
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold))),
                  ),
                ),
              )),
        ]),
      );
}

// 🔢 NUMBER GAME
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
  void initState() {
    super.initState();
    _cf = ConfettiController(duration: const Duration(seconds: 1));
    _gen();
  }

  @override
  void dispose() {
    _cf.dispose();
    super.dispose();
  }

  void _gen() {
    final r = Random();
    int d = AI.difficulty(),
        mx = d == 1 ? 5 : d == 2 ? 10 : 20;
    setState(() {
      n1 = r.nextInt(mx) + 1;
      n2 = r.nextInt(mx) + 1;
      ans = n1 + n2;
      opts = {
        ans,
        ans + r.nextInt(3) + 1,
        (ans - r.nextInt(3) - 1).abs(),
        ans + r.nextInt(5) + 2
      }.toList()
        ..shuffle();
      while (opts.length < 4) opts.add(ans + Random().nextInt(10));
      opts = opts.take(4).toList()..shuffle();
    });
  }

  void _chk(int a) {
    if (AI.fatigued(mis, DateTime.now().difference(_st))) {
      showDialog(
          context: context,
          builder: (c) => AlertDialog(
                title: const Text("🧸 استراحت کن!"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(c);
                        Navigator.pop(c);
                      },
                      child: const Text("باشه"))
                ],
              ));
      return;
    }
    if (a == ans) {
      HapticFeedback.mediumImpact();
      _cf.play();
      GameData.addCoins(5);
      GameData.addStars(1);
      GameData.recordCorrect();
      ChildFeedback.correct(context);
      GameData.addSkill('math');
      GameData.progressMission('questions');
      setState(() => sc += 5);
      if (sc >= 50) GameData.unlockAch("math_50");
      Future.delayed(const Duration(milliseconds: 800),
          () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      mis++;
      GameData.recordWrong();
      ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
            title: Text("اعداد | $sc | ${AI.diffName()}"),
            backgroundColor: Colors.green.shade100),
        body: Stack(children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                            gradient: Gradients.success,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text("$n1 + $n2 = ?",
                            style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
                    const SizedBox(height: 30),
                    GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        children: opts
                            .map((o) => BounceBtn(
                                onTap: () => _chk(o),
                                child: Container(
                                    decoration: BoxDecoration(
                                        gradient: Gradients.warning,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Center(
                                        child: Text("$o",
                                            style: const TextStyle(
                                                fontSize: 40,
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold))))))
                            .toList()),
                  ])),
          Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                  confettiController: _cf,
                  blastDirectionality: BlastDirectionality.explosive)),
        ]),
      );
}

// 🧩 MEMORY GAME
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});
  @override
  State<MemoryGame> createState() => _MemState();
}

class _MemState extends State<MemoryGame> {
  final List<String> em = [
    '🍎', '🍌', '🍇', '🌸', '🍎', '🍌', '🍇', '🌸',
    '🐶', '🐱', '🐶', '🐱'
  ];
  List<bool> rv = [];
  int? fi;
  int mt = 0;

  @override
  void initState() {
    super.initState();
    em.shuffle();
    rv = List.filled(em.length, false);
  }

  void _tap(int i) {
    if (rv[i]) return;
    HapticFeedback.lightImpact();
    setState(() => rv[i] = true);
    if (fi == null) {
      fi = i;
    } else {
      if (em[fi!] == em[i]) {
        mt++;
        GameData.addCoins(10);
        GameData.addStars(2);
        GameData.recordCorrect();
        ChildFeedback.correct(context);
        GameData.addSkill('memory');
        if (mt == em.length ~/ 2) GameData.unlockAch("memory_king");
        fi = null;
      } else {
        GameData.recordWrong();
        ChildFeedback.tryAgain(context);
        int f = fi!;
        fi = null;
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() { rv[f] = false; rv[i] = false; });
        });
      }
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(
            title: Text("حافظه | جفت: $mt"),
            backgroundColor: Colors.teal.shade100),
        body: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10),
          itemCount: em.length,
          itemBuilder: (c, i) => BounceBtn(
            onTap: () => _tap(i),
            child: Container(
              decoration: BoxDecoration(
                  color: rv[i] ? Colors.white : Colors.teal,
                  borderRadius: BorderRadius.circular(15)),
              child: Center(
                  child: Text(rv[i] ? em[i] : "❓",
                      style: const TextStyle(fontSize: 40))),
            ),
          ),
        ),
      );
}

// 🔢 COUNTING GAME
class CountingGame extends StatefulWidget {
  const CountingGame({super.key});
  @override
  State<CountingGame> createState() => _CountState();
}

class _CountState extends State<CountingGame> {
  int target = 0, sc = 0;
  List<int> opts = [];
  String emoji = '';
  final emojis = ['🍎', '🌟', '⚽', '🎈', '🌺'];

  @override
  void initState() {
    super.initState();
    _gen();
  }

  void _gen() {
    final r = Random();
    setState(() {
      target = r.nextInt(8) + 1;
      emoji = emojis[r.nextInt(emojis.length)];
      opts = {
        target,
        target + 1,
        (target - 1).clamp(1, 99).toInt(),
        target + 2
      }.toList()
        ..shuffle();
    });
  }

  void _chk(int a) {
    if (a == target) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3);
      GameData.addStars(1);
      GameData.recordCorrect();
      ChildFeedback.correct(context);
      GameData.addSkill('counting');
      GameData.progressMission('questions');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500),
          () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong();
      ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text("شمارش | $sc")),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("چندتاست؟",
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  Wrap(
                      children: List.generate(target,
                          (_) => Text(emoji, style: const TextStyle(fontSize: 50)))),
                  const SizedBox(height: 30),
                  GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: opts
                          .map((o) => BounceBtn(
                              onTap: () => _chk(o),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  child: Center(
                                      child: Text("$o",
                                          style: const TextStyle(
                                              fontSize: 40,
                                              color: Colors.white))))))
                          .toList()),
                ])),
      );
}

// 🔷 PATTERN GAME
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
  final sets = [
    ['🔴', '🔵', '🔴', '🔵', '?'],
    ['⭐', '🌙', '⭐', '🌙', '?'],
    ['🟢', '🟢', '🟡', '🟢', '🟢', '?'],
    ['🔺', '🔻', '🔺', '🔻', '?']
  ];
  final answers = ['🔴', '⭐', '🟡', '🔺'];
  int idx = 0;

  @override
  void initState() {
    super.initState();
    _gen();
  }

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
      GameData.addCoins(5);
      GameData.addStars(1);
      GameData.recordCorrect();
      ChildFeedback.correct(context);
      GameData.addSkill('pattern');
      setState(() => sc += 5);
      Future.delayed(const Duration(milliseconds: 500),
          () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong();
      ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text("تشخیص الگو | $sc")),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("الگو رو کامل کن:",
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pattern
                          .map((e) =>
                              Text(e, style: const TextStyle(fontSize: 40)))
                          .toList()),
                  const SizedBox(height: 40),
                  GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: opts
                          .map((o) => BounceBtn(
                              onTap: () => _chk(o),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade100,
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  child: Center(
                                      child: Text(o,
                                          style: const TextStyle(
                                              fontSize: 50))))))
                          .toList()),
                ])),
      );
}

// 🌈 COLOR GAME
class ColorGame extends StatefulWidget {
  const ColorGame({super.key});
  @override
  State<ColorGame> createState() => _ColState();
}

class _ColState extends State<ColorGame> {
  final Map<String, Color> cl = {
    "قرمز": Colors.red,
    "آبی": Colors.blue,
    "سبز": Colors.green,
    "زرد": Colors.yellow,
    "بنفش": Colors.purple,
    "نارنجی": Colors.orange
  };
  late String tn;
  late Color tc;
  List<MapEntry<String, Color>> opts = [];
  int sc = 0;

  @override
  void initState() {
    super.initState();
    _gen();
  }

  void _gen() {
    var e = cl.entries.toList()..shuffle();
    setState(() {
      tn = e.first.key;
      tc = e.first.value;
      opts = e.take(4).toList()..shuffle();
    });
  }

  void _chk(Color c) {
    if (c == tc) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3);
      GameData.addStars(1);
      GameData.recordCorrect();
      ChildFeedback.correct(context);
      GameData.addSkill('colors');
      GameData.progressMission('colors');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500),
          () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong();
      ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text("رنگ‌ها | $sc")),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Text("رنگ «$tn» کدومه؟",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: opts
                          .map((e) => BounceBtn(
                              onTap: () => _chk(e.value),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: e.value,
                                      borderRadius:
                                          BorderRadius.circular(20)))))
                          .toList())),
            ])),
      );
}

// 🔷 SHAPE GAME
class ShapeGame extends StatefulWidget {
  const ShapeGame({super.key});
  @override
  State<ShapeGame> createState() => _ShpState();
}

class _ShpState extends State<ShapeGame> {
  final Map<String, IconData> sh = {
    "دایره": Icons.circle,
    "مربع": Icons.square,
    "مثلث": Icons.change_history,
    "ستاره": Icons.star,
    "قلب": Icons.favorite
  };
  late String tn;
  late IconData ti;
  List<MapEntry<String, IconData>> opts = [];
  int sc = 0;

  @override
  void initState() {
    super.initState();
    _gen();
  }

  void _gen() {
    var e = sh.entries.toList()..shuffle();
    setState(() {
      tn = e.first.key;
      ti = e.first.value;
      opts = e.take(4).toList()..shuffle();
    });
  }

  void _chk(IconData i) {
    if (i == ti) {
      HapticFeedback.mediumImpact();
      GameData.addCoins(3);
      GameData.addStars(1);
      GameData.recordCorrect();
      ChildFeedback.correct(context);
      GameData.addSkill('shapes');
      setState(() => sc += 3);
      Future.delayed(const Duration(milliseconds: 500),
          () { if (mounted) _gen(); });
    } else {
      HapticFeedback.heavyImpact();
      GameData.recordWrong();
      ChildFeedback.tryAgain(context);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: Text("اشکال | $sc")),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Text("شکل «$tn» کدومه؟",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: opts
                          .map((e) => BounceBtn(
                              onTap: () => _chk(e.value),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.blue, width: 2)),
                                  child: Icon(e.value,
                                      size: 70, color: Colors.blue))))
                          .toList())),
            ])),
      );
}

// Remaining games - compact versions
class AnimalGame extends StatefulWidget {
  const AnimalGame({super.key});
  @override
  State<AnimalGame> createState() => _AniState();
}
class _AniState extends State<AnimalGame> {
  final Map<String, String> an = {"شیر":"🦁","گربه":"🐱","سگ":"🐶","خرگوش":"🐰","فیل":"🐘","میمون":"🐵","ببر":"🐯","خرس":"🐻"};
  late String tn, te; List<MapEntry<String, String>> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = an.entries.toList()..shuffle(); setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); }); }
  void _chk(String e) {
    if (e == te) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('animals'); setState(() => sc += 3); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); }
    else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); }
  }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("حیوانات | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    Text("$tn کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
      children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value),
        child: Container(decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
          child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
  ])));
}

class FruitGame extends StatefulWidget {
  const FruitGame({super.key});
  @override State<FruitGame> createState() => _FrtState();
}
class _FrtState extends State<FruitGame> {
  final Map<String, String> fr = {"سیب":"🍎","موز":"🍌","انگور":"🍇","پرتقال":"🍊","توت‌فرنگی":"🍓","هندوانه":"🍉","گیلاس":"🍒","آناناس":"🍍"};
  late String tn, te; List<MapEntry<String, String>> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = fr.entries.toList()..shuffle(); setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); }); }
  void _chk(String e) {
    if (e == te) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('fruits'); setState(() => sc += 3); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); }
    else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); }
  }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("میوه‌ها | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    Text("$tn کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
      children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value), child: Container(decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
  ])));
}

class ConceptGame extends StatefulWidget { const ConceptGame({super.key}); @override State<ConceptGame> createState() => _ConState(); }
class _ConState extends State<ConceptGame> {
  String q = ''; bool ansIsBig = true; int sc = 0;
  final items = [{'q': '🐘 و 🐁 کدوم بزرگ‌تره؟', 'a': true}, {'q': '🌳 و 🌱 کدوم کوچک‌تره؟', 'a': false}, {'q': '🏔 و 🏠 کدوم بزرگ‌تره؟', 'a': true}, {'q': '🚗 و 🚲 کدوم کوچک‌تره؟', 'a': false}];
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var r = items[Random().nextInt(items.length)]; setState(() { q = r['q'] as String; ansIsBig = r['a'] as bool; }); }
  void _chk(bool b) { if (b == ansIsBig) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('concepts'); setState(() => sc += 3); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("مفاهیم | $sc")), body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(q, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 40),
    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      BounceBtn(onTap: () => _chk(true), child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)), child: const Center(child: Text("بزرگ‌تر", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))))),
      BounceBtn(onTap: () => _chk(false), child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)), child: const Center(child: Text("کوچک‌تر", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))))),
    ]),
  ])));
}

class VocabGame extends StatefulWidget { const VocabGame({super.key}); @override State<VocabGame> createState() => _VocState(); }
class _VocState extends State<VocabGame> {
  final vc = {"سیب":"Apple","کتاب":"Book","خانه":"House","آب":"Water","درخت":"Tree","خورشید":"Sun","ماه":"Moon","گل":"Flower","مدرسه":"School","دوست":"Friend"};
  late String tn, ta; List<String> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = vc.entries.toList()..shuffle(); setState(() { tn = e.first.key; ta = e.first.value; opts = e.take(4).map((x) => x.value).toList()..shuffle(); }); }
  void _chk(String a) { if (a == ta) { HapticFeedback.mediumImpact(); GameData.addCoins(5); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('vocab'); setState(() => sc += 5); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("لغات | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(gradient: Gradients.purple, borderRadius: BorderRadius.circular(20)), child: Text(tn, style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold))),
    const SizedBox(height: 20), const Text("انگلیسی این کلمه چیست؟", style: TextStyle(fontSize: 16)), const SizedBox(height: 20),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((o) => BounceBtn(onTap: () => _chk(o), child: Container(decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(o, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)))))).toList())),
  ])));
}

// Body, Vehicle, Time, Weather, Emotion, Job, Space, Sports games (compact)
class BodyGame extends StatefulWidget { const BodyGame({super.key}); @override State<BodyGame> createState() => _BdyState(); }
class _BdyState extends State<BodyGame> {
  final bp = {"چشم":"👁","دهان":"👄","گوش":"👂","دست":"✋","پا":"🦵","دماغ":"👃","مغز":"🧠","قلب":"❤️"};
  late String tn, te; List<MapEntry<String, String>> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = bp.entries.toList()..shuffle(); setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); }); }
  void _chk(String e) { if (e == te) { HapticFeedback.mediumImpact(); GameData.addCoins(4); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('body'); setState(() => sc += 4); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("اعضای بدن | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ Text("«$tn» کدومه؟", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value), child: Container(decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
  ])));
}

class VehicleGame extends StatefulWidget { const VehicleGame({super.key}); @override State<VehicleGame> createState() => _VhState(); }
class _VhState extends State<VehicleGame> {
  final vh = {"ماشین":"🚗","اتوبوس":"🚌","دوچرخه":"🚲","هواپیما":"✈️","قطار":"🚂","کشتی":"🚢","موتور":"🏍","بالگرد":"🚁"};
  late String tn, te; List<MapEntry<String, String>> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = vh.entries.toList()..shuffle(); setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); }); }
  void _chk(String e) { if (e == te) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('vehicles'); setState(() => sc += 3); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("وسایل نقلیه | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ Text("$tn کدومه؟", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value), child: Container(decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
  ])));
}

class TimeGame extends StatefulWidget { const TimeGame({super.key}); @override State<TimeGame> createState() => _TmState(); }
class _TmState extends State<TimeGame> {
  final days = ["شنبه","یکشنبه","دوشنبه","سه‌شنبه","چهارشنبه","پنج‌شنبه","جمعه"];
  final months = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور","مهر","آبان","آذر","دی","بهمن","اسفند"];
  bool isDayMode = true; late String question; late int correctIdx; List<String> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { isDayMode = Random().nextBool(); var list = isDayMode ? days : months; setState(() { correctIdx = Random().nextInt(list.length); question = isDayMode ? "روز ${correctIdx + 1}م هفته چیه؟" : "ماه ${correctIdx + 1}م سال چیه؟"; opts = [list[correctIdx]]; while (opts.length < 4) { String r = list[Random().nextInt(list.length)]; if (!opts.contains(r)) opts.add(r); } opts.shuffle(); }); }
  void _chk(String a) { var list = isDayMode ? days : months; if (a == list[correctIdx]) { HapticFeedback.mediumImpact(); GameData.addCoins(4); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('time'); setState(() => sc += 4); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("روزها و ماه‌ها | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(gradient: Gradients.warning, borderRadius: BorderRadius.circular(20)), child: Text(question, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
    const SizedBox(height: 30), Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((o) => BounceBtn(onTap: () => _chk(o), child: Container(decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(o, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)))))).toList())),
  ])));
}

class WeatherGame extends StatefulWidget { const WeatherGame({super.key}); @override State<WeatherGame> createState() => _WtState(); }
class _WtState extends State<WeatherGame> {
  final wt = {"آفتابی":"☀️","بارانی":"🌧","برفی":"❄️","ابری":"☁️","طوفانی":"⛈","رنگین‌کمان":"🌈","بادی":"💨","مه":"🌫"};
  late String tn, te; List<MapEntry<String, String>> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = wt.entries.toList()..shuffle(); setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); }); }
  void _chk(String e) { if (e == te) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('weather'); setState(() => sc += 3); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("آب و هوا | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ Text("هوای «$tn» کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value), child: Container(decoration: BoxDecoration(color: Colors.cyan.shade100, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
  ])));
}

class EmotionGame extends StatefulWidget { const EmotionGame({super.key}); @override State<EmotionGame> createState() => _EmState(); }
class _EmState extends State<EmotionGame> {
  final em = {"خوشحال":"😄","غمگین":"😢","عصبانی":"😡","تعجب":"😲","خواب‌آلود":"😴","عاشق":"😍","ترسیده":"😱","خجالتی":"😊"};
  late String tn, te; List<MapEntry<String, String>> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = em.entries.toList()..shuffle(); setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); }); }
  void _chk(String e) { if (e == te) { HapticFeedback.mediumImpact(); GameData.addCoins(4); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('emotions'); setState(() => sc += 4); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("احساسات | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ Text("چهره «$tn» کدومه؟", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value), child: Container(decoration: BoxDecoration(color: Colors.yellow.shade100, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
  ])));
}

class JobGame extends StatefulWidget { const JobGame({super.key}); @override State<JobGame> createState() => _JbState(); }
class _JbState extends State<JobGame> {
  final jb = {"دکتر":"👨‍⚕️","معلم":"👨‍🏫","پلیس":"👮","آشپز":"👨‍🍳","خلبان":"👨‍✈️","کشاورز":"👨‍🌾","دانشمند":"👨‍🔬","نقاش":"👨‍🎨"};
  late String tn, te; List<MapEntry<String, String>> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = jb.entries.toList()..shuffle(); setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); }); }
  void _chk(String e) { if (e == te) { HapticFeedback.mediumImpact(); GameData.addCoins(4); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.addSkill('jobs'); setState(() => sc += 4); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("شغل‌ها | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ Text("$tn کدومه؟", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value), child: Container(decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
  ])));
}

class SpaceGame extends StatefulWidget { const SpaceGame({super.key}); @override State<SpaceGame> createState() => _SpState(); }
class _SpState extends State<SpaceGame> {
  final sp = {"خورشید":"☀️","ماه":"🌙","زمین":"🌍","ستاره":"⭐","موشک":"🚀","سیاره":"🪐","کهکشان":"🌌","ماهواره":"🛰"};
  late String tn, te; List<MapEntry<String, String>> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = sp.entries.toList()..shuffle(); setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); }); }
  void _chk(String e) { if (e == te) { HapticFeedback.mediumImpact(); GameData.addCoins(4); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); setState(() => sc += 4); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("فضا و سیارات | $sc"), backgroundColor: Colors.indigo.shade100), body: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F0F1E), Color(0xFF1E1E3F)])), padding: const EdgeInsets.all(20), child: Column(children: [
    Text("$tn کدومه؟", style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value), child: Container(decoration: BoxDecoration(color: Colors.indigo.shade900, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber, width: 2)), child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
  ])));
}

class SportsGame extends StatefulWidget { const SportsGame({super.key}); @override State<SportsGame> createState() => _SgState(); }
class _SgState extends State<SportsGame> {
  final sp = {"فوتبال":"⚽","بسکتبال":"🏀","تنیس":"🎾","والیبال":"🏐","شنا":"🏊","دو":"🏃","بوکس":"🥊","دوچرخه‌سواری":"🚴"};
  late String tn, te; List<MapEntry<String, String>> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = sp.entries.toList()..shuffle(); setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); }); }
  void _chk(String e) { if (e == te) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); setState(() => sc += 3); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("ورزش‌ها | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ Text("$tn کدومه؟", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value), child: Container(decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
  ])));
}

// Quiz Master, Sequence, OddOneOut, MathRace
class QuizMaster extends StatefulWidget { const QuizMaster({super.key}); @override State<QuizMaster> createState() => _QzState(); }
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
  int currentQ = 0, sc = 0; bool _answerLocked = false; late ConfettiController _cf;
  @override void initState() { super.initState(); _cf = ConfettiController(duration: const Duration(seconds: 1)); questions.shuffle(); }
  @override void dispose() { _cf.dispose(); super.dispose(); }
  void _answer(int idx) {
    if (_answerLocked) return;
    setState(() => _answerLocked = true);
    if (idx == questions[currentQ]['a']) { HapticFeedback.mediumImpact(); _cf.play(); GameData.addCoins(10); GameData.addStars(2); GameData.recordCorrect(); ChildFeedback.correct(context); GameData.progressMission('questions'); setState(() => sc += 10); }
    else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); }
    if (currentQ < questions.length - 1) { Future.delayed(const Duration(milliseconds: 800), () { if (mounted) setState(() { currentQ++; _answerLocked = false; }); }); }
    else { Future.delayed(const Duration(milliseconds: 800), () { if (!mounted) return; GameData.updateHighScore(sc, 'quiz'); showDialog(context: context, builder: (c) => AlertDialog(title: const Text("🎉 پایان مسابقه!"), content: Text("امتیاز: $sc\nرکورد: ${GameData.quizHighScore}"), actions: [TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(c); }, child: const Text("عالی!"))])); }); }
  }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("مسابقه | ${currentQ + 1}/${questions.length}")), body: Stack(children: [
    Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      LinearProgressIndicator(value: (currentQ + 1) / questions.length, backgroundColor: Colors.grey.shade200, color: Colors.deepPurple, minHeight: 10),
      const SizedBox(height: 20), Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(gradient: Gradients.purple, borderRadius: BorderRadius.circular(20)), child: Text(questions[currentQ]['q'] as String, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
      const SizedBox(height: 30), Text("امتیاز: $sc", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
      Expanded(child: ListView.builder(itemCount: (questions[currentQ]['opts'] as List).length, itemBuilder: (c, i) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: BounceBtn(onTap: () => _answer(i), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.deepPurple.shade100, borderRadius: BorderRadius.circular(15)), child: Text((questions[currentQ]['opts'] as List)[i] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center)))))),
    ])),
    Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _cf, blastDirectionality: BlastDirectionality.explosive)),
  ]));
}

class SequenceGame extends StatefulWidget { const SequenceGame({super.key}); @override State<SequenceGame> createState() => _SqState(); }
class _SqState extends State<SequenceGame> {
  List<int> numbers = []; List<int> userOrder = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { setState(() { numbers = List.generate(6, (i) => i + 1)..shuffle(); userOrder = []; }); }
  void _tap(int n) { if (userOrder.length >= numbers.length || userOrder.contains(n)) return; setState(() => userOrder.add(n));
    if (userOrder.length == numbers.length) { if (List.generate(userOrder.length, (i) => userOrder[i] == i + 1).every((e) => e)) { HapticFeedback.mediumImpact(); GameData.addCoins(8); GameData.addStars(2); GameData.recordCorrect(); ChildFeedback.correct(context); setState(() => sc += 8); Future.delayed(const Duration(milliseconds: 800), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) setState(() => userOrder = []); }); } }
  }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("ترتیب اعداد | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    const Text("اعداد رو از ۱ تا ۶ به ترتیب کلیک کن", style: TextStyle(fontSize: 16), textAlign: TextAlign.center), const SizedBox(height: 20),
    Text("انتخاب شده: ${userOrder.join(' → ')}", style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 3, crossAxisSpacing: 15, mainAxisSpacing: 15, children: numbers.map((n) => BounceBtn(onTap: () { if (!userOrder.contains(n)) _tap(n); }, child: Container(decoration: BoxDecoration(color: userOrder.contains(n) ? Colors.grey : Colors.orange, borderRadius: BorderRadius.circular(20)), child: Center(child: Text("$n", style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold)))))).toList())),
  ])));
}

class OddOneOut extends StatefulWidget { const OddOneOut({super.key}); @override State<OddOneOut> createState() => _OoState(); }
class _OoState extends State<OddOneOut> {
  final sets = [{"items": ["🍎","🍌","🍇","🚗"], "odd": 3}, {"items": ["🐶","🐱","🦁","🌳"], "odd": 3}, {"items": ["🚗","🚌","🚲","🍕"], "odd": 3}, {"items": ["⚽","🏀","🎾","📱"], "odd": 3}, {"items": ["🌸","🌺","🌻","🐛"], "odd": 3}];
  int idx = 0, sc = 0;
  @override void initState() { super.initState(); sets.shuffle(); }
  void _tap(int i) { if (i == sets[idx]['odd']) { HapticFeedback.mediumImpact(); GameData.addCoins(5); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); setState(() { sc += 5; idx = (idx + 1) % sets.length; }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("مورد اضافه | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    const Text("کدوم به بقیه ربطی نداره؟", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: List.generate((sets[idx]['items'] as List).length, (i) => BounceBtn(onTap: () => _tap(i), child: Container(decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)), child: Center(child: Text((sets[idx]['items'] as List)[i] as String, style: const TextStyle(fontSize: 80)))))))),
  ])));
}

class MathRace extends StatefulWidget { const MathRace({super.key}); @override State<MathRace> createState() => _MrState(); }
class _MrState extends State<MathRace> {
  int n1 = 0, n2 = 0, ans = 0, sc = 0, timeLeft = 30; List<int> opts = []; Timer? _t; bool _gameEnded = false;
  @override void initState() { super.initState(); _gen(); _startTimer(); }
  @override void dispose() { _t?.cancel(); super.dispose(); }
  void _startTimer() { _t = Timer.periodic(const Duration(seconds: 1), (t) { if (!mounted || _gameEnded) { t.cancel(); return; } if (timeLeft <= 1) { setState(() => timeLeft = 0); t.cancel(); _endGame(); } else { setState(() => timeLeft--); } }); }
  void _gen() { final r = Random(); setState(() { n1 = r.nextInt(10) + 1; n2 = r.nextInt(10) + 1; ans = n1 + n2; opts = {ans, ans + 1, ans - 1, ans + 2}.toList()..shuffle(); while (opts.length < 4) opts.add(ans + Random().nextInt(5) + 3); opts = opts.take(4).toList()..shuffle(); }); }
  void _chk(int a) { if (_gameEnded) return; if (a == ans) { HapticFeedback.mediumImpact(); GameData.addCoins(2); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); setState(() => sc++); _gen(); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  void _endGame() { if (_gameEnded || !mounted) return; _gameEnded = true; GameData.updateHighScore(sc, 'math_race'); showDialog(context: context, builder: (c) => AlertDialog(title: const Text("⏰ زمان تموم شد!"), content: Text("امتیاز: $sc\nرکورد: ${GameData.mathRaceHighScore}"), actions: [TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(c); }, child: const Text("باشه"))])); }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("مسابقه ریاضی | امتیاز: $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    LinearProgressIndicator(value: timeLeft / 30, minHeight: 15, backgroundColor: Colors.grey.shade200, color: timeLeft > 10 ? Colors.green : Colors.red),
    const SizedBox(height: 10), Text("⏱ $timeLeft ثانیه", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(gradient: Gradients.success, borderRadius: BorderRadius.circular(20)), child: Text("$n1 + $n2 = ?", style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold))),
    const SizedBox(height: 30), Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((o) => BounceBtn(onTap: () => _chk(o), child: Container(decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)), child: Center(child: Text("$o", style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)))))).toList())),
  ])));
}

// Story, Music, Lucky Wheel, Drawing
class StoryTime extends StatefulWidget { const StoryTime({super.key}); @override State<StoryTime> createState() => _StTState(); }
class _StTState extends State<StoryTime> {
  final stories = [
    {"title": "خرگوش و لاک‌پشت 🐰🐢", "text": "روزی خرگوش و لاک‌پشت مسابقه دادن. خرگوش تندتر بود اما وسط راه خوابش برد. لاک‌پشت آروم آروم رفت و برنده شد.\n\n📝 درس: صبر و پشتکار مهم‌تر از سرعته!"},
    {"title": "شیر و موش 🦁🐭", "text": "شیری موشی رو نگه داشت. موش خواهش کرد ولش کنه. شیر رحم کرد. بعداً شیر تو تور گیر کرد و موش ریسمان رو جوید و نجاتش داد.\n\n📝 درس: هیچکس رو کوچک نبین!"},
    {"title": "چوپان دروغگو 👦🐺", "text": "چوپانی از سر شوخی می‌گفت گرگ اومد! مردم می‌دویدن. یه روز واقعاً گرگ اومد اما کسی باور نکرد.\n\n📝 درس: دروغ نگو حتی به شوخی!"},
    {"title": "روباه و کلاغ 🦊🐦", "text": "کلاغ پنیر داشت. روباه تعریفش کرد و گفت آواز بخون. کلاغ خواند و پنیر افتاد. روباه پنیر رو برد.\n\n📝 درس: مواظب حرف‌های چاپلوسانه باش!"},
  ];
  int idx = 0;
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("داستان‌ها")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    Text(stories[idx]['title']!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
    Expanded(child: SingleChildScrollView(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(20)), child: Text(stories[idx]['text']!, style: const TextStyle(fontSize: 21, height: 1.95, fontWeight: FontWeight.w500))))),
    const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      ElevatedButton.icon(icon: const Icon(Icons.arrow_forward), label: const Text("قبلی"), onPressed: () => setState(() => idx = (idx - 1 + stories.length) % stories.length)),
      ElevatedButton.icon(icon: const Icon(Icons.arrow_back), label: const Text("بعدی"), onPressed: () { setState(() => idx = (idx + 1) % stories.length); GameData.addCoins(5); GameData.addStars(1); }),
    ]),
  ])));
}

class MusicGame extends StatefulWidget { const MusicGame({super.key}); @override State<MusicGame> createState() => _McState(); }
class _McState extends State<MusicGame> {
  final ms = {"پیانو":"🎹","گیتار":"🎸","ویولن":"🎻","درام":"🥁","ساکسیفون":"🎷","ترومپت":"🎺","میکروفون":"🎤","هدفون":"🎧"};
  late String tn, te; List<MapEntry<String, String>> opts = []; int sc = 0;
  @override void initState() { super.initState(); _gen(); }
  void _gen() { var e = ms.entries.toList()..shuffle(); setState(() { tn = e.first.key; te = e.first.value; opts = e.take(4).toList()..shuffle(); }); }
  void _chk(String e) { if (e == te) { HapticFeedback.mediumImpact(); GameData.addCoins(3); GameData.addStars(1); GameData.recordCorrect(); ChildFeedback.correct(context); setState(() => sc += 3); Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _gen(); }); } else { HapticFeedback.heavyImpact(); GameData.recordWrong(); ChildFeedback.tryAgain(context); } }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: Text("سازها | $sc")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ Text("$tn کدومه؟", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
    Expanded(child: GridView.count(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, children: opts.map((e) => BounceBtn(onTap: () => _chk(e.value), child: Container(decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(e.value, style: const TextStyle(fontSize: 70)))))).toList())),
  ])));
}

class LuckyWheel extends StatefulWidget { const LuckyWheel({super.key}); @override State<LuckyWheel> createState() => _LwState(); }
class _LwState extends State<LuckyWheel> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl; bool spinning = false; String result = "";
  final prizes = [10, 20, 50, 5, 100, 15, 30, 25]; late ConfettiController _cf;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3)); _cf = ConfettiController(duration: const Duration(seconds: 2)); }
  @override void dispose() { _ctrl.dispose(); _cf.dispose(); super.dispose(); }
  void _spin() { if (GameData.luckyWheelSpunToday) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("امروز چرخ رو زدی! فردا برگرد"), backgroundColor: Colors.orange)); return; }
    setState(() { spinning = true; result = ""; }); _ctrl.forward(from: 0).then((_) { int prize = prizes[Random().nextInt(prizes.length)]; GameData.addCoins(prize); GameData.addStars(prize ~/ 10 + 1); GameData.spinLucky(); _cf.play(); setState(() { spinning = false; result = "🎉 $prize سکه بردی!"; }); }); }
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("چرخ شانس روزانه")), body: Stack(children: [
    Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      RotationTransition(turns: Tween(begin: 0.0, end: 10.0).animate(_ctrl), child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const SweepGradient(colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.pink, Colors.cyan]), border: Border.all(color: Colors.amber, width: 8)), child: const Center(child: Icon(Icons.stars, size: 80, color: Colors.white)))),
      const SizedBox(height: 30), Text(result, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
      const SizedBox(height: 20), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(200, 60)), onPressed: spinning ? null : _spin, child: Text(GameData.luckyWheelSpunToday ? "فردا برگرد!" : "بچرخون! 🎡", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    ])), Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _cf, blastDirectionality: BlastDirectionality.explosive)),
  ]));
}

class DrawingPage extends StatefulWidget { const DrawingPage({super.key}); @override State<DrawingPage> createState() => _DrawState(); }
class _DrawState extends State<DrawingPage> {
  List<Map<String, dynamic>> strokes = []; List<Offset?> cur = []; Color col = Colors.red; double w = 5;
  final cl = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.black, Colors.pink, Colors.brown];
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("نقاشی"), backgroundColor: Colors.pink.shade100, actions: [
    IconButton(icon: const Icon(Icons.undo), onPressed: () { if (strokes.isNotEmpty) setState(() => strokes.removeLast()); }),
    IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => setState(() => strokes.clear())),
  ]), body: Column(children: [
    SizedBox(height: 60, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: cl.length, itemBuilder: (c, i) => GestureDetector(onTap: () => setState(() => col = cl[i]), child: Container(margin: const EdgeInsets.all(8), width: 40, height: 40, decoration: BoxDecoration(color: cl[i], shape: BoxShape.circle, border: col == cl[i] ? Border.all(color: Colors.black, width: 3) : null))))),
    Slider(value: w, min: 2, max: 20, onChanged: (v) => setState(() => w = v)),
    Expanded(child: GestureDetector(onPanStart: (_) => cur = [], onPanUpdate: (d) { RenderBox b = context.findRenderObject() as RenderBox; setState(() => cur.add(b.globalToLocal(d.globalPosition))); }, onPanEnd: (_) { if (cur.isNotEmpty) { setState(() { strokes.add({'p': List<Offset?>.from(cur), 'c': col, 'w': w}); cur = []; }); GameData.progressMission('drawing'); GameData.addStars(1); } },
      child: Container(color: Colors.white, child: CustomPaint(painter: _DP(strokes, cur, col, w), size: Size.infinite)))),
  ]));
}
class _DP extends CustomPainter {
  final List<Map<String, dynamic>> s; final List<Offset?> c; final Color cc; final double cw;
  _DP(this.s, this.c, this.cc, this.cw);
  @override void paint(Canvas cv, Size sz) { for (var st in s) { Paint p = Paint()..color = st['c']..strokeCap = StrokeCap.round..strokeWidth = st['w']; List<Offset?> pts = st['p']; for (int i = 0; i < pts.length - 1; i++) { if (pts[i] != null && pts[i + 1] != null) cv.drawLine(pts[i]!, pts[i + 1]!, p); } } Paint cp = Paint()..color = cc..strokeCap = StrokeCap.round..strokeWidth = cw; for (int i = 0; i < c.length - 1; i++) { if (c[i] != null && c[i + 1] != null) cv.drawLine(c[i]!, c[i + 1]!, cp); } }
  @override bool shouldRepaint(covariant CustomPainter o) => true;
}

// ==========================================================
// 📊 STATS, SETTINGS, PARENT, ETC.
// ==========================================================
class StatsPage extends StatelessWidget { const StatsPage({super.key}); @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("آمار کامل")), body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
  Card(color: Colors.amber.shade50, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ const Icon(Icons.emoji_events, size: 60, color: Colors.amber), Text("${GameData.coins}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)), const Text("سکه‌های کل"), const SizedBox(height: 10), const StarDisplay(size: 24), ]))),
  const SizedBox(height: 10),
  Row(children: [ Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [ const Icon(Icons.trending_up, color: Colors.blue), Text("لول ${GameData.level}"), Text(GameData.getLevelName(), style: const TextStyle(fontSize: 12))])))), Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [ const Icon(Icons.local_fire_department, color: Colors.orange), Text("${GameData.streak} روز"), const Text("پیاپی")])))), ]),
  Row(children: [ Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [ const Icon(Icons.check_circle, color: Colors.green), Text("${GameData.totalCorrect}"), const Text("درست")])))), Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [ const Icon(Icons.timer, color: Colors.purple), Text("${GameData.weeklyPlayMinutes} دقیقه"), const Text("این هفته")])))), ]),
  const SizedBox(height: 20),
  Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text("مدال‌ها", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("${GameData.achievements.length} مدال کسب شده"), const SizedBox(height: 10), Wrap(spacing: 5, children: GameData.achievements.map((a) => const Chip(label: Text("🏅"), backgroundColor: Colors.amber)).toList()), ]))),
])));
}

class TrophiesRoom extends StatelessWidget { const TrophiesRoom({super.key}); @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("اتاق افتخارات")), body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
  Card(color: Colors.amber.shade50, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ const Text("🏆 رکوردهای شما", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
    ListTile(leading: const Icon(Icons.speed, color: Colors.orange), title: const Text("رکورد مسابقه ریاضی"), trailing: Text("${GameData.mathRaceHighScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
    ListTile(leading: const Icon(Icons.quiz, color: Colors.purple), title: const Text("رکورد مسابقه"), trailing: Text("${GameData.quizHighScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
    ListTile(leading: const Icon(Icons.emoji_events, color: Colors.amber), title: const Text("بیشترین امتیاز"), trailing: Text("${GameData.highScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
  ]))),
  const SizedBox(height: 20),
  Card(color: Colors.blue.shade50, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [ const Text("🎖 آمار کلی", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 15),
    Text("💰 ${GameData.coins} سکه جمع کردی", style: const TextStyle(fontSize: 16)),
    Text("⭐ ${GameData.stars} ستاره داری", style: const TextStyle(fontSize: 16)),
    Text("📈 به لول ${GameData.level} رسیدی", style: const TextStyle(fontSize: 16)),
    Text("🔥 ${GameData.streak} روز پیاپی", style: const TextStyle(fontSize: 16)),
    Text("🎯 ${GameData.totalCorrect} جواب درست", style: const TextStyle(fontSize: 16)),
    Text("🏅 ${GameData.achievements.length} مدال", style: const TextStyle(fontSize: 16)),
  ]))),
])));
}

class AchPage extends StatelessWidget { const AchPage({super.key}); @override Widget build(BuildContext c) {
  final all = [{"id":"math_50","t":"ریاضیدان","d":"۵۰ امتیاز ریاضی","i":"🧮"},{"id":"memory_king","t":"شاه حافظه","d":"بازی حافظه کامل","i":"🧠"},{"id":"streak_3","t":"۳ روز پیاپی","d":"۳ روز متوالی","i":"🔥"},{"id":"streak_7","t":"۷ روز پیاپی","d":"۷ روز متوالی","i":"🏆"},{"id":"streak_30","t":"۳۰ روز پیاپی","d":"۳۰ روز متوالی","i":"🏅"},{"id":"coin_500","t":"ثروتمند","d":"۵۰۰ سکه","i":"💰"},{"id":"coin_1000","t":"میلیونر","d":"۱۰۰۰ سکه","i":"💎"},{"id":"coin_5000","t":"مولتی‌میلیونر","d":"۵۰۰۰ سکه","i":"💠"},{"id":"level_3","t":"تلاشگر","d":"لول ۳","i":"⭐"},{"id":"level_5","t":"استاد","d":"لول ۵","i":"🌟"},{"id":"level_10","t":"افسانه","d":"لول ۱۰","i":"👑"},{"id":"level_20","t":"استاد بزرگ","d":"لول ۲۰","i":"🎖"},{"id":"correct_50","t":"دقیق","d":"۵۰ جواب درست","i":"🎯"},{"id":"correct_100","t":"ماهر","d":"۱۰۰ جواب درست","i":"🏹"},{"id":"correct_500","t":"استاد پاسخ","d":"۵۰۰ جواب درست","i":"🎪"},{"id":"collector","t":"کلکسیونر","d":"۵ استیکر","i":"🎁"},{"id":"mega_collector","t":"سوپر کلکسیونر","d":"۱۰ استیکر","i":"🎊"}];
  return Scaffold(appBar: AppBar(title: const Text("مدال‌ها")), body: GameData.achievements.isEmpty
    ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ Text("🏆", style: TextStyle(fontSize: 80)), Text("هنوز مدالی نداری!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), ]))
    : ListView.builder(padding: const EdgeInsets.all(16), itemCount: all.length, itemBuilder: (c, i) { bool u = GameData.achievements.contains(all[i]['id']); return Card(color: u ? Colors.amber.shade50 : Colors.grey.shade100, child: ListTile(leading: Text(all[i]['i'] as String, style: const TextStyle(fontSize: 30)), title: Text(all[i]['t'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: u ? Colors.black : Colors.grey)), subtitle: Text(all[i]['d'] as String), trailing: u ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.lock, color: Colors.grey))); }));
}
}

class SettingsPage extends StatefulWidget { const SettingsPage({super.key}); @override State<SettingsPage> createState() => _StState(); }
class _StState extends State<SettingsPage> { @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("تنظیمات")), body: ListView(padding: const EdgeInsets.all(16), children: [
  SwitchListTile(secondary: const Icon(Icons.volume_up), title: const Text("صداها و لرزش"), value: GameData.soundEnabled, onChanged: (v) { setState(() => GameData.soundEnabled = v); GameData.save(); }),
  ListTile(leading: const Icon(Icons.timer), title: Text("محدودیت زمانی: ${GameData.timeLimitMinutes} دقیقه"), subtitle: Slider(value: GameData.timeLimitMinutes.toDouble(), min: 15, max: 120, divisions: 7, onChanged: (v) { setState(() => GameData.timeLimitMinutes = v.toInt()); GameData.save(); })),
  const Divider(),
  ListTile(leading: const Icon(Icons.refresh, color: Colors.red), title: const Text("پاک کردن همه اطلاعات"), onTap: () => showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("مطمئنی؟"), content: const Text("همه امتیازات پاک می‌شن!"), actions: [ TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("لغو")), ElevatedButton(onPressed: () async { await SharedPreferences.getInstance().then((p) => p.clear()); await GameData.load(); if (!mounted) return; Navigator.pop(ctx); setState(() {}); }, child: const Text("پاک کن")) ]))),
]));
}

class HelpCenter extends StatelessWidget { const HelpCenter({super.key}); final faqs = const [{"q": "چطور سکه بگیرم؟", "a": "با بازی کردن و جواب درست دادن به سوالات سکه می‌گیری."},{"q": "چطور لول‌آپ کنم؟", "a": "هر ۱۰۰ سکه که جمع کنی یک لول بالا می‌ری."},{"q": "ستاره چیه؟", "a": "ستاره‌ها جایزه ویژه‌ان! با تکمیل مرحله‌ها ستاره می‌گیری."},{"q": "چرخ شانس چطور کار میکنه؟", "a": "هر روز یک بار می‌تونی چرخ رو بچرخونی و سکه رایگان بگیری."},{"q": "فندقی کیه؟", "a": "فندقی دوست فندقیت‌ه که کمکت میکنه یاد بگیری و بازی کنی!"},{"q": "مدال‌ها چطور باز می‌شن؟", "a": "با انجام کارهای خاص مثل ۷ روز پیاپی، ۵۰۰ سکه و... باز می‌شن."}];
  @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("مرکز راهنما")), body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: faqs.length, itemBuilder: (c, i) => Card(child: ExpansionTile(leading: const Icon(Icons.help_outline, color: Colors.blue), title: Text(faqs[i]['q']!, style: const TextStyle(fontWeight: FontWeight.bold)), children: [Padding(padding: const EdgeInsets.all(16), child: Text(faqs[i]['a']!, style: const TextStyle(fontSize: 17, height: 1.8)))],))));
}

class RateApp extends StatefulWidget { const RateApp({super.key}); @override State<RateApp> createState() => _RaState(); }
class _RaState extends State<RateApp> { int rating = 0; @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("امتیاز به برنامه")), body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  const Icon(Icons.star, size: 100, color: Colors.amber), const SizedBox(height: 20), const Text("چقدر کودک ایران رو دوست داری؟", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 30),
  Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(icon: Icon(Icons.star, size: 45, color: i < rating ? Colors.amber : Colors.grey.shade300), onPressed: () => setState(() => rating = i + 1)))),
  const SizedBox(height: 30), if (rating > 0) Text(rating >= 4 ? "🎉 عالیه! ممنون از حمایتت" : "🙏 نظرت برامون مهمه", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  const SizedBox(height: 40), ElevatedButton.icon(icon: const Icon(Icons.send), label: const Text("ثبت نظر در کافه بازار"), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), backgroundColor: Colors.amber), onPressed: rating > 0 ? () async { await launchUrl(Uri.parse("bazaar://details?id=com.parsaapps.kudakeiran"), mode: LaunchMode.externalApplication); } : null),
])));
}

class ParentPanel extends StatelessWidget { const ParentPanel({super.key}); @override Widget build(BuildContext c) => Scaffold(appBar: AppBar(title: const Text("پنل والدین")), body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
  Card(child: ListTile(leading: const Icon(Icons.star, color: Colors.amber), title: const Text("ستاره"), trailing: Text("${GameData.stars}"))),
  Card(child: ListTile(leading: const Icon(Icons.monetization_on, color: Colors.orange), title: const Text("سکه"), trailing: Text("${GameData.coins}"))),
  Card(child: ListTile(leading: const Icon(Icons.trending_up, color: Colors.blue), title: Text("سطح (${GameData.getLevelName()})"), trailing: Text("${GameData.level}"))),
  Card(child: ListTile(leading: const Icon(Icons.local_fire_department, color: Colors.orange), title: const Text("روزهای پیاپی"), trailing: Text("${GameData.streak}"))),
  Card(child: ListTile(leading: const Icon(Icons.check, color: Colors.green), title: const Text("جواب درست"), trailing: Text("${GameData.totalCorrect}"))),
  Card(child: ListTile(leading: const Icon(Icons.close, color: Colors.red), title: const Text("جواب غلط"), trailing: Text("${GameData.totalWrong}"))),
  Card(child: ListTile(leading: const Icon(Icons.speed), title: const Text("نرخ موفقیت"), trailing: Text("${(GameData.successRate * 100).toStringAsFixed(0)}%"))),
  Card(child: ListTile(leading: const Icon(Icons.lightbulb, color: Colors.yellow), title: const Text("پیشنهاد"), subtitle: Text("بیشتر روی ${AI.weakSkill()} تمرین کنید"))),
  Card(child: ListTile(leading: const Icon(Icons.settings, color: Colors.blueGrey), title: const Text("تنظیمات والدین"), trailing: const Icon(Icons.chevron_left), onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const SettingsPage())))),
  const SizedBox(height: 20), const Text("📊 مهارت‌ها", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  SizedBox(height: 200, child: BarChart(BarChartData(barGroups: GameData.skills.entries.toList().asMap().entries.map((e) => BarChartGroupData(x: e.key.toDouble(), barRods: [BarChartRodData(toY: e.value.value.toDouble(), color: Colors.indigo, width: 16)])).toList(),
    titlesData: FlTitlesData(leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { final n = ['ریاضی','الفبا','حافظه','رنگ','شکل','حیوان','شمارش','الگو','میوه','مفاهیم','لغات','بدن','ماشین','زمان','هوا','حس','شغل']; int idx = v.toInt(); if (idx < 0 || idx >= n.length) return const Text(''); return Text(n[idx], style: const TextStyle(fontSize: 8)); })), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),)))),
])));
}

class AboutPage extends StatelessWidget { const AboutPage({super.key});
  Future<void> _o(String u) async { await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication); }
  @override Widget build(BuildContext c) => Scaffold(backgroundColor: const Color(0xFF0F0F1E), appBar: AppBar(backgroundColor: Colors.transparent, leading: const BackButton(color: Colors.white)), body: SingleChildScrollView(child: Column(children: [
    const Fandoghi(size: 80, animate: true, showBubble: false),
    const SizedBox(height: 10), const Icon(Icons.workspace_premium, size: 60, color: Colors.amber).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
    Text("Parsa Apps™", style: GoogleFonts.exo2(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w900)),
    Text("مدیر عامل: فرشاد پارسا", style: GoogleFonts.vazirmatn(fontSize: 20, color: Colors.amber, fontWeight: FontWeight.bold)),
    const SizedBox(height: 30), Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.amber.withOpacity(0.3))), child: Text("گروه برنامه‌نویسی پارسا با تکیه بر دانش روز، تجربه‌ای متفاوت برای شما خلق می‌کند.", textAlign: TextAlign.center, style: GoogleFonts.vazirmatn(color: Colors.white70, fontSize: 16, height: 1.8)))),
    const SizedBox(height: 30), Row(mainAxisAlignment: MainAxisAlignment.center, children: [ _b(Icons.email, "ایمیل", Colors.red, () => _o('mailto:farshadparsa2019@gmail.com')), const SizedBox(width: 20), _b(Icons.send, "تلگرام", Colors.blue, () => _o('https://t.me/Parsaappsadmin')), ]),
    const SizedBox(height: 30), const Text("© 2024-2026 Parsa Apps", style: TextStyle(color: Colors.amberAccent)), const SizedBox(height: 20),
  ])));
  Widget _b(IconData i, String l, Color c, VoidCallback t) => GestureDetector(onTap: t, child: Column(children: [ Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.15), border: Border.all(color: c, width: 2)), child: Icon(i, color: c, size: 30)), const SizedBox(height: 5), Text(l, style: TextStyle(color: c, fontWeight: FontWeight.bold)), ]));
}
