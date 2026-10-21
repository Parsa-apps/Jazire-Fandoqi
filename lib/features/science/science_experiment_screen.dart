import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/science/science_experiments.dart';
import '../../shared/widgets/kids_world_scaffold.dart';
import 'experiments/float_sink_experiment.dart';
import 'experiments/light_mix_experiment.dart';
import 'experiments/magnet_experiment.dart';
import 'experiments/plant_experiment.dart';
import 'experiments/static_electricity_experiment.dart';
import 'experiments/water_cycle_experiment.dart';

/// 🔬 صفحهٔ یک آزمایش: سؤال، نمایشِ تعاملی، «چرا؟» و فعالیتِ خانه.
class ScienceExperimentScreen extends StatefulWidget {
  const ScienceExperimentScreen({super.key, required this.experiment});

  final ScienceExperiment experiment;

  @override
  State<ScienceExperimentScreen> createState() =>
      _ScienceExperimentScreenState();
}

class _ScienceExperimentScreenState extends State<ScienceExperimentScreen> {
  bool _done = false;
  bool _justEarned = false;

  String get _doneKey => 'science_done_${widget.experiment.id}';

  @override
  void initState() {
    super.initState();
    _done = GameData.getBool(_doneKey) == true;
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        widget.experiment.bigQuestion,
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _onCompleted() {
    if (!mounted) return;
    final firstTime = !_done;
    HapticFeedback.mediumImpact();
    unawaited(AudioService.win());
    if (firstTime) {
      GameData.addStars(3);
      GameData.addXp(8);
      GameData.recordAnswer(correct: true, skill: 'science');
      unawaited(GameData.setBool(_doneKey, true));
    }
    setState(() {
      _done = true;
      _justEarned = firstTime;
    });
    FandoghiCoach.celebrate(
      firstTime
          ? 'آفرین دانشمند کوچک! آزمایش را کامل کردی و ۳ ستاره گرفتی ⭐'
          : 'دوباره هم آزمایش کردی؛ تمرین، بهترین معلم است 🔬',
    );
  }

  void _readAloud(String text) {
    HapticFeedback.selectionClick();
    AudioService.tap();
    unawaited(AudioService.speak(text));
  }

  @override
  Widget build(BuildContext context) {
    final experiment = widget.experiment;
    final gradient = <Color>[
      Color.lerp(experiment.themeColor, Colors.black, 0.55)!,
      experiment.themeColor,
      experiment.accentColor,
    ];

    return KidsWorldScaffold(
      title: experiment.title,
      subtitle: experiment.subtitle,
      emoji: experiment.emoji,
      gradient: gradient,
      headerActions: <Widget>[
        if (_done)
          const KidsWorldBadge(
            label: '✓ انجام شد',
            background: Color(0x33FFFFFF),
            foreground: Colors.white,
          ),
      ],
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        children: <Widget>[
          _QuestionCard(experiment: experiment),
          const SizedBox(height: 12),
          _buildDemo(experiment),
          const SizedBox(height: 12),
          _RewardCard(done: _done, justEarned: _justEarned),
          const SizedBox(height: 12),
          _InfoCard(
            emoji: '💡',
            title: 'چرا این اتفاق می‌افتد؟',
            body: experiment.explanation,
            color: const Color(0xFFFFF8E1),
            borderColor: const Color(0xFFFFE082),
            onSpeak: () => _readAloud(experiment.explanation),
          ),
          const SizedBox(height: 10),
          _InfoCard(
            emoji: '🏠',
            title: 'در خانه هم امتحان کن',
            body: experiment.homeActivity,
            color: const Color(0xFFE8F5E9),
            borderColor: const Color(0xFFA5D6A7),
            onSpeak: () => _readAloud(experiment.homeActivity),
          ),
          const SizedBox(height: 10),
          _SafetyCard(text: experiment.safetyTip),
          const KidsWorldOfflineNote(
            text: 'این آزمایش فقط نمایشی است و به وسیلهٔ خطرناک نیاز ندارد.',
          ),
          const KidsWorldBottomSpacer(),
        ],
      ),
    );
  }

  Widget _buildDemo(ScienceExperiment experiment) {
    switch (experiment.kind) {
      case ScienceKind.floatSink:
        return FloatSinkExperiment(
          experiment: experiment,
          onCompleted: _onCompleted,
        );
      case ScienceKind.magnet:
        return MagnetExperiment(
          experiment: experiment,
          onCompleted: _onCompleted,
        );
      case ScienceKind.lightMix:
        return LightMixExperiment(
          experiment: experiment,
          onCompleted: _onCompleted,
        );
      case ScienceKind.plant:
        return PlantExperiment(
          experiment: experiment,
          onCompleted: _onCompleted,
        );
      case ScienceKind.staticElectricity:
        return StaticElectricityExperiment(
          experiment: experiment,
          onCompleted: _onCompleted,
        );
      case ScienceKind.waterCycle:
        return WaterCycleExperiment(
          experiment: experiment,
          onCompleted: _onCompleted,
        );
    }
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.experiment});

  final ScienceExperiment experiment;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[experiment.accentColor, experiment.themeColor],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                experiment.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'سؤالِ امروز',
                  style: AppFonts.vazirmatn(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: experiment.themeColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  experiment.bigQuestion,
                  style: AppFonts.kids(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.6,
                    color: IslandWorldPalette.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.done, required this.justEarned});

  final bool done;
  final bool justEarned;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: done
                ? const <Color>[Color(0xFFFFF8E1), Color(0xFFFFECB3)]
                : const <Color>[Color(0xFFF5F7F8), Color(0xFFECEFF1)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: done ? const Color(0xFFFFD54F) : const Color(0xFFCFD8DC),
            width: 1.4,
          ),
        ),
        child: Row(
          children: <Widget>[
            Text(
              done ? (justEarned ? '🎉' : '🏅') : '⭐',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    done ? 'آزمایش انجام شد!' : 'جایزهٔ تو منتظر است',
                    style: AppFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: IslandWorldPalette.ink,
                    ),
                  ),
                  Text(
                    done
                        ? (justEarned
                            ? '۳ ستاره و ۸ امتیازِ یادگیری گرفتی.'
                            : 'این آزمایش را قبلاً کامل کرده بودی؛ باز هم تمرین کردی!')
                        : 'آزمایش را کامل کن تا ۳ ستاره بگیری.',
                    style: AppFonts.vazirmatn(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: IslandWorldPalette.mutedInk,
                    ),
                  ),
                ],
              ),
            ),
            if (done)
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Color(0xFFFFB300),
                  ),
                  Text(
                    PersianDigits.toFa(3),
                    style: AppFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF8A6D00),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
    required this.borderColor,
    required this.onSpeak,
  });

  final String emoji;
  final String title;
  final String body;
  final Color color;
  final Color borderColor;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      color: color,
      borderColor: borderColor,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 19)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.kids(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'خواندن با صدا',
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up_rounded),
                color: IslandWorldPalette.mutedInk,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            body,
            style: AppFonts.vazirmatn(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.75,
              color: IslandWorldPalette.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFCC80), width: 1.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('🛡️', style: TextStyle(fontSize: 21)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'برای امنیتِ تو',
                  style: AppFonts.vazirmatn(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF8A4B00),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: AppFonts.vazirmatn(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    height: 1.65,
                    color: const Color(0xFF6D4C41),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
