import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📊 SKILL RADAR CHART — پیشنهاد پریمیوم شماره ۴۲
/// نمودار راداری ۸ مهارت + پیش‌بینی ماه آینده
/// ═══════════════════════════════════════════════════════════════
class SkillRadarChart extends StatelessWidget {
  final Map<String, int> skills; // skill -> 0..100
  final double size;
  const SkillRadarChart({super.key, required this.skills, this.size = 220});

  static const List<String> order = ['الفبا', 'اعداد', 'رنگ‌ها', 'شکل‌ها', 'حیوانات', 'حافظه', 'ریاضی', 'هنر'];
  static const Map<String, String> emoji = {
    'الفبا': '🔤',
    'اعداد': '🔢',
    'رنگ‌ها': '🎨',
    'شکل‌ها': '🔷',
    'حیوانات': '🦁',
    'حافظه': '🧠',
    'ریاضی': '🧮',
    'هنر': '🎨',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final values = order.map((k) => (skills[k] ?? 0).clamp(0, 100).toDouble() / 100).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE8E8E8)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadii.sm)),
                child: const Icon(Icons.radar_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('نقشه مهارت‌ها', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1F3A5F)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF00B894).withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Text('پیش‌بینی +${_prediction(values)}٪ تا ماه بعد', style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF00B894))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RadarPainter(values: values, isDark: isDark),
              child: Stack(
                children: List.generate(order.length, (i) {
                  final angle = (2 * pi * i / order.length) - pi / 2;
                  final r = size * 0.48;
                  final dx = cos(angle) * r;
                  final dy = sin(angle) * r;
                  return Positioned(
                    left: size / 2 + dx - 18,
                    top: size / 2 + dy - 18,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D2D3D) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _skillColor(values[i]).withOpacity(0.3)),
                        boxShadow: [BoxShadow(color: _skillColor(values[i]).withOpacity(0.2), blurRadius: 6)],
                      ),
                      child: Center(child: Text(emoji[order[i]] ?? '⭐', style: const TextStyle(fontSize: 16))),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // لیست مهارت‌ها با نوار
          ...List.generate(order.length, (i) {
            final label = order[i];
            final v = values[i];
            final pct = (v * 100).round();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 70, child: Text('${emoji[label]} $label', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : const Color(0xFF2D3436)))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: isDark ? Colors.white12 : const Color(0xFFF1F3F8), valueColor: AlwaysStoppedAnimation<Color>(_skillColor(v))),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: 36, child: Text('$pct٪', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w900, color: _skillColor(v)))),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: AppColors.primary.withOpacity(0.15))),
            child: Row(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('پیشنهاد فندقی', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      const SizedBox(height: 2),
                      Text(_coachSuggestion(values), style: TextStyle(fontSize: 12, height: 1.6, color: isDark ? Colors.white70 : const Color(0xFF2D3436))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _prediction(List<double> values) {
    final avg = values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
    // اگر روزانه 10 دقیقه تمرین کند، 15٪ رشد
    return (15 * (1 - avg)).round().clamp(5, 18);
  }

  String _coachSuggestion(List<double> values) {
    var minIdx = 0;
    var minVal = values[0];
    for (var i = 1; i < values.length; i++) {
      if (values[i] < minVal) {
        minVal = values[i];
        minIdx = i;
      }
    }
    final weak = order[minIdx];
    if (minVal < 0.3) return 'مهارت «$weak» نیاز به تمرین بیشتری دارد؛ بازی‌های $weak را بیشتر امتحان کن تا ماه بعد بدرخشی!';
    if (minVal < 0.6) return '«$weak» خوبه ولی می‌تونه عالی بشه؛ روزی یک بازی $weak کافیه!';
    return 'عالیه! در همه مهارت‌ها قوی هستی؛ حالا چالش‌های سخت‌تر را امتحان کن 🚀';
  }

  Color _skillColor(double v) {
    if (v >= 0.75) return const Color(0xFF00B894);
    if (v >= 0.5) return const Color(0xFF0984E3);
    if (v >= 0.3) return const Color(0xFFFDCB6E);
    return const Color(0xFFFF7675);
  }
}

class _RadarPainter extends CustomPainter {
  final List<double> values;
  final bool isDark;
  const _RadarPainter({required this.values, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.38;
    final n = values.length;

    // حلقه‌های پس‌زمینه
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white12 : const Color(0xFFE8E8E8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var r = 1; r <= 4; r++) {
      final path = Path();
      for (var i = 0; i < n; i++) {
        final angle = (2 * pi * i / n) - pi / 2;
        final rr = radius * r / 4;
        final p = Offset(center.dx + cos(angle) * rr, center.dy + sin(angle) * rr);
        if (i == 0) path.moveTo(p.dx, p.dy);
        else path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // خطوط شعاعی
    for (var i = 0; i < n; i++) {
      final angle = (2 * pi * i / n) - pi / 2;
      final p = Offset(center.dx + cos(angle) * radius, center.dy + sin(angle) * radius);
      canvas.drawLine(center, p, gridPaint);
    }

    // چندضلعی مهارت
    final skillPath = Path();
    for (var i = 0; i < n; i++) {
      final angle = (2 * pi * i / n) - pi / 2;
      final rr = radius * values[i];
      final p = Offset(center.dx + cos(angle) * rr, center.dy + sin(angle) * rr);
      if (i == 0) skillPath.moveTo(p.dx, p.dy);
      else skillPath.lineTo(p.dx, p.dy);
    }
    skillPath.close();

    final fillPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.22)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(skillPath, fillPaint);
    canvas.drawPath(skillPath, strokePaint);

    // نقطه‌ها
    final dotPaint = Paint()..color = AppColors.primary;
    final dotBorder = Paint()..color = Colors.white;
    for (var i = 0; i < n; i++) {
      final angle = (2 * pi * i / n) - pi / 2;
      final rr = radius * values[i];
      final p = Offset(center.dx + cos(angle) * rr, center.dy + sin(angle) * rr);
      canvas.drawCircle(p, 5, dotBorder);
      canvas.drawCircle(p, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => oldDelegate.values != values || oldDelegate.isDark != isDark;
}
