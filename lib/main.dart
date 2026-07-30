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

  _loadData() async 
