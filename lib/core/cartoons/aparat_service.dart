import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// ═══════════════════════════════════════════════════════════════
/// 🎬 APARAT SERVICE — دریافت لینک مستقیم پخش از سرورهای ایران
///
/// لینک‌های مستقیم آپارات (CDN ایران) بعد از چند ساعت منقضی می‌شوند،
/// بنابراین به‌جای لینک مستقیم ثابت، «هش ویدیو» را ذخیره می‌کنیم و لینک
/// مستقیمِ قابل پخش را **در لحظه** از سرور آپارات می‌گیریم. این باعث می‌شود
/// کارتون‌ها همیشه واقعاً پخش شوند (دکوری نباشند) و روی کودکان در داخل
/// ایران سریع بالا بیایند.
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

  /// دریافت لینک مستقیم پخش برای یک هش ویدیو (مثلاً از آدرس aparat.com/v/XXXX).
  /// در صورت شکست، [searchQuery] را جستجو می‌کند تا اولین نتیجه را پیدا کند.
  static Future<AparatResolved> resolve({
    String? videoHash,
    String? searchQuery,
  }) async {
    if (videoHash != null && videoHash.isNotEmpty) {
      final cached = _cached(videoHash);
      if (cached != null) return cached;

      final fromHash = await _resolveByHash(videoHash);
      if (fromHash.hasSource) {
        _setCache(videoHash, fromHash);
        return fromHash;
      }
    }

    // فال‌بک: جستجو بر اساس عنوان کارتون
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final hash = await _searchFirstHash(searchQuery.trim());
      if (hash != null) {
        final fromSearch = await _resolveByHash(hash);
        if (fromSearch.hasSource) {
          if (videoHash != null && videoHash.isNotEmpty) {
            _setCache(videoHash, fromSearch);
          }
          return fromSearch;
        }
      }
    }

    return const AparatResolved(streams: []);
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
    final endpoints = [
      // API فعلی آپارات؛ endpoint قدیمی /etc/api برای بسیاری از ویدیوها
      // دیگر لینک پخش برنمی‌گرداند.
      'https://www.aparat.com/api/fa/v1/video/video/show/videohash/$hash?pr=1&mf=1&referer=direct',
      'https://www.aparat.com/etc/api/video/videohash/$hash',
      'https://api.aparat.com/etc/api/video/videohash/$hash',
    ];
    for (final ep in endpoints) {
      try {
        final res = await http.get(Uri.parse(ep), headers: _headers).timeout(_timeout);
        if (res.statusCode != 200) continue;
        final parsed = _parseVideoJson(res.body);
        if (parsed.hasSource) return parsed;
      } catch (_) {
        // ادامه به endpoint بعدی
      }
    }
    return const AparatResolved(streams: []);
  }

  static Future<String?> _searchFirstHash(String query) async {
    final encoded = Uri.encodeComponent(query);
    final endpoints = [
      'https://www.aparat.com/api/fa/v1/video/video/search/text/$encoded',
      'https://www.aparat.com/etc/api/videoBySearch/text/$encoded',
      'https://api.aparat.com/etc/api/videoBySearch/text/$encoded',
    ];
    for (final ep in endpoints) {
      try {
        final res = await http.get(Uri.parse(ep), headers: _headers).timeout(_timeout);
        if (res.statusCode != 200) continue;
        final hash = _parseSearchFirstHash(res.body);
        if (hash != null) return hash;
      } catch (_) {
        // ادامه
      }
    }
    return null;
  }

  /// پیدا کردن اولین هش ویدیو در پاسخ جستجو (فرمت‌های مختلف آپارات).
  static String? _parseSearchFirstHash(String body) {
    try {
      final decoded = jsonDecode(body);
      String? found;
      void walk(dynamic node) {
        if (found != null) return;
        if (node is Map) {
          for (final entry in node.entries) {
            final key = entry.key.toString().toLowerCase();
            final value = entry.value;
            if (value is String &&
                (key == 'uid' || key == 'hash_id' || key == 'videoid' ||
                    key == 'uid_short' || key == 'video_hash')) {
              found = value;
              return;
            }
            if (value is Map || value is List) walk(value);
          }
        } else if (node is List) {
          for (final value in node) walk(value);
        }
      }
      walk(decoded);
      return found;
    } catch (_) {
      return null;
    }
  }

  /// پارس کردن پاسخ ویدیو و استخراج لینک‌های مستقیم به‌ترتیب کیفیت.
  static AparatResolved _parseVideoJson(String body) {
    try {
      final decoded = jsonDecode(body);
      final streams = <VideoStream>[];
      String? poster;
      String? title;

      // پاسخ API در نسخه‌های مختلف، داخل data.attributes یا مستقیماً در data
      // قرار می‌گیرد. به‌صورت بازگشتی می‌خوانیم تا تغییر جزئی schema دوباره
      // باعث از کار افتادن تمام کارتون‌ها نشود.
      void walk(dynamic node, {String quality = 'auto', String key = ''}) {
        if (node is Map) {
          for (final entry in node.entries) {
            final k = entry.key.toString().toLowerCase();
            final value = entry.value;
            if (value is String && _isPlayable(value) && (_isStreamKey(k) || _isStreamKey(key) || RegExp(r'^(144|240|360|480|720|1080)p?$').hasMatch(k))) {
              final q = _qualityFrom(k, quality);
              if (!streams.any((s) => s.url == value)) {
                streams.add(VideoStream(url: value, quality: q));
              }
            } else if (value is Map || value is List) {
              walk(value, quality: _qualityFrom(k, quality), key: k);
            }
            if (poster == null && value is String && k.contains('poster')) poster = value;
            if (title == null && value is String && k == 'title') title = value;
          }
        } else if (node is List) {
          for (final value in node) {
            if (value is String && _isPlayable(value) && (_isStreamKey(key) || key == 'urls')) {
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
      return AparatResolved(streams: streams, posterUrl: poster, title: title);
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

  static bool _isPlayable(String u) {
    final value = u.trim();
    if (!(value.startsWith('http://') || value.startsWith('https://'))) return false;
    final lower = value.toLowerCase();
    // CDN آپارات گاهی URL بدون پسوند یا با query امضاشده می‌دهد.
    return lower.contains('.mp4') || lower.contains('.m3u8') ||
        lower.contains('aparat.com/video') || lower.contains('aparat.com/vod') ||
        lower.contains('aparat.com/stream');
  }

}
