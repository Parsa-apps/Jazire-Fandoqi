import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_theme.dart';
import 'core/game_data.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';

/// ═══════════════════════════════════════════════
/// 🚀 کودک ایران - Kudake Iran
/// اپلیکیشن فوق‌گرافیکی آموزشی کودکان
/// ═══════════════════════════════════════════════

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // بارگذاری داده‌های بازی از حافظه محلی
  await GameData.load();

  runApp(const KudakeIranApp());
}

class KudakeIranApp extends StatelessWidget {
  const KudakeIranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'کودک ایران',
      debugShowCheckedModeBanner: false,

      //  پشتیبانی از زبان فارسی (RTL)
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      //  تم اپلیکیشن
      theme: AppTheme.light,

      // 🛣️ مسیرهای اپلیکیشن
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
