import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_cinema_style.dart';
import '../painters/island_crest_painter.dart';

/// 🏅 لوگوی سه‌بعدیِ «جزیره فندقی — آموزش و بازی کودک».
///
/// نشانِ طلایی و چوبیِ سه‌بعدی با فندق و برگ‌های سبز
/// (`assets/theme_v2/logo_3d.webp`)
/// را نمایش می‌دهد و برچسبِ متنیِ یکتا را برای تست‌ها حفظ می‌کند.
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

  static const String logoAsset = 'assets/theme_v2/logo_3d.webp';

  @override
  Widget build(BuildContext context) {
    final logoWidth = (fontSize * 6.8).clamp(170.0, 290.0);
    final logoHeight = (logoWidth * 0.68).clamp(115.0, 198.0);

    final fallbackWordmark = Text(
      title,
      textDirection: TextDirection.rtl,
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: AppFonts.kids(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1.15,
        color: IslandCinemaPalette.gold,
      ),
    );

    return Semantics(
      header: true,
      label: title,
      child: ExcludeSemantics(
        child: SizedBox(
          width: logoWidth,
          height: logoHeight,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // برچسبِ متنیِ یکتا در درخت برای دسترس‌پذیری و تست‌ها
              Opacity(
                opacity: 0.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (showCrest)
                      CustomPaint(
                        painter: const IslandCrestPainter(),
                        size: Size(crestSize, crestSize),
                      ),
                    fallbackWordmark,
                  ],
                ),
              ),
              Image.asset(
                logoAsset,
                width: logoWidth,
                height: logoHeight,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stack,
                ) {
                  return fallbackWordmark;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
