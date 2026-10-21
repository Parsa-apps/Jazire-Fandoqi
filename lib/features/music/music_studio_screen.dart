import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/audio_service.dart';
import '../../core/content_access_policy.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/monetization.dart';
import '../../core/music/music_data.dart';
import '../../shared/widgets/kids_world_scaffold.dart';
import '../shop/content_lock.dart';
import '../shop/full_version_purchase_entry.dart';
import 'rhythm_echo_game.dart';

/// 🎵 استودیوی موسیقی فندقی
///
/// سه بخش دارد:
///   ۱. سازها — آشنایی با سازهای ایرانی و جهانی + نمونهٔ صدا
///   ۲. آهنگ‌ساز — پیانوی رنگی، آهنگ‌های آماده و ضبطِ آهنگِ کودک
///   ۳. ریتم — بازیِ حافظهٔ شنیداری «ریتم را تکرار کن»
///
/// همهٔ صداها فایلِ WAV داخل برنامه‌اند؛ هیچ شبکه‌ای مصرف نمی‌شود.
class MusicStudioScreen extends StatefulWidget {
  const MusicStudioScreen({super.key});

  @override
  State<MusicStudioScreen> createState() => _MusicStudioScreenState();
}

class _MusicStudioScreenState extends State<MusicStudioScreen> {
  static const List<Color> _gradient = <Color>[
    Color(0xFF251743),
    Color(0xFF4B2168),
    Color(0xFF7A2C62),
  ];

  int _tab = 1; // پیش‌فرض: آهنگ‌ساز، چون جذاب‌ترین بخش برای اولین لمس است.
  bool _hasFullVersion = false;

  String? _activeSongId;
  int? _playingNote;
  int _playToken = 0;

  bool _recording = false;
  bool _openingInstrument = false;
  /// امضای آخرین آهنگِ پاداش‌گرفته. پاداشِ «آهنگِ خودت» فقط برای آهنگِ
  /// *تازه* (دست‌کم ۳ نت) داده می‌شود تا با ساختِ مکررِ یک‌نُتی، ستاره
  /// بی‌نهایت به دست نیاید.
  String? _lastRewardedTune;

  /// آهنگ‌هایی که پاداششان همین حالا در حال ذخیره است؛ جلوی پاداشِ
  /// هم‌زمان (تپِ سریعِ دوباره) را می‌گیرد.
  final Set<String> _awardingSongs = <String>{};
  final List<int> _myTune = <int>[];

  @override
  void initState() {
    super.initState();
    Monetization.accessStatus.addListener(_onAccessChanged);
    FandoghiCoach.enablePersistentPresence();
    unawaited(_refreshEntitlement());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'به استودیوی موسیقی خوش آمدی! روی نت‌ها بزن و آهنگِ خودت را بساز 🎵',
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  void dispose() {
    _playToken++;
    Monetization.accessStatus.removeListener(_onAccessChanged);
    FandoghiCoach.clear();
    super.dispose();
  }

  void _onAccessChanged() {
    if (!mounted) return;
    final has = Monetization.accessStatus.value.isVerified;
    if (has != _hasFullVersion) setState(() => _hasFullVersion = has);
  }

  Future<void> _refreshEntitlement() async {
    final has = await Monetization.hasFullVersion();
    if (mounted && has != _hasFullVersion) {
      setState(() => _hasFullVersion = has);
    }
  }

  bool _isInstrumentFree(MusicInstrument instrument) =>
      ContentAccessPolicy.isFreeHalfItem(
        instrument.id,
        MusicInstruments.all.map((item) => item.id),
      );

  void _stopPlayback() {
    _playToken++;
    if (_activeSongId != null || _playingNote != null) {
      setState(() {
        _activeSongId = null;
        _playingNote = null;
      });
    }
  }

  void _selectTab(int tab) {
    if (tab == _tab) return;
    HapticFeedback.selectionClick();
    AudioService.select();
    _stopPlayback();
    if (_recording) setState(() => _recording = false);
    setState(() => _tab = tab);
  }

  // ── آهنگ‌ساز ────────────────────────────────────────────────────────────
  void _onKeyTap(int index) {
    final note = MusicNotes.all[index];
    unawaited(AudioService.playStudioAsset(note.asset, volume: 0.72));
    HapticFeedback.selectionClick();
    setState(() {
      _playingNote = index;
      if (_recording && _myTune.length < 32) _myTune.add(index);
    });
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _playingNote == index && _activeSongId == null) {
        setState(() => _playingNote = null);
      }
    });
  }

  void _toggleRecording() {
    HapticFeedback.mediumImpact();
    _stopPlayback();
    setState(() {
      _recording = !_recording;
      if (_recording) {
        _myTune.clear();
      }
    });
    if (_recording) {
      FandoghiCoach.instruction(
        'ضبط شروع شد! هر نت که دوست داری بزن؛ وقتی تمام شد دوباره ضبط را بزن 🎙️',
      );
    } else if (_myTune.isNotEmpty) {
      FandoghiCoach.correct('آهنگِ تو آماده شد! دکمهٔ پخش را بزن و گوش کن 🎶');
    }
  }

  Future<void> _playMyTune() async {
    if (_myTune.isEmpty) return;
    _stopPlayback();
    final token = ++_playToken;
    // کپی می‌گیریم تا اگر کودک در حین پخش، آهنگ را پاک کرد یا نتِ تازه
    // ضبط کرد، حلقه با ConcurrentModificationError نشکند.
    final tune = List<int>.of(_myTune);
    setState(() => _activeSongId = 'my_tune');
    for (final index in tune) {
      if (!mounted || token != _playToken) return;
      setState(() => _playingNote = index);
      unawaited(AudioService.playStudioAsset(
        MusicNotes.all[index].asset,
        volume: 0.72,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 330));
    }
    if (!mounted || token != _playToken) return;
    setState(() {
      _activeSongId = null;
      _playingNote = null;
    });
    final signature = tune.join('-');
    if (tune.length >= 3 && signature != _lastRewardedTune) {
      _lastRewardedTune = signature;
      GameData.addStars(1);
      GameData.addXp(2);
      FandoghiCoach.celebrate(
        'آهنگِ خودت را ساختی و شنیدی! یک ستاره گرفتی 🎉',
      );
    } else {
      FandoghiCoach.celebrate('آهنگِ خودت را شنیدی؟ خیلی قشنگ بود! 🎵');
    }
  }

  Future<void> _playSong(KidsSong song) async {
    if (_activeSongId == song.id) {
      _stopPlayback();
      return;
    }
    _stopPlayback();
    final token = ++_playToken;
    final msPerBeat = (60000 / song.bpm).round();
    setState(() {
      _activeSongId = song.id;
      _recording = false;
    });
    for (final step in song.steps) {
      if (!mounted || token != _playToken) return;
      final noteIndex = step.note % MusicNotes.all.length;
      setState(() => _playingNote = noteIndex);
      unawaited(AudioService.playStudioAsset(
        MusicNotes.all[noteIndex].asset,
        volume: 0.70,
      ));
      await Future<void>.delayed(
        Duration(
          milliseconds: (msPerBeat * step.beats).clamp(180, 2400).toInt(),
        ),
      );
    }
    if (!mounted || token != _playToken) return;
    setState(() {
      _activeSongId = null;
      _playingNote = null;
    });
    unawaited(_awardSongOnce(song));
  }

  Future<void> _awardSongOnce(KidsSong song) async {
    final key = 'music_song_done_${song.id}';
    if (_awardingSongs.contains(song.id) || GameData.getBool(key) == true) {
      return;
    }
    _awardingSongs.add(song.id);
    await GameData.setBool(key, true);
    _awardingSongs.remove(song.id);
    GameData.addStars(2);
    GameData.addXp(6);
    GameData.recordAnswer(correct: true, skill: 'music');
    if (!mounted) return;
    setState(() {});
    FandoghiCoach.celebrate('آهنگِ «${song.title}» را کامل شنیدی! 🎶');
  }

  // ── سازها ──────────────────────────────────────────────────────────────
  Future<void> _openInstrument(MusicInstrument instrument) async {
    if (_openingInstrument) return;
    _openingInstrument = true;
    HapticFeedback.selectionClick();
    final allowed = await ensureContentAccess(
      context,
      featureName: instrument.name,
      isFree: _isInstrumentFree(instrument),
    );
    if (!allowed || !mounted) {
      _openingInstrument = false;
      return;
    }
    unawaited(_refreshEntitlement());
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => _InstrumentSheet(
        instrument: instrument,
      ),
    );
    _openingInstrument = false;
  }

  @override
  Widget build(BuildContext context) {
    final freeInstruments = MusicInstruments.all
        .where(_isInstrumentFree)
        .length;

    return KidsWorldScaffold(
      title: 'استودیوی موسیقی',
      subtitle: 'بنواز، بساز و ریتم را کشف کن',
      emoji: '🎵',
      gradient: _gradient,
      headerActions: <Widget>[
        KidsWorldBadge(
          label: '${PersianDigits.toFa(freeInstruments)} ساز رایگان',
          background: const Color(0x33FFFFFF),
          foreground: Colors.white,
        ),
      ],
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        children: <Widget>[
          _StudioIntroCard(
            onPlayNote: () => _onKeyTap(0),
          ),
          const SizedBox(height: 10),
          _StudioTabs(selected: _tab, onSelect: _selectTab),
          const SizedBox(height: 10),
          if (_tab == 0) ...<Widget>[
            if (!_hasFullVersion)
              ContentAccessNotice(
                featureName: 'سازها',
                freeCount: freeInstruments,
                totalCount: MusicInstruments.all.length,
                hasFullVersion: _hasFullVersion,
                onUnlocked: _refreshEntitlement,
              ),
            _InstrumentGrid(
              hasFullVersion: _hasFullVersion,
              isFree: _isInstrumentFree,
              onTap: _openInstrument,
            ),
          ] else if (_tab == 1) ...<Widget>[
            _ComposerCard(
              selectedNote: _playingNote,
              recording: _recording,
              myTune: _myTune,
              activeSongId: _activeSongId,
              onKeyTap: _onKeyTap,
              onToggleRecording: _toggleRecording,
              onPlayMyTune: _playMyTune,
              onClearMyTune: () => setState(() => _myTune.clear()),
            ),
            const SizedBox(height: 10),
            _SongsSection(
              activeSongId: _activeSongId,
              onToggle: _playSong,
            ),
          ] else ...<Widget>[
            const RhythmEchoGame(),
          ],
          const SizedBox(height: 12),
          if (_tab != 2)
            const Center(child: FullVersionPurchaseEntry(compact: true)),
          const KidsWorldOfflineNote(
            text: 'همهٔ نت‌ها و ریتم‌ها به‌صورت فایل داخل برنامه ذخیره شده‌اند.',
          ),
          const KidsWorldBottomSpacer(),
        ],
      ),
    );
  }
}

class _StudioIntroCard extends StatelessWidget {
  const _StudioIntroCard({required this.onPlayNote});

  final VoidCallback onPlayNote;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      color: const Color(0xFFFFF7E6),
      borderColor: const Color(0xFFFFD166),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: onPlayNote,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFFFE082), Color(0xFFFFB300)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFFFFB300).withOpacity(0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎹', style: TextStyle(fontSize: 30)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'استودیوی کوچکِ فندقی',
                  style: AppFonts.kids(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'روی کلیدها بزن، آهنگِ آماده گوش کن یا با ضبط، '
                  'آهنگِ خودت را بساز.',
                  style: AppFonts.vazirmatn(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.55,
                    color: IslandWorldPalette.mutedInk,
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

class _StudioTabs extends StatelessWidget {
  const _StudioTabs({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const tabs = <(String, String)>[
      ('🎻', 'سازها'),
      ('🎹', 'آهنگ‌ساز'),
      ('🥁', 'ریتم'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: selected == i,
                label: tabs[i].$2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected == i
                          ? const Color(0xFFFFD166)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          tabs[i].$1,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            tabs[i].$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.kids(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: selected == i
                                  ? const Color(0xFF3B2A00)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InstrumentGrid extends StatelessWidget {
  const _InstrumentGrid({
    required this.hasFullVersion,
    required this.isFree,
    required this.onTap,
  });

  final bool hasFullVersion;
  final bool Function(MusicInstrument) isFree;
  final Future<void> Function(MusicInstrument) onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 720 ? 4 : (width >= 520 ? 3 : 2);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: MusicInstruments.all.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 154,
      ),
      itemBuilder: (BuildContext context, int index) {
        final instrument = MusicInstruments.all[index];
        final locked = !hasFullVersion && !isFree(instrument);
        return LockedCardOverlay(
          locked: locked,
          badgeSize: 32,
          child: KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            semanticLabel: '${instrument.name}، ${instrument.family}',
            onTap: () => onTap(instrument),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      instrument.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                    const Spacer(),
                    if (!locked)
                      const Icon(
                        Icons.play_circle_fill_rounded,
                        size: 22,
                        color: Color(0xFFB8860B),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  instrument.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.kids(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                Text(
                  instrument.family,
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
                    instrument.fact,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.vazirmatn(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: IslandWorldPalette.mutedInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ComposerCard extends StatelessWidget {
  const _ComposerCard({
    required this.selectedNote,
    required this.recording,
    required this.myTune,
    required this.activeSongId,
    required this.onKeyTap,
    required this.onToggleRecording,
    required this.onPlayMyTune,
    required this.onClearMyTune,
  });

  final int? selectedNote;
  final bool recording;
  final List<int> myTune;
  final String? activeSongId;
  final ValueChanged<int> onKeyTap;
  final VoidCallback onToggleRecording;
  final Future<void> Function() onPlayMyTune;
  final VoidCallback onClearMyTune;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('🎹', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'پیانوی فندقی',
                  style: AppFonts.kids(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: recording
                      ? const Color(0xFFFFE0E0)
                      : const Color(0xFFEDF7ED),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: recording
                        ? const Color(0xFFE57373)
                        : const Color(0xFF81C784),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      recording
                          ? Icons.fiber_manual_record
                          : Icons.music_note_rounded,
                      size: 13,
                      color: recording
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recording
                          ? 'در حال ضبط'
                          : (activeSongId == 'my_tune'
                              ? 'پخشِ آهنگِ من'
                              : 'آماده'),
                      style: AppFonts.vazirmatn(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: recording
                            ? const Color(0xFFB71C1C)
                            : const Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 142,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: <Widget>[
                  for (var i = 0; i < MusicNotes.all.length; i++)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: _PianoKey(
                        note: MusicNotes.all[i],
                        highlighted: selectedNote == i,
                        onTap: () => onKeyTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: KidsWorldButton(
                  label: recording ? 'پایانِ ضبط' : 'ضبطِ آهنگ',
                  emoji: recording ? '⏹️' : '🎙️',
                  color: recording
                      ? const Color(0xFFFFCDD2)
                      : const Color(0xFFFFD166),
                  textColor: recording
                      ? const Color(0xFF8E0000)
                      : const Color(0xFF3B2A00),
                  onPressed: onToggleRecording,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KidsWorldButton(
                  label: 'پخشِ آهنگِ من',
                  emoji: '▶️',
                  color: const Color(0xFFCDE7FF),
                  textColor: const Color(0xFF00325B),
                  onPressed: myTune.isEmpty ? null : onPlayMyTune,
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'پاک‌کردن آهنگ',
                child: IconButton(
                  tooltip: 'پاک‌کردن آهنگ',
                  onPressed: myTune.isEmpty ? null : onClearMyTune,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: IslandWorldPalette.mutedInk,
                ),
              ),
            ],
          ),
          if (myTune.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: <Widget>[
                for (var i = 0; i < myTune.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: MusicNotes.all[myTune[i]].color.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      MusicNotes.all[myTune[i]].persianName,
                      style: AppFonts.vazirmatn(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: IslandWorldPalette.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            recording
                ? 'هر نت که می‌زنی به آهنگِ تو اضافه می‌شود.'
                : 'می‌توانی نت‌ها را آزادانه بزنی یا آهنگِ خودت را ضبط کنی.',
            style: AppFonts.vazirmatn(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: IslandWorldPalette.mutedInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _PianoKey extends StatefulWidget {
  const _PianoKey({
    required this.note,
    required this.highlighted,
    required this.onTap,
  });

  final MusicNote note;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  State<_PianoKey> createState() => _PianoKeyState();
}

class _PianoKeyState extends State<_PianoKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final down = _pressed || widget.highlighted;
    return Semantics(
      button: true,
      label: 'نتِ ${widget.note.persianName}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: 52,
          height: down ? 134 : 142,
          margin: EdgeInsets.only(top: down ? 8 : 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color.lerp(widget.note.color, Colors.white, 0.55)!,
                widget.note.color,
                Color.lerp(widget.note.color, Colors.black, 0.18)!,
              ],
              stops: const <double>[0, 0.45, 1],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
              bottom: Radius.circular(18),
            ),
            border: Border.all(
              color: down ? Colors.white : Colors.white.withOpacity(0.65),
              width: down ? 3 : 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: widget.note.color.withOpacity(0.45),
                blurRadius: down ? 6 : 12,
                offset: Offset(0, down ? 2 : 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                widget.note.persianName,
                style: AppFonts.kids(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: const <Shadow>[
                    Shadow(color: Color(0x66000000), blurRadius: 4),
                  ],
                ),
              ),
              Text(
                widget.note.solfege,
                style: AppFonts.vazirmatn(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongsSection extends StatelessWidget {
  const _SongsSection({
    required this.activeSongId,
    required this.onToggle,
  });

  final String? activeSongId;
  final Future<void> Function(KidsSong) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const KidsWorldSectionTitle(
          title: 'آهنگ‌های آماده',
          emoji: '🎶',
        ),
        for (final song in KidsSongs.all) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SongCard(
              song: song,
              active: activeSongId == song.id,
              done: GameData.getBool('music_song_done_${song.id}') == true,
              onTap: () => onToggle(song),
            ),
          ),
        ],
      ],
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({
    required this.song,
    required this.active,
    required this.done,
    required this.onTap,
  });

  final KidsSong song;
  final bool active;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      borderColor: active ? const Color(0xFF7BE495) : IslandWorldPalette.honey,
      onTap: onTap,
      semanticLabel: '${song.title}، ${song.subtitle}',
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
            ),
            child: Center(
              child: Text(song.emoji, style: const TextStyle(fontSize: 21)),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.kids(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                Text(
                  '${song.subtitle} • ${PersianDigits.toFa(song.steps.length)} نت',
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
          const SizedBox(width: 6),
          if (done)
            const Padding(
              padding: EdgeInsetsDirectional.only(end: 4),
              child: Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: Color(0xFF2E7D4F),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? const Color(0xFF7BE495)
                  : const Color(0xFFFFD166),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              active ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: const Color(0xFF3B2A00),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstrumentSheet extends StatefulWidget {
  const _InstrumentSheet({required this.instrument});

  final MusicInstrument instrument;

  @override
  State<_InstrumentSheet> createState() => _InstrumentSheetState();
}

class _InstrumentSheetState extends State<_InstrumentSheet> {
  int _token = 0;
  bool _playing = false;

  @override
  void dispose() {
    _token++;
    super.dispose();
  }

  Future<void> _playDemo() async {
    if (_playing) return;
    final token = ++_token;
    setState(() => _playing = true);
    final instrument = widget.instrument;
    if (instrument.percussion) {
      for (final pad in instrument.demoPads) {
        if (!mounted || token != _token) return;
        unawaited(AudioService.playStudioAsset(
          PercussionPads.all[pad % PercussionPads.all.length].asset,
          volume: 0.76,
        ));
        await Future<void>.delayed(const Duration(milliseconds: 260));
      }
    } else {
      for (final note in instrument.demoNotes) {
        if (!mounted || token != _token) return;
        unawaited(AudioService.playStudioAsset(
          MusicNotes.all[note % MusicNotes.all.length].asset,
          volume: 0.70,
        ));
        await Future<void>.delayed(const Duration(milliseconds: 330));
      }
    }
    if (mounted && token == _token) setState(() => _playing = false);
  }

  @override
  Widget build(BuildContext context) {
    final instrument = widget.instrument;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          10,
          10,
          10,
          MediaQuery.paddingOf(context).bottom + 10,
        ),
        child: KidsWorldCard(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    instrument.emoji,
                    style: const TextStyle(fontSize: 42),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          instrument.name,
                          style: AppFonts.kids(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: IslandWorldPalette.ink,
                          ),
                        ),
                        Text(
                          instrument.family,
                          style: AppFonts.vazirmatn(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: IslandWorldPalette.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded),
                    color: IslandWorldPalette.ink,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                instrument.fact,
                style: AppFonts.vazirmatn(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.7,
                  color: IslandWorldPalette.ink,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: Color(0xFFB8860B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        instrument.playHint,
                        style: AppFonts.vazirmatn(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B4E00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              KidsWorldButton(
                label: _playing ? 'در حال پخش...' : 'یک نمونه بشنو',
                emoji: '🎧',
                onPressed: _playing ? null : _playDemo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
