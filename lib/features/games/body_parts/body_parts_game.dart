import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/app_colors.dart';
import '../../../app/design_tokens.dart';
import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/fandoghi_coach.dart';
import '../../../core/fandoghi_models.dart';
import '../../../core/game_data.dart';
import '../../../shared/widgets/child_touch_target.dart';
import '../../../shared/widgets/fandoghi_premium.dart';
import '../../../shared/widgets/magnetic_drag.dart';
import '../../../shared/widgets/premium_button.dart';

/// ────────────────────────────────────────────────────────────
/// 🧍 فاز ۳۹: بازی بدن و حواس
///
/// کودک اعضای بدن (چشم، گوش، دست، پا) را با کشیدن روی بدن
/// کارتونی می‌گذارد. حواس پنج‌گانه هم با کلیک روی هر عضو گفته
/// می‌شود (TTS). آهنربا + ویبره نرم برای هر عضو درست.
/// ────────────────────────────────────────────────────────────
class BodyPartsGame extends StatefulWidget {
  final String? stageId;
  final int? stageNumber;

  const BodyPartsGame({super.key, this.stageId, this.stageNumber});

  @override
  State<BodyPartsGame> createState() => _BodyPartsGameState();
}

class _BodyPartsGameState extends State<BodyPartsGame> {
  // پریمیوم: ۶ عضو + بینی و دهان (درخواست فیکس دور ۸: برچسب چشم)
  static const List<(String, String, String, String)> _parts = <(String, String, String, String)>[
    ('چشم', '👀', 'می‌بینم', 'بینایی'),
    ('گوش', '👂', 'می‌شنوم', 'شنوایی'),
    ('بینی', '👃', 'بو می‌کشم', 'بویایی'),
    ('دهان', '👄', 'مزه می‌کنم', 'چشایی'),
    ('دست', '✋', 'لمس می‌کنم', 'لامسه'),
    ('پا', '🦶', 'راه می‌روم', 'حرکت'),
  ];

  final Set<int> _placed = <int>{};
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.instruction(
        'هر عضو بدن را با انگشت بکش و سر جایش بگذار! بعد رویش بزن تا حرفش را بشنوی 🧍',
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  void _onDrop(int index, String emoji) {
    if (_placed.contains(index)) return;
    if (_parts[index].$2 != emoji) return;
    setState(() => _placed.add(index));
    HapticFeedback.lightImpact();
    FandoghiCoach.correct('${_parts[index].$1} سر جایش نشست! ${_parts[index].$3} ✨');
    unawaited(AudioService.playCorrect());
    if (_placed.length == _parts.length) {
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _finished = true);
        GameData.recordAnswer(correct: true, skill: 'body');
        GameData.addCoins(18);
        GameData.addStars(3);
        if (widget.stageId != null) {
          GameData.completeStage(widget.stageId!, stageNumber: widget.stageNumber);
        }
        unawaited(AudioService.win());
        FandoghiCoach.reward('آفرین! هر ۶ عضو سر جاشه — حالا هر ۵ حس رو می‌شناسی 👏');
      });
    }
  }

  void _saySense(int index) {
    AudioService.tap();
    unawaited(AudioService.speak('${_parts[index].$1}، ${_parts[index].$3}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.forest),
        child: SafeArea(
          child: _finished ? _buildResult() : _buildGame(),
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              ChildTouchTarget(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white30)),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('بدن من 🧍 — ۶ عضو', textAlign: TextAlign.center, style: AppFonts.vazirmatn(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.soft),
                child: Text('${_placed.length}/${_parts.length}', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF2D3436))),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF00B894).withOpacity(0.9), borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Text('+18 🪙', style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // فندقی راهنما کوچک
        const FandoghiPremium(size: 52, mood: FandoghiMood.happy, showParticles: false),
        const SizedBox(height: 8),
        // بدن پریمیوم — شبکه 3×2 با سیلوئت
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Column(
            children: [
              Text('هر عضو را بکش و بچسبان ✨', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.92),
                itemCount: _parts.length,
                itemBuilder: (context, index) => _slot(index, _parts[index].$1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('اعضای بدن را بکش و بگذار سر جایش — بعد رویش بزن تا «${_parts[0].$3}» رو بشنوی!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, height: 1.5)),
        const SizedBox(height: 12),
        // اعضای کشیدنی
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              for (var i = 0; i < _parts.length; i++)
                if (!_placed.contains(i))
                  MagneticDraggable(
                    data: _parts[i].$2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_parts[i].$2, style: const TextStyle(fontSize: 42)),
                        Text(
                          _parts[i].$1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _slot(int index, String label) {
    final filled = _placed.contains(index);
    final part = _parts[index];
    return Column(
      children: [
        DragTarget<String>(
          onWillAcceptWithDetails: (_) => !_placed.contains(index),
          onAcceptWithDetails: (details) => _onDrop(index, details.data),
          builder: (context, candidates, rejected) {
            final hovering = candidates.isNotEmpty;
            return AnimatedContainer(
              duration: AppMotion.fast,
              decoration: BoxDecoration(
                color: hovering
                    ? Colors.amber.withOpacity(0.30)
                    : filled
                        ? Colors.white
                        : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: hovering ? Colors.amber : filled ? const Color(0xFF00B894) : Colors.white30,
                  width: hovering ? 3 : filled ? 2 : 1.5,
                ),
                boxShadow: filled ? [BoxShadow(color: const Color(0xFF00B894).withOpacity(0.2), blurRadius: 8)] : null,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: filled
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(part.$2, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 2),
                          Text(part.$1, style: AppFonts.vazirmatn(color: const Color(0xFF2D3436), fontSize: 11, fontWeight: FontWeight.w800)),
                          Text(part.$3, style: TextStyle(color: const Color(0xFF00B894), fontSize: 9, fontWeight: FontWeight.w700)),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, color: Colors.white70, size: 20),
                            const SizedBox(height: 2),
                            Text(label, style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
              ),
            );
          },
        ),
        if (filled) ...[
          const SizedBox(height: 4),
          ChildTouchTarget(
            minSize: 40,
            onTap: () => _saySense(index),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                SizedBox(width: 2),
                Text(
                  'بشنو',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResult() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FandoghiPremium(size: 110, mood: FandoghiMood.celebrating, showParticles: true).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text('بدنت کامل شد! 🧍✨', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: const Icon(Icons.star_rounded, size: 28, color: Color(0xFFFFD700)).animate(delay: (i * 100).ms).scale(begin: Offset(0, 0), end: Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut))),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: Colors.white24)),
              child: Column(
                children: [
                  Text('هر ۶ عضو سر جاشه!', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('👀 بینایی  •  👂 شنوایی  •  👃 بویایی  •  👄 چشایی  •  ✋ لامسه  •  🦶 حرکت', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, height: 1.6)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadii.pill)), child: Row(children: [const Text('🪙', style: TextStyle(fontSize: 14)), const SizedBox(width: 4), Text('+18', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFFFFD700)))])),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadii.pill)), child: Row(children: [const Icon(Icons.star_rounded, size: 14, color: Colors.white), const SizedBox(width: 4), Text('+3 ⭐', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white))])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: PremiumButton(text: 'دوباره بساز 🔄', icon: Icons.replay_rounded, onPressed: () { HapticFeedback.mediumImpact(); setState(() { _placed.clear(); _finished = false; }); })),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.home_rounded, size: 18, color: Colors.white), label: Text('برگشت به خانه', style: AppFonts.vazirmatn(color: Colors.white)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Colors.white54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))))),
          ],
        ),
      ),
    );
  }
}
