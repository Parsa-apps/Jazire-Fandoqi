import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/music/music_data.dart';
import '../../shared/widgets/kids_world_scaffold.dart';

/// 🥁 بازیِ «ریتم را تکرار کن»
///
/// فندقی یک الگوی کوتاه از ضربه‌ها را می‌نوازد؛ کودک باید همان الگو را
/// تکرار کند. هر دور یک ضربه بلندتر می‌شود. این بازی حافظهٔ شنیداری،
/// توجه و هماهنگیِ دست را تمرین می‌دهد و هیچ شکستِ تنبیهی ندارد: خطا فقط
/// یعنی «دوباره گوش کن».
class RhythmEchoGame extends StatefulWidget {
  const RhythmEchoGame({super.key});

  @override
  State<RhythmEchoGame> createState() => _RhythmEchoGameState();
}

class _RhythmEchoGameState extends State<RhythmEchoGame> {
  final Random _random = Random();

  int _round = 0; // ۰..۴
  int _bestRound = 0;
  List<int> _sequence = <int>[];
  bool _playing = false;
  bool _waiting = false;
  bool _completed = false;
  bool _completionRewarded = false;
  int _inputIndex = 0;
  int _flashPad = -1;
  int _pressedPad = -1;
  String _feedback = 'دکمهٔ «گوش کن» را بزن تا فندقی ریتم را بنوازد.';
  int _runToken = 0;

  static const int _maxRound = 5;

  @override
  void dispose() {
    _runToken++;
    FandoghiCoach.clear();
    super.dispose();
  }

  void _setFeedback(String value) {
    if (mounted) setState(() => _feedback = value);
  }

  Future<void> _startRound() async {
    if (_playing) return;
    _runToken++;
    final token = _runToken;
    final length = 3 + _round;

    final sequence = <int>[];
    for (var i = 0; i < length; i++) {
      // تکرارِ سه‌بارهٔ یک صدا در پشتِ سرِ هم برای کودک گمراه‌کننده است.
      int next = _random.nextInt(PercussionPads.all.length);
      var guard = 0;
      while (i >= 2 && next == sequence[i - 1] && next == sequence[i - 2] &&
          guard < 12) {
        next = _random.nextInt(PercussionPads.all.length);
        guard++;
      }
      sequence.add(next);
    }

    setState(() {
      _sequence = sequence;
      _inputIndex = 0;
      _waiting = false;
      _completed = false;
      _playing = true;
      _feedback = 'گوش کن...';
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));
    for (var i = 0; i < sequence.length; i++) {
      if (!mounted || token != _runToken) return;
      final padIndex = sequence[i];
      setState(() {
        _flashPad = padIndex;
        _inputIndex = i;
      });
      unawaited(AudioService.playStudioAsset(
        PercussionPads.all[padIndex].asset,
        volume: PercussionPads.all[padIndex].volume,
      ));
      HapticFeedback.selectionClick();
      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (!mounted || token != _runToken) return;
      setState(() => _flashPad = -1);
      await Future<void>.delayed(const Duration(milliseconds: 130));
    }

    if (!mounted || token != _runToken) return;
    setState(() {
      _playing = false;
      _waiting = true;
      _inputIndex = 0;
      _feedback = 'حالا نوبتِ توست: ${PersianDigits.toFa(sequence.length)} ضربه';
    });
  }

  Future<void> _tapPad(int index) async {
    final token = _runToken;
    unawaited(AudioService.playStudioAsset(
      PercussionPads.all[index].asset,
      volume: PercussionPads.all[index].volume,
    ));
    HapticFeedback.lightImpact();
    setState(() => _pressedPad = index);
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (mounted && _pressedPad == index) {
        setState(() => _pressedPad = -1);
      }
    });

    if (!_waiting || _playing) return;

    if (index != _sequence[_inputIndex]) {
      setState(() {
        _waiting = false;
        _feedback = 'نزدیک بود! یک بار دیگر گوش کن.';
      });
      FandoghiCoach.instruction('اشکالی ندارد؛ دوباره گوش کن و با من بزن 🥁');
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted || token != _runToken) return;
      await _startRound();
      return;
    }

    final next = _inputIndex + 1;
    if (next < _sequence.length) {
      setState(() {
        _inputIndex = next;
        _feedback = 'آفرین! ${PersianDigits.toFa(next)} از '
            '${PersianDigits.toFa(_sequence.length)}';
      });
      return;
    }

    // دور کامل شد.
    final finishedRound = _round + 1;
    final isNewBest = finishedRound > _bestRound;
    final best = isNewBest ? finishedRound : _bestRound;
    if (finishedRound >= _maxRound) {
      setState(() {
        _round = finishedRound;
        _bestRound = best;
        _waiting = false;
        _completed = true;
        _feedback = 'همهٔ پنج دور را زدی! تو یک نوازندهٔ کوچک هستی 🌟';
      });
      AudioService.win();
      if (!_completionRewarded) {
        _completionRewarded = true;
        GameData.addStars(3);
        GameData.addXp(12);
        GameData.recordAnswer(correct: true, skill: 'music');
        FandoghiCoach.celebrate(
          'پنج دور ریتم را کامل زدی و ۳ ستاره گرفتی! گوشِ تو خیلی تیز است 🎉',
        );
      } else {
        FandoghiCoach.celebrate('دوباره همهٔ دورها را زدی؛ تمرین عالی بود 🎉');
      }
      return;
    }

    setState(() {
      _round = finishedRound;
      _bestRound = best;
      _waiting = false;
      _feedback = 'دورِ ${PersianDigits.toFa(finishedRound)} تمام شد! '
          'حالا یک ضربهٔ بیشتر...';
    });
    AudioService.correct();
    // امتیاز فقط برای «رکوردِ تازه» است تا تکرارِ دورهای قبلی، XP را
    // بی‌نهایت بالا نبرد؛ خودِ تمرین همیشه آزاد است.
    if (isNewBest) GameData.addXp(4);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted || token != _runToken || _completed) return;
    await _startRound();
  }

  void _restart() {
    _runToken++;
    setState(() {
      _round = 0;
      _sequence = <int>[];
      _playing = false;
      _waiting = false;
      _completed = false;
      _inputIndex = 0;
      _flashPad = -1;
      _feedback = 'دکمهٔ «گوش کن» را بزن تا فندقی ریتم را بنوازد.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pads = PercussionPads.all;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        KidsWorldCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text('🥁', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ریتم را تکرار کن',
                      style: AppFonts.kids(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: IslandWorldPalette.ink,
                      ),
                    ),
                  ),
                  KidsWorldBadge(
                    label: 'دورِ ${PersianDigits.toFa(_round.clamp(0, _maxRound))}'
                        ' از ${PersianDigits.toFa(_maxRound)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _feedback,
                style: AppFonts.vazirmatn(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  color: IslandWorldPalette.mutedInk,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  for (var i = 0; i < _maxRound; i++) ...<Widget>[
                    _RoundDot(
                      done: i < _round,
                      current: i == _round && !_completed,
                    ),
                    if (i < _maxRound - 1) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: KidsWorldButton(
                      label: _completed ? 'بازیِ دوباره' : 'گوش کن',
                      emoji: _completed ? '🔄' : '👂',
                      onPressed: _playing
                          ? null
                          : (_completed ? _restart : _startRound),
                    ),
                  ),
                  if (_sequence.isNotEmpty && !_completed) ...<Widget>[
                    const SizedBox(width: 8),
                    Expanded(
                      child: KidsWorldButton(
                        label: 'تکرارِ الگو',
                        emoji: '🔁',
                        color: const Color(0xFFFFE08A),
                        onPressed: _playing ? null : _startRound,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (var i = 0; i < _sequence.length; i++) ...<Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: _sequence.length > 8 ? 11 : 14,
                  height: _sequence.length > 8 ? 11 : 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _inputIndex && _waiting
                        ? pads[_sequence[i]].color
                        : Colors.white.withOpacity(0.34),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.65),
                      width: 1.4,
                    ),
                  ),
                ),
                if (i < _sequence.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pads.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 88,
          ),
          itemBuilder: (BuildContext context, int index) {
            final pad = pads[index];
            final active = _flashPad == index || _pressedPad == index;
            return Semantics(
              button: true,
              label: pad.label,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _tapPad(index),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 90),
                  scale: active ? 0.94 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color.lerp(pad.color, Colors.white, 0.22)!,
                          pad.color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: active
                            ? Colors.white
                            : Colors.white.withOpacity(0.55),
                        width: active ? 3 : 1.5,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: pad.color.withOpacity(0.45),
                          blurRadius: active ? 16 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(pad.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 2),
                        Text(
                          pad.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.kids(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          'بهترین دورِ تو: ${PersianDigits.toFa(_bestRound)} از '
          '${PersianDigits.toFa(_maxRound)}',
          textAlign: TextAlign.center,
          style: AppFonts.vazirmatn(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.72),
          ),
        ),
      ],
    );
  }
}

class _RoundDot extends StatelessWidget {
  const _RoundDot({required this.done, required this.current});

  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: current ? 30 : 18,
      height: 8,
      decoration: BoxDecoration(
        color: done
            ? const Color(0xFF7BE495)
            : current
                ? const Color(0xFFFFD166)
                : Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
