import 'dart:math' as math;
import 'dart:ui' show PathOperation;

import 'package:flutter/material.dart';

/// 🎨 کتابِ رنگ‌آمیزی فندقی
///
/// هر صفحه از چند «ناحیه» ساخته شده است. کودک روی هر ناحیه بزند، همان
/// ناحیه با رنگِ انتخابی پر می‌شود؛ خط‌های دورِ ناحیه‌ها مثل نقاشیِ
/// آمادهٔ کودکانه باقی می‌مانند. برخلاف تصویرِ بیت‌مپ، این صفحات در هر
/// اندازه‌ای تیز و تمیز رندر می‌شوند و حجمی هم به بستهٔ برنامه اضافه
/// نمی‌کنند.
typedef ColoringPathBuilder = Path Function(Size size);

class ColoringRegion {
  final String id;
  final String label;
  final Color defaultColor;
  final ColoringPathBuilder buildPath;

  const ColoringRegion({
    required this.id,
    required this.label,
    required this.defaultColor,
    required this.buildPath,
  });
}

class ColoringDetail {
  final ColoringPathBuilder buildPath;
  final Color color;
  final double strokeWidth;
  final bool fill;

  const ColoringDetail({
    required this.buildPath,
    this.color = const Color(0xFF3A3A4A),
    this.strokeWidth = 2,
    this.fill = false,
  });
}

class ColoringPage {
  final String id;
  final String title;
  final String emoji;
  final String hint;
  final Color paperColor;
  final List<ColoringRegion> regions;
  final List<ColoringDetail> details;

  const ColoringPage({
    required this.id,
    required this.title,
    required this.emoji,
    required this.hint,
    required this.paperColor,
    required this.regions,
    this.details = const <ColoringDetail>[],
  });
}

const Color _ink = Color(0xFF3A3A4A);

Offset _p(Size size, double x, double y) =>
    Offset(size.width * x, size.height * y);

Path _oval(Size size, double x1, double y1, double x2, double y2) => Path()
  ..addOval(Rect.fromLTRB(
    size.width * x1,
    size.height * y1,
    size.width * x2,
    size.height * y2,
  ));

Path _roundRect(
  Size size,
  double x1,
  double y1,
  double x2,
  double y2,
  double radius,
) =>
    Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(
          size.width * x1,
          size.height * y1,
          size.width * x2,
          size.height * y2,
        ),
        Radius.circular(radius),
      ));

Path _polygon(Size size, List<double> points) {
  final path = Path();
  for (var i = 0; i + 1 < points.length; i += 2) {
    final point = _p(size, points[i], points[i + 1]);
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
}

Path _full(Size size) => Path()
  ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

Path _line(Size size, List<double> points) {
  final path = Path();
  for (var i = 0; i + 1 < points.length; i += 2) {
    final point = _p(size, points[i], points[i + 1]);
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path;
}

Path _curve(Size size, double x1, double y1, double cx, double cy, double x2,
    double y2) {
  final start = _p(size, x1, y1);
  final control = _p(size, cx, cy);
  final end = _p(size, x2, y2);
  return Path()
    ..moveTo(start.dx, start.dy)
    ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
}

Path _star(Size size, double cx, double cy, double outer, double inner,
    {int points = 5}) {
  final path = Path();
  final center = _p(size, cx, cy);
  final outerRadius = size.shortestSide * outer;
  final innerRadius = size.shortestSide * inner;
  for (var i = 0; i < points * 2; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final angle = -math.pi / 2 + (i * math.pi) / points;
    final point = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
}

/// صفحه‌های کتاب؛ ترتیبِ این فهرست همان ترتیبِ کتاب است و قانون
/// «نیمهٔ اول رایگان» روی همین ترتیب اعمال می‌شود.
class ColoringPages {
  ColoringPages._();

  static final List<ColoringPage> all = <ColoringPage>[
    // ── ۱. ماهی ────────────────────────────────────────────────
    ColoringPage(
      id: 'fish',
      title: 'ماهیِ شاد',
      emoji: '🐟',
      hint: 'آبِ دریا را آبی کن، بعد ماهی را رنگ کن.',
      paperColor: const Color(0xFFE0F7FA),
      regions: <ColoringRegion>[
        ColoringRegion(
          id: 'water',
          label: 'آبِ دریا',
          defaultColor: const Color(0xFFB3E5FC),
          buildPath: _full,
        ),
        ColoringRegion(
          id: 'tail',
          label: 'دُم',
          defaultColor: const Color(0xFFFFD54F),
          buildPath: (size) => _polygon(size, <double>[
            0.20, 0.50, 0.03, 0.32, 0.05, 0.50, 0.03, 0.68,
          ]),
        ),
        ColoringRegion(
          id: 'top_fin',
          label: 'بالهٔ بالا',
          defaultColor: const Color(0xFFF48FB1),
          buildPath: (size) => _polygon(size, <double>[
            0.34, 0.38, 0.44, 0.20, 0.54, 0.38,
          ]),
        ),
        ColoringRegion(
          id: 'bottom_fin',
          label: 'بالهٔ پایین',
          defaultColor: const Color(0xFFF48FB1),
          buildPath: (size) => _polygon(size, <double>[
            0.36, 0.62, 0.46, 0.82, 0.56, 0.62,
          ]),
        ),
        ColoringRegion(
          id: 'body',
          label: 'تنِ ماهی',
          defaultColor: const Color(0xFFFFB74D),
          buildPath: (size) => _oval(size, 0.18, 0.34, 0.70, 0.68),
        ),
      ],
      details: <ColoringDetail>[
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.47, 0.43, 0.54, 0.50),
          color: Colors.white,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.495, 0.455, 0.525, 0.485),
          color: _ink,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.56, 0.54, 0.60, 0.58, 0.56, 0.60),
          strokeWidth: 2.4,
        ),
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.30, 0.40, 0.36, 0.46, 0.31, 0.52),
          strokeWidth: 1.8,
        ),
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.38, 0.38, 0.44, 0.45, 0.39, 0.52),
          strokeWidth: 1.8,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.76, 0.22, 0.82, 0.28),
          color: const Color(0xFF81D4FA),
          strokeWidth: 1.6,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.84, 0.12, 0.88, 0.16),
          color: const Color(0xFF81D4FA),
          strokeWidth: 1.4,
        ),
      ],
    ),

    // ── ۲. خانه ────────────────────────────────────────────────
    ColoringPage(
      id: 'house',
      title: 'خانهٔ گرم',
      emoji: '🏠',
      hint: 'پشت‌بام را قرمز کن و پنجره‌ها را آبیِ روشن.',
      paperColor: const Color(0xFFE1F5FE),
      regions: <ColoringRegion>[
        ColoringRegion(
          id: 'sky',
          label: 'آسمان',
          defaultColor: const Color(0xFFB3E5FC),
          buildPath: _full,
        ),
        ColoringRegion(
          id: 'grass',
          label: 'چمن',
          defaultColor: const Color(0xFFA5D6A7),
          buildPath: (size) => _roundRect(size, -0.05, 0.78, 1.05, 1.05, 0),
        ),
        ColoringRegion(
          id: 'sun',
          label: 'خورشید',
          defaultColor: const Color(0xFFFFE082),
          buildPath: (size) => _oval(size, 0.76, 0.04, 0.96, 0.24),
        ),
        ColoringRegion(
          id: 'chimney',
          label: 'دودکش',
          defaultColor: const Color(0xFFBCAAA4),
          buildPath: (size) => _roundRect(size, 0.64, 0.22, 0.72, 0.40, 4),
        ),
        ColoringRegion(
          id: 'roof',
          label: 'پشت‌بام',
          defaultColor: const Color(0xFFE57373),
          buildPath: (size) => _polygon(size, <double>[
            0.12, 0.44, 0.46, 0.16, 0.80, 0.44,
          ]),
        ),
        ColoringRegion(
          id: 'wall',
          label: 'دیوار',
          defaultColor: const Color(0xFFFFF3E0),
          buildPath: (size) => _roundRect(size, 0.20, 0.42, 0.72, 0.82, 4),
        ),
        ColoringRegion(
          id: 'window_left',
          label: 'پنجرهٔ چپ',
          defaultColor: const Color(0xFF81D4FA),
          buildPath: (size) => _roundRect(size, 0.27, 0.48, 0.38, 0.60, 3),
        ),
        ColoringRegion(
          id: 'window_right',
          label: 'پنجرهٔ راست',
          defaultColor: const Color(0xFF81D4FA),
          buildPath: (size) => _roundRect(size, 0.54, 0.48, 0.65, 0.60, 3),
        ),
        ColoringRegion(
          id: 'door',
          label: 'در',
          defaultColor: const Color(0xFFA1887F),
          buildPath: (size) => _roundRect(size, 0.40, 0.58, 0.52, 0.82, 6),
        ),
      ],
      details: <ColoringDetail>[
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.325, 0.48, 0.325, 0.60,
        ])),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.27, 0.54, 0.38, 0.54,
        ])),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.595, 0.48, 0.595, 0.60,
        ])),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.54, 0.54, 0.65, 0.54,
        ])),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.475, 0.68, 0.495, 0.70),
          color: _ink,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.60, 0.26, 0.65, 0.20, 0.60, 0.16),
          color: const Color(0xFFB0BEC5),
          strokeWidth: 5,
        ),
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.60, 0.31, 0.68, 0.24, 0.62, 0.18),
          color: const Color(0xFFB0BEC5),
          strokeWidth: 4,
        ),
      ],
    ),

    // ── ۳. گل ──────────────────────────────────────────────────
    ColoringPage(
      id: 'flower',
      title: 'گلِ باغ',
      emoji: '🌸',
      hint: 'هر گلبرگ را یک رنگ کن؛ وسطش را زرد بگذار.',
      paperColor: const Color(0xFFF1F8E9),
      regions: <ColoringRegion>[
        ColoringRegion(
          id: 'sky',
          label: 'آسمان',
          defaultColor: const Color(0xFFE1F5FE),
          buildPath: _full,
        ),
        ColoringRegion(
          id: 'grass',
          label: 'چمن',
          defaultColor: const Color(0xFFC5E1A5),
          buildPath: (size) => _roundRect(size, -0.05, 0.80, 1.05, 1.05, 0),
        ),
        ColoringRegion(
          id: 'stem',
          label: 'ساقه',
          defaultColor: const Color(0xFF66BB6A),
          buildPath: (size) => _roundRect(size, 0.47, 0.50, 0.53, 0.86, 4),
        ),
        ColoringRegion(
          id: 'leaf_left',
          label: 'برگِ چپ',
          defaultColor: const Color(0xFF81C784),
          buildPath: (size) => _curveLeaf(size, 0.47, 0.64, 0.28, 0.56, 0.30, 0.72),
        ),
        ColoringRegion(
          id: 'leaf_right',
          label: 'برگِ راست',
          defaultColor: const Color(0xFF81C784),
          buildPath: (size) => _curveLeaf(size, 0.53, 0.70, 0.72, 0.62, 0.70, 0.78),
        ),
        ColoringRegion(
          id: 'petal_1',
          label: 'گلبرگ ۱',
          defaultColor: const Color(0xFFF06292),
          buildPath: (size) => _oval(size, 0.42, 0.10, 0.58, 0.28),
        ),
        ColoringRegion(
          id: 'petal_2',
          label: 'گلبرگ ۲',
          defaultColor: const Color(0xFFFFB74D),
          buildPath: (size) => _oval(size, 0.56, 0.16, 0.72, 0.34),
        ),
        ColoringRegion(
          id: 'petal_3',
          label: 'گلبرگ ۳',
          defaultColor: const Color(0xFFF06292),
          buildPath: (size) => _oval(size, 0.56, 0.32, 0.72, 0.50),
        ),
        ColoringRegion(
          id: 'petal_4',
          label: 'گلبرگ ۴',
          defaultColor: const Color(0xFFFFB74D),
          buildPath: (size) => _oval(size, 0.42, 0.38, 0.58, 0.56),
        ),
        ColoringRegion(
          id: 'petal_5',
          label: 'گلبرگ ۵',
          defaultColor: const Color(0xFFF06292),
          buildPath: (size) => _oval(size, 0.28, 0.32, 0.44, 0.50),
        ),
        ColoringRegion(
          id: 'petal_6',
          label: 'گلبرگ ۶',
          defaultColor: const Color(0xFFFFB74D),
          buildPath: (size) => _oval(size, 0.28, 0.16, 0.44, 0.34),
        ),
        ColoringRegion(
          id: 'center',
          label: 'وسطِ گل',
          defaultColor: const Color(0xFFFFE082),
          buildPath: (size) => _oval(size, 0.42, 0.22, 0.58, 0.40),
        ),
      ],
      details: <ColoringDetail>[
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.465, 0.285, 0.485, 0.305),
          color: _ink,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.515, 0.285, 0.535, 0.305),
          color: _ink,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.475, 0.33, 0.50, 0.35, 0.525, 0.33),
          strokeWidth: 2,
        ),
      ],
    ),

    // ── ۴. پروانه ──────────────────────────────────────────────
    ColoringPage(
      id: 'butterfly',
      title: 'پروانهٔ رنگین',
      emoji: '🦋',
      hint: 'چهار بال را چهار رنگ کن؛ پروانه پرواز می‌کند!',
      paperColor: const Color(0xFFEDE7F6),
      regions: <ColoringRegion>[
        ColoringRegion(
          id: 'sky',
          label: 'آسمان',
          defaultColor: const Color(0xFFE1F5FE),
          buildPath: _full,
        ),
        ColoringRegion(
          id: 'wing_tl',
          label: 'بالِ بالا چپ',
          defaultColor: const Color(0xFFBA68C8),
          buildPath: (size) => _oval(size, 0.12, 0.18, 0.47, 0.48),
        ),
        ColoringRegion(
          id: 'wing_tr',
          label: 'بالِ بالا راست',
          defaultColor: const Color(0xFF64B5F6),
          buildPath: (size) => _oval(size, 0.53, 0.18, 0.88, 0.48),
        ),
        ColoringRegion(
          id: 'wing_bl',
          label: 'بالِ پایین چپ',
          defaultColor: const Color(0xFFFFB74D),
          buildPath: (size) => _oval(size, 0.18, 0.46, 0.47, 0.74),
        ),
        ColoringRegion(
          id: 'wing_br',
          label: 'بالِ پایین راست',
          defaultColor: const Color(0xFFFF8A80),
          buildPath: (size) => _oval(size, 0.53, 0.46, 0.82, 0.74),
        ),
        ColoringRegion(
          id: 'body',
          label: 'تنِ پروانه',
          defaultColor: const Color(0xFF6D4C41),
          buildPath: (size) => _roundRect(size, 0.46, 0.28, 0.54, 0.78, 12),
        ),
        ColoringRegion(
          id: 'head',
          label: 'سر',
          defaultColor: const Color(0xFF8D6E63),
          buildPath: (size) => _oval(size, 0.445, 0.20, 0.555, 0.31),
        ),
      ],
      details: <ColoringDetail>[
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.465, 0.21, 0.42, 0.10, 0.36, 0.08),
          strokeWidth: 2,
        ),
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.535, 0.21, 0.58, 0.10, 0.64, 0.08),
          strokeWidth: 2,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.36, 0.06, 0.375, 0.075),
          color: _ink,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.625, 0.06, 0.64, 0.075),
          color: _ink,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.245, 0.29, 0.315, 0.36),
          color: Colors.white,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.685, 0.29, 0.755, 0.36),
          color: Colors.white,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.285, 0.55, 0.34, 0.61),
          color: Colors.white,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.66, 0.55, 0.715, 0.61),
          color: Colors.white,
          fill: true,
        ),
      ],
    ),

    // ── ۵. ماشین ───────────────────────────────────────────────
    ColoringPage(
      id: 'car',
      title: 'ماشینِ قرمز',
      emoji: '🚗',
      hint: 'بدنه را قرمز کن و چرخ‌ها را سیاهِ دلخواه.',
      paperColor: const Color(0xFFECEFF1),
      regions: <ColoringRegion>[
        ColoringRegion(
          id: 'road',
          label: 'جاده',
          defaultColor: const Color(0xFFB0BEC5),
          buildPath: (size) => _roundRect(size, -0.05, 0.72, 1.05, 1.05, 0),
        ),
        ColoringRegion(
          id: 'cabin',
          label: 'کابین',
          defaultColor: const Color(0xFF64B5F6),
          buildPath: (size) => _roundRect(size, 0.30, 0.22, 0.70, 0.48, 18),
        ),
        ColoringRegion(
          id: 'body',
          label: 'بدنه',
          defaultColor: const Color(0xFFE53935),
          buildPath: (size) => _roundRect(size, 0.10, 0.38, 0.90, 0.72, 18),
        ),
        ColoringRegion(
          id: 'window_left',
          label: 'شیشهٔ چپ',
          defaultColor: const Color(0xFFB3E5FC),
          buildPath: (size) => _roundRect(size, 0.35, 0.27, 0.48, 0.42, 5),
        ),
        ColoringRegion(
          id: 'window_right',
          label: 'شیشهٔ راست',
          defaultColor: const Color(0xFFB3E5FC),
          buildPath: (size) => _roundRect(size, 0.52, 0.27, 0.65, 0.42, 5),
        ),
        ColoringRegion(
          id: 'wheel_left',
          label: 'چرخِ چپ',
          defaultColor: const Color(0xFF37474F),
          buildPath: (size) => _oval(size, 0.20, 0.60, 0.40, 0.82),
        ),
        ColoringRegion(
          id: 'wheel_right',
          label: 'چرخِ راست',
          defaultColor: const Color(0xFF37474F),
          buildPath: (size) => _oval(size, 0.60, 0.60, 0.80, 0.82),
        ),
      ],
      details: <ColoringDetail>[
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.26, 0.67, 0.34, 0.75),
          color: const Color(0xFFCFD8DC),
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.66, 0.67, 0.74, 0.75),
          color: const Color(0xFFCFD8DC),
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _roundRect(size, 0.13, 0.50, 0.20, 0.56, 3),
          color: const Color(0xFFFFF59D),
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _roundRect(size, 0.80, 0.50, 0.87, 0.56, 3),
          color: const Color(0xFFFF8A80),
          fill: true,
        ),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.02, 0.90, 0.18, 0.90,
        ]), color: Colors.white, strokeWidth: 4),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.30, 0.90, 0.46, 0.90,
        ]), color: Colors.white, strokeWidth: 4),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.58, 0.90, 0.74, 0.90,
        ]), color: Colors.white, strokeWidth: 4),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.86, 0.90, 0.98, 0.90,
        ]), color: Colors.white, strokeWidth: 4),
      ],
    ),

    // ── ۶. موشک ────────────────────────────────────────────────
    ColoringPage(
      id: 'rocket',
      title: 'موشکِ ستاره',
      emoji: '🚀',
      hint: 'موشک را روشن کن و آسمان را تیره بگذار.',
      paperColor: const Color(0xFF1B1B3A),
      regions: <ColoringRegion>[
        ColoringRegion(
          id: 'space',
          label: 'فضا',
          defaultColor: const Color(0xFF283593),
          buildPath: _full,
        ),
        ColoringRegion(
          id: 'body',
          label: 'تنِ موشک',
          defaultColor: const Color(0xFFF5F5F5),
          buildPath: (size) => _polygon(size, <double>[
            0.38, 0.78, 0.38, 0.40, 0.50, 0.13, 0.62, 0.40, 0.62, 0.78,
          ]),
        ),
        ColoringRegion(
          id: 'nose',
          label: 'نوکِ موشک',
          defaultColor: const Color(0xFFE53935),
          buildPath: (size) => _polygon(size, <double>[
            0.38, 0.40, 0.50, 0.13, 0.62, 0.40,
          ]),
        ),
        ColoringRegion(
          id: 'fin_left',
          label: 'بالِ چپ',
          defaultColor: const Color(0xFF1E88E5),
          buildPath: (size) => _polygon(size, <double>[
            0.38, 0.62, 0.22, 0.82, 0.38, 0.78,
          ]),
        ),
        ColoringRegion(
          id: 'fin_right',
          label: 'بالِ راست',
          defaultColor: const Color(0xFF1E88E5),
          buildPath: (size) => _polygon(size, <double>[
            0.62, 0.62, 0.78, 0.82, 0.62, 0.78,
          ]),
        ),
        ColoringRegion(
          id: 'window',
          label: 'پنجره',
          defaultColor: const Color(0xFF81D4FA),
          buildPath: (size) => _oval(size, 0.44, 0.40, 0.56, 0.52),
        ),
        ColoringRegion(
          id: 'flame',
          label: 'شعله',
          defaultColor: const Color(0xFFFFB74D),
          buildPath: (size) => _polygon(size, <double>[
            0.43, 0.79, 0.50, 0.97, 0.57, 0.79,
          ]),
        ),
      ],
      details: <ColoringDetail>[
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.14, 0.20, 0.17, 0.23),
          color: Colors.white,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.80, 0.16, 0.84, 0.20),
          color: Colors.white,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.70, 0.60, 0.73, 0.63),
          color: Colors.white,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.20, 0.66, 0.23, 0.69),
          color: Colors.white,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _star(size, 0.88, 0.38, 0.035, 0.016),
          color: Colors.white,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.435, 0.395, 0.565, 0.525),
          strokeWidth: 2.6,
          color: const Color(0xFF90CAF9),
        ),
      ],
    ),

    // ── ۷. بستنی ───────────────────────────────────────────────
    ColoringPage(
      id: 'icecream',
      title: 'بستنیِ شاد',
      emoji: '🍦',
      hint: 'هر توپ بستنی یک طعم و یک رنگ دارد!',
      paperColor: const Color(0xFFFFF1F5),
      regions: <ColoringRegion>[
        ColoringRegion(
          id: 'background',
          label: 'پس‌زمینه',
          defaultColor: const Color(0xFFFFE4EC),
          buildPath: _full,
        ),
        ColoringRegion(
          id: 'cone',
          label: 'قیف',
          defaultColor: const Color(0xFFD7A86E),
          buildPath: (size) => _polygon(size, <double>[
            0.38, 0.52, 0.62, 0.52, 0.50, 0.94,
          ]),
        ),
        ColoringRegion(
          id: 'scoop_bottom',
          label: 'توپِ پایین',
          defaultColor: const Color(0xFFF8BBD0),
          buildPath: (size) => _oval(size, 0.29, 0.40, 0.71, 0.68),
        ),
        ColoringRegion(
          id: 'scoop_middle',
          label: 'توپِ وسط',
          defaultColor: const Color(0xFFFFD54F),
          buildPath: (size) => _oval(size, 0.32, 0.26, 0.68, 0.52),
        ),
        ColoringRegion(
          id: 'scoop_top',
          label: 'توپِ بالا',
          defaultColor: const Color(0xFFA5D6A7),
          buildPath: (size) => _oval(size, 0.36, 0.12, 0.64, 0.38),
        ),
        ColoringRegion(
          id: 'cherry',
          label: 'گیلاس',
          defaultColor: const Color(0xFFE53935),
          buildPath: (size) => _oval(size, 0.54, 0.05, 0.64, 0.15),
        ),
      ],
      details: <ColoringDetail>[
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.40, 0.58, 0.58, 0.58,
        ]), color: const Color(0xFF8D6E63), strokeWidth: 1.6),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.42, 0.66, 0.56, 0.66,
        ]), color: const Color(0xFF8D6E63), strokeWidth: 1.6),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.44, 0.74, 0.54, 0.74,
        ]), color: const Color(0xFF8D6E63), strokeWidth: 1.6),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.49, 0.52, 0.46, 0.94,
        ]), color: const Color(0xFF8D6E63), strokeWidth: 1.6),
        ColoringDetail(buildPath: (size) => _line(size, <double>[
          0.56, 0.52, 0.52, 0.94,
        ]), color: const Color(0xFF8D6E63), strokeWidth: 1.6),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.42, 0.29, 0.45, 0.32),
          color: const Color(0xFFEF5350),
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.55, 0.34, 0.58, 0.37),
          color: const Color(0xFFAB47BC),
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.47, 0.18, 0.50, 0.21),
          color: const Color(0xFF42A5F5),
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.585, 0.10, 0.64, 0.04, 0.66, 0.01),
          color: _ink,
          strokeWidth: 2,
        ),
      ],
    ),

    // ── ۸. لاک‌پشت ─────────────────────────────────────────────
    ColoringPage(
      id: 'turtle',
      title: 'لاک‌پشتِ آرام',
      emoji: '🐢',
      hint: 'لاک را سبز کن؛ خانه‌اش روی پشتش است.',
      paperColor: const Color(0xFFFFF8E1),
      regions: <ColoringRegion>[
        ColoringRegion(
          id: 'sand',
          label: 'شن',
          defaultColor: const Color(0xFFFFE0B2),
          buildPath: _full,
        ),
        ColoringRegion(
          id: 'tail',
          label: 'دُم',
          defaultColor: const Color(0xFF8BC34A),
          buildPath: (size) => _polygon(size, <double>[
            0.14, 0.50, 0.22, 0.46, 0.22, 0.58,
          ]),
        ),
        ColoringRegion(
          id: 'leg_1',
          label: 'پای ۱',
          defaultColor: const Color(0xFF7CB342),
          buildPath: (size) => _oval(size, 0.20, 0.60, 0.31, 0.72),
        ),
        ColoringRegion(
          id: 'leg_2',
          label: 'پای ۲',
          defaultColor: const Color(0xFF7CB342),
          buildPath: (size) => _oval(size, 0.30, 0.68, 0.41, 0.80),
        ),
        ColoringRegion(
          id: 'leg_3',
          label: 'پای ۳',
          defaultColor: const Color(0xFF7CB342),
          buildPath: (size) => _oval(size, 0.59, 0.68, 0.70, 0.80),
        ),
        ColoringRegion(
          id: 'leg_4',
          label: 'پای ۴',
          defaultColor: const Color(0xFF7CB342),
          buildPath: (size) => _oval(size, 0.69, 0.60, 0.80, 0.72),
        ),
        ColoringRegion(
          id: 'shell',
          label: 'لاک',
          defaultColor: const Color(0xFF66BB6A),
          buildPath: (size) => _oval(size, 0.20, 0.28, 0.80, 0.70),
        ),
        ColoringRegion(
          id: 'head',
          label: 'سر',
          defaultColor: const Color(0xFF9CCC65),
          buildPath: (size) => _oval(size, 0.72, 0.38, 0.92, 0.58),
        ),
      ],
      details: <ColoringDetail>[
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.30, 0.38, 0.42, 0.46),
          strokeWidth: 2,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.46, 0.35, 0.58, 0.43),
          strokeWidth: 2,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.62, 0.35, 0.72, 0.43),
          strokeWidth: 2,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.36, 0.50, 0.48, 0.58),
          strokeWidth: 2,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.52, 0.50, 0.64, 0.58),
          strokeWidth: 2,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.78, 0.44, 0.805, 0.465),
          color: _ink,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.82, 0.50, 0.86, 0.51, 0.87, 0.47),
          strokeWidth: 1.8,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.08, 0.18, 0.11, 0.21),
          color: const Color(0xFFFFCC80),
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.88, 0.80, 0.91, 0.83),
          color: const Color(0xFFFFCC80),
          fill: true,
        ),
      ],
    ),

    // ── ۹. بادکنک ──────────────────────────────────────────────
    ColoringPage(
      id: 'balloon',
      title: 'بادکنکِ پروازی',
      emoji: '🎈',
      hint: 'بادکنک را قرمز کن و ابرها را سفید بگذار.',
      paperColor: const Color(0xFFE3F2FD),
      regions: <ColoringRegion>[
        ColoringRegion(
          id: 'sky',
          label: 'آسمان',
          defaultColor: const Color(0xFFBBDEFB),
          buildPath: _full,
        ),
        ColoringRegion(
          id: 'cloud',
          label: 'ابر',
          defaultColor: const Color(0xFFF5F5F5),
          buildPath: (size) => _cloudPath(size),
        ),
        ColoringRegion(
          id: 'balloon',
          label: 'بادکنک',
          defaultColor: const Color(0xFFE53935),
          buildPath: (size) => _oval(size, 0.28, 0.10, 0.72, 0.58),
        ),
        ColoringRegion(
          id: 'knot',
          label: 'گره',
          defaultColor: const Color(0xFFFFD54F),
          buildPath: (size) => _polygon(size, <double>[
            0.46, 0.57, 0.54, 0.57, 0.50, 0.63,
          ]),
        ),
      ],
      details: <ColoringDetail>[
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.50, 0.63, 0.42, 0.75, 0.53, 0.90),
          strokeWidth: 2,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.34, 0.17, 0.40, 0.31),
          color: Colors.white,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.76, 0.14, 0.80, 0.18),
          color: Colors.white,
          fill: true,
        ),
      ],
    ),

    // ── ۱۰. ستاره ──────────────────────────────────────────────
    ColoringPage(
      id: 'star',
      title: 'ستارهٔ شب',
      emoji: '⭐',
      hint: 'ستارهٔ بزرگ را طلایی کن؛ آسمان مالِ توست.',
      paperColor: const Color(0xFF141B3D),
      regions: <ColoringRegion>[
        ColoringRegion(
          id: 'night',
          label: 'آسمانِ شب',
          defaultColor: const Color(0xFF1A237E),
          buildPath: _full,
        ),
        ColoringRegion(
          id: 'moon',
          label: 'ماه',
          defaultColor: const Color(0xFFFFF9C4),
          buildPath: (size) => _crescentPath(size),
        ),
        ColoringRegion(
          id: 'star_small_1',
          label: 'ستارهٔ کوچک ۱',
          defaultColor: const Color(0xFFFFE082),
          buildPath: (size) => _star(size, 0.18, 0.20, 0.045, 0.020),
        ),
        ColoringRegion(
          id: 'star_small_2',
          label: 'ستارهٔ کوچک ۲',
          defaultColor: const Color(0xFFFFE082),
          buildPath: (size) => _star(size, 0.84, 0.30, 0.040, 0.018),
        ),
        ColoringRegion(
          id: 'star_small_3',
          label: 'ستارهٔ کوچک ۳',
          defaultColor: const Color(0xFFFFE082),
          buildPath: (size) => _star(size, 0.72, 0.82, 0.035, 0.016),
        ),
        ColoringRegion(
          id: 'star_big',
          label: 'ستارهٔ بزرگ',
          defaultColor: const Color(0xFFFFD54F),
          buildPath: (size) => _star(size, 0.47, 0.55, 0.28, 0.13),
        ),
      ],
      details: <ColoringDetail>[
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.41, 0.51, 0.435, 0.535),
          color: _ink,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _oval(size, 0.505, 0.51, 0.53, 0.535),
          color: _ink,
          fill: true,
        ),
        ColoringDetail(
          buildPath: (size) => _curve(size, 0.42, 0.59, 0.47, 0.62, 0.52, 0.59),
          strokeWidth: 2,
        ),
      ],
    ),
  ];

  static ColoringPage? byId(String id) {
    for (final page in all) {
      if (page.id == id) return page;
    }
    return null;
  }

  static String? regionAt(ColoringPage page, Offset point, Size size) {
    // آخرین ناحیه‌ای که نقطه را دربرمی‌گیرد، بالاترین لایه است.
    for (final region in page.regions.reversed) {
      if (region.buildPath(size).contains(point)) return region.id;
    }
    return null;
  }
}

Path _curveLeaf(
  Size size,
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
) {
  final start = _p(size, x1, y1);
  final tip = _p(size, x2, y2);
  final end = _p(size, x3, y3);
  final firstControl = _p(size, (x1 + x2) / 2, y1 - 0.06);
  final secondControl = _p(size, (x2 + x3) / 2, y3 + 0.06);
  return Path()
    ..moveTo(start.dx, start.dy)
    ..quadraticBezierTo(firstControl.dx, firstControl.dy, tip.dx, tip.dy)
    ..quadraticBezierTo(secondControl.dx, secondControl.dy, end.dx, end.dy)
    ..close();
}

Path _cloudPath(Size size) {
  final path = Path();
  final baseY = 0.78;
  path.moveTo(size.width * 0.08, size.height * baseY);
  path.quadraticBezierTo(
    size.width * 0.02,
    size.height * 0.72,
    size.width * 0.14,
    size.height * 0.68,
  );
  path.quadraticBezierTo(
    size.width * 0.16,
    size.height * 0.58,
    size.width * 0.28,
    size.height * 0.61,
  );
  path.quadraticBezierTo(
    size.width * 0.34,
    size.height * 0.50,
    size.width * 0.45,
    size.height * 0.58,
  );
  path.quadraticBezierTo(
    size.width * 0.56,
    size.height * 0.48,
    size.width * 0.65,
    size.height * 0.60,
  );
  path.quadraticBezierTo(
    size.width * 0.79,
    size.height * 0.55,
    size.width * 0.82,
    size.height * 0.66,
  );
  path.quadraticBezierTo(
    size.width * 0.96,
    size.height * 0.68,
    size.width * 0.92,
    size.height * 0.78,
  );
  path.close();
  return path;
}

Path _crescentPath(Size size) {
  final outer = _oval(size, 0.10, 0.08, 0.36, 0.34);
  final inner = _oval(size, 0.17, 0.05, 0.41, 0.30);
  return Path.combine(PathOperation.difference, outer, inner);
}
