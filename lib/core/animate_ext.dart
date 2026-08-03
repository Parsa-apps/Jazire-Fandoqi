import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension FloatExtension on Animate {
  // افکت انیمیشن شناور سه‌بعدی
  Animate float({
    Duration? duration,
    double? begin,
    double? end,
    Curve? curve,
  }) {
    return move(
      duration: duration,
      begin: Offset(0, begin ?? -3),
      end: Offset(0, end ?? 3),
      curve: curve ?? Curves.easeInOut,
    );
  }

  // افکت انیمیشن خاموش و روشن شدن تدریجی زنده
  Animate fadeInOut({
    Duration? duration,
    Curve? curve,
  }) {
    final d = duration ?? const Duration(milliseconds: 1500);
    return custom(
      duration: d,
      curve: curve ?? Curves.easeInOut,
      builder: (context, value, child) {
        final opacity = value < 0.5 ? value * 2 : (1.0 - value) * 2;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: child,
        );
      },
    );
  }
}
