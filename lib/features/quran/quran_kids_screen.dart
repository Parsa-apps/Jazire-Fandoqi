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
import 'quran_surah_screen.dart';

/// 🕌 قرآنِ کودک — سوره‌های کوتاه با معنیِ ساده و حالتِ حفظ
///
/// این بخش عمداً کامل رایگان است و هیچ درِ پرداختی ندارد. صوتِ تلاوت در
/// بسته نیست؛ به‌جای آن معنیِ فارسی با TTS خوانده می‌شود و کودک متنِ عربی
/// را با کمکِ یک بزرگ‌تر تمرین می‌کند. این کار از پخشِ تلاوتِ ناقص یا
/// نامعتبر جلوگیری می‌کند.
class QuranKidsScreen extends StatefulWidget {
  const QuranKidsScreen({super.key});

  @override
  State<QuranKidsScreen> createState() => _QuranKidsScreenState();
}

class _QuranKidsScreenState extends State<QuranKidsScreen> {
  static const List<Color> _gradient = <Color>[
    Color(0xFF06282B),
    Color(0xFF0B4A48),
    Color(0xFF14746A),
  ];

  bool _opening = false;

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'به بخش قرآن خوش آمدی. با آرامش و صدای مهربان، یک سورهٔ کوتاه '
        'با هم بخوانیم 🕌',
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  void dispose() {
    FandoghiCoach.clear();
    super.dispose();
  }

  bool _isRead(QuranSurah surah) =>
      GameData.getBool('quran_done_${surah.id}') == true;

  Future<void> _openSurah(QuranSurah surah) async {
    if (_opening) return;
    _opening = true;
    HapticFeedback.selectionClick();
    AudioService.page();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/quran/${surah.id}'),
        builder: (_) => QuranSurahScreen(surah: surah),
      ),
    );
    _opening = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final surahs = QuranData.all;
    final today = QuranData.surahOfTheDay();
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 760 ? 4 : (width >= 520 ? 3 : 2);

    return KidsWorldScaffold(
      title: 'قرآنِ کودک',
      subtitle: 'سوره‌های کوتاه، معنیِ ساده و آرامش',
      emoji: '🕌',
      gradient: _gradient,
      headerActions: const <Widget>[
        KidsWorldBadge(
          label: 'کامل رایگان',
          background: Color(0xE67BE495),
          foreground: Color(0xFF0B3D1E),
        ),
      ],
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        children: <Widget>[
          _QuranIntroCard(surahCount: surahs.length),
          const SizedBox(height: 10),
          _SurahOfDayCard(
            surah: today,
            read: _isRead(today),
            onTap: () => _openSurah(today),
          ),
          const SizedBox(height: 10),
          const _EtiquetteCard(),
          const KidsWorldSectionTitle(
            title: 'سوره‌ها',
            emoji: '📖',
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: surahs.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 154,
            ),
            itemBuilder: (BuildContext context, int index) {
              final surah = surahs[index];
              return _SurahCard(
                surah: surah,
                read: _isRead(surah),
                onTap: () => _openSurah(surah),
              );
            },
          ),
          const SizedBox(height: 10),
          KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            color: const Color(0xFFFFF8E6),
            borderColor: const Color(0xFFD4AF37),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'برای شنیدنِ تلاوت، از یک بزرگ‌تر بخواه با تو بخواند. '
                    'دکمهٔ «معنی» فقط ترجمهٔ فارسی را می‌خواند و جای '
                    'تلاوتِ قرآن را نمی‌گیرد.',
                    style: AppFonts.vazirmatn(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.65,
                      color: IslandWorldPalette.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const KidsWorldOfflineNote(
            text: 'متن و معنی داخل برنامه است؛ همه‌چیز بدون اینترنت کار می‌کند.',
          ),
          const KidsWorldBottomSpacer(),
        ],
      ),
    );
  }
}

class _QuranIntroCard extends StatelessWidget {
  const _QuranIntroCard({required this.surahCount});

  final int surahCount;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      color: const Color(0xFF073B3A),
      borderColor: const Color(0xFFD4AF37),
      child: Row(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFF5E6B8), Color(0xFFD4AF37)],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text('📖', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'قرآن، کتابِ مهربانی',
                  style: AppFonts.kids(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF5E6B8),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${PersianDigits.toFa(surahCount)} سورهٔ کوتاه با معنیِ ساده '
                  'برای خواندن با خانواده.',
                  style: AppFonts.vazirmatn(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                    color: Colors.white.withOpacity(0.86),
                  ),
                ),
                const SizedBox(height: 5),
                const KidsWorldBadge(
                  label: 'بدون قفل • بدون تبلیغ',
                  background: Color(0xFF0B4A48),
                  foreground: Color(0xFFF5E6B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahOfDayCard extends StatelessWidget {
  const _SurahOfDayCard({
    required this.surah,
    required this.read,
    required this.onTap,
  });

  final QuranSurah surah;
  final bool read;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      color: const Color(0xFFFFFCF0),
      borderColor: const Color(0xFFD4AF37),
      onTap: onTap,
      semanticLabel: 'سورهٔ امروز: ${surah.name}',
      child: Row(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: surah.accentColor.withOpacity(0.28),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: surah.accentColor, width: 1.5),
            ),
            child: Center(
              child: Text(
                PersianDigits.toFa(surah.number),
                style: AppFonts.kids(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: surah.themeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text(
                      'سورهٔ امروز',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92700A),
                      ),
                    ),
                    if (read) ...<Widget>[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Color(0xFF2E7D32),
                      ),
                    ],
                  ],
                ),
                Text(
                  surah.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.kids(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                Text(
                  '${surah.meaning} • ${PersianDigits.toFa(surah.ayahCount)} آیه',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: IslandWorldPalette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.menu_book_rounded,
            size: 30,
            color: Color(0xFFB8860B),
          ),
        ],
      ),
    );
  }
}

class _EtiquetteCard extends StatelessWidget {
  const _EtiquetteCard();

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      color: const Color(0xFFF1F8E9),
      borderColor: const Color(0xFFA5D6A7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('🌿', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(
                'آدابِ خواندن',
                style: AppFonts.kids(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: IslandWorldPalette.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final item in QuranData.etiquette)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.spa_rounded,
                    size: 15,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: AppFonts.vazirmatn(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: IslandWorldPalette.ink,
                      ),
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

class _SurahCard extends StatelessWidget {
  const _SurahCard({
    required this.surah,
    required this.read,
    required this.onTap,
  });

  final QuranSurah surah;
  final bool read;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      semanticLabel: '${surah.name}، ${surah.meaning}',
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: surah.accentColor.withOpacity(0.26),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: surah.accentColor.withOpacity(0.85),
                  ),
                ),
                child: Center(
                  child: Text(
                    PersianDigits.toFa(surah.number),
                    style: AppFonts.kids(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: surah.themeColor,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (read)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: Color(0xFF2E7D32),
                )
              else
                const Icon(
                  Icons.menu_book_rounded,
                  size: 17,
                  color: Color(0xFFB8860B),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            surah.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.kids(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: IslandWorldPalette.ink,
            ),
          ),
          Text(
            surah.meaning,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.vazirmatn(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: IslandWorldPalette.mutedInk,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              surah.kidMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.vazirmatn(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                height: 1.55,
                color: IslandWorldPalette.mutedInk,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Text(
                '${PersianDigits.toFa(surah.ayahCount)} آیه',
                style: AppFonts.vazirmatn(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: surah.themeColor,
                ),
              ),
              const Spacer(),
              Text(
                surah.place,
                style: AppFonts.vazirmatn(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: IslandWorldPalette.mutedInk,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
