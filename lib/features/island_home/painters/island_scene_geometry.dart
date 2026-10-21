import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📐 هندسهٔ مشترکِ صحنهٔ جزیره
///
/// سه نقاش (آسمان، دریا، خشکی) باید دقیقاً بر سر یک خطِ افق و یک
/// خطِ ساحل توافق داشته باشند؛ وگرنه لایه‌ها هنگام انیمیشن از هم
/// جدا می‌شوند. همهٔ مختصات اینجا و فقط اینجا تعریف می‌شوند.
///
/// همهٔ مقادیر نسبی‌اند: روی گوشیِ باریک، بلند یا تبلت همان ترکیب
/// حفظ می‌شود و فقط مقیاس عوض می‌شود.
/// ═══════════════════════════════════════════════════════════════
class IslandSceneGeometry {
  IslandSceneGeometry(Size size)
      : w = size.width,
        h = size.height;

  final double w;
  final double h;

  // ── خطوطِ اصلی ──
  double get horizon => h * 0.40;

  /// قلهٔ گنبدیِ جزیره
  double get islandPeak => h * 0.255;

  /// جایی که جلویِ جزیره به آب می‌رسد
  double get islandShore => h * 0.78;

  /// ضخامتِ صخره (برجستگیِ سه‌بعدیِ زیرِ چمن)
  double get cliffThickness => h * 0.075;

  /// نوارِ ماسهٔ ساحل
  double get sandThickness => h * 0.026;

  /// جای ایستادنِ فندقی روی چمن
  Offset get mascotAnchor => Offset(w * 0.5, islandPeak + h * 0.115);

  // ── خورشید ──
  Offset get sunCenter => Offset(w * 0.78, h * 0.115);
  double get sunRadius => math.min(w, h) * 0.072;

  // ── آبشار ──
  double get fallTop => h * 0.425;
  double get fallBottom => islandShore + cliffThickness * 0.35;
  double get fallLeft => w * 0.815;
  double get fallWidth => w * 0.062;

  // ── پلِ چوبی ──
  double get bridgeStartX => -w * 0.02;
  double get bridgeEndX => w * 0.28;
  double get bridgeStartY => h * 0.735;
  double get bridgeEndY => h * 0.665;

  // ── خانه‌ها ──
  Rect get houseA => Rect.fromLTWH(w * 0.115, h * 0.315, w * 0.165, h * 0.085);
  Rect get houseB =>
      Rect.fromLTWH(w * 0.700, h * 0.300, w * 0.140, h * 0.078);

  /// خط‌الرأسِ جزیره: تپهٔ چپ، گنبدِ میانی (جای فندقی)، تپهٔ راست
  /// و ساحلیِ کوژ که به سمت پایین برآمدگی دارد.
  Path islandSilhouette() {
    final path = Path();
    final left = -w * 0.08;
    final right = w * 1.08;
    final shoulderLeft = h * 0.56;
    final shoulderRight = h * 0.54;

    path.moveTo(left, islandShore);
    // لبهٔ چپِ صخره
    path.lineTo(left, shoulderLeft);
    // تپهٔ چپ
    path.quadraticBezierTo(w * 0.06, h * 0.395, w * 0.19, h * 0.435);
    // فرورفتگیِ پیش از گنبد
    path.quadraticBezierTo(w * 0.27, h * 0.462, w * 0.34, h * 0.400);
    // گنبدِ اصلی (سکوی فندقی)
    path.quadraticBezierTo(w * 0.44, islandPeak, w * 0.62, h * 0.330);
    // شیبِ راست
    path.quadraticBezierTo(w * 0.72, h * 0.372, w * 0.79, h * 0.408);
    // تپهٔ راست (لبهٔ آبشار)
    path.quadraticBezierTo(w * 0.90, h * 0.372, right, h * 0.430);
    // لبهٔ راستِ صخره
    path.lineTo(right, shoulderRight);
    // بستن از پایین با همان انحنای ساحل (برعکس) تا پایینِ جزیره
    // یک خطِ صافِ مصنوعی نباشد و برآمدگیِ سه‌بعدی بسازد.
    path.quadraticBezierTo(
      w * 0.5,
      islandShore + h * 0.075,
      left,
      islandShore,
    );
    path.close();
    return path;
  }

  /// خطِ ساحلِ جلویی برای کفِ دریا و حلقهٔ موج
  Path shoreEdge({double offset = 0}) {
    final path = Path();
    final left = -w * 0.08;
    final right = w * 1.08;
    path.moveTo(left, islandShore + offset);
    path.quadraticBezierTo(
      w * 0.5,
      islandShore + h * 0.075 + offset,
      right,
      islandShore + offset,
    );
    return path;
  }

  /// یک مسیرِ مارپیچِ کوتاه از ساحل تا سکوی فندقی
  Path gardenPath() {
    final path = Path();
    final bottomY = islandShore + h * 0.02;
    final bottomHalfWidth = w * 0.115;
    final topY = mascotAnchor.dy + h * 0.055;
    final topHalfWidth = w * 0.028;

    path.moveTo(w * 0.5 - bottomHalfWidth, bottomY);
    path.quadraticBezierTo(
      w * 0.34,
      h * 0.66,
      w * 0.455,
      h * 0.55,
    );
    path.quadraticBezierTo(
      w * 0.545,
      h * 0.470,
      w * 0.5 + topHalfWidth,
      topY,
    );
    path.lineTo(w * 0.5 - topHalfWidth, topY);
    path.quadraticBezierTo(
      w * 0.480,
      h * 0.472,
      w * 0.400,
      h * 0.552,
    );
    path.quadraticBezierTo(
      w * 0.310,
      h * 0.665,
      w * 0.5 + bottomHalfWidth,
      bottomY,
    );
    path.close();
    return path;
  }
}
