import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/learning_content/quran_data.dart';
import '../../shared/widgets/kids_world_scaffold.dart';

/// 📖 صفحهٔ یک سوره: متن عربی، معنیِ ساده، حالتِ حفظ و تکمیلِ مطالعه.
///
/// صدا فقط برای «معنیِ فارسی» استفاده می‌شود. متنِ عربی برای تمرینِ خواندن
/// با خانواده طراحی شده و برنامه ادعای پخشِ تلاوت ندارد.
class QuranSurahScreen extends StatefulWidget {
  const QuranSurahScreen({super.key, required this.surah});

  final QuranSurah surah;

  @override
  State<QuranSurahScreen> createState() => _QuranSurahScreenState();
}

class _QuranSurahScreenState extends State<QuranSurahScreen> {
  bool _hideArabic = false;
  final Set<int> _revealed = <int>{};
  bool _reading = false;
  bool _readDone = false;
  bool _markingRead = false;
  int _token = 0;

  QuranSurah get _surah => widget.surah;

  String get _doneKey => 'quran_done_${_surah.id}';

  @override
  void initState() {
    super.initState();
    _readDone = GameData.getBool(_doneKey) == true;
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        '${_surah.name}؛ با آرامش بخوان و اگر خواستی حالتِ حفظ را روشن کن 📖',
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  void dispose() {
    _token++;
    AudioService.stopSpeaking();
    FandoghiCoach.clear();
    super.dispose();
  }

  void _toggleHide(bool value) {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(() {
      _hideArabic = value;
      _revealed.clear();
    });
  }

  void _reveal(int number) {
    HapticFeedback.lightImpact();
    AudioService.tick();
    setState(() => _revealed.add(number));
  }

  void _hideOne(int number) {
    HapticFeedback.selectionClick();
    setState(() => _revealed.remove(number));
  }

  void _showAll() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    setState(() {
      _hideArabic = false;
      _revealed.clear();
    });
  }

  Future<void> _toggleReading() async {
    if (_reading) {
      _stopReading();
      return;
    }
    HapticFeedback.lightImpact();
    final token = ++_token;
    setState(() => _reading = true);
    FandoghiCoach.instruction(
      'معنیِ فارسی را می‌خوانم؛ متنِ عربی را با صدای بلند خودت بخوان 🎧',
    );
    for (final ayah in _surah.ayahs) {
      if (!mounted || token != _token) return;
      unawaited(AudioService.speak(ayah.persian));
      final ms = (1500 + ayah.persian.runes.length * 72)
          .clamp(1800, 6200)
          .toInt();
      await Future<void>.delayed(Duration(milliseconds: ms));
    }
    if (!mounted || token != _token) return;
    setState(() => _reading = false);
  }

  void _stopReading() {
    _token++;
    AudioService.stopSpeaking();
    if (mounted) setState(() => _reading = false);
  }

  void _speakAyah(QuranAyah ayah) {
    HapticFeedback.selectionClick();
    unawaited(AudioService.speak(ayah.persian));
    FandoghiCoach.say(
      'معنیِ این آیه: ${ayah.persian}',
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> _markRead() async {
    if (_readDone || _markingRead) return;
    _markingRead = true;
    await GameData.setBool(_doneKey, true);
    GameData.addStars(3);
    GameData.addXp(10);
    GameData.recordAnswer(correct: true, skill: 'quran');
    if (!mounted) return;
    setState(() => _readDone = true);
    _markingRead = false;
    AudioService.win();
    FandoghiCoach.celebrate(
      'آفرین! ${_surah.name} را خواندی. یک کارِ خوب هم یادت نرود 🌟',
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = <Color>[
      Color.lerp(_surah.themeColor, Colors.black, 0.40)!,
      _surah.themeColor,
      Color.lerp(_surah.themeColor, _surah.accentColor, 0.55)!,
    ];

    return KidsWorldScaffold(
      title: _surah.name,
      subtitle: '${_surah.meaning} • ${_surah.place}',
      emoji: '📖',
      gradient: gradient,
      headerActions: <Widget>[
        KidsWorldBadge(
          label: _readDone ? 'خوانده‌شده' : '${PersianDigits.toFa(_surah.ayahCount)} آیه',
          background: _readDone
              ? const Color(0xE67BE495)
              : const Color(0x33FFFFFF),
          foreground: _readDone ? const Color(0xFF0B3D1E) : Colors.white,
        ),
      ],
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        children: <Widget>[
          _SurahHeaderCard(surah: _surah),
          const SizedBox(height: 10),
          if (_surah.startsWithBismillah) ...<Widget>[
            _BismillahCard(accent: _surah.accentColor),
            const SizedBox(height: 10),
          ],
          KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            color: const Color(0xFFF4F9F8),
            borderColor: _surah.accentColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text('👁️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'حالتِ حفظ',
                            style: AppFonts.kids(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: IslandWorldPalette.ink,
                            ),
                          ),
                          Text(
                            'متنِ عربی پنهان می‌شود؛ روی هر آیه بزن تا ببینی.',
                            style: AppFonts.vazirmatn(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: IslandWorldPalette.mutedInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _hideArabic,
                      onChanged: _toggleHide,
                      activeColor: const Color(0xFF0B4A48),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: KidsWorldButton(
                        label: _reading ? 'توقفِ معنی' : 'خواندنِ معنی',
                        emoji: _reading ? '⏹️' : '🎧',
                        color: _reading
                            ? const Color(0xFFFFE0E0)
                            : const Color(0xFFD4AF37),
                        textColor: _reading
                            ? const Color(0xFF8E0000)
                            : const Color(0xFF3B2A00),
                        onPressed: _toggleReading,
                      ),
                    ),
                    if (_hideArabic) ...<Widget>[
                      const SizedBox(width: 8),
                      Expanded(
                        child: KidsWorldButton(
                          label: 'همه را نشان بده',
                          emoji: '👀',
                          color: const Color(0xFFCDE7FF),
                          textColor: const Color(0xFF00325B),
                          onPressed: _showAll,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'دکمهٔ معنی فقط ترجمهٔ فارسی را می‌خواند؛ تلاوتِ قرآن نیست.',
                  style: AppFonts.vazirmatn(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: IslandWorldPalette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          const KidsWorldSectionTitle(
            title: 'آیه‌ها',
            emoji: '🕌',
          ),
          for (final ayah in _surah.ayahs) ...<Widget>[
            _AyahCard(
              ayah: ayah,
              hidden: _hideArabic && !_revealed.contains(ayah.number),
              hideMode: _hideArabic,
              onReveal: () => _reveal(ayah.number),
              onHide: () => _hideOne(ayah.number),
              onSpeak: () => _speakAyah(ayah),
            ),
            const SizedBox(height: 9),
          ],
          KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            color: const Color(0xFFFFFCF0),
            borderColor: const Color(0xFFD4AF37),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text('💛', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'پیامِ سوره',
                        style: AppFonts.kids(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: IslandWorldPalette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _surah.kidMessage,
                  style: AppFonts.vazirmatn(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.7,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                const SizedBox(height: 10),
                KidsWorldButton(
                  label: _readDone ? 'خواندم ✓' : 'خواندم و یاد گرفتم',
                  emoji: _readDone ? '🌟' : '✅',
                  color: _readDone
                      ? const Color(0xFFC8E6C9)
                      : const Color(0xFFD4AF37),
                  textColor: const Color(0xFF3B2A00),
                  onPressed: _readDone ? null : _markRead,
                ),
              ],
            ),
          ),
          const KidsWorldOfflineNote(
            text: 'این سوره داخل برنامه است؛ بدون اینترنت بخوان و بیاموز.',
          ),
          const KidsWorldBottomSpacer(),
        ],
      ),
    );
  }
}

class _SurahHeaderCard extends StatelessWidget {
  const _SurahHeaderCard({required this.surah});

  final QuranSurah surah;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      color: const Color(0xFF073B3A),
      borderColor: const Color(0xFFD4AF37),
      child: Row(
        children: <Widget>[
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Colors.white.withOpacity(0.95),
                  surah.accentColor,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: Center(
              child: Text(
                PersianDigits.toFa(surah.number),
                style: AppFonts.kids(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: surah.themeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  surah.name,
                  style: AppFonts.kids(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF5E6B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${surah.meaning} • ${surah.place}',
                  style: AppFonts.vazirmatn(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  surah.kidMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.78),
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

class _BismillahCard extends StatelessWidget {
  const _BismillahCard({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF0B4A48), Color(0xFF06282B)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.6),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            QuranData.bismillah,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: AppFonts.quran(fontSize: 24, height: 1.9, color: accent),
          ),
          const SizedBox(height: 3),
          Text(
            'به نامِ خداوندِ بخشندهٔ مهربان',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.76),
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.ayah,
    required this.hidden,
    required this.hideMode,
    required this.onReveal,
    required this.onHide,
    required this.onSpeak,
  });

  final QuranAyah ayah;
  final bool hidden;
  final bool hideMode;
  final VoidCallback onReveal;
  final VoidCallback onHide;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
      color: const Color(0xFFFFFDF6),
      borderColor: const Color(0xFFE4D3A1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0B4A48),
                ),
                child: Center(
                  child: Text(
                    PersianDigits.toFa(ayah.number),
                    style: AppFonts.vazirmatn(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF5E6B8),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (hideMode && !hidden)
                IconButton(
                  tooltip: 'دوباره پنهان کن',
                  visualDensity: VisualDensity.compact,
                  onPressed: onHide,
                  icon: const Icon(Icons.visibility_off_rounded, size: 19),
                  color: IslandWorldPalette.mutedInk,
                ),
              if (!hidden)
                IconButton(
                  tooltip: 'شنیدنِ معنی',
                  visualDensity: VisualDensity.compact,
                  onPressed: onSpeak,
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  color: const Color(0xFF0B4A48),
                ),
            ],
          ),
          if (hidden)
            Semantics(
              button: true,
              label: 'نمایشِ آیهٔ ${PersianDigits.toFa(ayah.number)}',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onReveal,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6F4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFB2D8D0),
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      const Text('🫣', style: TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        'این آیه پنهان است؛ برای دیدن لمس کن',
                        style: AppFonts.vazirmatn(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: IslandWorldPalette.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
              child: Text(
                ayah.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppFonts.quran(
                  fontSize: 22,
                  height: 2.0,
                  color: const Color(0xFF16302F),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ayah.persian,
                textAlign: TextAlign.right,
                style: AppFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.7,
                  color: IslandWorldPalette.ink,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
