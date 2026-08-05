import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_theme.dart';
import 'core/game_data.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/island/island_screen.dart';
import 'features/stage_map/stage_map_screen.dart';
import 'features/games/star_catch/star_catch_game.dart';
import 'features/games/bubble_pop/bubble_pop_game.dart';
import 'features/games/memory_match/memory_match_game.dart';
import 'features/profile/profile_screen.dart';
import 'features/shop/shop_screen.dart';

// ═══════════════════════════════════════════════
// 🇮🇷 KUDAKE IRAN v4.0 — Super Graphics Edition
// ═══════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Load saved data
  await GameData.load();
  
  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  runApp(const KudakeIranApp());
}

class KudakeIranApp extends StatelessWidget {
  const KudakeIranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'کودک ایران',
      theme: AppTheme.light,
      
      // RTL + Persian locale
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Force RTL
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      
      // Start with splash
      initialRoute: '/splash',
      
      // Routes
      onGenerateRoute: (settings) {
        final uri = settings.name ?? '';
        
        switch (uri) {
          case '/splash':
            return _pageRoute(const SplashScreen(), settings);
          
          case '/home':
            return _pageRoute(const HomeScreen(), settings);
          
          case '/island':
            return _pageRoute(const LearningIsland(), settings);
          
          case '/stage_map':
            return _pageRoute(const StageMapScreen(), settings);
          
          case '/profile':
            return _pageRoute(const ProfileScreen(), settings);
          
          case '/shop':
            return _pageRoute(const ShopScreen(), settings);
          
          case '/game/ستاره‌گیری':
          case '/star_catch':
            return _pageRoute(const StarCatchGame(), settings);
          
          case '/game/حباب‌ترکان':
          case '/bubble_pop':
            return _pageRoute(const BubblePopGame(), settings);
          
          case '/game/حافظه':
          case '/memory_match':
            return _pageRoute(const MemoryMatchGame(), settings);
          
          // Game routes
          case '/game/الفبا':
          case '/game/اعداد':
          case '/game/رنگ‌ها':
          case '/game/حیوانات':
          case '/game/نقاشی':
          case '/game/اشکال':
          case '/game/الگو':
          case '/game/مسابقه':
          case '/game/ترتیب':
          case '/game/مورد اضافه':
          case '/game/مسابقه ریاضی':
          case '/game/چرخ شانس':
          case '/game/شمارش':
          case '/game/مفاهیم':
          case '/game/لغات':
          case '/game/بدن':
          case '/game/وسایل نقلیه':
          case '/game/زمان':
          case '/game/آب و هوا':
          case '/game/احساسات':
          case '/game/شغل‌ها':
          case '/game/فضا':
          case '/game/ورزش‌ها':
          case '/game/داستان':
          case '/game/سازها':
            // Temporary: redirect to star catch game
            return _pageRoute(const StarCatchGame(), settings);
          
          default:
            return _pageRoute(const SplashScreen(), settings);
        }
      },
    );
  }

  PageRouteBuilder _pageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, a, __) => page,
      transitionsBuilder: (_, a, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: a,
            curve: Curves.easeOutCubic,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: a,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
