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

// ============================================================
// --- تنظیمات اصلی برنامه و تم (Premium Theme) ---
// ============================================================
class KudakeIranApp extends StatelessWidget {
  const KudakeIranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'کودک ایران',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFFFFB84D),
        ),
        textTheme: GoogleFonts.vazirmatnTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// --- صفحه اسپلش (Splash Screen) - اصلاح شده ---
// ============================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const OnboardingPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // پس زمینه گرادیانی حرفه‌ای به جای رنگ زرد ساده
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 120, color: Colors.white)
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(duration: 1000.ms, curve: Curves.easeInOut)
                  .then()
                  .shake(hz: 4),
              const SizedBox(height: 20),
              Text("کودک ایران",
                      style: GoogleFonts.vazirmatn(
                          fontSize: 45,
                          color: Colors.white,
                          fontWeight: FontWeight.bold))
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 1),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// --- صفحه معرفی (Onboarding) - باگ Color اصلاح شد ---
// ============================================================
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // اصلاح باگ اصلی: اضافه کردن const Color
  final List<Map<String, dynamic>> _pages = [
    {
      "icon": Icons.school_rounded,
      "title": "یادگیری شاد و آسان",
      "desc": "الفبا، اعداد و مهارت‌های پایه را با روش‌های نوین و جذاب به فرزندتان بیاموزید.",
      "color": const Color(0xFF6C63FF),
    },
    {
      "icon": Icons.videogame_asset_rounded,
      "title": "بازی و سرگرمی",
      "desc": "با ده‌ها بازی هدفمند، خلاقیت و هوش فرزند شما در حین بازی رشد می‌کند.",
      "color": const Color(0xFFFFB84D),
    },
    {
      "icon": Icons.family_restroom_rounded,
      "title": "پنل ویژه والدین",
      "desc": "همیشه در جریان پیشرفت فرزندتان باشید و روند یادگیری او را مدیریت کنید.",
      "color": const Color(0xFF4CAF50),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text("رد کردن",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPageContent(_pages[index]);
                },
              ),
            ),
            _buildBottomSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(Map<String, dynamic> pageData) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (pageData['color'] as Color).withOpacity(0.1),
            ),
            child: Icon(pageData['icon'] as IconData, size: 100, color: pageData['color'] as Color),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(
            pageData['title'] as String,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),
          const SizedBox(height: 15),
          Text(
            pageData['desc'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.6),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    if (_currentPage == _pages.length - 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _pages[_currentPage]['color'] as Color,
            minimumSize: const Size(double.infinity, 55),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: _finishOnboarding,
          child: const Text("ورود به دنیای کودک",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ).animate().fadeIn().slideY(begin: 1),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 25 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? _pages[_currentPage]['color'] as Color
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("برای ادامه به سمت چپ بکشید",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .slideX(begin: 0.5, end: -0.5, duration: 800.ms),
          ],
        ),
      ],
    );
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const KidDashboard()),
    );
  }
}

// ============================================================
// --- داشبورد اصلی کودک (Kid Home) - قفل‌ها باز شد ---
// ============================================================
class KidDashboard extends StatefulWidget {
  const KidDashboard({super.key});
  @override
  State<KidDashboard> createState() => _KidDashboardState();
}

class _KidDashboardState extends State<KidDashboard> {
  int coins = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadData();
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => coins = prefs.getInt('coins') ?? 0);
  }

  _addReward() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins += 10;
      _confettiController.play();
    });
    await prefs.setInt('coins', coins);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text("امتیاز تو: $coins ⭐",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _parentGate(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.count(
            padding: const EdgeInsets.all(20),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _menuItem("الفبای شاد", Icons.sort_by_alpha, Colors.purple),
              _menuItem("بازی اعداد", Icons.calculate, Colors.green),
              _menuItem("نقاشی کن", Icons.brush, Colors.pink),
              _menuItem("درباره ما", Icons.info_outline, Colors.orange,
                  isAbout: true),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: _addReward,
        child: const Icon(Icons.star, color: Colors.white),
      ),
    );
  }

  Widget _menuItem(String title, IconData icon, Color color, {bool isAbout = false}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          if (isAbout) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()));
          } else {
            _addReward();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: color)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(delay: 2.seconds),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _parentGate(BuildContext context) {
    int n1 = Random().nextInt(10) + 1;
    int n2 = Random().nextInt(10) + 1;
    int result = n1 + n2;
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ورود ویژه والدین"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("لطفاً برای تایید بزرگسال بودن، حاصل جمع را وارد کنید:"),
            const SizedBox(height: 10),
            Text("$n1 + $n2 = ?",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("انصراف")),
          ElevatedButton(
            onPressed: () {
              if (int.tryParse(controller.text) == result) {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ParentPanel()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("جواب اشتباه بود! فقط والدین اجازه ورود دارند."),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text("تایید"),
          )
        ],
      ),
    );
  }
}

// ============================================================
// --- پنل پیشرفته والدین (Parent Panel) ---
// ============================================================
class ParentPanel extends StatelessWidget {
  const ParentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("گزارش پیشرفت هوشمند")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.timer, color: Colors.blue),
                title: Text("زمان استفاده امروز"),
                trailing: Text("۴۵ دقیقه"),
              ),
            ),
            const SizedBox(height: 10),
            const Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text("تمرین‌های موفق"),
                trailing: Text("۱۲ تمرین"),
              ),
            ),
            const SizedBox(height: 20),
            const Text("نمودار پیشرفت هفته گذشته",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2),
                        FlSpot(3, 5), FlSpot(4, 3), FlSpot(5, 4),
                      ],
                      isCurved: true,
                      color: const Color(0xFF6C63FF),
                      barWidth: 5,
                      belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF6C63FF).withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("دریافت کارنامه PDF"),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// --- صفحه درباره ما (Parsa Apps™ Showcase) ---
// ============================================================
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.workspace_premium, size: 100, color: Colors.amber)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2.seconds, color: Colors.white)
                .then(delay: 500.ms)
                .shake(hz: 2),
            const SizedBox(height: 30),
            Text("Parsa Apps™",
                    style: GoogleFonts.exo2(
                        fontSize: 40, color: Colors.white,
                        fontWeight: FontWeight.w900, letterSpacing: 3))
                .animate().fadeIn(duration: 1.seconds).slideY(begin: 0.5),
            const SizedBox(height: 10),
            Text("مدیر عامل: فرشاد پارسا",
                    style: GoogleFonts.vazirmatn(
                        fontSize: 20, color: Colors.amber,
                        fontWeight: FontWeight.bold))
                .animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Text(
                  "گروه برنامه‌نویسی پارسا با تکیه بر دانش روز و طراحی خلاقانه، تجربه‌ای متفاوت را برای کاربران ایرانی رقم می‌زند. کیفیت، تعهد و نوآوری، ارکان اصلی محصولات ماست.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                      color: Colors.white70, fontSize: 16, height: 1.8),
                ),
              ).animate().scale(delay: 800.ms, curve: Curves.elasticOut),
            ),
            const SizedBox(height: 40),
            const Text("راه‌های ارتباطی و پشتیبانی",
                style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _contactButton(
                  icon: Icons.email_rounded,
                  label: "ایمیل",
                  color: Colors.redAccent,
                  onTap: () => _launchURL('mailto:farshadparsa2019@gmail.com?subject=پشتیبانی اپلیکیشن کودک ایران'),
                ),
                const SizedBox(width: 25),
                _contactButton(
                  icon: Icons.send_rounded,
                  label: "تلگرام",
                  color: Colors.blueAccent,
                  onTap: () => _launchURL('https://t.me/Parsaappsadmin'),
                ),
              ],
            ).animate().fadeIn(delay: 1200.ms).slideY(begin: 1),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("© 2024 Parsa Apps - تمامی حقوق محفوظ است",
                  style: TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _contactButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
