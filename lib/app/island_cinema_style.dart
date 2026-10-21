import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎬 CINEMATIC ISLAND — زبان بصریِ «جزیرهٔ زندهٔ فندقی»
///
/// این فایل فقط «نشانه‌های طراحی» است: رنگ، گرادیان، زمان‌بندی و
/// رشته‌ها. هیچ ویجتی اینجا ساخته نمی‌شود، تا:
///   * یک تغییر در پالت = کل صفحهٔ اصلی یکدست تغییر کند؛
///   * رشته‌های فارسی از میان کدهای پراکنده بیرون بیایند و
///     قابل بازبینی/ترجمه بمانند؛
///   * طراح بدون خواندن منطقِ صفحه بتواند حرکت‌ها را تنظیم کند.
///
/// این نشانه‌ها *افزوده*اند و کنار [IslandWorldPalette] زندگی می‌کنند؛
/// صفحه‌های قدیمی تا زمان مهاجرت ظاهر خود را حفظ می‌کنند.
/// ═══════════════════════════════════════════════════════════════

// ─────────────────────────── رنگ ───────────────────────────
abstract final class IslandCinemaPalette {
  // آسمان: از اوجِ آبی تا گرمایِ نزدیکِ افق
  static const Color skyHigh = Color(0xFF2C7FC4);
  static const Color skyMid = Color(0xFF8AD9F5);
  static const Color skyLow = Color(0xFFFFF1CF);

  // خورشیدِ سینمایی
  static const Color sunCore = Color(0xFFFFFBEA);
  static const Color sunGlow = Color(0xFFFFD977);
  static const Color sunHalo = Color(0xFFFFB74D);

  // آبِ فیروزه‌ای: دور → نزدیک → عمق
  static const Color seaFar = Color(0xFF6FE0E4);
  static const Color seaMid = Color(0xFF2FBBD4);
  static const Color seaNear = Color(0xFF1595B8);
  static const Color seaDeep = Color(0xFF0B5B84);
  static const Color foam = Color(0xFFEAFCFF);

  // کوه‌های دوردست (مه‌آلود)
  static const Color ridgeFar = Color(0xFFA6CFE4);
  static const Color ridgeNear = Color(0xFF6FA6C4);

  // خاک و صخرهٔ جزیره
  static const Color cliff = Color(0xFFB08359);
  static const Color cliffShade = Color(0xFF7C5537);
  static const Color cliffDeep = Color(0xFF51351F);

  // پوشش گیاهی: سبز جنگلیِ هویت برند
  static const Color forest = Color(0xFF1E7A44);
  static const Color forestDeep = Color(0xFF12532F);
  static const Color meadow = Color(0xFF4EB85A);
  static const Color meadowLight = Color(0xFF9BD96A);
  static const Color mint = Color(0xFF8FE3B0);

  // چوبِ پل، تابلو و خانه‌ها
  static const Color wood = Color(0xFFB0763F);
  static const Color woodShade = Color(0xFF7E4E26);
  static const Color woodDeep = Color(0xFF5A3618);

  // طلاییِ لوگو و اقدام اصلی
  static const Color goldLight = Color(0xFFFFF3BE);
  static const Color gold = Color(0xFFFFC542);
  static const Color goldRich = Color(0xFFF0A021);
  static const Color goldDeep = Color(0xFFC97A11);
  static const Color bronze = Color(0xFF9C5F14);

  // نارنجیِ شخصیت فندقی
  static const Color fandoqi = Color(0xFFF2924C);
  static const Color fandoqiDeep = Color(0xFFD2651F);

  // رنگ‌های تفکیکِ سه مسیر اصلی
  static const Color pathPlay = Color(0xFF8E6CF0);
  static const Color pathPlayDeep = Color(0xFF5B3FBF);
  static const Color pathLearn = Color(0xFF3FA8E0);
  static const Color pathLearnDeep = Color(0xFF1F6FA5);
  static const Color pathStory = Color(0xFFF0729C);
  static const Color pathStoryDeep = Color(0xFFC13F70);

  // متن و لایه‌های تیره
  static const Color ink = Color(0xFF2A3A45);
  static const Color inkSoft = Color(0xFF5A6E78);
  static const Color paper = Color(0xFFFFFBF0);
  static const Color shade = Color(0xFF06202E);

  // درخشش‌های کم‌جان (هرگز چشمک‌زن و تند)
  static const Color sparkle = Color(0xFFFFF4C4);
}

// ──────────────────────── گرادیان‌ها ────────────────────────
abstract final class IslandCinemaGradients {
  static const LinearGradient sky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      IslandCinemaPalette.skyHigh,
      IslandCinemaPalette.skyMid,
      IslandCinemaPalette.skyLow,
    ],
    stops: <double>[0.0, 0.58, 1.0],
  );

  static const LinearGradient sea = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      IslandCinemaPalette.seaFar,
      IslandCinemaPalette.seaMid,
      IslandCinemaPalette.seaNear,
      IslandCinemaPalette.seaDeep,
    ],
    stops: <double>[0.0, 0.34, 0.68, 1.0],
  );

  /// رویهٔ دکمهٔ اصلی: از کرمِ روشنِ بالا تا طلاییِ پایین
  static const LinearGradient goldFace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      IslandCinemaPalette.goldLight,
      IslandCinemaPalette.gold,
      IslandCinemaPalette.goldRich,
    ],
    stops: <double>[0.0, 0.46, 1.0],
  );

  static const LinearGradient meadow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      IslandCinemaPalette.meadowLight,
      IslandCinemaPalette.meadow,
      IslandCinemaPalette.forest,
    ],
    stops: <double>[0.0, 0.42, 1.0],
  );
}

// ───────────────────────── اندازه‌ها ─────────────────────────
abstract final class IslandCinemaMetrics {
  /// کمینهٔ هدف لمسی برای دستِ کوچک کودک (بزرگ‌تر از استاندارد ۴۸)
  static const double minTouch = 60;

  /// بلندای دکمهٔ اصلیِ «شروع بازی»
  static const double startButtonHeight = 78;

  /// بلندای کارت‌های سه مسیر اصلی
  static const double pathCardHeight = 116;

  /// شعاع گوشهٔ کارت‌ها و دکمه‌ها
  static const double radius = 26;

  /// ضخامت لبهٔ برجستهٔ دکمه‌های سه‌بعدی
  static const double extrusion = 7;

  /// بودجهٔ ذراتِ درخشانِ محیط (حافظه/CPU روی گوشی ضعیف)
  static const int sparkleBudget = 12;
}

// ───────────────────── لوگوهای تصویریِ دکمه‌های خانه ─────────────────────
/// مسیرِ لوگوهای سه‌بعدیِ کودک‌پسندِ دکمه‌های صفحهٔ اصلی تا کودکانِ پیش‌دبستانی
/// حتی پیش از خواندنِ متن، مقصدِ هر دکمه را در یک نگاه بشناسند.
abstract final class IslandHomeLogos {
  /// 🧭🏝️ شروع ماجراجویی — جزیرهٔ گنج، قطب‌نما و نقشهٔ ماجراجویی
  static const String adventure = 'assets/theme_v2/btn_adventure_logo.webp';

  /// 📺🍿 کارتون‌ها — تلویزیونِ خندانِ کارتون و پاپ‌کورن
  static const String cartoons = 'assets/theme_v2/btn_cartoons_logo.webp';

  /// 📖🏰 قصه‌ها — کتابِ بازِ قصه با قلعه و ستارهٔ جادویی
  static const String stories = 'assets/theme_v2/btn_stories_logo.webp';

  /// 🌙🧸 لالایی — هلالِ ماهِ مهربان، خرسِ خواب‌آلود و نت‌های موسیقی
  static const String lullabies = 'assets/theme_v2/btn_lullabies_logo.webp';

  /// 🎮🧩 بازی‌ها — دستهٔ بازیِ رنگارنگ، پازل و ستاره
  static const String games = 'assets/theme_v2/btn_games_logo.webp';
}

// ─────────────────────── زمان‌بندی حرکت ───────────────────────
abstract final class IslandCinemaMotion {
  /// چرخهٔ کاملِ محیط (آب، آبشار، ذرات)
  static const Duration ambientLoop = Duration(seconds: 14);

  /// ورودِ فندقی به صحنه
  static const Duration heroEntrance = Duration(milliseconds: 900);

  /// دم‌وبازدمِ ملایمِ فندقی
  static const Duration heroBreath = Duration(milliseconds: 3400);

  /// پلک (مکثِ کوتاهِ چهره)
  static const Duration heroBlink = Duration(milliseconds: 150);

  /// جشنِ کوتاه پس از لمس یا پایان فعالیت
  static const Duration heroCheer = Duration(milliseconds: 1150);

  /// فشرده‌شدنِ دکمه
  static const Duration pressIn = Duration(milliseconds: 90);
  static const Duration pressOut = Duration(milliseconds: 220);
}

// ───────────────────── رشته‌های صفحهٔ اصلی ─────────────────────
/// همهٔ متن‌های صفحهٔ اصلی در یک‌جا تا ترجمه/بازبینیِ آینده آسان باشد
/// و هیچ برچسبی در میان کد گم نشود.
abstract final class IslandHomeStrings {
  static const String appName = 'جزیره فندقی';

  /// دکمهٔ اصلی
  static const String start = 'شروع بازی';

  /// نام‌های قدیمیِ مسیرهای اصلی (برای سازگاری با بخش‌های دیگر)
  static const String play = 'بازی';
  static const String learn = 'آموزش';
  static const String story = 'داستان';

  /// نقشهٔ کامل جزیره — مقصدِ دکمهٔ اصلیِ «شروع ماجراجویی».
  /// نام‌های قدیمیِ `adventureMap` برای سازگاری نگه داشته شده‌اند
  /// (دکمهٔ جداگانهٔ نقشه از صفحهٔ اصلی حذف شده است).
  static const String islandMap = 'نقشه جزیره';
  static const String adventureMap = 'نقشه ماجراجویی';
  static const String adventureMapHint = 'بازکردن نقشه کامل جزیره';

  /// میان‌برهای مستقیمِ صفحهٔ اصلی
  static const String cartoons = 'کارتون‌ها';
  static const String stories = 'قصه‌ها';
  static const String lullabies = 'لالایی';
  static const String games = 'بازی‌ها';

  /// برچسب‌های دسترس‌پذیری و راهنما
  static const String startHint = 'بازکردن نقشه کامل جزیره';
  static const String playHint = 'شهربازی و بازی‌های فندقی';
  static const String learnHint = 'حروف، اعداد و یادگیری';
  static const String storyHint = 'قصه‌ها و لالایی‌ها';
  static const String islandMapHint = 'همهٔ بخش‌های جزیره';
  static const String parentSettings = 'تنظیمات والدین';
  static const String profile = 'پروفایل من';
  static const String voiceGuideOn = 'راهنمای صوتی روشن';
  static const String voiceGuideOff = 'راهنمای صوتی خاموش';
  static const String dailyGift = 'هدیهٔ روزانه';
  static const String library = 'کتابخانه';

  /// پیام‌های تشویقیِ کوتاه (هرگز تنبیهی/ترسناک)
  static const String cheer = 'آفرین!';
  static const String restDay = 'امروز استراحت';
  static const String dailyLimitBody =
      'زمان بازی امروز تمام شد. فردا دوباره با هم بازی می‌کنیم.';
}
