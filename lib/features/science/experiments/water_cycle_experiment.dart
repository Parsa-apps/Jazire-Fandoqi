import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_world_style.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/science/science_experiments.dart';
import '../../../shared/widgets/kids_world_scaffold.dart';
import 'experiment_common.dart';

/// ☔ چرخهٔ آب — خورشید آب را بخار می‌کند، ابر می‌سازد و باران می‌بارد.
class WaterCycleExperiment extends StatefulWidget {
  const WaterCycleExperiment({
    super.key,
    required this.experiment,
    this.onCompleted,
  });

  final ScienceExperiment experiment;
  final VoidCallback? onCompleted;

  @override
  State<WaterCycleExperiment> createState() => _WaterCycleExperimentState();
}

class _WaterCycleExperimentState extends State<WaterCycleExperiment> {
  /// ۰ = دریا، ۱ = بخار، ۲ = ابر، ۳ = باران، ۴ = دوباره دریا.
  int _step = 0;
  bool _completed = false;

  bool _reported = false;

  void _reportComplete() {
    if (_reported) return;
    _reported = true;
    widget.onCompleted?.call();
  }

  static const List<String> _stepTitles = <String>[
    'دریا گرم است',
    'آب بخار می‌شود',
    'ابر ساخته می‌شود',
    'باران می‌بارد',
    'آب برمی‌گردد',
  ];

  static const List<String> _stepHints = <String>[
    'خورشید را لمس کن تا آبِ دریا گرم شود.',
    'بخار به آسمان می‌رود؛ حالا ابر را بساز.',
    'قطره‌های ریز به هم می‌رسند و ابرِ سنگین می‌سازند.',
    'ابر پُر از آب است؛ باران را بفرست.',
    'باران به دریا و زمین برگشت. چرخهٔ آب دوباره شروع می‌شود.',
  ];

  void _advance() {
    HapticFeedback.selectionClick();
    switch (_step) {
      case 0:
        AudioService.bubble();
        break;
      case 1:
        AudioService.swoosh();
        break;
      case 2:
        AudioService.bubble();
        break;
      case 3:
        AudioService.win();
        break;
      default:
        AudioService.tap();
    }
    final next = _step >= 4 ? 0 : _step + 1;
    setState(() => _step = next);
    if (next == 4) {
      _completed = true;
      _reportComplete();
      FandoghiCoach.celebrate(
        'چرخهٔ آب کامل شد! آب از دریا به آسمان و دوباره به زمین برمی‌گردد ☔',
      );
    } else {
      FandoghiCoach.instruction(_stepHints[next]);
    }
  }

  void _reset() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(() {
      _step = 0;
      _completed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasVapor = _step >= 1;
    final hasCloud = _step >= 2;
    final raining = _step >= 3;

    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('☔', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'سفرِ یک قطره',
                  style: AppFonts.kids(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
              ),
              if (_completed) const ExperimentDoneBadge(),
              ExperimentResetIcon(onTap: _reset),
            ],
          ),
          const SizedBox(height: 8),
          ExperimentStage(
            colors: const <Color>[
              Color(0xFF81D4FA),
              Color(0xFF4FC3F7),
              Color(0xFF0277BD),
            ],
            height: 246,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 10,
                  left: 14,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 400),
                    scale: _step == 0 ? 1.15 : 0.85,
                    child: Column(
                      children: <Widget>[
                        const Text('☀️', style: TextStyle(fontSize: 34)),
                        if (_step == 0)
                          Text(
                            'خورشید',
                            style: AppFonts.vazirmatn(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF01579B),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 46,
                  left: 54,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 420),
                    opacity: hasVapor ? 1 : 0,
                    child: const _VaporTrail(),
                  ),
                ),
                Positioned(
                  top: hasCloud ? 22 : 74,
                  right: 24,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 460),
                    curve: Curves.easeOutBack,
                    scale: hasCloud ? 1 : 0.4,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 380),
                      opacity: hasCloud ? 1 : 0,
                      child: Column(
                        children: <Widget>[
                          Text(
                            hasCloud && _step >= 2 ? '☁️' : '🌥️',
                            style: TextStyle(fontSize: hasCloud ? 44 : 30),
                          ),
                          if (hasCloud)
                            Text(
                              _step >= 3 ? 'ابرِ پُر آب' : 'ابرِ سبک',
                              style: AppFonts.vazirmatn(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF01579B),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (raining)
                  Positioned(
                    top: 82,
                    right: 30,
                    child: _RainDrops(count: 7),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 62,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          const Color(0xFF29B6F6).withOpacity(0.7),
                          const Color(0xFF01579B).withOpacity(0.92),
                        ],
                      ),
                    ),
                    child: Align(
                      alignment: const Alignment(0, 0.55),
                      child: Text(
                        'دریا',
                        style: AppFonts.vazirmatn(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'مرحلهٔ ${_step + 1} از ۴',
                      style: AppFonts.vazirmatn(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: IslandWorldPalette.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5FE),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFB3E5FC)),
            ),
            child: Row(
              children: <Widget>[
                Text(_stepEmoji[_step], style: const TextStyle(fontSize: 17)),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _stepTitles[_step],
                        style: AppFonts.vazirmatn(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF01579B),
                        ),
                      ),
                      Text(
                        _stepHints[_step],
                        style: AppFonts.vazirmatn(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1.55,
                          color: IslandWorldPalette.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          _BigActionButton(
            label: _actionLabel[_step],
            emoji: _actionEmoji[_step],
            onTap: _advance,
          ),
        ],
      ),
    );
  }

  static const List<String> _stepEmoji = <String>['🌊', '💨', '☁️', '🌧️', '🌍'];
  static const List<String> _actionLabel = <String>[
    'آب را گرم کن',
    'بخار بساز',
    'ابر بساز',
    'باران بفرست',
    'دوباره شروع کن',
  ];
  static const List<String> _actionEmoji = <String>['☀️', '💨', '☁️', '🌧️', '🔁'];
}

class _VaporTrail extends StatelessWidget {
  const _VaporTrail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsetsDirectional.only(start: i * 9.0),
            child: Text(
              '〰️',
              style: TextStyle(
                fontSize: 15 - i * 3,
                color: Colors.white.withOpacity(0.9 - i * 0.2),
              ),
            ),
          ),
      ],
    );
  }
}

class _RainDrops extends StatelessWidget {
  const _RainDrops({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: count * 9.0,
      child: Wrap(
        spacing: 4,
        runSpacing: 5,
        children: <Widget>[
          for (var i = 0; i < count; i++)
            Text(
              '💧',
              style: TextStyle(fontSize: 11 - (i % 2) * 2),
            ),
        ],
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  const _BigActionButton({
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  final String label;
  final String emoji;
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF29B6F6), Color(0xFF0277BD)],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF0277BD).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 17)),
              const SizedBox(width: 7),
              Text(
                label,
                style: AppFonts.vazirmatn(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
