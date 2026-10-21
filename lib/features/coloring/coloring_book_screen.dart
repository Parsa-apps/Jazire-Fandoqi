import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/audio_service.dart';
import '../../core/coloring/coloring_pages.dart';
import '../../core/content_access_policy.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/game_data.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/kids_world_scaffold.dart';
import '../shop/content_lock.dart';
import '../shop/full_version_purchase_entry.dart';
import 'coloring_canvas_screen.dart';
import 'coloring_painter.dart';

/// 🎨 کتابِ رنگ‌آمیزی — انتخابِ صفحه و نمایشِ نیمهٔ رایگان/نیمهٔ کامل.
///
/// نقاشی‌ها برداری‌اند و در هر اندازه‌ای تیز می‌مانند؛ هیچ تصویری از
/// گالری خوانده یا به گالری نوشته نمی‌شود.
class ColoringBookScreen extends StatefulWidget {
  const ColoringBookScreen({super.key});

  @override
  State<ColoringBookScreen> createState() => _ColoringBookScreenState();
}

class _ColoringBookScreenState extends State<ColoringBookScreen> {
  static const List<Color> _gradient = <Color>[
    Color(0xFF7A1E4C),
    Color(0xFFB93E6E),
    Color(0xFFEF8A8A),
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
        'کتابِ رنگ‌آمیزی آماده است! یک صفحه انتخاب کن و با رنگ‌های شاد رنگش کن 🎨',
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

  bool _isFree(ColoringPage page) => ContentAccessPolicy.isFreeHalfItem(
        page.id,
        ColoringPages.all.map((item) => item.id),
      );

  Future<void> _openPage(ColoringPage page) async {
    if (_opening) return;
    _opening = true;
    HapticFeedback.selectionClick();
    AudioService.page();
    final allowed = await ensureContentAccess(
      context,
      featureName: page.title,
      isFree: _isFree(page),
    );
    if (!allowed || !mounted) {
      _opening = false;
      return;
    }
    unawaited(_refreshEntitlement());
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/coloring/${page.id}'),
        builder: (_) => ColoringCanvasScreen(page: page),
      ),
    );
    _opening = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = ColoringPages.all;
    final freeCount = pages.where(_isFree).length;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 760 ? 4 : (width >= 520 ? 3 : 2);

    return KidsWorldScaffold(
      title: 'کتابِ رنگ‌آمیزی',
      subtitle: 'انتخاب کن، رنگ کن و ذخیره کن',
      emoji: '🎨',
      gradient: _gradient,
      headerActions: <Widget>[
        KidsWorldBadge(
          label: '${PersianDigits.toFa(freeCount)} صفحه رایگان',
          background: const Color(0x33FFFFFF),
          foreground: Colors.white,
        ),
      ],
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        children: <Widget>[
          KidsWorldCard(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            color: const Color(0xFFFFF8F2),
            borderColor: const Color(0xFFFFC2D4),
            child: Row(
              children: <Widget>[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Color(0xFFFF8FB1), Color(0xFFE64A7A)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text('🖍️', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'یک رنگ انتخاب کن و روی هر قسمت از نقاشی بزن. '
                    'خط‌های نقاشی کمک می‌کنند شکلِ تصویر حفظ شود.',
                    style: AppFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.65,
                      color: IslandWorldPalette.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_hasFullVersion)
            ContentAccessNotice(
              featureName: 'کتاب رنگ‌آمیزی',
              freeCount: freeCount,
              totalCount: pages.length,
              hasFullVersion: _hasFullVersion,
              onUnlocked: _refreshEntitlement,
            ),
          const KidsWorldSectionTitle(
            title: 'صفحه‌های رنگ‌آمیزی',
            emoji: '📄',
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pages.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 196,
            ),
            itemBuilder: (BuildContext context, int index) {
              final page = pages[index];
              final locked = !_hasFullVersion && !_isFree(page);
              return LockedCardOverlay(
                locked: locked,
                badgeSize: 34,
                child: KidsWorldCard(
                  padding: const EdgeInsets.all(8),
                  semanticLabel: '${page.title}، ${page.hint}',
                  onTap: () => _openPage(page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              ColoredBox(
                                color: page.paperColor,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox.square(
                                    dimension: 132,
                                    child: ColoringPreview(page: page),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: KidsWorldBadge(
                                  label: _isFree(page) ? 'رایگان' : 'کامل',
                                  background: _isFree(page)
                                      ? const Color(0xE6E8F5E9)
                                      : const Color(0xE6FFF3CD),
                                  foreground: _isFree(page)
                                      ? const Color(0xFF1B5E20)
                                      : const Color(0xFF6B4E00),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          Text(
                            page.emoji,
                            style: const TextStyle(fontSize: 17),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              page.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.kids(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: IslandWorldPalette.ink,
                              ),
                            ),
                          ),
                          if (GameData.getBool('coloring_done_${page.id}') ==
                              true)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Color(0xFF2E7D4F),
                            )
                          else
                            const Icon(
                              Icons.brush_rounded,
                              size: 17,
                              color: Color(0xFFB23A6B),
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
            text: 'نقاشی‌ها فقط در آلبومِ خودِ برنامه ذخیره می‌شوند؛ '
                'هیچ عکسی به گالری گوشی نمی‌رود.',
          ),
          const KidsWorldBottomSpacer(),
        ],
      ),
    );
  }
}
