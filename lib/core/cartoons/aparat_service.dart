import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎬 APARAT SERVICE — دریافت لینک مستقیم پخش از سرورهای ایران
///
/// لینک‌های مستقیم آپارات (CDN ایران) بعد از چند ساعت منقضی می‌شوند،
/// بنابراین به‌جای لینک مستقیم ثابت، «هش ویدیو» را ذخیره می‌کنیم و لینک
/// مستقیمِ قابل پخش را **در لحظه** از سرور آپارات می‌گیریم.
///
/// 🛡️ سیاست ایمنی کودک (C2):
/// این سرویس **هرگز جستجو نمی‌کند**. فقط ویدیوهایی پخش می‌شوند که هش آن‌ها
/// از قبل در کاتالوگ `CartoonData` توسط تیم محتوا بررسی و تأیید شده است
/// (وایت‌لیست). اگر resolve شکست بخورد، هیچ ویدیوی جایگزینی پخش نمی‌شود و
/// UI پیام «الان قابل پخش نیست» را نشان می‌دهد. همچنین هر URL پخش/پوستر
/// باید HTTPS و روی دامنه‌های مجاز آپارات باشد.
/// ═══════════════════════════════════════════════════════════════

/// یک منبع پخش با یک کیفیت مشخص.
class VideoStream {
  final String url;
  final String quality;

  const VideoStream({required this.url, required this.quality});

  @override
  String toString() => 'VideoStream($quality)';
}

/// نتیجهٔ resolve شدن یک ویدیو: لینک‌های مستقیم به‌ترتیب کیفیت + پوستر.
class AparatResolved {
  final List<VideoStream> streams;
  final String? posterUrl;
  final String? title;

  const AparatResolved({required this.streams, this.posterUrl, this.title});

  bool get hasSource => streams.isNotEmpty;
}

class AparatService {
  AparatService._();

  static const Duration _timeout = Duration(seconds: 18);

  // آپارات درخواست‌های بدون User-Agent/Referer را گاهی با پاسخ خالی رد می‌کند.
  static const Map<String, String> _headers = {
    'Accept': 'application/json, text/plain, */*',
    'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
    'Referer': 'https://www.aparat.com/',
  };

  // ═══════════════════════════════════════════════════════════
  // 🛡️ لایهٔ ایمنی محتوا (C2)
  // ═══════════════════════════════════════════════════════════

  /// دامنه‌های مجاز برای لینک پخش و پوستر. هر URL دیگری (حتی HTTPS) رد می‌شود
  /// تا اگر پاسخ API دستکاری/ری‌دایرکت شد، ویدیوی ناشناس روی کودک باز نشود.
  /// برای افزودن CDN جدید آپارات فقط همین لیست را گسترش دهید.
  static const List<String> allowedHosts = <String>[
    'aparat.com',
    'aparat.ir',
    'aparat-cdn.ir',
    'aparatcdn.com',
    'aparat.cloud',
    'arvanvod.ir',
    'arvanvod.com',
  ];

  /// فرمت مجاز هش ویدیو در آپارات (حروف/عدد/خط تیره).
  static final RegExp _hashPattern = RegExp(r'^[A-Za-z0-9_-]{3,32}$');

  static Set<String>? _approvedHashesCache;

  /// وایت‌لیست هش‌ها — تنها منبع حقیقت، مستقیماً از کاتالوگ تأییدشدهٔ محتوا.
  static Set<String> get approvedHashes {
    return _approvedHashesCache ??= <String>{
      for (final cartoon in CartoonData.allCartoons)
        for (final episode in cartoon.episodes)
          if (episode.aparatHash != null && episode.aparatHash!.trim().isNotEmpty)
            episode.aparatHash!.trim(),
    };
  }

  /// آیا این هش در کاتالوگ تأییدشدهٔ اپ وجود دارد؟
  static bool isApprovedHash(String? hash) {
    final value = hash?.trim() ?? '';
    if (value.isEmpty) return false;
    if (!_hashPattern.hasMatch(value)) return false;
    return approvedHashes.contains(value);
  }

  /// آیا این URL برای پخش روی دستگاه کودک امن است؟
  /// شرط: HTTPS + دامنهٔ مجاز + پسوند/مسیر رسانه‌ای.
  static bool isPlayableStreamUrl(String? url) {
    final value = url?.trim() ?? '';
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    // Cartoon playback is networked, but all trusted Aparat endpoints use TLS.
    // Rejecting clear-text streams prevents media URL downgrade attacks.
    if (uri.scheme != 'https') return false;
    if (!_isAllowedHost(uri.host)) return false;
    final path = uri.path.toLowerCase();
    // CDN آپارات گاهی URL بدون پسوند یا با query امضاشده می‌دهد.
    return path.contains('.mp4') ||
        path.contains('.m3u8') ||
        path.contains('/video') ||
        path.contains('/vod') ||
        path.contains('/stream') ||
        path.contains('/hls');
  }

  /// آیا این URL برای نمایش پوستر امن است؟ (HTTPS + دامنهٔ مجاز)
  static bool isAllowedImageUrl(String? url) {
    final value = url?.trim() ?? '';
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    if (uri.scheme != 'https') return false;
    return _isAllowedHost(uri.host);
  }

  /// تطبیق دقیق دامنه (نه `contains`) تا آدرسی مثل
  /// `https://evil.com/aparat.com/x.mp4` عبور نکند.
  static bool _isAllowedHost(String host) {
    final h = host.toLowerCase();
    for (final allowed in allowedHosts) {
      if (h == allowed || h.endsWith('.$allowed')) return true;
    }
    return false;
  }

  // کشِ موقت برای جلوگیری از درخواست تکراری (لینک‌ها چندساعت معتبرند).
  static final Map<String, AparatResolved> _cache = {};
  static final Map<String, DateTime> _cacheTime = {};
  static const Duration _cacheTtl = Duration(hours: 2);

  static bool get isCacheHealthy {
    // در صورت رشد بیش‌ازحد حافظه، کش را پاک می‌کنیم.
    return _cache.length < 200;
  }

  /// بررسی ساده دسترسی به اینترنت (فقط برای پیام مناسب به کاربر).
  static Future<bool> hasInternet() async {
    try {
      final r = await http
          .head(Uri.parse('https://www.aparat.com'), headers: _headers)
          .timeout(_timeout);
      return r.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  /// دریافت لینک مستقیم پخش برای یک هش ویدیوی **تأییدشده**.
  ///
  /// اگر هش در وایت‌لیست کاتالوگ نباشد یا resolve شکست بخورد، نتیجهٔ خالی
  /// برمی‌گردد؛ **هیچ ویدیوی جایگزینی جستجو یا پخش نمی‌شود** (C2).
  static Future<AparatResolved> resolve({String? videoHash}) async {
    final hash = videoHash?.trim() ?? '';
    if (!isApprovedHash(hash)) return const AparatResolved(streams: []);

    final cached = _cached(hash);
    if (cached != null) return cached;

    final resolved = await _resolveByHash(hash);
    if (resolved.hasSource) _setCache(hash, resolved);
    return resolved;
  }

  static AparatResolved? _cached(String key) {
    final v = _cache[key];
    final t = _cacheTime[key];
    if (v == null || t == null) return null;
    if (DateTime.now().difference(t) > _cacheTtl) {
      _cache.remove(key);
      _cacheTime.remove(key);
      return null;
    }
    return v;
  }

  static void _setCache(String key, AparatResolved value) {
    if (!isCacheHealthy) {
      _cache.clear();
      _cacheTime.clear();
    }
    _cache[key] = value;
    _cacheTime[key] = DateTime.now();
  }

  static Future<AparatResolved> _resolveByHash(String hash) async {
    // دفاع در عمق: هش هرگز مستقیماً داخل URL بدون اعتبارسنجی نمی‌رود.
    if (!_hashPattern.hasMatch(hash)) return const AparatResolved(streams: []);
    final endpoints = [
      // API فعلی آپارات؛ endpoint قدیمی /etc/api برای بسیاری از ویدیوها
      // دیگر لینک پخش برنمی‌گرداند.
      'https://www.aparat.com/api/fa/v1/video/video/show/videohash/$hash?pr=1&mf=1&referer=direct',
      'https://www.aparat.com/etc/api/video/videohash/$hash',
      'https://api.aparat.com/etc/api/video/videohash/$hash',
    ];
    for (var attempt = 0; attempt < 2; attempt++) {
      for (final ep in endpoints) {
        try {
          final res = await http.get(Uri.parse(ep), headers: _headers).timeout(_timeout);
          if (res.statusCode != 200) continue;
          final parsed = _parseVideoJson(res.body);
          // برای نمایش پوستر در کارت‌ها، حتی اگر لینک پخش پیدا نشود هم
          // نتیجه را برمی‌گردانیم تا عکس شخصیت‌ها از دست نرود.
          if (parsed.hasSource || parsed.posterUrl != null) return parsed;
        } catch (_) {
          // ادامه به endpoint بعدی
        }
      }
      if (attempt == 0) {
        // تاخیر کوتاه قبل از تلاش دوم در نوسانات لحظه‌ای اینترنت
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return const AparatResolved(streams: []);
  }

  // ═══════════════════════════════════════════════════════════
  // 🖼️ پوستر / تصویر شاخص (tumbnail) — با کش دائمی برای نمایش در کارت‌ها
  // ═══════════════════════════════════════════════════════════

  static final Map<String, String> _thumbMemCache = {};
  static final Map<String, Future<String?>> _thumbInFlight = {};
  static SharedPreferences? _prefs;

  static const String _thumbPrefPrefix = 'aparat_thumb_v1_';
  static const String _thumbPrefTimePrefix = 'aparat_thumb_t_';
  static const Duration _thumbCacheTtl = Duration(days: 30);

  /// کلید یکتا برای کش پوستر (فقط هش تأییدشده).
  static String _thumbKey(String? videoHash) {
    final hash = videoHash?.trim() ?? '';
    if (hash.isEmpty) return '';
    return 'h_$hash';
  }

  static Future<SharedPreferences> _prefsInstance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// URL پوسترِ از قبل کش‌شده (هم‌روند) — برای نمایش فوری در UI بدون چشمک‌زدن.
  static String? cachedThumbnail({String? videoHash}) {
    if (!isApprovedHash(videoHash)) return null;
    final key = _thumbKey(videoHash);
    if (key.isEmpty) return null;
    final mem = _thumbMemCache[key];
    if (mem != null) return mem;
    final prefs = _prefs;
    if (prefs == null) return null;
    final url = prefs.getString('$_thumbPrefPrefix$key');
    final time = prefs.getInt('$_thumbPrefTimePrefix$key') ?? 0;
    final isFresh = DateTime.now().millisecondsSinceEpoch - time < _thumbCacheTtl.inMilliseconds;
    // کش قدیمی ممکن است حاوی آدرسی خارج از دامنه‌های مجاز باشد؛ دوباره اعتبارسنجی می‌کنیم.
    if (url != null && isFresh && isAllowedImageUrl(url)) {
      _thumbMemCache[key] = url;
      return url;
    }
    return null;
  }

  /// دریافت URL پوستر نمایشی برای یک ویدیوی تأییدشده — با کش حافظه + دیسک و
  /// بدون ارسال درخواست‌های تکراری موازی. در صورت شکست، `null` برمی‌گرداند.
  static Future<String?> thumbnailFor({String? videoHash}) {
    if (!isApprovedHash(videoHash)) return Future.value(null);
    final key = _thumbKey(videoHash);
    if (key.isEmpty) return Future.value(null);

    final inFlight = _thumbInFlight[key];
    if (inFlight != null) return inFlight;

    final future = _thumbnailForInner(key, videoHash!.trim())
        .whenComplete(() => _thumbInFlight.remove(key));
    _thumbInFlight[key] = future;
    return future;
  }

  static Future<String?> _thumbnailForInner(String key, String videoHash) async {
    // ۱) کش حافظه‌ای
    final mem = _thumbMemCache[key];
    if (mem != null) return mem;

    // ۲) کش دیسک با اعتبار TTL
    final prefs = await _prefsInstance();
    final diskUrl = prefs.getString('$_thumbPrefPrefix$key');
    final diskTime = prefs.getInt('$_thumbPrefTimePrefix$key') ?? 0;
    final diskFresh = DateTime.now().millisecondsSinceEpoch - diskTime < _thumbCacheTtl.inMilliseconds;
    if (diskUrl != null && diskFresh && isAllowedImageUrl(diskUrl)) {
      _thumbMemCache[key] = diskUrl;
      return diskUrl;
    }

    // ۳) واکشی از شبکه — فقط با هش تأییدشده. جستجوی متنی حذف شده است (C2).
    // اگر پاسخ، لینک پخش هم داشت، آن را هم کش می‌کنیم تا شروع پخش فوری‌تر شود.
    final byHash = await _resolveByHash(videoHash);
    if (byHash.hasSource) _setCache(videoHash, byHash);
    final poster = byHash.posterUrl?.trim() ?? '';

    if (poster.isNotEmpty && isAllowedImageUrl(poster)) {
      _thumbMemCache[key] = poster;
      await prefs.setString('$_thumbPrefPrefix$key', poster);
      await prefs.setInt('$_thumbPrefTimePrefix$key', DateTime.now().millisecondsSinceEpoch);
      return poster;
    }
    return null;
  }

  /// پیش‌بارگیری آرام پوستر مجموعه‌ای از کارتون‌ها در پس‌زمینه،
  /// تا وقتی کارت‌ها دیده می‌شوند ارائهٔ بصری تقریباً آماده باشد.
  /// [onProgress] بعد از هر پوستر موفق فراخوانی می‌شود تا UI به‌روز شود.
  static void prefetchCartoonCovers(
    Iterable<String?> hashes, {
    void Function()? onProgress,
  }) {
    Future.microtask(() async {
      for (final hash in hashes) {
        try {
          final url = await thumbnailFor(videoHash: hash);
          if (url != null && onProgress != null) onProgress();
        } catch (_) {
          // نادیده گرفتن خطای پیش‌بارگیری؛ کارت‌ها خودشان دوباره تلاش می‌کنند.
        }
      }
    });
  }

  /// پارس کردن پاسخ ویدیو و استخراج لینک‌های مستقیم به‌ترتیب کیفیت.
  static AparatResolved _parseVideoJson(String body) {
    try {
      final decoded = jsonDecode(body);
      final streams = <VideoStream>[];
      String? poster;        // بهترین کیفیت (big)
      String? posterSmall;   // کیفیت کوچک‌تر (small)
      String? title;

      // پاسخ API در نسخه‌های مختلف، داخل data.attributes یا مستقیماً در data
      // قرار می‌گیرد. به‌صورت بازگشتی می‌خوانیم تا تغییر جزئی schema دوباره
      // باعث از کار افتادن تمام کارتون‌ها نشود.
      void walk(dynamic node, {String quality = 'auto', String key = ''}) {
        if (node is Map) {
          for (final entry in node.entries) {
            final k = entry.key.toString().toLowerCase();
            final value = entry.value;
            if (value is String && isPlayableStreamUrl(value) && (_isStreamKey(k) || _isStreamKey(key) || RegExp(r'^(144|240|360|480|720|1080)p?$').hasMatch(k))) {
              final q = _qualityFrom(k, quality);
              if (!streams.any((s) => s.url == value)) {
                streams.add(VideoStream(url: value, quality: q));
              }
            } else if (value is Map || value is List) {
              walk(value, quality: _qualityFrom(k, quality), key: k);
            }
            if (value is String && isAllowedImageUrl(value)) {
              if (k == 'big_poster') {
                poster ??= value;
              } else if (k == 'small_poster') {
                posterSmall ??= value;
              } else if (poster == null && posterSmall == null && k.contains('poster')) {
                posterSmall = value;
              }
            }
            if (title == null && value is String && k == 'title') title = value;
          }
        } else if (node is List) {
          for (final value in node) {
            if (value is String && isPlayableStreamUrl(value) && (_isStreamKey(key) || key == 'urls')) {
              if (!streams.any((s) => s.url == value)) {
                streams.add(VideoStream(url: value, quality: quality));
              }
            } else {
              walk(value, quality: quality, key: key);
            }
          }
        }
      }

      walk(decoded);
      return AparatResolved(streams: streams, posterUrl: poster ?? posterSmall, title: title);
    } catch (_) {
      return const AparatResolved(streams: []);
    }
  }

  static bool _isStreamKey(String key) {
    return key == 'url' || key == 'src' || key == 'file_link' ||
        key == 'file_link_all' || key == 'file' || key == 'stream' ||
        key == 'stream_url' || key == 'play_url' || key == 'download_url' ||
        key == 'video_url' || key == 'urls';
  }

  static String _qualityFrom(String key, String fallback) {
    final match = RegExp(r'(144|240|360|480|720|1080)p?').firstMatch(key);
    return match == null ? fallback : '${match.group(1)}p';
  }

  /// فقط برای تست‌ها: پاک‌سازی کش‌های درون‌حافظه‌ای.
  static void resetForTesting() {
    _cache.clear();
    _cacheTime.clear();
    _thumbMemCache.clear();
    _thumbInFlight.clear();
    _approvedHashesCache = null;
  }
}
