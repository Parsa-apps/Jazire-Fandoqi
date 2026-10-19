import 'package:flutter/material.dart';

import '../../app/parsa_brand.dart';

/// The canonical Parsa Apps brand mark.
///
/// Keep every in-app publisher logo routed through this widget so the artwork,
/// accessibility label and rendering quality remain consistent.
///
/// تصویر، همان لوگوی رسمی (شخصیت تاج‌دار + نماد P + نوشتهٔ PARSA APPS) است.
/// نسبت ۱:۱ و تمام جزئیات حفظ می‌شود؛ هیچ برش یا کشیدگی‌ای رخ نمی‌دهد.
class ParsaAppsLogo extends StatelessWidget {
  const ParsaAppsLogo({
    super.key,
    this.size = 64,
    this.borderRadius = 16,
    this.showShadow = true,
    this.semanticLabel = 'لوگوی پارسا اپس',
  });

  static const String assetPath = ParsaBrand.logoAsset;

  final double size;
  final double borderRadius;
  final bool showShadow;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    // برای نشان‌های کوچک (۳۴ تا ۸۰ پیکسل) رمزگشایی ۱۰۲۴ پیکسلی هم حافظه
    // می‌خواهد و هم بی‌فایده است؛ اندازهٔ رمزگشایی با نمایش هماهنگ می‌شود.
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
    final decodeWidth = (size * dpr).round().clamp(96, 1024).toInt();

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: showShadow
                ? <BoxShadow>[
                    BoxShadow(
                      color: ParsaBrand.gold.withOpacity(0.30),
                      blurRadius: size * 0.24,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: ParsaBrand.neonBlue.withOpacity(0.18),
                      blurRadius: size * 0.30,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            ParsaBrand.logoAsset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            cacheWidth: decodeWidth,
            gaplessPlayback: true,
            errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
              // فقط در حالت خرابی دارایی؛ هرگز آیکون شکسته نشان نمی‌دهد.
              return Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    fontSize: size * 0.52,
                    fontWeight: FontWeight.w900,
                    color: ParsaBrand.gold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
