import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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
          .head(Uri.parse('https://www.aparat.com'))
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
      'https://www.aparat.com/etc/api/video/videohash/$hash',
      'https://api.aparat.com/etc/api/video/videohash/$hash',
    ];
    for (final ep in endpoints) {
      try {
        final res = await http.get(Uri.parse(ep)).timeout(_timeout);
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
      'https://www.aparat.com/etc/api/videoBySearch/text/$encoded',
      'https://api.aparat.com/etc/api/videoBySearch/text/$encoded',
    ];
    for (final ep in endpoints) {
      try {
        final res = await http.get(Uri.parse(ep)).timeout(_timeout);
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
      final data = jsonDecode(body) as Map<String, dynamic>;
      final items = _digList(data, 'data');
      if (items != null) {
        for (final it in items) {
          if (it is Map) {
            final h = _digString(it as Map<String, dynamic>, 'uid') ??
                _digString(it as Map<String, dynamic>, 'videoid') ??
                _digString(it as Map<String, dynamic>, 'uid_short');
            if (h != null && h.isNotEmpty) return h;
          }
        }
      }
    } catch (_) {
      // نادیده گرفتن خطای پارس
    }
    return null;
  }

  /// پارس کردن پاسخ ویدیو و استخراج لینک‌های مستقیم به‌ترتیب کیفیت.
  static AparatResolved _parseVideoJson(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;

      // ساختار جدید (JSON:API)
      final attributes = data['data'] is Map
          ? (data['data'] as Map)['attributes']
          : null;
      final src = attributes is Map ? attributes : data;

      final List<VideoStream> streams = [];
      String? poster;
      String? title;

      final fla = src['file_link_all'];
      if (fla is List) {
        for (final entry in fla) {
          if (entry is! Map) continue;
          final e = entry as Map<String, dynamic>;
          final profile = _digString(e, 'profile') ?? _digString(e, 'quality');
          final urls = e['urls'];
          final single = e['url'];
          List<String> urlList = [];
          if (urls is List) {
            for (final u in urls) {
              if (u is String && _isPlayable(u)) urlList.add(u);
              if (u is Map && u['src'] is String) urlList.add(u['src'] as String);
            }
          } else if (single is String && _isPlayable(single)) {
            urlList.add(single);
          }
          if (urlList.isNotEmpty) {
            streams.add(VideoStream(
              url: urlList.first,
              quality: profile ?? 'auto',
            ));
          }
        }
      }

      // لینک پشتیبان تکی
      if (streams.isEmpty) {
        final fb = src['file_link'];
        if (fb is String && _isPlayable(fb)) {
          streams.add(VideoStream(url: fb, quality: 'auto'));
        }
      }

      poster = _digString(src as Map<String, dynamic>, 'big_poster') ??
          _digString(src as Map<String, dynamic>, 'small_poster') ??
          _digString(src as Map<String, dynamic>, 'poster');
      title = _digString(src as Map<String, dynamic>, 'title');

      if (streams.isNotEmpty) {
        return AparatResolved(
          streams: streams,
          posterUrl: poster,
          title: title,
        );
      }
    } catch (_) {
      // نادیده گرفتن
    }
    return const AparatResolved(streams: []);
  }

  static bool _isPlayable(String u) =>
      u.startsWith('http') && (u.contains('.mp4') || u.contains('.m3u8'));

  static List? _digList(Map m, String key) {
    final v = m[key];
    return v is List ? v : null;
  }

  static String? _digString(Map<String, dynamic> m, String key) {
    final v = m[key];
    return v is String && v.isNotEmpty ? v : null;
  }
}
