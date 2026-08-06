import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_theme.dart';
import 'core/game_data.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/games/memory_match/memory_match_game.dart';
import 'features/games/bubble_pop/bubble_pop_game.dart';
import 'features/games/star_catch/star_catch_game.dart';
import 'features/parent/parent_panel.dart';

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
        '/memory_match': (context) => const MemoryMatchGame(),
        '/bubble_pop': (context) => const BubblePopGame(),
        '/star_catch': (context) => const StarCatchGame(),
        '/parent': (context) => const ParentPanel(),
      },
      // مدیریت مسیرهای پویا (بازی‌ها با اسم فارسی)
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (name.startsWith('/game/')) {
          final game = name.substring('/game/'.length);
          return MaterialPageRoute(
            builder: (_) => _gameFor(game),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const SplashScreen(),
      ),
    );
  }

  /// انتخاب بازی مناسب بر اساس نام فارسی
  Widget _gameFor(String name) {
    if (name.contains('حافظه') || name.contains('memory')) {
      return const MemoryMatchGame();
    }
    if (name.contains('حباب') || name.contains('bubble')) {
      return const BubblePopGame();
    }
    return const StarCatchGame();
  }
}
