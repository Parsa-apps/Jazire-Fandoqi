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
// --- صفحه اسپلش (Splash Screen) با انیمیشن ---
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
      backgroundColor: const Color(0xFFFFEB3B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 120, color: Color(0xFF6C63FF))
                .animate(onPlay: (controller) => controller.repeat())
                .scale(duration: 1000.ms, curve: Curves.easeInOut)
                .then()
                .shake(hz: 4),
            const SizedBox(height: 20),
            Text("کودک ایران",
                    style: GoogleFonts.vazirmatn(
                        fontSize: 45,
                        color: const Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold))
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: 1),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFF6C63FF)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// --- صفحه معرفی (Onboarding) ---
// ============================================================
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: 150, color: Color(0xFF6C63FF))
                .animate()
                .slideX(),
            const SizedBox(height: 40),
            const Text("به دنیای شاد یادگیری خوش آمدید",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text(
              "همراه با فرشاد پارسا، آموزش را برای فرزندتان لذت‌بخش کنید",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const KidDashboard())),
              child: const Text("شروع ماجراجویی",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// --- داشبورد اصلی کودک (Kid Home) ---
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
              _menuItem("الفبای شاد", Icons.sort_by_alpha, Colors.purple, true),
              _menuItem("بازی اعداد", Icons.calculate, Colors.green, true),
              _menuItem("نقاشی کن", Icons.brush, Colors.pink, false),
              _menuItem("درباره ما", Icons.info_outline, Colors.orange, true,
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
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
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

  Widget _menuItem(String title, IconData icon, Color color, bool isFree,
      {bool isAbout = false}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          if (isAbout) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()));
          } else if (!isFree) {
            _showPremiumDialog();
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
            if (!isFree)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Icon(Icons.lock, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("نسخه طلایی"),
        content: const Text("برای دسترسی به این بخش لطفاً نسخه کامل را از کافه بازار تهیه کنید."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("متوجه شدم"))
        ],
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
            Text("لطفاً برای تایید بزرگسال بودن، حاصل جمع را وارد کنید:"),
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
                      spots: [
                        const FlSpot(0, 1),
                        const FlSpot(1, 3),
                        const FlSpot(2, 2),
                        const FlSpot(3, 5),
                        const FlSpot(4, 3),
                        const FlSpot(5, 4),
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
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3))
                .animate()
                .fadeIn(duration: 1.seconds)
                .slideY(begin: 0.5),
            const SizedBox(height: 10),
            Text("مدیر عامل: فرشاد پارسا",
                    style: GoogleFonts.vazirmatn(
                        fontSize: 20,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold))
                .animate()
                .fadeIn(delay: 500.ms),
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
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _contactButton(
                  icon: Icons.email_rounded,
                  label: "ایمیل",
                  color: Colors.redAccent,
                  onTap: () => _launchURL(
                      'mailto:farshadparsa2019@gmail.com?subject=پشتیبانی اپلیکیشن کودک ایران'),
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
                  style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _contactButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
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
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
