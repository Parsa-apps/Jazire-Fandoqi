part of 'about_screen.dart';

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.palette, required this.child});

  final _AboutPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 520;
    return _HoverLift(
      distance: 8,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 21 : 36,
          vertical: compact ? 28 : 40,
        ),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: palette.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(palette.isLight ? 0.08 : 0.20),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _FounderSection extends StatelessWidget {
  const _FounderSection({required this.palette, required this.motion});

  final _AboutPalette palette;
  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final avatar = _FounderAvatar(palette: palette, motion: motion);
        final information = _FounderInformation(
          palette: palette,
          centered: compact,
        );

        if (compact) {
          return Column(
            children: [
              avatar,
              const SizedBox(height: 34),
              information,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            avatar,
            const SizedBox(width: 38),
            Expanded(child: information),
          ],
        );
      },
    );
  }
}

class _FounderAvatar extends StatelessWidget {
  const _FounderAvatar({required this.palette, required this.motion});

  final _AboutPalette palette;
  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: motion,
        builder: (context, child) {
          final wave = math.sin(motion.value * math.pi * 2);
          return Transform.translate(
            offset: Offset(0, wave * 4.5),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 34),
          child: SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 170,
                  height: 170,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.surfaceStrong,
                    borderRadius: BorderRadius.circular(42),
                    border: Border.all(
                      color: palette.gold.withOpacity(0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.36),
                        blurRadius: 48,
                        offset: const Offset(0, 22),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset(
                      'assets/about/parsa-apps-logo.webp',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const Positioned(
                  top: -43,
                  right: 43,
                  child: _CrownArtwork(width: 84),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _Sparkle(motion: motion, phase: 0.1, size: 13),
                ),
                Positioned(
                  top: 57,
                  left: 6,
                  child: _Sparkle(motion: motion, phase: 0.45, size: 11),
                ),
                Positioned(
                  top: 3,
                  left: 34,
                  child: _Sparkle(motion: motion, phase: 0.8, size: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FounderInformation extends StatelessWidget {
  const _FounderInformation({required this.palette, required this.centered});

  final _AboutPalette palette;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          AppLegal.developerName,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: AppFonts.vazirmatn(
            color: palette.gold,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFEF7A1A), Color(0xFFFBD06F)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x59EF7A1A),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            '👨‍💻 بنیان‌گذار، برنامه‌نویس و مدیر پارسا اپس',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              color: const Color(0xFF3D2600),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'پشت پارسا اپس یک مهندس نرم‌افزار متعهد ایستاده است که سال‌هاست با سخت‌گیری مهندسی، '
          'کدنویسی تمیز و تمرکز روی جزئیات، محصولات دیجیتال می‌سازد. هر خط کد با تست و بازبینی، '
          'هر صفحه با استانداردهای تجربه کاربری فارسی و RTL، و هر انتشار با رعایت اصول امنیت '
          'و کیفیت انجام می‌شود؛ چون اینجا یک پروژه معمولی نیست — یک برند حرفه‌ای است.',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: AppFonts.vazirmatn(
            color: palette.muted,
            fontSize: 15.5,
            height: 2.05,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '— فرشاد پارسا، مدیر پارسا اپس',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: AppFonts.vazirmatn(
            color: palette.gold,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _UpcomingGrid extends StatelessWidget {
  const _UpcomingGrid({required this.palette, required this.motion});

  final _AboutPalette palette;
  final Animation<double> motion;

  static const List<_UpcomingApp> _apps = [
    _UpcomingApp(
      title: 'باغ الفبا',
      description:
          'یادگیری حروف و الفبای فارسی با بازی و ماجراجویی در یک باغ جادویی؛ مخصوص پیش‌دبستانی و دبستان.',
      asset: 'assets/about/upcoming/bagh-alfaba.webp',
    ),
    _UpcomingApp(
      title: 'قصه‌های شب فندقی',
      description:
          'قصه‌های صوتی و تعاملی قبل از خواب با شخصیت‌های محبوب؛ آرامش، خیال‌پردازی و خواب شیرین.',
      asset: 'assets/about/upcoming/gheseh-shab.webp',
    ),
    _UpcomingApp(
      title: 'ریاضیدان کوچولو',
      description:
          'آموزش شیرین ریاضی با بازی، جایزه و چالش‌های مرحله‌ای؛ از شمارش تا ضرب، بدون استرس.',
      asset: 'assets/about/upcoming/riyazidan.webp',
    ),
    _UpcomingApp(
      title: 'آشپزخانه فندقی',
      description:
          'بازی آشپزی و آموزش تغذیه سالم؛ دستور پخت‌های ساده و سرگرم‌کننده برای کودکان و خانواده.',
      asset: 'assets/about/upcoming/ashpazkhaneh.webp',
    ),
    _UpcomingApp(
      title: 'سیاره‌نما',
      description:
          'ماجراجویی فضایی و آشنایی کودکان با ستاره‌ها، سیاره‌ها و نجوم؛ با گرافیک خیره‌کننده.',
      asset: 'assets/about/upcoming/sayarehnama.webp',
    ),
    _UpcomingApp(
      title: 'نگارخانه فندقی',
      description:
          'استودیوی نقاشی و خلاقیت کودکان؛ ابزارهای حرفه‌ای، براش‌های جادویی و آلبوم شاهکارها.',
      asset: 'assets/about/upcoming/negar-khaneh.webp',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 26.0;
        final columns = math.min(
          2,
          math.max(1, ((constraints.maxWidth + gap) / (250 + gap)).floor()),
        );
        final itemWidth =
            (constraints.maxWidth - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var index = 0; index < _apps.length; index++)
              SizedBox(
                width: itemWidth,
                child: _UpcomingCard(
                  app: _apps[index],
                  palette: palette,
                  motion: motion,
                  phase: index / _apps.length,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.app,
    required this.palette,
    required this.motion,
    required this.phase,
  });

  final _UpcomingApp app;
  final _AboutPalette palette;
  final Animation<double> motion;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      distance: 10,
      child: Container(
        constraints: const BoxConstraints(minHeight: 292),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(palette.isLight ? 0.07 : 0.20),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 28,
              left: 28,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      palette.gold.withOpacity(0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: motion,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          app.asset,
                          width: 94,
                          height: 94,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                      builder: (context, child) {
                        final wave = math.sin(
                          (motion.value + phase) * math.pi * 2,
                        );
                        return Transform.translate(
                          offset: Offset(0, wave * 4),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: palette.gold.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.36),
                                  blurRadius: 26,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: child,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    app.title,
                    style: AppFonts.vazirmatn(
                      color: palette.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    app.description,
                    style: AppFonts.vazirmatn(
                      color: palette.muted,
                      fontSize: 14.5,
                      height: 1.9,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFFEF7A1A), Color(0xFFFBD06F)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x59EF7A1A),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  'به‌زودی',
                  style: AppFonts.vazirmatn(
                    color: const Color(0xFF3D2600),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactGrid extends StatelessWidget {
  const _ContactGrid({
    required this.palette,
    required this.motion,
    required this.destinations,
  });

  final _AboutPalette palette;
  final Animation<double> motion;
  final List<_ContactDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 22.0;
        final columns = math.min(
          4,
          math.max(1, ((constraints.maxWidth + gap) / (165 + gap)).floor()),
        );
        final itemWidth =
            (constraints.maxWidth - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var index = 0; index < destinations.length; index++)
              SizedBox(
                width: itemWidth,
                child: _ContactCard(
                  destination: destinations[index],
                  palette: palette,
                  motion: motion,
                  phase: index / destinations.length,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.destination,
    required this.palette,
    required this.motion,
    required this.phase,
  });

  final _ContactDestination destination;
  final _AboutPalette palette;
  final Animation<double> motion;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${destination.name}؛ ${destination.meta}',
      child: _HoverLift(
        distance: 9,
        child: Material(
          color: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: palette.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: destination.onTap,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 0,
                  right: 24,
                  left: 24,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          palette.gold.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: motion,
                          builder: (context, _) {
                            final normalized =
                                (motion.value + phase) % 1.0;
                            final haloScale = 0.75 + normalized * 0.85;
                            final haloOpacity = 0.86 * (1 - normalized);
                            return SizedBox(
                              width: 104,
                              height: 94,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.scale(
                                    scale: haloScale,
                                    child: Opacity(
                                      opacity: haloOpacity,
                                      child: Container(
                                        width: 74,
                                        height: 74,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: destination.glowColor,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 74,
                                    height: 74,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: destination.colors,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: destination.glowColor
                                              .withOpacity(0.40),
                                          blurRadius: 28,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      destination.icon,
                                      color: destination.iconColor,
                                      size: 33,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        destination.name,
                        textAlign: TextAlign.center,
                        style: AppFonts.vazirmatn(
                          color: palette.text,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        destination.meta,
                        textAlign: TextAlign.center,
                        style: AppFonts.vazirmatn(
                          color: palette.muted,
                          fontSize: 12.5,
                          height: 1.8,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.text,
    required this.palette,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final _AboutPalette palette;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: textAlign,
        style: AppFonts.vazirmatn(
          color: palette.gold,
          fontSize: 25,
          fontWeight: FontWeight.w800,
          height: 1.5,
        ),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({
    required this.palette,
    required this.text,
    this.textAlign = TextAlign.start,
  });

  final _AboutPalette palette;
  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: textAlign,
        style: AppFonts.vazirmatn(
          color: palette.muted,
          fontSize: 16,
          height: 2.05,
        ),
      ),
    );
  }
}

class _GradientTitle extends StatelessWidget {
  const _GradientTitle({required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFFF9800), Color(0xFFFFD43B)],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppFonts.vazirmatn(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1.35,
        ),
      ),
    );
  }
}

class _AboutBackdrop extends StatelessWidget {
  const _AboutBackdrop({required this.palette, required this.progress});

  final _AboutPalette palette;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final wave = math.sin(progress * math.pi * 2);
    final drift = math.sin((progress + 0.25) * math.pi * 2);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.background, palette.backgroundSecondary],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -70,
            right: -60,
            child: Transform.translate(
              offset: Offset(wave * 34, drift * 24),
              child: _GlowOrb(
                color: palette.violet,
                opacity: palette.isLight ? 0.22 : 0.18,
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -90,
            child: Transform.translate(
              offset: Offset(-drift * 30, wave * 22),
              child: _GlowOrb(
                color: palette.leaf,
                opacity: palette.isLight ? 0.20 : 0.17,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.42,
            right: MediaQuery.sizeOf(context).width * 0.24,
            child: Transform.translate(
              offset: Offset(drift * 28, -wave * 20),
              child: _GlowOrb(
                color: palette.orange,
                opacity: palette.isLight ? 0.16 : 0.12,
                size: 230,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: MediaQuery.sizeOf(context).width * 0.12,
            child: Transform.translate(
              offset: Offset(wave * 24, drift * 16),
              child: _GlowOrb(
                color: palette.gold,
                opacity: palette.isLight ? 0.14 : 0.09,
                size: 210,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.opacity, this.size = 300});

  final Color color;
  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity * 0.34),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(opacity),
              blurRadius: 110,
              spreadRadius: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({
    required this.motion,
    required this.phase,
    required this.size,
  });

  final Animation<double> motion;
  final double phase;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (context, _) {
        final pulse =
            (math.sin((motion.value + phase) * math.pi * 2) + 1) / 2;
        return Opacity(
          opacity: 0.35 + pulse * 0.65,
          child: Transform.scale(
            scale: 0.8 + pulse * 0.35,
            child: Text(
              '✦',
              style: TextStyle(
                color: const Color(0xFFFBD06F),
                fontSize: size,
                shadows: const [
                  Shadow(color: Color(0xE6FBD06F), blurRadius: 14),
                  Shadow(color: Color(0x80FBD06F), blurRadius: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HoverLift extends StatefulWidget {
  const _HoverLift({required this.child, required this.distance});

  final Widget child;
  final double distance;

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: const Cubic(0.2, 0.8, 0.2, 1),
        transform: Matrix4.translationValues(
          0,
          _hovered ? -widget.distance : 0,
          0,
        ),
        child: widget.child,
      ),
    );
  }
}
