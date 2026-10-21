import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_cinema_style.dart';
import '../painters/island_crest_painter.dart';

/// 🏅 لوگوی «جزیره فندقی» — هویتِ طلایی، چوبی و طبیعی.
///
/// تصمیمِ طراحی: هیچ فایلِ تصویری برای واژه‌نما اضافه نشده است؛
/// نشان با [IslandCrestPainter] و نوشته با `ShaderMask` روی فونتِ
/// کودکانهٔ موجود کشیده می‌شوند. سه دلیل:
///   ۱. در هر اندازه‌ای (از ۳۲۰ تا تبلت) تیز می‌ماند؛
///   ۲. حجمِ APK افزایش نمی‌یابد؛
///   ۳. راست‌به‌چپ و شکل‌دهیِ فارسی دقیقاً همان فونتِ برنامه است.
///
/// سایهٔ تیرهٔ پشتِ نوشته عمداً دو لایه است تا روی آسمانِ روشن و روی
/// برگ‌های تیره هر دو خوانا بماند (کنتراست برای کودکِ کم‌بینا).
class IslandLogo extends StatelessWidget {
  const IslandLogo({
    super.key,
    this.title = IslandHomeStrings.appName,
    this.fontSize = 30,
    this.crestSize = 46,
    this.showCrest = true,
  });

  final String title;
  final double fontSize;
  final double crestSize;
  final bool showCrest;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppFonts.kids(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1.15,
      color: Colors.white,
    );

    final wordmark = Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // لایهٔ پشت: فقط سایه (بدنهِ شفاف) برای کنتراست
        Text(
          title,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: textStyle.copyWith(
            color: Colors.transparent,
            shadows: <Shadow>[
              Shadow(
                color: IslandCinemaPalette.shade.withOpacity(0.55),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
              Shadow(
                color: IslandCinemaPalette.bronze.withOpacity(0.95),
                blurRadius: 1.6,
                offset: const Offset(0, 1.6),
              ),
            ],
          ),
        ),
        // لایهٔ رویی: شیبِ طلایی
        ShaderMask(
          shaderCallback: (Rect bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              IslandCinemaPalette.goldLight,
              IslandCinemaPalette.gold,
              IslandCinemaPalette.goldDeep,
            ],
            stops: <double>[0.0, 0.45, 1.0],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            title,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: textStyle,
          ),
        ),
      ],
    );

    if (!showCrest) {
      return Semantics(
        header: true,
        label: title,
        child: ExcludeSemantics(child: wordmark),
      );
    }

    return Semantics(
      header: true,
      label: title,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: crestSize + 12,
              height: crestSize + 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    IslandCinemaPalette.goldLight.withOpacity(0.55),
                    IslandCinemaPalette.gold.withOpacity(0.14),
                    Colors.transparent,
                  ],
                  stops: const <double>[0.0, 0.62, 1.0],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: CustomPaint(
                  painter: const IslandCrestPainter(),
                  size: Size(crestSize, crestSize),
                ),
              ),
            ),
            const SizedBox(width: 8),
            wordmark,
          ],
        ),
      ),
    );
  }
}
