import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app_theme.dart';
import 'core/game_data.dart';
import 'core/game_launch.dart';
import 'features/about/about_screen.dart';
import 'features/about/privacy_policy_screen.dart';
import 'features/games/bubble_pop/bubble_pop_game.dart';
import 'features/games/drawing/drawing_game.dart';
import 'features/games/learning_quiz/learning_quiz_game.dart';
import 'features/games/memory_match/memory_match_game.dart';
import 'features/games/star_catch/star_catch_game.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/parent/parent_panel.dart';
import 'features/splash/splash_screen.dart';

/// کودک ایران - Kudake Iran
/// آفلاین، فارسی و طراحی‌شده برای یادگیری امن کودکان.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A child app must work without a network connection. Google Fonts otherwise
  // may try to fetch a font at runtime on the first launch.
  GoogleFonts.config.allowRuntimeFetching = false;

  try {
    await GameData.load();
  } catch (error, stackTrace) {
    // Storage failures should degrade to a playable session, not a crash or a
    // blank screen. The next launch can retry persistence automatically.
    debugPrint('Game data storage unavailable: $error');
    debugPrintStack(stackTrace: stackTrace);
    GameData.useMemoryFallback();
  }

  runApp(const KudakeIranApp());
}

class KudakeIranApp extends StatelessWidget {
  const KudakeIranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'کودک ایران',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      builder: (context, child) => _PlayTimeTracker(
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/memory_match': (context) => const MemoryMatchGame(),
        '/bubble_pop': (context) => const BubblePopGame(),
        '/star_catch': (context) => const StarCatchGame(),
        '/parent': (context) => const ParentPanel(),
        '/about': (context) => const AboutScreen(),
        '/privacy': (context) => const PrivacyPolicyScreen(),
      },
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (name.startsWith('/game/')) {
          final gameName = name.substring('/game/'.length);
          final suppliedLaunch = settings.arguments;
          final launch = suppliedLaunch is GameLaunch
              ? suppliedLaunch
              : GameLaunch(gameName: gameName);
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => _gameFor(launch),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => const _UnknownRouteScreen(),
      ),
    );
  }

  /// Every item shown in the island/map has a real destination. Previously
  /// unknown Persian route names silently opened Star Catch, which made the
  /// learning map misleading.
  Widget _gameFor(GameLaunch launch) {
    final name = launch.gameName.toLowerCase();
    if (name.contains('حافظه') || name.contains('memory')) {
      return MemoryMatchGame(
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('حباب') || name.contains('bubble')) {
      return BubblePopGame(
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('ستاره') || name.contains('star')) {
      return StarCatchGame(
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('نقاش') || name.contains('draw')) {
      return DrawingGame(
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }

    return LearningQuizGame(
      topic: launch.gameName,
      stageId: launch.stageId,
      stageNumber: launch.stageNumber,
    );
  }
}

class _PlayTimeTracker extends StatefulWidget {
  final Widget child;

  const _PlayTimeTracker({required this.child});

  @override
  State<_PlayTimeTracker> createState() => _PlayTimeTrackerState();
}

class _PlayTimeTrackerState extends State<_PlayTimeTracker>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_foreground && GameData.onboardingSeen && !GameData.isDailyLimitReached) {
        GameData.addPlayTime();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صفحه پیدا نشد')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🧭', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'این مسیر فعلاً در دسترس نیست.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                ),
                child: const Text('برگشت به خانه'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
