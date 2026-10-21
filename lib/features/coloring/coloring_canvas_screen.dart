import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/audio_service.dart';
import '../../core/coloring/coloring_pages.dart';
import '../../core/drawing/drawing_album.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/kids_world_scaffold.dart';
import '../games/drawing/drawing_album_screen.dart';
import 'coloring_painter.dart';

class _PaletteColor {
  final String name;
  final Color color;

  const _PaletteColor(this.name, this.color);
}

const List<_PaletteColor> _palette = <_PaletteColor>[
  _PaletteColor('قرمز', Color(0xFFE53935)),
  _PaletteColor('نارنجی', Color(0xFFFB8C00)),
  _PaletteColor('زرد', Color(0xFFFFD600)),
  _PaletteColor('سبز', Color(0xFF43A047)),
  _PaletteColor('سبزِ روشن', Color(0xFF9CCC65)),
  _PaletteColor('فیروزه‌ای', Color(0xFF00ACC1)),
  _PaletteColor('آبی', Color(0xFF1E88E5)),
  _PaletteColor('آبیِ روشن', Color(0xFF81D4FA)),
  _PaletteColor('بنفش', Color(0xFF8E24AA)),
  _PaletteColor('صورتی', Color(0xFFF06292)),
  _PaletteColor('قهوه‌ای', Color(0xFF8D6E63)),
  _PaletteColor('سیاه', Color(0xFF37474F)),
  _PaletteColor('سفید', Color(0xFFFFFFFF)),
];

class _ColorChange {
  final String regionId;
  final Color? previous;

  const _ColorChange(this.regionId, this.previous);
}

/// 🖌️ بومِ رنگ‌آمیزی
///
/// کودک ناحیه‌ها را پر می‌کند، رنگ‌ها را عوض می‌کند، اشتباه را با «برگشت»
/// درست می‌کند و در پایان نقاشی را در آلبومِ خصوصیِ برنامه ذخیره می‌کند.
class ColoringCanvasScreen extends StatefulWidget {
  const ColoringCanvasScreen({super.key, required this.page});

  final ColoringPage page;

  @override
  State<ColoringCanvasScreen> createState() => _ColoringCanvasScreenState();
}

class _ColoringCanvasScreenState extends State<ColoringCanvasScreen> {
  static const List<Color> _gradient = <Color>[
    Color(0xFF7A1E4C),
    Color(0xFFB93E6E),
    Color(0xFFEF8A8A),
  ];

  final GlobalKey _boundaryKey = GlobalKey();
  final Map<String, Color> _colors = <String, Color>{};
  final List<_ColorChange> _history = <_ColorChange>[];

  _PaletteColor _selected = _palette[1];
  String _lastRegion = 'یک قسمت از نقاشی را لمس کن.';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'اول یک رنگ انتخاب کن، بعد روی هر قسمت از نقاشی بزن 🖍️',
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _selectColor(_PaletteColor color) {
    HapticFeedback.selectionClick();
    AudioService.select();
    setState(() => _selected = color);
  }

  void _handleTap(Offset localPosition, Size size) {
    final regionId = ColoringPages.regionAt(
      widget.page,
      localPosition,
      size,
    );
    if (regionId == null) {
      setState(() => _lastRegion = 'این‌جا ناحیه‌ای برای رنگ‌کردن نیست.');
      return;
    }
    ColoringRegion? region;
    for (final item in widget.page.regions) {
      if (item.id == regionId) region = item;
    }
    if (region == null) return;
    final selectedRegion = region;

    if (_colors[selectedRegion.id] == _selected.color) {
      setState(() => _lastRegion = '${selectedRegion.label} همین رنگ را دارد.');
      return;
    }

    final previous = _colors[selectedRegion.id];
    setState(() {
      _colors[selectedRegion.id] = _selected.color;
      _history.add(_ColorChange(selectedRegion.id, previous));
      if (_history.length > 60) _history.removeAt(0);
      _lastRegion = '${selectedRegion.label} را ${_selected.name} کردی.';
    });
    HapticFeedback.lightImpact();
    AudioService.bubble();
  }

  void _undo() {
    if (_history.isEmpty) return;
    HapticFeedback.selectionClick();
    AudioService.tap();
    final change = _history.removeLast();
    setState(() {
      if (change.previous == null) {
        _colors.remove(change.regionId);
      } else {
        _colors[change.regionId] = change.previous!;
      }
      _lastRegion = 'آخرین رنگ برگشت.';
    });
  }

  void _clear() {
    if (_colors.isEmpty) return;
    HapticFeedback.mediumImpact();
    AudioService.page();
    setState(() {
      _colors.clear();
      _history.clear();
      _lastRegion = 'همهٔ رنگ‌ها پاک شد؛ دوباره شروع کنیم.';
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    Uint8List? pngBytes;
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('canvas-not-ready');
      }
      final image = await boundary.toImage(pixelRatio: 2.4);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      pngBytes = data?.buffer.asUint8List();
    } catch (_) {
      pngBytes = null;
    }

    if (!mounted) return;
    if (pngBytes == null || pngBytes.isEmpty) {
      setState(() => _saving = false);
      FandoghiCoach.say(
        'ذخیره نشد؛ یک بار دیگر امتحان کن.',
        mood: FandoghiMood.thinking,
        tone: FandoghiCoachTone.encouragement,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ذخیره نشد؛ یک بار دیگر امتحان کن.'),
        ),
      );
      return;
    }

    final record = await DrawingAlbum.savePng(pngBytes);
    if (!mounted) return;
    setState(() => _saving = false);
    if (record == null) {
      FandoghiCoach.say(
        'آلبوم الان در دسترس نیست؛ بعداً دوباره امتحان کن.',
        mood: FandoghiMood.thinking,
        tone: FandoghiCoachTone.encouragement,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('آلبوم در دسترس نیست؛ بعداً امتحان کن.')),
      );
      return;
    }

    await AudioService.success();
    final rewardKey = 'coloring_done_${widget.page.id}';
    final firstSave = GameData.getBool(rewardKey) != true;
    if (firstSave) {
      await GameData.setBool(rewardKey, true);
      GameData.addStars(2);
      GameData.addXp(5);
      GameData.progressMission('drawing');
      FandoghiCoach.celebrate(
        'نقاشیِ «${widget.page.title}» ذخیره شد و ۲ ستاره گرفتی! 🖼️',
      );
    } else {
      FandoghiCoach.celebrate(
        'نقاشیِ «${widget.page.title}» دوباره در آلبوم ذخیره شد! 🖼️',
      );
    }
    if (!mounted) return;

    final openAlbum = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('🖼️', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                Text(
                  'ذخیره شد!',
                  style: AppFonts.kids(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نقاشیِ «${widget.page.title}» در آلبومِ خصوصیِ برنامه است.',
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                    color: IslandWorldPalette.mutedInk,
                  ),
                ),
                const SizedBox(height: 14),
                KidsWorldButton(
                  label: 'دیدنِ آلبوم',
                  emoji: '📚',
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                ),
                const SizedBox(height: 8),
                KidsWorldButton(
                  label: 'ادامهٔ رنگ‌آمیزی',
                  emoji: '🎨',
                  color: const Color(0xFFFFD9E4),
                  textColor: const Color(0xFF7A1E4C),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (openAlbum == true) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const DrawingAlbumScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KidsWorldScaffold(
      title: widget.page.title,
      subtitle: widget.page.hint,
      emoji: widget.page.emoji,
      gradient: _gradient,
      headerActions: <Widget>[
        KidsWorldBadge(
          label: '${_colors.length} رنگ',
          background: const Color(0x33FFFFFF),
          foreground: Colors.white,
        ),
      ],
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        children: <Widget>[
          KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'رنگ‌ها',
                      style: AppFonts.kids(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: IslandWorldPalette.ink,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _selected.color.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _selected.color.withOpacity(0.55),
                        ),
                      ),
                      child: Text(
                        _selected.name,
                        style: AppFonts.vazirmatn(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: IslandWorldPalette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: <Widget>[
                    for (final color in _palette)
                      _ColorDot(
                        color: color,
                        selected: color.name == _selected.name,
                        onTap: () => _selectColor(color),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          KidsWorldCard(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            borderColor: widget.page.paperColor == const Color(0xFF141B3D)
                ? const Color(0xFF9FA8DA)
                : const Color(0xFFFFC2D4),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final side = math.min(constraints.maxWidth, 520.0);
                final size = Size(side, side);
                return Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (TapUpDetails details) =>
                        _handleTap(details.localPosition, size),
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: SizedBox(
                        width: side,
                        height: side,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CustomPaint(
                            painter: ColoringPainter(
                              page: widget.page,
                              colors: _colors,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.20)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.touch_app_rounded,
                  size: 18,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _lastRegion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.vazirmatn(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.88),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _CanvasToolButton(
                icon: Icons.undo_rounded,
                label: 'برگشت',
                enabled: _history.isNotEmpty,
                onTap: _undo,
              ),
              const SizedBox(width: 8),
              _CanvasToolButton(
                icon: Icons.format_color_reset_rounded,
                label: 'پاک‌کردن',
                enabled: _colors.isNotEmpty,
                onTap: _clear,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KidsWorldButton(
                  label: _saving ? 'در حال ذخیره...' : 'ذخیره در آلبوم',
                  emoji: '💾',
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          KidsWorldButton(
            label: 'صفحهٔ دیگر',
            emoji: '📄',
            color: const Color(0xFFFFE3EC),
            textColor: const Color(0xFF7A1E4C),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const KidsWorldOfflineNote(
            text: 'نقاشی در آلبومِ خودِ برنامه ذخیره می‌شود؛ '
                'هیچ فایلی به اینترنت فرستاده نمی‌شود.',
          ),
          const KidsWorldBottomSpacer(),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final _PaletteColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: color.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? const Color(0xFF3B2A00)
                  : const Color(0x22000000),
              width: selected ? 2.6 : 1,
            ),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: color.color.withOpacity(0.45),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.color,
              border: Border.all(
                color: Colors.black.withOpacity(0.10),
                width: 1,
              ),
            ),
            child: selected
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: color.name == 'سفید' || color.name == 'زرد'
                        ? const Color(0xFF3B2A00)
                        : Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _CanvasToolButton extends StatelessWidget {
  const _CanvasToolButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: Container(
            width: 58,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFC2D4), width: 1.6),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 20, color: const Color(0xFF7A1E4C)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7A1E4C),
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
