import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/theme_controller.dart';
import 'core/audio_service.dart';
import 'core/fandoghi_coach.dart';
import 'core/game_data.dart';
import 'core/game_launch.dart';
import 'core/logger_service.dart';
import 'features/about/about_screen.dart';
import 'features/about/privacy_policy_screen.dart';
import 'features/buddy/buddy_chat_screen.dart';
import 'features/games/alphabet_academy/alphabet_academy_game.dart';
import 'features/games/bubble_pop/bubble_pop_game.dart';
import 'features/games/drawing/drawing_game.dart';
import 'features/games/body_parts/body_parts_game.dart';
import 'features/games/island_builder/island_builder_game.dart';
import 'features/games/math_race/math_race_game.dart';
import 'features/games/pattern/pattern_game.dart';
import 'features/games/puzzle/puzzle_game.dart';
import 'features/games/sound_match/sound_match_game.dart';
import 'features/games/academy/academy_game.dart';
import 'features/games/colors_lab/colors_lab_game.dart';
import 'features/games/learning_quiz/learning_quiz_game.dart';
import 'features/games/memory_match/memory_match_game.dart';
import 'features/games/star_catch/star_catch_game.dart';
import 'features/games/stories/story_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/sticker_album_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/parent/parent_panel.dart';
import 'features/splash/splash_screen.dart';
import 'shared/widgets/fandoghi_coach.dart';

/// آموزش فندقی - Kudake Iran
/// آفلاین، فارسی و طراحی‌شده برای یادگیری امن کودکان.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // بنیادهای فنی - فاز ۴، ۶ و ۸
  await Hive.initFlutter();
  await Hive.openBox('playerBox');
  await AudioService.init();

  // فاز ۸: ثبت سراسری خطاهای غیرمنتظره به‌صورت آفلاین
  FlutterError.onError = (details) {
    LoggerService.reportCrash(
      details.exception,
      details.stack ?? StackTrace.current,
      source: 'flutter',
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    LoggerService.reportCrash(error, stackTrace, source: 'async');
    return true; // جلوگیری از کرش پیش‌فرض
  };

  // Never leave a child staring at a blank white screen.
  ErrorWidget.builder = (_) => const _FirstFrameErrorScreen();

  // ✅ فیکس عمیق فاز ۲: تنظیم امن فونت‌ها برای آفلاین — دیگر کرش سفید نمی‌دهد
  // اگر فونت کش نشده باشد، AppFonts به fallback می‌رود
  AppFonts.configure();

  try {
    await GameData.load();
    // فاز ۴۳: فندقی اسم کودک را به یاد می‌آورد
    FandoghiCoach.rememberChild(GameData.childName);
  } catch (error, stackTrace) {
    // Storage failures should degrade to a playable session, not a crash or a
    // blank screen. The next launch can retry persistence automatically.
    LoggerService.e('Game data storage unavailable', error, stackTrace);
    GameData.useMemoryFallback();
  }

  runApp(
    const ProviderScope(
      child: AmoozeshFandoghiApp(),
    ),
  );
}

class AmoozeshFandoghiApp extends StatefulWidget {
  const AmoozeshFandoghiApp({super.key});

  @override
  State<AmoozeshFandoghiApp> createState() => _AmoozeshFandoghiAppState();
}

class _AmoozeshFandoghiAppState extends State<AmoozeshFandoghiApp>
    with WidgetsBindingObserver {
  final ThemeController _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // فاز ۷: هنگام برگشت از پس‌زمینه، تم و فونت به‌روز می‌شوند
    if (state == AppLifecycleState.resumed) {
      _themeController.refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'آموزش فندقی',
          debugShowCheckedModeBanner: false,
          locale: const Locale('fa'),
          supportedLocales: const [Locale('fa')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: _themeController.themeFor(Brightness.light),
          darkTheme: _themeController.themeFor(Brightness.dark),
          themeMode: ThemeMode.system,
          builder: (context, child) => FandoghiCoachOverlay(
            child: _PlayTimeTracker(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/alphabet': (context) => const AlphabetAcademyGame(),
        '/memory_match': (context) => const MemoryMatchGame(),
        '/bubble_pop': (context) => const BubblePopGame(),
        '/star_catch': (context) => const StarCatchGame(),
        '/colors_lab': (context) => const ColorsLabGame(),
        '/puzzle': (context) => const PuzzleGame(),
        '/math_race': (context) => const MathRaceGame(),
        '/pattern': (context) => const PatternGame(),
        '/sound_match': (context) => const SoundMatchGame(),
        '/body_parts': (context) => const BodyPartsGame(),
        '/island_builder': (context) => const IslandBuilderGame(),
        '/buddy_chat': (context) => const BuddyChatScreen(),
        '/stickers': (context) => const StickerAlbumScreen(),
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
        // فاز ۲۹: داستان‌های تعاملی (/story/<id>)
        if (name.startsWith('/story/')) {
          final storyId = name.substring('/story/'.length);
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => StoryScreen(storyId: storyId),
          );
        }
        // فاز ۲۲-۲۸: آکادمی‌های محتوایی (/academy/numbers, /academy/colors ...)
        if (name.startsWith('/academy/')) {
          final topicId = name.substring('/academy/'.length);
          final launch = settings.arguments;
          final isGameLaunch = launch is GameLaunch;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => AcademyGame(
              topicId: topicId,
              stageId: isGameLaunch ? launch.stageId : null,
              stageNumber: isGameLaunch ? launch.stageNumber : null,
            ),
          );
        }
        return null;
      },
          onUnknownRoute: (settings) => MaterialPageRoute(
            settings: settings,
            builder: (_) => const _UnknownRouteScreen(),
          ),
        );
      },
    );
  }

  /// Every item shown in the island/map has a real destination. Previously
  /// unknown Persian route names silently opened Star Catch, which made the
  /// learning map misleading.
  Widget _gameFor(GameLaunch launch) {
    final name = launch.gameName.toLowerCase();
    // فاز ۵۴: مدال «کاوشگر بازی‌ها» — هر بازی انجام‌شده یک‌بار ثبت می‌شود
    GameData.recordGamePlayed(launch.gameName);
    if (name.contains('الفبا') || name.contains('alphabet')) {
      return AlphabetAcademyGame(
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
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
    if (name.contains('پازل') || name.contains('puzzle')) {
      return PuzzleGame(
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('الگو') || name.contains('pattern')) {
      return PatternGame(
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('بدن') || name.contains('body')) {
      return BodyPartsGame(
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('جزیره‌ساز') || name.contains('island_builder')) {
      return const IslandBuilderGame();
    }
    if (name.contains('داستان') || name.contains('story')) {
      return const StoryScreen(storyId: 'helpful_rabbit');
    }
    if (name.contains('مسابقه') || name.contains('math') ||
        name.contains('race')) {
      return MathRaceGame(
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('بشنو') || name.contains('sound')) {
      return SoundMatchGame(
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('رنگ') || name.contains('color')) {
      return AcademyGame(
        topicId: 'colors',
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('حیوان') || name.contains('animal')) {
      return AcademyGame(
        topicId: 'animals',
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('شغل') || name.contains('job')) {
      return AcademyGame(
        topicId: 'jobs',
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('احساس') || name.contains('emotion')) {
      return AcademyGame(
        topicId: 'emotions',
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('میوه') || name.contains('fruit')) {
      return AcademyGame(
        topicId: 'fruits',
        stageId: launch.stageId,
        stageNumber: launch.stageNumber,
      );
    }
    if (name.contains('عدد') || name.contains('number') ||
        name.contains('شمار')) {
      return AcademyGame(
        topicId: 'numbers',
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
  Timer? _autosaveTimer;
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
    // فاز ۶۷: ذخیره خودکار هر ۱۰ ثانیه — بازیابی پس از کرش
    _autosaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_foreground && GameData.isLoaded) {
        unawaited(GameData.save());
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
    _autosaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Shown by [ErrorWidget.builder] when an unexpected first-frame error would
/// otherwise leave the app on a blank white screen.
class _FirstFrameErrorScreen extends StatelessWidget {
  const _FirstFrameErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xFF1B1B2F),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🐰', style: TextStyle(fontSize: 72)),
                SizedBox(height: 16),
                Text(
                  'اوه! یک مشکل ناگهانی پیش آمد. لطفاً برنامه را دوباره باز کن.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
