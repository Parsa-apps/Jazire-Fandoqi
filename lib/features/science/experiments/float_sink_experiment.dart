import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_world_style.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/science/science_experiments.dart';
import '../../../shared/widgets/kids_world_scaffold.dart';
import 'experiment_common.dart';

class _WaterObject {
  final String id;
  final String label;
  final String emoji;
  final bool floats;

  const _WaterObject(this.id, this.label, this.emoji, this.floats);
}

const List<_WaterObject> _objects = <_WaterObject>[
  _WaterObject('wood', 'چوب', '🪵', true),
  _WaterObject('leaf', 'برگ', '🍃', true),
  _WaterObject('stone', 'سنگ', '🪨', false),
];

/// 💧 آزمایشِ شنا/غرق — سه چیزِ بی‌خطر را در آب می‌اندازیم.
class FloatSinkExperiment extends StatefulWidget {
  const FloatSinkExperiment({
    super.key,
    required this.experiment,
    this.onCompleted,
  });

  final ScienceExperiment experiment;
  final VoidCallback? onCompleted;

  @override
  State<FloatSinkExperiment> createState() => _FloatSinkExperimentState();
}

class _FloatSinkExperimentState extends State<FloatSinkExperiment> {
  final Map<String, bool> _status = <String, bool>{};
  String? _lastId;

  bool _reported = false;

  void _reportComplete() {
    if (_reported) return;
    _reported = true;
    widget.onCompleted?.call();
  }

  void _test(_WaterObject object) {
    HapticFeedback.lightImpact();
    AudioService.bubble();
    setState(() {
      _status[object.id] = object.floats;
      _lastId = object.id;
    });
    FandoghiCoach.instruction(
      object.floats
          ? '${object.label} سبک‌تر از آب است و روی آب می‌ماند.'
          : '${object.label} سنگین‌تر از آب است و به پایین می‌رود.',
    );
    if (_status.length == _objects.length) _reportComplete();
  }

  void _reset() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(() {
      _status.clear();
      _lastId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allTested = _status.length == _objects.length;
    final last = _lastId == null
        ? null
        : _objects.firstWhere((object) => object.id == _lastId);

    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('💧', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'حوضچهٔ آزمایش',
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
              Color(0xFFE1F5FE),
              Color(0xFF81D4FA),
              Color(0xFF0277BD),
            ],
            height: 240,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                return Stack(
                  children: <Widget>[
                    Positioned(
                      top: height * 0.28,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.white.withOpacity(0.35),
                              const Color(0xFF29B6F6).withOpacity(0.55),
                              const Color(0xFF01579B).withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: height * 0.27,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 8,
                      child: Text(
                        'آب',
                        style: AppFonts.vazirmatn(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF01579B).withOpacity(0.8),
                        ),
                      ),
                    ),
                    for (var i = 0; i < _objects.length; i++)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 750),
                        curve: Curves.easeOutBack,
                        left: width * (0.18 + i * 0.32) - 26,
                        top: _status.containsKey(_objects[i].id)
                            ? (_status[_objects[i].id]!
                                ? height * 0.31
                                : height * 0.76)
                            : height * 0.035,
                        child: _WaterToken(
                          object: _objects[i],
                          state: _status[_objects[i].id],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final object in _objects)
                _TestButton(
                  object: object,
                  tested: _status.containsKey(object.id),
                  onTap: () => _test(object),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ExperimentCaption(
            emoji: allTested ? '🎉' : '💡',
            text: allTested
                ? 'همه را امتحان کردی! چوب و برگ روی آب ماندند و سنگ رفت '
                    'پایین. چوب و برگ از آب سبک‌ترند.'
                : last == null
                    ? 'یکی از چیزها را در آب بینداز و ببین چه می‌شود.'
                    : _status[last.id]!
                        ? '${last.label} روی آب شنا می‌کند؛ چون از آب سبک‌تر است.'
                        : '${last.label} به پایین می‌رود؛ چون از آب سنگین‌تر است.',
          ),
        ],
      ),
    );
  }
}

class _WaterToken extends StatelessWidget {
  const _WaterToken({required this.object, required this.state});

  final _WaterObject object;
  final bool? state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(object.emoji, style: const TextStyle(fontSize: 36)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            object.label,
            style: AppFonts.vazirmatn(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: IslandWorldPalette.ink,
            ),
          ),
        ),
        if (state != null)
          Container(
            margin: const EdgeInsets.only(top: 1),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: state!
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              state! ? 'شنا می‌کند' : 'غرق شد',
              style: AppFonts.vazirmatn(
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                color: state!
                    ? const Color(0xFF1B5E20)
                    : const Color(0xFFB71C1C),
              ),
            ),
          ),
      ],
    );
  }
}

class _TestButton extends StatelessWidget {
  const _TestButton({
    required this.object,
    required this.tested,
    required this.onTap,
  });

  final _WaterObject object;
  final bool tested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${object.label} را در آب بینداز',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: tested ? const Color(0xFFE8F5E9) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: tested
                  ? const Color(0xFF81C784)
                  : const Color(0xFFB3E5FC),
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(object.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 5),
              Text(
                object.label,
                style: AppFonts.vazirmatn(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: IslandWorldPalette.ink,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_downward_rounded,
                size: 14,
                color: tested
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF0277BD),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
