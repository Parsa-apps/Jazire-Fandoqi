import 'package:flutter/material.dart';

/// 🎨 حرفه‌ای — متن با گرادیان رنگی برای عناوین حرفه‌ای
/// قابل استفاده در پرداخت، داستان، و هر عنوان حرفه‌ای
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> gradientColors;
  final TextAlign textAlign;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradientColors = const [
      Color(0xFFFFA726),
      Color(0xFFF06292),
      Color(0xFFBA68C8),
      Color(0xFF4FC3F7),
    ],
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
