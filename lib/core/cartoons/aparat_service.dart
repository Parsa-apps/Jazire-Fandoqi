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

  /// آیا این URL برای پخش روی دستگاه کودک امن است؟
  /// شرط: HTTPS + دامنهٔ مجاز + پسوند/مسیر رسانه‌ای.
  static bool isPlayableStreamUrl(String? url) {
    final value = url?.trim() ?? '';
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    if (uri.scheme != 'https') return false;
    if (!_isAllowedHost(uri.host)) return false;
    final path = uri.path.toLowerCase();
    return path.contains('.mp4') ||
        path.contains('.m3u8') ||
        path.contains('/video') ||
        path.contains('/vod') ||
        path.contains('/stream') ||
        path.contains('/hls') ||
        path.contains('/watch') ||
        path.contains('/file') ||
        path.contains('/aparat-video') ||
        value.contains('.mp4') ||
        value.contains('.m3u8') ||
        value.contains('video') ||
        value.contains('stream');
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

  // کشِ موقت برای جلوگیری از درخواست تکراری (لینک‌ها چندساعت معتبرند).
  static final Map<String, AparatResolved> _cache = {};
  static final Map<String, DateTime> _cacheTime = {};
  static const Duration _cacheTtl = Duration(hours: 2);

  static bool get isCacheHealthy {
    return _cache.length < 200;
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

  static Future<AparatResolved> _resolveByHash(String hash) async {
    if (!_hashPattern.hasMatch(hash)) return const AparatResolved(streams: []);
    final endpoints = [
      'https://www.aparat.com/api/fa/v1/video/video/show/videohash/$hash?pr=1&mf=1&referer=direct',
      'https://www.aparat.com/etc/api/video/videohash/$hash',
      'https://api.aparat.com/etc/api/video/videohash/$hash',
      'https://www.aparat.com/v/$hash',
    ];
    for (var attempt = 0; attempt < 2; attempt++) {
      for (final ep in endpoints) {
        try {
          final res = await http.get(Uri.parse(ep), headers: _headers).timeout(_timeout);
          if (res.statusCode != 200 || res.body.trim().isEmpty) continue;
          final parsed = _parseVideoJson(res.body);
          if (parsed.hasSource || parsed.posterUrl != null) return parsed;
        } catch (_) {
          // ادامه به endpoint بعدی
        }
      }
      if (attempt == 0) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return const AparatResolved(streams: []);
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

  /// پارس کردن پاسخ ویدیو و استخراج لینک‌های مستقیم به‌ترتیب کیفیت.
  static AparatResolved _parseVideoJson(String body) {
    try {
      final streams = <VideoStream>[];
      String? poster;
      String? posterSmall;
      String? title;

      // ۱) تلاش برای پارس JSON ساختاریافته
      if (body.trim().startsWith('{') || body.trim().startsWith('[')) {
        final decoded = jsonDecode(body);

        void walk(dynamic node, {String quality = 'auto', String key = ''}) {
          if (node is Map) {
            String currentQuality = quality;
            if (node.containsKey('profile') || node.containsKey('quality') || node.containsKey('title')) {
              final p = (node['profile'] ?? node['quality'] ?? node['title']).toString();
              currentQuality = _qualityFrom(p, quality);
            }

            for (final entry in node.entries) {
              final k = entry.key.toString().toLowerCase();
              final value = entry.value;
              if (value is String && isPlayableStreamUrl(value)) {
                final q = _qualityFrom(k, currentQuality);
                if (!streams.any((s) => s.url == value)) {
                  streams.add(VideoStream(url: value, quality: q));
                }
              } else if (value is Map || value is List) {
                walk(value, quality: _qualityFrom(k, currentQuality), key: k);
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
              if (value is String && isPlayableStreamUrl(value)) {
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
      }

      // ۲) فال‌بک Regex برای استخراج ویدیو و پوستر از HTML یا اسکریپت‌های درون‌صفحه‌ای
      if (streams.isEmpty) {
        final videoMatches = RegExp(r'https:\/\/[^"<\s>]+\.(?:mp4|m3u8)(?:\?[^"<\s>]*)?').allMatches(body);
        for (final match in videoMatches) {
          final url = match.group(0);
          if (url != null && isPlayableStreamUrl(url) && !streams.any((s) => s.url == url)) {
            final q = _qualityFrom(url, 'auto');
            streams.add(VideoStream(url: url, quality: q));
          }
        }
      }

      if (poster == null) {
        final posterMatch = RegExp(r'https:\/\/[^"<\s>]+\.(?:jpg|jpeg|webp|png)(?:\?[^"<\s>]*)?').firstMatch(body);
        if (posterMatch != null) {
          final url = posterMatch.group(0);
          if (url != null && isAllowedImageUrl(url)) {
            poster = url;
          }
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

  /// فقط برای تست‌ها: پاک‌سازی کش‌های درون‌حافظه‌ای.
  static void resetForTesting() {
    _cache.clear();
    _cacheTime.clear();
    _thumbMemCache.clear();
    _thumbInFlight.clear();
    _approvedHashesCache = null;
  }
}
