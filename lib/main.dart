import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KudakeIranApp());
}

// --- تنظیمات تم و برندینگ (Premium UI) ---
class KudakeIranApp extends StatelessWidget {
  const KudakeIranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KudakeIran',
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

// --- صفحه شروع انیمیشنی (Splash - Phase 52) ---
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: 100, color: Colors.white)
                .animate(onPlay: (controller) => controller.repeat())
                .scale(duration: 1000.ms, curve: Curves.easeInOut)
                .then()
                .shake(hz: 4),
            const SizedBox(height: 20),
            Text("کودک ایران", 
              style: GoogleFonts.vazirmatn(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 1),
          ],
        ),
      ),
    );
  }
}

// --- صفحه معرفی (Onboarding - Phase 53) ---
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          _buildStep(context, "آموزش هوشمند", "مسیر اختصاصی یادگیری برای فرزند شما", Icons.psychology, Colors.blue),
          _buildStep(context, "بازی و سرگرمی", "یادگیری الفبا و اعداد با متدهای روز دنیا", Icons.videogame_asset, Colors.orange),
          _buildLastStep(context),
        ],
      ),
    );
  }

  Widget _buildStep(context, title, desc, icon, color) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 150, color: color).animate().scale(),
          const SizedBox(height: 40),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLastStep(context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars, size: 150, color: Colors.amber),
          const SizedBox(height: 40),
          const Text("آماده‌ای؟", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), minimumSize: const Size(double.infinity, 60)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KidDashboard())),
            child: const Text("شروع ماجراجویی", style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

// --- داشبورد اصلی کودک (Kid Hub - Phase 54) ---
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
      coins += 50;
      _confettiController.play();
    });
    await prefs.setInt('coins', coins);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text("سلام قهرمان! ⭐ $coins", style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => _parentGate(context)),
        ],
      ),
      body: Stack(
        children: [
          GridView.count(
            padding: const EdgeInsets.all(20),
            crossAxisCount: 2,
            children: [
              _menuItem("آموزش الفبا", Icons.sort_by_alpha, Colors.purple, true),
              _menuItem("بازی ریاضی", Icons.calculate, Colors.green, true),
              _menuItem("رنگ‌آمیزی", Icons.brush, Colors.pink, false),
              _menuItem("فروشگاه", Icons.shopping_bag, Colors.orange, false),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReward,
        child: const Icon(Icons.add_task),
      ),
    );
  }

  Widget _menuItem(title, icon, color, isFree) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 8,
      child: InkWell(
        onTap: () => isFree ? null : _showPremiumDialog(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: color).animate(onPlay: (c) => c.repeat()).shimmer(delay: 2.seconds),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (!isFree) const Icon(Icons.lock, size: 16, color: Colors.grey),
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
        content: const Text("برای دسترسی به این بخش، نسخه کامل را از بازار تهیه کنید."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("باشه"))],
      ),
    );
  }

  void _parentGate(context) {
    int n1 = Random().nextInt(10);
    int n2 = Random().nextInt(10);
    int result = n1 + n2;
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("بخش والدین"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("حاصل جمع مقابل را وارد کنید: $n1 + $n2 = ?"),
            TextField(controller: controller, keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (int.tryParse(controller.text) == result) {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentPanel()));
              }
            },
            child: const Text("ورود"),
          )
        ],
      ),
    );
  }
}

// --- پنل پیشرفته والدین (Parent Analytics - Phase 64) ---
class ParentPanel extends StatelessWidget {
  const ParentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("گزارش پیشرفت و تحلیل هوشمند")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Card(
              child: ListTile(
                leading: Icon(Icons.timer),
                title: Text("زمان استفاده امروز: ۱ ساعت و ۲۰ دقیقه"),
                subtitle: Text("وضعیت: مناسب"),
              ),
            ),
            const SizedBox(height: 20),
            const Text("نمودار یادگیری هفته اخیر", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [const FlSpot(0, 1), const FlSpot(1, 3), const FlSpot(2, 2), const FlSpot(3, 5), const FlSpot(4, 3)],
                      isCurved: true,
                      color: Colors.indigo,
                      barWidth: 5,
                      belowBarData: BarAreaData(show: true, color: Colors.indigo.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("دریافت کارنامه PDF (Phase 85)"),
            ),
          ],
        ),
      ),
    );
  }
}
