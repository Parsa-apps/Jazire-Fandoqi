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
import '../../core/learning_content/poems_data.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/kids_world_scaffold.dart';
import '../shop/content_lock.dart';
import '../shop/full_version_purchase_entry.dart';
import 'poem_reader_screen.dart';

/// 📖 شعرستانِ فندقی — ده شعرِ اورجینال با خواندن، ریتم و بازیِ قافیه.
class PoemsHubScreen extends StatefulWidget {
  const PoemsHubScreen({super.key});

  @override
  State<PoemsHubScreen> createState() => _PoemsHubScreenState();
}

class _PoemsHubScreenState extends State<PoemsHubScreen> {
  static const List<Color> _gradient = <Color>[
    Color(0xFF4A2418),
    Color(0xFF8B3F27),
    Color(0xFFD07A45),
  ];

  bool _hasFullVersion = false;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    Monetization.accessStatus.addListener(_onAccessChanged);
    FandoghiCoach.enablePersistentPresence();
    unawaited(_refreshEntitlement());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FandoghiCoach.say(
        'به شعرستان خوش آمدی! شعرها را با هم بخوانیم و روی ریتم دست بزنیم 📖',
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  void dispose() {
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

  bool _isFree(KidsPoem poem) => ContentAccessPolicy.isFreeHalfItem(
        poem.id,
        PoemsData.all.map((item) => item.id),
      );

  bool _isRead(KidsPoem poem) =>
      GameData.getBool('poem_done_${poem.id}') == true;

  Future<void> _openPoem(KidsPoem poem) async {
    if (_opening) return;
    _opening = true;
    HapticFeedback.selectionClick();
    AudioService.page();
    final allowed = await ensureContentAccess(
      context,
      featureName: poem.title,
      isFree: _isFree(poem),
    );
    if (!allowed || !mounted) {
      _opening = false;
      return;
    }
    unawaited(_refreshEntitlement());
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/poems/${poem.id}'),
        builder: (_) => PoemReaderScreen(poem: poem),
      ),
    );
    _opening = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final poems = PoemsData.all;
    final freeCount = poems.where(_isFree).length;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 760 ? 4 : (width >= 520 ? 3 : 2);
    final featured =
        poems[(DateTime.now().weekday - 1) % poems.length];

    return KidsWorldScaffold(
      title: 'شعرستانِ فندقی',
      subtitle: 'بخوان، دست بزن و قافیه را پیدا کن',
      emoji: '📖',
      gradient: _gradient,
      headerActions: <Widget>[
        KidsWorldBadge(
          label: '${PersianDigits.toFa(freeCount)} شعر رایگان',
          background: const Color(0x33FFFFFF),
          foreground: Colors.white,
        ),
      ],
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        children: <Widget>[
          _FeaturedPoemCard(
            poem: featured,
            read: _isRead(featured),
            locked: !_hasFullVersion && !_isFree(featured),
            onTap: () => _openPoem(featured),
          ),
          if (!_hasFullVersion)
            ContentAccessNotice(
              featureName: 'شعرها',
              freeCount: freeCount,
              totalCount: poems.length,
              hasFullVersion: _hasFullVersion,
              onUnlocked: _refreshEntitlement,
            ),
          const KidsWorldSectionTitle(
            title: 'همهٔ شعرها',
            emoji: '🎶',
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: poems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 178,
            ),
            itemBuilder: (BuildContext context, int index) {
              final poem = poems[index];
              final locked = !_hasFullVersion && !_isFree(poem);
              final read = _isRead(poem);
              return LockedCardOverlay(
                locked: locked,
                badgeSize: 32,
                child: KidsWorldCard(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                  semanticLabel: '${poem.title}، ${poem.theme}',
                  onTap: () => _openPoem(poem),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: poem.themeColor.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                poem.emoji,
                                style: const TextStyle(fontSize: 21),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (read)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Color(0xFF2E7D32),
                            )
                          else
                            KidsWorldBadge(
                              label: _isFree(poem) ? 'رایگان' : 'کامل',
                              background: _isFree(poem)
                                  ? const Color(0xE6E8F5E9)
                                  : const Color(0xE6FFF3CD),
                              foreground: _isFree(poem)
                                  ? const Color(0xFF1B5E20)
                                  : const Color(0xFF6B4E00),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        poem.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.kids(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: IslandWorldPalette.ink,
                        ),
                      ),
                      Text(
                        poem.theme,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.vazirmatn(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: IslandWorldPalette.mutedInk,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Text(
                          '"${poem.lines.first.text}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.vazirmatn(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                            color: IslandWorldPalette.ink,
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color: poem.themeColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${PersianDigits.toFa(poem.lines.length)} خط • '
                            '${PersianDigits.toFa(poem.totalBeats)} ضربه',
                            style: AppFonts.vazirmatn(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: IslandWorldPalette.mutedInk,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          const Center(child: FullVersionPurchaseEntry()),
          const KidsWorldOfflineNote(
            text: 'شعرها اورجینال‌اند و همهٔ صداها از خودِ برنامه پخش می‌شوند.',
          ),
          const KidsWorldBottomSpacer(),
        ],
      ),
    );
  }
}

class _FeaturedPoemCard extends StatelessWidget {
  const _FeaturedPoemCard({
    required this.poem,
    required this.read,
    required this.locked,
    required this.onTap,
  });

  final KidsPoem poem;
  final bool read;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      color: const Color(0xFFFFF6E9),
      borderColor: poem.accentColor,
      onTap: onTap,
      semanticLabel: 'شعرِ امروز: ${poem.title}',
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
                  Color.lerp(poem.themeColor, Colors.white, 0.25)!,
                  poem.themeColor,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: poem.themeColor.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(poem.emoji, style: const TextStyle(fontSize: 32)),
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
                      'شعرِ امروز',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF9A3412),
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
                    if (locked) ...<Widget>[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.lock_rounded,
                        size: 13,
                        color: Color(0xFF8A6D00),
                      ),
                      const Text(
                        'نسخهٔ کامل',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF8A6D00),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  poem.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.kids(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                Text(
                  '"${poem.lines.first.text}"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: IslandWorldPalette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.play_circle_fill_rounded,
            size: 34,
            color: Color(0xFFB8860B),
          ),
        ],
      ),
    );
  }
}
