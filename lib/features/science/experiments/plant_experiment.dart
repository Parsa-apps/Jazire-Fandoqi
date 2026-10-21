import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_world_style.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/science/science_experiments.dart';
import '../../../shared/widgets/kids_world_scaffold.dart';
import 'experiment_common.dart';

/// 🌱 آزمایشِ گیاه — نور و آب، دو نیازِ اصلیِ گیاه است.
class PlantExperiment extends StatefulWidget {
  const PlantExperiment({
    super.key,
    required this.experiment,
    this.onCompleted,
  });

  final ScienceExperiment experiment;
  final VoidCallback? onCompleted;

  @override
  State<PlantExperiment> createState() => _PlantExperimentState();
}

class _PlantExperimentState extends State<PlantExperiment> {
  int _water = 0;
  int _sun = 0;

  bool _reported = false;

  void _reportComplete() {
    if (_reported) return;
    _reported = true;
    widget.onCompleted?.call();
  }

  /// ۰ تا ۳: جوانه، ساقه، برگ، گل.
  int get _growth {
    final min = _water < _sun ? _water : _sun;
    return min > 3 ? 3 : min;
  }

  void _addWater() {
    HapticFeedback.selectionClick();
    AudioService.bubble();
    setState(() {
      _water = _water >= 3 ? 0 : _water + 1;
    });
    if (_growth >= 3) _reportComplete();
    _comment('آب');
  }

  void _addSun() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(() {
      _sun = _sun >= 3 ? 0 : _sun + 1;
    });
    if (_growth >= 3) _reportComplete();
    _comment('نور');
  }

  void _comment(String what) {
    if (_water > 0 && _sun > 0 && _growth >= 3) {
      FandoghiCoach.celebrate(
        'گیاهت گل داد! آب و نورِ کافی، رازِ رشدِ گیاه است 🌸',
      );
    } else if (_water > 0 && _sun > 0) {
      FandoghiCoach.instruction('کم‌کم بزرگ می‌شود؛ آب و نور را برابر نگه دار.');
    } else {
      FandoghiCoach.instruction(
        '$what را زیاد کردی. حالا $whatِ دیگر را هم اضافه کن تا گیاه رشد کند.',
      );
    }
  }

  void _reset() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(() {
      _water = 0;
      _sun = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final growth = _growth;
    final grown = growth >= 3;

    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('🌱', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'باغچهٔ کوچک',
                  style: AppFonts.kids(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
              ),
              if (grown) const ExperimentDoneBadge(),
              ExperimentResetIcon(onTap: _reset),
            ],
          ),
          const SizedBox(height: 8),
          ExperimentStage(
            colors: <Color>[
              _sun >= 2
                  ? const Color(0xFFB3E5FC)
                  : const Color(0xFFCFE8F3),
              _sun >= 2
                  ? const Color(0xFFE1F5FE)
                  : const Color(0xFFE3F2FD),
              const Color(0xFFA1887F),
            ],
            height: 236,
            borderColor: const Color(0xFFBCAAA4),
            child: Stack(
              children: <Widget>[
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  top: 10,
                  left: _sun >= 2 ? 18 : 8,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _sun == 0 ? 0.45 : 1,
                    child: Text(
                      _sun >= 2 ? '☀️' : '🌤️',
                      style: TextStyle(fontSize: _sun >= 2 ? 34 : 27),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          const Color(0xFF8D6E63).withOpacity(0.55),
                          const Color(0xFF5D4037).withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.62),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    transitionBuilder: (Widget child, Animation<double> anim) {
                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.6, end: 1).animate(
                          CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                        ),
                        child: child,
                      );
                    },
                    child: Text(
                      _stages[growth],
                      key: ValueKey<int>(growth),
                      style: TextStyle(fontSize: _stageSize[growth]),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _MeterRow(
                    icon: '💧',
                    filled: _water,
                    color: const Color(0xFF0288D1),
                  ),
                ),
                Positioned(
                  top: 42,
                  right: 12,
                  child: _MeterRow(
                    icon: '☀️',
                    filled: _sun,
                    color: const Color(0xFFF9A825),
                  ),
                ),
                if (grown)
                  const Align(
                    alignment: Alignment(-0.55, -0.55),
                    child: Text('✨', style: TextStyle(fontSize: 20)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              Expanded(
                child: _GrowButton(
                  emoji: '💧',
                  label: 'آب بده',
                  color: const Color(0xFF0288D1),
                  onTap: _addWater,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GrowButton(
                  emoji: '☀️',
                  label: 'نور بده',
                  color: const Color(0xFFF9A825),
                  onTap: _addSun,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ExperimentCaption(
            emoji: grown ? '🌸' : '🌱',
            text: grown
                ? 'آب و نور با هم گیاه را بزرگ کردند. اگر یکی از آن‌ها کم '
                    'باشد، گیاه پژمرده می‌شود.'
                : _water == 0
                    ? 'به گیاه آب بده تا شروع به رشد کند.'
                    : _sun == 0
                        ? 'گیاه آب دارد؛ حالا به آن نور بده.'
                        : 'کم‌کم رشد می‌کند! آب و نور را برابر نگه دار.',
          ),
        ],
      ),
    );
  }

  static const List<String> _stages = <String>['🌰', '🌱', '🌿', '🌷'];
  static const List<double> _stageSize = <double>[26, 42, 60, 74];
}

class _MeterRow extends StatelessWidget {
  const _MeterRow({
    required this.icon,
    required this.filled,
    required this.color,
  });

  final String icon;
  final int filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(icon, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 3),
        for (var i = 0; i < 3; i++)
          Container(
            width: 11,
            height: 6,
            margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              color: i < filled ? color : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}

class _GrowButton extends StatelessWidget {
  const _GrowButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.55), width: 1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 17)),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
