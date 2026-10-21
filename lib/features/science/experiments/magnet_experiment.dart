import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_world_style.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/science/science_experiments.dart';
import '../../../shared/widgets/kids_world_scaffold.dart';
import 'experiment_common.dart';

class _MagnetItem {
  final String id;
  final String label;
  final String emoji;
  final bool magnetic;

  const _MagnetItem(this.id, this.label, this.emoji, this.magnetic);
}

const List<_MagnetItem> _items = <_MagnetItem>[
  _MagnetItem('nail', 'میخ آهنی', '🔩', true),
  _MagnetItem('clip', 'گیره', '📎', true),
  _MagnetItem('paper', 'کاغذ', '📄', false),
  _MagnetItem('coin', 'سکه', '🪙', false),
];

/// 🧲 آزمایشِ آهنربا — فقط چیزهای آهنی جذب می‌شوند.
class MagnetExperiment extends StatefulWidget {
  const MagnetExperiment({
    super.key,
    required this.experiment,
    this.onCompleted,
  });

  final ScienceExperiment experiment;
  final VoidCallback? onCompleted;

  @override
  State<MagnetExperiment> createState() => _MagnetExperimentState();
}

class _MagnetExperimentState extends State<MagnetExperiment> {
  final Map<String, bool> _tested = <String, bool>{};
  String? _selectedId;
  bool _attracted = false;

  bool _reported = false;

  void _reportComplete() {
    if (_reported) return;
    _reported = true;
    widget.onCompleted?.call();
  }

  _MagnetItem? get _selected {
    for (final item in _items) {
      if (item.id == _selectedId) return item;
    }
    return null;
  }

  void _test(_MagnetItem item) {
    HapticFeedback.selectionClick();
    if (item.magnetic) {
      AudioService.coin();
      FandoghiCoach.instruction(
        '${item.label} جذب شد! آهنربا چیزهای آهنی را به خودش می‌کشد.',
      );
    } else {
      AudioService.tap();
      FandoghiCoach.instruction(
        '${item.label} جذب نشد؛ چون آهنی نیست. آهنربا فقط آهن را می‌کشد.',
      );
    }
    setState(() {
      _tested[item.id] = item.magnetic;
      _selectedId = item.id;
      _attracted = false;
    });
    if (_tested.length == _items.length) _reportComplete();
    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (mounted && _selectedId == item.id && item.magnetic) {
        setState(() => _attracted = true);
      }
    });
  }

  void _reset() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(() {
      _tested.clear();
      _selectedId = null;
      _attracted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final allTested = _tested.length == _items.length;
    final magneticCount = _tested.values.where((value) => value).length;

    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('🧲', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'میدانِ آهنربا',
                  style: AppFonts.kids(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
              ),
              if (allTested) const ExperimentDoneBadge(),
              ExperimentResetIcon(onTap: _reset),
            ],
          ),
          const SizedBox(height: 8),
          ExperimentStage(
            colors: const <Color>[
              Color(0xFFF3E5F5),
              Color(0xFFD1C4E9),
              Color(0xFF7E57C2),
            ],
            height: 232,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: const Alignment(0, -0.68),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.55),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xFF4527A0).withOpacity(0.35),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🧲', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'آهنربا',
                        style: AppFonts.vazirmatn(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF311B92),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 720),
                  curve: Curves.easeOutBack,
                  alignment:
                      _attracted ? const Alignment(0, -0.32) : const Alignment(0, 0.74),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    scale: selected == null ? 0.65 : 1,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.86),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selected == null
                              ? Colors.transparent
                              : _attracted
                                  ? const Color(0xFF43A047)
                                  : const Color(0xFF8E24AA),
                          width: 2.2,
                        ),
                      ),
                      child: Center(
                        child: selected == null
                            ? Text(
                                'یک چیز انتخاب کن',
                                textAlign: TextAlign.center,
                                style: AppFonts.vazirmatn(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF5E35B1),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    selected.emoji,
                                    style: const TextStyle(fontSize: 38),
                                  ),
                                  Text(
                                    selected.label,
                                    style: AppFonts.vazirmatn(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: IslandWorldPalette.ink,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                if (selected != null && !selected.magnetic)
                  Align(
                    alignment: const Alignment(0.62, 0.22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: Text(
                        'جذب نمی‌شود',
                        style: AppFonts.vazirmatn(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF8A4B00),
                        ),
                      ),
                    ),
                  ),
                if (_attracted)
                  const Align(
                    alignment: Alignment(0.48, -0.52),
                    child: Text('✨', style: TextStyle(fontSize: 22)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              for (final item in _items)
                _MagnetChip(
                  item: item,
                  tested: _tested.containsKey(item.id),
                  onTap: () => _test(item),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ExperimentCaption(
            emoji: allTested ? '🎉' : '🧪',
            text: allTested
                ? 'از چهار چیز، $magneticCount مورد جذب شدند. میخ و گیره آهنی '
                    'بودند؛ کاغذ و سکهٔ معمولی نه.'
                : 'روی هر چیز بزن تا ببینی آهنربا آن را جذب می‌کند یا نه.',
          ),
        ],
      ),
    );
  }
}

class _MagnetChip extends StatelessWidget {
  const _MagnetChip({
    required this.item,
    required this.tested,
    required this.onTap,
  });

  final _MagnetItem item;
  final bool tested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${item.label} را آزمایش کن',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: tested ? const Color(0xFFF3E5F5) : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: tested
                  ? const Color(0xFF9575CD)
                  : const Color(0xFFD1C4E9),
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(item.emoji, style: const TextStyle(fontSize: 17)),
              const SizedBox(width: 4),
              Text(
                item.label,
                style: AppFonts.vazirmatn(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: IslandWorldPalette.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
