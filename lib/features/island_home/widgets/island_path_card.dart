import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_cinema_style.dart';
import '../../../core/audio_service.dart';
import '../painters/path_icon_painter.dart';

/// 🧭 دکمهٔ کپسولیِ شیشه‌ایِ مسیرهای اصلیِ خانه (بازی، آموزش، داستان).
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
    final pillHeight = height.clamp(36.0, 56.0);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: semanticHint,
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              AudioService.select();
              onTap();
            }
          : null,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  AudioService.select();
                  onTap();
                }
              : null,
          child: Container(
            height: pillHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xD8134E5E),
                  Color(0xEB092C36),
                ],
              ),
              border: Border.all(
                color: baseColor.withOpacity(0.90),
                width: 1.6,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CustomPaint(
                    painter: PathIconPainter(
                      icon: icon,
                      baseColor: baseColor,
                      deepColor: deepColor,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      textDirection: TextDirection.rtl,
                      style: AppFonts.kids(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
