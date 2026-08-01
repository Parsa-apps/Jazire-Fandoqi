import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension FloatExtension on Animate {
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
}
