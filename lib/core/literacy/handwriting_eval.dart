import 'dart:math' as math;
import 'dart:ui';

/// راهنمای حرکت قلم برای یک نشانهٔ فارسی (مختصات نرمال جعبهٔ حرف: ۰ راست؟ نه —
/// x=۰ چپ جعبه، x=۱ راست جعبه؛ خط فارسی معمولاً از راست شروع می‌شود).
class LetterStrokeGuide {
  final double startX;
  final double startY;
  final double dirX;
  final double dirY;
  final List<Offset> demo;

  const LetterStrokeGuide({
    required this.startX,
    required this.startY,
    required this.dirX,
    required this.dirY,
    required this.demo,
  });
}

class HandwritingGeometry {
  final bool longEnough;
  final bool startedAtDot;
  final bool directionOk;
  final bool sitsOnBaseline;
  final bool followsPath;
  final double geometryScore;
  final String failReason;

  const HandwritingGeometry({
    required this.longEnough,
    required this.startedAtDot,
    required this.directionOk,
    required this.sitsOnBaseline,
    this.followsPath = true,
    required this.geometryScore,
    required this.failReason,
  });

  bool get passed =>
      longEnough &&
      startedAtDot &&
      directionOk &&
      sitsOnBaseline &&
      followsPath;
}

/// ارزیابی هندسی خط کودک — مستقل از Canvas تا در تست واحد قابل بررسی باشد.
class HandwritingEval {
  HandwritingEval._();

  static const double startRadius = 72;
  static const double baselineSlack = 38;
  static const int minPoints = 12;
  static const double pathSlack = 64;

  static LetterStrokeGuide guideFor(String letter) {
    final key = _family(letter);
    return _guides[key] ?? _guides['ب']!;
  }

  static Offset startDot({
    required String letter,
    required Offset glyphOrigin,
    required Size glyphSize,
  }) {
    final g = guideFor(letter);
    return Offset(
      glyphOrigin.dx + glyphSize.width * g.startX,
      glyphOrigin.dy + glyphSize.height * g.startY,
    );
  }

  static List<Offset> demoPath({
    required String letter,
    required Offset glyphOrigin,
    required Size glyphSize,
  }) {
    final g = guideFor(letter);
    return [
      for (final p in g.demo)
        Offset(
          glyphOrigin.dx + glyphSize.width * p.dx,
          glyphOrigin.dy + glyphSize.height * p.dy,
        ),
    ];
  }

  static Offset lerpPath(List<Offset> path, double t) {
    if (path.isEmpty) return Offset.zero;
    if (path.length == 1) return path.first;
    final clamped = t.clamp(0.0, 1.0);
    final scaled = clamped * (path.length - 1);
    final i = scaled.floor().clamp(0, path.length - 2);
    final local = scaled - i;
    return Offset.lerp(path[i], path[i + 1], local)!;
  }

  static HandwritingGeometry evaluate({
    required String letter,
    required List<Offset> points,
    required Offset start,
    required double baselineY,
    List<Offset>? demoPath,
  }) {
    if (points.length < minPoints) {
      return const HandwritingGeometry(
        longEnough: false,
        startedAtDot: false,
        directionOk: false,
        sitsOnBaseline: false,
        followsPath: false,
        geometryScore: 0.2,
        failReason: 'خط خیلی کوتاه بود. از نقطه سبز یک خط بلند بکش.',
      );
    }

    final started = points.first.distanceTo(start) <= startRadius;
    final guide = guideFor(letter);
    final probe = math.min(18, points.length - 1);
    final delta = points[probe] - points.first;
    final len = delta.distance;
    var directionOk = true;
    if (len >= 10) {
      final nx = delta.dx / len;
      final ny = delta.dy / len;
      final expected = Offset(guide.dirX, guide.dirY);
      final el = expected.distance == 0 ? 1.0 : expected.distance;
      final dot = nx * (expected.dx / el) + ny * (expected.dy / el);
      directionOk = dot >= 0.12;
    }

    var nearBase = 0;
    for (final p in points) {
      if ((p.dy - baselineY).abs() <= baselineSlack) nearBase++;
    }
    final sits = nearBase / points.length >= 0.12;

    final follows = demoPath == null ||
        demoPath.length < 2 ||
        pathFit(points: points, demo: demoPath) >= 0.38;

    var score = 0.15;
    if (started) score += 0.25;
    if (directionOk) score += 0.20;
    if (sits) score += 0.15;
    if (follows) score += 0.25;

    var reason = '';
    if (!started) {
      reason = 'باید از نقطه سبز شروع کنی.';
    } else if (!directionOk) {
      reason = 'جهت قلم درست نبود. حرکت قلم جادویی را ببین.';
    } else if (!follows) {
      reason = 'دقیقاً روی خط کم‌رنگ نشانه بکش.';
    } else if (!sits) {
      reason = 'حرف باید روی خط کرسی آبی بنشیند.';
    }

    return HandwritingGeometry(
      longEnough: true,
      startedAtDot: started,
      directionOk: directionOk,
      sitsOnBaseline: sits,
      followsPath: follows,
      geometryScore: score,
      failReason: reason,
    );
  }

  /// نزدیکی خط کودک به مسیر نمونه: ۱ یعنی روی مسیر، ۰ یعنی خیلی دور.
  static double pathFit({
    required List<Offset> points,
    required List<Offset> demo,
  }) {
    if (points.isEmpty || demo.isEmpty) return 0;
    var total = 0.0;
    for (final p in points) {
      var best = double.infinity;
      if (demo.length == 1) {
        best = p.distanceTo(demo.first);
      } else {
        for (var i = 0; i < demo.length - 1; i++) {
          final d = _distanceToSegment(p, demo[i], demo[i + 1]);
          if (d < best) best = d;
        }
      }
      total += best;
    }
    final avg = total / points.length;
    return (1.0 - (avg / pathSlack)).clamp(0.0, 1.0);
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return p.distanceTo(a);
    var t = ((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2;
    t = t.clamp(0.0, 1.0);
    final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return p.distanceTo(proj);
  }

  /// خانوادهٔ شکل حرف برای راهنمای قلم. «او و» باید و باشد نه الف.
  static String familyOf(String letter) => _family(letter);

  static String _family(String letter) {
    final t = letter.replaceAll('ـ', '').trim();
    if (t.isEmpty) return 'ب';
    if (t.startsWith('آ')) return 'آ';
    if (t.startsWith('اَ') || t.startsWith('اِ') || t.startsWith('اُ')) return 'ا';
    if (t.startsWith('خوا')) return 'خ';
    if (t.startsWith('او')) return 'و';
    if (t.startsWith('ای')) return 'ی';
    return t.substring(0, 1);
  }
}

const Map<String, LetterStrokeGuide> _guides = <String, LetterStrokeGuide>{
  'آ': LetterStrokeGuide(
    startX: 0.72,
    startY: 0.12,
    dirX: 0.05,
    dirY: 1,
    demo: [Offset(0.72, 0.12), Offset(0.70, 0.55), Offset(0.68, 0.92)],
  ),
  'ا': LetterStrokeGuide(
    startX: 0.62,
    startY: 0.10,
    dirX: 0,
    dirY: 1,
    demo: [Offset(0.62, 0.10), Offset(0.60, 0.92)],
  ),
  'ب': LetterStrokeGuide(
    startX: 0.88,
    startY: 0.42,
    dirX: -1,
    dirY: 0.15,
    demo: [
      Offset(0.88, 0.42),
      Offset(0.55, 0.48),
      Offset(0.22, 0.55),
      Offset(0.18, 0.78),
    ],
  ),
  'پ': LetterStrokeGuide(
    startX: 0.88,
    startY: 0.42,
    dirX: -1,
    dirY: 0.15,
    demo: [Offset(0.88, 0.42), Offset(0.50, 0.50), Offset(0.18, 0.78)],
  ),
  'ت': LetterStrokeGuide(
    startX: 0.88,
    startY: 0.42,
    dirX: -1,
    dirY: 0.1,
    demo: [Offset(0.88, 0.42), Offset(0.50, 0.50), Offset(0.18, 0.78)],
  ),
  'ث': LetterStrokeGuide(
    startX: 0.88,
    startY: 0.42,
    dirX: -1,
    dirY: 0.1,
    demo: [Offset(0.88, 0.42), Offset(0.50, 0.50), Offset(0.18, 0.78)],
  ),
  'ج': LetterStrokeGuide(
    startX: 0.82,
    startY: 0.22,
    dirX: -0.6,
    dirY: 0.8,
    demo: [Offset(0.82, 0.22), Offset(0.40, 0.55), Offset(0.55, 0.88)],
  ),
  'چ': LetterStrokeGuide(
    startX: 0.82,
    startY: 0.22,
    dirX: -0.6,
    dirY: 0.8,
    demo: [Offset(0.82, 0.22), Offset(0.40, 0.55), Offset(0.55, 0.88)],
  ),
  'ح': LetterStrokeGuide(
    startX: 0.82,
    startY: 0.22,
    dirX: -0.6,
    dirY: 0.8,
    demo: [Offset(0.82, 0.22), Offset(0.40, 0.55), Offset(0.55, 0.88)],
  ),
  'خ': LetterStrokeGuide(
    startX: 0.82,
    startY: 0.22,
    dirX: -0.6,
    dirY: 0.8,
    demo: [Offset(0.82, 0.22), Offset(0.40, 0.55), Offset(0.55, 0.88)],
  ),
  'د': LetterStrokeGuide(
    startX: 0.70,
    startY: 0.28,
    dirX: -0.2,
    dirY: 0.9,
    demo: [Offset(0.70, 0.28), Offset(0.55, 0.62), Offset(0.62, 0.90)],
  ),
  'ذ': LetterStrokeGuide(
    startX: 0.70,
    startY: 0.28,
    dirX: -0.2,
    dirY: 0.9,
    demo: [Offset(0.70, 0.28), Offset(0.55, 0.62), Offset(0.62, 0.90)],
  ),
  'ر': LetterStrokeGuide(
    startX: 0.68,
    startY: 0.32,
    dirX: -0.35,
    dirY: 0.9,
    demo: [Offset(0.68, 0.32), Offset(0.52, 0.70), Offset(0.38, 0.92)],
  ),
  'ز': LetterStrokeGuide(
    startX: 0.68,
    startY: 0.32,
    dirX: -0.35,
    dirY: 0.9,
    demo: [Offset(0.68, 0.32), Offset(0.52, 0.70), Offset(0.38, 0.92)],
  ),
  'ژ': LetterStrokeGuide(
    startX: 0.68,
    startY: 0.32,
    dirX: -0.35,
    dirY: 0.9,
    demo: [Offset(0.68, 0.32), Offset(0.52, 0.70), Offset(0.38, 0.92)],
  ),
  'س': LetterStrokeGuide(
    startX: 0.90,
    startY: 0.40,
    dirX: -1,
    dirY: 0.2,
    demo: [
      Offset(0.90, 0.40),
      Offset(0.68, 0.55),
      Offset(0.46, 0.40),
      Offset(0.24, 0.62),
      Offset(0.16, 0.86),
    ],
  ),
  'ش': LetterStrokeGuide(
    startX: 0.90,
    startY: 0.40,
    dirX: -1,
    dirY: 0.2,
    demo: [
      Offset(0.90, 0.40),
      Offset(0.68, 0.55),
      Offset(0.46, 0.40),
      Offset(0.24, 0.62),
      Offset(0.16, 0.86),
    ],
  ),
  'ص': LetterStrokeGuide(
    startX: 0.88,
    startY: 0.38,
    dirX: -1,
    dirY: 0.25,
    demo: [Offset(0.88, 0.38), Offset(0.50, 0.55), Offset(0.22, 0.82)],
  ),
  'ض': LetterStrokeGuide(
    startX: 0.88,
    startY: 0.38,
    dirX: -1,
    dirY: 0.25,
    demo: [Offset(0.88, 0.38), Offset(0.50, 0.55), Offset(0.22, 0.82)],
  ),
  'ط': LetterStrokeGuide(
    startX: 0.58,
    startY: 0.10,
    dirX: 0,
    dirY: 1,
    demo: [Offset(0.58, 0.10), Offset(0.58, 0.55), Offset(0.78, 0.55), Offset(0.30, 0.55)],
  ),
  'ظ': LetterStrokeGuide(
    startX: 0.58,
    startY: 0.10,
    dirX: 0,
    dirY: 1,
    demo: [Offset(0.58, 0.10), Offset(0.58, 0.55), Offset(0.78, 0.55), Offset(0.30, 0.55)],
  ),
  'ع': LetterStrokeGuide(
    startX: 0.78,
    startY: 0.18,
    dirX: -0.4,
    dirY: 0.9,
    demo: [Offset(0.78, 0.18), Offset(0.45, 0.48), Offset(0.58, 0.88)],
  ),
  'غ': LetterStrokeGuide(
    startX: 0.78,
    startY: 0.18,
    dirX: -0.4,
    dirY: 0.9,
    demo: [Offset(0.78, 0.18), Offset(0.45, 0.48), Offset(0.58, 0.88)],
  ),
  'ف': LetterStrokeGuide(
    startX: 0.80,
    startY: 0.22,
    dirX: -0.7,
    dirY: 0.7,
    demo: [Offset(0.80, 0.22), Offset(0.55, 0.48), Offset(0.22, 0.78)],
  ),
  'ق': LetterStrokeGuide(
    startX: 0.80,
    startY: 0.22,
    dirX: -0.7,
    dirY: 0.7,
    demo: [Offset(0.80, 0.22), Offset(0.55, 0.48), Offset(0.22, 0.78)],
  ),
  'ک': LetterStrokeGuide(
    startX: 0.78,
    startY: 0.14,
    dirX: -0.2,
    dirY: 1,
    demo: [Offset(0.78, 0.14), Offset(0.70, 0.55), Offset(0.28, 0.78)],
  ),
  'گ': LetterStrokeGuide(
    startX: 0.78,
    startY: 0.14,
    dirX: -0.2,
    dirY: 1,
    demo: [Offset(0.78, 0.14), Offset(0.70, 0.55), Offset(0.28, 0.78)],
  ),
  'ل': LetterStrokeGuide(
    startX: 0.72,
    startY: 0.12,
    dirX: 0,
    dirY: 1,
    demo: [Offset(0.72, 0.12), Offset(0.68, 0.55), Offset(0.30, 0.82)],
  ),
  'م': LetterStrokeGuide(
    startX: 0.82,
    startY: 0.28,
    dirX: -0.8,
    dirY: 0.5,
    demo: [Offset(0.82, 0.28), Offset(0.50, 0.48), Offset(0.28, 0.82)],
  ),
  'ن': LetterStrokeGuide(
    startX: 0.86,
    startY: 0.40,
    dirX: -1,
    dirY: 0.2,
    demo: [Offset(0.86, 0.40), Offset(0.50, 0.52), Offset(0.22, 0.82)],
  ),
  'و': LetterStrokeGuide(
    startX: 0.70,
    startY: 0.30,
    dirX: -0.3,
    dirY: 0.9,
    demo: [Offset(0.70, 0.30), Offset(0.52, 0.62), Offset(0.40, 0.90)],
  ),
  'ه': LetterStrokeGuide(
    startX: 0.78,
    startY: 0.28,
    dirX: -0.6,
    dirY: 0.7,
    demo: [Offset(0.78, 0.28), Offset(0.48, 0.52), Offset(0.32, 0.84)],
  ),
  'ی': LetterStrokeGuide(
    startX: 0.86,
    startY: 0.42,
    dirX: -1,
    dirY: 0.25,
    demo: [Offset(0.86, 0.42), Offset(0.48, 0.55), Offset(0.20, 0.84)],
  ),
};
