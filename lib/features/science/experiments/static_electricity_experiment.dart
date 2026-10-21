import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../app/island_world_style.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/science/science_experiments.dart';
import '../../../shared/widgets/kids_world_scaffold.dart';
import 'experiment_common.dart';

/// ⚡ آزمایشِ الکتریسیتهٔ ساکن — بادکنکِ مالیده‌شده کاغذ را می‌کشد.
class StaticElectricityExperiment extends StatefulWidget {
  const StaticElectricityExperiment({
    super.key,
    required this.experiment,
    this.onCompleted,
  });

  final ScienceExperiment experiment;
  final VoidCallback? onCompleted;

  @override
  State<StaticElectricityExperiment> createState() =>
      _StaticElectricityExperimentState();
}

class _StaticElectricityExperimentState
    extends State<StaticElectricityExperiment> {
  /// ۰ = بدون بار، ۱ = مالیده شده، ۲ = کاغذها جذب شدند.
  int _stage = 0;
  bool _rubbing = false;

  bool _reported = false;

  void _reportComplete() {
    if (_reported) return;
    _reported = true;
    widget.onCompleted?.call();
  }

  void _rub() {
    if (_rubbing) return;
    HapticFeedback.mediumImpact();
    AudioService.page();
    setState(() => _rubbing = true);
    FandoghiCoach.instruction(
      'بادکنک را به موهایت یا به پارچهٔ پشمی بمال تا بارِ الکتریکی بگیرد.',
    );
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _rubbing = false;
        _stage = _stage == 2 ? 2 : 1;
      });
    });
  }

  void _attract() {
    if (_stage < 1) {
      HapticFeedback.heavyImpact();
      AudioService.wrong();
      FandoghiCoach.instruction(
        'اول بادکنک را بمال تا بارِ الکتریکی بگیرد؛ بعد نزدیکِ کاغذها کن.',
      );
      return;
    }
    HapticFeedback.lightImpact();
    AudioService.correct();
    setState(() => _stage = 2);
    _reportComplete();
    FandoghiCoach.celebrate(
      'کاغذها به بادکنک چسبیدند! به این نیرو، الکتریسیتهٔ ساکن می‌گوییم.',
    );
  }

  void _reset() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(() {
      _stage = 0;
      _rubbing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final charged = _stage >= 1;
    final attracted = _stage == 2;

    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('⚡', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'آزمایشِ بادکنک',
                  style: AppFonts.kids(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
              ),
              if (attracted) const ExperimentDoneBadge(),
              ExperimentResetIcon(onTap: _reset),
            ],
          ),
          const SizedBox(height: 8),
          ExperimentStage(
            colors: const <Color>[
              Color(0xFFFFF8E1),
              Color(0xFFFFE0B2),
              Color(0xFFFFB74D),
            ],
            height: 238,
            child: Stack(
              children: <Widget>[
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 620),
                  curve: Curves.easeOutBack,
                  top: attracted ? 76 : 16,
                  left: 26,
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 620),
                    turns: attracted ? 0.06 : -0.12,
                    child: Column(
                      children: <Widget>[
                        Text(
                          '🎈',
                          style: TextStyle(
                            fontSize: charged ? 52 : 46,
                          ),
                        ),
                        if (charged)
                          Text(
                            '⚡',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.amber.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 16,
                  child: SizedBox(
                    width: 150,
                    height: 96,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        for (var i = 0; i < 6; i++)
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 420 + i * 55),
                            curve: Curves.easeOut,
                            left: attracted
                                ? -44.0 - i * 2
                                : 8.0 + (i % 3) * 34,
                            top: 10.0 + (i ~/ 3) * 30,
                            child: Transform.rotate(
                              angle: (i * 0.7),
                              child: Container(
                                width: 20,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: const Color(0xFFB0BEC5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 116,
                  child: Text(
                    'کاغذهای کوچک',
                    style: AppFonts.vazirmatn(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6D4C41),
                    ),
                  ),
                ),
                if (_rubbing)
                  Positioned(
                    left: 20,
                    top: 92,
                    child: Text(
                      '💨',
                      style: TextStyle(fontSize: 26, color: Colors.brown.shade200),
                    ),
                  ),
                Positioned(
                  left: 10,
                  bottom: 8,
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
                      charged ? 'بادکنک باردار است ⚡' : 'بادکنک بی‌بار است',
                      style: AppFonts.vazirmatn(
                        fontSize: 9,
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
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionButton(
                  emoji: '🧣',
                  label: 'مالیدن بادکنک',
                  color: const Color(0xFF8E24AA),
                  onTap: _rub,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  emoji: '📄',
                  label: 'نزدیک کردن',
                  color: const Color(0xFFEF6C00),
                  onTap: _attract,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ExperimentCaption(
            emoji: attracted ? '🎉' : '⚡',
            text: attracted
                ? 'بادکنک باردار، کاغذهای سبک را به خودش کشید. مالیدنِ بادکنک '
                    'به پارچه، بارِ الکتریکی می‌سازد.'
                : charged
                    ? 'حالا بادکنک را نزدیکِ کاغذها کن و ببین چه می‌شود.'
                    : 'اول بادکنک را به مو یا پارچهٔ پشمی بمال.',
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.11),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.5), width: 1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
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
