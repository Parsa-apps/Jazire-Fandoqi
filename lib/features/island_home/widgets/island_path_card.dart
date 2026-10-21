import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_cinema_style.dart';
import '../painters/path_icon_painter.dart';
import 'island_3d_surface.dart';

/// 🧭 یکی از سه مسیرِ اصلیِ خانه: بازی، آموزش یا داستان.
///
/// کودکِ ۵ساله‌ای که هنوز نمی‌خواند باید فقط با نگاه‌کردن تشخیص
/// بدهد کجا می‌رود؛ برای همین:
///   * نشان، بزرگ و برداری است (دستهٔ بازی / کتابِ باز / کتابِ ستاره)؛
///   * هر مسیر رنگِ اختصاصیِ خودش را دارد (بنفش / آبی / صورتی)؛
///   * برچسبِ فارسی هست اما شرطِ استفاده نیست: نشان به‌تنهایی کافی است؛
///   * با لمسِ طولانی یا از طریقِ راهنمای صوتی نامِ مسیر خوانده می‌شود.
class IslandPathCard extends StatelessWidget {
  const IslandPathCard({
    super.key,
    required this.label,
    required this.icon,
    required this.baseColor,
    required this.deepColor,
    required this.onTap,
    this.height = IslandCinemaMetrics.pathCardHeight,
    this.semanticHint,
    this.enabled = true,
  });

  final String label;
  final IslandPathIcon icon;
  final Color baseColor;
  final Color deepColor;
  final VoidCallback onTap;
  final double height;
  final String? semanticHint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Island3DSurface(
      height: height,
      radius: IslandCinemaMetrics.radius,
      extrusion: IslandCinemaMetrics.extrusion,
      baseColor: baseColor,
      deepColor: deepColor,
      enabled: enabled,
      onTap: onTap,
      semanticLabel: label,
      semanticHint: semanticHint,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: height * 0.46,
            height: height * 0.46,
            child: CustomPaint(
              painter: PathIconPainter(
                icon: icon,
                baseColor: baseColor,
                deepColor: deepColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              textDirection: TextDirection.rtl,
              style: AppFonts.kids(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                    color: deepColor.withOpacity(0.9),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
