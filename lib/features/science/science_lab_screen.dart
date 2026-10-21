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
import '../../core/science/science_experiments.dart';
import '../../shared/widgets/kids_world_scaffold.dart';
import '../shop/content_lock.dart';
import '../shop/full_version_purchase_entry.dart';
import 'science_experiment_screen.dart';

/// 🔬 آزمایشگاهِ علوم فندقی — ورودیِ شش آزمایشِ تعاملی و بی‌خطر.
class ScienceLabScreen extends StatefulWidget {
  const ScienceLabScreen({super.key});

  @override
  State<ScienceLabScreen> createState() => _ScienceLabScreenState();
}

class _ScienceLabScreenState extends State<ScienceLabScreen> {
  static const List<Color> _gradient = <Color>[
    Color(0xFF062A33),
    Color(0xFF0B4F60),
    Color(0xFF0E7490),
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
        'به آزمایشگاه خوش آمدی! اینجا می‌پرسیم، حدس می‌زنیم و آزمایش می‌کنیم 🔬',
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

  bool _isFree(ScienceExperiment experiment) =>
      ContentAccessPolicy.isFreeHalfItem(
        experiment.id,
        ScienceData.all.map((item) => item.id),
      );

  bool _isDone(ScienceExperiment experiment) =>
      GameData.getBool('science_done_${experiment.id}') == true;

  Future<void> _openExperiment(ScienceExperiment experiment) async {
    if (_opening) return;
    _opening = true;
    HapticFeedback.selectionClick();
    AudioService.page();
    final allowed = await ensureContentAccess(
      context,
      featureName: 'آزمایش ${experiment.title}',
      isFree: _isFree(experiment),
    );
    if (!allowed || !mounted) {
      _opening = false;
      return;
    }
    unawaited(_refreshEntitlement());
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/science-lab/${experiment.id}'),
        builder: (_) => ScienceExperimentScreen(experiment: experiment),
      ),
    );
    _opening = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final experiments = ScienceData.all;
    final freeCount = experiments.where(_isFree).length;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 760 ? 3 : 2;
    final featured =
        experiments[(DateTime.now().weekday - 1) % experiments.length];
    final doneCount = experiments.where(_isDone).length;

    return KidsWorldScaffold(
      title: 'آزمایشگاهِ علوم',
      subtitle: 'بپرس، حدس بزن و آزمایش کن',
      emoji: '🔬',
      gradient: _gradient,
      headerActions: <Widget>[
        KidsWorldBadge(
          label: '${PersianDigits.toFa(freeCount)} آزمایش رایگان',
          background: const Color(0x33FFFFFF),
          foreground: Colors.white,
        ),
      ],
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        children: <Widget>[
          _LabIntroCard(doneCount: doneCount, total: experiments.length),
          const KidsWorldSectionTitle(title: 'آزمایشِ امروز', emoji: '⭐'),
          _FeaturedExperimentCard(
            experiment: featured,
            locked: !_hasFullVersion && !_isFree(featured),
            done: _isDone(featured),
            onTap: () => _openExperiment(featured),
          ),
          if (!_hasFullVersion)
            ContentAccessNotice(
              featureName: 'آزمایشگاه علوم',
              freeCount: freeCount,
              totalCount: experiments.length,
              hasFullVersion: _hasFullVersion,
              onUnlocked: _refreshEntitlement,
            ),
          const KidsWorldSectionTitle(title: 'همهٔ آزمایش‌ها', emoji: '🧪'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: experiments.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 172,
            ),
            itemBuilder: (BuildContext context, int index) {
              final experiment = experiments[index];
              return _ExperimentCard(
                experiment: experiment,
                locked: !_hasFullVersion && !_isFree(experiment),
                done: _isDone(experiment),
                onTap: () => _openExperiment(experiment),
              );
            },
          ),
          const KidsWorldSectionTitle(title: 'قانون‌های آزمایشگاه', emoji: '📋'),
          const _LabRulesCard(),
          ScienceFullVersionEntry(hasFullVersion: _hasFullVersion),
          const KidsWorldOfflineNote(
            text: 'همهٔ آزمایش‌ها داخل برنامه و بدون اینترنت کار می‌کنند.',
          ),
          const KidsWorldBottomSpacer(),
        ],
      ),
    );
  }
}

class _LabIntroCard extends StatelessWidget {
  const _LabIntroCard({required this.doneCount, required this.total});

  final int doneCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF67E8F9), Color(0xFF0E7490)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('🔬', style: TextStyle(fontSize: 27)),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'دانشمندِ کوچک، خوش آمدی!',
                  style: AppFonts.kids(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: IslandWorldPalette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'هر آزمایش یک سؤال دارد. اول حدس بزن، بعد امتحان کن و '
                  'آخرش ببین چرا آن اتفاق افتاد.',
                  style: AppFonts.vazirmatn(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.65,
                    color: IslandWorldPalette.mutedInk,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    KidsWorldBadge(
                      label: '${PersianDigits.toFa(doneCount)} از '
                          '${PersianDigits.toFa(total)} انجام شد',
                      background: const Color(0xFFE0F7FA),
                      foreground: const Color(0xFF006064),
                    ),
                    const KidsWorldBadge(
                      label: 'بی‌خطر و آفلاین',
                      background: Color(0xFFE8F5E9),
                      foreground: Color(0xFF1B5E20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedExperimentCard extends StatelessWidget {
  const _FeaturedExperimentCard({
    required this.experiment,
    required this.locked,
    required this.done,
    required this.onTap,
  });

  final ScienceExperiment experiment;
  final bool locked;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LockedCardOverlay(
      locked: locked,
      badgeSize: 34,
      child: Semantics(
        button: true,
        label: 'آزمایش امروز: ${experiment.title}',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: <Color>[
                  experiment.accentColor,
                  experiment.themeColor,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: experiment.themeColor.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.6,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      experiment.emoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              experiment.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.kids(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (done) ...<Widget>[
                            const SizedBox(width: 6),
                            const KidsWorldBadge(
                              label: '✓ انجام شد',
                              background: Color(0xFFE8F5E9),
                              foreground: Color(0xFF1B5E20),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        experiment.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.vazirmatn(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.55,
                          color: Colors.white.withOpacity(0.92),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'شروعِ آزمایش',
                              style: AppFonts.vazirmatn(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: experiment.themeColor,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 14,
                              color: experiment.themeColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({
    required this.experiment,
    required this.locked,
    required this.done,
    required this.onTap,
  });

  final ScienceExperiment experiment;
  final bool locked;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LockedCardOverlay(
      locked: locked,
      badgeSize: 30,
      child: KidsWorldCard(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
        semanticLabel: '${experiment.title}، ${experiment.subtitle}',
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        experiment.accentColor,
                        experiment.themeColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      experiment.emoji,
                      style: const TextStyle(fontSize: 23),
                    ),
                  ),
                ),
                const Spacer(),
                if (done)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 19,
                    color: Color(0xFF2E7D4F),
                  )
                else if (!locked)
                  const KidsWorldBadge(
                    label: 'رایگان',
                    background: Color(0xFFE8F5E9),
                    foreground: Color(0xFF1B5E20),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              experiment.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.kids(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: IslandWorldPalette.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              experiment.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.vazirmatn(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: IslandWorldPalette.mutedInk,
              ),
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: experiment.themeColor,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    locked ? 'نسخهٔ کامل' : 'آمادهٔ آزمایش',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.vazirmatn(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: experiment.themeColor,
                    ),
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

class _LabRulesCard extends StatelessWidget {
  const _LabRulesCard();

  static const List<(String, String, String)> _rules = <(String, String, String)>[
    ('🤝', 'با اجازه', 'هر آزمایش را با یک بزرگ‌تر و با اجازهٔ او انجام بده.'),
    ('🤔', 'اول حدس بزن', 'قبل از لمس کردن، حدس بزن چه اتفاقی می‌افتد.'),
    ('🧹', 'تمیزکاری', 'بعد از آزمایش، وسایل را جمع کن و دست‌هایت را بشور.'),
  ];

  @override
  Widget build(BuildContext context) {
    return KidsWorldCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < _rules.length; i++) ...<Widget>[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Divider(height: 1, color: Color(0xFFF0E4C8)),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _rules[i].$1,
                  style: const TextStyle(fontSize: 19),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _rules[i].$2,
                        style: AppFonts.vazirmatn(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: IslandWorldPalette.ink,
                        ),
                      ),
                      Text(
                        _rules[i].$3,
                        style: AppFonts.vazirmatn(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1.55,
                          color: IslandWorldPalette.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// کارتِ دعوت به نسخهٔ کامل؛ فقط وقتی نسخهٔ کامل نیست نمایش داده می‌شود.
class ScienceFullVersionEntry extends StatelessWidget {
  const ScienceFullVersionEntry({super.key, required this.hasFullVersion});

  final bool hasFullVersion;

  @override
  Widget build(BuildContext context) {
    if (hasFullVersion) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 14, 4, 2),
      child: Center(child: FullVersionPurchaseEntry()),
    );
  }
}
