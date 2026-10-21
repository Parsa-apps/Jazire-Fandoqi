import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_world_style.dart';

/// صحنهٔ رنگیِ آزمایش؛ همهٔ آزمایش‌ها از همین قالب استفاده می‌کنند تا
/// کودک همیشه بداند «صحنهٔ بازی» کجاست و «کنترل‌ها» کجا.
class ExperimentStage extends StatelessWidget {
  const ExperimentStage({
    super.key,
    required this.child,
    required this.colors,
    this.height = 230,
    this.borderColor,
  });

  final Widget child;
  final List<Color> colors;
  final double height;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.55),
          width: 1.6,
        ),
      ),
      child: child,
    );
  }
}

/// پیامِ کوتاهِ نتیجه/راهنما زیرِ صحنه.
class ExperimentCaption extends StatelessWidget {
  const ExperimentCaption({
    super.key,
    required this.text,
    this.emoji = '💡',
    this.color = IslandWorldPalette.ink,
  });

  final String text;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F4),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFDDE8DF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppFonts.vazirmatn(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.6,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// دکمهٔ کوچکِ «شروع دوباره» که در همهٔ آزمایش‌ها یکسان است.
class ExperimentResetIcon extends StatelessWidget {
  const ExperimentResetIcon({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'شروع دوبارهٔ آزمایش',
      child: IconButton(
        tooltip: 'شروع دوباره',
        onPressed: onTap,
        icon: const Icon(Icons.restart_alt_rounded),
        color: IslandWorldPalette.mutedInk,
      ),
    );
  }
}

/// برچسبِ کوچکِ «آزمایش انجام شد» برای بخش‌های تکمیل‌شده.
class ExperimentDoneBadge extends StatelessWidget {
  const ExperimentDoneBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Text(
        '✓ انجام شد',
        style: AppFonts.vazirmatn(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1B5E20),
        ),
      ),
    );
  }
}
