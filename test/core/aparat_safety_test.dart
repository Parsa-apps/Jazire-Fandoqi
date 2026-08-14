import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/cartoons/aparat_service.dart';
import 'package:jazireh_fandoghi/core/cartoons/cartoon_data.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🛡️ C2 — تست‌های ایمنی محتوای کارتون
///
/// این تست‌ها تضمین می‌کنند هرگز ویدیویی خارج از کاتالوگ تأییدشده یا از
/// دامنه‌ای غیرمجاز برای کودک پخش نشود.
/// ═══════════════════════════════════════════════════════════════
void main() {
  setUp(AparatService.resetForTesting);

  group('وایت‌لیست هش ویدیو', () {
    test('همهٔ قسمت‌های کاتالوگ هش تأییدشده دارند', () {
      for (final cartoon in CartoonData.allCartoons) {
        for (final ep in cartoon.episodes) {
          expect(
            AparatService.isApprovedHash(ep.aparatHash),
            isTrue,
            reason: 'قسمت ${ep.id} از کارتون ${cartoon.id} هش تأییدشده ندارد',
          );
        }
      }
    });

    test('هش خارج از کاتالوگ رد می‌شود', () {
      expect(AparatService.isApprovedHash('zzzUNKNOWNzz'), isFalse);
      expect(AparatService.isApprovedHash(''), isFalse);
      expect(AparatService.isApprovedHash(null), isFalse);
      expect(AparatService.isApprovedHash('   '), isFalse);
    });

    test('هش با کاراکتر خطرناک (path/query injection) رد می‌شود', () {
      const malicious = [
        '../../etc/passwd',
        'v38wn/../../search',
        'v38wn?redirect=https://evil.com',
        'v38wn&pr=0',
        'v38wn#frag',
        'v38 wn',
        'v38wn/../v38wn',
      ];
      for (final hash in malicious) {
        expect(
          AparatService.isApprovedHash(hash),
          isFalse,
          reason: 'هش مخرب پذیرفته شد: $hash',
        );
      }
    });

    test('resolve برای هش تأییدنشده بدون هیچ درخواست شبکه‌ای خالی برمی‌گردد', () async {
      final result = await AparatService.resolve(videoHash: 'notInCatalog');
      expect(result.hasSource, isFalse);
      expect(result.streams, isEmpty);
    });

    test('thumbnailFor برای هش تأییدنشده null برمی‌گرداند', () async {
      expect(await AparatService.thumbnailFor(videoHash: 'notInCatalog'), isNull);
      expect(await AparatService.thumbnailFor(videoHash: null), isNull);
      expect(AparatService.cachedThumbnail(videoHash: 'notInCatalog'), isNull);
    });
  });

  group('وایت‌لیست دامنهٔ لینک پخش', () {
    test('لینک HTTPS روی دامنهٔ مجاز آپارات پذیرفته می‌شود', () {
      const valid = [
        'https://www.aparat.com/video/hls/manifest/x.m3u8',
        'https://hs1.aparat.com/vod/1/file.mp4',
        'https://asset.aparat.com/aparat-video/abc-720p.mp4',
        'https://cdn.aparat.ir/video/x.mp4',
      ];
      for (final url in valid) {
        expect(
          AparatService.isPlayableStreamUrl(url),
          isTrue,
          reason: 'لینک معتبر رد شد: $url',
        );
      }
    });

    test('لینک غیر HTTPS رد می‌شود (جلوگیری از downgrade)', () {
      expect(
        AparatService.isPlayableStreamUrl('http://hs1.aparat.com/vod/x.mp4'),
        isFalse,
      );
    });

    test('دامنهٔ جعلی که نام آپارات را در مسیر یا زیر‌دامنه دارد رد می‌شود', () {
      const spoofed = [
        'https://evil.com/aparat.com/video/x.mp4',
        'https://aparat.com.evil.com/vod/x.mp4',
        'https://notaparat.com/vod/x.mp4',
        'https://evil.com/vod/aparat.com/stream.m3u8',
        'https://youtube.com/video/x.mp4',
      ];
      for (final url in spoofed) {
        expect(
          AparatService.isPlayableStreamUrl(url),
          isFalse,
          reason: 'دامنهٔ جعلی پذیرفته شد: $url',
        );
      }
    });

    test('ورودی خالی یا نامعتبر رد می‌شود', () {
      expect(AparatService.isPlayableStreamUrl(null), isFalse);
      expect(AparatService.isPlayableStreamUrl(''), isFalse);
      expect(AparatService.isPlayableStreamUrl('   '), isFalse);
      expect(AparatService.isPlayableStreamUrl('javascript:alert(1)'), isFalse);
      expect(AparatService.isPlayableStreamUrl('file:///sdcard/x.mp4'), isFalse);
    });
  });

  group('وایت‌لیست دامنهٔ پوستر', () {
    test('پوستر آپارات مجاز و پوستر خارجی غیرمجاز است', () {
      expect(
        AparatService.isAllowedImageUrl('https://static.cdn.asset.aparat.com/avt/x.jpg'),
        isTrue,
      );
      expect(AparatService.isAllowedImageUrl('https://evil.com/x.jpg'), isFalse);
      expect(AparatService.isAllowedImageUrl('http://www.aparat.com/x.jpg'), isFalse);
      expect(AparatService.isAllowedImageUrl(null), isFalse);
    });
  });

  group('لینک مستقیم قسمت‌ها (streamUrl)', () {
    test('هر streamUrl تعریف‌شده در کاتالوگ باید از فیلتر امنیتی عبور کند', () {
      for (final cartoon in CartoonData.allCartoons) {
        for (final ep in cartoon.episodes) {
          final url = ep.streamUrl?.trim() ?? '';
          if (url.isEmpty) continue;
          expect(
            AparatService.isPlayableStreamUrl(url),
            isTrue,
            reason: 'streamUrl ناامن در قسمت ${ep.id}: $url',
          );
        }
      }
    });
  });
}
