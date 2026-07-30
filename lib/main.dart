import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        textTheme: GoogleFonts.vazirmatnTextTheme(), // فونت حرفه‌ای فارسی
      ),
      home: const SplashScreen(),
    );
  }
}

// --- مدیریت داده‌ها (Database) ---
class AppData {
  static int coins = 0;
  static Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    coins = prefs.getInt('coins') ?? 0;
  }
  static Future<void> addCoin() async {
    coins += 10;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
  }
}

// --- صفحه شروع (Splash) ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    AppData.loadProgress().then((_) {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const KidHomePage()));
      });
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
            const Icon(Icons.star, size: 100, color: Colors.yellowAccent),
            const SizedBox(height: 20),
            Text("کودک ایران", style: GoogleFonts.vazirmatn(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// --- صفحه اصلی کودک (Kid Home) ---
class KidHomePage extends StatefulWidget {
  const KidHomePage({super.key});
  @override
  State<KidHomePage> createState() => _KidHomePageState();
}

class _KidHomePageState extends State<KidHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("امتیاز تو: ${AppData.coins} ⭐", style: const TextStyle(color: Colors.black)),
              background: Container(color: Colors.yellow[200]),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () => _showParentalGate(context),
              )
            ],
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            delegate: SliverChildListDelegate([
              _buildMenuCard(context, "آموزش الفبا", Icons.abc, Colors.blue, true),
              _buildMenuCard(context, "اعداد طلایی", Icons.pin, Colors.green, false),
              _buildMenuCard(context, "دفتر نقاشی", Icons.brush, Colors.orange, false),
              _buildMenuCard(context, "جایزه‌ها", Icons.card_giftcard, Colors.red, false),
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, bool isFree) {
    return Card(
      margin: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: InkWell(
        onTap: () {
          if (!isFree) {
            _showPremiumDialog(context);
          } else {
            // اینجا بازی باز می‌شود و بعد از موفقیت:
            setState(() { AppData.addCoin(); });
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: color),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (!isFree) const Icon(Icons.lock, size: 20, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  // --- سیستم هوشمند قفل والدین (Parental Gate) ---
  void _showParentalGate(BuildContext context) {
    int num1 = Random().nextInt(10) + 1;
    int num2 = Random().nextInt(10) + 1;
    int correctAnswer = num1 + num2;
    TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ورود والدین"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("برای تایید، حاصل جمع رو بنویس: $num1 + $num2 = ?"),
            TextField(controller: answerController, keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (int.tryParse(answerController.text) == correctAnswer) {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentDashboard()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("جواب اشتباهه!")));
              }
            },
            child: const Text("ورود"),
          )
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("نسخه طلایی"),
        content: const Text("برای باز کردن این بخش و حمایت از ما، باید نسخه کامل رو از کافه بازار تهیه کنی."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("بعداً")),
          ElevatedButton(onPressed: () {}, child: const Text("خرید از بازار")),
        ],
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
      appBar: AppBar(title: const Text("تنظیمات و گزارش پیشرفت")),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.person), title: Text("نام کودک: نیما")),
          ListTile(leading: Icon(Icons.bar_chart), title: Text("زمان یادگیری امروز: ۴۵ دقیقه")),
          ListTile(leading: Icon(Icons.shopping_cart), title: Text("خرید نسخه کامل")),
        ],
      ),
    );
  }
}
