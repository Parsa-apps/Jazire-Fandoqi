import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_world_style.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/science/science_experiments.dart';
import '../../../shared/widgets/kids_world_scaffold.dart';
import 'experiment_common.dart';

/// 🌈 آزمایشِ ترکیبِ نور — قرمز، سبز و آبی سه رنگِ اصلیِ نور هستند.
class LightMixExperiment extends StatefulWidget {
  const LightMixExperiment({
    super.key,
    required this.experiment,
    this.onCompleted,
  });

  final ScienceExperiment experiment;
  final VoidCallback? onCompleted;

  @override
  State<LightMixExperiment> createState() => _LightMixExperimentState();
}

class _LightMixExperimentState extends State<LightMixExperiment> {
  final Set<String> _active = <String>{};

  bool _reported = false;

  void _reportComplete() {
    if (_reported) return;
    _reported = true;
    widget.onCompleted?.call();
  }

  static const List<String> _order = <String>['red', 'green', 'blue'];

  static const Map<String, Color> _colors = <String, Color>{
    'red': Color(0xFFFF5252),
    'green': Color(0xFF69F0AE),
    'blue': Color(0xFF448AFF),
  };

  static const Map<String, String> _names = <String, String>{
    'red': 'قرمز',
    'green': 'سبز',
    'blue': 'آبی',
  };

  Color get _result {
    if (_active.isEmpty) return const Color(0xFFE0E0E0);
    if (_active.length == 1) return _colors[_active.first]!;
    if (_active.length == 2) {
      if (_active.contains('red') && _active.contains('green')) {
        return const Color(0xFFFFEB3B);
      }
      if (_active.contains('green') && _active.contains('blue')) {
        return const Color(0xFF18FFFF);
      }
      return const Color(0xFFE040FB);
    }
    return Colors.white;
  }

  String get _resultName {
    if (_active.isEmpty) return 'یک رنگ انتخاب کن';
    if (_active.length == 1) return _names[_active.first]!;
    if (_active.length == 2) {
      if (_active.contains('red') && _active.contains('green')) {
        return 'زرد';
      }
      if (_active.contains('green') && _active.contains('blue')) {
        return 'فیروزه‌ای';
      }
      return 'ارغوانی';
    }
    return 'سفید';
  }

  void _toggle(String key) {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(() {
      if (_active.contains(key)) {
        _active.remove(key);
      } else {
        _active.add(key);
      }
    });
    if (_active.length >= 2) {
      if (_active.length >= 3) _reportComplete();
      FandoghiCoach.correct('ترکیبِ نورها «$_resultName» شد! رنگ‌های نور با '
          'هم دوست هستند 🌈');
    } else {
      FandoghiCoach.instruction(
        '${_names[key]} را ${_active.contains(key) ? 'روشن' : 'خاموش'} کردی. '
        'یک رنگِ دیگر هم اضافه کن.',
      );
    }
  }

  void _reset() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(_active.clear);
  }

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('🌈', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'کارگاهِ نور',
                  style: AppFonts.kids(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
              ),
              ExperimentResetIcon(onTap: _reset),
            ],
          ),
          const SizedBox(height: 8),
          ExperimentStage(
            colors: const <Color>[
              Color(0xFF1A1033),
              Color(0xFF241447),
              Color(0xFF3A1B5C),
            ],
            height: 250,
            child: Stack(
              children: <Widget>[
                for (var i = 0; i < _order.length; i++)
                  Align(
                    alignment: Alignment(-0.75 + i * 0.75, -0.72),
                    child: _LightSwitch(
                      color: _colors[_order[i]]!,
                      label: _names[_order[i]]!,
                      on: _active.contains(_order[i]),
                      onTap: () => _toggle(_order[i]),
                    ),
                  ),
                Align(
                  alignment: const Alignment(0, 0.12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _result,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.85),
                        width: 2.4,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: _result.withOpacity(0.6),
                          blurRadius: 26,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.12),
                  child: Text(
                    _resultName,
                    style: AppFonts.kids(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _result.computeLuminance() > 0.55
                          ? const Color(0xFF3B2A00)
                          : Colors.white,
                      shadows: const <Shadow>[
                        Shadow(color: Color(0x88000000), blurRadius: 5),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.83),
                  child: Container(
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Color(0xFFFF5252),
                          Color(0xFFFFEB3B),
                          Color(0xFF69F0AE),
                          Color(0xFF18FFFF),
                          Color(0xFF448AFF),
                          Color(0xFFE040FB),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              for (var i = 0; i < _order.length; i++) ...<Widget>[
                Expanded(
                  child: _LightButton(
                    label: _names[_order[i]]!,
                    color: _colors[_order[i]]!,
                    active: _active.contains(_order[i]),
                    onTap: () => _toggle(_order[i]),
                  ),
                ),
                if (i < _order.length - 1) const SizedBox(width: 7),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ExperimentCaption(
            emoji: '💡',
            text: _active.length >= 3
                ? 'قرمز + سبز + آبی = نورِ سفید! هر سه رنگِ نور با هم '
                    'روشن باشند، چشم ما سفیدی می‌بیند.'
                : _active.length == 2
                    ? '${_names[_order.firstWhere(_active.contains)]} + '
                        '${_names[_order.lastWhere(_active.contains)]} = '
                        '$_resultName. یک رنگِ دیگر هم اضافه کن!'
                    : 'دو رنگ را با هم روشن کن و نتیجه را ببین. '
                        'نورِ رنگی با رنگِ گواش فرق دارد!',
          ),
        ],
      ),
    );
  }
}

class _LightSwitch extends StatelessWidget {
  const _LightSwitch({
    required this.color,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: on,
      label: 'نورِ $label',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: on ? 50 : 40,
              height: on ? 50 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: Colors.white.withOpacity(on ? 0.95 : 0.45),
                  width: 2,
                ),
                boxShadow: on
                    ? <BoxShadow>[
                        BoxShadow(
                          color: color.withOpacity(0.8),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppFonts.vazirmatn(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LightButton extends StatelessWidget {
  const _LightButton({
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: 'ترکیبِ $label',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.22) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? color : const Color(0xFFE0E0E0),
              width: active ? 2 : 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
