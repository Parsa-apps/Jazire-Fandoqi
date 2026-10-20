import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/cartoons/aparat_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎬 تست‌های رگرسیون پخش کارتون
///
/// سه خرابی واقعی که باعث می‌شد کارتون‌ها پخش نشوند اینجا قفل می‌شوند:
///  ۱) صفحهٔ HTML embed (`frame_src`) و فایل `.apt` به‌عنوان «لینک پخش»
///     شناسایی می‌شدند و به ExoPlayer تحویل داده می‌شدند.
///  ۲) پاسخ‌های فقط‌پوستر باعث می‌شدند resolver زودتر از موعد متوقف شود.
///  ۳) پلی‌لیست HLS آپارات (`manifest`/`hls_link`) استخراج نمی‌شد؛ برای
///     ویدیوهای بدون MP4 دانلودی هیچ گزینهٔ قابل پخشی نمی‌ماند.
/// ═══════════════════════════════════════════════════════════════
void main() {
  group('شناسایی رسانهٔ قابل پخش', () {
    test('MP4 و M3U8 روی دامنهٔ آپارات پذیرفته می‌شوند', () {
      expect(
        AparatService.isPlayableStreamUrl(
          'https://persian5.cdn.asset.aparat.com/aparat-video/x-720p.mp4?wmsAuthSign=a',
        ),
        isTrue,
      );
      expect(
        AparatService.isPlayableStreamUrl(
          'https://caspian14.cdn.asset.aparat.com/aparat-video/x-360p.apt/chunk.m3u8?wmsAuthSign=a',
        ),
        isTrue,
      );
      expect(
        AparatService.isPlayableStreamUrl('https://www.aparat.com/external/chelsea/manifest.m3u8?q=a'),
        isTrue,
      );
    });

    test('صفحهٔ embed، صفحهٔ ویدیو و فایل .apt رسانه نیستند', () {
      expect(
        AparatService.isPlayableStreamUrl(
          'https://www.aparat.com/video/video/embed/videohash/v38wn/vt/frame',
        ),
        isFalse,
      );
      expect(AparatService.isPlayableStreamUrl('https://www.aparat.com/v/v38wn'), isFalse);
      expect(
        AparatService.isPlayableStreamUrl(
          'https://persian5.cdn.asset.aparat.com/aparat-video/x-1080p.apt?wmsAuthSign=a',
        ),
        isFalse,
      );
      expect(
        AparatService.isPlayableStreamUrl(
          'https://www.aparat.com/api/fa/v1/video/video/show/videohash/v38wn',
        ),
        isFalse,
      );
    });
  });

  group('پارس پاسخ JSON آپارات', () {
    test('MP4 های file_link_all با کیفیت درست استخراج می‌شوند', () {
      const body = r'''
      {
        "data": {
          "attributes": {
            "title": "کارتون تست",
            "big_poster": "https://static.cdn.asset.aparat.cloud/avt/x.jpg?width=900",
            "file_link_all": [
              {"text": "با کیفیت 240p", "profile": "240p", "urls": ["https://persian5.cdn.asset.aparat.com/aparat-video/x-240p.mp4?wmsAuthSign=a"]},
              {"text": "با کیفیت 720p", "profile": "720p", "urls": ["https://persian5.cdn.asset.aparat.com/aparat-video/x-720p.mp4?wmsAuthSign=b"]}
            ],
            "file_link": "https://persian5.cdn.asset.aparat.com/aparat-video/x-1080p.apt?wmsAuthSign=c",
            "hls_link": "https://www.aparat.com/external/chelsea/manifest.m3u8?q=abc",
            "frame_src": "https://www.aparat.com/video/video/embed/videohash/x/vt/frame"
          }
        }
      }
      ''';

      final resolved = AparatService.parseVideoPayload(body);

      expect(resolved.hasSource, isTrue);
      expect(resolved.title, 'کارتون تست');
      expect(resolved.posterUrl, contains('aparat.cloud'));

      final urls = resolved.streams.map((s) => s.url).toList();
      expect(urls.any((u) => u.contains('-240p.mp4')), isTrue);
      expect(urls.any((u) => u.contains('-720p.mp4')), isTrue);
      expect(urls.any((u) => u.contains('.apt')), isFalse);
      expect(urls.any((u) => u.contains('/embed/')), isFalse);

      final as720 = resolved.streams.firstWhere((s) => s.url.contains('-720p.mp4'));
      expect(as720.quality, '720p');
      expect(as720.isHls, isFalse);

      final hls = resolved.streams.firstWhere((s) => s.url.contains('manifest.m3u8'));
      expect(hls.quality, 'auto');
      expect(hls.isHls, isTrue);
    });

    test('وقتی MP4 وجود ندارد، پلی‌لیست HLS با کیفیت هر رزولوشن استخراج می‌شود', () {
      const body = r'''
      {
        "data": {
          "attributes": {
            "title": "کارتون فقط HLS",
            "manifest": "#EXTM3U\n#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=682972, RESOLUTION=640x360, FRAME-RATE=30\nhttps://caspian14.cdn.asset.aparat.com/aparat-video/x-360p.apt/chunk.m3u8?wmsAuthSign=a\n#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=280971, RESOLUTION=264x148, FRAME-RATE=15\nhttps://caspian14.cdn.asset.aparat.com/aparat-video/x-144p.apt/chunk.m3u8?wmsAuthSign=a\n"
          }
        }
      }
      ''';

      final resolved = AparatService.parseVideoPayload(body);

      expect(resolved.hasSource, isTrue);
      expect(resolved.streams.length, 2);
      expect(resolved.streams.every((s) => s.isHls), isTrue);
      expect(resolved.streams.map((s) => s.quality), containsAll(<String>['360p', '144p']));
      expect(resolved.streams.every((s) => !s.url.contains('.apt?')), isTrue);
    });

    test('کیفیت از profile استفاده می‌شود حتی وقتی نام فایل کیفیت ندارد', () {
      const body = r'''
      {
        "data": {
          "attributes": {
            "file_link_all": [
              {"profile": "480p", "urls": ["https://persian5.cdn.asset.aparat.com/aparat-video/video.mp4?wmsAuthSign=a"]}
            ]
          }
        }
      }
      ''';

      final resolved = AparatService.parseVideoPayload(body);

      expect(resolved.streams.length, 1);
      expect(resolved.streams.first.quality, '480p');
      expect(resolved.streams.first.isHls, isFalse);
    });

    test('پاسخ بدون رسانه (فقط .apt و صفحهٔ embed) منبع پخش ندارد', () {
      const body = r'''
      {
        "data": {
          "attributes": {
            "file_link": "https://persian5.cdn.asset.aparat.com/aparat-video/x-1080p.apt?wmsAuthSign=a",
            "frame": "https://www.aparat.com/video/video/embed/videohash/x/vt/frame",
            "frame_src": "https://www.aparat.com/video/video/embed/videohash/x/vt/frame"
          }
        }
      }
      ''';

      final resolved = AparatService.parseVideoPayload(body);

      expect(resolved.hasSource, isFalse);
      expect(resolved.streams, isEmpty);
    });

    test('فال‌بک HTML لینک MP4 را از صفحهٔ وب استخراج می‌کند', () {
      const html =
          '<video controls><source src="https://persian5.cdn.asset.aparat.com/aparat-video/x-480p.mp4?wmsAuthSign=a" type="video/mp4"></video>';

      final resolved = AparatService.parseVideoPayload(html);

      expect(resolved.hasSource, isTrue);
      expect(resolved.streams.first.url, contains('-480p.mp4'));
    });
  });
}
