import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import '../../app/design_tokens.dart';
import '../../app/app_fonts.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/fandoghi_premium.dart';

/// ═══════════════════════════════════════════════════════════════
/// 💛 SEL HUB PREMIUM — پیشنهاد ۲۷ و ۲۸
/// هوش هیجانی: ۸ احساس + قصه اجتماعی + تمرین نفس عمیق
/// با FandoghiPremium و انیمیشن تنفس 4-7-8
/// ═══════════════════════════════════════════════════════════════
class SelHubScreen extends StatefulWidget {
  const SelHubScreen({super.key});
  @override
  State<SelHubScreen> createState() => _SelHubState();
}

class _SelHubState extends State<SelHubScreen> with TickerProviderStateMixin {
  String? _selectedEmotion;
  late final AnimationController _breathCtrl;
  bool _breathing = false;
  int _breathPhase = 0; // 0: دم, 1: نگه‌دار, 2: بازدم

  static const List<_Emotion> _emotions = [
    _Emotion(id: 'happy', name: 'شادی', emoji: '😄', color: Color(0xFFFFD700), story: 'فندقی امروز خیلی خوشحاله چون با تو بازی کرده! وقتی شادی، لبخند بزن و بگو «من شادم!»', tip: 'شادی‌ات را با یک بغل به مامان یا بابا قسمت کن 🤗'),
    _Emotion(id: 'sad', name: 'ناراحتی', emoji: '😢', color: Color(0xFF74B9FF), story: 'فندقی گاهی ناراحت می‌شود، مثل وقتی اسباب‌بازی‌اش گم شد. او گریه کرد و بعد با مامان حرف زد.', tip: 'وقتی ناراحتی، گریه اشکالی ندارد. بعد با یک بزرگتر حرف بزن 💧'),
    _Emotion(id: 'angry', name: 'خشم', emoji: '😠', color: Color(0xFFFF6B6B), story: 'فندقی عصبانی شد چون برجش خراب شد. او نفس عمیق کشید و دوباره ساخت.', tip: 'وقتی عصبانی هستی، ۳ نفس عمیق بکش و بشمار ۱ تا ۵ 🧘'),
    _Emotion(id: 'fear', name: 'ترس', emoji: '😨', color: Color(0xFF6C5CE7), story: 'فندقی از تاریکی می‌ترسید. او چراغ کوچکش را روشن کرد و مامان کنارش ماند.', tip: 'ترس طبیعی است. یک چراغ کوچک یا عروسک کمکت می‌کند 🌙'),
    _Emotion(id: 'surprise', name: 'تعجب', emoji: '😮', color: Color(0xFFFF8E53), story: 'فندقی جعبه‌ای باز کرد و یک ستاره درخشان دید! چشمانش گرد شد.', tip: 'تعجب یعنی چیز جدید یاد گرفتی — بپرس «چرا؟» 🤔'),
    _Emotion(id: 'tired', name: 'خستگی', emoji: '😪', color: Color(0xFF636E72), story: 'فندقی خیلی بازی کرد و خسته شد. او چشم‌هایش را بست و ۵ دقیقه استراحت کرد.', tip: 'وقتی خسته‌ای، آب بخور و کمی دراز بکش 😴'),
    _Emotion(id: 'love', name: 'عشق', emoji: '🥰', color: Color(0xFFFF6B9E), story: 'فندقی مامانش را بغل کرد و گفت «دوستت دارم». قلبش گرم شد.', tip: 'عشقت را با «دوستت دارم» و یک نقاشی نشان بده 💌'),
    _Emotion(id: 'calm', name: 'آرامش', emoji: '😌', color: Color(0xFF00B894), story: 'فندقی روی چمن نشست، چشم‌هایش را بست و به صدای پرنده‌ها گوش داد.', tip: 'آرامش را با نفس عمیق و گوش دادن به صدای طبیعت پیدا کن 🌿'),
  ];

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000));
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FandoghiCoach.say('به دنیای احساسات خوش اومدی! هر احساس یه رنگ داره — بزن روش تا قصه‌اش رو بشنوی 💛', mood: FandoghiMood.happy, duration: const Duration(seconds: 4));
    });
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    FandoghiCoach.clear();
    super.dispose();
  }

  void _selectEmotion(_Emotion e) {
    HapticFeedback.selectionClick();
    setState(() => _selectedEmotion = e.id);
    FandoghiCoach.say(e.story, mood: e.id == 'sad' || e.id == 'angry' || e.id == 'fear' ? FandoghiMood.shy : FandoghiMood.happy, duration: const Duration(seconds: 5));
    GameData.recordAnswer(correct: true, skill: 'emotions');
  }

  void _startBreathing() {
    HapticFeedback.mediumImpact();
    setState(() {
      _breathing = true;
      _breathPhase = 0;
    });
    _runBreathCycle();
  }

  Future<void> _runBreathCycle() async {
    // چرخه 4-7-8: دم 4ث، نگه 2ث (ساده‌شده برای کودک)، بازدم 4ث — 3 دور
    for (var cycle = 0; cycle < 3; cycle++) {
      if (!mounted || !_breathing) return;
      setState(() => _breathPhase = 0);
      _breathCtrl.forward(from: 0);
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted || !_breathing) return;
      setState(() => _breathPhase = 1);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_breathing) return;
      setState(() => _breathPhase = 2);
      _breathCtrl.reverse();
      await Future.delayed(const Duration(seconds: 4));
    }
    if (mounted) {
      setState(() {
        _breathing = false;
        _breathPhase = 0;
      });
      HapticFeedback.lightImpact();
      FandoghiCoach.celebrate('آفرین! حالا آروم‌تر شدی؟ نفس عمیق همیشه کمکت می‌کند 🌿');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedEmotion == null ? null : _emotions.firstWhere((e) => e.id == _selectedEmotion);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2), Color(0xFFFFCCBC)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 14),
                      _buildEmotionGrid(),
                      if (selected != null) ...[
                        const SizedBox(height: 16),
                        _buildDetailCard(selected),
                      ],
                      const SizedBox(height: 16),
                      _buildBreathingCard(),
                      const SizedBox(height: 12),
                      _buildTipCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white), boxShadow: AppShadows.soft),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6D4C41), size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('دنیای احساسات 💛', style: AppFonts.vazirmatn(color: const Color(0xFF4E342E), fontSize: 18, fontWeight: FontWeight.w900))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.soft),
            child: Row(children: [const Text('🧠', style: TextStyle(fontSize: 14)), const SizedBox(width: 4), Text('SEL', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF6D4C41)))]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)]),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          const FandoghiPremium(size: 64, mood: FandoghiMood.happy, showParticles: false),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('هر احساسی مهم است!', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('شادی، ناراحتی، خشم... همه طبیعی‌اند. یاد بگیر بشناسی و آرام شوی.', style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 12, height: 1.6, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _buildEmotionGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.88),
      itemCount: _emotions.length,
      itemBuilder: (context, index) {
        final e = _emotions[index];
        final selected = _selectedEmotion == e.id;
        return GestureDetector(
          onTap: () => _selectEmotion(e),
          child: AnimatedContainer(
            duration: AppMotion.fast,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: selected ? e.color : Colors.white.withOpacity(0.6), width: selected ? 3 : 1.5),
              boxShadow: selected ? AppShadows.colored(e.color, opacity: 0.25) : AppShadows.soft,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(e.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Text(e.name, style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w900, color: selected ? e.color : const Color(0xFF4E342E))),
                if (selected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: e.color),
                  ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
              ],
            ),
          ).animate(delay: (index * 60).ms).fadeIn(duration: 350.ms).scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
        );
      },
    );
  }

  Widget _buildDetailCard(_Emotion e) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.xl), border: Border.all(color: e.color.withOpacity(0.25), width: 1.5), boxShadow: AppShadows.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: e.color.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadii.md)),
                child: Text(e.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              Text(e.name, style: AppFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w900, color: e.color)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: e.color.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Text('قصه فندقی', style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w800, color: e.color)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(e.story, style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w600, height: 1.7, color: const Color(0xFF3E2723))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: e.color.withOpacity(0.08), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: e.color.withOpacity(0.15))),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Text(e.tip, style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w700, height: 1.5, color: const Color(0xFF4E342E)))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildBreathingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: const Color(0xFF00B894).withOpacity(0.2)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF00B894).withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadii.md)),
                child: const Icon(Icons.air_rounded, color: Color(0xFF00B894), size: 18),
              ),
              const SizedBox(width: 10),
              Text('تمرین نفس عمیق 🌿', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFF00695C))),
              const Spacer(),
              if (_breathing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF00B894), borderRadius: BorderRadius.circular(AppRadii.pill)),
                  child: Text(_breathPhase == 0 ? 'دم...' : _breathPhase == 1 ? 'نگه‌دار...' : 'بازدم...', style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _breathCtrl,
            builder: (context, _) {
              final scale = 0.85 + (_breathCtrl.value * 0.3);
              final color = _breathPhase == 0 ? const Color(0xFF00B894) : _breathPhase == 1 ? const Color(0xFFFFD700) : const Color(0xFF74B9FF);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [color.withOpacity(0.25), color.withOpacity(0.08)]),
                    border: Border.all(color: color.withOpacity(0.4), width: 3),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 20)],
                  ),
                  child: Center(
                    child: Text(_breathing ? (_breathPhase == 0 ? '🌬️' : _breathPhase == 1 ? '⏸️' : '😮‍💨') : '🌿', style: const TextStyle(fontSize: 42)),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _breathing ? (_breathPhase == 0 ? 'از بینی نفس بکش...' : _breathPhase == 1 ? 'نگه دار...' : 'از دهان بیرون بده...') : 'وقتی ناراحت یا عصبانی هستی، این دکمه را بزن و با فندقی نفس بکش',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w600, height: 1.5, color: const Color(0xFF4E342E)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _breathing
                  ? () => setState(() {
                        _breathing = false;
                        _breathCtrl.stop();
                      })
                  : _startBreathing,
              icon: Icon(_breathing ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 20),
              label: Text(_breathing ? 'توقف' : 'شروع تمرین ۳ دور 🌬️', style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 15)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(AppRadii.xl), border: Border.all(color: const Color(0xFFFFCC80))),
      child: Row(
        children: [
          const Text('👨‍👩‍👧', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('برای والدین', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFFE65100))),
                const SizedBox(height: 2),
                Text('هر روز یک احساس را با کودک حرف بزنید: «امروز کی عصبانی شدی؟ چی کمکت کرد آروم شی؟» این گفتگو هوش هیجانی را ۲ برابر می‌کند.', style: TextStyle(fontSize: 12, height: 1.6, color: const Color(0xFF4E342E), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Emotion {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final String story;
  final String tip;
  const _Emotion({required this.id, required this.name, required this.emoji, required this.color, required this.story, required this.tip});
}
