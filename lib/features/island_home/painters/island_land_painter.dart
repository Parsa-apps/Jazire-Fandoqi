import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/island_cinema_style.dart';
import 'island_scene_geometry.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ لایهٔ ۳ — خودِ جزیره: صخره، چمن، آبشار، پل، خانه‌ها و درختان
///
/// چرا نقاشیِ برداری و نه مدلِ سه‌بعدیِ بلادرنگ؟
///   * صحنه ثابت است (فقط آبشار و شاخه‌ها تکان می‌خورند)؛
///   * هیچ داراییٔ حجیمی به APK اضافه نمی‌شود؛
///   * روی هر نسبتِ تصویری بدون کشیدگی و برش پر می‌شود.
///
/// عمق با سه لایه ساخته می‌شود: تودهٔ صخره (پایین)، نوارِ ماسه،
/// و رویهٔ چمن — همان ترفندِ ۲٫۵بعدیِ بازی‌های موبایلیِ کم‌حجم.
/// ═══════════════════════════════════════════════════════════════
class IslandLandPainter extends CustomPainter {
  const IslandLandPainter({
    required this.phase,
    this.reduceMotion = false,
  });

  /// پیشرفتِ چرخهٔ محیط (۰ تا ۱)
  final double phase;

  /// در حالتِ کاهشِ حرکت فقط آبشار و شاخه‌ها ثابت می‌مانند
  final bool reduceMotion;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final geo = IslandSceneGeometry(size);
    final silhouette = geo.islandSilhouette();

    _paintCliff(canvas, geo, silhouette);
    _paintSandRim(canvas, geo, silhouette);
    _paintGrass(canvas, geo, silhouette);
    _paintGardenPath(canvas, geo);
    _paintWaterfall(canvas, geo);
    _paintBridge(canvas, geo);
    _paintHouse(canvas, geo, geo.houseA, IslandCinemaPalette.pathStoryDeep);
    _paintHouse(canvas, geo, geo.houseB, IslandCinemaPalette.pathLearnDeep);
    _paintPalm(canvas, geo, Offset(geo.w * 0.055, geo.h * 0.470), 0.92);
    _paintRoundTree(canvas, geo, Offset(geo.w * 0.325, geo.h * 0.415), 0.86);
    _paintRoundTree(canvas, geo, Offset(geo.w * 0.660, geo.h * 0.395), 0.72);
    _paintRoundTree(canvas, geo, Offset(geo.w * 0.940, geo.h * 0.455), 0.80);
    _paintBushes(canvas, geo);
    _paintShoreFoam(canvas, geo, silhouette);
  }

  // ─── صخره (برجستگیِ زیرِ جزیره) ───
  void _paintCliff(Canvas canvas, IslandSceneGeometry geo, Path silhouette) {
    final shifted = silhouette.shift(Offset(0, geo.cliffThickness));
    final bounds = shifted.getBounds();
    canvas.drawPath(
      shifted,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            IslandCinemaPalette.cliff,
            IslandCinemaPalette.cliffShade,
            IslandCinemaPalette.cliffDeep,
          ],
          stops: const <double>[0.0, 0.45, 1.0],
        ).createShader(bounds),
    );

    // چند ترکِ صخره برای حسِ متریال
    final crackPaint = Paint()
      ..color = IslandCinemaPalette.cliffDeep.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, geo.w * 0.005);
    for (var i = 0; i < 5; i++) {
      final x = geo.w * (0.10 + i * 0.20);
      final y0 = geo.islandShore + geo.h * 0.012;
      canvas.drawPath(
        Path()
          ..moveTo(x, y0)
          ..quadraticBezierTo(
            x + geo.w * 0.03,
            y0 + geo.cliffThickness * 0.5,
            x - geo.w * 0.02,
            y0 + geo.cliffThickness * 0.95,
          ),
        crackPaint,
      );
    }
  }

  // ─── نوارِ ماسهٔ ساحل ───
  void _paintSandRim(Canvas canvas, IslandSceneGeometry geo, Path silhouette) {
    canvas.drawPath(
      silhouette.shift(Offset(0, geo.sandThickness)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            IslandCinemaPalette.goldLight,
            IslandCinemaPalette.goldRich,
          ],
        ).createShader(
          Rect.fromLTWH(
            0,
            geo.islandShore - geo.h * 0.02,
            geo.w,
            geo.sandThickness + geo.h * 0.12,
          ),
        ),
    );
  }

  // ─── رویهٔ چمن ───
  void _paintGrass(Canvas canvas, IslandSceneGeometry geo, Path silhouette) {
    final bounds = silhouette.getBounds();
    canvas.drawPath(
      silhouette,
      Paint()
        ..shader = IslandCinemaGradients.meadow.createShader(bounds),
    );

    // سایهٔ گرمِ سمتِ راست (نور از راستِ بالا می‌آید)
    canvas.save();
    canvas.clipPath(silhouette);
    canvas.drawRect(
      Rect.fromLTWH(geo.w * 0.55, bounds.top, geo.w * 0.45, bounds.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Colors.transparent,
            IslandCinemaPalette.forestDeep.withOpacity(0.16),
          ],
        ).createShader(
          Rect.fromLTWH(
            geo.w * 0.55,
            bounds.top,
            geo.w * 0.45,
            bounds.height,
          ),
        ),
    );
    // هایلایتِ ملایمِ سمتِ چپِ گنبد
    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(geo.w * 0.42, geo.islandPeak + geo.h * 0.055),
        radius: geo.w * 0.30,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            IslandCinemaPalette.meadowLight.withOpacity(0.34),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(geo.w * 0.42, geo.islandPeak + geo.h * 0.055),
            radius: geo.w * 0.30,
          ),
        ),
    );
    canvas.restore();

    // دسته‌های کوچکِ علف روی خط‌الرأس
    final tuft = Paint()
      ..color = IslandCinemaPalette.forestDeep.withOpacity(0.30)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, geo.w * 0.0045);
    for (var i = 0; i < 22; i++) {
      final t = i / 21;
      final x = geo.w * (-0.03 + t * 1.06);
      final ridgeY = _ridgeYAt(geo, t);
      final sway = reduceMotion
          ? 0.0
          : math.sin(phase * 2 * math.pi + i * 0.9) * geo.h * 0.004;
      canvas.drawLine(
        Offset(x, ridgeY),
        Offset(x + sway, ridgeY - geo.h * 0.012),
        tuft,
      );
    }
  }

  /// ارتفاعِ تقریبیِ خط‌الرأس برای کاشتِ علف و بوته
  double _ridgeYAt(IslandSceneGeometry geo, double t) {
    // تابعی ساده و پیوسته که همان حسِ تپه‌ها را می‌دهد
    final dome = math.sin(t * math.pi);
    final bump = math.sin(t * math.pi * 3.0) * 0.35;
    return geo.islandPeak + geo.h * (0.10 * (1 - dome + 0.55 + bump));
  }

  // ─── مسیرِ باغچه ───
  void _paintGardenPath(Canvas canvas, IslandSceneGeometry geo) {
    canvas.drawPath(
      geo.gardenPath(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            IslandCinemaPalette.goldLight.withOpacity(0.92),
            IslandCinemaPalette.wood.withOpacity(0.80),
          ],
        ).createShader(geo.gardenPath().getBounds()),
    );
    // سنگ‌فرش‌های کوچک
    final step = Paint()..color = IslandCinemaPalette.woodShade.withOpacity(0.22);
    for (var i = 0; i < 7; i++) {
      final t = i / 6;
      final y = geo.islandShore - geo.h * 0.02 - t * geo.h * 0.20;
      final half = geo.w * (0.055 - t * 0.032);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(geo.w * (0.5 - t * 0.035), y),
          width: half * 2,
          height: geo.h * 0.010,
        ),
        step,
      );
    }
  }

  // ─── آبشار ───
  void _paintWaterfall(Canvas canvas, IslandSceneGeometry geo) {
    final left = geo.fallLeft;
    final width = geo.fallWidth;
    final top = geo.fallTop;
    final bottom = geo.fallBottom;

    // شیارِ صخره
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left - width * 0.28, top - geo.h * 0.012, width * 1.56,
            bottom - top + geo.h * 0.012),
        Radius.circular(width * 0.72),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            IslandCinemaPalette.cliffDeep,
            IslandCinemaPalette.cliffShade,
            IslandCinemaPalette.cliffDeep,
          ],
        ).createShader(
          Rect.fromLTWH(left - width * 0.28, top, width * 1.56, bottom - top),
        ),
    );

    // بدنهٔ آب
    final waterRect = Rect.fromLTWH(left, top, width, bottom - top);
    canvas.drawRRect(
      RRect.fromRectAndRadius(waterRect, Radius.circular(width * 0.5)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            IslandCinemaPalette.seaFar.withOpacity(0.95),
            IslandCinemaPalette.foam.withOpacity(0.95),
          ],
        ).createShader(waterRect),
    );

    // رگه‌های روانِ آب
    final streakPaint = Paint()
      ..color = Colors.white.withOpacity(0.72)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, width * 0.10);
    for (var i = 0; i < 5; i++) {
      final lane = i / 4;
      final x = left + width * (0.18 + lane * 0.64);
      final travel = reduceMotion ? 0.35 : ((phase * 2.2 + i * 0.31) % 1.0);
      final y = top + (bottom - top - geo.h * 0.05) * travel;
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + geo.h * 0.042),
        streakPaint,
      );
    }

    // مه و کفِ پایینِ آبشار
    final mistBase = Offset(left + width * 0.5, bottom);
    canvas.drawCircle(
      mistBase,
      width * 1.5,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            IslandCinemaPalette.foam.withOpacity(0.75),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: mistBase, radius: width * 1.5)),
    );
    for (var i = 0; i < 4; i++) {
      final pulse = reduceMotion
          ? 0.5
          : 0.5 + 0.5 * math.sin((phase * 2 * math.pi) + i * 1.3);
      canvas.drawCircle(
        mistBase + Offset((i - 1.5) * width * 0.62, -width * 0.30 * pulse),
        width * (0.30 + 0.12 * pulse),
        Paint()..color = Colors.white.withOpacity(0.42),
      );
    }
  }

  // ─── پلِ چوبی ───
  void _paintBridge(Canvas canvas, IslandSceneGeometry geo) {
    final x0 = geo.bridgeStartX;
    final x1 = geo.bridgeEndX;
    final y0 = geo.bridgeStartY;
    final y1 = geo.bridgeEndY;
    final deckWidth = math.max(6.0, geo.h * 0.014);

    // طناب‌های نگهدارنده
    final rope = Paint()
      ..color = IslandCinemaPalette.woodDeep.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, geo.h * 0.0035);

    for (final lift in <double>[-1.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(x0, y0)
          ..quadraticBezierTo(
            (x0 + x1) / 2,
            (y0 + y1) / 2 + lift * geo.h * 0.052,
            x1,
            y1,
          ),
        rope,
      );
    }

    // عرشه
    canvas.drawPath(
      Path()
        ..moveTo(x0, y0)
        ..quadraticBezierTo(
          (x0 + x1) / 2,
          (y0 + y1) / 2 + geo.h * 0.026,
          x1,
          y1,
        ),
      Paint()
        ..color = IslandCinemaPalette.woodDeep
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = deckWidth,
    );

    // تخته‌ها
    final planks = 8;
    final plankPaint = Paint()
      ..color = IslandCinemaPalette.wood
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2.0, deckWidth * 0.42);
    for (var i = 0; i <= planks; i++) {
      final t = i / planks;
      final bezX = _quad(x0, (x0 + x1) / 2, x1, t);
      final bezY = _quad(y0, (y0 + y1) / 2 + geo.h * 0.026, y1, t);
      canvas.drawLine(
        Offset(bezX, bezY - deckWidth * 0.45),
        Offset(bezX, bezY + deckWidth * 0.45),
        plankPaint,
      );
    }

    // دو ستونِ انتهایی
    final post = Paint()
      ..color = IslandCinemaPalette.woodShade
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(3.0, deckWidth * 0.55);
    canvas.drawLine(
      Offset(x1 - geo.w * 0.004, y1),
      Offset(x1 - geo.w * 0.004, y1 + deckWidth * 1.5),
      post,
    );
    canvas.drawLine(
      Offset(x0 + geo.w * 0.010, y0),
      Offset(x0 + geo.w * 0.010, y0 + deckWidth * 1.8),
      post,
    );
  }

  double _quad(double p0, double p1, double p2, double t) {
    final inv = 1 - t;
    return inv * inv * p0 + 2 * inv * t * p1 + t * t * p2;
  }

  // ─── خانهٔ فانتزی ───
  void _paintHouse(
    Canvas canvas,
    IslandSceneGeometry geo,
    Rect box,
    Color roofColor,
  ) {
    final bodyRadius = box.width * 0.20;

    // سایهٔ زیرِ خانه
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(box.center.dx, box.bottom + box.height * 0.04),
        width: box.width * 1.05,
        height: box.height * 0.16,
      ),
      Paint()..color = IslandCinemaPalette.forestDeep.withOpacity(0.20),
    );

    // بدنه
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(bodyRadius)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            IslandCinemaPalette.paper,
            IslandCinemaPalette.goldLight.withOpacity(0.92),
          ],
        ).createShader(box),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(bodyRadius)),
      Paint()
        ..color = IslandCinemaPalette.woodShade.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, box.width * 0.022),
    );

    // سقفِ مخروطی
    final roofHeight = box.height * 0.82;
    final roof = Path()
      ..moveTo(box.left - box.width * 0.14, box.top + box.height * 0.12)
      ..quadraticBezierTo(
        box.center.dx,
        box.top - roofHeight,
        box.right + box.width * 0.14,
        box.top + box.height * 0.12,
      )
      ..quadraticBezierTo(
        box.center.dx,
        box.top + box.height * 0.30,
        box.left - box.width * 0.14,
        box.top + box.height * 0.12,
      )
      ..close();
    canvas.drawPath(
      roof,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[roofColor, roofColor.withOpacity(0.72)],
        ).createShader(
          Rect.fromLTWH(
            box.left - box.width * 0.14,
            box.top - roofHeight,
            box.width * 1.28,
            roofHeight + box.height * 0.3,
          ),
        ),
    );

    // درِ گرد
    final doorSize = box.width * 0.30;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(box.center.dx, box.bottom - doorSize * 0.62),
        width: doorSize,
        height: doorSize * 1.25,
      ),
      Paint()..color = IslandCinemaPalette.wood,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(box.center.dx, box.bottom - doorSize * 0.62),
        width: doorSize * 0.72,
        height: doorSize * 1.0,
      ),
      Paint()..color = IslandCinemaPalette.woodShade.withOpacity(0.75),
    );

    // پنجرهٔ گردِ نورانی
    final win = box.width * 0.17;
    canvas.drawCircle(
      Offset(box.left + box.width * 0.24, box.top + box.height * 0.42),
      win,
      Paint()..color = IslandCinemaPalette.gold,
    );
    canvas.drawCircle(
      Offset(box.left + box.width * 0.24, box.top + box.height * 0.42),
      win * 0.62,
      Paint()..color = IslandCinemaPalette.goldLight,
    );
    canvas.drawCircle(
      Offset(box.right - box.width * 0.24, box.top + box.height * 0.42),
      win,
      Paint()..color = IslandCinemaPalette.gold,
    );
    canvas.drawCircle(
      Offset(box.right - box.width * 0.24, box.top + box.height * 0.42),
      win * 0.62,
      Paint()..color = IslandCinemaPalette.goldLight,
    );
  }

  // ─── نخل ───
  void _paintPalm(Canvas canvas, IslandSceneGeometry geo, Offset base, double scale) {
    final height = geo.h * 0.115 * scale;
    final lean = geo.w * 0.028 * scale;

    canvas.drawPath(
      Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
          base.dx + lean * 0.4,
          base.dy - height * 0.55,
          base.dx + lean,
          base.dy - height,
        ),
      Paint()
        ..color = IslandCinemaPalette.woodShade
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(3.0, geo.w * 0.016 * scale),
    );

    final crown = base + Offset(lean, -height);
    final frondPaint = Paint()
      ..color = IslandCinemaPalette.forest
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2.4, geo.w * 0.011 * scale);
    for (var i = 0; i < 6; i++) {
      final angle = -math.pi + (i / 5) * math.pi;
      final swing = reduceMotion
          ? 0.0
          : math.sin(phase * 2 * math.pi + i) * geo.h * 0.006 * scale;
      canvas.drawPath(
        Path()
          ..moveTo(crown.dx, crown.dy)
          ..quadraticBezierTo(
            crown.dx + math.cos(angle) * geo.w * 0.055 * scale,
            crown.dy + math.sin(angle) * geo.h * 0.030 * scale - geo.h * 0.012,
            crown.dx + math.cos(angle) * geo.w * 0.098 * scale,
            crown.dy + math.sin(angle) * geo.h * 0.040 * scale + swing,
          ),
        frondPaint,
      );
    }
    // نارگیل‌های کوچک
    canvas.drawCircle(
      crown + Offset(geo.w * 0.006, geo.h * 0.006),
      geo.w * 0.011 * scale,
      Paint()..color = IslandCinemaPalette.wood,
    );
    canvas.drawCircle(
      crown + Offset(-geo.w * 0.010, geo.h * 0.008),
      geo.w * 0.010 * scale,
      Paint()..color = IslandCinemaPalette.woodDeep,
    );
  }

  // ─── درختِ تاج‌گرد ───
  void _paintRoundTree(
    Canvas canvas,
    IslandSceneGeometry geo,
    Offset base,
    double scale,
  ) {
    final trunkH = geo.h * 0.052 * scale;
    final trunkW = math.max(3.5, geo.w * 0.019 * scale);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - trunkW / 2, base.dy - trunkH, trunkW, trunkH),
        Radius.circular(trunkW / 2),
      ),
      Paint()..color = IslandCinemaPalette.woodShade,
    );

    final r = geo.w * 0.052 * scale;
    final sway = reduceMotion
        ? 0.0
        : math.sin(phase * 2 * math.pi + base.dx) * geo.w * 0.004;
    final crownCenter = Offset(base.dx + sway, base.dy - trunkH - r * 0.35);

    canvas.drawCircle(
      crownCenter + Offset(0, r * 0.18),
      r * 1.05,
      Paint()..color = IslandCinemaPalette.forestDeep.withOpacity(0.85),
    );
    canvas.drawCircle(
      crownCenter - Offset(r * 0.34, -r * 0.10),
      r * 0.80,
      Paint()..color = IslandCinemaPalette.forest,
    );
    canvas.drawCircle(
      crownCenter + Offset(r * 0.30, -r * 0.16),
      r * 0.74,
      Paint()..color = IslandCinemaPalette.meadow,
    );
    canvas.drawCircle(
      crownCenter - Offset(r * 0.10, -r * 0.52),
      r * 0.56,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            IslandCinemaPalette.meadowLight.withOpacity(0.95),
            IslandCinemaPalette.meadowLight.withOpacity(0.0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: crownCenter - Offset(r * 0.10, -r * 0.52),
            radius: r * 0.56,
          ),
        ),
    );
  }

  // ─── بوته‌ها و گل‌ها ───
  void _paintBushes(Canvas canvas, IslandSceneGeometry geo) {
    const spots = <List<double>>[
      <double>[0.10, 0.560],
      <double>[0.20, 0.520],
      <double>[0.43, 0.470],
      <double>[0.60, 0.452],
      <double>[0.86, 0.520],
      <double>[0.95, 0.560],
    ];
    for (var i = 0; i < spots.length; i++) {
      final spot = spots[i];
      final center = Offset(geo.w * spot[0], geo.h * spot[1]);
      final r = geo.w * 0.020;
      canvas.drawCircle(
        center,
        r,
        Paint()..color = IslandCinemaPalette.forest.withOpacity(0.9),
      );
      canvas.drawCircle(
        center - Offset(r * 0.4, r * 0.5),
        r * 0.7,
        Paint()..color = IslandCinemaPalette.meadowLight.withOpacity(0.9),
      );
      // یک گلِ ریز برای زنده‌بودنِ صحنه
      canvas.drawCircle(
        center + Offset(r * 0.9, -r * 0.7),
        r * 0.24,
        Paint()..color = i.isEven
            ? IslandCinemaPalette.pathStory
            : IslandCinemaPalette.gold,
      );
    }
  }

  // ─── کفِ موج دورِ ساحل ───
  void _paintShoreFoam(
    Canvas canvas,
    IslandSceneGeometry geo,
    Path silhouette,
  ) {
    final offset = geo.cliffThickness;
    final pulse = reduceMotion
        ? 0.6
        : 0.5 + 0.5 * math.sin(phase * 2 * math.pi);
    final paint = Paint()
      ..color = IslandCinemaPalette.foam.withOpacity(0.30 + 0.26 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2.0, geo.h * 0.011);
    canvas.drawPath(silhouette.shift(Offset(0, offset)), paint);

    final inner = Paint()
      ..color = IslandCinemaPalette.seaFar.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2.0, geo.h * 0.008);
    canvas.drawPath(silhouette.shift(Offset(0, offset + geo.h * 0.022)), inner);
  }

  @override
  bool shouldRepaint(covariant IslandLandPainter oldDelegate) {
    if (oldDelegate.reduceMotion != reduceMotion) return true;
    if (reduceMotion && oldDelegate.reduceMotion) return false;
    return oldDelegate.phase != phase;
  }
}
