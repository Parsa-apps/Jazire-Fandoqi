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
/// پاسخ آپارات سه نوع نشانی دارد:
///  ۱) `file_link_all[].urls[]` → فایل‌های MP4 مستقیم با کیفیت مشخص
///  ۲) `manifest` → پلی‌لیست HLS (همان چیزی که پخش‌کنندهٔ وب آپارات
///     استفاده می‌کند؛ برای هر کیفیت یک `chunk.m3u8`)
///  ۳) `hls_link` → پلی‌لیست HLS اصلی (adaptive)
///
/// `file_link` با پسوند `.apt` و `frame`/`frame_src` **رسانهٔ قابل پخش
/// نیستند** (یکی بستهٔ adaptive اختصاصی آپارات است و دیگری صفحهٔ HTML
/// embed). نسخهٔ قبلی این دو را هم «لینک پخش» حساب می‌کرد؛ نتیجه این بود
/// که برای ویدیوهای بدون MP4 دانلودی، یک صفحهٔ HTML یا فایل `.apt` به
/// ExoPlayer تحویل داده می‌شد و کارتون اصلاً پخش نمی‌شد. اکنون فقط
/// `.mp4` و `.m3u8` واقعی به پلیر می‌رسند.
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

  /// آیا این منبع HLS است؟ (پخش HLS برای آپارات پایدارتر از لینک MP4 است.)
  bool get isHls {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    return path.endsWith('.m3u8');
  }

  @override
  String toString() => 'VideoStream($quality${isHls ? ', hls' : ', mp4'})';
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

  static const Duration _timeout = Duration(seconds: 12);

  // سقف زمانی کلِ resolve: با ۵ endpoint و ۲ تلاش، نباید کودک را دقیقه‌ها
  // پشت اسپینر نگه داریم. هر endpoint فقط وقتی شروع می‌شود که هنوز وقت داریم.
  static const Duration _resolveBudget = Duration(seconds: 30);

  // آپارات درخواست‌های بدون User-Agent/Referer را گاهی با پاسخ خالی رد می‌کند.
  static const Map<String, String> _headers = {
    'Accept': 'application/json, text/plain, text/html, */*',
    'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Referer': 'https://www.aparat.com/',
  };

  // ═══════════════════════════════════════════════════════════
  // 🛡️ لایهٔ ایمنی محتوا (C2)
  // ═══════════════════════════════════════════════════════════

  /// دامنه‌های مجاز برای لینک پخش و پوستر (شامل کلیه CDNهای رسمی آپارات و هلدینگ صبایدیا).
  static const List<String> allowedHosts = <String>[
    'aparat.com',
    'aparat.ir',
    'aparat-cdn.ir',
    'aparatcdn.com',
    'aparat.cloud',
    'arvanvod.ir',
    'arvanvod.com',
    'arvancloud.ir',
    'arvancloud.com',
    'arvancloud.plus',
    'sabaidea.com',
    'sabaidea.ir',
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

  /// آیا این URL یک رسانهٔ واقعی (MP4/HLS) روی دامنهٔ مجاز است؟
  ///
  /// عمداً سخت‌گیر است: صفحهٔ تماشا (`/v/...`)، صفحهٔ embed
  /// (`/video/video/embed/...`) و فایل‌های `.apt` هیچ‌کدام ویدیوی
  /// قابل پخش برای ExoPlayer نیستند و نباید به پلیر برسند.
  static bool isPlayableStreamUrl(String? url) {
    final value = url?.trim() ?? '';
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    if (uri.scheme != 'https') return false;
    if (uri.host.isEmpty) return false;
    if (!_isAllowedHost(uri.host)) return false;

    final path = uri.path.toLowerCase();
    if (path.isEmpty) return false;

    // صفحه‌های HTML آپارات هرچقدر هم در path کلمهٔ video داشته باشند، رسانه نیستند.
    if (path.contains('/embed') ||
        path.contains('/result') ||
        path == '/v' ||
        path.startsWith('/v/') ||
        path.contains('/api/')) {
      return false;
    }

    // فقط فرمت‌های رسانه‌ای استاندارد و قابل‌پخش.
    return path.endsWith('.mp4') || path.endsWith('.m3u8');
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

  /// تطبیق دقیق دامنه تا آدرسی خارج از دامنه های مجاز عبور نکند.
  static bool _isAllowedHost(String host) {
    final h = host.toLowerCase();
    for (final allowed in allowedHosts) {
      if (h == allowed || h.endsWith('.$allowed')) return true;
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════
  // 🗂️ کش لینک پخش
  // ═══════════════════════════════════════════════════════════

  // لینک‌های CDN آپارات امضاشده‌اند و چند ساعت عمر دارند؛ کش کوتاه‌تر
  // (۱ ساعت) از تحویل لینک منقضی به پلیر جلوگیری می‌کند.
  static final Map<String, AparatResolved> _cache = {};
  static final Map<String, DateTime> _cacheTime = {};
  static const Duration _cacheTtl = Duration(hours: 1);

  static bool get isCacheHealthy {
    return _cache.length < 200;
  }

  /// پاک‌کردن کش یک ویدیو (یا کل کش) تا لینک تازه گرفته شود.
  ///
  /// وقتی پلیر در بارگذاری شکست می‌خورد، لینک امضاشده ممکن است منقضی
  /// شده باشد؛ این متد اجازه می‌دهد بدون بستن صفحه، resolve تازه انجام شود.
  static void invalidateCache({String? videoHash}) {
    final hash = videoHash?.trim() ?? '';
    if (hash.isEmpty) {
      _cache.clear();
      _cacheTime.clear();
      return;
    }
    _cache.remove(hash);
    _cacheTime.remove(hash);
  }

  /// بررسی ساده دسترسی به اینترنت.
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

  static Future<AparatResolved> _resolveByHash(
    String hash, {
    bool posterIsEnough = false,
  }) async {
    if (!_hashPattern.hasMatch(hash)) return const AparatResolved(streams: []);

    final endpoints = [
      // API فعلی آپارات — کامل‌ترین پاسخ: MP4 + manifest HLS + hls_link.
      'https://www.aparat.com/api/fa/v1/video/video/show/videohash/$hash?pr=1&mf=1&referer=direct',
      'https://www.aparat.com/etc/api/video/videohash/$hash',
      'https://api.aparat.com/etc/api/video/videohash/$hash',
      // آخرین راه‌ها: صفحهٔ ویدیو و صفحهٔ embed (فقط برای استخراج لینک
      // رسانه از HTML؛ اگر API هیچ لینکی نداد، player وب آپارات معمولاً
      // manifest را داخل همین صفحه تزریق می‌کند).
      'https://www.aparat.com/v/$hash',
      'https://www.aparat.com/video/video/embed/videohash/$hash/vt/frame',
    ];

    AparatResolved? posterOnly;
    final deadline = DateTime.now().add(_resolveBudget);

    for (var attempt = 0; attempt < 2; attempt++) {
      for (final ep in endpoints) {
        if (DateTime.now().isAfter(deadline)) break;
        try {
          final res = await http.get(Uri.parse(ep), headers: _headers).timeout(_timeout);
          if (res.statusCode != 200 || res.body.trim().isEmpty) continue;

          final parsed = _parseVideoJson(res.body);
          if (parsed.hasSource) return parsed;
          // برای پیش‌بارگیری کارت‌ها فقط پوستر کافی است؛ ولی برای پخش،
          // پاسخِ فقط‌پوستر را نگه می‌داریم و به endpoint بعدی می‌رویم
          // (باگ قبلی: همین‌جا زودتر از موعد برمی‌گشت).
          if (posterIsEnough && parsed.posterUrl != null) return parsed;
          if (posterOnly == null && parsed.posterUrl != null) posterOnly = parsed;
        } catch (_) {
          // ادامه به endpoint بعدی
        }
      }
      if (DateTime.now().isAfter(deadline)) break;
      if (attempt == 0) {
        await Future.delayed(const Duration(milliseconds: 350));
      }
    }

    return posterOnly ?? const AparatResolved(streams: []);
  }

  // ═══════════════════════════════════════════════════════════
  // 🖼️ پوستر / تصویر شاخص (thumbnail)
  // ═══════════════════════════════════════════════════════════

  static final Map<String, String> _thumbMemCache = {};
  static final Map<String, Future<String?>> _thumbInFlight = {};
  static SharedPreferences? _prefs;

  static const String _thumbPrefPrefix = 'aparat_thumb_v1_';
  static const String _thumbPrefTimePrefix = 'aparat_thumb_t_';
  static const Duration _thumbCacheTtl = Duration(days: 30);

  static String _thumbKey(String? videoHash) {
    final hash = videoHash?.trim() ?? '';
    if (hash.isEmpty) return '';
    return 'h_$hash';
  }

  static Future<SharedPreferences> _prefsInstance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

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
    if (url != null && isFresh && isAllowedImageUrl(url)) {
      _thumbMemCache[key] = url;
      return url;
    }
    return null;
  }

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
    final mem = _thumbMemCache[key];
    if (mem != null) return mem;

    final prefs = await _prefsInstance();
    final diskUrl = prefs.getString('$_thumbPrefPrefix$key');
    final diskTime = prefs.getInt('$_thumbPrefTimePrefix$key') ?? 0;
    final diskFresh = DateTime.now().millisecondsSinceEpoch - diskTime < _thumbCacheTtl.inMilliseconds;
    if (diskUrl != null && diskFresh && isAllowedImageUrl(diskUrl)) {
      _thumbMemCache[key] = diskUrl;
      return diskUrl;
    }

    final byHash = await _resolveByHash(videoHash, posterIsEnough: true);
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
          // ignore
        }
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  // 🧩 پارس پاسخ آپارات
  // ═══════════════════════════════════════════════════════════

  /// فقط برای تست: پارس پاسخ API/HTML بدون هیچ درخواست شبکه‌ای.
  static AparatResolved parseVideoPayload(String body) => _parseVideoJson(body);

  /// پارس کردن پاسخ ویدیو و استخراج لینک‌های واقعی پخش (MP4/HLS).
  static AparatResolved _parseVideoJson(String body) {
    final streams = <VideoStream>[];
    String? poster;
    String? posterSmall;
    String? title;

    void addStream(String? url, String quality, {bool inferQuality = true}) {
      final value = url?.trim() ?? '';
      if (!isPlayableStreamUrl(value)) return;
      if (streams.any((s) => s.url == value)) return;
      final resolvedQuality = inferQuality ? _qualityFrom(value, quality) : quality;
      streams.add(VideoStream(url: value, quality: resolvedQuality));
    }

    /// پلی‌لیست master آپارات را به لینک‌های HLS با کیفیت مشخص تبدیل می‌کند.
    /// نمونهٔ خطوط:
    /// `#EXT-X-STREAM-INF:...RESOLUTION=640x360...`
    /// `https://caspian14.cdn.asset.aparat.com/...-360p.apt/chunk.m3u8?wmsAuthSign=...`
    void parseManifest(String manifest) {
      final text = manifest.replaceAll(r'\/', '/').trim();
      if (text.isEmpty) return;
      if (!text.contains('#EXTM3U')) {
        if (text.startsWith('http')) addStream(text, 'auto', inferQuality: false);
        return;
      }

      String? height;
      for (final rawLine in text.split(RegExp(r'[\r\n]+'))) {
        final line = rawLine.trim();
        if (line.isEmpty) continue;
        if (line.startsWith('#EXT-X-STREAM-INF')) {
          final match = RegExp(r'RESOLUTION=\d+x(\d+)').firstMatch(line);
          height = match?.group(1);
          continue;
        }
        if (line.startsWith('#')) continue;
        if (line.startsWith('http')) {
          addStream(line, _qualityFromHeight(height), inferQuality: false);
          height = null;
        }
      }
    }

    try {
      final trimmed = body.trim().replaceFirst('\uFEFF', '');

      // ۱) پاسخ JSON (ساختار v1 و etc/api)
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        void walk(dynamic node, {String quality = 'auto'}) {
          if (node is Map) {
            final profile = node['profile'] ?? node['quality'];
            final current = profile is String ? _qualityFrom(profile, quality) : quality;

            for (final entry in node.entries) {
              final key = entry.key.toString().toLowerCase();
              final value = entry.value;

              if (value is String) {
                if (key == 'manifest') {
                  parseManifest(value);
                } else if (key == 'hls_link' || key == 'hls_url' || key == 'm3u8') {
                  addStream(value, 'auto', inferQuality: false);
                } else if (key == 'frame' || key == 'frame_src') {
                  // صفحهٔ embed رسانهٔ قابل پخش نیست (پیش از این اشتباهاً
                  // به‌عنوان stream پذیرفته می‌شد).
                } else if (isPlayableStreamUrl(value)) {
                  addStream(value, _qualityFrom(key, current));
                }

                if (isAllowedImageUrl(value)) {
                  if (key == 'big_poster') {
                    poster ??= value;
                  } else if (key == 'small_poster') {
                    posterSmall ??= value;
                  } else if (poster == null && posterSmall == null && key.contains('poster')) {
                    posterSmall = value;
                  }
                }
                if (title == null && key == 'title' && value.trim().isNotEmpty) {
                  title = value;
                }
              } else if (value is Map || value is List) {
                walk(value, quality: _qualityFrom(key, current));
              }
            }
          } else if (node is List) {
            for (final value in node) {
              if (value is String) {
                addStream(value, quality);
              } else if (value is Map || value is List) {
                walk(value, quality: quality);
              }
            }
          }
        }

        try {
          walk(jsonDecode(trimmed));
        } catch (_) {
          // JSON ناقص/ناسالم — به فال‌بک HTML می‌رویم.
        }
      }

      // ۲) فال‌بک HTML/اسکریپت درون‌صفحه‌ای (وقتی API لینک نمی‌دهد)
      if (streams.isEmpty) {
        final normalized = body.replaceAll(r'\/', '/');
        final matcher = RegExp(
          r"""https?://[^"'\s<>]+?\.(?:mp4|m3u8)(?:\?[^"'\s<>]*)?""",
        );
        for (final match in matcher.allMatches(normalized)) {
          final url = match.group(0);
          if (url != null) addStream(url, 'auto');
        }
      }

      if (poster == null) {
        final normalized = body.replaceAll(r'\/', '/');
        final posterMatcher = RegExp(
          r"""https?://[^"'\s<>]+?\.(?:jpg|jpeg|webp|png)(?:\?[^"'\s<>]*)?""",
        );
        final match = posterMatcher.firstMatch(normalized);
        if (match != null) {
          final url = match.group(0);
          if (isAllowedImageUrl(url)) poster = url;
        }
      }

      return AparatResolved(
        streams: streams,
        posterUrl: poster ?? posterSmall,
        title: title,
      );
    } catch (_) {
      return const AparatResolved(streams: []);
    }
  }

  static String _qualityFrom(String key, String fallback) {
    final match = RegExp(r'(144|240|360|480|720|1080)p?').firstMatch(key);
    return match == null ? fallback : '${match.group(1)}p';
  }

  static String _qualityFromHeight(String? height) {
    final value = int.tryParse(height ?? '');
    if (value == null) return 'auto';
    if (value >= 1080) return '1080p';
    if (value >= 720) return '720p';
    if (value >= 480) return '480p';
    if (value >= 360) return '360p';
    if (value >= 240) return '240p';
    return '144p';
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
