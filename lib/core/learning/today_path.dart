import '../game_data.dart';

/// یک کار واقعی برای امروز — بدون نمرهٔ ساختگی و بدون پیش‌بینی دروغ.
class TodayTask {
  final String title;
  final String reason;
  final String route;
  final String station;
  final int doneCount;
  final int totalCount;
  final bool allDone;

  const TodayTask({
    required this.title,
    required this.reason,
    required this.route,
    this.station = '',
    this.doneCount = 0,
    this.totalCount = 4,
    this.allDone = false,
  });
}

/// مسیر هدایت‌شدهٔ امروز مثل Khan Kids: الفبا → جمع → نقاشی → قصه.
class TodayPath {
  TodayPath._();

  static const List<String> stations = <String>[
    'literacy',
    'math',
    'drawing',
    'story',
  ];

  static TodayTask forChild({String? today}) {
    final doneCount = countDone(today: today);
    if (GameData.isDailyLimitReached) {
      return TodayTask(
        title: 'امروز استراحت',
        reason: 'زمان بازی امروز تمام شده است.',
        route: '/parent',
        station: 'rest',
        doneCount: doneCount,
      );
    }

    if (!GameData.isTodayStationDone('literacy', today: today)) {
      final due = GameData.dueAlphabetReviewKeys(today: today);
      if (due.isNotEmpty) {
        return TodayTask(
          title: 'مرور الفبا',
          reason: 'نشانه‌ای که قبلاً نوشتی، امروز وقت مرور دارد.',
          route: '/alphabet',
          station: 'literacy',
          doneCount: doneCount,
        );
      }
      if (GameData.masteredAlphabetKeys.isEmpty) {
        return TodayTask(
          title: 'نشانهٔ آ',
          reason: 'هنوز مهری روی الفبا نزده‌ای؛ از آ شروع کن.',
          route: '/alphabet',
          station: 'literacy',
          doneCount: doneCount,
        );
      }
      return TodayTask(
        title: 'تمرین الفبا',
        reason: 'نشانهٔ امروز را بنویس.',
        route: '/alphabet',
        station: 'literacy',
        doneCount: doneCount,
      );
    }

    if (!GameData.isTodayStationDone('math', today: today)) {
      return TodayTask(
        title: 'جمع تا ۲۰',
        reason: 'تمرین جمع و تفریق امروز مانده.',
        route: '/math/add',
        station: 'math',
        doneCount: doneCount,
      );
    }

    if (!GameData.isTodayStationDone('drawing', today: today)) {
      return TodayTask(
        title: 'یک نقاشی',
        reason: 'مأموریت نقاشی امروز هنوز انجام نشده.',
        route: '/game/نقاشی',
        station: 'drawing',
        doneCount: doneCount,
      );
    }

    if (!GameData.isTodayStationDone('story', today: today)) {
      return TodayTask(
        title: 'قصهٔ کلاس اول',
        reason: 'حالا متن کوتاه با همان نشانه‌هایی که نوشتی.',
        route: '/stories/read',
        station: 'story',
        doneCount: doneCount,
      );
    }

    return const TodayTask(
      title: 'امروز تمام شد',
      reason: 'چهار کار امروز را انجام دادی. فردا کارت تازه می‌آید.',
      route: '/home',
      station: 'done',
      doneCount: 4,
      allDone: true,
    );
  }

  static int countDone({String? today}) {
    var n = 0;
    for (final station in stations) {
      if (GameData.isTodayStationDone(station, today: today)) n++;
    }
    return n;
  }

  /// ایستگاه بعدی بعد از تمام‌کردن [justFinished] — بدون نوشتن روی حافظه.
  static String? nextStationAfter(String? justFinished, {String? today}) {
    for (final station in stations) {
      if (station == justFinished) continue;
      if (!GameData.isTodayStationDone(station, today: today)) return station;
    }
    return null;
  }

  static const Map<String, String> stationTitles = <String, String>{
    'literacy': 'الفبا',
    'math': 'جمع تا ۲۰',
    'drawing': 'نقاشی',
    'story': 'قصه',
  };

  /// جمع‌بندی صادقانهٔ امروز — بدون نمرهٔ ساختگی.
  static List<String> recapLines({String? today}) {
    return [
      for (final station in stations)
        if (GameData.isTodayStationDone(station, today: today))
          stationTitles[station] ?? station,
    ];
  }
}
