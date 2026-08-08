import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/app_colors.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/game_data.dart';
import '../../../core/play_limit.dart';
import '../../../shared/widgets/illustration_tile.dart';

/// An offline creative studio with brush, eraser, undo/redo and generated
/// sticker stamps. Everything is local and the canvas never leaves the device.
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

enum _DrawingTool { brush, eraser, sticker }

class _DrawingGameState extends State<DrawingGame> {
  static const String _stickerAsset =
      'assets/illustrations/drawing_stickers.webp';
  static const int _stickerCount = 8;

  final List<_Stroke> _strokes = <_Stroke>[];
  final List<_Sticker> _stickers = <_Sticker>[];
  final List<_CanvasAction> _history = <_CanvasAction>[];
  final List<_CanvasAction> _redo = <_CanvasAction>[];

  Color _selectedColor = const Color(0xFFFFD166);
  double _strokeWidth = 8;
  _DrawingTool _tool = _DrawingTool.brush;
  int _stickerIndex = 0;
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
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GameData.isDailyLimitReached) {
        FandoghiCoach.judge(
          'زمان بازی امروز تمام شده؛ فردا دوباره با هم نقاشی می‌کنیم ⏰',
        );
        showPlayLimitDialog(context).then((_) {
          if (mounted) Navigator.pop(context);
        });
        return;
      }
      FandoghiCoach.instruction(
        'هر چیزی که دوست داری بکش! قلم، پاک‌کن و استیکرهای رنگی همه دم دست تو هستند 🎨🌰',
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  bool get _hasArtwork => _strokes.isNotEmpty || _stickers.isNotEmpty;

  void _startStroke(DragStartDetails details) {
    if (_tool == _DrawingTool.sticker) return;
    HapticFeedback.selectionClick();
    final stroke = _Stroke(
      <Offset>[details.localPosition],
      _selectedColor,
      _strokeWidth,
      _tool == _DrawingTool.eraser,
    );
    setState(() {
      _strokes.add(stroke);
      _history.add(_CanvasAction.stroke(stroke));
      _redo.clear();
    });
  }

  void _continueStroke(DragUpdateDetails details) {
    if (_tool == _DrawingTool.sticker || _strokes.isEmpty) return;
    setState(() => _strokes.last.points.add(details.localPosition));
  }

  void _addSticker(TapUpDetails details) {
    if (_tool != _DrawingTool.sticker) return;
    final sticker = _Sticker(details.localPosition, _stickerIndex);
    setState(() {
      _stickers.add(sticker);
      _history.add(_CanvasAction.sticker(sticker));
      _redo.clear();
    });
    FandoghiCoach.correct('یک استیکر قشنگ اضافه شد! نقاشی‌ات دارد زنده می‌شود ✨');
  }

  void _undo() {
    if (_history.isEmpty) return;
    final action = _history.removeLast();
    setState(() {
      if (action.stroke != null) {
        _strokes.remove(action.stroke);
      } else if (action.sticker != null) {
        _stickers.remove(action.sticker);
      }
      _redo.add(action);
    });
  }

  void _redoAction() {
    if (_redo.isEmpty) return;
    final action = _redo.removeLast();
    setState(() {
      if (action.stroke != null) {
        _strokes.add(action.stroke!);
      } else if (action.sticker != null) {
        _stickers.add(action.sticker!);
      }
      _history.add(action);
    });
  }

  void _clear() {
    if (!_hasArtwork) return;
    setState(() {
      _strokes.clear();
      _stickers.clear();
      _history.clear();
      _redo.clear();
    });
    FandoghiCoach.instruction('صفحه سفید شد؛ یک ایده تازه برای نقاشی داری؟ 🌈');
  }

  void _selectTool(_DrawingTool tool) {
    setState(() => _tool = tool);
    final message = switch (tool) {
      _DrawingTool.brush => 'قلم آماده است؛ رنگت را انتخاب کن و بکش ✏️',
      _DrawingTool.eraser => 'پاک‌کن آماده است؛ هر جا خواستی اصلاح کن 🧽',
      _DrawingTool.sticker => 'یک استیکر انتخاب کن و روی نقاشی‌ات بزن ⭐',
    };
    FandoghiCoach.instruction(message);
  }

  Future<void> _finish() async {
    if (GameData.isDailyLimitReached) {
      await showPlayLimitDialog(context);
      if (mounted) Navigator.pop(context);
      return;
    }
    if (!_saved) {
      _saved = true;
      GameData.progressMission('drawing');
      GameData.addCoins(10);
      GameData.addStars(1);
      if (widget.stageId != null) {
        GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
      }
      FandoghiCoach.reward(
        'نقاشی‌ات ثبت شد! فندقی به خلاقیتت امتیاز کامل می‌دهد 🎨🏆',
      );
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
            tooltip: 'پاک کردن همه',
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
                  onTapUp: _addSticker,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(painter: _DrawingPainter(_strokes)),
                      ..._stickers.map(
                        (sticker) => Positioned(
                          left: sticker.position.dx - 30,
                          top: sticker.position.dy - 30,
                          width: 60,
                          height: 60,
                          child: IllustrationTile(
                            asset: _stickerAsset,
                            index: sticker.imageIndex,
                            semanticLabel: 'استیکر نقاشی',
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
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
                  onPressed: _hasArtwork ? _finish : null,
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
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._colors.map(_colorButton),
                const SizedBox(width: 6),
                _toolChip(Icons.edit_rounded, 'قلم', _DrawingTool.brush),
                _toolChip(Icons.auto_fix_high_rounded, 'پاک‌کن', _DrawingTool.eraser),
                _toolChip(Icons.emoji_emotions_rounded, 'استیکر', _DrawingTool.sticker),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'برگرداندن',
                  onPressed: _history.isEmpty ? null : _undo,
                  icon: const Icon(Icons.undo_rounded, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'دوباره انجام دادن',
                  onPressed: _redo.isEmpty ? null : _redoAction,
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
                if (_tool == _DrawingTool.sticker) ...[
                  const SizedBox(width: 6),
                  ...List.generate(_stickerCount, (index) => _stickerButton(index)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorButton(Color color) {
    final selected = color == _selectedColor;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Semantics(
        button: true,
        label: 'انتخاب رنگ',
        selected: selected,
        child: InkWell(
          onTap: () => setState(() {
            _selectedColor = color;
            _tool = _DrawingTool.brush;
          }),
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: selected ? 36 : 30,
            height: selected ? 36 : 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.white : Colors.white30,
                width: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolChip(IconData icon, String label, _DrawingTool tool) {
    final selected = _tool == tool;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: FilterChip(
        selected: selected,
        onSelected: (_) => _selectTool(tool),
        avatar: Icon(
          icon,
          size: 17,
          color: selected ? Colors.white : Colors.white70,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: FontWeight.w700,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white.withOpacity(0.1),
        side: BorderSide(color: Colors.white.withOpacity(0.14)),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _stickerButton(int index) {
    final selected = index == _stickerIndex;
    return GestureDetector(
      onTap: () => setState(() => _stickerIndex = index),
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsetsDirectional.only(end: 6),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected ? AppColors.warning : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.white : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        child: IllustrationTile(
          asset: _stickerAsset,
          index: index,
          semanticLabel: 'انتخاب استیکر',
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }
}

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final bool eraser;

  _Stroke(this.points, this.color, this.width, this.eraser);
}

class _Sticker {
  final Offset position;
  final int imageIndex;

  _Sticker(this.position, this.imageIndex);
}

class _CanvasAction {
  final _Stroke? stroke;
  final _Sticker? sticker;

  const _CanvasAction._({this.stroke, this.sticker});

  factory _CanvasAction.stroke(_Stroke stroke) => _CanvasAction._(stroke: stroke);
  factory _CanvasAction.sticker(_Sticker sticker) => _CanvasAction._(sticker: sticker);
}

class _DrawingPainter extends CustomPainter {
  final List<_Stroke> strokes;

  const _DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.eraser ? Colors.white : stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.width / 2,
          paint..style = PaintingStyle.fill,
        );
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
