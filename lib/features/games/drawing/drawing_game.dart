import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/app_colors.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';

/// An offline drawing activity used by the daily mission and creative map.
class DrawingGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const DrawingGame({
    super.key,
    this.stageId,
    this.stageNumber,
  });

  @override
  State<DrawingGame> createState() => _DrawingGameState();
}

class _DrawingGameState extends State<DrawingGame> {
  final List<_Stroke> _strokes = <_Stroke>[];
  final List<_Stroke> _redo = <_Stroke>[];
  Color _selectedColor = const Color(0xFFFFD166);
  double _strokeWidth = 8;
  bool _saved = false;

  static const _colors = <Color>[
    Color(0xFFE74C3C),
    Color(0xFFFFD166),
    Color(0xFF2ECC71),
    Color(0xFF3498DB),
    Color(0xFF9B59B6),
    Color(0xFF111827),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FandoghiCoach.instruction(
          'هر چیزی که دوست داری بکش! من فندقی داور خلاقیت تو هستم 🎨🌰',
        );
      }
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _startStroke(DragStartDetails details) {
    HapticFeedback.selectionClick();
    setState(() {
      _strokes.add(_Stroke(<Offset>[details.localPosition], _selectedColor, _strokeWidth));
      _redo.clear();
    });
  }

  void _continueStroke(DragUpdateDetails details) {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.last.points.add(details.localPosition);
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _redo.add(_strokes.removeLast()));
  }

  void _redoStroke() {
    if (_redo.isEmpty) return;
    setState(() => _strokes.add(_redo.removeLast()));
  }

  void _clear() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redo.addAll(_strokes);
      _strokes.clear();
    });
  }

  void _finish() {
    if (!_saved) {
      _saved = true;
      GameData.progressMission('drawing');
      GameData.addCoins(10);
      GameData.addStars(1);
      if (widget.stageId != null) {
        GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
      }
      FandoghiCoach.reward('نقاشی‌ات ثبت شد! فندقی به خلاقیتت امتیاز کامل می‌دهد 🎨🏆');
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101124),
      appBar: AppBar(
        title: Text(
          'کارگاه نقاشی 🎨',
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          tooltip: 'برگشت',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'پاک کردن',
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _toolbar(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: _startStroke,
                  onPanUpdate: _continueStroke,
                  child: CustomPaint(
                    painter: _DrawingPainter(_strokes),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _strokes.isEmpty ? null : _finish,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('تمام شد! ذخیره کن 🌟'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      child: Row(
        children: [
          ..._colors.map(
            (color) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Semantics(
                button: true,
                label: 'انتخاب رنگ',
                selected: color == _selectedColor,
                child: InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  customBorder: const CircleBorder(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: color == _selectedColor ? 36 : 30,
                    height: color == _selectedColor ? 36 : 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == _selectedColor
                            ? Colors.white
                            : Colors.white30,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'برگرداندن',
            onPressed: _strokes.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo_rounded, color: Colors.white),
          ),
          IconButton(
            tooltip: 'دوباره انجام دادن',
            onPressed: _redo.isEmpty ? null : _redoStroke,
            icon: const Icon(Icons.redo_rounded, color: Colors.white),
          ),
          PopupMenuButton<double>(
            tooltip: 'اندازه قلم',
            initialValue: _strokeWidth,
            onSelected: (value) => setState(() => _strokeWidth = value),
            icon: const Icon(Icons.line_weight_rounded, color: Colors.white),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 4, child: Text('قلم نازک')),
              PopupMenuItem(value: 8, child: Text('قلم معمولی')),
              PopupMenuItem(value: 16, child: Text('قلم پهن')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  _Stroke(this.points, this.color, this.width);
}

class _DrawingPainter extends CustomPainter {
  final List<_Stroke> strokes;

  const _DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.width / 2, paint..style = PaintingStyle.fill);
        continue;
      }
      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
