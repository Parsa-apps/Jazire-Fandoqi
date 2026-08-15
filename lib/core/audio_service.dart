import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'game_data.dart';
import 'growth/parent_controls.dart';
import 'logger_service.dart';

/// ────────────────────────────────────────────────────────────
/// 🔊 سامانه صوتی آفلاین فندقی
///
/// افکت‌های بازی از `assets/audio/sfx` پخش می‌شوند (فایل‌های
/// سینثسایزشدهٔ نرم و کودک‌پسند). تلفظ حروف، اعداد، رنگ و شکل
/// هم آفلاین است.
///
/// داستان‌ها و لالایی‌ها از این کلاس رد نمی‌شوند — آن‌ها را
/// `StoryAudioService` و پخش‌کنندهٔ لالایی جداگانه مدیریت می‌کنند
/// و سشن صوتی‌شان نباید توسط افکت‌های UI قطع شود.
/// ────────────────────────────────────────────────────────────
class AudioService {
  static const String _sfxPath = 'assets/audio/sfx/';
  static const String _lettersPath = 'assets/audio/letters/';
  static const String _numbersPath = 'assets/audio/numbers/';
  static const String _learningPath = 'assets/audio/learning/';
  static const String _wordsPath = 'assets/audio/words/';
  static const String _bgmPath = 'assets/audio/bgm/';

  /// فهرست افکت‌های بسته‌بندی‌شده — برای تست و بازتولید.
  static const List<String> sfxNames = <String>[
    'tap',
    'click',
    'select',
    'back',
    'page',
    'swoosh',
    'bubble',
    'coin',
    'star',
    'correct',
    'success',
    'wrong',
    'error',
    'win',
    'lose',
    'levelup',
    'unlock',
    'tick',
    'countdown',
    'go',
    'sleep',
  ];

  /// بلندی هر دسته — UI آرام، جشن بلندتر، غلط هرگز بلند/ترسناک.
  static const Map<String, double> sfxVolumes = <String, double>{
    'tap': 0.40,
    'click': 0.36,
    'tick': 0.26,
    'back': 0.42,
    'page': 0.40,
    'swoosh': 0.46,
    'select': 0.50,
    'bubble': 0.56,
    'coin': 0.66,
    'star': 0.68,
    'correct': 0.70,
    'success': 0.68,
    'wrong': 0.44,
    'error': 0.38,
    'win': 0.78,
    'lose': 0.44,
    'levelup': 0.80,
    'unlock': 0.74,
    'countdown': 0.52,
    'go': 0.66,
    'sleep': 0.48,
  };

  static const double voiceVolume = 0.88;
  static const double defaultSfxVolume = 0.55;

  static const int _poolSize = 8;
  static final List<AudioPlayer> _sfxPool = List<AudioPlayer>.generate(
    _poolSize,
    (_) => AudioPlayer(
      handleInterruptions: false,
      handleAudioSessionActivation: false,
    ),
  );
  static int _poolIndex = 0;

  static final AudioPlayer _bgmPlayer = AudioPlayer(
    handleInterruptions: false,
    handleAudioSessionActivation: false,
  );

  /// فایل‌های گفتاری و نشانه‌های شنیداری روی پلیر جدا پخش می‌شوند تا افکت
  /// دکمه یا جشن، سؤال بازی و تلفظ آموزشی را قطع نکند.
  static final AudioPlayer _voicePlayer = AudioPlayer(
    handleInterruptions: false,
    handleAudioSessionActivation: false,
  );

  /// سقف امن موسیقی پس‌زمینه؛ کنترل کاربر به‌صورت ۰ تا ۱ روی این مقدار
  /// اعمال می‌شود. ۵۰٪ از این سقف همان میکس قبلی ۰٫۲۲ است.
  static const double _maximumBgmVolume = 0.44;
  static const double _duckedBgmFactor = 0.10;
  static String? _currentBgmAsset;
  static String? _loadedBgmAsset;
  static int _bgmRequest = 0;
  static int _foregroundAudioCount = 0;

  /// موتور TTS — فقط برای محتوای پویا و به‌عنوان آخرین راه.
  static final FlutterTts _tts = FlutterTts();

  static final List<String> _speechQueue = <String>[];
  static bool _speaking = false;

  /// شمارندهٔ نشست هجی‌کردن؛ هر درخواست تازه، هجی قبلی را باطل می‌کند.
  static int _spellSession = 0;

  static bool _initialized = false;
  static bool _ttsAvailable = false;

  /// فاز H2: راه‌اندازی صدا از مسیر بحرانی اولین فریم خارج شده است.
  /// این Future یک‌بار ساخته و کش می‌شود (همان الگوی `GameData._loadFuture`)
  /// تا هر مسیری که زودتر از موعد صدا بخواهد، منتظر همان راه‌اندازی بماند
  /// و رفتار دقیقاً مثل قبل باقی بماند.
  static Future<void>? _initFuture;

  static String? _lastSfxName;
  static DateTime _lastSfxAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _uiDebounce = Duration(milliseconds: 45);
  static const Set<String> _uiSfx = <String>{'tap', 'click', 'tick'};

  /// راه‌اندازی صوت. idempotent است و می‌توان بدون `await` صدایش زد؛
  /// خودِ متدهای پخش قبل از کار، منتظر پایان همین Future می‌مانند.
  static Future<void> init() {
    if (_initialized) return Future<void>.value();
    return _initFuture ??= _initInternal();
  }

  /// هر مسیر پخش صدا از این عبور می‌کند تا اگر راه‌اندازی هنوز تمام نشده
  /// باشد (چون بعد از اولین فریم شروع می‌شود) صدا از دست نرود.
  static Future<void> _ensureInitialized() {
    if (_initialized) return Future<void>.value();
    return init();
  }

  static Future<void> _initInternal() async {
    // بلندی هر هشت پلیر مستقل است؛ موازی انجام می‌شود تا هشت رفت‌وبرگشت
    // platform channel پشت‌سرهم صف نکشند.
    // این راه‌اندازی هرگز throw نمی‌کند: چون دیگر در main منتظرش نمی‌مانیم،
    // یک خطای صوتی نباید بعداً از داخل یک متد پخش بیرون بزند.
    try {
      await Future.wait<void>(<Future<void>>[
        for (final AudioPlayer player in _sfxPool)
          player.setVolume(defaultSfxVolume),
      ]);
    } catch (error) {
      LoggerService.e('Audio pool volume init failed', error);
    }

    // لحن گرم و کودکانه.
    //
    // ⚠️ نکتهٔ مهم (رفع باگ «صدای عربی»): روی خیلی از گوشی‌ها موتور TTS
    // فارسی نصب نیست. در آن حالت `setLanguage('fa-IR')` خطا نمی‌دهد و موتور
    // ساکت هم نمی‌ماند؛ متن فارسی را با نزدیک‌ترین زبانِ موجود — معمولاً
    // عربی — می‌خواند و صدای عربی با صدای ضبط‌شدهٔ فارسی قاطی می‌شود.
    // پس قبل از فعال‌کردن TTS، واقعاً بررسی می‌کنیم که زبان فارسی موجود
    // باشد؛ در غیر این صورت TTS خاموش می‌ماند و فقط فایل‌های ضبط‌شدهٔ
    // داخل اپ پخش می‌شوند.
    try {
      _ttsAvailable = await _hasPersianVoice();
      if (_ttsAvailable) {
        await _tts.setLanguage('fa-IR');
        await _tts.setPitch(1.22);
        await _tts.setSpeechRate(0.42);
        await _tts.setVolume(1.0);
        // Ducking باید تا پایان واقعی گفتار ادامه داشته باشد، نه فقط تا
        // تحویل متن به موتور TTS.
        await _tts.awaitSpeakCompletion(true);
      } else {
        LoggerService.i(
          'Persian TTS not installed — falling back to bundled recordings only',
        );
      }
    } catch (error) {
      _ttsAvailable = false;
      LoggerService.e('TTS unavailable on this device', error);
    }

    _initialized = true;
  }

  /// آیا موتور TTS دستگاه واقعاً فارسی حرف می‌زند؟
  ///
  /// هم `isLanguageAvailable` و هم فهرست زبان‌ها را چک می‌کنیم؛ بعضی
  /// دستگاه‌ها فقط یکی از این دو را درست پاسخ می‌دهند. اگر هیچ‌کدام فارسی
  /// را تأیید نکند، جواب منفی است تا هرگز صدای عربی/انگلیسی جای فارسی
  /// پخش نشود.
  static Future<bool> _hasPersianVoice() async {
    bool available = false;
    try {
      final dynamic result = await _tts.isLanguageAvailable('fa-IR');
      available = result == true;
    } catch (_) {
      available = false;
    }
    if (available) return true;

    try {
      final dynamic languages = await _tts.getLanguages;
      if (languages is List) {
        return languages
            .map((dynamic lang) => lang.toString().toLowerCase())
            .any((String lang) => lang.startsWith('fa'));
      }
    } catch (_) {}
    return false;
  }

  static bool get _muted =>
      !GameData.soundEnabled || ParentControls.shouldMuteSound;

  static AudioPlayer _acquirePlayer() {
    for (final AudioPlayer player in _sfxPool) {
      if (!player.playing) return player;
    }
    final AudioPlayer player = _sfxPool[_poolIndex];
    _poolIndex = (_poolIndex + 1) % _poolSize;
    return player;
  }

  static bool _shouldSkipDuplicate(String name) {
    if (!_uiSfx.contains(name)) return false;
    if (_lastSfxName != name) return false;
    return DateTime.now().difference(_lastSfxAt) < _uiDebounce;
  }

  /// پخش یک افکت از استخر (بدون قطع جشن در حال پخش).
  static Future<void> _playFromPool(
    String assetPath, {
    double volume = defaultSfxVolume,
  }) async {
    if (_muted) return;
    // اگر راه‌اندازی (که بعد از اولین فریم شروع می‌شود) هنوز تمام نشده،
    // اینجا کامل می‌شود تا هیچ افکتی از دست نرود.
    await _ensureInitialized();
    if (_muted) return;
    try {
      final AudioPlayer player = _acquirePlayer();
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.stop();
      await player.setAsset(assetPath);
      unawaited(player.play());
    } catch (error) {
      LoggerService.e('SFX missing: $assetPath', error);
    }
  }

  /// پخش محتوای اصلی شنیداری (تلفظ، سؤال یا صدای محیط) با Ducking خودکار.
  /// تا پایان فایل صبر می‌کند؛ بنابراین موسیقی دقیقاً در زمان درست برمی‌گردد.
  static Future<void> playVoiceAsset(
    String assetPath, {
    double volume = voiceVolume,
  }) async {
    if (_muted) return;
    await _ensureInitialized();
    if (_muted) return;
    beginForegroundAudio();
    try {
      await _voicePlayer.stop();
      await _voicePlayer.setVolume(volume.clamp(0.0, 1.0));
      await _voicePlayer.setAsset(assetPath);
      await _voicePlayer.play();
    } catch (error) {
      LoggerService.e('Voice asset missing: $assetPath', error);
    } finally {
      endForegroundAudio();
    }
  }

  static Future<void> playSfx(String name) async {
    if (_shouldSkipDuplicate(name)) return;
    _lastSfxName = name;
    _lastSfxAt = DateTime.now();
    final double volume = sfxVolumes[name] ?? defaultSfxVolume;
    await _playFromPool('$_sfxPath$name.wav', volume: volume);
  }

  static Future<void> tap() => playSfx('tap');
  static Future<void> click() => playSfx('click');
  static Future<void> select() => playSfx('select');
  static Future<void> back() => playSfx('back');
  static Future<void> page() => playSfx('page');
  static Future<void> swoosh() => playSfx('swoosh');
  static Future<void> bubble() => playSfx('bubble');
  static Future<void> coin() => playSfx('coin');
  static Future<void> star() => playSfx('star');
  static Future<void> correct() => playSfx('correct');
  static Future<void> success() => playSfx('success');
  static Future<void> wrong() => playSfx('wrong');
  static Future<void> error() => playSfx('error');
  static Future<void> win() => playSfx('win');
  static Future<void> lose() => playSfx('lose');
  static Future<void> levelUp() => playSfx('levelup');
  static Future<void> unlock() => playSfx('unlock');
  static Future<void> tick() => playSfx('tick');
  static Future<void> countdown() => playSfx('countdown');
  static Future<void> go() => playSfx('go');
  static Future<void> sleepChime() => playSfx('sleep');

  /// بازخورد لمسی + صوتی برای دکمه‌ها.
  static Future<void> buttonTap() async {
    HapticFeedback.lightImpact();
    await tap();
  }

  // ─────────────────────────── حروف الفبا (آفلاین) ───────────────────────────

  /// نویسه‌های عربی که ممکن است از کیبورد، متن‌های کپی‌شده یا داده‌های قدیمی
  /// وارد شوند و شکل فارسی‌شان با آن‌ها یکی نیست. اگر این‌ها نرمال نشوند،
  /// `letterIndex` آن‌ها را پیدا نمی‌کند و صدای حرف پخش نمی‌شود (یا بدتر:
  /// به TTS می‌افتد و روی گوشی‌های بدون فارسی با لهجهٔ عربی خوانده می‌شود).
  static const Map<String, String> _arabicToPersian = <String, String>{
    'ك': 'ک', // ARABIC KAF → PERSIAN KEHEH
    'ي': 'ی', // ARABIC YEH → FARSI YEH
    'ى': 'ی', // ALEF MAKSURA → FARSI YEH
    'ئ': 'ی',
    'ة': 'ه', // TEH MARBUTA → HEH
    'أ': 'ا',
    'إ': 'ا',
    'ٱ': 'ا',
    'ؤ': 'و',
    'ء': 'ا',
  };

  /// اعشار عربی‌ـهندی (٠١٢…) و فارسی (۰۱۲…) به ارقام لاتین.
  static const Map<String, String> _digitsToLatin = <String, String>{
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
    '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
  };

  /// حرف ورودی را به شکل استاندارد فارسی برمی‌گرداند:
  /// حذف اعراب/کشیده/نویسه‌های نامرئی + تبدیل نویسه‌های عربی.
  static String normalizeLetter(String input) {
    final StringBuffer buffer = StringBuffer();
    for (final int rune in input.runes) {
      // اعراب و علائم ترکیبی عربی (فتحه، کسره، تشدید، …)
      if (rune >= 0x064B && rune <= 0x065F) continue;
      if (rune == 0x0640) continue; // ـ (تطویل)
      if (rune == 0x0670) continue; // الف خنجری
      if (rune >= 0x200B && rune <= 0x200F) continue; // نویسه‌های نامرئی
      if (rune == 0xFEFF) continue;
      final String ch = String.fromCharCode(rune);
      buffer.write(_arabicToPersian[ch] ?? ch);
    }
    return buffer.toString().trim();
  }

  /// ارقام فارسی/عربی داخل متن را به لاتین تبدیل می‌کند تا `int.tryParse` کار کند.
  static String normalizeDigits(String input) {
    final StringBuffer buffer = StringBuffer();
    for (final String ch in input.split('')) {
      buffer.write(_digitsToLatin[ch] ?? ch);
    }
    return buffer.toString();
  }

  /// نگاشت حرف فارسی به شماره فایل صوتی (l01..l33).
  /// «آ» و «ا» دو فایل جدا دارند: l01 = «آ مثل آهو»، l33 = «الف مثل ابر».
  static const Map<String, int> letterIndex = {
    'آ': 1,
    'ا': 33,
    'ب': 2,
    'پ': 3,
    'ت': 4,
    'ث': 5,
    'ج': 6,
    'چ': 7,
    'ح': 8,
    'خ': 9,
    'د': 10,
    'ذ': 11,
    'ر': 12,
    'ز': 13,
    'ژ': 14,
    'س': 15,
    'ش': 16,
    'ص': 17,
    'ض': 18,
    'ط': 19,
    'ظ': 20,
    'ع': 21,
    'غ': 22,
    'ف': 23,
    'ق': 24,
    'ک': 25,
    'گ': 26,
    'ل': 27,
    'م': 28,
    'ن': 29,
    'و': 30,
    'ه': 31,
    'ی': 32,
  };

  static String? letterAssetFor(String letter) {
    final String key = normalizeLetter(letter);
    if (key.isEmpty) return null;
    // ورودی ممکن است «ب» یا «بـ» یا «بادبادک» باشد؛ اولین نویسهٔ شناخته‌شده ملاک است.
    final int? idx = letterIndex[key] ?? letterIndex[key.substring(0, 1)];
    if (idx == null) return null;
    return '$_lettersPath${'l${idx.toString().padLeft(2, '0')}'}.mp3';
  }

  /// تلفظ رسای حرف فارسی از فایل آفلاین.
  /// هرگز به TTS نمی‌افتد؛ اگر حرف ناشناخته باشد ساکت می‌ماند تا موتور
  /// پیش‌فرض دستگاه (که اغلب عربی است) اسم حرف را عربی نخواند.
  static Future<void> pronounceLetter(String letter) async {
    if (_muted) return;
    final String? asset = letterAssetFor(letter);
    if (asset == null) return;
    await playVoiceAsset(asset, volume: voiceVolume);
  }

  /// متن را برای خوانده‌شدن تمیز می‌کند: ایموجی، اعراب، نویسه‌های نامرئی و
  /// گیومه‌ها حذف می‌شوند ولی خود واژه (با نیم‌فاصله) دست‌نخورده می‌ماند.
  static String cleanSpokenText(String input) {
    final withoutEmoji = input
        .replaceAll(RegExp(r'[\p{Extended_Pictographic}]', unicode: true), ' ')
        // پرچم‌ها (🇮🇷) از دو Regional Indicator ساخته می‌شوند و در ردهٔ
        // Extended_Pictographic نیستند؛ باید جداگانه حذف شوند.
        .replaceAll(RegExp(r'[\u{1F1E6}-\u{1F1FF}]', unicode: true), ' ')
        .replaceAll(RegExp(r'[\uFE0E\uFE0F\u200D]'), ' ')
        .replaceAll(RegExp(r'[«»"“”:•]'), ' ');
    final buffer = StringBuffer();
    for (final rune in withoutEmoji.runes) {
      if (rune >= 0x064B && rune <= 0x065F) continue; // اعراب
      if (rune == 0x0670) continue;
      if (rune == 0x0640) continue; // ـ (کشیده/تطویل) خوانده نمی‌شود
      if (rune == 0x200B || rune == 0x200E || rune == 0x200F) continue;
      if (rune == 0xFEFF) continue;
      // ZWNJ (0x200C) عمداً حفظ می‌شود: بخشی از املای درست فارسی است.
      buffer.writeCharCode(rune);
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// ─────────────── واژه‌های کارگاه واژه‌سازی (آفلاین) ───────────────
  ///
  /// گوشیِ کودک معمولاً اینترنت و موتور TTS فارسی ندارد، پس کلمه‌های
  /// کارگاه واژه‌سازیِ آکادمی الفبا با صدای ضبط‌شده داخل خود اپ می‌آیند.
  /// کلید نگاشت، شکلِ **تمیزشدهٔ** کلمه است (بدون ایموجی/اعراب) تا با
  /// خروجی `cleanSpokenText` بخواند.
  static const Map<String, String> wordAudioKeys = <String, String>{
    'آب': 'w01',
    'بابا': 'w02',
    'باد': 'w03',
    'داد': 'w04',
    'آباد': 'w05',
    'مادر': 'w06',
    'توت': 'w07',
    'دوست': 'w08',
    'دست': 'w09',
    'سوت': 'w10',
    'باران': 'w11',
    'ایران': 'w12',
    'سبز': 'w13',
    'نان': 'w14',
    'زرد': 'w15',
    'شیر': 'w16',
    'یاس': 'w17',
    'اردک': 'w18',
    'ستاره': 'w19',
    'دریا': 'w20',
    'کفش': 'w21',
    'ورزش': 'w22',
    'پا': 'w23',
    'گل': 'w24',
    'کودک': 'w25',
    'فیل': 'w26',
    'خرس': 'w27',
    'قاشق': 'w28',
    'بلبل': 'w29',
    'برف': 'w30',
    'جوجه': 'w31',
    'خورشید': 'w32',
    'چتر': 'w33',
    'هواپیما': 'w34',
    'ژاله': 'w35',
    'صابون': 'w36',
    'عسل': 'w37',
    'حباب': 'w38',
    'طبل': 'w39',
    'غاز': 'w40',
    'ظرف': 'w41',
    // کلمه‌های نمونهٔ کارت درس (که در کارگاه تکرار نشده‌اند)
    'انار': 'w42',
    'سیب': 'w43',
    'تاب': 'w44',
    'رنگ': 'w45',
    'استخر': 'w46',
    'لب': 'w47',
    'ذرت': 'w48',
    'ثانیه': 'w49',
    'ضبط': 'w50',
    'ابر': 'w51',
    'ژله': 'w52',
    'ماه': 'w53',
    'وان': 'w54',
    'هلو': 'w55',
    'یخ': 'w56',
    // کلمه‌های کارت «اشکال چهارگانه» (شکل نشانه در آغاز/میان/پایان کلمه)
    'داس': 'w57',
    'نمد': 'w58',
    'پرچم': 'w59',
    'بادام': 'w60',
    'پسته': 'w61',
    'نرگس': 'w62',
    'او': 'w63',
    'دفتر': 'w64',
    'قند': 'w65',
    'دامن': 'w66',
    'آبی': 'w67',
    'سینی': 'w68',
    'امروز': 'w69',
    'نرده': 'w70',
    'نامه': 'w71',
    'کوه': 'w72',
    'گوشت': 'w73',
    'آتش': 'w74',
    'سایه': 'w75',
    'چای': 'w76',
    'موی': 'w77',
    'شکلات': 'w78',
    'نمک': 'w79',
    'پاک': 'w80',
    'گاو': 'w81',
    'سوپ': 'w82',
    'توپ': 'w83',
    'چپ': 'w84',
    'سگ': 'w85',
    'برگ': 'w86',
  };

  /// مسیر فایل ضبط‌شدهٔ یک کلمه، یا `null` اگر ضبط نشده باشد.
  static String? wordAssetFor(String word) {
    final key = wordAudioKeys[cleanSpokenText(word)];
    if (key == null) return null;
    return '$_wordsPath$key.wav';
  }

  /// آیا موتور فارسی دستگاه آمادهٔ خواندن واژه است؟
  /// (راه‌اندازی صوت را در صورت نیاز کامل می‌کند.)
  static Future<bool> canSpeakPersian() async {
    await _ensureInitialized();
    return _ttsAvailable;
  }

  /// 🗣️ خواندن یک «واژهٔ کامل» — نه هجی‌کردن حرف‌به‌حرف.
  ///
  /// کارگاه واژه‌سازی و کارت‌های نمونهٔ الفبا از این متد استفاده می‌کنند؛
  /// قبلاً حلقهٔ `pronounceLetter` روی تک‌تک نویسه‌ها اجرا می‌شد و نتیجه‌اش
  /// «الف… ب… ر…» (آن هم روی هم) بود، نه خواندن خود کلمه.
  ///
  /// ترتیب اولویت:
  ///   ۱. صدای ضبط‌شدهٔ داخل اپ (کاملاً آفلاین) — مسیر عادی.
  ///   ۲. اگر آن کلمه ضبط نشده باشد و موتور فارسی دستگاه موجود باشد، TTS.
  ///   ۳. در غیر این صورت `false` تا رابط کاربری تصمیم بگیرد (مثلاً هجی).
  ///
  /// هرگز به TTSِ غیرفارسی نمی‌افتد؛ روی گوشی‌های بدون فارسی این کار
  /// باعث خوانده‌شدن متن با لهجهٔ عربی می‌شد.
  static Future<bool> speakWord(String word) async {
    if (_muted) return false;
    final clean = cleanSpokenText(word);
    if (clean.isEmpty) return false;

    // لمس سریع چند کلمه نباید صداها را روی هم بیندازد: گفتار و هجیِ قبلی
    // قطع می‌شوند و فقط آخرین کلمه خوانده می‌شود.
    _spellSession++;
    _interruptSpeech();

    final asset = wordAssetFor(clean);
    if (asset != null) {
      await playVoiceAsset(asset, volume: voiceVolume);
      return true;
    }

    await _ensureInitialized();
    if (_muted || !_ttsAvailable) return false;
    await speak(clean);
    return true;
  }

  /// 🔡 هجی‌کردن آگاهانهٔ یک واژه: حرف‌ها **پشت سر هم** (نه هم‌زمان) با
  /// صدای ضبط‌شدهٔ فارسی خوانده می‌شوند. فقط وقتی صدا زده می‌شود که کودک
  /// عمداً هجی خواسته باشد.
  static Future<void> spellOut(
    String word, {
    Duration gap = const Duration(milliseconds: 90),
  }) async {
    if (_muted) return;
    final clean = cleanSpokenText(word);
    if (clean.isEmpty) return;
    // اگر کودک وسط هجی، کلمهٔ دیگری را لمس کند، هجی قبلی باید بمیرد؛
    // وگرنه دو رشتهٔ حرف روی هم پخش می‌شوند (همان باگ «تکرار حروف»).
    final int session = ++_spellSession;
    _interruptSpeech();
    for (final rune in clean.runes) {
      if (_muted || session != _spellSession) return;
      final ch = String.fromCharCode(rune);
      final asset = letterAssetFor(ch);
      if (asset == null) continue; // فاصله، نیم‌فاصله و نویسه‌های ناشناخته
      await playVoiceAsset(asset, volume: voiceVolume);
      if (session != _spellSession) return;
      await Future<void>.delayed(gap);
    }
  }

  // ─────────────────────────── اعداد (آفلاین) ───────────────────────────

  static String? numberAssetFor(int number) {
    if (number < 0 || number > 20) return null;
    return '$_numbersPath${'n${number.toString().padLeft(2, '0')}'}.mp3';
  }

  /// همان `numberAssetFor` ولی از روی متن — ارقام فارسی «۷» و عربی «٧»
  /// هم پشتیبانی می‌شوند تا بازی‌هایی که کلید متنی دارند به TTS نیفتند.
  static String? numberAssetForText(String text) {
    final int? value = int.tryParse(normalizeDigits(text).trim());
    if (value == null) return null;
    return numberAssetFor(value);
  }

  /// تلفظ عدد فارسی از فایل آفلاین (در صورت موجود بودن).
  static Future<void> speakNumber(int number) async {
    if (_muted) return;
    final String? asset = numberAssetFor(number);
    if (asset == null) return;
    await playVoiceAsset(asset, volume: voiceVolume);
  }

  /// تلفظ عدد از روی متن (با ارقام فارسی/عربی). اگر عدد در بستهٔ آفلاین
  /// نباشد، به TTS برمی‌گردد.
  static Future<void> speakNumberText(String text) async {
    if (_muted) return;
    final String? asset = numberAssetForText(text);
    if (asset != null) {
      await playVoiceAsset(asset, volume: voiceVolume);
      return;
    }
    await speak(text);
  }

  // ─────────────────────── واژه‌های آموزشی آفلاین ───────────────────────

  /// مسیر فایل ضبط‌شدهٔ کارت‌های رنگ و شکل را برمی‌گرداند.
  /// این دو بازی نباید به نصب‌بودن موتور فارسی TTS روی گوشی وابسته باشند.
  static String? learningVoiceAsset({
    required String topicId,
    required String cardId,
  }) {
    final match = RegExp(r'^[a-zA-Z](\d+)$').firstMatch(cardId);
    final index = int.tryParse(match?.group(1) ?? '');
    if (index == null) return null;
    final padded = index.toString().padLeft(2, '0');

    return switch (topicId) {
      'colors' when index >= 1 && index <= 12 =>
        '${_learningPath}colors/c$padded.wav',
      'shapes' when index >= 1 && index <= 10 =>
        '${_learningPath}shapes/s$padded.wav',
      _ => null,
    };
  }

  /// نام کارت را می‌خواند؛ برای رنگ‌ها و شکل‌ها همیشه از صدای بسته‌بندی‌شده
  /// داخل اپ استفاده می‌کند و برای موضوع‌های دیگر به TTS فارسی برمی‌گردد.
  static Future<void> speakLearningCard({
    required String topicId,
    required String cardId,
    required String fallbackText,
  }) async {
    if (_muted) return;
    final asset = learningVoiceAsset(topicId: topicId, cardId: cardId);
    if (asset != null) {
      await playVoiceAsset(asset, volume: voiceVolume);
      return;
    }
    await speak(fallbackText);
  }

  // ─────────────────────────── موسیقی پس‌زمینه ───────────────────────────

  static const Map<String, String> backgroundTracks = <String, String>{
    'home': '${_bgmPath}home_island.wav',
    'games': '${_bgmPath}games_adventure.wav',
    'cartoons': '${_bgmPath}cartoon_cinema.wav',
    'stories': '${_bgmPath}story_dreams.wav',
    'learning': '${_bgmPath}learning_garden.wav',
  };

  static bool get canPlayAudio => !_muted;
  static double get _effectiveBgmVolume =>
      _maximumBgmVolume *
      GameData.musicVolume *
      (_foregroundAudioCount > 0 ? _duckedBgmFactor : 1.0);

  static Future<void> playBgmSection(String section) async {
    final asset = backgroundTracks[section];
    if (asset == null) {
      stopBgm();
      return;
    }
    await playBgm(asset);
  }

  static Future<void> playBgm(String assetPath) async {
    _currentBgmAsset = assetPath;
    final request = ++_bgmRequest;
    if (_muted) return;
    await _ensureInitialized();
    if (_muted || request != _bgmRequest) return;
    try {
      if (_loadedBgmAsset != assetPath) {
        await _bgmPlayer.stop();
        if (request != _bgmRequest) return;
        await _bgmPlayer.setAsset(assetPath);
        _loadedBgmAsset = assetPath;
        await _bgmPlayer.setLoopMode(LoopMode.one);
      }
      await _bgmPlayer.setVolume(_effectiveBgmVolume);
      if (!_bgmPlayer.playing) unawaited(_bgmPlayer.play());
    } catch (error) {
      LoggerService.e('BGM missing: $assetPath', error);
    }
  }

  static void stopBgm() {
    _currentBgmAsset = null;
    _bgmRequest++;
    unawaited(_bgmPlayer.stop());
  }

  /// پیش‌نمایش فوری کنترل کاربر. [volume] نرمال‌شده و بین صفر تا یک است؛
  /// ذخیرهٔ مقدار نهایی بر عهدهٔ [GameData.setMusicVolume] است.
  static void setBgmVolume(double volume) {
    final normalized = volume.clamp(0.0, 1.0).toDouble();
    final duckFactor =
        _foregroundAudioCount > 0 ? _duckedBgmFactor : 1.0;
    unawaited(
      _bgmPlayer.setVolume(_maximumBgmVolume * normalized * duckFactor),
    );
  }

  /// هر صدای محتوایی (گوینده، داستان یا ویدیو) این جفت متد را صدا می‌زند.
  /// شمارنده باعث می‌شود هم‌پوشانی دو صدا، موسیقی را زودتر از موعد بلند نکند.
  static void beginForegroundAudio() {
    _foregroundAudioCount++;
    unawaited(_bgmPlayer.setVolume(_effectiveBgmVolume));
  }

  static void endForegroundAudio() {
    if (_foregroundAudioCount > 0) _foregroundAudioCount--;
    unawaited(_bgmPlayer.setVolume(_effectiveBgmVolume));
  }

  /// پس از تغییر کلید صدای صفحه اصلی، همه پلیرهای مرکزی فوراً همگام می‌شوند.
  static Future<void> syncSoundSetting() async {
    if (_muted) {
      _speechQueue.clear();
      try {
        await _tts.stop();
      } catch (_) {}
      await _voicePlayer.stop();
      for (final player in _sfxPool) {
        await player.stop();
      }
      await _bgmPlayer.pause();
      return;
    }
    final asset = _currentBgmAsset;
    if (asset != null) await playBgm(asset);
  }

  // ─────────────────────────── TTS پویا (فقط محتوای زنده) ───────────────────────────

  /// سخن گفتن برای محتوای کاملاً پویا که نمی‌توان از قبل ضبط کرد
  /// (مثل پاسخ‌های هوش مصنوعی دوست فندقی). روی دستگاه‌های بدون
  /// TTS بی‌صدا رد می‌شود.
  static Future<void> speak(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _muted) return;
    // `_ttsAvailable` تا پایان راه‌اندازی معلوم نیست؛ پس اول منتظر می‌مانیم
    // وگرنه اولین درخواست گفتار بی‌صدا رد می‌شد.
    await _ensureInitialized();
    if (_muted || !_ttsAvailable) return;

    final spoken = clean
        .replaceAll(RegExp(r'[\p{Extended_Pictographic}]', unicode: true), ' ')
        .trim();
    if (spoken.isEmpty) return;

    _speechQueue.add(spoken);
    if (!_speaking) {
      unawaited(_drainQueue());
    }
  }

  static bool get isSpeaking => _speaking;

  /// قطع گفتار در حال پخش، **بدون** دست‌زدن به پرچم `_speaking`.
  ///
  /// اگر حلقهٔ `_drainQueue` در حال اجرا باشد، `_tts.stop()` باعث می‌شود
  /// همان حلقه فوراً سراغ متن بعدی برود. صفر کردن `_speaking` اینجا یک
  /// حلقهٔ موازیِ دوم می‌ساخت و شمارندهٔ ducking را نامتوازن می‌کرد.
  static void _interruptSpeech() {
    _speechQueue.clear();
    try {
      _tts.stop();
    } catch (_) {}
  }

  static void stopSpeaking() {
    _speechQueue.clear();
    try {
      _tts.stop();
    } catch (_) {}
    _speaking = false;
  }

  static Future<void> _drainQueue() async {
    _speaking = true;
    beginForegroundAudio();
    try {
      while (_speechQueue.isNotEmpty && !_muted && _ttsAvailable) {
        final text = _speechQueue.removeAt(0);
        try {
          await _tts.speak(text);
        } catch (error) {
          LoggerService.e('TTS speak failed', error);
          break;
        }
      }
    } finally {
      _speaking = false;
      endForegroundAudio();
    }
  }

  // ─────────────────────────── سازگاری با نسخه قدیم ───────────────────────────

  static Future<void> playCorrect() => correct();
  static Future<void> playWrong() => wrong();
  static Future<void> playWin() => win();
  static Future<void> playCoin() => coin();

  static Future<void> playEffect(String assetPath) =>
      _playFromPool(assetPath, volume: defaultSfxVolume);

  static void dispose() {
    for (final AudioPlayer player in _sfxPool) {
      player.dispose();
    }
    _voicePlayer.dispose();
    _bgmPlayer.dispose();
  }
}
