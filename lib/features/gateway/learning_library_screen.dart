import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../shared/widgets/fandoghi_premium.dart';
import '../shop/full_version_purchase_entry.dart';

/// 📚 صفحهٔ «دسته‌بندی‌ها» (کتابخانه و کوله‌پشتی یادگیری — مطابقِ طرحِ مرجع).
class LearningLibraryScreen extends StatelessWidget {
  final bool embedded;

  const LearningLibraryScreen({super.key, this.embedded = false});

  static const List<_LibraryItem> _items = <_LibraryItem>[
    _LibraryItem(
      title: 'حروف الفبا',
      subtitle: 'آشنایی با الفبا و صدای حروف',
      emoji: '🔤',
      assetPath: 'assets/theme_v2/cat_alphabet.webp',
      route: '/alphabet',
      cardTop: Color(0xFFD9F2FF),
      cardBottom: Color(0xFFA6DCFC),
      extrusionColor: Color(0xFF4F9FD1),
      textColor: Color(0xFF0D3B5E),
    ),
    _LibraryItem(
      title: 'دنیای اعداد',
      subtitle: 'اعداد ۱ تا ۲۰ و شمارش شاد',
      emoji: '🔢',
      badgeLabel: 'اعداد',
      assetPath: 'assets/theme_v2/cat_numbers.webp',
      route: '/numbers',
      cardTop: Color(0xFFFFF4CC),
      cardBottom: Color(0xFFFFDE82),
      extrusionColor: Color(0xFFD19926),
      textColor: Color(0xFF4E3000),
    ),
    _LibraryItem(
      title: 'دانشنامه حیوانات ایران',
      subtitle: 'حیوانات بومی با صدای واقعی',
      emoji: '🦁',
      badgeLabel: 'حیوانات',
      assetPath: 'assets/theme_v2/cat_animals.webp',
      // مسیر کانونی دانشنامه؛ مسیر قبلی هیچ‌جا تعریف نشده بود و لمسِ
      // این کارت کاربر را به صفحهٔ «پیدا نشد» می‌برد.
      route: '/animals',
      cardTop: Color(0xFFDCF9E4),
      cardBottom: Color(0xFFA3E9B8),
      extrusionColor: Color(0xFF459E62),
      textColor: Color(0xFF104523),
    ),
    _LibraryItem(
      title: 'مفاهیم اولیه',
      subtitle: 'بزرگ و کوچک، شب و روز، فصل‌ها و هوا',
      emoji: '🔺',
      badgeLabel: 'شکل‌ها',
      assetPath: 'assets/theme_v2/cat_shapes.webp',
      // هاب «مفاهیم اولیه» با همین عنوان؛ مسیر قبلی تعریف‌نشده بود.
      route: '/concepts',
      cardTop: Color(0xFFF5DFFF),
      cardBottom: Color(0xFFE0B3FA),
      extrusionColor: Color(0xFF9155B8),
      textColor: Color(0xFF3A1457),
    ),
    _LibraryItem(
      title: 'پازل',
      subtitle: 'پازل و بازی‌های فکری کودکانه',
      emoji: '🧩',
      assetPath: 'assets/theme_v2/cat_puzzle.webp',
      route: '/games-carnival',
      cardTop: Color(0xFFFFE5D4),
      cardBottom: Color(0xFFFFBF96),
      extrusionColor: Color(0xFFD6753E),
      textColor: Color(0xFF542308),
    ),
    _LibraryItem(
      title: 'موسیقی',
      subtitle: 'لالایی‌ها و آهنگ‌های آرام کودکانه',
      emoji: '🎵',
      assetPath: 'assets/theme_v2/cat_music.webp',
      // صفحهٔ ساز/ریتم در اپ وجود ندارد؛ نزدیک‌ترین مقصدِ موسیقاییِ واقعی
      // هاب لالایی‌هاست. مسیر قبلی تعریف‌نشده بود.
      route: '/lullabies',
      cardTop: Color(0xFFD4F8F8),
      cardBottom: Color(0xFF95E6E6),
      extrusionColor: Color(0xFF349CA1),
      textColor: Color(0xFF0A4245),
    ),
    _LibraryItem(
      title: 'شغل‌های قهرمانانه',
      subtitle: 'آتش‌نشان، پزشک، خلبان و معلم',
      emoji: '🚒',
      route: '/jobs',
      cardTop: Color(0xFFFFE0E6),
      cardBottom: Color(0xFFFFB3C1),
      extrusionColor: Color(0xFFC95B72),
      textColor: Color(0xFF521220),
    ),
    _LibraryItem(
      title: 'دنیای احساسات',
      subtitle: 'شادی، خشم، آرامش و همدلی',
      emoji: '💛',
      route: '/sel',
      cardTop: Color(0xFFFFF6D6),
      cardBottom: Color(0xFFFFE08A),
      extrusionColor: Color(0xFFC99826),
      textColor: Color(0xFF4A3200),
    ),
    _LibraryItem(
      title: 'مهارت زندگی',
      subtitle: 'مسواک، نظم، سلام و تشکر',
      emoji: '🌱',
      route: '/life-skills',
      cardTop: Color(0xFFE0F7E9),
      cardBottom: Color(0xFFADE8C4),
      extrusionColor: Color(0xFF479968),
      textColor: Color(0xFF104224),
    ),
    _LibraryItem(
      title: 'قصه‌ها',
      subtitle: 'قصه‌های صوتی و آموزنده شب',
      emoji: '📖',
      route: '/stories',
      cardTop: Color(0xFFE8E2FF),
      cardBottom: Color(0xFFC5B8FA),
      extrusionColor: Color(0xFF6F5CC2),
      textColor: Color(0xFF23165C),
    ),
    _LibraryItem(
      title: 'رنگ‌آمیزی',
      subtitle: 'بوم نقاشی و رنگ‌های شاد',
      emoji: '🎨',
      // بوم نقاشی (DrawingGame)؛ همان مقصدی که جست‌وجو و هاب هنر هم
      // برای «نقاشی» استفاده می‌کنند. مسیر قبلی تعریف‌نشده بود.
      route: '/game/نقاشی',
      cardTop: Color(0xFFFFE6F2),
      cardBottom: Color(0xFFFFB8DA),
      extrusionColor: Color(0xFFC7588E),
      textColor: Color(0xFF4F1130),
    ),
    _LibraryItem(
      title: 'شعرها',
      subtitle: 'شعرهای کودکانه و ریتمیک',
      emoji: '🎶',
      route: '/poems',
      cardTop: Color(0xFFDDF4FF),
      cardBottom: Color(0xFFA8E0FA),
      extrusionColor: Color(0xFF4395BD),
      textColor: Color(0xFF0A3952),
    ),
    _LibraryItem(
      title: 'قرآن کودک',
      subtitle: 'سوره‌های کوتاه با صوت دلنشین',
      emoji: '🕌',
      route: '/quran',
      cardTop: Color(0xFFD9F7EE),
      cardBottom: Color(0xFF9EE8D2),
      extrusionColor: Color(0xFF33967A),
      textColor: Color(0xFF0A3D2E),
    ),
    _LibraryItem(
      title: 'کارتون‌کده فندقی',
      subtitle: 'انیمیشن‌های آموزنده و شاد',
      emoji: '🎬',
      route: '/cartoons',
      cardTop: Color(0xFFFFEAD6),
      cardBottom: Color(0xFFFFC896),
      extrusionColor: Color(0xFFC97B36),
      textColor: Color(0xFF4D2400),
    ),
    _LibraryItem(
      title: 'آزمایشگاه علوم',
      subtitle: 'فصل‌ها، آب‌وهوا، شب و روز و طبیعت',
      emoji: '🔬',
      // آزمایشگاه علومِ جدا در اپ نیست؛ هاب علومِ خودِ برنامه هم «مفاهیم
      // علوم و دنیای اطراف» (فصل‌ها، آب‌وهوا، شب و روز) را به همین مقصد
      // می‌فرستد. مسیر قبلی تعریف‌نشده بود.
      route: '/concepts',
      cardTop: Color(0xFFE0F2FE),
      cardBottom: Color(0xFFBAE6FD),
      extrusionColor: Color(0xFF3B82F6),
      textColor: Color(0xFF1E3A8A),
    ),
    _LibraryItem(
      title: 'مراحل بازی',
      subtitle: 'نقشهٔ مراحل و ماجراجویی در جزیره',
      emoji: '🗺️',
      route: '/stage-map',
      cardTop: Color(0xFFFEF3C7),
      cardBottom: Color(0xFFFDE68A),
      extrusionColor: Color(0xFFD97706),
      textColor: Color(0xFF451A03),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final content = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF145C6B),
            Color(0xFF0B3B46),
            Color(0xFF06232B),
          ],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final width = constraints.maxWidth;
            final compact = width < 360 || constraints.maxHeight < 600;
            final crossAxisCount = width >= 900
                ? 4
                : width >= 620
                    ? 3
                    : 2;
            final cardExtent = compact ? 132.0 : 152.0;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      compact ? 6 : 10,
                      12,
                      compact ? 6 : 10,
                    ),
                    child: _buildHeader(
                      context,
                      compact: compact,
                      animationsDisabled: animationsDisabled,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 14),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: compact ? 10 : 12,
                      crossAxisSpacing: compact ? 10 : 12,
                      mainAxisExtent: cardExtent,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return _Category3DCard(
                          item: _items[index],
                          compact: compact,
                          onTap: () => _openItem(context, _items[index]),
                        );
                      },
                      childCount: _items.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 24),
                    child: FullVersionPurchaseEntry(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (embedded) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: content,
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF06232B),
        body: content,
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required bool compact,
    required bool animationsDisabled,
  }) {
    final legacyTitle =
        embedded ? 'کوله‌پشتی یادگیری 🎒' : 'کتابخانه یادگیری 📚';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xD8176778),
            Color(0xEB0B3640),
          ],
        ),
        border: Border.all(
          color: const Color(0x9980DEEA),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          if (!embedded) ...<Widget>[
            _Green3DBackButton(
              size: compact ? 36 : 40,
              onTap: () {
                HapticFeedback.lightImpact();
                AudioService.tap();
                Navigator.of(context).maybePop();
              },
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: compact ? 36 : 44,
            height: compact ? 36 : 44,
            child: FandoghiPremium(
              size: compact ? 34 : 40,
              animated: !animationsDisabled,
              showParticles: false,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'دسته‌بندی‌ها',
                      style: AppFonts.kids(
                        fontSize: compact ? 18 : 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        legacyTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.vazirmatn(
                          fontSize: compact ? 10.5 : 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB2EBF2),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'هر کارت یک ماجراجویی شاد با فندقی است!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.vazirmatn(
                    fontSize: compact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE0F7FA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openItem(BuildContext context, _LibraryItem item) {
    HapticFeedback.lightImpact();
    AudioService.tap();
    Navigator.of(context).pushNamed(item.route);
  }
}

class _Green3DBackButton extends StatelessWidget {
  const _Green3DBackButton({
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'بازگشت',
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF81C784),
                Color(0xFF2E7D32),
              ],
            ),
            border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF1B5E20).withOpacity(0.55),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Category3DCard extends StatelessWidget {
  const _Category3DCard({
    required this.item,
    required this.compact,
    required this.onTap,
  });

  final _LibraryItem item;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 20.0 : 24.0;
    final iconSize = compact ? 58.0 : 72.0;

    return Semantics(
      button: true,
      label: '${item.title} — ${item.subtitle}',
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Stack(
          children: <Widget>[
            // لایهٔ زیرینِ سه‌بعدی
            Positioned(
              left: 0,
              right: 0,
              top: 5,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: item.extrusionColor,
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            // رویهٔ کارتِ پاستلیِ سه‌بعدی
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 5,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  8,
                  compact ? 6 : 8,
                  8,
                  compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[item.cardTop, item.cardBottom],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.92),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: item.assetPath != null
                            ? Image.asset(
                                item.assetPath!,
                                width: iconSize,
                                height: iconSize,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                                errorBuilder: (_, __, ___) => Text(
                                  item.emoji,
                                  style: TextStyle(
                                    fontSize: compact ? 34 : 42,
                                  ),
                                ),
                              )
                            : Container(
                                width: iconSize * 0.85,
                                height: iconSize * 0.85,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.62),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.8,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    item.emoji,
                                    style: TextStyle(
                                      fontSize: compact ? 30 : 36,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.title,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: AppFonts.kids(
                          fontSize: compact ? 14.5 : 16.5,
                          fontWeight: FontWeight.w900,
                          color: item.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppFonts.vazirmatn(
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: item.textColor.withOpacity(0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (item.badgeLabel != null)
              Positioned(
                top: 6,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.86),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.badgeLabel!,
                    style: AppFonts.kids(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: item.textColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

class _LibraryItem {
  final String title;
  final String subtitle;
  final String emoji;
  final String? badgeLabel;
  final String? assetPath;
  final String route;
  final Color cardTop;
  final Color cardBottom;
  final Color extrusionColor;
  final Color textColor;

  const _LibraryItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.route,
    required this.cardTop,
    required this.cardBottom,
    required this.extrusionColor,
    required this.textColor,
    this.badgeLabel,
    this.assetPath,
  });
}
