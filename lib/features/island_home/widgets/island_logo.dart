import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_cinema_style.dart';
import '../painters/island_crest_painter.dart';

/// 🏅 لوگوی «جزیره فندقی» — هویتِ طلایی، چوبی و طبیعی.
///
/// تصمیم‌های طراحی:
///   * هیچ فایلِ تصویری برای واژه‌نما اضافه نشده است؛ نشان با
///     [IslandCrestPainter] و نوشته با فونتِ کودکانهٔ موجود کشیده
///     می‌شوند. سه دلیل: در هر اندازه‌ای (از ۳۲۰ تا تبلت) تیز
///     می‌ماند، حجمِ APK افزایش نمی‌یابد، و راست‌به‌چپ و شکل‌دهیِ
///     فارسی دقیقاً همان فونتِ برنامه است.
///   * برجستگی با سه سایه روی **یک** ویجتِ `Text` ساخته شده است
///     (تیرهٔ پایین، تیرهٔ دورخط، هایلایتِ بالا) — نه با دو `Text`
///     روی هم؛ با این کار برچسبِ لوگو در درختِ ویجت‌ها یکتا می‌ماند
///     و تست‌های دسترس‌پذیری و متن درست کار می‌کنند.
///   * کنتراستِ نوشته روی آسمانِ روشن با سایهٔ تیرهٔ دورخط تضمین
///     می‌شود (برای کودکِ کم‌بینا و نورِ زیادِ محیط).
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
    final wordmark = Text(
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
        shadows: <Shadow>[
          // دورخطِ تیره: خوانایی روی آسمانِ روشن
          Shadow(
            color: IslandCinemaPalette.woodDeep.withOpacity(0.95),
            blurRadius: 2,
            offset: const Offset(0, 1.4),
          ),
          // سایهٔ نرم: جداشدن از پس‌زمینه
          Shadow(
            color: IslandCinemaPalette.shade.withOpacity(0.45),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          // هایلایتِ بالا: حسِ برجستگیِ طلایی
          Shadow(
            color: IslandCinemaPalette.goldLight.withOpacity(0.9),
            blurRadius: 1,
            offset: const Offset(0, -1.2),
          ),
        ],
      ),
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
