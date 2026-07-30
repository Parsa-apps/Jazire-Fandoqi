import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const KudakeIranApp());
}

class KudakeIranApp extends StatelessWidget {
  const KudakeIranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KudakeIran',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Roboto', // اگر فونت فارسی اضافه کردی نامش را اینجا بنویس
      ),
      home: const SplashScreen(),
    );
  }
}

// --- صفحه شروع (Splash Screen) با تایمر هوشمند ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // بعد از ۳ ثانیه به صورت خودکار به صفحه Onboarding می‌رود
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
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
            const Icon(Icons.auto_awesome, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "KudakeIran",
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// --- صفحه خوش‌آمدگویی (Onboarding) ---
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 100, color: Color(0xFF6C63FF)),
            const SizedBox(height: 40),
            const Text(
              "یادگیری شاد، آینده روشن",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "به دنیای آموزش و سرگرمی کودکان ایران خوش آمدید",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const KidHomePage()));
              },
              child: const Text("ورود به دنیای کودک", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentDashboard()));
              },
              child: const Text("پنل مخصوص والدین"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- صفحه اصلی کودک (Kid Home) ---
class KidHomePage extends StatelessWidget {
  const KidHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("دنیای بازی و آموزش"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _buildMenuCard(context, "آموزش الفبا", Icons.abc, Colors.blue),
          _buildMenuCard(context, "اعداد", Icons.calculate, Colors.green),
          _buildMenuCard(context, "نقاشی", Icons.palette, Colors.purple),
          _buildMenuCard(context, "بازی‌ها", Icons.videogame_asset, Colors.red),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- پنل والدین (Parent Dashboard) ---
class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("گزارش وضعیت برای والدین")),
      body: const Center(
        child: Text("اینجا لیست پیشرفت‌های فرزند شما نمایش داده می‌شود"),
      ),
    );
  }
}
