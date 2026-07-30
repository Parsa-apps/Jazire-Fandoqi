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
  runApp(const KudakeIranApp());
}

// ==========================================================
// -- تنظیمات کلی و تم اپلیکیشن
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
// -- کلاس مدیریت داده و امتیازات (Database Manager)
// ==========================================================
class ScoreManager {
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('coins') ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('coins') ?? 0;
    await prefs.setInt('coins', current + amount);
  }
}

// ==========================================================
// -- صفحه شروع (Splash)
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)],
          ),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.auto_awesome, size: 120, color: Colors.white)
                .animate(onPlay: (c) => c.repeat()).scale(duration: 1000.ms).then().shake(),
            const SizedBox(height: 20),
            Text("کودک ایران", style: GoogleFonts.vazirmatn(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold))
                .animate().fadeIn().slideY(begin: 1),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.white),
          ]),
        ),
      ),
    );
  }
}

// ==========================================================
// -- صفحه راهنما (Onboarding)
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
    {"icon": Icons.school_rounded, "title": "یادگیری شاد", "desc": "الفبا و اعداد را به روشی جذاب یاد بگیرید.", "color": const Color(0xFF6C63FF)},
    {"icon": Icons.videogame_asset_rounded, "title": "بازی و سرگرمی", "desc": "بازی‌های هوشمند در انتظار شماست.", "color": const Color(0xFFFFB84D)},
    {"icon": Icons.family_restroom_rounded, "title": "پنل والدین", "desc": "پیشرفت فرزندتان را کنترل کنید.", "color": const Color(0xFF4CAF50)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          Align(alignment: Alignment.topLeft, child: TextButton(onPressed: _finish, child: const Text("رد کردن", style: TextStyle(color: Colors.grey)))),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(30),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: (_pages[index]['color'] as Color).withOpacity(0.1)),
                    child: Icon(_pages[index]['icon'], size: 100, color: _pages[index]['color']),
                  ).animate().scale(),
                  const SizedBox(height: 30),
                  Text(_pages[index]['title'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(_pages[index]['desc'], textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ]),
              ),
            ),
          ),
          if (_currentPage == _pages.length - 1)
            Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _pages[_currentPage]['color'], minimumSize: const Size(double.infinity, 55)),
                onPressed: _finish,
                child: const Text("ورود به دنیای کودک", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          else
            Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 25 : 8, height: 8,
                decoration: BoxDecoration(color: _currentPage == index ? _pages[_currentPage]['color'] : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ))),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("به سمت چپ بکشید", style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 5),
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
// -- داشبورد اصلی کودک با اتصال به بازی‌ها
// ==========================================================
class KidDashboard extends StatefulWidget {
  const KidDashboard({super.key});
  @override
  State<KidDashboard> createState() => _KidDashboardState();
}

class _KidDashboardState extends State<KidDashboard> {
  int coins = 0;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    int c = await ScoreManager.getCoins();
    setState(() => coins = c);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text("امتیاز: $coins ⭐", style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => _parentGate())],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15, mainAxisSpacing: 15,
        children: [
          _menuItem("الفبای شاد", Icons.sort_by_alpha, Colors.purple, const AlphabetGame()),
          _menuItem("بازی اعداد", Icons.calculate, Colors.green, const NumberGame()),
          _menuItem("نقاشی کن", Icons.brush, Colors.pink, const DrawingPage()),
          _menuItem("درباره ما", Icons.info_outline, Colors.orange, const AboutUsPage()),
        ],
      ),
    );
  }

  Widget _menuItem(String title, IconData icon, Color color, Widget page) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
          _loadCoins(); // بعد از بازگشت از بازی، امتیازات را آپدیت کن
        },
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 60, color: color).animate(onPlay: (c) => c.repeat()).shimmer(delay: 2.seconds),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  void _parentGate() {
    int n1 = Random().nextInt(10) + 1;
    int n2 = Random().nextInt(10) + 1;
    int result = n1 + n2;
    TextEditingController controller = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("ورود والدین"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("حاصل جمع: $n1 + $n2 = ?", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextField(controller: controller, keyboardType: TextInputType.number, textAlign: TextAlign.center),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("انصراف")),
        ElevatedButton(onPressed: () {
          if (int.tryParse(controller.text) == result) {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentPanel()));
          }
        }, child: const Text("تایید")),
      ],
    ));
  }
}

// ==========================================================
// -- بازی ۱: آموزش الفبای شاد (کاملاً کاربردی)
// ==========================================================
class AlphabetGame extends StatefulWidget {
  const AlphabetGame({super.key});
  @override
  State<AlphabetGame> createState() => _AlphabetGameState();
}

class _AlphabetGameState extends State<AlphabetGame> {
  final List<String> letters = ["ا", "ب", "پ", "ت", "ث", "ج", "چ", "ح", "خ", "د", "ذ", "ر", "ز", "ژ", "س", "ش", "ص", "ض", "ط", "ظ", "ع", "غ", "ف", "ق", "ک", "گ", "ل", "م", "ن", "و", "ه", "ی"];
  String selectedLetter = "ا";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("آموزش الفبا"), backgroundColor: Colors.purple[100]),
      body: Column(children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.purple, width: 3)),
            child: Center(
              child: Text(selectedLetter, style: const TextStyle(fontSize: 200, color: Colors.purple, fontWeight: FontWeight.bold))
                  .animate(key: ValueKey(selectedLetter)).scale(duration: 400.ms),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
            itemCount: letters.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () async {
                setState(() => selectedLetter = letters[index]);
                await ScoreManager.addCoins(1); // به ازای هر کلیک ۱ سکه
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectedLetter == letters[index] ? Colors.purple : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
                ),
                child: Center(
                  child: Text(letters[index],
                      style: TextStyle(fontSize: 30, color: selectedLetter == letters[index] ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ==========================================================
// -- بازی ۲: بازی اعداد (کاملاً کاربردی)
// ==========================================================
class NumberGame extends StatefulWidget {
  const NumberGame({super.key});
  @override
  State<NumberGame> createState() => _NumberGameState();
}

class _NumberGameState extends State<NumberGame> {
  int num1 = 0, num2 = 0, correctAnswer = 0;
  List<int> options = [];
  int score = 0;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _generateQuestion();
  }

  @override
  void dispose() { _confetti.dispose(); super.dispose(); }

  void _generateQuestion() {
    final rand = Random();
    setState(() {
      num1 = rand.nextInt(9) + 1;
      num2 = rand.nextInt(9) + 1;
      correctAnswer = num1 + num2;
      options = [correctAnswer, correctAnswer + 1, correctAnswer - 1, correctAnswer + 2]..shuffle();
    });
  }

  void _checkAnswer(int selected) async {
    if (selected == correctAnswer) {
      _confetti.play();
      await ScoreManager.addCoins(5);
      setState(() => score += 5);
      Future.delayed(const Duration(milliseconds: 800), _generateQuestion);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("اشتباه بود! دوباره تلاش کن"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("بازی اعداد - امتیاز: $score"), backgroundColor: Colors.green[100]),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("جواب رو انتخاب کن:", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
              child: Text("$num1 + $num2 = ?", style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.green)),
            ),
            const SizedBox(height: 40),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
              children: options.map((opt) => ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () => _checkAnswer(opt),
                child: Text("$opt", style: const TextStyle(fontSize: 40, color: Colors.white)),
              )).toList(),
            ),
          ]),
        ),
        Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confetti, blastDirectionality: BlastDirectionality.explosive)),
      ]),
    );
  }
}

// ==========================================================
// -- بازی ۳: صفحه نقاشی (کاملاً کاربردی)
// ==========================================================
class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});
  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<Offset?> points = [];
  Color selectedColor = Colors.red;
  double strokeWidth = 5.0;

  final List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.black, Colors.pink, Colors.brown];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("دفتر نقاشی"),
        backgroundColor: Colors.pink[100],
        actions: [IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => setState(() => points.clear()))],
      ),
      body: Column(children: [
        Container(
          height: 60,
          color: Colors.grey[200],
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => setState(() => selectedColor = colors[index]),
              child: Container(
                margin: const EdgeInsets.all(8),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                  border: selectedColor == colors[index] ? Border.all(color: Colors.black, width: 3) : null,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox box = context.findRenderObject() as RenderBox;
                Offset point = box.globalToLocal(details.globalPosition);
                point = Offset(point.dx, point.dy - 130); // اصلاح موقعیت بابت AppBar و color picker
                points.add(point);
              });
            },
            onPanEnd: (_) => points.add(null),
            child: Container(
              color: Colors.white,
              child: CustomPaint(painter: DrawingPainter(points, selectedColor, strokeWidth), size: Size.infinite),
            ),
          ),
        ),
      ]),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;
  DrawingPainter(this.points, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color..strokeCap = StrokeCap.round..strokeWidth = strokeWidth;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================================
// -- پنل والدین
// ==========================================================
class ParentPanel extends StatelessWidget {
  const ParentPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("پنل والدین")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Card(child: ListTile(leading: Icon(Icons.timer), title: Text("زمان امروز"), trailing: Text("۴۵ دقیقه"))),
          const Card(child: ListTile(leading: Icon(Icons.check_circle), title: Text("موفقیت‌ها"), trailing: Text("۱۲"))),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(LineChartData(
              lineBarsData: [LineChartBarData(spots: const [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5)], isCurved: true, color: Colors.indigo, barWidth: 5)],
            )),
          ),
        ]),
      ),
    );
  }
}

// ==========================================================
// -- درباره ما (Parsa Apps)
// ==========================================================
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton(color: Colors.white)),
      body: SingleChildScrollView(
        child: Column(children: [
          const Icon(Icons.workspace_premium, size: 100, color: Colors.amber).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds, color: Colors.white),
          const SizedBox(height: 20),
          Text("Parsa Apps™", style: GoogleFonts.exo2(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 3)),
          const SizedBox(height: 10),
          Text("مدیر عامل: فرشاد پارسا", style: GoogleFonts.vazirmatn(fontSize: 20, color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.amber.withOpacity(0.3))),
              child: Text("گروه برنامه‌نویسی پارسا با تکیه بر دانش روز و طراحی خلاقانه، تجربه‌ای متفاوت برای شما خلق می‌کند.",
                  textAlign: TextAlign.center, style: GoogleFonts.vazirmatn(color: Colors.white70, fontSize: 16, height: 1.8)),
            ),
          ),
          const SizedBox(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _contactButton(Icons.email, "ایمیل", Colors.redAccent, () => _launchURL('mailto:farshadparsa2019@gmail.com')),
            const SizedBox(width: 20),
            _contactButton(Icons.send, "تلگرام", Colors.blueAccent, () => _launchURL('https://t.me/Parsaappsadmin')),
          ]),
          const SizedBox(height: 30),
          const Text("© 2024 Parsa Apps", style: TextStyle(color: Colors.amberAccent)),
        ]),
      ),
    );
  }

  Widget _contactButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.15), border: Border.all(color: color, width: 2)),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
